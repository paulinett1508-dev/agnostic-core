Advisor Checkpoints

Objetivo: Garantir que tarefas nao triviais passem por uma revisao independente de um modelo mais forte em dois pontos fixos — antes de cravar a abordagem e antes de declarar concluido — sem transformar isso em ritual para toda tarefa.

Aplica-se quando a ferramenta `advisor` estiver disponivel na sessao. Se nao estiver, esta skill nao obriga nada: use o tier alto do model-routing para a decisao e declare que nao houve segunda revisao.

---

O QUE E O ADVISOR

Ferramenta nativa, sem parametros. Ao chamar `advisor()`, a conversa inteira (tarefa, chamadas de ferramenta, resultados, raciocinio) e encaminhada a um revisor mais forte que o modelo da sessao. O retorno e um conselho — nao executa nada.

Nao existe flag de CLI para liga-lo (ex.: `claude --advisor` nao existe). Disponibilidade depende de conta e build. Para usar: a regra no CLAUDE.md do projeto faz o agente chamar sozinho; o usuario tambem pode pedir "consulte o advisor antes de implementar".

---

QUANDO CHAMAR

  1. ANTES de cravar a abordagem — depois da orientacao (achar arquivos, ler, ver o que existe), antes de escrever, editar ou assumir uma interpretacao. Orientacao nao conta como trabalho substantivo; escrever, editar e declarar resposta contam.
  2. ANTES de declarar concluido — com o entregavel ja DURAVEL: arquivo salvo, commit feito, resultado gravado. A chamada demora; se a sessao cair no meio, o que esta persistido sobrevive e o que nao esta, nao.
  3. QUANDO TRAVAR — erro recorrente, abordagem que nao converge, resultado que nao encaixa.
  4. AO MUDAR DE ABORDAGEM — antes de abandonar o caminho atual.

Dispensado: tarefa reativa de poucos passos em que a proxima acao e ditada pela saida da ferramenta que acabou de ser lida. O valor do advisor esta na primeira chamada, antes de a abordagem cristalizar — nao em chamar a cada passo.

---

AREAS OBRIGATORIAS (cada projeto preenche as suas)

O advisor e obrigatorio — nao so recomendado — onde o erro custa caro e e dificil de reverter. Esta lista e DO PROJETO, nao desta skill. Declare-a no CLAUDE.md. Exemplos por tipo:

  - Financeiro: calculo de saldo, cobranca, conciliacao, qualquer funcao que mova valor
  - Dados: migracao, escrita em banco de producao, script destrutivo, backfill
  - Infra: deploy, rotacao de credencial, mudanca em reverse proxy / DNS / firewall
  - Seguranca: autenticacao, autorizacao, criptografia, exposicao de segredo
  - Consolidacao/jobs: processo que fecha periodo, consolida ou notifica usuarios reais

Na duvida se uma tarefa entra na lista: se o erro chegaria a usuario real ou a dado persistido, entra.

Obrigatorio nao e ilimitado. Obrigar em tudo vira ruido e o lembrete passa a ser ignorado — por isso a lista e curta e explicita.

---

CONFLITO COM EVIDENCIA

Se o advisor aponta para um lado e ja existe evidencia coletada apontando para o outro (o arquivo diz X, o log mostra Y):

  - NAO trocar de abordagem em silencio
  - NAO ignorar o conselho em silencio
  - Nova chamada expondo o conflito: "encontrei X, voce sugere Y, qual restricao desempata?"

O advisor viu a evidencia mas pode ter subestimado parte dela; uma chamada de reconciliacao custa menos que seguir o ramo errado. Passou no teste proprio nao e prova de que o conselho esta errado — pode ser prova de que o teste nao verifica o que o conselho verifica. Conselho que falhou empiricamente, ou contradito por fonte primaria, se adapta.

---

ECONOMIA DE TOKENS (sem cortar poder de resolucao)

O custo de cada chamada e o tamanho da conversa que ela encaminha. Chamar no momento certo e
com a pergunta clara custa menos do que chamar mais vezes, e nao tira nenhuma revisao que
importa. Estas regras cortam desperdicio, nunca cobertura.

  1. CHAMAR CEDO, COM CONTEXTO ENXUTO. A primeira chamada acontece logo depois da orientacao.
     Orientar com leitura cirurgica (so o trecho necessario, ver `context-management`): o
     que for lido antes da chamada viaja junto com ela.
  2. DECLARAR A DECISAO EM ABERTO ANTES DE CHAMAR. O advisor nao recebe parametros: ele le a
     conversa. Escreva no texto imediatamente anterior a chamada o que esta em jogo ("estou
     entre A e B; a restricao que desempata e X"). Uma chamada com a pergunta explicita
     evita a segunda rodada.
  3. EVIDENCIA BARATA PRIMEIRO. Teste, tipagem, log e leitura direta decidem o que e fato. O
     advisor julga abordagem e risco; nao substitui rodar o teste. Nao gastar chamada para
     descobrir o que um comando de segundos responde.
  4. ORCAMENTO POR TAREFA (sugestao, o projeto ajusta no CLAUDE.md): 2 chamadas base
     (abordagem e conclusao) mais 1 por travada ou mudanca de abordagem. A reconciliacao de
     conflito com evidencia faz parte da chamada em curso, nao e uma extra. Passou de 4 sem
     convergir: parar, resumir o impasse ao usuario e so entao subir o tier ou tentar de novo.
  5. UMA REVISAO DO PLANO, NAO UMA POR SUBAGENT. Ao despachar varios subagents, chamar o
     advisor uma vez sobre o plano antes do dispatch e uma vez sobre o conjunto antes de
     concluir; nao em cada subagent.
  6. CONTEXTO PESADO ANTES DA CHAMADA FINAL. Se a sessao ja esta na faixa degradada do
     `context-management`, gravar o entregavel e o resumo do que foi decidido e verificado
     (handover) antes da chamada de conclusao, em vez de encaminhar um historico inflado.

  Nunca cortar para economizar: as duas chamadas em area obrigatoria, a chamada final com o
  entregavel duravel, a reconciliacao de conflito com evidencia, a chamada ao travar. O
  custo de um erro em area obrigatoria e maior do que o de qualquer chamada.

  Ressalva: os numeros do orcamento sao politica, nao medicao deste acervo. Medir o custo
  real das chamadas na ferramenta de uso da sua conta antes de apertar o teto.

---

QUANTO CHAMAR, POR TIER E POR RISCO

Combina com a tabela do `model-routing`. A coluna do meio e o minimo; area obrigatoria do
projeto sempre sobe uma linha, independente do tier.

  Tier do executor        Tarefa comum                       Area obrigatoria do projeto
  Tier 3 (mecanico)       dispensado                         as duas chamadas (abordagem e conclusao)
  Tier 2 (padrao)         so se houver ambiguidade real      as duas chamadas
  Tier 1 (complexo)       as duas chamadas                   as duas chamadas e reconciliacao
  Tier 0 (superior)       a chamada de conclusao             as duas chamadas

Tier 3 numa area obrigatoria e sinal de roteamento errado: subir o tier da execucao e manter
as chamadas. No Tier 0 o proprio executor ja e o teto, entao a abordagem se decide nele; a
chamada de conclusao segue valendo como segunda opiniao independente.

---

RELACAO COM OUTRAS SKILLS

  - model-routing: decide QUAL MODELO executa cada subagent (politica de custo). O advisor decide SE A ABORDAGEM ESTA CERTA (revisao). Sao complementares: decisao de alto risco vai para o advisor em vez de apenas subir o tier do subagent. A regra de escolha esta em "JULGAMENTO OU EXECUCAO" do `model-routing`.
  - context-management / context-audit: o contexto encaminhado e o custo da chamada; contexto enxuto e handover baratam e melhoram o conselho.
  - senior-verification-protocol: checklist mental antes de concluir. O advisor e a versao com segunda opiniao independente, nao substitui o checklist.
  - planning-mode-enforcement / goal-backward-planning: planejar vem antes; o advisor revisa o plano pronto, antes de executar.

---

COMO INSTALAR NO PROJETO

Adicione ao CLAUDE.md, na secao de verificacao antes de concluir, trocando a lista de areas pela do projeto:

  - **Advisor:** em tarefa nao trivial, chamar `advisor` (1) antes de fixar a abordagem — depois da orientacao, antes de editar — e (2) antes de declarar concluido, com o entregavel ja duravel. Chamar tambem ao travar ou ao mudar de abordagem. **Obrigatorio** em <AREAS DO PROJETO>. Dispensado em tarefa reativa de poucos passos. Se o advisor contradiz evidencia ja coletada, nova chamada expondo o conflito. Detalhes: skill `advisor-checkpoints`.

Se o projeto tem indice de praticas, acrescente uma linha: "Em tarefa nao trivial, `advisor` antes da abordagem e antes de concluir."

---

CHECKLIST

- [ ] Tarefa nao trivial? Chamei o advisor depois de orientar e antes de editar
- [ ] Entregavel esta salvo/commitado ANTES da chamada final
- [ ] Area obrigatoria do projeto? Entao nao pulei nenhuma das duas chamadas
- [ ] Conselho contradiz evidencia? Reconciliei com nova chamada, sem trocar em silencio
- [ ] A lista de areas obrigatorias esta no CLAUDE.md do projeto, nao so nesta skill
- [ ] Escrevi a decisao em aberto no texto antes de chamar (o advisor le a conversa)
- [ ] Rodei a evidencia barata (teste, tipos, log) antes de gastar a chamada
- [ ] Estou dentro do orcamento da tarefa? Passou de 4 sem convergir: parei e resumi o impasse
- [ ] Varios subagents? Uma revisao do plano e uma do conjunto, nao uma por subagent
- [ ] Ferramenta indisponivel? Declarei que nao houve segunda revisao
