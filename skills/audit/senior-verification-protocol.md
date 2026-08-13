# Protocolo de Verificação — Senior Engineer

Checklist mental obrigatório antes de declarar qualquer tarefa concluída.
Aplique a features, bug fixes e refactors.

Fonte: padrão extraído de dois projetos reais em produção, que adotaram independentemente.

> **Precedência:** com o plugin `superpowers` do Claude Code ativo, use
> `superpowers:verification-before-completion` no lugar desta skill — a de lá é acoplada ao harness (plan mode,
> subagentes, worktree). Esta versão existe para quem não tem o plugin: Cursor,
> Copilot, Codex, ou Claude Code sem ele. Regra e exclusões prontas em
> [docs/precedencia-de-skills.md](../../docs/precedencia-de-skills.md).

---

## A Pergunta Central

> "Um senior engineer aprovaria esse diff?"

Se a resposta é "talvez" ou "não tenho certeza" — não está pronto.

---

## Regras

### Nunca declare pronto sem evidência

- Feature → demonstre funcionando (screenshot, log, teste passando)
- Bug fix → demonstre que o bug não reproduz mais
- Refactor → demonstre zero quebra (testes verdes, build limpo)

Afirmar não é demonstrar. Mostre o diff, o log ou o teste.

### Regra dos 3 arquivos — pausa para elegância

Para mudanças que tocam 3 ou mais arquivos:
1. Pause antes de implementar
2. Pergunte: "Há uma solução mais elegante?"
3. Se a solução parece hack: "Sabendo tudo o que sei agora, qual seria a implementação limpa?"

**Exceção obrigatória:** fixes simples e óbvios. Não over-engenheirar onde não agrega.

### Zero fixes temporários

- Identifique a causa raiz, não o sintoma
- "Funciona por enquanto" não passa nessa verificação
- Se o fix correto é complexo demais agora: documente a dívida, não silencie o problema

---

## Quando aplicar

| Situação | Aplicar? |
|---|---|
| Feature nova implementada | Sim |
| Bug fix concluído | Sim |
| Refactor de módulo existente | Sim |
| Mudança de configuração | Sim |
| Atualização de dependência | Sim |
| Correção de typo em texto | Não obrigatório |

---

## Ver também

- `skills/audit/systematic-debugging.md` — investigação de bugs
- `skills/audit/validation-checklist.md` — checklist consolidado de validação
- `skills/audit/code-review.md` — revisão de código
- `skills/behavioral/sais-principle.md` — mudança cirúrgica antes de alterar
