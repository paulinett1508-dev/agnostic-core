# Documentation Hygiene

Auditoria e higienização de documentação de codebase. Use sempre que a documentação
(docs/, MDs diversos, planos, specs) estiver "amontoada" — com arquivos obsoletos,
órfãos, redundantes, ou planos já implementados que continuam parados como se fossem
pendentes. Também ao notar que o `docs/` cresceu sem curadoria, que há informação
duplicada em vários lugares com risco de divergência, ou antes de um onboarding/refactor
onde a doc precisa refletir o estado real. Combate o acúmulo e o "limbo" de documentação.

## Por que isso importa

Documentação que não reflete a realidade é pior que ausência de documentação: ela
*mente* com autoridade. Um POP que manda o admin acessar a porta errada, um plano
"pendente" que já foi entregue há um mês, três arquivos descrevendo a mesma coisa de
formas divergentes — tudo isso corrói a confiança e faz o leitor parar de acreditar
nos docs. O objetivo da higienização é que **cada documento tenha um dono claro, um
estado verdadeiro, e um lugar único**.

## O conceito central: limbo invertido

O acúmulo mais comum e traiçoeiro é o **limbo invertido**: planos e specs de features
**já implementadas e em produção** que continuam na pasta `plans/`/`specs/` misturados
com o trabalho ativo. Quem abre a pasta não distingue o que falta fazer do que já foi
feito. A pasta de "a fazer" vira um cemitério de "já foi feito".

A cura: separe fisicamente o implementado (mova para `done/` ou `historico/`) do que
ainda é trabalho. A pasta ativa deve conter **só o que está pendente ou em curso**.

## Protocolo de auditoria

Para cada documento, cruze evidências e atribua **um** veredito:

| Veredito | Quando | Ação |
|---|---|---|
| **MANTER** | Vigente e correto | Nada |
| **ATUALIZAR** | Factualmente errado/desatualizado | Corrigir o fato específico |
| **ARQUIVAR** | Histórico/concluído, sem valor operacional ativo | Mover para `historico/` ou `done/` |
| **MOVER** | No lugar errado (pertence a outro módulo/pasta) | Reposicionar |
| **DELETAR** | Sem valor algum, nunca referenciado | Remover (raro — prefira arquivar) |

### Como cruzar evidência (não chute)

Um veredito honesto vem de fatos verificáveis, não de impressão:

- **É referenciado?** `grep` pelo nome do arquivo no resto do repo. Órfão = ninguém aponta para ele.
- **Descreve algo já implementado?** Cruze com o código real / git log / ledger de tarefas. Plano cujo código já está em produção → limbo invertido.
- **Tem entry no ledger de tarefas?** Plano/spec sem rastreamento vai morrer quando o contexto da sessão sumir (anti-limbo).
- **Há outra fonte da mesma informação?** Se sim, uma delas é a fonte-única e as outras redirecionam. Duplicata divergente é dívida garantida.
- **O fato bate com a realidade?** Portas, versões, hostnames, status de migração — confronte com o estado vivo (config, `systemctl`, inventário). Docs operacionais que apontam o recurso errado são os mais perigosos.

## Fonte única de verdade

Quando a mesma informação (lista de recursos, tabela de config, estratégia) aparece em
2+ documentos, eleja **um** como fonte única e faça os outros redirecionarem para ele
com uma linha (`> Fonte única: <arquivo>`). Nunca deixe duas cópias "vivas" — elas
divergem em 2-3 edições e ninguém sabe qual vale. Escolha como fonte o documento mais
próximo da origem do dado (ex.: a lista de shares mora junto da definição que a gera).

## Execução em ondas

Higienização de codebase inteiro é volumosa — fatie em ondas mergeáveis, da menor à
maior superfície de risco, e registre cada uma no ledger de tarefas para não recriar
o limbo que você está combatendo:

0. **Auditar** — varrer e classificar (use subagentes em paralelo para cobrir muitos arquivos).
1. **Limbo invertido** — mover implementados para `done/`. Maior alívio visual, risco zero.
2. **Caducos factuais** — corrigir os fatos errados (priorize os que afetam operação: um POP que aponta a porta errada vale mais que um typo).
3. **Índices + arquivamento** — sincronizar índices com a realidade, arquivar soltos.
4+. **Código/scripts/estrutura** — consolidar scripts legados, mover arquivos de lugar. Maior risco, por último.

Preserve sempre o histórico ao mover (`git mv`, não delete+create). E ao depreciar um
doc, não o apague: marque no topo (`> ⚠️ DEPRECADO — consolidado em <X>`) e redirecione.
O passado tem valor de auditoria; o que se combate é o passado *fingindo ser presente*.

## Verificação ao terminar

- Os índices listam exatamente os arquivos que existem (sem órfãos nem fantasmas)?
- Cada informação tem uma fonte única?
- A pasta de trabalho ativo contém só trabalho ativo?
- Cada doc arquivado tem nota de por que foi arquivado e para onde aponta o sucessor?
- Toda onda ficou registrada no ledger?
