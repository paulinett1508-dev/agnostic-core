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

RELACAO COM OUTRAS SKILLS

  - model-routing: decide QUAL MODELO executa cada subagent (politica de custo). O advisor decide SE A ABORDAGEM ESTA CERTA (revisao). Sao complementares: decisao de alto risco vai para o advisor em vez de apenas subir o tier do subagent.
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
- [ ] Ferramenta indisponivel? Declarei que nao houve segunda revisao
