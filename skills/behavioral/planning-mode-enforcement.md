# Planning Mode Enforcement

Protocolo de planejamento obrigatório antes de qualquer escrita de código. Aplica-se em todos os ambientes do Claude Code (CLI, VS Code, Web).

Companheiro de `skills/automacao/planning-gate-hooks.md`, que automatiza a aplicação via hooks.

> **Precedência:** com o plugin `superpowers` do Claude Code ativo, use
> `superpowers:brainstorming` no lugar desta skill — a de lá é acoplada ao harness (plan mode,
> subagentes, worktree). Esta versão existe para quem não tem o plugin: Cursor,
> Copilot, Codex, ou Claude Code sem ele. Regra e exclusões prontas em
> [docs/precedencia-de-skills.md](../../docs/precedencia-de-skills.md).

---

## Regra cardinal

```
Nenhum código pode ser escrito antes de:
1. Criar planejamento completo
2. Listar tarefas com TodoWrite/TaskCreate
3. Apresentar plano ao usuário
4. Receber aprovação explícita
```

Violação → parar, desfazer (se possível via `git reset`), recriar planejamento, recomeçar.

---

## Fluxo (3 fases)

### Fase 1 — Planejamento

**Permitido:** `Read`, `Glob`, `Grep`, exploração read-only.
**Proibido:** `Edit`, `Write`, `Bash` com efeitos colaterais.

Output esperado:

```markdown
## Planejamento: <nome da tarefa>

### Contexto
<solicitação do usuário, em 1-2 linhas>

### Análise
<o que precisa ser feito e por quê>

### Tarefas identificadas
1. <tarefa atômica> — <justificativa>
2. ...

### Arquivos afetados
- `caminho/arquivo.ext` — <o que muda>

### Riscos
- <risco 1>
```

### Fase 2 — Validação

1. Criar TodoWrite/TaskCreate com a lista de tarefas
2. Apresentar plano ao usuário
3. Perguntar explicitamente: *"Este planejamento faz sentido? Posso prosseguir?"*
4. Aguardar resposta — **nunca** assumir aprovação

Respostas que liberam execução: "sim", "pode prosseguir", "ok", "execute", "faça", "correto".
Ajustes solicitados → volta para Fase 1.

### Fase 3 — Execução

Ferramentas liberadas: `Edit`, `Write`, `Bash`, `TaskUpdate`.

Para cada tarefa:
1. Marcar `in_progress`
2. Executar
3. Marcar `completed` imediatamente após
4. Próxima tarefa

---

## Exceções (não exige planejamento prévio)

- Perguntas puramente informativas (sem escrita)
- Comandos triviais explicitamente pedidos pelo usuário ("rode `npm test`")
- Correção pontual já discutida na conversa (continuação direta)
- Ações reversíveis de exploração (ler arquivos, listar diretórios)

---

## Anti-patterns

- Começar a editar arquivos e só depois "documentar" o que foi feito
- Criar TodoWrite **depois** da primeira mudança (flag deve preceder)
- Pular validação assumindo que "o usuário quer isso óbvio"
- Apresentar plano e executar na mesma resposta sem esperar confirmação

---

## Aplicação automatizada

Para forçar mecanicamente via hooks do Claude Code, ver `skills/automacao/planning-gate-hooks.md`. Os hooks bloqueiam `Edit`/`Write` até que `TaskCreate`/`TodoWrite` seja chamado.

---

## Skills relacionadas

- `skills/automacao/planning-gate-hooks.md` — automação via hooks
- `skills/behavioral/goal-backward-planning.md` — técnica de planejamento reverso
- `skills/audit/pre-implementation.md` — checklist pré-implementação
