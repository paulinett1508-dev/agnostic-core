## Uso deste repo

Este é o **agnostic-core**: acervo de skills, agents e commands em Markdown puro, agnósticos de stack.

- **Skills em `skills/`** são a fonte da verdade — não duplicar em outros formatos.
- **Mudanças em skills existentes** devem preservar linguagem agnóstica: sem amarrar a framework ou linguagem específicos; extrair a parte genérica como regra e a específica como exemplo.
- **Antes de commitar**: `npm run lint` e `npm run check-refs` devem passar.

## Uso de Subagents

- Use subagents para pesquisar boas práticas externas, comparar padrões entre frameworks e analisar skills existentes em paralelo.
- Offload análise de consistência entre skills relacionadas e verificação de duplicação para subagents.
- Para criação de nova categoria de skill: subagent de pesquisa de referências antes de escrever.

## Verificação antes de Concluir

- Nunca marque uma skill como concluída sem verificar: exemplos concretos incluídos, linguagem agnóstica (sem amarrar a stack específica), formatação Markdown consistente com as demais skills.
- Pergunta padrão: *"Um desenvolvedor de qualquer stack conseguiria aplicar isso no próprio projeto?"*
- Confirmar que a nova skill está referenciada em `docs/skills-index.md`.

## Elegância (features não-triviais)

- Para skills que cobrem 3+ conceitos distintos: pause e avalie se deve ser dividida em skills menores.
- Se uma skill está prescritiva demais para uma stack específica: extrair a parte genérica como regra e a específica como exemplo.
- **Exceção:** adições pontuais de exemplos ou referências — não reestruturar uma skill inteira por um detalhe.

## Convenção Git

- Branch principal: `master`.
- Commits seguem [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`.
- PRs têm `master` como base, com summary + test plan.

## Princípios básicos

- **Simplicidade primeiro**: faça cada mudança em uma skill a mais simples possível; evite reescrever a skill inteira por um detalhe.
- **Sem previsão**: encontre causas-raiz; sem fixes temporários para passar lint/check-refs; padrões de dev sênior.
- **Impacto mínimo**: toque apenas no que é necessário; sem efeitos colaterais que quebrem skills relacionadas.

## Modo de Output

**Caveman ativo por padrão em toda sessão.**

O que isso significa:
- Respostas diretas e densas — sem introduções, sem conclusões, sem repetição de contexto
- Frases curtas. Código > explicação. Decisão > raciocínio exposto.
- Análise pode ser profunda internamente; o que aparece no output é só o essencial.
- Modos cognitivos (steelman, red team, etc.) são ortogonais: pensamento aprofundado, output comprimido.

Para desativar: `modo normal` | `full output` | `sem caveman`
→ Execute: `echo normal > .claude/output-mode`

Para reativar: `caveman` | `comprimir` | `modo comprimido`
→ Execute: `echo caveman > .claude/output-mode`

O status line do Claude Code reflete o modo ativo da sessão.

## Auto-invocação de skills

Este projeto usa agnostic-core. O arquivo `docs/keywords-map.md` define
quais skills devem ser invocadas automaticamente por contexto de conversa.

Regras:
- Leia o `keywords-map.md` no início de cada sessão
- Monitore keywords ao longo da conversa
- Skills técnicas: entre em plan mode e aguarde confirmação antes de executar
- Skills behavioral: ative silenciosamente, sem notificação
