# Code Review

Referência para revisão de código — útil ao revisar Pull Requests, auditar código legado
ou como guia para quem está aprendendo o que olhar numa revisão.

> **Precedência:** com o plugin `superpowers` do Claude Code ativo, use
> `superpowers:requesting-code-review` no lugar desta skill — a de lá é acoplada ao
> harness (plan mode, subagentes, worktree). Esta versão existe para quem não tem o
> plugin: Cursor, Copilot, Codex, ou Claude Code sem ele. Regra e exclusões prontas em
> [docs/precedencia-de-skills.md](../../docs/precedencia-de-skills.md).

O que revisar

Corretude:
- O codigo faz o que a issue/task pede?
- Casos de borda tratados?
- Tratamento de erros adequado?
- Sem logica invertida

Seguranca:
- Inputs validados e sanitizados
- Sem dados sensiveis em logs ou responses
- Permissoes verificadas onde necessario
- Dependencias novas auditadas (npm audit, pip check)

Qualidade:
- Funcoes com responsabilidade unica
- Sem codigo duplicado (DRY)
- Nomes de variaveis e funcoes claros
- Sem comentarios que explicam o obvio
- TODO/FIXME com issue linkada

Testes:
- Novos comportamentos cobertos por testes
- Testes legiveis com assertions claras
- Mocks usados com moderacao

Performance:
- Loops sem operacoes pesadas desnecessarias
- Cache considerado onde aplicavel
- Queries otimizadas (ver skills/database/query-compliance.md)

Como dar feedback:
- Cite arquivo e linha, explique o problema
- Use prefixos: BLOCKER, SUGESTAO, NITPICK
- Proponha solucao, nao apenas aponte o problema
- Elogie o que esta bom