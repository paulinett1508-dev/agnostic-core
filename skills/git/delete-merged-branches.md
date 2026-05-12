# Delete Merged Branches

Remove referências de branches remotas cujos PRs já foram mergeados. Operação puramente organizacional — preserva todo o histórico git.

---

## Quando usar

- Acúmulo de branches antigas após merges
- "limpar branches" / "higienizar branches" / "remover branches mergeadas"
- Antes de fazer onboarding de novos devs (repositório mais limpo)
- Manutenção periódica do repositório

---

## Regras de segurança

**Branches protegidas — nunca deletar:**

```
main, master, develop, staging, production
```

Adapte a lista conforme o projeto. Nunca deletar a branch atual.

**Dry-run é o padrão.** Deleção só acontece com confirmação explícita do usuário.

**Verificação de PR:** só candidata branches com PR confirmado como mergeado.

---

## Workflow (5 fases)

### Fase 1 — Listar branches mergeadas remotamente

```bash
git fetch --prune origin

# Branches já integradas a main
git branch -r --merged origin/main \
  | grep -v "origin/main\|origin/master\|origin/develop\|origin/staging\|origin/production\|HEAD"
```

### Fase 2 — Filtrar protegidas e atual

```bash
CURRENT=$(git branch --show-current)
PROTECTED="main|master|develop|staging|production|$CURRENT"

git branch -r --merged origin/main \
  | grep -v "origin/HEAD" \
  | grep -vE "origin/($PROTECTED)" \
  | sed 's/origin\///'
```

### Fase 3 — Apresentar ao usuário (dry-run)

Mostrar lista antes de qualquer deleção:

```
Branches candidatas à remoção:
  feature/login-redesign    (último commit: 2024-01-15)
  fix/cart-overflow         (último commit: 2024-01-10)
  chore/update-deps         (último commit: 2024-01-08)

Total: 3 branches

Confirma a remoção? (s/N)
```

### Fase 4 — Executar deleção (após confirmação)

```bash
for branch in $BRANCHES_TO_DELETE; do
  git push origin --delete "$branch" \
    && echo "✅ Deletada: $branch" \
    || echo "❌ Falha: $branch"
done
```

### Fase 5 — Relatório final

```
Resultado:
  ✅ feature/login-redesign — deletada
  ✅ fix/cart-overflow      — deletada
  ❌ chore/update-deps      — falha (sem permissão)

2 de 3 branches removidas.
```

---

## O que NÃO é afetado

Esta operação remove apenas o ponteiro de branch. Permanece intacto:

- Pull Requests com histórico de discussão
- Commits integrados à main
- Diffs acessíveis via `git log`
- Tags e releases
- Logs completos do git

---

## Limpar referências locais obsoletas

Após deletar remotas, limpar o tracking local:

```bash
git fetch --prune origin
# ou
git remote prune origin
```

---

## Checklist

- [ ] `git fetch --prune` executado antes de listar
- [ ] Branches protegidas excluídas da lista
- [ ] Branch atual excluída da lista
- [ ] Usuário confirmou antes de deletar
- [ ] Relatório de sucesso/falha exibido
- [ ] `git remote prune origin` executado após deleção

---

Ver também: `skills/git/branching-strategy.md`, `skills/git/pr-template.md`
