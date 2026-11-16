------------------ PROJETO FRAUDE ------------------
-------- PARTE 01. CONSTRUÇÃO DA abt_fraude --------
----------------------------------------------------

-- Exploração das tabelas: transacao, scores_modelo, scores_financeiros
-- Mostrar apenas dados enriquecidos onde a transação exista em todas as bases de score

-- Seleção das colunas

--- transações: t.entrega_doc_1, t.entrega_doc_2, t.entrega_doc_3, t.data_compra, t.valor_compra, t.pais, t.produto, t.categoria_produto
--- scores_modelo: mo.score_8, mo.score_fraude_modelo, mo.fraude
--- scores_comportamentais: cb.score_1, cb.score_2, cb.score_4, cb.score_5, cb.score_7
--- scores_financeiros: fi.score_3, fi.score_6. fi.score_9, fi.score_10,

--- CRITÉRIO DE ACEITE: 150000 TRANSAÇÕES

--- QUERY PRINCIPAL

CREATE TABLE `posrafaunipds2026.capstone_fraude.abt_fraude` AS (
SELECT
  t.entrega_doc_1,
  t.entrega_doc_2,
  t.entrega_doc_3,
  t.data_compra,
  t.valor_compra,
  t.pais,
  t.produto,
  t.categoria_produto,
  mo.score_8,
  mo.score_fraude_modelo,
  mo.fraude,
  cb.score_1,
  cb.score_2,
  cb.score_4,
  cb.score_5,
  cb.score_7,
  fi.score_3,
  fi.score_6,
  fi.score_9,
  fi.score_10,
FROM posrafaunipds2026.capstone_fraude.transacoes t
JOIN posrafaunipds2026.capstone_fraude.scores_comportamentais cb ON cb.id_transacao = t.id_transacao
JOIN posrafaunipds2026.capstone_fraude.scores_financeiros fi ON fi.id_transacao = t.id_transacao
JOIN posrafaunipds2026.capstone_fraude.scores_modelo mo ON mo.id_transacao = t.id_transacao
WHERE t.is_teste = 0);


