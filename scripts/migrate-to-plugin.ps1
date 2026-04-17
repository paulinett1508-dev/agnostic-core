# ============================================================
# agnostic-core - Migracao: flat .md -> plugin SKILL.md
#
# Converte skills/cat/foo.md -> skills-plugin/cat/foo/SKILL.md
# mantendo os originais intactos (para usuarios em modo submodule).
#
# Uso:
#   .\migrate-to-plugin.ps1                      # migra tudo
#   .\migrate-to-plugin.ps1 -Category workflow   # so uma categoria
#   .\migrate-to-plugin.ps1 -DryRun              # lista sem escrever
# ============================================================

#Requires -Version 5.1
[CmdletBinding()]
param(
  [string]$Category = '',
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$repoRoot   = Split-Path -Parent $PSScriptRoot
$skillsSrc  = Join-Path $repoRoot 'skills'
$skillsDest = Join-Path $repoRoot 'skills-plugin'

if (-not (Test-Path $skillsSrc)) {
  Write-Host "ERRO: $skillsSrc nao encontrado" -ForegroundColor Red
  exit 1
}

function ConvertTo-SkillFrontmatter {
  param([string]$Content, [string]$Name)

  # Extrai frontmatter existente (YAML entre --- ---)
  $hasFrontmatter = $Content -match '(?ms)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$'

  $description = $null
  $body        = $Content

  if ($hasFrontmatter) {
    $yaml = $Matches[1]
    $body = $Matches[2]
    if ($yaml -match '(?m)^description:\s*(.+)$') {
      $description = $Matches[1].Trim().Trim('"').Trim("'")
    } elseif ($yaml -match '(?m)^title:\s*(.+)$') {
      $description = $Matches[1].Trim().Trim('"').Trim("'")
    }
  }

  if (-not $description) {
    # Usa primeiro paragrafo apos # heading como descricao
    if ($body -match '(?ms)^#\s+.+?\r?\n\r?\n(.+?)(\r?\n\r?\n|$)') {
      $description = ($Matches[1] -replace '\r?\n', ' ').Trim()
      if ($description.Length -gt 200) {
        $description = $description.Substring(0, 197) + '...'
      }
    } else {
      $description = "Skill $Name do agnostic-core"
    }
  }

  $description = $description -replace '"', "'"

  $newFrontmatter = @"
---
name: $Name
description: $description
---

"@
  return $newFrontmatter + $body.TrimStart()
}

$categories = if ($Category) {
  @(Get-Item (Join-Path $skillsSrc $Category) -ErrorAction SilentlyContinue)
} else {
  Get-ChildItem -Path $skillsSrc -Directory
}

if (-not $categories) {
  Write-Host "Nenhuma categoria encontrada" -ForegroundColor Yellow
  exit 0
}

$migrated = 0
$skipped  = 0

foreach ($cat in $categories) {
  Write-Host "`n== Categoria: $($cat.Name) ==" -ForegroundColor Cyan

  $files = Get-ChildItem -Path $cat.FullName -Filter '*.md' -File

  foreach ($f in $files) {
    $skillName = $f.BaseName
    $destDir   = Join-Path $skillsDest (Join-Path $cat.Name $skillName)
    $destFile  = Join-Path $destDir 'SKILL.md'

    if (Test-Path $destFile) {
      Write-Host "  [SKIP] $($cat.Name)/$skillName (ja existe)" -ForegroundColor DarkGray
      $skipped++
      continue
    }

    if ($DryRun) {
      Write-Host "  [DRY]  $($f.Name) -> $($cat.Name)/$skillName/SKILL.md"
      continue
    }

    $content = Get-Content $f.FullName -Raw
    $newContent = ConvertTo-SkillFrontmatter -Content $content -Name $skillName

    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    Set-Content -Path $destFile -Value $newContent -Encoding UTF8

    Write-Host "  [OK]   $($cat.Name)/$skillName" -ForegroundColor Green
    $migrated++
  }
}

Write-Host ""
Write-Host "Migrados: $migrated | Pulados: $skipped" -ForegroundColor Cyan
if ($DryRun) { Write-Host "(dry-run - nenhum arquivo escrito)" -ForegroundColor Yellow }
