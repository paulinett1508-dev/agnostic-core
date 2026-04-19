#!/usr/bin/env node
/**
 * agnostic-core — entry point for `npx agnostic-core <command>`.
 *
 * Commands:
 *   init        Install agnostic-core in current git repo (runs install.sh)
 *   update      Update .agnostic-core submodule in current repo
 *   check       Run check-refs.sh to validate local .agnostic-core integrity
 *   list        List available skills, agents and commands
 *   help        Show usage
 *
 * Strategy: this wrapper simply delegates to the bash scripts. On Windows
 * without Git Bash, it prints install.ps1 instructions instead.
 */

'use strict';

const { spawnSync, execSync } = require('child_process');
const { existsSync, readdirSync, statSync } = require('fs');
const { join, resolve, basename } = require('path');
const os = require('os');
const https = require('https');

const PKG_ROOT = resolve(__dirname, '..');
const CMD = process.argv[2] || 'help';
const ARGS = process.argv.slice(3);
const LOCAL_VERSION = require('../package.json').version;

function checkForUpdates() {
  return new Promise((resolve) => {
    const req = https.get(
      'https://registry.npmjs.org/agnostic-core/latest',
      { headers: { 'Accept': 'application/json' }, timeout: 3000 },
      (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => {
          try {
            const latest = JSON.parse(data).version;
            if (latest && latest !== LOCAL_VERSION) {
              console.log(`\n⚠  Nova versão disponível: ${LOCAL_VERSION} → ${latest}`);
              console.log(`   npx agnostic-core@latest update\n`);
            }
          } catch { /* silently ignore */ }
          resolve();
        });
      }
    );
    req.on('error', () => resolve());
    req.on('timeout', () => { req.destroy(); resolve(); });
  });
}

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
  npx agnostic-core list [--skills] [--agents] [--commands]
  npx agnostic-core help

Docs: https://github.com/paulinett1508-dev/agnostic-core
`);
}

function listContents(args) {
  const showAll = args.length === 0;
  const showSkills   = showAll || args.includes('--skills');
  const showAgents   = showAll || args.includes('--agents');
  const showCommands = showAll || args.includes('--commands');

  // prefer local submodule if running inside a consumer repo
  const base = existsSync(join(process.cwd(), '.agnostic-core'))
    ? join(process.cwd(), '.agnostic-core')
    : PKG_ROOT;

  function listDir(dir) {
    if (!existsSync(dir)) return [];
    return readdirSync(dir).filter(f => statSync(join(dir, f)).isDirectory());
  }

  function listMdFiles(dir) {
    if (!existsSync(dir)) return [];
    return readdirSync(dir)
      .filter(f => f.endsWith('.md') && statSync(join(dir, f)).isFile())
      .map(f => f.replace(/\.md$/, ''));
  }

  console.log(`\nagnostic-core v${LOCAL_VERSION} — ${base}\n`);

  if (showSkills) {
    console.log('── SKILLS ──────────────────────────────');
    const entries = listDir(join(base, 'skills'));
    for (const entry of entries) {
      const entryDir = join(base, 'skills', entry);
      // if the dir itself is a skill (has SKILL.md directly), list it as a skill
      if (existsSync(join(entryDir, 'SKILL.md'))) {
        console.log(`  ${entry}`);
        continue;
      }
      // otherwise treat as category containing skills
      const flatFiles = listMdFiles(entryDir);
      const subDirs = readdirSync(entryDir)
        .filter(f => statSync(join(entryDir, f)).isDirectory())
        .filter(f => existsSync(join(entryDir, f, 'SKILL.md')));
      const items = [...flatFiles, ...subDirs];
      if (items.length) console.log(`  ${entry}/\n    ${items.join('\n    ')}`);
    }
    console.log('');
  }

  if (showAgents) {
    console.log('── AGENTS ──────────────────────────────');
    const agentsDir = join(base, 'agents');
    function walkAgents(dir, prefix = '') {
      if (!existsSync(dir)) return;
      for (const f of readdirSync(dir)) {
        const full = join(dir, f);
        if (statSync(full).isDirectory()) walkAgents(full, prefix + f + '/');
        else if (f.endsWith('.md')) console.log(`  ${prefix}${f.replace(/\.md$/, '')}`);
      }
    }
    walkAgents(agentsDir);
    console.log('');
  }

  if (showCommands) {
    console.log('── COMMANDS ────────────────────────────');
    const commandsDir = join(base, 'commands');
    function walkCmds(dir, prefix = '') {
      if (!existsSync(dir)) return;
      for (const f of readdirSync(dir)) {
        const full = join(dir, f);
        if (statSync(full).isDirectory()) walkCmds(full, prefix + f + '/');
        else if (f.endsWith('.md')) console.log(`  ${prefix}${f.replace(/\.md$/, '')}`);
      }
    }
    walkCmds(commandsDir);
    console.log('');
  }
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
     iwr -useb https://raw.githubusercontent.com/paulinett1508-dev/agnostic-core/master/scripts/install.ps1 | iex
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
    checkForUpdates().then(() => runBash('check-refs.sh', ARGS));
    break;
  case 'list':
    listContents(ARGS);
    process.exit(0);
    break;
  default:
    console.error(`Comando desconhecido: ${CMD}\n`);
    printHelp();
    process.exit(1);
}
