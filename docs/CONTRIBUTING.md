# Como Contribuir

## Anatomia de uma skill

Toda skill segue este template:

```markdown
# Nome da Skill

## Objetivo
O que essa skill faz (1-2 linhas)

## Quando usar
Contextos e triggers para aplicar

## Checklist / Passos
- [ ] Item verificavel

## Exemplos
Casos reais de uso

## Ferramentas
Comandos e ferramentas relevantes

## Referencias
Links externos se necessario
```

## Regras

- Markdown puro, sem dependencia de ferramenta especifica
- Um arquivo = uma responsabilidade
- Nomes em kebab-case: `api-hardening.md`
- Secao "Quando usar" obrigatoria
- Checklist acionavel (nao texto vago)

## Onde colocar

| Dominio         | Pasta                        |
|-----------------|------------------------------|
| Seguranca       | `skills/security/`           |
| Frontend        | `skills/frontend/`           |
| Banco de dados  | `skills/database/`           |
| Code review     | `skills/audit/`              |
| Infra / CI-CD   | `skills/devops/`             |
| Agents          | `agents/{reviewers,generators,validators}/` |
| Commands IDE    | `commands/{vscode,claude-code,cursor}/`     |
| Compliance      | `compliance/{checklists,policies}/`         |

## Fluxo de contribuicao

1. Fork do repositorio
2. Crie branch: `feat/nome-da-skill`
3. Escreva a skill seguindo o template
4. Teste em um projeto real
5. Abra PR usando o template em `.github/PULL_REQUEST_TEMPLATE.md`
