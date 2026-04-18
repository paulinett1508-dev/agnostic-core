#!/bin/bash
# ============================================================
# agnostic-core — Script Universal de Instalação
# Execute na raiz de qualquer repositório git
#
# Uso:
#   curl -sL https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/master/scripts/install.sh | bash
#
# Flags:
#   --template <t>   Força template (fullstack|api-backend|frontend|generic)
#   --no-hook        Não configura o hook PostToolUse do Claude Code
#   --no-commit      Não faz git add/commit/push automático no final
#   --no-claude-skills  Não gera a camada .claude/skills/ nativa
# ============================================================

set -e

TEMPLATE=""
NO_HOOK=false
NO_COMMIT=false
NO_CLAUDE_SKILLS=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --template) TEMPLATE="$2"; shift 2;;
    --no-hook) NO_HOOK=true; shift;;
    --no-commit) NO_COMMIT=true; shift;;
    --no-claude-skills) NO_CLAUDE_SKILLS=true; shift;;
    *) echo "Uso: install.sh [--template fullstack|api-backend|frontend|generic] [--no-hook] [--no-commit] [--no-claude-skills]"; exit 1;;
  esac
done

# ── 1/7 Verificar que está em um repositório git ──
echo ""
echo "=== 1/7 Verificando repositório ==="
if [ ! -d ".git" ]; then
  echo "ERRO: Não é um repositório git. Execute na raiz do projeto."
  exit 1
fi
REPO_NAME=$(basename "$(pwd)")
echo "  Repositório: $REPO_NAME"

# ── 2/7 Detectar stack automaticamente ──
echo ""
echo "=== 2/7 Detectando stack ==="

HAS_REACT=false
HAS_VUE=false
HAS_SVELTE=false
HAS_NEXT=false
HAS_EXPRESS=false
HAS_FASTAPI=false
HAS_DJANGO=false
HAS_FLASK=false
HAS_PYTHON=false
HAS_NODE=false
HAS_TAILWIND=false
HAS_VITEST=false
HAS_JEST=false
HAS_DOCKER=false
HAS_VERCEL=false
HAS_REPLIT=false
HAS_CLOUDFLARE=false
HAS_FIREBASE=false
HAS_DRIZZLE=false
HAS_PRISMA=false
HAS_MONGODB=false
HAS_TURBO=false

# Detectar via package.json
if [ -f "package.json" ]; then
  HAS_NODE=true
  PKG=$(cat package.json)
  echo "$PKG" | grep -q '"react"' && HAS_REACT=true
  echo "$PKG" | grep -q '"vue"' && HAS_VUE=true
  echo "$PKG" | grep -q '"svelte"' && HAS_SVELTE=true
  echo "$PKG" | grep -q '"next"' && HAS_NEXT=true
  echo "$PKG" | grep -q '"express"' && HAS_EXPRESS=true
  echo "$PKG" | grep -q '"tailwindcss"' && HAS_TAILWIND=true
  echo "$PKG" | grep -q '"vitest"' && HAS_VITEST=true
  echo "$PKG" | grep -q '"jest"' && HAS_JEST=true
  echo "$PKG" | grep -q '"drizzle-orm"' && HAS_DRIZZLE=true
  echo "$PKG" | grep -q '"prisma"' && HAS_PRISMA=true
  echo "$PKG" | grep -q '"@prisma/client"' && HAS_PRISMA=true
  echo "$PKG" | grep -q '"mongodb"' && HAS_MONGODB=true
  echo "$PKG" | grep -q '"mongoose"' && HAS_MONGODB=true
  echo "$PKG" | grep -q '"firebase"' && HAS_FIREBASE=true
  echo "$PKG" | grep -q '"turbo"' && HAS_TURBO=true
fi

# Detectar Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "Pipfile" ]; then
  HAS_PYTHON=true
  PYFILES=$(cat requirements.txt pyproject.toml Pipfile 2>/dev/null || true)
  echo "$PYFILES" | grep -qi "fastapi" && HAS_FASTAPI=true
  echo "$PYFILES" | grep -qi "django" && HAS_DJANGO=true
  echo "$PYFILES" | grep -qi "flask" && HAS_FLASK=true
fi

# Detectar infra
[ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] && HAS_DOCKER=true
[ -f "vercel.json" ] && HAS_VERCEL=true
[ -f ".replit" ] && HAS_REPLIT=true
[ -f "wrangler.toml" ] && HAS_CLOUDFLARE=true

# Classificar stack
HAS_BACKEND=false
HAS_FRONTEND=false
HAS_DB=false

($HAS_EXPRESS || $HAS_FASTAPI || $HAS_DJANGO || $HAS_FLASK || $HAS_NEXT) && HAS_BACKEND=true
($HAS_REACT || $HAS_VUE || $HAS_SVELTE) && HAS_FRONTEND=true
($HAS_DRIZZLE || $HAS_PRISMA || $HAS_MONGODB || $HAS_FIREBASE) && HAS_DB=true

# Determinar template
if [ -z "$TEMPLATE" ]; then
  if $HAS_BACKEND && $HAS_FRONTEND; then
    TEMPLATE="fullstack"
  elif $HAS_BACKEND && ! $HAS_FRONTEND; then
    TEMPLATE="api-backend"
  elif $HAS_FRONTEND && ! $HAS_BACKEND; then
    TEMPLATE="frontend"
  else
    TEMPLATE="generic"
  fi
fi

echo "  Stack detectado:"
$HAS_REACT && echo "    - React"
$HAS_VUE && echo "    - Vue"
$HAS_SVELTE && echo "    - Svelte"
$HAS_NEXT && echo "    - Next.js"
$HAS_EXPRESS && echo "    - Express"
$HAS_FASTAPI && echo "    - FastAPI"
$HAS_DJANGO && echo "    - Django"
$HAS_FLASK && echo "    - Flask"
$HAS_PYTHON && echo "    - Python"
$HAS_TAILWIND && echo "    - Tailwind CSS"
$HAS_VITEST && echo "    - Vitest"
$HAS_JEST && echo "    - Jest"
$HAS_DRIZZLE && echo "    - Drizzle ORM"
$HAS_PRISMA && echo "    - Prisma"
$HAS_MONGODB && echo "    - MongoDB"
$HAS_FIREBASE && echo "    - Firebase"
$HAS_DOCKER && echo "    - Docker"
$HAS_VERCEL && echo "    - Vercel"
$HAS_REPLIT && echo "    - Replit"
$HAS_CLOUDFLARE && echo "    - Cloudflare"
$HAS_TURBO && echo "    - Turborepo"
echo "  Template selecionado: $TEMPLATE"

# ── 3/7 Adicionar submodule ──
echo ""
echo "=== 3/7 Adicionando agnostic-core como submodule ==="
if [ -d ".agnostic-core" ]; then
  echo "  AVISO: .agnostic-core já existe. Atualizando..."
  git submodule update --remote .agnostic-core
else
  git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
  git submodule update --init
fi

# ── 4/7 Gerar ou complementar CLAUDE.md ──
echo ""
echo "=== 4/7 Configurando CLAUDE.md ==="

# Detectar arquivo existente (CLAUDE.md ou claude.md)
CLAUDE_FILE=""
[ -f "CLAUDE.md" ] && CLAUDE_FILE="CLAUDE.md"
[ -f "claude.md" ] && CLAUDE_FILE="claude.md"

if [ -n "$CLAUDE_FILE" ]; then
  # Já tem claude.md — verificar se já referencia agnostic-core
  if grep -q "agnostic-core" "$CLAUDE_FILE" 2>/dev/null; then
    echo "  $CLAUDE_FILE já referencia agnostic-core. Pulando."
  else
    echo "  Adicionando seção de referência ao $CLAUDE_FILE existente..."
    echo "" >> "$CLAUDE_FILE"
    echo "---" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    echo "## Acervo de Referência — agnostic-core" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    echo "Submodule em \`.agnostic-core/\` com skills, agents e workflows reutilizáveis." >> "$CLAUDE_FILE"
    echo "Consultar quando relevante para a tarefa em andamento." >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"

    # Adicionar skills por stack detectado
    echo "### Skills Relevantes (detectadas para este stack)" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"

    if $HAS_FRONTEND; then
      echo "Frontend:" >> "$CLAUDE_FILE"
      echo "  HTML/CSS Audit:        .agnostic-core/skills/frontend/html-css-audit.md" >> "$CLAUDE_FILE"
      echo "  Acessibilidade:        .agnostic-core/skills/frontend/accessibility.md" >> "$CLAUDE_FILE"
      echo "  UX Guidelines:         .agnostic-core/skills/frontend/ux-guidelines.md" >> "$CLAUDE_FILE"
      $HAS_REACT && echo "  React Performance:     .agnostic-core/skills/frontend/react-performance.md" >> "$CLAUDE_FILE"
      $HAS_TAILWIND && echo "  Tailwind Patterns:     .agnostic-core/skills/frontend/tailwind-patterns.md" >> "$CLAUDE_FILE"
      $HAS_TAILWIND && echo "  Anti-Frankenstein:     .agnostic-core/skills/frontend/anti-frankenstein.md" >> "$CLAUDE_FILE"
      $HAS_TAILWIND && echo "  CSS Governance:        .agnostic-core/skills/frontend/css-governance.md" >> "$CLAUDE_FILE"
      echo "  SEO:                   .agnostic-core/skills/frontend/seo-checklist.md" >> "$CLAUDE_FILE"
      echo "" >> "$CLAUDE_FILE"
    fi

    if $HAS_BACKEND; then
      echo "Backend:" >> "$CLAUDE_FILE"
      echo "  REST API Design:       .agnostic-core/skills/backend/rest-api-design.md" >> "$CLAUDE_FILE"
      echo "  Error Handling:        .agnostic-core/skills/backend/error-handling.md" >> "$CLAUDE_FILE"
      echo "  Segurança de API:      .agnostic-core/skills/security/api-hardening.md" >> "$CLAUDE_FILE"
      echo "  OWASP Checklist:       .agnostic-core/skills/security/owasp-checklist.md" >> "$CLAUDE_FILE"
      $HAS_NODE && echo "  Node.js Patterns:      .agnostic-core/skills/nodejs/nodejs-patterns.md" >> "$CLAUDE_FILE"
      $HAS_EXPRESS && echo "  Express Practices:     .agnostic-core/skills/nodejs/express-best-practices.md" >> "$CLAUDE_FILE"
      $HAS_PYTHON && echo "  Python Patterns:       .agnostic-core/skills/python/python-patterns.md" >> "$CLAUDE_FILE"
      echo "" >> "$CLAUDE_FILE"
    fi

    if $HAS_DB; then
      echo "Banco de Dados:" >> "$CLAUDE_FILE"
      echo "  Query Compliance:      .agnostic-core/skills/database/query-compliance.md" >> "$CLAUDE_FILE"
      echo "  Schema Design:         .agnostic-core/skills/database/schema-design.md" >> "$CLAUDE_FILE"
      echo "" >> "$CLAUDE_FILE"
    fi

    echo "Testes:" >> "$CLAUDE_FILE"
    echo "  Unit Testing:          .agnostic-core/skills/testing/unit-testing.md" >> "$CLAUDE_FILE"
    echo "  TDD Workflow:          .agnostic-core/skills/testing/tdd-workflow.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"

    echo "Performance:" >> "$CLAUDE_FILE"
    echo "  Performance Audit:     .agnostic-core/skills/performance/performance-audit.md" >> "$CLAUDE_FILE"
    echo "  Caching Strategies:    .agnostic-core/skills/performance/caching-strategies.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"

    echo "Deploy:" >> "$CLAUDE_FILE"
    echo "  Pre-Deploy Checklist:  .agnostic-core/skills/devops/pre-deploy-checklist.md" >> "$CLAUDE_FILE"
    $HAS_VERCEL && echo "  Vercel Patterns:       .agnostic-core/skills/platforms/vercel/vercel-patterns.md" >> "$CLAUDE_FILE"
    $HAS_REPLIT && echo "  Replit Patterns:       .agnostic-core/skills/platforms/replit/replit-patterns.md" >> "$CLAUDE_FILE"
    $HAS_CLOUDFLARE && echo "  Cloudflare Patterns:   .agnostic-core/skills/platforms/cloudflare/cloudflare-patterns.md" >> "$CLAUDE_FILE"
    $HAS_DOCKER && echo "  Containerização:       .agnostic-core/skills/devops/containerizacao.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"

    echo "Qualidade:" >> "$CLAUDE_FILE"
    echo "  Code Review:           .agnostic-core/skills/audit/code-review.md" >> "$CLAUDE_FILE"
    echo "  Debugging:             .agnostic-core/skills/audit/systematic-debugging.md" >> "$CLAUDE_FILE"
    echo "  Commit Conventions:    .agnostic-core/skills/git/commit-conventions.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"

    echo "Produtividade:" >> "$CLAUDE_FILE"
    echo "  Claude Code Tips:      .agnostic-core/skills/workflow/claude-code-productivity.md" >> "$CLAUDE_FILE"
    echo "  Context Management:    .agnostic-core/skills/workflow/context-management.md" >> "$CLAUDE_FILE"
    echo "  Model Routing:         .agnostic-core/skills/ai/model-routing.md" >> "$CLAUDE_FILE"
    $HAS_TURBO && echo "  Monorepo:              .agnostic-core/skills/devops/monorepo.md" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"

    echo "### Commands" >> "$CLAUDE_FILE"
    echo "" >> "$CLAUDE_FILE"
    echo "  Catálogo completo:     .agnostic-core/commands/claude-code/COMMANDS.md" >> "$CLAUDE_FILE"
  fi
else
  # Não tem claude.md — copiar template do agnostic-core
  echo "  Copiando template $TEMPLATE..."
  case $TEMPLATE in
    fullstack)   cp .agnostic-core/templates/project-bootstrap/fullstack/CLAUDE.md CLAUDE.md;;
    api-backend) cp .agnostic-core/templates/project-bootstrap/api-backend/CLAUDE.md CLAUDE.md;;
    frontend)    cp .agnostic-core/templates/project-bootstrap/frontend/CLAUDE.md CLAUDE.md;;
    generic)     cp .agnostic-core/templates/project-bootstrap/fullstack/CLAUDE.md CLAUDE.md;;
  esac
  CLAUDE_FILE="CLAUDE.md"
  echo "  CLAUDE.md criado a partir do template $TEMPLATE"
  echo "  IMPORTANTE: Edite o CLAUDE.md e preencha as convenções do projeto"
fi

# ── 5/7 Gerar camada nativa .claude/skills/ ──
echo ""
echo "=== 5/7 Gerando camada nativa .claude/skills/ ==="

if $NO_CLAUDE_SKILLS; then
  echo "  Pulado (--no-claude-skills)."
elif [ -x ".agnostic-core/scripts/generate-claude-skills.sh" ]; then
  bash .agnostic-core/scripts/generate-claude-skills.sh "$(pwd)"
else
  echo "  AVISO: .agnostic-core/scripts/generate-claude-skills.sh não encontrado ou não executável. Pulando."
fi

# ── 6/7 Configurar auto-push hook (Claude Code) ──
echo ""
echo "=== 6/7 Configurando auto-push hook ==="

SETTINGS_DIR="$HOME/.claude"
SETTINGS_FILE="$SETTINGS_DIR/settings.json"

if $NO_HOOK; then
  echo "  Pulado (--no-hook)."
elif [ -d "$SETTINGS_DIR" ]; then
  if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
  fi

  # Verifica se já tem hook configurado
  if grep -q "post-tool-use-autopush" "$SETTINGS_FILE" 2>/dev/null; then
    echo "  Hook auto-push já configurado. Pulando."
  else
    echo "  Configurando PostToolUse hook para auto-push..."
    # Usa python/node para manipular JSON de forma segura
    if command -v python3 &>/dev/null; then
      python3 -c "
import json, os
f = '$SETTINGS_FILE'
with open(f) as fh: data = json.load(fh)
hooks = data.setdefault('hooks', {})
post = hooks.setdefault('PostToolUse', [])
post.append({
  'matcher': 'Bash',
  'hooks': [{
    'type': 'command',
    'command': '.agnostic-core/scripts/hooks/post-tool-use-autopush'
  }]
})
with open(f, 'w') as fh: json.dump(data, fh, indent=2)
"
      echo "  Hook auto-push configurado em $SETTINGS_FILE"
    elif command -v node &>/dev/null; then
      node -e "
const fs = require('fs');
const f = '$SETTINGS_FILE';
const data = JSON.parse(fs.readFileSync(f, 'utf8'));
if (!data.hooks) data.hooks = {};
if (!data.hooks.PostToolUse) data.hooks.PostToolUse = [];
data.hooks.PostToolUse.push({
  matcher: 'Bash',
  hooks: [{ type: 'command', command: '.agnostic-core/scripts/hooks/post-tool-use-autopush' }]
});
fs.writeFileSync(f, JSON.stringify(data, null, 2));
"
      echo "  Hook auto-push configurado em $SETTINGS_FILE"
    else
      echo "  AVISO: Nem python3 nem node disponíveis. Configure manualmente."
      echo "  Adicione ao $SETTINGS_FILE:"
      echo '  { "hooks": { "PostToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command", "command": ".agnostic-core/scripts/hooks/post-tool-use-autopush" }] }] } }'
    fi
  fi
else
  echo "  Claude Code não detectado (~/.claude não existe). Pulando hook."
  echo "  Após instalar Claude Code, execute novamente ou configure manualmente."
fi

# ── 7/7 Commit e push ──
echo ""
echo "=== 7/7 Commit e push ==="
if $NO_COMMIT; then
  echo "  Pulado (--no-commit). Execute manualmente:"
  echo "    git add .agnostic-core .gitmodules $CLAUDE_FILE .claude/"
  echo "    git commit -m 'chore: integrar agnostic-core'"
  echo "    git push origin \$(git branch --show-current)"
else
  git add .agnostic-core .gitmodules "$CLAUDE_FILE"
  [ -d ".claude" ] && git add .claude
  git commit -m "chore: integrar agnostic-core ($TEMPLATE) com skills selecionadas por stack"
  git push origin "$(git branch --show-current)"
fi

echo ""
echo "============================================"
echo "  INSTALAÇÃO CONCLUÍDA — $REPO_NAME"
echo "============================================"
echo ""
echo "  Template: $TEMPLATE"
echo "  Arquivo:  $CLAUDE_FILE"
echo ""
echo "  Verificação:"
echo "    ls .agnostic-core/skills/    → deve listar 13+ diretórios"
echo "    git submodule status         → deve mostrar commit"
echo ""
echo "  Próximo passo no Claude Code:"
echo "    @.agnostic-core/commands/claude-code/COMMANDS.md"
echo "    liste os prompts prontos disponíveis"
echo ""
