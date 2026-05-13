# Delete Merged Branches

Higienização de branches remotas já mergeadas via Pull Requests. Operação puramente organizacional: remove ponteiros de branches mantendo intacto todo o histórico (commits, PRs, diffs, reviews).

---

## Quando usar

- Limpeza periódica de branches remotas após merges
- Antes de auditar branches ativas (reduz ruído)
- Trigger por keywords: "deletar branches mergeadas", "limpar branches", "cleanup branches", "higienizar branches"

---

## O que é afetado vs. preservado

| Removido | Preservado |
|---|---|
| `refs/heads/<branch>` no remote | Pull Requests (visíveis com discussão, reviews, commits) |
| Entrada na listagem de branches | Commits (no `main`/`master` via merge) |
| | Diffs (acessíveis pela PR) |
| | Tags, git log, histórico |

---

## Protocolo

### Fase 1 — Listar branches com PR mergeado

```bash
gh pr list --state merged --limit 200 \
  --json number,title,headRefName,mergedAt,author \
  --jq '.[] | "\(.headRefName)\t\(.number)\t\(.title)\t\(.mergedAt)\t\(.author.login)"'
```

### Fase 2 — Filtrar branches protegidas

Nunca deletar: `main`, `master`, `develop`, `staging`, `production`, e a branch atual (`git branch --show-current`).

Cruzar com branches remotas existentes:

```bash
git ls-remote --heads origin | awk '{print $2}' | sed 's|refs/heads/||'
```

Manter só branches que: (1) existem no remote, (2) têm PR `merged`, (3) não estão protegidas.

### Fase 3 — Dry-run obrigatório

Apresentar tabela ao usuário **antes** de deletar:

```
| # | Branch | PR | Mergeado em | Autor |
|---|--------|----|-------------|-------|
| 1 | feat/login-x | #42 | 2026-02-15 | user1 |
```

Aguardar confirmação explícita ("sim", "prossiga", ou seleção específica).

### Fase 4 — Deletar

```bash
# Via gh API
gh api -X DELETE "repos/{owner}/{repo}/git/refs/heads/{branch_name}"

# Ou via git
git push origin --delete <branch_name>
```

### Fase 5 — Relatório

Listar: deletadas com sucesso, falhas (com motivo), protegidas ignoradas.

---

## Regras de segurança

1. Nunca deletar sem confirmação explícita
2. Nunca deletar a branch atual de trabalho
3. Apenas PRs com estado `merged` — `closed` sem merge pode conter trabalho não recuperado
4. Não confiar em `git branch -r --merged` (não garante existência de PR)
5. Em caso de falha em uma branch, continuar com as demais e reportar no fim

---

## Anti-patterns

```bash
# ERRADO — automatiza deleção sem approval
git push origin --delete $(git branch -r --merged | grep -v main)

# ERRADO — inclui PRs fechados sem merge
gh pr list --state closed

# ERRADO — branch pode ter sido mergeada manualmente, sem PR
git branch -r --merged main
```

```bash
# CERTO — explicitamente PRs com merge concluído
gh pr list --state merged --json headRefName,number,mergedAt
```

---

## Checklist pré-execução

- [ ] `gh auth status` ok
- [ ] `git remote -v` configurado
- [ ] Lista de protegidas validada
- [ ] Tabela apresentada ao usuário
- [ ] Confirmação recebida
- [ ] Relatório final emitido

---

## Skills relacionadas

- `skills/git/branching-strategy.md` — estratégia de branches
- `skills/git/pr-template.md` — template de PR
