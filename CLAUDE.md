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
