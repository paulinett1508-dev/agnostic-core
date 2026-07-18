'use strict';
/*
 * agnostic-router (porte Node.js) — roteamento comportamental de modelos.
 *
 * Porte 1:1 de scripts/agnostic-router/router.py para viabilizar um hook
 * técnico (UserPromptSubmit/Stop) em máquinas sem python3 instalado.
 * Mesma lógica, mesmos limiares, mesmo léxico — ver router.py para o
 * racional comentado de cada seção; aqui só a estrutura de dados muda
 * (dataclass -> objeto plano, Enum -> string).
 *
 * Zero dependencias externas.
 */

const Tier = { HAIKU: 'haiku', SONNET: 'sonnet', OPUS: 'opus' };
const TIER_ORDER = [Tier.HAIKU, Tier.SONNET, Tier.OPUS];

const DEFAULT_MODEL_MAP = {
  [Tier.HAIKU]: 'claude-haiku-4-5-20251001',
  [Tier.SONNET]: 'claude-sonnet-5',
  [Tier.OPUS]: 'claude-opus-4-8',
};

const WorkPhase = {
  EXPLORE: 'explore',
  DESIGN: 'design',
  IMPLEMENT: 'implement',
  DEBUG: 'debug',
  REVIEW: 'review',
  OPERATE: 'operate',
};

const PHASE_LEXICON = {
  [WorkPhase.DESIGN]: [
    [/\barquitet\w*/i, 1.0], [/\bplanej\w*/i, 0.9], [/\bdesenh\w* a solu/i, 0.9],
    [/\bcomo (eu )?fa(z|ç)\w*/i, 0.7], [/\bmelhor (abordagem|forma|jeito)/i, 0.8],
    [/\bestrateg\w*/i, 0.8], [/\bdecidir?\b/i, 0.6], [/\btrade-?off/i, 0.9],
    [/\bdo zero\b/i, 0.7], [/\bestrutur\w* o projeto/i, 0.9],
    [/\barchitect\w*/i, 1.0], [/\bdesign (the|a|an)\b/i, 0.9], [/\bplan\b/i, 0.7],
    [/\bmigra(r|ç|tion)\w*/i, 0.9], [/\bmodelagem\b/i, 0.8],
  ],
  [WorkPhase.IMPLEMENT]: [
    [/\bimplement\w*/i, 0.9], [/\bcod(a|e|ificar?)\w*/i, 0.7],
    [/\bescrev\w* (o|a|um|uma)?\s*(código|função|classe|componente)/i, 0.9],
    [/\balter\w*/i, 0.7], [/\bmud(a|ar|e)\b/i, 0.6], [/\btroc\w*/i, 0.6],
    [/\batualiz\w*/i, 0.6], [/\brefator\w*/i, 0.8], [/\badicion\w*/i, 0.7],
    [/\brenome\w*/i, 0.7], [/\brename\b/i, 0.7],
    [/\bcria(r|)\b (o |a |um |uma )?(endpoint|rota|função|classe|componente|script|teste)/i, 0.9],
    [/\bwrite (a|the|some)\b/i, 0.7], [/\bfix the\b/i, 0.6], [/\brefactor\b/i, 0.8],
  ],
  [WorkPhase.DEBUG]: [
    [/\bnão funciona\b/i, 0.9], [/\bnao funciona\b/i, 0.9], [/\bquebr\w*/i, 0.8],
    [/\berro\b/i, 0.7], [/\bbug\b/i, 0.8], [/\bfalh\w*/i, 0.7], [/\btravou?\b/i, 0.7],
    [/\bpor ?que (não|nao|isso|ele|ela)\b/i, 0.7], [/\bstack ?trace/i, 0.9],
    [/\bexception\b/i, 0.8], [/\btraceback\b/i, 0.9], [/\bdebug\w*/i, 0.8],
    [/\bnot working\b/i, 0.9], [/\bfails?\b/i, 0.7], [/\bcrash\w*/i, 0.8],
    [/\bcausa raiz\b/i, 0.9], [/\broot cause\b/i, 0.9],
  ],
  [WorkPhase.REVIEW]: [
    [/\brevis\w*/i, 0.9], [/\bauditar?\w*/i, 1.0], [/\bcritic\w*/i, 0.9],
    [/\banalis\w* (o|a|esse|este|o meu|meu)?\s*(código|design|arquitetura)/i, 0.9],
    [/\bavali\w*/i, 0.7], [/\bfaz sentido\b/i, 0.6], [/\bestá (certo|correto)\b/i, 0.6],
    [/\breview\b/i, 0.9], [/\bcritique\b/i, 1.0], [/\bsecurity\b/i, 0.7],
    [/\bvulnerabilidad\w*/i, 0.9], [/\bboas práticas\b/i, 0.6],
  ],
  [WorkPhase.EXPLORE]: [
    [/\bo que (é|e|significa)\b/i, 0.8], [/\bqual a diferença\b/i, 0.7],
    [/\bexplic\w*/i, 0.6], [/\bcomo funciona\b/i, 0.6], [/\bdúvida\b/i, 0.7],
    [/\bduvida\b/i, 0.7], [/\bopini\w*/i, 0.6], [/\bexiste\b/i, 0.5],
    [/\bwhat is\b/i, 0.8], [/\bhow does\b/i, 0.6], [/\bpesquis\w*/i, 0.6],
    [/\brecomend\w*/i, 0.5], [/\bvale a pena\b/i, 0.6],
  ],
  [WorkPhase.OPERATE]: [
    [/\bresum\w*/i, 0.8], [/\bextrai\w*/i, 0.9], [/\bextrair\b/i, 0.9],
    [/\bliste?\b/i, 0.6], [/\bconvert\w*/i, 0.6], [/\btraduz\w*/i, 0.7],
    [/\bformat\w*/i, 0.5], [/\brod(a|e|ar)\b (o|esse|este)/i, 0.6],
    [/\bsummari\w*/i, 0.8], [/\bextract\b/i, 0.9], [/\blist\b/i, 0.6],
    [/\bqual (o |a )?(valor|status|nome|id)\b/i, 0.7],
  ],
};

const COMPLEXITY_MARKERS = [
  [/\bsistema\b/i, 0.25], [/\bmúltipl\w*/i, 0.2], [/\bmultipl\w*/i, 0.2],
  [/\bdistribuíd\w*/i, 0.3], [/\bconcorrên\w*/i, 0.3], [/\bescala\w*/i, 0.25],
  [/\bperformance\b/i, 0.2], [/\botimiz\w*/i, 0.25], [/\bmigra\w*/i, 0.3],
  [/\bintegra\w*/i, 0.2], [/\btransaçã\w*/i, 0.25], [/\bconsistência\b/i, 0.3],
  [/\brace condition\b/i, 0.35], [/\bdeadlock\b/i, 0.35], [/\btrigger\b/i, 0.2],
  [/\boracle\b/i, 0.2], [/\bkubernetes\b/i, 0.25], [/\bagente?s?\b/i, 0.2],
  [/\bpassos?\b.*\bpassos?\b/i, 0.2],
];

const SCOPE_MARKERS = [
  [/\btod(o|os|a|as) (o|os|a|as)?\b/i, 0.25], [/\bo projeto (inteiro|todo)\b/i, 0.4],
  [/\bvárias?\b/i, 0.2], [/\bvarios?\b/i, 0.2], [/\bem (todo|toda)\b/i, 0.25],
  [/\brefator\w* geral/i, 0.4], [/\bcodebase\b/i, 0.35], [/\bend-?to-?end\b/i, 0.3],
  [/\bfull\b/i, 0.2], [/\bcompleto\b/i, 0.2],
];

const RISK_MARKERS = [
  [/\bprod(ução|ucao|)\b/i, 0.4], [/\bproduction\b/i, 0.4], [/\bdados? (reais?|de cliente)/i, 0.4],
  [/\bmigra\w*/i, 0.3], [/\bdelet\w*/i, 0.3], [/\bdrop\b/i, 0.4], [/\btruncate\b/i, 0.4],
  [/\bfinanceir\w*/i, 0.35], [/\bfiscal\b/i, 0.35], [/\bcontábil\b/i, 0.3],
  [/\birreversí\w*/i, 0.5], [/\bsem backup\b/i, 0.5], [/\bLGPD\b/i, 0.3],
  [/\bpagamento\b/i, 0.35], [/\bsegurança\b/i, 0.3],
];

const LATENCY_MARKERS = [
  [/\brápid\w*/i, 0.4], [/\brapid\w*/i, 0.4], [/\bquick\w*/i, 0.4],
  [/\bsó (me )?diz\w*/i, 0.4], [/\bapenas\b/i, 0.2], [/\bsimples\b/i, 0.3],
  [/\bum (a )?linha\b/i, 0.4], [/\bfast\b/i, 0.4], [/\bjust\b/i, 0.2],
];

const AUTONOMY_MARKERS = [
  [/\bautônom\w*/i, 0.4], [/\bautonom\w*/i, 0.4], [/\bsozinho\b/i, 0.3],
  [/\bpor (várias|varias|muitas) (horas|etapas)\b/i, 0.4], [/\bmulti-?agente?\b/i, 0.4],
  [/\bsub-?agente?\b/i, 0.3], [/\borquestr\w*/i, 0.3], [/\bpipeline\b/i, 0.2],
  [/\bagentic\b/i, 0.4], [/\bloop\b/i, 0.2], [/\bfaça tudo\b/i, 0.4],
];

const STACKTRACE = /(Traceback|at \w+\.\w+\(|Exception in thread|ORA-\d{5}|\bError:)/i;
const CODE_FENCE = /```/;

function score(text, markers, matched) {
  let total = 0;
  for (const [pat, w] of markers) {
    if (pat.test(text)) {
      total += w;
      matched.push(pat.source);
    }
  }
  return Math.min(total, 1.0);
}

function looksLikeCode(text) {
  return CODE_FENCE.test(text) || (text.match(/;/g) || []).length > 5 || (text.match(/\{/g) || []).length > 3;
}

function newSessionState() {
  return {
    turn: 0,
    last_tier: null,
    consecutive_debug_turns: 0,
    files_touched: 0,
    last_phase: null,
    error_seen_recently: false,
    tokens_in_context: 0,
  };
}

function extractSignals(message, session) {
  session = session || newSessionState();
  const text = String(message || '').trim();
  const matched = [];

  const phaseScores = {};
  for (const phase of Object.values(WorkPhase)) {
    phaseScores[phase] = score(text, PHASE_LEXICON[phase], matched);
  }

  if (STACKTRACE.test(text) || session.error_seen_recently) {
    phaseScores[WorkPhase.DEBUG] = (phaseScores[WorkPhase.DEBUG] || 0) + 0.5;
  }

  const topBeforeContinuity = Object.keys(phaseScores).reduce((a, b) => (phaseScores[a] >= phaseScores[b] ? a : b));
  if (session.last_phase && phaseScores[topBeforeContinuity] < 0.3) {
    phaseScores[session.last_phase] = (phaseScores[session.last_phase] || 0) + 0.35;
  }

  let phase = Object.keys(phaseScores).reduce((a, b) => (phaseScores[a] >= phaseScores[b] ? a : b));
  if (phaseScores[phase] === 0) {
    phase = looksLikeCode(text) ? WorkPhase.IMPLEMENT : WorkPhase.EXPLORE;
  }

  const tokensIn = Math.max(Math.floor(text.length / 4), Math.floor(session.tokens_in_context / 4));

  let complexity = score(text, COMPLEXITY_MARKERS, matched);
  if (looksLikeCode(text)) complexity += 0.15;
  if (text.length > 800) complexity += 0.15;
  if (tokensIn >= 4000) complexity += 0.1;
  complexity = Math.min(complexity, 1.0);

  let scope = score(text, SCOPE_MARKERS, matched);
  if (session.files_touched >= 5) scope = Math.min(scope + 0.2, 1.0);

  const risk = score(text, RISK_MARKERS, matched);
  const latencyPref = score(text, LATENCY_MARKERS, matched);
  const autonomy = score(text, AUTONOMY_MARKERS, matched);

  const roundedPhaseScores = {};
  for (const [p, s] of Object.entries(phaseScores)) roundedPhaseScores[p] = Math.round(s * 1000) / 1000;

  return {
    phase, complexity, scope, risk, latency_pref: latencyPref,
    tokens_in: tokensIn, autonomy, phase_scores: roundedPhaseScores, matched,
  };
}

const PHASE_BASE_TIER = {
  [WorkPhase.EXPLORE]: Tier.HAIKU,
  [WorkPhase.OPERATE]: Tier.HAIKU,
  [WorkPhase.IMPLEMENT]: Tier.SONNET,
  [WorkPhase.DEBUG]: Tier.SONNET,
  [WorkPhase.DESIGN]: Tier.OPUS,
  [WorkPhase.REVIEW]: Tier.OPUS,
};

function bump(tier, steps) {
  let i = TIER_ORDER.indexOf(tier);
  i = Math.max(0, Math.min(TIER_ORDER.length - 1, i + steps));
  return TIER_ORDER[i];
}

class Router {
  constructor(config) {
    this.cfg = Object.assign({
      model_map: { ...DEFAULT_MODEL_MAP },
      escalate_at: 0.55,
      downgrade_latency_at: 0.5,
      risk_floor_at: 0.4,
      stuck_debug_turns: 2,
      hard_override: null,
    }, config || {});
  }

  route(message, session) {
    session = session || newSessionState();
    const sig = extractSignals(message, session);
    const reasons = [];

    if (this.cfg.hard_override) {
      const forced = this.cfg.hard_override(message, sig);
      if (forced) {
        return this._decide(forced, sig, ['hard_override do chamador'], 1.0, 'hard_override');
      }
    }

    let tier = PHASE_BASE_TIER[sig.phase];
    reasons.push(`fase=${sig.phase} -> base=${tier}`);

    const pressure = sig.complexity * 0.5 + sig.scope * 0.3 + sig.autonomy * 0.2;
    if (pressure >= this.cfg.escalate_at) {
      tier = bump(tier, 1);
      reasons.push(`pressão=${pressure.toFixed(2)}>= ${this.cfg.escalate_at} -> +1 tier`);
    }
    if (pressure >= this.cfg.escalate_at + 0.25) {
      tier = bump(tier, 1);
      reasons.push(`pressão muito alta (${pressure.toFixed(2)}) -> +1 tier extra`);
    }

    let forcedEscalation = false;
    if (sig.phase === WorkPhase.DEBUG && session.consecutive_debug_turns >= this.cfg.stuck_debug_turns) {
      tier = Tier.OPUS;
      forcedEscalation = true;
      reasons.push(`debug travado há ${session.consecutive_debug_turns} turnos -> OPUS`);
    }

    if (sig.risk >= this.cfg.risk_floor_at && tier === Tier.HAIKU) {
      tier = Tier.SONNET;
      reasons.push(`risco=${sig.risk.toFixed(2)} -> piso SONNET`);
    }
    if (sig.risk >= 0.7) {
      tier = bump(tier, 1);
      forcedEscalation = true;
      reasons.push(`risco crítico (${sig.risk.toFixed(2)}) -> +1 tier`);
    }

    if (sig.latency_pref >= this.cfg.downgrade_latency_at
        && sig.risk < this.cfg.risk_floor_at
        && sig.complexity < 0.4
        && sig.phase !== WorkPhase.DESIGN && sig.phase !== WorkPhase.REVIEW) {
      tier = bump(tier, -1);
      reasons.push(`latência preferida=${sig.latency_pref.toFixed(2)} + baixo risco -> -1 tier`);
    }

    if (session.last_tier && session.last_tier !== tier && !forcedEscalation) {
      const dist = Math.abs(TIER_ORDER.indexOf(tier) - TIER_ORDER.indexOf(session.last_tier));
      if (dist === 1 && pressure < 0.35 && sig.risk < 0.3) {
        reasons.push(`histerese: sinal fraco, mantém ${session.last_tier}`);
        tier = session.last_tier;
      }
    }

    const confidence = this._confidence(sig);
    return this._decide(tier, sig, reasons, confidence);
  }

  _decide(tier, sig, reasons, confidence, overriddenBy) {
    return {
      tier,
      model_id: this.cfg.model_map[tier],
      confidence: Math.round(confidence * 1000) / 1000,
      signals: sig,
      reasons,
      overridden_by: overriddenBy || null,
    };
  }

  _confidence(sig) {
    const scores = Object.values(sig.phase_scores).sort((a, b) => b - a);
    const top = scores[0] || 0;
    const second = scores[1] || 0;
    const margin = top - second;
    const base = 0.5 + Math.min(margin, 0.5);
    return Math.max(0.3, Math.min(base, 0.99));
  }

  updateSession(session, decision, assistantReply, filesTouchedDelta, tokensInContext) {
    assistantReply = assistantReply || '';
    filesTouchedDelta = filesTouchedDelta || 0;
    session.turn += 1;
    session.last_tier = decision.tier;
    session.last_phase = decision.signals.phase;
    if (decision.signals.phase === WorkPhase.DEBUG) {
      session.consecutive_debug_turns += 1;
    } else {
      session.consecutive_debug_turns = 0;
    }
    session.error_seen_recently = STACKTRACE.test(assistantReply);
    session.files_touched += Math.max(0, filesTouchedDelta);
    if (tokensInContext !== undefined && tokensInContext !== null) {
      session.tokens_in_context = tokensInContext;
    } else {
      session.tokens_in_context += assistantReply.length;
    }
    return session;
  }
}

module.exports = {
  Tier, WorkPhase, DEFAULT_MODEL_MAP, Router, extractSignals, newSessionState,
};
