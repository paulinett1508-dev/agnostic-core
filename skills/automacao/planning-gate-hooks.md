# Planning Gate Hooks

Trio de hooks do Claude Code que força mecanicamente o protocolo de planejamento descrito em `skills/behavioral/planning-mode-enforcement.md`. Bloqueia `Edit`/`Write` até que `TaskCreate`/`TodoWrite` seja chamado primeiro.

---

## Como funciona

1. **SessionStart** — limpa flag de planejamento anterior e lembra protocolo
2. **UserPromptSubmit** — lembra o protocolo a cada nova mensagem do usuário
3. **PreToolUse** — gate principal: bloqueia `Edit`/`Write` se a flag não existe; cria a flag quando `TaskCreate`/`TodoWrite`/`TaskUpdate` é chamado

Flag: `/tmp/.claude-planning-done` (em Windows: `%TEMP%/.claude-planning-done`).

---

## Instalação

### 1. Criar os 3 scripts

**`.claude/hooks/session-start-planning-enforcer`**

```bash
#!/bin/bash
# SessionStart — limpa flag e exibe protocolo
rm -f /tmp/.claude-planning-done

echo "Modo de Planejamento Obrigatório ATIVO"
echo ""
echo "Antes de editar/escrever código:"
echo "1. Criar planejamento completo"
echo "2. Listar tarefas via TaskCreate/TodoWrite"
echo "3. Apresentar plano ao usuário"
echo "4. Aguardar aprovação explícita"
echo ""
echo "Ver: skills/behavioral/planning-mode-enforcement.md"
```

**`.claude/hooks/user-prompt-submit-planning-reminder`**

```bash
#!/bin/bash
# UserPromptSubmit — lembrete a cada mensagem
echo "Lembrete: antes de programar, crie planejamento + TaskCreate + questione usuário"
```

**`.claude/hooks/pre-tool-use-planning-gate`**

```bash
#!/bin/bash
# PreToolUse — bloqueia Edit/Write até TaskCreate/TodoWrite
# Input: JSON via stdin com tool_name
# Saída: exit 2 bloqueia a tool

FLAG_FILE="/tmp/.claude-planning-done"
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')

# Marca planejamento feito ao chamar TaskCreate/TodoWrite/TaskUpdate
if [[ "$TOOL_NAME" == "TaskCreate" || "$TOOL_NAME" == "TaskUpdate" || "$TOOL_NAME" == "TodoWrite" ]]; then
    touch "$FLAG_FILE"
    exit 0
fi

# Bloqueia Edit/Write se planejamento não foi feito
if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" ]]; then
    if [[ ! -f "$FLAG_FILE" ]]; then
        echo "BLOQUEADO: crie planejamento com TaskCreate/TodoWrite antes de editar/escrever." >&2
        exit 2
    fi
fi

exit 0
```

### 2. Tornar executáveis

```bash
chmod +x .claude/hooks/session-start-planning-enforcer
chmod +x .claude/hooks/user-prompt-submit-planning-reminder
chmod +x .claude/hooks/pre-tool-use-planning-gate
```

### 3. Registrar em `.claude/settings.json`

```json
{
  "hooks": {
    "SessionStart": [
      { "command": "bash .claude/hooks/session-start-planning-enforcer" }
    ],
    "UserPromptSubmit": [
      { "command": "bash .claude/hooks/user-prompt-submit-planning-reminder" }
    ],
    "PreToolUse": [
      { "command": "bash .claude/hooks/pre-tool-use-planning-gate" }
    ]
  }
}
```

---

## Bypass

- Remover o `PreToolUse` hook temporariamente
- Ou chamar `TodoWrite` com lista vazia para liberar o gate (não recomendado — quebra a disciplina)

---

## Adaptações

- **Windows nativo**: trocar `/tmp/.claude-planning-done` por `$env:TEMP\.claude-planning-done` e portar para PowerShell
- **Por projeto**: usar caminho do repo em vez de `/tmp` para isolar entre projetos: `.claude/.planning-done` (adicionar ao `.gitignore`)
- **Liberar tools adicionais**: incluir `Bash` na lista bloqueada se quiser gate mais rígido

---

## Skills relacionadas

- `skills/behavioral/planning-mode-enforcement.md` — o protocolo que esses hooks aplicam
- `skills/automacao/git-auto-push-hook.md` — outro hook utilitário do Claude Code
