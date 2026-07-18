#!/usr/bin/env node
// Stop hook — fecha o ciclo do agnostic-router: le a resposta do assistente e as
// ferramentas usadas neste turno (via transcript_path) e chama update_session,
// espelhando router.py: route() em UserPromptSubmit, update_session() apos a
// resposta (ver user-prompt-router.js). Silencioso — so mantem o estado.

'use strict';

const fs = require('fs');
const os = require('os');
const path = require('path');
const { Router } = require('../agnostic-router/router.js');

const FILE_TOOLS = new Set(['Edit', 'Write', 'NotebookEdit', 'MultiEdit']);

function statePath(sessionId) {
  const dir = path.join(os.tmpdir(), 'agnostic-router-state');
  fs.mkdirSync(dir, { recursive: true });
  return path.join(dir, `${sessionId}.json`);
}

function loadState(sessionId) {
  try {
    return JSON.parse(fs.readFileSync(statePath(sessionId), 'utf8'));
  } catch {
    return null;
  }
}

function saveState(sessionId, state) {
  fs.writeFileSync(statePath(sessionId), JSON.stringify(state));
}

function readTranscriptTail(transcriptPath) {
  let entries;
  try {
    entries = fs.readFileSync(transcriptPath, 'utf8')
      .split('\n')
      .filter(Boolean)
      .map((line) => { try { return JSON.parse(line); } catch { return null; } })
      .filter(Boolean);
  } catch {
    return { assistantText: '', filesTouched: 0 };
  }

  let lastUserIdx = -1;
  for (let i = entries.length - 1; i >= 0; i--) {
    if (entries[i].type === 'user') { lastUserIdx = i; break; }
  }
  const tail = lastUserIdx >= 0 ? entries.slice(lastUserIdx + 1) : entries;

  let assistantText = '';
  const touchedFiles = new Set();

  for (const entry of tail) {
    if (entry.type !== 'assistant') continue;
    const content = entry.message && entry.message.content;
    if (!Array.isArray(content)) continue;
    for (const block of content) {
      if (block.type === 'text' && typeof block.text === 'string') {
        assistantText += `${block.text}\n`;
      } else if (block.type === 'tool_use' && FILE_TOOLS.has(block.name)) {
        const fp = block.input && (block.input.file_path || block.input.path);
        touchedFiles.add(fp || `${block.name}:${block.id}`);
      }
    }
  }

  return { assistantText, filesTouched: touchedFiles.size };
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

  const sessionId = input.session_id;
  const transcriptPath = input.transcript_path;
  if (!sessionId) process.exit(0);

  const state = loadState(sessionId);
  if (!state || !state.lastDecision) process.exit(0);

  const { assistantText, filesTouched } = transcriptPath
    ? readTranscriptTail(transcriptPath)
    : { assistantText: '', filesTouched: 0 };

  const router = new Router();
  router.updateSession(state.session, state.lastDecision, assistantText, filesTouched);
  state.lastDecision = null;
  saveState(sessionId, state);
  process.exit(0);
});
