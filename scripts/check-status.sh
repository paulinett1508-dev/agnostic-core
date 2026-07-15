#!/bin/bash
# ==============================================================================
# agnostic-core — verificacao de status
# ==============================================================================
#
# Execute na raiz do seu projeto (onde .agnostic-core/ esta instalado):
#   bash .agnostic-core/scripts/check-status.sh
#
# O script e read-only: nao modifica nenhum arquivo.
# ==============================================================================

set -e

SUBMODULE_PATH=".agnostic-core"

if [ ! -d "$SUBMODULE_PATH" ]; then
  echo "ERRO: $SUBMODULE_PATH nao encontrado."
  echo "Verifique se o submodulo esta instalado:"
  echo "  git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core"
  exit 1
fi

# --- Info local ---

LOCAL_SHA=$(cd "$SUBMODULE_PATH" && git rev-parse HEAD)
LOCAL_SHORT=$(echo "$LOCAL_SHA" | cut -c1-7)
LOCAL_VERSION=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$SUBMODULE_PATH/package.json" 2>/dev/null | head -1)
LOCAL_VERSION=${LOCAL_VERSION:-sem versao}
LOCAL_DATE=$(cd "$SUBMODULE_PATH" && git log -1 --format="%ci" | cut -d' ' -f1)
SKILL_COUNT=$(find "$SUBMODULE_PATH/skills" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
AGENT_COUNT=$(find "$SUBMODULE_PATH/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "=== agnostic-core status ==="
echo ""
echo "Versao local:   $LOCAL_VERSION ($LOCAL_SHORT)"
echo "Data do commit: $LOCAL_DATE"
echo "Skills:         $SKILL_COUNT"
echo "Agents:         $AGENT_COUNT"

# --- Info remota ---

cd "$SUBMODULE_PATH"
git fetch origin master --quiet 2>/dev/null || {
  echo ""
  echo "AVISO: nao foi possivel conectar ao remote."
  echo "Mostrando apenas informacoes locais."
  exit 0
}

REMOTE_SHA=$(git rev-parse origin/master)
REMOTE_SHORT=$(echo "$REMOTE_SHA" | cut -c1-7)
REMOTE_VERSION=$(git show origin/master:package.json 2>/dev/null | sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
REMOTE_VERSION=${REMOTE_VERSION:-sem versao}

echo ""

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
  echo "Status:         ATUALIZADO"
else
  BEHIND=$(git rev-list HEAD..origin/master --count)
  echo "Status:         $BEHIND commit(s) atras"
  echo "Versao remota:  $REMOTE_VERSION ($REMOTE_SHORT)"
  echo ""
  echo "--- Novidades ---"
  git log --oneline HEAD..origin/master | head -15
  TOTAL=$(git rev-list HEAD..origin/master --count)
  if [ "$TOTAL" -gt 15 ]; then
    echo "... e mais $((TOTAL - 15)) commits"
  fi
  echo ""
  echo "Para atualizar:"
  echo "  git submodule update --remote .agnostic-core"
  echo "  git add .agnostic-core"
  echo "  git commit -m \"chore(deps): atualizar agnostic-core\""
fi
