Precedencia quando o acervo sobrepoe um plugin

Sete skills deste acervo cobrem o mesmo assunto que skills do plugin
`superpowers` do Claude Code. Nao e acidente nem duplicacao a ser removida: sao
dois publicos diferentes. Mas, quando os dois estao ativos na mesma sessao,
faltava dizer quem manda — e nada no acervo dizia.

Este documento diz.

---

A REGRA

Com o plugin `superpowers` ativo, **as skills de PROCESSO dele tem precedencia**
sobre as equivalentes deste acervo.

Motivo: as do plugin sao acopladas ao harness. Elas entram em plan mode,
despacham subagentes, criam worktree, encadeiam com outras skills do proprio
plugin. As deste acervo sao Markdown puro, sem nenhuma dessas alavancas — foram
escritas para funcionar em Cursor, Copilot, Codex, ou num Claude Code sem o
plugin instalado.

Mesmo processo, mecanismos diferentes. Rodar os dois e pagar duas vezes pelo
mesmo raciocinio, com o risco de seguir dois protocolos que discordam num
detalhe.

**Sem o plugin, as deste acervo sao a unica opcao e valem integralmente.**

---

O MAPA

| skill do acervo                        | skill do plugin                            |
|----------------------------------------|--------------------------------------------|
| `skills/audit/systematic-debugging`    | `superpowers:systematic-debugging`         |
| `skills/testing/tdd-workflow`          | `superpowers:test-driven-development`      |
| `skills/audit/pre-implementation`      | `superpowers:writing-plans` (parcial)      |
| `skills/audit/senior-verification-protocol` | `superpowers:verification-before-completion` |
| `skills/audit/code-review`             | `superpowers:requesting-code-review`       |
| `skills/behavioral/planning-mode-enforcement` | `superpowers:brainstorming` (o gate)  |
| `commands/workflows/brainstorm.md`     | `superpowers:brainstorming`                |

A sobreposicao e de assunto, nao de texto: as duas versoes de debugging
descrevem o mesmo ciclo de reproduzir/isolar/entender/corrigir, e as duas de TDD
descrevem Red-Green-Refactor. Por isso escolher uma nao perde conteudo.

---

COMO APLICAR

Precedencia declarada resolve a ambiguidade, mas a skill preterida continua
ocupando uma linha no system prompt de toda sessao. Se o projeto usa o plugin,
tire as sete do espelhamento — em `.agnostic-skills`, na raiz do projeto:

```
# superpowers cobre estes processos com acoplamento ao harness.
# Ver .agnostic-core/docs/precedencia-de-skills.md
!audit/systematic-debugging
!audit/pre-implementation
!audit/senior-verification-protocol
!audit/code-review
!testing/tdd-workflow
!behavioral/planning-mode-enforcement
```

As exclusoes sao avaliadas depois das inclusoes, entao elas funcionam mesmo
junto de um `audit/*` ou `testing/*` mais acima no arquivo.

O acervo continua completo no submodulo: a exclusao controla o que e
pre-carregado, nao o que esta disponivel. Um `Read` no arquivo-fonte continua
resolvendo quando alguem quiser justamente a versao agnostica.

---

O QUE ESTA REGRA NAO COBRE

Skills de DOMINIO do acervo (`security/`, `frontend/`, `database/`, `backend/`,
`devops/`, `performance/`…) nao tem equivalente no `superpowers` e nao entram
nesta disputa. O plugin traz processo; o acervo traz processo **e** dominio. So
o processo colide.
