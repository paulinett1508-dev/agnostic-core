#!/usr/bin/env node
// UserPromptSubmit hook — declara o tier do agnostic-router pra cada prompt.
// Porte tecnico do "protocolo declarado" descrito em skills/ai/agnostic-router.md
// (secao "Enforcement real vs. protocolo declarado"): em CLI interativa o router
// nao troca o modelo sozinho (nao rebobina a chamada ja em curso) — so declara e
// deixa visivel via systemMessage. Estado de sessao persiste em disco entre turnos
// (ver stop-router-update.js, que fecha o ciclo com update_session apos a resposta).

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { Router, newSessionState } = require('../agnostic-router/router.js');

function statePath(sessionId) {
  const dir = path.join(os.tmpdir(), 'agnostic-router-state');
  fs.mkdirSync(dir, { recursive: true });
  return path.join(dir, `${sessionId}.json`);
}

function loadState(sessionId) {
  try {
    return JSON.parse(fs.readFileSync(statePath(sessionId), 'utf8'));
  } catch {
    return { session: newSessionState(), lastDecision: null };
  }
}

function saveState(sessionId, state) {
  fs.writeFileSync(statePath(sessionId), JSON.stringify(state));
}

let raw = '';
process.stdin.on('data', (chunk) => { raw += chunk; });
process.stdin.on('end', () => {
  let input;
  try {
    input = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const prompt = input.prompt || '';
  const sessionId = input.session_id;
  if (!prompt || !sessionId) process.exit(0);

  const state = loadState(sessionId);
  const router = new Router();
  const decision = router.route(prompt, state.session);

  state.lastDecision = decision;
  saveState(sessionId, state);

  const conf = decision.confidence.toFixed(2);
  const message = `[router: ${decision.tier} | fase=${decision.signals.phase} | conf=${conf}]`;
  process.stdout.write(JSON.stringify({ systemMessage: message }));
  process.exit(0);
});
