# setup.ps1 — Browser MCP + Chrome DevTools MCP
# Skill: browser-mcp | agnostic-core
# Uso: Execute como Administrador no PowerShell
# Posicione o terminal na raiz do projeto antes de executar

param(
    [string]$ProjectPath = (Get-Location).Path,
    [switch]$Global  # Instala globalmente em ~/.claude/mcp.json em vez do projeto
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Browser MCP + Chrome DevTools Setup  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ─── 1. Verificar Node.js ───────────────────────────────────────────────────
Write-Host "[1/4] Verificando Node.js..." -ForegroundColor Yellow

try {
    $nodeVersion = node -v 2>&1
    Write-Host "      OK — Node.js $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "      ERRO: Node.js nao encontrado. Instale em https://nodejs.org" -ForegroundColor Red
    exit 1
}

# ─── 2. Verificar/Instalar npx ──────────────────────────────────────────────
Write-Host "[2/4] Verificando npx..." -ForegroundColor Yellow

try {
    npx --version | Out-Null
    Write-Host "      OK — npx disponivel" -ForegroundColor Green
} catch {
    Write-Host "      ERRO: npx nao encontrado. Reinstale o Node.js." -ForegroundColor Red
    exit 1
}

# ─── 3. Testar servidores MCP ────────────────────────────────────────────────
Write-Host "[3/4] Validando pacotes MCP (dry-run)..." -ForegroundColor Yellow

Write-Host "      Testando @browsermcp/mcp..." -ForegroundColor Gray
$browsermcpOk = $false
try {
    $result = npx @browsermcp/mcp@latest --help 2>&1
    $browsermcpOk = $true
    Write-Host "      OK — @browsermcp/mcp" -ForegroundColor Green
} catch {
    Write-Host "      AVISO: Nao foi possivel validar @browsermcp/mcp (pode funcionar mesmo assim)" -ForegroundColor Yellow
}

Write-Host "      Testando chrome-devtools-mcp..." -ForegroundColor Gray
$devtoolsOk = $false
try {
    $result = npx chrome-devtools-mcp@latest --help 2>&1
    $devtoolsOk = $true
    Write-Host "      OK — chrome-devtools-mcp" -ForegroundColor Green
} catch {
    Write-Host "      AVISO: Nao foi possivel validar chrome-devtools-mcp (pode funcionar mesmo assim)" -ForegroundColor Yellow
}

# ─── 4. Injetar configuracao no .mcp.json ────────────────────────────────────
Write-Host "[4/4] Configurando .mcp.json..." -ForegroundColor Yellow

$mcpConfig = @{
    mcpServers = @{
        browsermcp = @{
            command = "npx"
            args    = @("@browsermcp/mcp@latest")
        }
        "chrome-devtools" = @{
            command = "npx"
            args    = @("chrome-devtools-mcp@latest", "--slim")
        }
    }
} | ConvertTo-Json -Depth 5

if ($Global) {
    $targetDir = "$env:USERPROFILE\.claude"
    $targetFile = "$targetDir\mcp.json"
    Write-Host "      Modo: Global (~\.claude\mcp.json)" -ForegroundColor Gray
} else {
    $targetDir = $ProjectPath
    $targetFile = "$targetDir\.mcp.json"
    Write-Host "      Modo: Projeto ($targetFile)" -ForegroundColor Gray
}

# Criar diretório se necessário
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# Merge com config existente ou criar novo
if (Test-Path $targetFile) {
    Write-Host "      Arquivo existente encontrado. Fazendo merge..." -ForegroundColor Gray
    try {
        $existing = Get-Content $targetFile -Raw | ConvertFrom-Json
        
        # Adicionar/atualizar mcpServers sem sobrescrever outros campos
        if (-not $existing.mcpServers) {
            $existing | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value @{}
        }
        
        $existing.mcpServers | Add-Member -MemberType NoteProperty -Name "browsermcp" -Value @{
            command = "npx"
            args    = @("@browsermcp/mcp@latest")
        } -Force
        
        $existing.mcpServers | Add-Member -MemberType NoteProperty -Name "chrome-devtools" -Value @{
            command = "npx"
            args    = @("chrome-devtools-mcp@latest", "--slim")
        } -Force
        
        $existing | ConvertTo-Json -Depth 5 | Set-Content $targetFile -Encoding UTF8
        Write-Host "      OK — Merge realizado em $targetFile" -ForegroundColor Green
    } catch {
        Write-Host "      AVISO: Nao foi possivel fazer merge. Sobrescrevendo..." -ForegroundColor Yellow
        $mcpConfig | Set-Content $targetFile -Encoding UTF8
        Write-Host "      OK — Arquivo criado em $targetFile" -ForegroundColor Green
    }
} else {
    $mcpConfig | Set-Content $targetFile -Encoding UTF8
    Write-Host "      OK — Arquivo criado em $targetFile" -ForegroundColor Green
}

# ─── Resumo ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Setup concluido!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor White
Write-Host ""
Write-Host "  1. Instale a extensao Browser MCP no Chrome:" -ForegroundColor Gray
Write-Host "     https://chromewebstore.google.com/detail/browser-mcp-automate-your/bjfgambnhccakkhmkepdoekmckoijdlc" -ForegroundColor Blue
Write-Host ""
Write-Host "  2. Clique no icone da extensao > botao [Connect]" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Reinicie o Claude Code no projeto:" -ForegroundColor Gray
Write-Host "     cd $ProjectPath" -ForegroundColor DarkGray
Write-Host "     claude" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  4. Claude Code ja reconhece os servidores MCP automaticamente." -ForegroundColor Gray
Write-Host ""
