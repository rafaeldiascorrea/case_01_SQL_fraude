/* ======================================================================
   ANÁLISE DE FRAUDE EM TRANSAÇÕES - QUERIES ANALÍTICAS
   BASE: abt_fraude (150.000 linhas * 20 colunas). GRÃO = 1 TRANSAÇÃO
   DIALETO: BIGQUERY (GOOGLESQL/ STANDARD SQL)

   CONTEXTO DO CASE:
   AGORA A LIDERANÇA DE RISCO CHEGA COM UM PEDIDO ABERTO: ELES PRECISAM -
   DECIDIR ONDE INVESTIR NO PRÓXIMO TRIMESTRE - APERTAR REGRAS, TREINAR -
   UM NOVO MODELO, COLOCAR REVISÃO MANUAL EM ALGUM SEGMENTO - E QUEREM  -
   QUE VOCÊ DIGA ONDE ESTÁ O PROBLEMA.
====================================================================== */

/* ----------------------------------------------------------------------
   1. PANORAMA - TAMANHO DO PROBLEMA
   ANTES DE RECORTAR POR SEGMENTO, PRECISA-SE DA LINHA DE BASE: QUÃO    -
   GRANDE É O PROBLEMA EM NÚMERO E EM DINHEIRO?
---------------------------------------------------------------------- */

SELECT
  COUNT(*)                                                         AS total,
  SUM(fraude)                                                      AS fraudes,
  ROUND(100.0*AVG(fraude), 3)                                      AS taxa_fraude_pct,
  ROUND(SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END), 2) AS valor_exposto,
  ROUND(AVG(CASE WHEN fraude = 1 THEN valor_compra END), 2)        AS ticket_medio_fraude,
  ROUND(AVG(valor_compra), 2)                                      AS ticket_medio_geral,
FROM `posrafaunipds2026.capstone_fraude.abt_fraude`;

/* ----------------------------------------------------------------------
   2. FRAUDE POR PAIS (JOIN COM DIMENSÃO * PISO DE VOLUME)
   O PRIMEIRO RECORTE NATURAL: O RISCO É O MESMO EM TODO LUGAR OU TEM   -
   GEOGRAFIA?
   O HAVING DESCARTA PRAÇAS PEQUENAS DEMAIS PARA UMA TAXA CONFIÁVEL
---------------------------------------------------------------------- */

SELECT
   p.nome_pais,
   p.regiao,
   COUNT(*)                    AS transacoes,
   ROUND(100.0*AVG(fraude), 2) AS taxa_fraude_pct,
FROM `posrafaunipds2026.capstone_fraude.abt_fraude` a
JOIN `posrafaunipds2026.capstone_fraude.dim_paises` p 
   ON p.sigla_pais = a.pais
GROUP BY p.nome_pais, p.regiao
HAVING COUNT(*) >= 1000
ORDER BY taxa_fraude_pct DESC;

/* ----------------------------------------------------------------------
   3. RISCO CADASTRADO VS. REALIDADE (JOIN COM DIM_CATEGORIAS)
   A EMPRESA CLASSIFICOU AS CATEGORIAS COMO RISCO BAIXO/MEDIO/ALTO. ANTES
   DE CONFIAR NESSA ETIQUETA PARA TOMAR DECISÃO, PRECISAMOS TESTAR SE ELA
   BATE COM A FRAUDE OBSERVADA
---------------------------------------------------------------------- */

SELECT
   c.nivel_risco_categoria,
   COUNT(*)                    AS transacoes,
   ROUND(100.0*AVG(fraude), 2) AS taxa_fraude_pct
FROM `posrafaunipds2026.capstone_fraude.abt_fraude` a
JOIN `posrafaunipds2026.capstone_fraude.dim_categorias` c
   ON c.id_categoria = a.categoria_produto
GROUP BY c.nivel_risco_categoria
ORDER BY taxa_fraude_pct DESC;


/* ----------------------------------------------------------------------
   4. FRAUDE POR FAIXA DE VALOR (CASE WHEN)
   TRANSFORMA O VALOR CONTINUO EM FAIXAS COMPARÁVEIS
---------------------------------------------------------------------- */

SELECT
   CASE
      WHEN valor_compra < 100 THEN '1) até 100'
      WHEN valor_compra < 500 THEN '2) 100-500'
      ELSE                         '3) acima de 500'
      END             AS faixa_valor,
   COUNT(*)           AS transacoes,
   ROUND(100.0*AVG(fraude), 2) AS taxa_fraude_pct
FROM `posrafaunipds2026.capstone_fraude.abt_fraude`
GROUP BY faixa_valor
ORDER BY faixa_valor;

-------------------------------------------------------------------------
------- COMPARANDO TAXA DE FRAUDE E ONDE ESTÁ O DINHEIRO POR FAIXA ------
-------------------------------------------------------------------------

WITH base AS(
   SELECT
      CASE
         WHEN valor_compra <  100 THEN '1) ate 100'
         WHEN valor_compra <  500 THEN '2) 100-500'
         WHEN valor_compra >= 500 THEN '3) acima de 500'
         ELSE                          '4) valor NULL' -- separa valor nulo ao invés de escondê-los
      END AS faixa_valor,
      fraude,
      valor_compra,
   FROM `capstone_fraude.abt_fraude`
)
SELECT
   faixa_valor,
   COUNT(*)                                                          AS transacoes,
   SUM(fraude)                                                       AS fraude,
   ROUND(100.0 * SUM(fraude) / COUNT(*), 2)                          AS taxa_fraude_pct,
      -- % das fraudes daquela faixa sobre o total de fraudes --
   ROUND(100.0 * SUM(fraude) / SUM(SUM(fraude)) OVER(),1)            AS pct_dos_casos,
   ROUND(SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END), 2)  AS valor_exposto,
   ROUND(SUM( CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END)
     /SUM(SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END))
      OVER(), 1)                                                    AS pct_do_valor,
   ROUND(SAFE_DIVIDE(
      SUM(CASE WHEN fraude = 1 THEN valor_compra ELSE 0 END),
      SUM(fraude)
   ), 2)                                                            AS perda_media_por_fraude      
FROM base
GROUP BY faixa_valor
ORDER BY faixa_valor;

/* -------------------------------------------------------------------
   5. O SCORE DO MODELO SEPARA FRAUDE? (NTILE - FUNÇÃO DE JANELA)
   DIVIDE A BASE EM 10 FAIXAS IGUAIS POR SCORE E MEDE A TAXA EM CADA UMA.
   ESPERA=SE QUE A TAXA CRESÇA DE FORMA CONSISTENTE DO DECIL 1 AO 10.
---------------------------------------------------------------------- */

WITH faixas AS (
   SELECT
      fraude,
      NTILE(10) OVER (ORDER BY score_fraude_modelo) AS decil
   FROM `capstone_fraude.abt_fraude`
)
SELECT
   decil,
   COUNT(*)                    AS transacoes,
   ROUND(100.0*AVG(fraude), 2) AS taxa_fraude_pct
FROM faixas
GROUP BY decil
ORDER BY decil;
-- 1:2,77   2:4,59   3:3,33   4:0,31   5:0,62   6:1,27   7:2,05   8:5,10   9:8,63   10:21,33
-- LEITURA: separa bem só no topo (decil 10 =~ 4x a base): o meio não é monotonico.

