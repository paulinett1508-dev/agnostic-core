System One Decision Models — decisões estruturadas fora do LLM generativo

Objetivo: usar um modelo de decisão estruturada (nao um LLM de texto livre) para
classificar, pontuar ou julgar conteudo de forma decidivel em codigo — roteamento,
triagem, scoring, checagem de condicao — mantendo o codigo, nunca o modelo, no
controle do fluxo.

Exemplo real usado como referencia neste documento: TypeSafe AI / modelo Jev
("System One model"), `POST https://api.typesafe.ai/v1/systemone`. O padrao e
agnostico de provider — qualquer modelo que devolva probabilidade calibrada sobre
uma pergunta tipada (em vez de prosa) se encaixa aqui.

---

QUANDO USAR ESTA SKILL vs. UM LLM GENERATIVO

Use um modelo de decisao estruturada quando a tarefa e **classificar, pontuar ou
julgar** algo de forma decidivel em codigo. NAO use para redigir respostas,
explicacoes ou qualquer texto para humanos — isso e sempre trabalho do LLM
generativo/agente, nunca do modelo de decisao.

Diferenca central: um LLM gera texto; um System One model responde uma pergunta
tipada com uma distribuicao de probabilidade calibrada. Nao ha "prompt" no sentido
tradicional — ha um `state` (o conteudo a avaliar) e um mapa de perguntas tipadas.

---

TRES TIPOS DE PERGUNTA (PRIMITIVAS)

Toda pergunta tem `type`, `instructions` (a pergunta em si, nunca a resposta
esperada) e, exceto Noul simples, `criteria`:

- **Choice**: `criteria` e um mapa `{opcao: descricao}`. Retorna a opcao vencedora,
  a distribuicao de probabilidade completa e uma confianca. Use quando a resposta
  e uma de um conjunto fixo SEM ordem (roteamento, categoria, tipo). Adicione
  sempre uma opcao "outro"/"nao se aplica" quando a lista pode nao cobrir tudo.
  Limite tipico: ate 255 opcoes.
- **Score**: `criteria` e uma lista ORDENADA de niveis descritivos. Retorna a
  posicao na escala (pode cair entre dois niveis), a legenda, a distribuicao e a
  confianca. Use para posicao num espectro (severidade, frustracao, potencial de
  lead). Limite tipico: entre 2 e 10 niveis.
- **Noul**: `criteria` opcional, mapa `{"true": descricao, "false": descricao}`.
  Retorna so a probabilidade (0 a 1) de ser verdadeiro — SEM confianca separada (a
  propria probabilidade ja e a medida de certeza). Use para pergunta binaria limpa.

Regra de ouro: cada pergunta deve ser um julgamento UNICO que uma pessoa competente
faria em segundos com o contexto certo. Nunca peca ao modelo para "analisar e
decidir o melhor curso de acao" de forma vaga — quebre em perguntas atomicas e
componha a decisao final em codigo.

---

QUATRO PADROES ARQUITETURAIS

O modelo de decisao nao e um agente — nao escolhe seu proprio proximo passo. O
codigo sempre fica no controle do fluxo; o modelo so entra onde e preciso "bom
senso programavel" sobre um pedaco de conteudo.

1. **Speculative Fan-Out**: mandar TODAS as perguntas relevantes numa unica
   chamada, inclusive as que so importam para alguns casos (ex.: severidade de bug
   so interessa se categoria == bug_report). Perguntas rodam em paralelo — quase
   nao muda a latencia e economiza uma segunda chamada de rede. O codigo ignora o
   que nao precisa.

2. **Confidence-Gated Routing**: usar a confianca/probabilidade como um SEGUNDO
   eixo de decisao, independente da resposta em si. O threshold nao e fixo — varia
   com o risco da acao (ex.: "ver saldo" pode agir com confianca >= 0.6; "aprovar
   transferencia" so acima de 0.85, senao pede confirmacao humana).

3. **Intent Routing**: classificar a intencao e rotear cada caso para o handler
   certo — codigo deterministico, um especialista, ou um humano — sem gastar um
   modelo caro em toda entrada so para descobrir do que se trata.

4. **Composite Scoring**: quebrar um julgamento amplo ("esse candidato e bom?") em
   varios scores independentes e atomicos (ex.: profundidade tecnica, lideranca,
   design de sistemas), normalizar cada um (`score / (n_niveis - 1)`) e combinar
   com PESOS que vivem no codigo — nunca pedir ao modelo para pesar os fatores.
   Trocar prioridade = mudar um numero no codigo, nunca reescrever uma instrucao.

Regra geral por tras dos quatro: **decisao ampla e vaga -> decomponha em perguntas
atomicas -> combine as respostas com logica deterministica no codigo** (pesos,
thresholds, condicionais). Nunca peca ao modelo para "pensar" sobre multiplos
fatores de uma vez — ele julga um fato por vez, o codigo compoe.

---

REGRA DE CONFIANCA E FALLBACK (quem decide o que)

- O modelo de decisao decide classificacoes, pontuacoes e probabilidades.
- O agente/aplicacao escreve explicacoes, respostas e textos para humanos — nunca
  peca ao modelo de decisao para redigir conteudo.
- Para Choice/Score: defina um piso de confianca (ex.: 0.70) abaixo do qual o
  resultado e INCERTO.
- Para Noul: valor >= 0.70 = provavel verdadeiro; <= 0.30 = provavel falso; entre
  os dois = incerto.
- Quando incerto, quem decide e o codigo/agente usando o contexto disponivel — e
  isso deve ser sinalizado EXPLICITAMENTE (log, campo de resposta, mensagem ao
  usuario) como fallback, nunca apresentado como se fosse decisao do modelo.

---

REGRA DE PRIVACIDADE

Antes de enviar dados privados a um provider externo de decisao estruturada,
peca confirmacao explicita. Considere privados: nomes, e-mails, telefones e
identificadores reais; dados de clientes; informacoes financeiras; credenciais;
documentos internos; qualquer dado que nao seja publico. Dado ficticio/de teste
explicitamente marcado como tal nao exige confirmacao.

---

GERENCIAMENTO DE CHAVE DE API (aplica o padrao de `ai-integration-patterns.md`)

- Chave sempre em variavel de ambiente, nunca hardcoded, nunca logada, nunca salva
  em arquivo versionavel/compartilhavel.
- Mascarar a chave em qualquer mensagem de erro/diagnostico.
- Pinar a versao do modelo em producao quando thresholds de confianca ja foram
  calibrados (um alias "latest" pode migrar de modelo silenciosamente e invalidar
  a calibracao).

---

TRATAMENTO DE ERROS (padrao observado, adapte aos codigos do seu provider)

| Situacao | Tratamento |
|---|---|
| Chave ausente/invalida | Nao re-tentar — erro permanente ate corrigir a chave |
| Payload invalido (campo faltando, pergunta malformada) | Nao re-tentar — mostrar o campo problematico ao usuario |
| Rate limit excedido | Retry com backoff exponencial |
| Provider sobrecarregado | Retry com backoff exponencial (mesmo tratamento) |

Meça latencia com timestamp de alta resolucao imediatamente antes de disparar a
chamada e imediatamente apos receber a resposta (sucesso OU falha) — latencia
total real, incluindo retries, nunca estimada.

---

CALCULO DE CUSTO

Providers de decisao estruturada tendem a cobrar so por tokens de ENTRADA (o
output e uma resposta tipada minuscula, nao texto gerado). Se a API nao devolver
um campo de custo explicito, calcule localmente e sempre mostre a formula usada:

```
custo = input_tokens * preco_por_token_de_entrada
```

Nunca inventar valores ausentes — se `input_tokens` nao vier na resposta, reporte
que o custo nao pode ser calculado.

---

FORMATO PADRAO DE APRESENTACAO DE RESULTADOS

Ao reportar um resultado bem-sucedido, mostre sempre:
- codigo HTTP e modelo efetivamente usado pela API (pode diferir do pedido se
  usar alias);
- resposta completa de cada pergunta (choice/score/probabilidades/confianca ou
  noul, conforme o tipo);
- tokens de entrada/saida;
- latencia total;
- custo (com a formula, se calculado localmente);
- nota explicita da regra de confianca aplicada a cada resposta (confiavel vs.
  incerto/fallback).

Ao reportar um erro, nunca substitua pela explicacao generica — sempre mostre
codigo HTTP (ou `None` se falha de rede antes de qualquer resposta), corpo/
mensagem exata retornada (mascarando qualquer dado sensivel), e latencia ate a
falha.

---

CHECKLIST

- [ ] Tarefa e de classificar/pontuar/julgar (nao de redigir texto para humano)
- [ ] Perguntas decompostas em atomos independentes (choice/score/noul)
- [ ] Todas as perguntas relevantes numa unica chamada (fan-out)
- [ ] Threshold de confianca definido por acao, proporcional ao risco
- [ ] Fallback do agente sinalizado explicitamente quando incerto
- [ ] Pesos de composicao (Composite Scoring) vivem no codigo, nunca no modelo
- [ ] Chave em variavel de ambiente, mascarada em logs/erros
- [ ] Modelo pinado em producao (nao usar alias "latest" com thresholds calibrados)
- [ ] Retry com backoff so para rate-limit/sobrecarga, nunca para erro de payload
- [ ] Custo calculado com formula explicita, nunca estimado
- [ ] Dado privado so enviado apos confirmacao explicita
