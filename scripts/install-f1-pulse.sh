#!/bin/bash
# ============================================================
# Script de Instalação: agnostic-core no f1-pulse
# Execute na raiz do repositório f1-pulse
# ============================================================

set -e

echo "=== 1/4 Verificando repositório ==="
if [ ! -f "package.json" ]; then
  echo "ERRO: Execute este script na raiz do f1-pulse (onde está o package.json)"
  exit 1
fi

echo "=== 2/4 Adicionando agnostic-core como submodule ==="
if [ -d ".agnostic-core" ]; then
  echo "AVISO: .agnostic-core já existe. Pulando submodule add."
else
  git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
  git submodule update --init
fi

echo "=== 3/4 Adicionando seção ao claude.md ==="
if grep -q "agnostic-core" claude.md 2>/dev/null; then
  echo "AVISO: claude.md já referencia agnostic-core. Pulando."
else
  cat >> claude.md << 'ACERVO_EOF'

---

## Acervo de Referência — agnostic-core

Submodule em `.agnostic-core/` com skills, agents e workflows reutilizáveis.
Consultar quando relevante para a tarefa em andamento.

### Skills Relevantes para este Projeto

Frontend / Tailwind / CSS:
  Anti-Frankenstein:     .agnostic-core/skills/frontend/anti-frankenstein.md
  CSS Governance:        .agnostic-core/skills/frontend/css-governance.md
  Tailwind Patterns:     .agnostic-core/skills/frontend/tailwind-patterns.md
  React Performance:     .agnostic-core/skills/frontend/react-performance.md
  Acessibilidade:        .agnostic-core/skills/frontend/accessibility.md
  UX Guidelines:         .agnostic-core/skills/frontend/ux-guidelines.md
  HTML/CSS Audit:        .agnostic-core/skills/frontend/html-css-audit.md
  SEO:                   .agnostic-core/skills/frontend/seo-checklist.md

Testes (Vitest):
  Unit Testing:          .agnostic-core/skills/testing/unit-testing.md
  E2E Testing:           .agnostic-core/skills/testing/e2e-testing.md
  TDD Workflow:          .agnostic-core/skills/testing/tdd-workflow.md

Performance:
  Performance Audit:     .agnostic-core/skills/performance/performance-audit.md
  Caching Strategies:    .agnostic-core/skills/performance/caching-strategies.md

Deploy (Vercel):
  Pre-Deploy Checklist:  .agnostic-core/skills/devops/pre-deploy-checklist.md
  Deploy Procedures:     .agnostic-core/skills/devops/deploy-procedures.md
  Vercel Patterns:       .agnostic-core/skills/platforms/vercel/vercel-patterns.md

Qualidade:
  Code Review:           .agnostic-core/skills/audit/code-review.md
  Refactoring:           .agnostic-core/skills/audit/refactoring.md
  Systematic Debugging:  .agnostic-core/skills/audit/systematic-debugging.md

Git:
  Commit Conventions:    .agnostic-core/skills/git/commit-conventions.md
  PR Template:           .agnostic-core/skills/git/pr-template.md

AI / Produtividade:
  Claude Code Tips:      .agnostic-core/skills/workflow/claude-code-productivity.md
  Context Management:    .agnostic-core/skills/workflow/context-management.md
  Model Routing:         .agnostic-core/skills/ai/model-routing.md
  Token Optimization:    .agnostic-core/skills/ai/token-optimization.md

### Agents Disponíveis

  Frontend Reviewer:     .agnostic-core/agents/reviewers/frontend-reviewer.md
  Code Inspector (SPARC):.agnostic-core/agents/reviewers/code-inspector.md
  Performance Reviewer:  .agnostic-core/agents/reviewers/performance-reviewer.md
  Test Reviewer:         .agnostic-core/agents/reviewers/test-reviewer.md
  Codebase Mapper:       .agnostic-core/agents/reviewers/codebase-mapper.md

### Commands

  Catálogo completo:     .agnostic-core/commands/claude-code/COMMANDS.md
ACERVO_EOF
fi

echo "=== 4/4 Commitando ==="
git add .agnostic-core .gitmodules claude.md
git commit -m "chore: integrar agnostic-core com skills selecionadas para stack React+TS+Tailwind"
git push origin main

echo ""
echo "=== INSTALAÇÃO CONCLUÍDA ==="
echo ""
echo "Verificação:"
echo "  ls .agnostic-core/          → deve listar skills/, agents/, commands/"
echo "  git submodule status        → deve mostrar commit do agnostic-core"
echo ""
echo "Uso no Claude Code:"
echo "  @.agnostic-core/skills/frontend/react-performance.md aplique ao Dashboard"
echo "  @.agnostic-core/skills/frontend/anti-frankenstein.md revise src/components/"
echo ""
