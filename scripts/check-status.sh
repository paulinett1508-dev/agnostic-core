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
LOCAL_VERSION=$(cat "$SUBMODULE_PATH/VERSION" 2>/dev/null || echo "sem versao")
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
git fetch origin main --quiet 2>/dev/null || {
  echo ""
  echo "AVISO: nao foi possivel conectar ao remote."
  echo "Mostrando apenas informacoes locais."
  exit 0
}

REMOTE_SHA=$(git rev-parse origin/main)
REMOTE_SHORT=$(echo "$REMOTE_SHA" | cut -c1-7)
REMOTE_VERSION=$(git show origin/main:VERSION 2>/dev/null || echo "sem versao")

echo ""

if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
  echo "Status:         ATUALIZADO"
else
  BEHIND=$(git rev-list HEAD..origin/main --count)
  echo "Status:         $BEHIND commit(s) atras"
  echo "Versao remota:  $REMOTE_VERSION ($REMOTE_SHORT)"
  echo ""
  echo "--- Novidades ---"
  git log --oneline HEAD..origin/main | head -15
  TOTAL=$(git rev-list HEAD..origin/main --count)
  if [ "$TOTAL" -gt 15 ]; then
    echo "... e mais $((TOTAL - 15)) commits"
  fi
  echo ""
  echo "Para atualizar:"
  echo "  git submodule update --remote .agnostic-core"
  echo "  git add .agnostic-core"
  echo "  git commit -m \"chore(deps): atualizar agnostic-core\""
fi
