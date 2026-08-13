# ============================================================
# agnostic-core — Script Universal de Instalacao (Windows)
# Paridade com scripts/install.sh — execute na raiz de qualquer repo git
#
# Uso rapido (PowerShell):
#   irm https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/master/scripts/install.ps1 | iex
#
# Uso local com template forcado:
#   .\install.ps1 -Template fullstack
#
# Se a execucao de scripts estiver bloqueada:
#   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
# ============================================================

#Requires -Version 5.1
[CmdletBinding()]
param(
  [ValidateSet('fullstack','api-backend','frontend','generic','')]
  [string]$Template = ''
)

$ErrorActionPreference = 'Stop'

function Write-Step { param([string]$Msg) Write-Host "`n=== $Msg ===" -ForegroundColor Cyan }
function Write-Info { param([string]$Msg) Write-Host "  $Msg" }
function Write-Warn { param([string]$Msg) Write-Host "  AVISO: $Msg" -ForegroundColor Yellow }
function Write-Err  { param([string]$Msg) Write-Host "  ERRO: $Msg"  -ForegroundColor Red }

# ---- 1/6 Verificar repositorio git ----
Write-Step '1/6 Verificando repositorio'
if (-not (Test-Path '.git')) {
  Write-Err 'Nao e um repositorio git. Execute na raiz do projeto.'
  exit 1
}
$repoName = Split-Path -Leaf (Get-Location)
Write-Info "Repositorio: $repoName"

# ---- 2/6 Detectar stack ----
Write-Step '2/6 Detectando stack'

$flags = [ordered]@{
  React=$false; Vue=$false; Svelte=$false; Next=$false
  Express=$false; FastAPI=$false; Django=$false; Flask=$false
  Python=$false; Node=$false; Tailwind=$false
  Vitest=$false; Jest=$false; Docker=$false
  Vercel=$false; Replit=$false; Cloudflare=$false; Firebase=$false
  Drizzle=$false; Prisma=$false; MongoDB=$false; Turbo=$false
}

if (Test-Path 'package.json') {
  $flags.Node = $true
  try {
    $pkg = Get-Content 'package.json' -Raw | ConvertFrom-Json
    $deps = @{}
    foreach ($group in 'dependencies','devDependencies','peerDependencies') {
      if ($pkg.$group) {
        $pkg.$group.PSObject.Properties | ForEach-Object { $deps[$_.Name] = $true }
      }
    }
    $flags.React    = $deps.ContainsKey('react')
    $flags.Vue      = $deps.ContainsKey('vue')
    $flags.Svelte   = $deps.ContainsKey('svelte')
    $flags.Next     = $deps.ContainsKey('next')
    $flags.Express  = $deps.ContainsKey('express')
    $flags.Tailwind = $deps.ContainsKey('tailwindcss')
    $flags.Vitest   = $deps.ContainsKey('vitest')
    $flags.Jest     = $deps.ContainsKey('jest')
    $flags.Drizzle  = $deps.ContainsKey('drizzle-orm')
    $flags.Prisma   = $deps.ContainsKey('prisma') -or $deps.ContainsKey('@prisma/client')
    $flags.MongoDB  = $deps.ContainsKey('mongodb') -or $deps.ContainsKey('mongoose')
    $flags.Firebase = $deps.ContainsKey('firebase')
    $flags.Turbo    = $deps.ContainsKey('turbo')
  } catch {
    Write-Warn "package.json invalido, ignorando deps Node."
  }
}

if ((Test-Path 'requirements.txt') -or (Test-Path 'pyproject.toml') -or (Test-Path 'Pipfile')) {
  $flags.Python = $true
  $pyContent = ''
  foreach ($f in 'requirements.txt','pyproject.toml','Pipfile') {
    if (Test-Path $f) { $pyContent += (Get-Content $f -Raw -ErrorAction SilentlyContinue) }
  }
  $flags.FastAPI = $pyContent -match '(?i)fastapi'
  $flags.Django  = $pyContent -match '(?i)django'
  $flags.Flask   = $pyContent -match '(?i)flask'
}

if ((Test-Path 'Dockerfile') -or (Test-Path 'docker-compose.yml')) { $flags.Docker = $true }
if (Test-Path 'vercel.json')   { $flags.Vercel = $true }
if (Test-Path '.replit')       { $flags.Replit = $true }
if (Test-Path 'wrangler.toml') { $flags.Cloudflare = $true }

$hasBackend  = $flags.Express -or $flags.FastAPI -or $flags.Django -or $flags.Flask -or $flags.Next
$hasFrontend = $flags.React -or $flags.Vue -or $flags.Svelte
$hasDb       = $flags.Drizzle -or $flags.Prisma -or $flags.MongoDB -or $flags.Firebase

if (-not $Template) {
  if ($hasBackend -and $hasFrontend)      { $Template = 'fullstack' }
  elseif ($hasBackend)                    { $Template = 'api-backend' }
  elseif ($hasFrontend)                   { $Template = 'frontend' }
  else                                    { $Template = 'generic' }
}

Write-Info 'Stack detectado:'
$flags.GetEnumerator() | Where-Object { $_.Value } | ForEach-Object { Write-Host "    - $($_.Key)" }
Write-Info "Template selecionado: $Template"

# ---- 3/6 Adicionar submodule ----
Write-Step '3/6 Adicionando agnostic-core como submodule'
if (Test-Path '.agnostic-core') {
  Write-Warn '.agnostic-core ja existe. Atualizando...'
  git submodule update --remote .agnostic-core
} else {
  git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
  git submodule update --init
}

# ---- 4/6 Gerar ou complementar CLAUDE.md ----
Write-Step '4/6 Configurando CLAUDE.md'

$claudeFile = @('CLAUDE.md','claude.md') | Where-Object { Test-Path $_ } | Select-Object -First 1

function Add-SkillSection {
  param([string]$File, [hashtable]$F, [bool]$Backend, [bool]$Frontend, [bool]$Db)

  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add('')
  $lines.Add('---')
  $lines.Add('')
  $lines.Add('## Acervo de Referencia - agnostic-core')
  $lines.Add('')
  $lines.Add('Submodule em `.agnostic-core/` com skills, agents e workflows reutilizaveis.')
  $lines.Add('Consultar quando relevante para a tarefa em andamento.')
  $lines.Add('')
  $lines.Add('### Skills Relevantes (detectadas para este stack)')
  $lines.Add('')

  if ($Frontend) {
    $lines.Add('Frontend:')
    $lines.Add('  HTML/CSS Audit:        .agnostic-core/skills/frontend/html-css-audit.md')
    $lines.Add('  Acessibilidade:        .agnostic-core/skills/frontend/accessibility.md')
    $lines.Add('  UX Guidelines:         .agnostic-core/skills/frontend/ux-guidelines.md')
    if ($F.React)    { $lines.Add('  React Performance:     .agnostic-core/skills/frontend/react-performance.md') }
    if ($F.Tailwind) {
      $lines.Add('  Tailwind Patterns:     .agnostic-core/skills/frontend/tailwind-patterns.md')
      $lines.Add('  CSS Governance:        .agnostic-core/skills/frontend/css-governance.md')
    }
    $lines.Add('  SEO:                   .agnostic-core/skills/frontend/seo-checklist.md')
    $lines.Add('')
  }

  if ($Backend) {
    $lines.Add('Backend:')
    $lines.Add('  REST API Design:       .agnostic-core/skills/backend/rest-api-design.md')
    $lines.Add('  Error Handling:        .agnostic-core/skills/backend/error-handling.md')
    $lines.Add('  Seguranca de API:      .agnostic-core/skills/security/api-hardening.md')
    $lines.Add('  OWASP Checklist:       .agnostic-core/skills/security/owasp-checklist.md')
    if ($F.Node)    { $lines.Add('  Node.js Patterns:      .agnostic-core/skills/nodejs/nodejs-patterns.md') }
    if ($F.Express) { $lines.Add('  Express Practices:     .agnostic-core/skills/nodejs/express-best-practices.md') }
    if ($F.Python)  { $lines.Add('  Python Patterns:       .agnostic-core/skills/python/python-patterns.md') }
    $lines.Add('')
  }

  if ($Db) {
    $lines.Add('Banco de Dados:')
    $lines.Add('  Query Compliance:      .agnostic-core/skills/database/query-compliance.md')
    $lines.Add('  Schema Design:         .agnostic-core/skills/database/schema-design.md')
    $lines.Add('')
  }

  $lines.Add('Testes:')
  $lines.Add('  Unit Testing:          .agnostic-core/skills/testing/unit-testing.md')
  $lines.Add('  TDD Workflow:          .agnostic-core/skills/testing/tdd-workflow.md')
  $lines.Add('')

  $lines.Add('Performance:')
  $lines.Add('  Performance Audit:     .agnostic-core/skills/performance/performance-audit.md')
  $lines.Add('  Caching Strategies:    .agnostic-core/skills/cache/estrategias-de-cache.md')
  $lines.Add('')

  $lines.Add('Deploy:')
  $lines.Add('  Pre-Deploy Checklist:  .agnostic-core/skills/devops/pre-deploy-checklist.md')
  if ($F.Vercel)     { $lines.Add('  Vercel Patterns:       .agnostic-core/skills/platforms/vercel/vercel-patterns.md') }
  if ($F.Replit)     { $lines.Add('  Replit Patterns:       .agnostic-core/skills/platforms/replit/replit-patterns.md') }
  if ($F.Cloudflare) { $lines.Add('  Cloudflare Patterns:   .agnostic-core/skills/platforms/cloudflare/cloudflare-patterns.md') }
  if ($F.Docker)     { $lines.Add('  Containerizacao:       .agnostic-core/skills/devops/containerizacao.md') }
  $lines.Add('')

  $lines.Add('Qualidade:')
  $lines.Add('  Code Review:           .agnostic-core/skills/audit/code-review.md')
  $lines.Add('  Debugging:             .agnostic-core/skills/audit/systematic-debugging.md')
  $lines.Add('  Commit Conventions:    .agnostic-core/skills/git/commit-conventions.md')
  $lines.Add('')

  $lines.Add('Produtividade:')
  $lines.Add('  Claude Code Tips:      .agnostic-core/skills/workflow/claude-code-productivity.md')
  $lines.Add('  Context Management:    .agnostic-core/skills/workflow/context-management.md')
  $lines.Add('  Model Routing:         .agnostic-core/skills/ai/model-routing.md')
  if ($F.Turbo) { $lines.Add('  Monorepo:              .agnostic-core/skills/devops/monorepo.md') }
  $lines.Add('')

  $lines.Add('### Commands')
  $lines.Add('')
  $lines.Add('  Catalogo completo:     .agnostic-core/commands/claude-code/COMMANDS.md')

  Add-Content -Path $File -Value $lines -Encoding UTF8
}

if ($claudeFile) {
  $content = Get-Content $claudeFile -Raw -ErrorAction SilentlyContinue
  if ($content -match 'agnostic-core') {
    Write-Info "$claudeFile ja referencia agnostic-core. Pulando."
  } else {
    Write-Info "Adicionando secao de referencia ao $claudeFile existente..."
    $hashFlags = @{}
    $flags.GetEnumerator() | ForEach-Object { $hashFlags[$_.Key] = $_.Value }
    Add-SkillSection -File $claudeFile -F $hashFlags -Backend $hasBackend -Frontend $hasFrontend -Db $hasDb
  }
} else {
  $templateDir = switch ($Template) {
    'fullstack'   { '.agnostic-core/templates/project-bootstrap/fullstack/CLAUDE.md' }
    'api-backend' { '.agnostic-core/templates/project-bootstrap/api-backend/CLAUDE.md' }
    'frontend'    { '.agnostic-core/templates/project-bootstrap/frontend/CLAUDE.md' }
    'generic'     { '.agnostic-core/templates/project-bootstrap/fullstack/CLAUDE.md' }
  }
  Copy-Item $templateDir 'CLAUDE.md'
  $claudeFile = 'CLAUDE.md'
  Write-Info "CLAUDE.md criado a partir do template $Template"
  Write-Info 'IMPORTANTE: Edite o CLAUDE.md e preencha as convencoes do projeto'
}

# ---- 4b/6 Selecao de skills e camada nativa ----
Write-Step '4b/6 Selecionando skills e gerando camada nativa'

# A selecao (.agnostic-skills) e escrita aqui, em PowerShell puro, porque e o
# que protege o projeto: sem ela o gerador espelha o acervo INTEIRO, e cada
# skill espelhada custa uma linha no system prompt de TODA sessao — um projeto
# TypeScript pagando por python-patterns e replit-patterns em cada turno.
# Escrever a selecao agora garante que ela exista antes de qualquer geracao,
# inclusive uma rodada depois, por outra pessoa, em outro terminal.
#
# Nunca sobrescrevemos um arquivo existente: selecao e decisao do projeto.
if (Test-Path '.agnostic-skills') {
  Write-Info '.agnostic-skills ja existe — mantido como esta.'
} else {
  $sel = [System.Collections.Generic.List[string]]::new()
  $sel.Add('# Skills do agnostic-core espelhadas em .claude/skills/.')
  $sel.Add("# Um padrao por linha. '!' exclui. '*' casa dentro de uma categoria.")
  $sel.Add('# Gerado por install.ps1 a partir do stack detectado — edite a vontade.')
  $sel.Add('# O acervo completo continua disponivel em .agnostic-core/skills/;')
  $sel.Add('# esta lista controla so o que e pre-carregado em toda sessao.')
  $sel.Add('')
  $sel.Add('# --- nucleo (independe de stack) ---')
  $sel.AddRange([string[]]@(
    'behavioral/*', 'workflow/*', 'git/*',
    'audit/code-review', 'audit/systematic-debugging', 'audit/pre-implementation',
    'audit/senior-verification-protocol', 'documentation/technical-docs'
  ))

  if ($hasFrontend -or $flags.Next) {
    $sel.Add(''); $sel.Add('# --- frontend ---')
    $sel.AddRange([string[]]@(
      'frontend/accessibility', 'frontend/html-css-audit', 'frontend/css-governance',
      'frontend/ux-guidelines', 'frontend/seo-checklist', 'ux-ui/*', 'design/sem-cara-de-ia'
    ))
    if ($flags.React)    { $sel.AddRange([string[]]@('frontend/react-performance','frontend/react-task-checklists')) }
    if ($flags.Tailwind) { $sel.AddRange([string[]]@('frontend/tailwind-patterns','frontend/dark-mode-tokens')) }
  }

  if ($hasBackend) {
    $sel.Add(''); $sel.Add('# --- backend ---')
    $sel.AddRange([string[]]@(
      'backend/rest-api-design', 'backend/error-handling',
      'security/api-hardening', 'security/owasp-checklist', 'performance/performance-audit'
    ))
    if ($flags.Express) { $sel.Add('nodejs/*') }
  }

  if ($hasDb)        { $sel.Add(''); $sel.Add('# --- banco de dados ---'); $sel.Add('database/*') }
  if ($flags.Python) { $sel.Add(''); $sel.Add('# --- python ---');         $sel.Add('python/*') }
  if ($flags.Vitest -or $flags.Jest) { $sel.Add(''); $sel.Add('# --- testes ---'); $sel.Add('testing/*') }

  if ($flags.Docker -or $flags.Vercel -or $flags.Replit -or $flags.Cloudflare -or $flags.Turbo) {
    $sel.Add(''); $sel.Add('# --- devops / plataforma ---')
    $sel.AddRange([string[]]@('devops/deploy-procedures','devops/pre-deploy-checklist'))
    if ($flags.Docker)     { $sel.Add('devops/containerizacao') }
    if ($flags.Turbo)      { $sel.Add('devops/monorepo') }
    if ($flags.Vercel)     { $sel.Add('platforms/vercel/*') }
    if ($flags.Replit)     { $sel.Add('platforms/replit/*') }
    if ($flags.Cloudflare) { $sel.Add('platforms/cloudflare/*') }
  }

  Set-Content -Path '.agnostic-skills' -Value $sel -Encoding UTF8
  $nPat = ($sel | Where-Object { $_ -and -not $_.StartsWith('#') }).Count
  Write-Info ".agnostic-skills criado ($nPat padroes, do stack detectado)."
}

# O gerador da camada nativa e um script bash e continua sendo o unico —
# reescreve-lo em PowerShell criaria uma segunda implementacao da mesma logica
# de slug, extracao de description e poda, que divergiriam em silencio.
# No Windows, bash vem junto com o Git (Git Bash), entao na pratica ele existe
# quase sempre; quando nao existir, dizemos exatamente o que rodar.
$genScript = '.agnostic-core/scripts/generate-claude-skills.sh'
$bashExe = (Get-Command bash -ErrorAction SilentlyContinue)
if (-not (Test-Path $genScript)) {
  Write-Warn "$genScript nao encontrado. Pulando a camada nativa."
} elseif ($bashExe) {
  & $bashExe.Source $genScript (Get-Location).Path
} else {
  Write-Warn 'bash nao encontrado — camada nativa .claude/skills/ NAO foi gerada.'
  Write-Info 'O Claude Code so autodescobre as skills depois de gera-la. Rode uma destas:'
  Write-Info '  no Git Bash:  bash .agnostic-core/scripts/generate-claude-skills.sh'
  Write-Info '  ou:           npx agnostic-core@latest init'
  Write-Info 'A selecao em .agnostic-skills ja esta pronta e sera respeitada.'
}

# ---- 4c/6 Configurando sync automatico do submodulo (CI) ----
Write-Step '4c/6 Configurando sync automatico do submodulo (CI)'

# .agnostic-skills evita o acervo inteiro no system prompt; este workflow
# evita o pin do submodulo ficar parado meses sem ninguem notar.
$workflowFile = '.github/workflows/sync-agnostic-core.yml'
if (Test-Path $workflowFile) {
  Write-Info "$workflowFile ja existe — mantido como esta."
} else {
  New-Item -ItemType Directory -Force -Path '.github/workflows' | Out-Null
  $workflowContent = @'
name: Sync agnostic-core

on:
  schedule:
    - cron: '0 6 * * *' # todo dia as 06:00 UTC (03:00 BRT)
  workflow_dispatch: # permite rodar manualmente pela UI do GitHub

permissions:
  contents: write

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: true
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Update submodule
        run: git submodule update --remote .agnostic-core

      - name: Check for changes
        id: diff
        run: |
          git diff --quiet .agnostic-core && echo "changed=false" >> $GITHUB_OUTPUT || echo "changed=true" >> $GITHUB_OUTPUT

      - name: Commit and push
        if: steps.diff.outputs.changed == 'true'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add .agnostic-core
          git commit -m "chore: sync agnostic-core submodule [skip ci]"
          git push
'@
  Set-Content -Path $workflowFile -Value $workflowContent -Encoding UTF8
  Write-Info "$workflowFile criado — cron diario mantem o pin em dia sem intervencao manual."
}

# ---- 5/6 Configurar auto-push hook ----
Write-Step '5/6 Configurando auto-push hook'

$settingsDir  = Join-Path $env:USERPROFILE '.claude'
$settingsFile = Join-Path $settingsDir 'settings.json'

if (Test-Path $settingsDir) {
  if (-not (Test-Path $settingsFile)) { '{}' | Set-Content $settingsFile -Encoding UTF8 }
  $raw = Get-Content $settingsFile -Raw
  if ($raw -match 'post-tool-use-autopush') {
    Write-Info 'Hook auto-push ja configurado. Pulando.'
  } else {
    try { $settings = $raw | ConvertFrom-Json } catch { $settings = [pscustomobject]@{} }

    if (-not $settings.PSObject.Properties['hooks']) {
      $settings | Add-Member -NotePropertyName 'hooks' -NotePropertyValue ([pscustomobject]@{})
    }
    if (-not $settings.hooks.PSObject.Properties['PostToolUse']) {
      $settings.hooks | Add-Member -NotePropertyName 'PostToolUse' -NotePropertyValue @()
    }

    $newEntry = [pscustomobject]@{
      matcher = 'Bash'
      hooks   = @(
        [pscustomobject]@{
          type    = 'command'
          command = '.agnostic-core/scripts/hooks/post-tool-use-autopush'
        }
      )
    }
    $settings.hooks.PostToolUse = @($settings.hooks.PostToolUse) + $newEntry
    $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsFile -Encoding UTF8
    Write-Info "Hook auto-push configurado em $settingsFile"
  }
} else {
  Write-Warn 'Claude Code nao detectado (~/.claude nao existe). Pulando hook.'
}

# ---- 5b/6 Configurar hooks do agnostic-router ----
Write-Step '5b/6 Configurando hooks do agnostic-router'

if (Test-Path $settingsDir) {
  if (-not (Test-Path $settingsFile)) { '{}' | Set-Content $settingsFile -Encoding UTF8 }
  $raw = Get-Content $settingsFile -Raw
  if ($raw -match 'user-prompt-router') {
    Write-Info 'Hooks do agnostic-router ja configurados. Pulando.'
  } else {
    try { $settings = $raw | ConvertFrom-Json } catch { $settings = [pscustomobject]@{} }

    if (-not $settings.PSObject.Properties['hooks']) {
      $settings | Add-Member -NotePropertyName 'hooks' -NotePropertyValue ([pscustomobject]@{})
    }
    if (-not $settings.hooks.PSObject.Properties['UserPromptSubmit']) {
      $settings.hooks | Add-Member -NotePropertyName 'UserPromptSubmit' -NotePropertyValue @()
    }
    if (-not $settings.hooks.PSObject.Properties['Stop']) {
      $settings.hooks | Add-Member -NotePropertyName 'Stop' -NotePropertyValue @()
    }

    $routerPromptCmd = '[ -f .agnostic-core/scripts/hooks/user-prompt-router.js ] && node .agnostic-core/scripts/hooks/user-prompt-router.js || true'
    $routerStopCmd   = '[ -f .agnostic-core/scripts/hooks/stop-router-update.js ] && node .agnostic-core/scripts/hooks/stop-router-update.js || true'

    $newPromptEntry = [pscustomobject]@{
      hooks = @([pscustomobject]@{ type = 'command'; command = $routerPromptCmd })
    }
    $newStopEntry = [pscustomobject]@{
      hooks = @([pscustomobject]@{ type = 'command'; command = $routerStopCmd })
    }
    $settings.hooks.UserPromptSubmit = @($settings.hooks.UserPromptSubmit) + $newPromptEntry
    $settings.hooks.Stop = @($settings.hooks.Stop) + $newStopEntry
    $settings | ConvertTo-Json -Depth 20 | Set-Content $settingsFile -Encoding UTF8
    Write-Info "Hooks do agnostic-router configurados em $settingsFile"
  }
} else {
  Write-Warn 'Claude Code nao detectado (~/.claude nao existe). Pulando hook.'
}

# ---- 6/6 Commit e push ----
Write-Step '6/6 Commitando'
git add .agnostic-core .gitmodules $claudeFile
if (Test-Path '.claude') { git add .claude }
if (Test-Path '.agnostic-skills') { git add .agnostic-skills }
if (Test-Path '.github') { git add .github }
git commit -m "chore: integrar agnostic-core ($Template) com skills selecionadas por stack"
$branch = (git branch --show-current).Trim()
git push origin $branch

Write-Host ''
Write-Host '============================================' -ForegroundColor Green
Write-Host "  INSTALACAO CONCLUIDA - $repoName"           -ForegroundColor Green
Write-Host '============================================' -ForegroundColor Green
Write-Host ''
Write-Host "  Template: $Template"
Write-Host "  Arquivo:  $claudeFile"
Write-Host ''
Write-Host '  Verificacao:'
Write-Host '    ls .agnostic-core/skills/   -> deve listar 13+ diretorios'
Write-Host '    git submodule status        -> deve mostrar commit'
Write-Host ''
Write-Host '  Proximo passo no Claude Code:'
Write-Host '    @.agnostic-core/commands/claude-code/COMMANDS.md'
Write-Host '    liste os prompts prontos disponiveis'
Write-Host ''
