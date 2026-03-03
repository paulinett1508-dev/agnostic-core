# Como Contribuir

## Anatomia de uma skill

Toda skill segue este formato:

```
Nome da Skill

Objetivo: O que essa skill faz em 1-2 linhas.

---

SECAO PRINCIPAL

- [ ] Item verificavel e acionavel
- [ ] Outro item com exemplo quando util

OUTRA SECAO

- [ ] Item
```

Regras:
- Markdown puro, sem dependencia de ferramenta especifica
- Um arquivo = uma responsabilidade
- Nomes em kebab-case: `api-hardening.md`
- Checklist acionavel com `- [ ]` (nao texto vago)
- Exemplos de codigo quando o item nao e obvio
- Sem tabelas em skills — apenas listas planas
- Caminhos relativos a raiz do repo ao referenciar outras skills

## Anatomia de um agent

Todo agent segue esta estrutura obrigatoria:

```markdown
# Nome do Agent

## Objetivo
O que o agent faz (1-2 linhas).

## Identidade
Descricao do papel e expertise do agent.

## Comportamento
Passos enumerados do que o agent faz ao receber input.

## Output esperado
Exemplo concreto de saida real (nao descricao abstrata do formato).

## Skills a consultar
- skills/dominio/skill.md
- skills/outro/skill.md

## Como acionar no Claude Code
Prompt de uma linha para acionar via Claude Code.
```

Regras de agent:
- Output esperado com exemplo concreto, nao "gere um relatorio com..."
- Skills a consultar sempre listadas
- Status final explicito quando aplicavel: APROVADO / BLOQUEAR / AJUSTAR

## Onde colocar

| Dominio              | Pasta                                         |
|----------------------|-----------------------------------------------|
| Seguranca            | `skills/security/`                            |
| Frontend             | `skills/frontend/`                            |
| Backend              | `skills/backend/`                             |
| Banco de dados       | `skills/database/`                            |
| Testes               | `skills/testing/`                             |
| Performance          | `skills/performance/`                         |
| Code review / Auditoria | `skills/audit/`                            |
| Infra / CI-CD        | `skills/devops/`                              |
| Git                  | `skills/git/`                                 |
| Documentacao         | `skills/documentation/`                       |
| Node.js              | `skills/nodejs/`                              |
| Python               | `skills/python/`                              |
| AI / LLM             | `skills/ai/`                                  |
| Workflow / Planejamento | `skills/workflow/`                         |
| Agents reviewers     | `agents/reviewers/`                           |
| Agents generators    | `agents/generators/`                          |
| Agents validators    | `agents/validators/`                          |
| Commands Claude Code | `commands/claude-code/`                       |
| Commands Cursor      | `commands/cursor/`                            |
| Commands genericos   | `commands/generic/`                           |
| Compliance           | `compliance/{checklists,policies}/`           |
| Templates            | `templates/project-bootstrap/`                |

## Fluxo de contribuicao

1. Fork do repositorio
2. Crie branch: `feat/nome-da-skill`
3. Escreva a skill ou agent seguindo os formatos acima
4. Teste em um projeto real — a skill deve ser acionavel imediatamente
5. Adicione entrada em `docs/skills-index.md`
6. Abra PR com titulo no formato Conventional Commits: `feat(testing): adicionar skill de contract testing`

## O que nao e bem-vindo

- Skills duplicatas de skills existentes (verifique docs/skills-index.md antes)
- Skills sem checklist acionavel (apenas texto descritivo)
- Agents sem Output esperado concreto
- Skills especificas a um unico projeto ou empresa
- Conteudo com licenca incompativel (CC BY-NC-ND, por exemplo, nao e incorporavel)

## Recursos externos referenciados

Consulte docs/resources.md para a lista de repos externos que inspiraram este toolkit,
com notas de licenca para cada um.
