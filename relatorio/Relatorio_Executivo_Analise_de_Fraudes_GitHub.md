# Análise Executiva de Fraudes

**Diagnóstico do risco, concentração financeira e efetividade do score**

> **Escopo:** 150.000 transações, 7.500 fraudes confirmadas, taxa geral de 5,0% e R$ 547.271,12 em valor exposto.  
> **Período da base:** 08/03/2020 a 21/04/2020.

---

## Sumário

1. [Resumo executivo](#1-resumo-executivo)
2. [Base, metodologia e qualidade dos dados](#2-base-metodologia-e-qualidade-dos-dados)
3. [Panorama e materialidade financeira](#3-panorama-e-materialidade-financeira)
4. [Geografia do risco](#4-geografia-do-risco)
5. [Risco cadastrado versus fraude observada](#5-risco-cadastrado-versus-fraude-observada)
6. [Fraude por faixa de valor](#6-fraude-por-faixa-de-valor)
7. [Casos versus concentração financeira](#7-casos-versus-concentração-financeira)
8. [Efetividade do score](#8-efetividade-do-score)
9. [Thresholds e trade-off operacional](#9-thresholds-e-trade-off-operacional)
10. [Evidências nos campos de documentação](#10-evidências-nos-campos-de-documentação)
11. [Comportamento temporal](#11-comportamento-temporal)
12. [Análises adicionais recomendadas](#12-análises-adicionais-recomendadas)
13. [Plano executivo de 90 dias](#13-plano-executivo-de-90-dias)
14. [Conclusão](#14-conclusão)

---

## 1. Resumo executivo

A base registra **150 mil transações**, **7.500 fraudes** e taxa geral de **5,0%**. O valor associado às transações fraudulentas é de **R$ 547,3 mil**. O ticket médio fraudulento, de **R$ 72,97**, é **67,7% maior** que o ticket geral de R$ 43,52.

### Principais conclusões

- **O Brasil é o principal foco:** reúne 111.628 transações e taxa de fraude de 5,52%, combinando escala e incidência.
- **O risco aumenta com o valor:** a taxa passa de 4,60% nas transações de até R$ 100 para 14,95% acima de R$ 500.
- **Casos e dinheiro estão em lugares diferentes:** até R$ 100 concentram 84,2% dos casos, enquanto a faixa de R$ 100 a R$ 500 concentra 42,6% do valor exposto.
- **A classificação cadastral discrimina pouco:** o nível médio apresenta 5,21% de fraude, acima do nível alto, com 5,06%.
- **O score possui capacidade preditiva moderada:** ROC-AUC de 0,726 e forte concentração no topo, mas com quebras de ordenação nos decis intermediários.
- **Um corte único não é recomendado:** os thresholds precisam considerar capacidade de revisão, custo de falso positivo, recall e valor financeiro evitado.

> [!IMPORTANT]
> **Recomendação central:** executar um piloto de 90 dias com políticas segmentadas por país e valor, score usado como priorizador e limites explícitos para falsos positivos.

---

## 2. Base, metodologia e qualidade dos dados

Os três CSVs anexados têm o mesmo tamanho e o mesmo conteúdo binário. Portanto, são cópias da mesma tabela, e não três partes distintas. A análise utiliza uma única cópia com **150.000 registros**, evitando triplicar artificialmente a amostra.

| Dimensão | Avaliação |
|---|---|
| Granularidade | Uma linha por transação |
| Variável-alvo | `fraude`, binária 0/1 |
| Score principal | `score_fraude_modelo`, escala de 0 a 100 |
| Janela temporal | 45 dias, de 08/03 a 21/04/2020 |
| País ausente | 0,13% |
| `entrega_doc_2` ausente | 72,57% |
| `score_2` e `score_3` ausentes | 8,66% cada |
| `score_4` e `score_10` ausentes | 0,24% cada |

### Limitações

1. A janela de 45 dias é curta para conclusões sobre sazonalidade, estabilidade e drift.
2. O valor exposto é uma aproximação de perda. Recuperações, chargeback, margem e custos operacionais não estão disponíveis.
3. Ausências podem representar falha de captura, não aplicabilidade ou informação operacional relevante.
4. As classificações de país e risco de categoria dependem de dimensões externas utilizadas nas consultas originais.

---

## 3. Panorama e materialidade financeira

![Panorama do tamanho do problema](../assets/01%20-%20Querie%20-%2001.png)

| Indicador | Resultado |
|---|---:|
| Transações | 150.000 |
| Fraudes | 7.500 |
| Taxa de fraude | 5,0% |
| Valor exposto | R$ 547.271,12 |
| Ticket médio da fraude | R$ 72,97 |
| Ticket médio geral | R$ 43,52 |

Cinco por cento das transações foram classificadas como fraude, ou **uma em cada vinte**. A exposição representa aproximadamente **8,38% do valor transacionado**, que totaliza R$ 6,53 milhões.

O ticket médio fraudulento supera o ticket geral em R$ 29,45. Assim, reduzir apenas a quantidade de ocorrências não é suficiente. A gestão deve acompanhar simultaneamente:

- taxa de fraude;
- quantidade de casos;
- valor exposto;
- perda média por ocorrência;
- valor líquido evitado;
- custo dos falsos positivos.

---

## 4. Geografia do risco

![Fraude por país](../assets/02%20-%20Querie%20-%2002.png)

| País | Transações | Fraudes | Taxa de fraude |
|---|---:|---:|---:|
| Brasil | 111.628 | 6.162 | 5,52% |
| Argentina | 31.964 | 1.179 | 3,69% |
| Estados Unidos | 2.273 | 70 | 3,08% |
| Uruguai | 2.967 | 29 | 0,98% |

O Brasil concentra aproximadamente **74,4% das transações** e **82,2% das fraudes**. Pequenas melhorias no processo brasileiro têm maior potencial de impacto absoluto.

O piso de volume deve ser mantido. Países com poucas observações podem apresentar taxas extremas por variação amostral, sem representar risco estrutural.

### Implicações

- Calibrar thresholds por país, evitando uma política global indiferenciada.
- Avaliar a interação entre país e faixa de valor.
- Aplicar intervalos de confiança binomiais e shrinkage bayesiano em mercados pequenos.
- Monitorar PSI do score e taxa de fraude separadamente por país.

---

## 5. Risco cadastrado versus fraude observada

![Risco cadastrado versus realidade](../assets/03%20-%20Querie%20-%2003.png)

| Nível cadastrado | Transações | Taxa observada |
|---|---:|---:|
| Baixo | 49.542 | 4,74% |
| Médio | 47.079 | 5,21% |
| Alto | 53.379 | 5,06% |

A ordenação esperada seria **baixo < médio < alto**. O resultado observado é **baixo < alto < médio**. Além da inversão, a amplitude entre a maior e a menor taxa é de apenas **0,47 ponto percentual**.

Essa etiqueta apresenta baixo poder de discriminação e não deve ser usada isoladamente em bloqueios ou decisões financeiras.

### Testes recomendados

- qui-quadrado para associação entre nível e fraude;
- teste de diferença de proporções;
- Information Value e Weight of Evidence;
- estabilidade por período, país e faixa de valor;
- revisão da regra que define baixo, médio e alto.

---

## 6. Fraude por faixa de valor

![Fraude por faixa de valor](../assets/04%20-%20Querie%2004-01.png)

| Faixa | Transações | Taxa de fraude | Participação no volume |
|---|---:|---:|---:|
| Até R$ 100 | 137.284 | 4,60% | 91,5% |
| R$ 100 a R$ 500 | 11.679 | 8,84% | 7,8% |
| Acima de R$ 500 | 1.037 | 14,95% | 0,7% |

A taxa cresce de maneira monotônica. A faixa acima de R$ 500 apresenta risco **3,25 vezes maior** que a faixa de até R$ 100.

O valor da transação é, portanto, uma variável operacionalmente interpretável para políticas progressivas. Uma prática possível é combinar faixas de valor com bandas de score:

- **baixo valor + score baixo:** aprovação ou monitoramento;
- **valor intermediário + score alto:** autenticação adicional;
- **alto valor + score muito alto:** revisão prioritária ou bloqueio condicionado à matriz de custos.

---

## 7. Casos versus concentração financeira

![Taxa de fraude e concentração financeira](../assets/04%20-%20Querie%2004-02.png)

| Faixa | Casos de fraude | % dos casos | Valor exposto | % do valor | Perda média |
|---|---:|---:|---:|---:|---:|
| Até R$ 100 | 6.313 | 84,2% | R$ 169.628,21 | 31,0% | R$ 26,87 |
| R$ 100 a R$ 500 | 1.032 | 13,8% | R$ 233.386,93 | 42,6% | R$ 226,15 |
| Acima de R$ 500 | 155 | 2,1% | R$ 144.255,98 | 26,4% | R$ 930,68 |

A maior quantidade de casos está nas transações menores, mas a maior parcela financeira está na faixa intermediária. A faixa superior possui poucos casos e grande severidade.

### Estratégia dual

1. **Redução de volume:** controles automatizados de baixo atrito nas transações menores.
2. **Proteção de valor:** controles mais rigorosos nas faixas intermediária e superior.
3. **Métrica econômica:** usar perda esperada e valor líquido evitado, não somente quantidade de casos capturados.

---

## 8. Efetividade do score

![Score por decil](../assets/05%20-%20Querie%2005.png)

O decil 10 apresenta taxa de **21,33%**, contra 2,81% no decil 1. O último decil concentra **42,7% das fraudes em 10% das transações**. Os decis 9 e 10, juntos, concentram aproximadamente 60% dos casos.

Por outro lado, a sequência não é monotônica nos decis inferiores. D2 supera D3, e a taxa cai para 0,30% em D4 antes de voltar a crescer.

### Métricas globais

| Métrica | Resultado | Interpretação |
|---|---:|---|
| ROC-AUC | 0,726 | Discriminação moderada |
| Average Precision | 0,176 | Superior à prevalência de 0,05, mas com ampla sobreposição |
| Lift D10 versus média | 4,27x | Forte concentração no topo |
| D10 versus D1 | 7,6x | Separação relevante entre extremos |

O score é útil para priorização, mas não deve ser usado como mecanismo de bloqueio sem calibração, avaliação econômica e monitoramento de estabilidade.

---

## 9. Thresholds e trade-off operacional

| Corte | Base enviada para revisão | Precisão | Recall | Fraudes capturadas | Legítimas sinalizadas |
|---|---:|---:|---:|---:|---:|
| Score >= 50 | 48,5% | 7,9% | 76,4% | 5.733 | 66.970 |
| Score >= 70 | 28,5% | 12,1% | 69,1% | 5.184 | 37.494 |
| Score >= 80 | 18,6% | 15,6% | 57,9% | 4.344 | 23.487 |
| Score >= 90 | 8,5% | 22,6% | 38,5% | 2.886 | 9.866 |
| Score >= 95 | 4,0% | 26,4% | 21,1% | 1.586 | 4.412 |

O corte 90 reduz a fila operacional para 8,5% da base, mas captura apenas 38,5% das fraudes. O corte 70 captura 69,1%, porém envia 42.678 transações para revisão.

### Política recomendada por bandas

| Banda | Tratamento sugerido |
|---|---|
| Risco muito alto + alto valor | Revisão prioritária ou bloqueio condicionado |
| Risco alto | Autenticação adicional |
| Risco intermediário | Regras contextuais por país e valor |
| Risco baixo | Aprovação e monitoramento |

A escolha final depende de capacidade diária, custo de revisão, margem, SLA, taxa de abandono e custo de falso positivo.

---

## 10. Evidências nos campos de documentação

Os campos `entrega_doc_1`, `entrega_doc_2` e `entrega_doc_3` apresentam diferenças relevantes de risco.

| Campo e status | Transações | Taxa de fraude |
|---|---:|---:|
| `entrega_doc_1 = 0` | 14.647 | 16,11% |
| `entrega_doc_1 = 1` | 135.353 | 3,80% |
| `entrega_doc_2 = ausente` | 108.857 | 2,05% |
| `entrega_doc_2 = False` | 17.052 | 21,75% |
| `entrega_doc_2 = True` | 24.091 | 6,45% |
| `entrega_doc_3 = False` | 66.871 | 7,60% |
| `entrega_doc_3 = True` | 83.129 | 2,91% |

Os diferenciais são fortes, mas os campos só devem ser utilizados após confirmar:

- significado de negócio;
- momento da captura;
- possível vazamento da variável-alvo;
- viés de seleção;
- estabilidade por período e segmento;
- ganho incremental sobre o score atual.

> [!WARNING]
> `entrega_doc_2` possui 72,57% de ausência. O valor ausente pode representar uma condição de processo, e não um simples dado faltante. Imputação automática pode destruir informação ou introduzir viés.

---

## 11. Comportamento temporal

| Mês | Transações | Fraudes | Taxa | Valor exposto |
|---|---:|---:|---:|---:|
| Março de 2020 | 76.961 | 3.877 | 5,04% | R$ 282.179,80 |
| Abril de 2020 | 73.039 | 3.623 | 4,96% | R$ 265.091,32 |

A diferença é de apenas 0,08 ponto percentual, mas a janela cobre dois meses incompletos. Não é possível concluir estabilidade estrutural ou ausência de sazonalidade.

Para produção, recomenda-se um painel semanal e mensal com:

- taxa e valor de fraude;
- mix por país e faixa de valor;
- precisão, recall e taxa de aprovação;
- PSI das variáveis e do score;
- atraso de confirmação da fraude;
- custo de revisão e valor recuperado.

---

## 12. Análises adicionais recomendadas

| Frente | Método | Entrega | Prioridade |
|---|---|---|---|
| Performance do score | ROC-AUC, PR-AUC, KS, lift e calibração | Relatório por período e segmento | Alta |
| Economia da decisão | Matriz de custos e expected loss | Threshold ótimo por política | Alta |
| Segmentação | País x valor x categoria | Mapa de risco e regras | Alta |
| Estabilidade | PSI, CSI e drift de conceito | Alertas mensais | Alta |
| Explicabilidade | SHAP e perfis de erro | Drivers e casos críticos | Média |
| Modelos challenger | LightGBM, XGBoost e regressão logística | Comparação out-of-time | Média |
| Anomalias | Isolation Forest e redes de relacionamento | Sinais de fraude emergente | Média |
| Causalidade operacional | Teste A/B ou rollout controlado | Impacto líquido das regras | Alta |

### Desenho de validação recomendado

1. Separar treino, validação e teste por tempo.
2. Manter amostra out-of-time.
3. Calcular métricas por país, faixa de valor e categoria.
4. Comparar campeão e challenger sob a mesma matriz de custos.
5. Registrar decisão, motivo, score, resultado posterior e valor recuperado.
6. Monitorar drift e recalibrar antes que a degradação afete as operações.

---

## 13. Plano executivo de 90 dias

### 0 a 30 dias — controle e visibilidade

- Instituir painel semanal com taxa, valor, país, faixa de valor e decis.
- Confirmar o dicionário dos campos `entrega_doc_*`.
- Definir capacidade de revisão e custo unitário de falso positivo.
- Criar regras temporárias de revisão para alto valor e score elevado.

### 31 a 60 dias — calibração e piloto

- Calcular KS, lift, calibração e intervalos de confiança.
- Desenhar bandas de decisão e piloto A/B com grupo de controle.
- Definir KPIs de valor evitado líquido, recall, precisão, aprovação e reclamação.
- Avaliar Platt scaling ou isotonic regression para recalibração.

### 61 a 90 dias — industrialização

- Selecionar modelo campeão e challenger com validação out-of-time.
- Automatizar monitoramento de PSI, performance e drift.
- Estabelecer fórum mensal com risco, operações, produto e dados.
- Documentar políticas de override, rollback e revisão de thresholds.

> [!IMPORTANT]
> **Decisão solicitada:** aprovar um piloto segmentado de 90 dias para medir benefício líquido, sem transformar o score em bloqueio automático indiscriminado.

---

## 14. Conclusão

A fraude é material e apresenta estrutura clara:

- o Brasil domina o impacto absoluto;
- o valor da transação diferencia risco;
- a concentração dos casos difere da concentração financeira;
- o score é útil para priorizar o topo;
- a classificação categórica baixo/médio/alto possui baixa discriminação;
- os decis intermediários do score exigem investigação e recalibração.

A resposta recomendada é uma arquitetura multicamada, combinando país, valor, score em bandas, autenticação adicional, revisão manual limitada pela capacidade e monitoramento econômico.

O sucesso deve ser medido em **valor líquido evitado**, incorporando perdas, custos operacionais, falsos positivos, abandono e impacto sobre clientes legítimos.

---

## Glossário

| Métrica | Definição |
|---|---|
| Precisão | Fraudes entre todas as transações sinalizadas |
| Recall | Fraudes capturadas entre todas as fraudes |
| ROC-AUC | Capacidade de ordenar fraude acima de não fraude |
| PR-AUC | Relação entre precisão e recall em classe rara |
| Lift | Ganho sobre uma seleção aleatória |
| PSI | Mudança da distribuição entre períodos |
| Calibração | Coerência entre probabilidade prevista e taxa observada |
| Falso positivo | Transação legítima sinalizada como fraude |
| Expected loss | Probabilidade de fraude multiplicada pelo impacto financeiro esperado |

---

## Estrutura utilizada no repositório

O relatório deve permanecer na pasta `relatorio`, enquanto as imagens ficam na pasta `assets`, ambas diretamente abaixo da raiz do repositório:

```text
case_01_SQL_fraude/
├── assets/
│   ├── 01 - Querie 01.png
│   ├── 02 - Querie 02.png
│   ├── 03 - Querie 03.png
│   ├── 04 - Querie 04-01.png
│   ├── 04 - Querie 04-02.png
│   └── 05 - Querie 05.png
└── relatorio/
    └── Relatorio_Executivo_Analise_de_Fraudes_GitHub.md
```

### Comandos Markdown utilizados para inserir as imagens

```markdown
![Gráfico 01 - Panorama do tamanho do problema](../assets/01%20-%20Querie%2001.png)
![Gráfico 02 - Fraude por país](../assets/02%20-%20Querie%2002.png)
![Gráfico 03 - Risco cadastrado versus realidade](../assets/03%20-%20Querie%2003.png)
![Gráfico 04-01 - Fraude por faixa de valor](../assets/04%20-%20Querie%2004-01.png)
![Gráfico 04-02 - Taxa de fraude e concentração financeira](../assets/04%20-%20Querie%2004-02.png)
![Gráfico 05 - Score do modelo por decil](../assets/05%20-%20Querie%2005.png)
```

Os espaços dos nomes dos arquivos foram codificados como `%20`. O prefixo `../` faz o GitHub sair da pasta `relatorio` e acessar a pasta irmã `assets`.

**Fonte:** base transacional fornecida pelo autor.  
**Observação:** as conclusões devem ser reavaliadas antes da implantação em produção, principalmente por causa da janela temporal limitada e da necessidade de incorporar custos operacionais e resultados out-of-time.
