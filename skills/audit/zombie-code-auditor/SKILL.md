---
name: zombie-code-auditor
description: Audita codigo, config e documentacao que PARECEM mortos (removidos, desativados, corrigidos) mas continuam vivos e agindo — kill incompleto com um 2o caminho ainda alcancavel, flag de teste que substitui producao em vez de somar a ela, arquivo revertido por build/geracao/sincronizacao automatica, doc ou handoff orfao ainda lido por convencao antiga, e incidente que volta 2+ vezes porque so o sintoma foi tratado. Complementa dead-code-auditor (que acha codigo com ZERO referencias, seguro apagar) — aqui o alvo tem referencia ATIVA e ainda executa ou e lido, so que nao devia. Use quando o usuario pedir para achar "codigo zumbi", "bug que voltou", "flag ainda ativa", "fix que nao pegou em producao", "revert silencioso", "kill incompleto", "resurreicao de bug", "por que isso ainda roda", ou apos qualquer "remocao"/"desativacao" de feature, para confirmar que matou de verdade.
---

# Zombie Code Auditor

Cacar codigo, configuracao ou documentacao que tem pulso quando devia estar morto: foi removido, desativado, corrigido ou descontinuado em ALGUM lugar, mas continua sendo referenciado, executado, lido ou reativado por outro caminho.

## Por que isso e diferente de "dead code"

`dead-code-auditor` (skill irma, `skills/audit/dead-code-auditor/`) acha o oposto: coisa com **zero referencias** — seguro apagar, ninguem chama. Esta skill acha coisa com **referencia ativa** que ainda roda ou ainda e lida, mas conceitualmente ja deveria ter sido eliminada. Um zumbi nao esta inerte: ele anda, morde, e engana quem olha de fora achando que "aquilo ja foi resolvido".

Padrao real que deu origem a esta skill (SuperCartolaManager, 2026-08): uma flag `MODO_TESTE` devia *adicionar* uma copia de teste ao envio real — em vez disso, ela *substituiu* o destino inteiro, e os grupos reais ficaram sem nenhum aviso o dia inteiro sem que ningum tivesse pedido isso. Nenhuma ferramenta de dead-code acharia esse bug: a flag tem referencia ativa, o codigo roda, os testes triviais passam. O bug so aparece quando alguem traca **todos os caminhos** que levam ao mesmo comportamento.

## Quando usar

- Depois de "remover" ou "desativar" uma feature — antes de declarar Done, confirmar que nao sobrou um segundo caminho vivo pro mesmo comportamento
- Quando um bug "corrigido" volta a acontecer (2a ou 3a ocorrencia do mesmo incidente)
- Ao investigar por que um fix "nao pegou" em producao mesmo com o deploy confirmado
- Antes de confiar num handoff, README ou comentario antigo que pode contradizer a convencao atual do repo
- Auditoria periodica, junto com `repo-overengineering-audit.md` e `dead-code-auditor/SKILL.md` — as tres cobrem angulos diferentes do mesmo "o repo cresceu e ninguem revisitou"

## Workflow

Cada fase e independente — pular a que nao se aplicar. Comandos e exemplos detalhados em [`references/commands.md`](references/commands.md). Catalogo de padroes por categoria em [`references/checklist.md`](references/checklist.md).

### Fase 1 — Kill incompleto (2o caminho ainda vivo)

Para toda remocao/desativacao encontrada (grep no git log por `remov|desliga|desativa|descontinua|disable|remove|deprecat`), mapear **todos** os caminhos que levam ao mesmo comportamento visivel e confirmar que cada um foi cortado — nao so o que foi relatado. Ver [`references/commands.md`](references/commands.md#fase-1--kill-incompleto).

### Fase 2 — Flag substitui em vez de somar

Procurar condicionais de "modo teste"/feature flag que **sobrescrevem** o destino/lista real em vez de **adicionar** uma copia a ele. Ver [`references/commands.md`](references/commands.md#fase-2--flag-substitui-em-vez-de-somar).

### Fase 3 — Resurreicao via build/geracao/sincronizacao

Comparar arquivos gerados/sincronizados (codegen, submodule, build step, migration/seed) contra a fonte que os alimenta — um fix manual aplicado só na cópia final volta na próxima geração. Ver [`references/commands.md`](references/commands.md#fase-3--resurreicao-via-buildgeracaosincronizacao).

### Fase 4 — Doc/handoff orfao ainda alcancavel

Achar documentacao datada (handoff, README, comentario) que contradiz a convencao atual mas ainda esta no caminho padrao que ferramentas ou agentes leem por default. Ver [`references/commands.md`](references/commands.md#fase-4--dochandoff-orfao-ainda-alcancavel).

### Fase 5 — Recorrencia (causa raiz nao morta)

Grep no CHANGELOG/LESSONS/historico de sessoes por incidentes com a mesma causa aparecendo 2+ vezes com fixes diferentes — sinal de que o fix anterior matou o sintoma no ponto relatado, nao o mecanismo que gera o sintoma. Ver [`references/commands.md`](references/commands.md#fase-5--recorrencia-causa-raiz-nao-morta).

## Reporting

Consolidar achados numa tabela:

| # | Tipo de zumbi | Onde | Evidencia (ainda vivo por que) | Acao recomendada |
|---|---|---|---|---|
| 1 | Kill incompleto | `services/x.js` | Feature saiu do menu mas rota `/api/x` segue sem guarda | Fechar o 2o caminho ou documentar por que fica aberto |
| 2 | Flag substitui | `brasileiraoWatcherWhatsapp.js` (`GOL_WATCHER_MODO_TESTE`) | Flag devia só adicionar cópia de teste, mas substituía o envio real aos grupos — corrigido em 2026-08-09 (exemplo histórico, não achado ativo) | Confirmar que toda flag nova soma em vez de substituir; e que um "kill-switch" que substitui de propósito (ex: `WHATSAPP_MODO_TESTE` em `whatsappNotifier.js`, documentado como redirect total) está de fato declarado como tal, não presumido |
| 3 | Resurreicao | `.claude/skills/x/SKILL.md` | Gerado a partir de fonte upstream desatualizada, fix local revertido a cada sync | Promover fix pra fonte, nao pra copia |
| 4 | Doc orfao | `docs/handoffs/2026-08-08.md` | Contradiz convencao atual, ainda no path padrao de leitura | Remover ou redirecionar pra fonte viva |
| 5 | Recorrencia | CRLF corrompendo `git pull` (3x) | Mesma causa, 3 sessoes, nunca investigada na raiz | Investigar a causa raiz de vez, nao so destravar |

**Confianca:**
- **Alta** — caminho alternativo confirmado rodando (log, teste manual, leitura de codigo sem ambiguidade)
- **Media** — caminho existe no codigo mas nao foi exercitado ao vivo nesta auditoria
- **Baixa** — suspeita por padrao (ex: feature flag) sem confirmacao de que o 2o caminho é alcançável de fato — marcar para revisão humana

## Regras de seguranca

- Nunca aplicar fix sozinho — listar achados, aguardar decisao humana (mesma regra do `dead-code-auditor` e do `repo-overengineering-audit`)
- Nao declarar "kill completo" sem mapear literalmente todos os caminhos conhecidos — um caminho não verificado é um caminho assumido morto sem prova
- Feature flag pendente de ativação futura não é zumbi — só é zumbi quando o código morto/desativado ainda executa ou ainda é lido como se estivesse ativo
- Doc antigo com nota explícita de "histórico, não seguir" não é zumbi — zumbi é o que contradiz a convenção atual **sem avisar** que é histórico

## Reference files

- [`references/commands.md`](references/commands.md) — comandos e exemplos por fase
- [`references/checklist.md`](references/checklist.md) — catálogo de padrões de zumbi por categoria
- `skills/audit/dead-code-auditor/SKILL.md` — skill irmã, código com zero referências
- `skills/audit/repo-overengineering-audit.md` — varredura de overengineering acumulado, mesmo ledger de débito técnico pode registrar achados desta skill também
