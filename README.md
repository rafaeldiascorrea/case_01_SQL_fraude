# Case 01 — Análise de Fraudes com SQL

Projeto de análise de dados desenvolvido para investigar o comportamento das fraudes em uma base transacional. O estudo utiliza **SQL** para construir indicadores, segmentar o risco e avaliar se o score do modelo consegue separar transações fraudulentas de transações legítimas.

A análise combina três perspectivas:

- **dimensão do problema:** quantidade de fraudes, taxa geral e valor financeiro exposto;
- **concentração do risco:** país, categoria e faixa de valor;
- **efetividade do modelo:** distribuição das fraudes por decil do score e implicações para priorização operacional.

> **Resultado geral:** foram analisadas **150.000 transações**, com **7.500 fraudes**, taxa geral de **5,0%** e aproximadamente **R$ 547 mil em valor exposto**.

---

## Principais resultados

| Análise | Principal conclusão |
|---|---|
| Panorama geral | Uma em cada 20 transações foi classificada como fraude. |
| Geografia | O Brasil combina o maior volume com a maior taxa entre os países com volume relevante: 5,52%. |
| Categoria de risco | A classificação baixo, médio e alto apresenta baixa discriminação; o nível médio supera o alto. |
| Faixa de valor | A taxa cresce de 4,60% nas transações de até R$ 100 para 14,95% acima de R$ 500. |
| Impacto financeiro | Até R$ 100 concentra a maioria dos casos, mas as faixas superiores concentram proporcionalmente mais valor. |
| Score do modelo | O decil 10 registra taxa de 21,33% e concentra 42,7% das fraudes, embora existam quebras de ordenação nos decis intermediários. |

---

## Gráficos da análise

### 1. Panorama do problema

![Gráfico 01 — Panorama do tamanho do problema](assets/01%20-%20Querie%2001.png)

### 2. Fraude por país

![Gráfico 02 — Fraude por país](assets/02%20-%20Querie%2002.png)

### 3. Risco cadastrado versus realidade

![Gráfico 03 — Risco cadastrado versus fraude observada](assets/03%20-%20Querie%2003.png)

### 4.1. Fraude por faixa de valor

![Gráfico 04-01 — Fraude por faixa de valor](assets/04%20-%20Querie%2004-01.png)

### 4.2. Casos e valor exposto por faixa

![Gráfico 04-02 — Taxa de fraude e concentração financeira](assets/04%20-%20Querie%2004-02.png)

### 5. Score do modelo por decil

![Gráfico 05 — Taxa de fraude por decil do score](assets/05%20-%20Querie%2005.png)

---

## Estrutura do repositório

```text
case_01_SQL_fraude/
├── apresentacao/   # Apresentações executivas em PowerPoint e PDF
├── assets/         # Imagens dos gráficos utilizados no projeto
├── queries/        # Consultas SQL construídas para cada etapa da análise
├── relatorio/      # Relatórios executivo e técnico em DOCX, PDF e Markdown
└── README.md       # Visão geral e navegação do projeto
```

### Onde encontrar cada conteúdo

| Pasta | Conteúdo |
|---|---|
| [`apresentacao/`](apresentacao/) | Apresentação executiva com os principais resultados, implicações de negócio e plano de ação. |
| [`assets/`](assets/) | Gráficos gerados para documentar visualmente os resultados das consultas. |
| [`queries/`](queries/) | Queries SQL utilizadas no panorama, recortes por país e valor, validação das categorias e avaliação do score. |
| [`relatorio/`](relatorio/) | Relatório detalhado em Markdown, Word e PDF, incluindo metodologia, interpretação e análises adicionais. |

---

## Perguntas respondidas

O projeto foi estruturado para responder às seguintes perguntas:

1. Qual é o tamanho do problema em quantidade e valor?
2. O risco de fraude é igual em todos os países?
3. A classificação de risco das categorias corresponde à fraude observada?
4. O valor da transação altera a probabilidade de fraude?
5. Onde estão os casos e onde está concentrado o valor financeiro?
6. O score do modelo ordena corretamente as transações por risco?
7. Quais análises e controles podem ser priorizados a partir dos resultados?

---

## Metodologia

As consultas usam recursos de SQL voltados à análise de dados, incluindo:

- agregações com `COUNT`, `SUM` e `AVG`;
- cálculos condicionais com `CASE WHEN`;
- junções com dimensões de país e categoria;
- filtros de volume com `HAVING`;
- funções de janela com `NTILE`;
- cálculo de taxas, participações e indicadores financeiros;
- comparação entre risco cadastrado e resultado observado.

Para reduzir conclusões instáveis, os recortes geográficos consideram um piso mínimo de volume. Na análise do score, a base foi dividida em dez grupos de mesmo tamanho, ordenados do menor para o maior score.

---

## Recomendações executivas

- Priorizar controles no **Brasil**, onde estão o maior volume e a maior quantidade absoluta de fraudes.
- Aplicar regras progressivas por **faixa de valor**, pois a taxa cresce com o valor da transação.
- Revisar a classificação de categorias em **baixo, médio e alto**, já que a ordenação esperada não foi confirmada.
- Usar o score como instrumento de **priorização**, principalmente nos decis 9 e 10, e não como regra automática isolada.
- Definir thresholds com base em **precisão, recall, capacidade de revisão, valor evitado e custo de falso positivo**.
- Monitorar estabilidade por período e segmento antes de implantar decisões permanentes.

---

## Relatório completo

A interpretação detalhada dos gráficos, limitações, análises complementares e plano executivo está disponível em:

- [`relatorio/Relatorio_Executivo_Analise_de_Fraudes_GitHub.md`](relatorio/Relatorio_Executivo_Analise_de_Fraudes_GitHub.md)
- [`relatorio/`](relatorio/) — demais formatos do relatório.

---

## Apresentação executiva

A versão resumida para apresentação a executivos está disponível na pasta:

- [`apresentacao/`](apresentacao/)

---

## Tecnologias e conceitos

- **Google BigQuery / SQL**
- análise exploratória de dados;
- segmentação de risco;
- prevenção a fraudes;
- funções de janela;
- métricas de classificação;
- visualização de dados;
- comunicação executiva de resultados.

---

## Repositório

Acesse o projeto completo em:

[github.com/rafaeldiascorrea/case_01_SQL_fraude](https://github.com/rafaeldiascorrea/case_01_SQL_fraude/tree/main)

---

## Observações

Os resultados representam a base analisada e devem ser validados em períodos adicionais antes da implantação em produção. Uma política antifraude deve considerar não apenas a taxa de detecção, mas também perdas financeiras, custo operacional, falsos positivos e impacto sobre clientes legítimos.
