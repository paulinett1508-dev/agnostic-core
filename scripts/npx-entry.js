#!/usr/bin/env node
/**
 * agnostic-core — entry point for `npx agnostic-core <command>`.
 *
 * Commands:
 *   init        Install agnostic-core in current git repo (runs install.sh)
 *   update      Update .agnostic-core submodule in current repo
 *   check       Run check-refs.sh to validate local .agnostic-core integrity
 *   help        Show usage
 *
 * Strategy: this wrapper simply delegates to the bash scripts. On Windows
 * without Git Bash, it prints install.ps1 instructions instead.
 */

'use strict';

const { spawnSync, execSync } = require('child_process');
const { existsSync } = require('fs');
const { join, resolve } = require('path');
const os = require('os');

const PKG_ROOT = resolve(__dirname, '..');
const CMD = process.argv[2] || 'help';
const ARGS = process.argv.slice(3);

function hasBash() {
  try {
    execSync('bash --version', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function runBash(script, args) {
  const scriptPath = join(PKG_ROOT, 'scripts', script);
  if (!existsSync(scriptPath)) {
    console.error(`ERRO: script não encontrado: ${scriptPath}`);
    process.exit(1);
  }
  const result = spawnSync('bash', [scriptPath, ...args], { stdio: 'inherit' });
  process.exit(result.status === null ? 1 : result.status);
}

function printHelp() {
  console.log(`
agnostic-core — acervo agnóstico de Claude Code Skills

Usage:
  npx agnostic-core init [--template <t>] [--no-hook] [--no-commit]
  npx agnostic-core update
  npx agnostic-core check
  npx agnostic-core help

Docs: https://github.com/paulinett1508-dev/agnostic-core
`);
}

if (CMD === 'help' || CMD === '--help' || CMD === '-h') {
  printHelp();
  process.exit(0);
}

if (os.platform() === 'win32' && !hasBash()) {
  console.error(`
ERRO: bash não encontrado no Windows.

Opções:
  1. Instale Git for Windows (inclui Git Bash) e tente novamente.
  2. Use o script PowerShell diretamente:
     iwr -useb https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/main/scripts/install.ps1 | iex
`);
  process.exit(1);
}

switch (CMD) {
  case 'init':
    runBash('install.sh', ARGS);
    break;
  case 'update': {
    if (!existsSync('.agnostic-core')) {
      console.error('ERRO: .agnostic-core/ não encontrado. Use `npx agnostic-core init` primeiro.');
      process.exit(1);
    }
    const result = spawnSync('git', ['submodule', 'update', '--remote', '.agnostic-core'], { stdio: 'inherit' });
    process.exit(result.status === null ? 1 : result.status);
    break;
  }
  case 'check':
    runBash('check-refs.sh', ARGS);
    break;
  default:
    console.error(`Comando desconhecido: ${CMD}\n`);
    printHelp();
    process.exit(1);
}
