# Claude Code Statusline

Statusline customizada para o Claude Code (CLI) exibindo projeto, modelo, contexto consumido e session ID. Agnóstico de stack.

---

## Resultado

```
📁 meu-projeto | 🤖 Claude Opus 4.7 | 🧠 42% ctx | 🔗 session-abc123
```

---

## Instalação

### 1. Criar o script

Arquivo: `.claude/statusline.sh`

```bash
#!/bin/bash
# Claude Code statusline — project | model | context% | session

INPUT=$(cat)

CYAN='\033[36m'
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
RESET='\033[0m'

if command -v jq &> /dev/null; then
    MODEL=$(echo "$INPUT" | jq -r '.model.display_name // "Claude"')
    DIR=$(echo "$INPUT" | jq -r '.workspace.current_dir // .cwd // "~"')
    USED_PCT=$(echo "$INPUT" | jq -r '.context_window.used_percentage // 0')
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
else
    MODEL=$(echo "$INPUT" | grep -o '"display_name":"[^"]*"' | head -1 | sed 's/"display_name":"//;s/"//')
    DIR=$(echo "$INPUT" | grep -o '"current_dir":"[^"]*"' | head -1 | sed 's/"current_dir":"//;s/"//')
    SESSION_ID=$(echo "$INPUT" | grep -o '"session_id":"[^"]*"' | head -1 | sed 's/"session_id":"//;s/"//')
    TOTAL_IN=$(echo "$INPUT" | grep -o '"total_input_tokens":[0-9]*' | sed 's/[^0-9]//g')
    TOTAL_OUT=$(echo "$INPUT" | grep -o '"total_output_tokens":[0-9]*' | sed 's/[^0-9]//g')
    CTX_SIZE=$(echo "$INPUT" | grep -o '"context_window_size":[0-9]*' | sed 's/[^0-9]//g')
    [ -n "$TOTAL_IN" ] && [ -n "$CTX_SIZE" ] && \
      USED_PCT=$(awk "BEGIN {printf \"%.0f\", (($TOTAL_IN + $TOTAL_OUT) / $CTX_SIZE) * 100}")
fi

[ -z "$MODEL" ] && MODEL="Claude"
[ -z "$DIR" ] && DIR=$(pwd)
[ -z "$USED_PCT" ] && USED_PCT=0

DIR_NAME=$(basename "$DIR")

printf "📁 ${BLUE}%s${RESET}" "$DIR_NAME"
printf " | 🤖 ${CYAN}%s${RESET}" "$MODEL"
printf " | 🧠 ${YELLOW}%s%% ctx${RESET}" "$USED_PCT"
[ -n "$SESSION_ID" ] && printf " | 🔗 ${GREEN}%s${RESET}" "$SESSION_ID"
printf "\n"
```

### 2. Tornar executável

```bash
chmod +x .claude/statusline.sh
```

### 3. Registrar em `.claude/settings.json`

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash .claude/statusline.sh"
  }
}
```

---

## Customizações comuns

- **Adicionar branch git**: `BRANCH=$(git branch --show-current 2>/dev/null)` e `printf " | 🌿 %s" "$BRANCH"`.
- **Indicador de modo** (caveman / normal): ler `.claude/output-mode` e exibir.
- **Modelo curto** (Opus / Sonnet / Haiku): `MODEL=$(echo "$MODEL" | grep -oE 'Opus|Sonnet|Haiku')`.
- **Sem emojis**: remover prefixos `📁 🤖 🧠 🔗` se o terminal não renderiza bem.

---

## Notas

- O input vem como JSON via stdin (Claude Code passa contexto da sessão).
- `jq` é opcional — o fallback com `grep`/`sed` funciona em ambientes sem jq.
- Em Windows/PowerShell: usar Git Bash, WSL, ou converter para `.ps1`.

---

## Skills relacionadas

- `skills/devops/observabilidade.md` — observabilidade geral
