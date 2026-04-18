# ============================================================
# agnostic-core - Script Universal de Instalacao (PowerShell)
# Execute na raiz de qualquer repositorio git
#
# Uso:
#   iwr -useb https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/scripts/install.ps1 | iex
#
# Com parametros:
#   .\install.ps1 -Template fullstack -NoHook -NoCommit
# ============================================================

[CmdletBinding()]
param(
    [ValidateSet('fullstack','api-backend','frontend','generic','')]
    [string]$Template = '',
    [switch]$NoHook,
    [switch]$NoCommit,
    [switch]$NoClaudeSkills
)

$ErrorActionPreference = 'Stop'

function Section($n, $total, $label) {
    Write-Host ""
    Write-Host "=== $n/$total $label ===" -ForegroundColor Cyan
}

# 1/7 - Verificar git repo
Section 1 7 'Verificando repositorio'
if (-not (Test-Path '.git')) {
    Write-Host "ERRO: nao e um repositorio git. Execute na raiz do projeto." -ForegroundColor Red
    exit 1
}
$repoName = Split-Path -Leaf (Get-Location)
Write-Host "  Repositorio: $repoName"

# 2/7 - Detectar stack
Section 2 7 'Detectando stack'
$has = @{
    React=$false; Vue=$false; Svelte=$false; Next=$false; Express=$false
    FastAPI=$false; Django=$false; Flask=$false; Python=$false; Node=$false
    Tailwind=$false; Vitest=$false; Jest=$false; Docker=$false; Vercel=$false
    Replit=$false; Cloudflare=$false; Firebase=$false; Drizzle=$false
    Prisma=$false; MongoDB=$false; Turbo=$false
}

if (Test-Path 'package.json') {
    $has.Node = $true
    $pkg = Get-Content 'package.json' -Raw
    if ($pkg -match '"react"')        { $has.React = $true }
    if ($pkg -match '"vue"')          { $has.Vue = $true }
    if ($pkg -match '"svelte"')       { $has.Svelte = $true }
    if ($pkg -match '"next"')         { $has.Next = $true }
    if ($pkg -match '"express"')      { $has.Express = $true }
    if ($pkg -match '"tailwindcss"')  { $has.Tailwind = $true }
    if ($pkg -match '"vitest"')       { $has.Vitest = $true }
    if ($pkg -match '"jest"')         { $has.Jest = $true }
    if ($pkg -match '"drizzle-orm"')  { $has.Drizzle = $true }
    if ($pkg -match '"@?prisma')      { $has.Prisma = $true }
    if ($pkg -match '"mongo(db|ose)"'){ $has.MongoDB = $true }
    if ($pkg -match '"firebase"')     { $has.Firebase = $true }
    if ($pkg -match '"turbo"')        { $has.Turbo = $true }
}

if ((Test-Path 'requirements.txt') -or (Test-Path 'pyproject.toml') -or (Test-Path 'Pipfile')) {
    $has.Python = $true
    $py = (Get-Content 'requirements.txt','pyproject.toml','Pipfile' -ErrorAction SilentlyContinue) -join "`n"
    if ($py -match '(?i)fastapi') { $has.FastAPI = $true }
    if ($py -match '(?i)django')  { $has.Django = $true }
    if ($py -match '(?i)flask')   { $has.Flask = $true }
}

if ((Test-Path 'Dockerfile') -or (Test-Path 'docker-compose.yml')) { $has.Docker = $true }
if (Test-Path 'vercel.json')    { $has.Vercel = $true }
if (Test-Path '.replit')        { $has.Replit = $true }
if (Test-Path 'wrangler.toml')  { $has.Cloudflare = $true }

$hasBackend  = $has.Express -or $has.FastAPI -or $has.Django -or $has.Flask -or $has.Next
$hasFrontend = $has.React -or $has.Vue -or $has.Svelte
$hasDb       = $has.Drizzle -or $has.Prisma -or $has.MongoDB -or $has.Firebase

if (-not $Template) {
    if ($hasBackend -and $hasFrontend)     { $Template = 'fullstack' }
    elseif ($hasBackend -and -not $hasFrontend) { $Template = 'api-backend' }
    elseif ($hasFrontend -and -not $hasBackend) { $Template = 'frontend' }
    else                                   { $Template = 'generic' }
}
Write-Host "  Template selecionado: $Template"

# 3/7 - Submodule
Section 3 7 'Adicionando agnostic-core como submodule'
if (Test-Path '.agnostic-core') {
    Write-Host "  AVISO: .agnostic-core ja existe. Atualizando..." -ForegroundColor Yellow
    git submodule update --remote .agnostic-core
} else {
    git submodule add https://github.com/paulinett1508-dev/agnostic-core.git .agnostic-core
    git submodule update --init
}

# 4/7 - CLAUDE.md
Section 4 7 'Configurando CLAUDE.md'
$claudeFile = $null
if (Test-Path 'CLAUDE.md') { $claudeFile = 'CLAUDE.md' }
elseif (Test-Path 'claude.md') { $claudeFile = 'claude.md' }

if ($claudeFile) {
    $content = Get-Content $claudeFile -Raw
    if ($content -match 'agnostic-core') {
        Write-Host "  $claudeFile ja referencia agnostic-core. Pulando."
    } else {
        Write-Host "  Adicionando secao de referencia ao $claudeFile..."
        $section = @"

---

## Acervo de Referencia - agnostic-core

Submodule em ``.agnostic-core/`` com skills, agents e workflows reutilizaveis.
Consultar quando relevante para a tarefa em andamento.

Skills relevantes indexadas em: ``.agnostic-core/docs/skills-index.md``

### Commands
Catalogo completo: ``.agnostic-core/commands/claude-code/COMMANDS.md``
"@
        Add-Content -Path $claudeFile -Value $section
    }
} else {
    Write-Host "  Copiando template $Template..."
    $src = ".agnostic-core/templates/project-bootstrap/$Template/CLAUDE.md"
    if (-not (Test-Path $src)) { $src = '.agnostic-core/templates/project-bootstrap/fullstack/CLAUDE.md' }
    Copy-Item $src 'CLAUDE.md'
    $claudeFile = 'CLAUDE.md'
    Write-Host "  CLAUDE.md criado a partir do template $Template"
}

# 5/7 - .claude/skills/
Section 5 7 'Gerando camada nativa .claude/skills/'
if ($NoClaudeSkills) {
    Write-Host "  Pulado (-NoClaudeSkills)."
} elseif (Test-Path '.agnostic-core/scripts/generate-claude-skills.sh') {
    if (Get-Command bash -ErrorAction SilentlyContinue) {
        bash .agnostic-core/scripts/generate-claude-skills.sh (Get-Location).Path
    } else {
        Write-Host "  AVISO: bash nao encontrado. Instale Git for Windows ou WSL." -ForegroundColor Yellow
    }
} else {
    Write-Host "  AVISO: generate-claude-skills.sh nao encontrado." -ForegroundColor Yellow
}

# 6/7 - Hook auto-push
Section 6 7 'Configurando auto-push hook'
$settingsDir  = Join-Path $HOME '.claude'
$settingsFile = Join-Path $settingsDir 'settings.json'

if ($NoHook) {
    Write-Host "  Pulado (-NoHook)."
} elseif (Test-Path $settingsDir) {
    if (-not (Test-Path $settingsFile)) {
        Set-Content $settingsFile '{}'
    }
    $existing = Get-Content $settingsFile -Raw
    if ($existing -match 'post-tool-use-autopush') {
        Write-Host "  Hook auto-push ja configurado. Pulando."
    } else {
        try {
            $data = $existing | ConvertFrom-Json -AsHashtable
        } catch {
            $data = @{}
        }
        if (-not $data.hooks) { $data.hooks = @{} }
        if (-not $data.hooks.PostToolUse) { $data.hooks.PostToolUse = @() }
        $data.hooks.PostToolUse += @{
            matcher = 'Bash'
            hooks = @(@{ type='command'; command='.agnostic-core/scripts/hooks/post-tool-use-autopush' })
        }
        $data | ConvertTo-Json -Depth 20 | Set-Content $settingsFile
        Write-Host "  Hook auto-push configurado em $settingsFile"
    }
} else {
    Write-Host "  Claude Code nao detectado (~/.claude nao existe). Pulando hook."
}

# 7/7 - Commit
Section 7 7 'Commit e push'
if ($NoCommit) {
    Write-Host "  Pulado (-NoCommit). Execute manualmente:"
    Write-Host "    git add .agnostic-core .gitmodules $claudeFile .claude/"
    Write-Host "    git commit -m 'chore: integrar agnostic-core'"
    Write-Host "    git push"
} else {
    git add .agnostic-core .gitmodules $claudeFile
    if (Test-Path '.claude') { git add .claude }
    git commit -m "chore: integrar agnostic-core ($Template) com skills selecionadas por stack"
    git push origin (git branch --show-current)
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  INSTALACAO CONCLUIDA - $repoName" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Template: $Template"
Write-Host "  Arquivo:  $claudeFile"
