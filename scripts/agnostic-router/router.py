"""
agnostic-router: roteamento comportamental de modelos para o framework agnostic-core.

Não escolhe modelo por keyword map. Extrai SINAIS da mensagem + estado da sessão,
deriva um PERFIL DE TAREFA (complexidade, fase de trabalho, risco, escopo, latência),
e mapeia o perfil para um tier de modelo (haiku / sonnet / opus).

Projetado para rodar no lado do orquestrador, ANTES da chamada ao endpoint /v1/messages.
Provider-agnostic: emite um TIER lógico; o mapeamento tier->model_id fica em config.

Uso mínimo:
    from router import Router
    r = Router()
    decision = r.route("preciso refatorar o auth pra suportar OAuth2", session=sess)
    model_id = decision.model_id
    # ... client.messages.create(model=model_id, ...)

Python 3.11+. Zero dependências externas.
"""

from __future__ import annotations

import re
import json
from dataclasses import dataclass, field, asdict
from enum import Enum
from typing import Optional, Callable


# ---------------------------------------------------------------------------
# Tiers lógicos (agnósticos de provider)
# ---------------------------------------------------------------------------

class Tier(str, Enum):
    HAIKU = "haiku"    # instant answers, lookups, extração, tarefas rotineiras
    SONNET = "sonnet"  # everyday work: edição, coding cotidiano, análise média
    OPUS = "opus"      # deep reasoning: arquitetura, migração, crítica, agentic longo


# Mapa default tier -> model_id. Sobrescrevível por config do agnostic-core.
DEFAULT_MODEL_MAP: dict[Tier, str] = {
    Tier.HAIKU: "claude-haiku-4-5-20251001",
    Tier.SONNET: "claude-sonnet-5",
    Tier.OPUS: "claude-opus-4-8",
}


# ---------------------------------------------------------------------------
# Fase do trabalho de codar — o eixo comportamental
# ---------------------------------------------------------------------------

class WorkPhase(str, Enum):
    """
    Onde a pessoa está no ciclo de codar. É o sinal comportamental central:
    a MESMA palavra pesa diferente dependendo da fase.
    """
    EXPLORE = "explore"    # entender, pesquisar, tirar dúvida  -> tende a HAIKU/SONNET
    DESIGN = "design"      # planejar, arquitetar, decidir       -> tende a OPUS
    IMPLEMENT = "implement"  # escrever/alterar código concreto  -> tende a SONNET
    DEBUG = "debug"        # investigar falha, achar causa raiz   -> SONNET, sobe p/ OPUS se travado
    REVIEW = "review"      # revisar, criticar, auditar           -> OPUS
    OPERATE = "operate"    # rodar, consultar, extrair, resumir   -> HAIKU


# ---------------------------------------------------------------------------
# Sinais extraídos (o que o router "vê")
# ---------------------------------------------------------------------------

@dataclass
class Signals:
    phase: WorkPhase
    complexity: float          # 0..1  — quão difícil é o raciocínio exigido
    scope: float               # 0..1  — quão grande é o escopo (1 linha vs. sistema)
    risk: float                # 0..1  — custo de errar (prod, migração, dados)
    latency_pref: float        # 0..1  — 1 = quer resposta instantânea
    tokens_in: int             # tamanho aproximado do contexto de entrada
    autonomy: float            # 0..1  — quão agentic/longo (multi-step autônomo)
    phase_scores: dict[str, float] = field(default_factory=dict)
    matched: list[str] = field(default_factory=list)


@dataclass
class SessionState:
    """
    Estado que o agnostic-core mantém entre turnos. Alimenta o roteamento
    comportamental (o que NÃO dá pra ver só olhando a mensagem atual).
    """
    turn: int = 0
    last_tier: Optional[Tier] = None
    consecutive_debug_turns: int = 0   # travado no mesmo bug?
    files_touched: int = 0             # quantos arquivos a sessão já mexeu
    last_phase: Optional[WorkPhase] = None
    error_seen_recently: bool = False  # última resposta continha stacktrace/erro?
    tokens_in_context: int = 0         # tamanho (em chars) do contexto acumulado


@dataclass
class Decision:
    tier: Tier
    model_id: str
    confidence: float
    signals: Signals
    reasons: list[str]
    overridden_by: Optional[str] = None

    def to_json(self) -> str:
        d = asdict(self)
        d["tier"] = self.tier.value
        d["signals"]["phase"] = self.signals.phase.value
        return json.dumps(d, ensure_ascii=False, indent=2)


# ---------------------------------------------------------------------------
# Léxico de FASE (pt-BR + en). Não é keyword->model; é keyword->fase.
# A força é ponderada; a fase vira sinal, não veredito.
# ---------------------------------------------------------------------------

_PHASE_LEXICON: dict[WorkPhase, list[tuple[str, float]]] = {
    WorkPhase.DESIGN: [
        (r"\barquitet\w*", 1.0), (r"\bplanej\w*", 0.9), (r"\bdesenh\w* a solu", 0.9),
        (r"\bcomo (eu )?fa(z|ç)\w*", 0.7), (r"\bmelhor (abordagem|forma|jeito)", 0.8),
        (r"\bestrateg\w*", 0.8), (r"\bdecidir?\b", 0.6), (r"\btrade-?off", 0.9),
        (r"\bdo zero\b", 0.7), (r"\bestrutur\w* o projeto", 0.9),
        (r"\barchitect\w*", 1.0), (r"\bdesign (the|a|an)\b", 0.9), (r"\bplan\b", 0.7),
        (r"\bmigra(r|ç|tion)\w*", 0.9), (r"\bmodelagem\b", 0.8),
    ],
    WorkPhase.IMPLEMENT: [
        (r"\bimplement\w*", 0.9), (r"\bcod(a|e|ificar?)\w*", 0.7), (r"\bescrev\w* (o|a|um|uma)?\s*(código|função|classe|componente)", 0.9),
        (r"\balter\w*", 0.7), (r"\bmud(a|ar|e)\b", 0.6), (r"\btroc\w*", 0.6),
        (r"\batualiz\w*", 0.6), (r"\brefator\w*", 0.8), (r"\badicion\w*", 0.7),
        (r"\brenome\w*", 0.7), (r"\brename\b", 0.7),
        (r"\bcria(r|)\b (o |a |um |uma )?(endpoint|rota|função|classe|componente|script|teste)", 0.9),
        (r"\bwrite (a|the|some)\b", 0.7), (r"\bfix the\b", 0.6), (r"\brefactor\b", 0.8),
    ],
    WorkPhase.DEBUG: [
        (r"\bnão funciona\b", 0.9), (r"\bnao funciona\b", 0.9), (r"\bquebr\w*", 0.8),
        (r"\berro\b", 0.7), (r"\bbug\b", 0.8), (r"\bfalh\w*", 0.7), (r"\btravou?\b", 0.7),
        (r"\bpor ?que (não|nao|isso|ele|ela)\b", 0.7), (r"\bstack ?trace", 0.9),
        (r"\bexception\b", 0.8), (r"\btraceback\b", 0.9), (r"\bdebug\w*", 0.8),
        (r"\bnot working\b", 0.9), (r"\bfails?\b", 0.7), (r"\bcrash\w*", 0.8),
        (r"\bcausa raiz\b", 0.9), (r"\broot cause\b", 0.9),
    ],
    WorkPhase.REVIEW: [
        (r"\brevis\w*", 0.9), (r"\bauditar?\w*", 1.0), (r"\bcritic\w*", 0.9),
        (r"\banalis\w* (o|a|esse|este|o meu|meu)?\s*(código|design|arquitetura)", 0.9),
        (r"\bavali\w*", 0.7), (r"\bfaz sentido\b", 0.6), (r"\bestá (certo|correto)\b", 0.6),
        (r"\breview\b", 0.9), (r"\bcritique\b", 1.0), (r"\bsecurity\b", 0.7),
        (r"\bvulnerabilidad\w*", 0.9), (r"\bboas práticas\b", 0.6),
    ],
    WorkPhase.EXPLORE: [
        (r"\bo que (é|e|significa)\b", 0.8), (r"\bqual a diferença\b", 0.7),
        (r"\bexplic\w*", 0.6), (r"\bcomo funciona\b", 0.6), (r"\bdúvida\b", 0.7),
        (r"\bduvida\b", 0.7), (r"\bopini\w*", 0.6), (r"\bexiste\b", 0.5),
        (r"\bwhat is\b", 0.8), (r"\bhow does\b", 0.6), (r"\bpesquis\w*", 0.6),
        (r"\brecomend\w*", 0.5), (r"\bvale a pena\b", 0.6),
    ],
    WorkPhase.OPERATE: [
        (r"\bresum\w*", 0.8), (r"\bextrai\w*", 0.9), (r"\bextrair\b", 0.9),
        (r"\bliste?\b", 0.6), (r"\bconvert\w*", 0.6), (r"\btraduz\w*", 0.7),
        (r"\bformat\w*", 0.5), (r"\brod(a|e|ar)\b (o|esse|este)", 0.6),
        (r"\bsummari\w*", 0.8), (r"\bextract\b", 0.9), (r"\blist\b", 0.6),
        (r"\bqual (o |a )?(valor|status|nome|id)\b", 0.7),
    ],
}

# Marcadores de COMPLEXIDADE (independem de fase)
_COMPLEXITY_MARKERS: list[tuple[str, float]] = [
    (r"\bsistema\b", 0.25), (r"\bmúltipl\w*", 0.2), (r"\bmultipl\w*", 0.2),
    (r"\bdistribuíd\w*", 0.3), (r"\bconcorrên\w*", 0.3), (r"\bescala\w*", 0.25),
    (r"\bperformance\b", 0.2), (r"\botimiz\w*", 0.25), (r"\bmigra\w*", 0.3),
    (r"\bintegra\w*", 0.2), (r"\btransaçã\w*", 0.25), (r"\bconsistência\b", 0.3),
    (r"\brace condition\b", 0.35), (r"\bdeadlock\b", 0.35), (r"\btrigger\b", 0.2),
    (r"\boracle\b", 0.2), (r"\bkubernetes\b", 0.25), (r"\bagente?s?\b", 0.2),
    (r"\bpassos?\b.*\bpassos?\b", 0.2),  # múltiplos passos citados
]

# Marcadores de ESCOPO grande
_SCOPE_MARKERS: list[tuple[str, float]] = [
    (r"\btod(o|os|a|as) (o|os|a|as)?\b", 0.25), (r"\bo projeto (inteiro|todo)\b", 0.4),
    (r"\bvárias?\b", 0.2), (r"\bvarios?\b", 0.2), (r"\bem (todo|toda)\b", 0.25),
    (r"\brefator\w* geral", 0.4), (r"\bcodebase\b", 0.35), (r"\bend-?to-?end\b", 0.3),
    (r"\bfull\b", 0.2), (r"\bcompleto\b", 0.2),
]

# Marcadores de RISCO
_RISK_MARKERS: list[tuple[str, float]] = [
    (r"\bprod(ução|ucao|)\b", 0.4), (r"\bproduction\b", 0.4), (r"\bdados? (reais?|de cliente)", 0.4),
    (r"\bmigra\w*", 0.3), (r"\bdelet\w*", 0.3), (r"\bdrop\b", 0.4), (r"\btruncate\b", 0.4),
    (r"\bfinanceir\w*", 0.35), (r"\bfiscal\b", 0.35), (r"\bcontábil\b", 0.3),
    (r"\birreversí\w*", 0.5), (r"\bsem backup\b", 0.5), (r"\bLGPD\b", 0.3),
    (r"\bpagamento\b", 0.35), (r"\bsegurança\b", 0.3),
]

# Marcadores de PREFERÊNCIA POR LATÊNCIA (quer rápido/barato)
_LATENCY_MARKERS: list[tuple[str, float]] = [
    (r"\brápid\w*", 0.4), (r"\brapid\w*", 0.4), (r"\bquick\w*", 0.4),
    (r"\bsó (me )?diz\w*", 0.4), (r"\bapenas\b", 0.2), (r"\bsimples\b", 0.3),
    (r"\bum (a )?linha\b", 0.4), (r"\bfast\b", 0.4), (r"\bjust\b", 0.2),
]

# Marcadores de AUTONOMIA / agentic longo
_AUTONOMY_MARKERS: list[tuple[str, float]] = [
    (r"\bautônom\w*", 0.4), (r"\bautonom\w*", 0.4), (r"\bsozinho\b", 0.3),
    (r"\bpor (várias|varias|muitas) (horas|etapas)\b", 0.4), (r"\bmulti-?agente?\b", 0.4),
    (r"\bsub-?agente?\b", 0.3), (r"\borquestr\w*", 0.3), (r"\bpipeline\b", 0.2),
    (r"\bagentic\b", 0.4), (r"\bloop\b", 0.2), (r"\bfaça tudo\b", 0.4),
]


def _score(text: str, markers: list[tuple[str, float]], matched: list[str]) -> float:
    total = 0.0
    for pat, w in markers:
        if re.search(pat, text, flags=re.IGNORECASE):
            total += w
            matched.append(pat)
    return min(total, 1.0)


# ---------------------------------------------------------------------------
# Detecção de código embutido na mensagem
# ---------------------------------------------------------------------------

_CODE_FENCE = re.compile(r"```")
_STACKTRACE = re.compile(r"(Traceback|at \w+\.\w+\(|Exception in thread|ORA-\d{5}|\bError:)", re.I)


def _looks_like_code(text: str) -> bool:
    return bool(_CODE_FENCE.search(text)) or text.count(";") > 5 or text.count("{") > 3


# ---------------------------------------------------------------------------
# Extração de sinais
# ---------------------------------------------------------------------------

def extract_signals(message: str, session: Optional[SessionState] = None) -> Signals:
    session = session or SessionState()
    text = message.strip()
    matched: list[str] = []

    # 1) Fase: soma ponderada por fase, escolhe a maior
    #
    # A ordem de inserção aqui é o critério de desempate: `max()` devolve o
    # primeiro máximo que encontrar. Ela vem de `_PHASE_LEXICON` (design,
    # implement, debug, review, explore, operate), NÃO da ordem de declaração
    # de `WorkPhase`. O `router.js` precisa percorrer a mesma sequência —
    # `scripts/agnostic-router/parity.sh` cobre isso.
    phase_scores: dict[WorkPhase, float] = {}
    for phase, markers in _PHASE_LEXICON.items():
        phase_scores[phase] = _score(text, markers, matched)

    # Ajustes comportamentais vindos da SESSÃO -----------------------------
    # Stacktrace na mensagem OU erro visto no turno anterior -> puxa p/ DEBUG
    if _STACKTRACE.search(text) or session.error_seen_recently:
        phase_scores[WorkPhase.DEBUG] = phase_scores.get(WorkPhase.DEBUG, 0) + 0.5

    # Continuidade: se estava debugando e a msg é curta ("e agora?"), mantém fase
    if session.last_phase and phase_scores.get(max(phase_scores, key=phase_scores.get), 0) < 0.3:
        phase_scores[session.last_phase] = phase_scores.get(session.last_phase, 0) + 0.35

    phase = max(phase_scores, key=phase_scores.get)
    if phase_scores[phase] == 0:
        # Sem sinal claro: default depende de haver código (implementar) ou não (explorar)
        phase = WorkPhase.IMPLEMENT if _looks_like_code(text) else WorkPhase.EXPLORE

    # Contexto acumulado (chars -> tokens aproximados). Alimenta complexidade.
    tokens_in = max(len(text) // 4, session.tokens_in_context // 4)

    # 2) Complexidade
    complexity = _score(text, _COMPLEXITY_MARKERS, matched)
    if _looks_like_code(text):
        complexity += 0.15
    if len(text) > 800:
        complexity += 0.15
    if tokens_in >= 4000:
        # contexto acumulado grande -> raciocínio mais caro de sustentar
        complexity += 0.1
    complexity = min(complexity, 1.0)

    # 3) Escopo
    scope = _score(text, _SCOPE_MARKERS, matched)
    if session.files_touched >= 5:
        scope = min(scope + 0.2, 1.0)

    # 4) Risco
    risk = _score(text, _RISK_MARKERS, matched)

    # 5) Latência preferida
    latency_pref = _score(text, _LATENCY_MARKERS, matched)

    # 6) Autonomia
    autonomy = _score(text, _AUTONOMY_MARKERS, matched)

    return Signals(
        phase=phase,
        complexity=complexity,
        scope=scope,
        risk=risk,
        latency_pref=latency_pref,
        tokens_in=tokens_in,
        autonomy=autonomy,
        phase_scores={p.value: round(s, 3) for p, s in phase_scores.items()},
        matched=matched,
    )


# ---------------------------------------------------------------------------
# Perfil de fase -> tier base (o "comportamento conforme o momento de codar")
# ---------------------------------------------------------------------------

_PHASE_BASE_TIER: dict[WorkPhase, Tier] = {
    WorkPhase.EXPLORE: Tier.HAIKU,
    WorkPhase.OPERATE: Tier.HAIKU,
    WorkPhase.IMPLEMENT: Tier.SONNET,
    WorkPhase.DEBUG: Tier.SONNET,
    WorkPhase.DESIGN: Tier.OPUS,
    WorkPhase.REVIEW: Tier.OPUS,
}

_TIER_ORDER = [Tier.HAIKU, Tier.SONNET, Tier.OPUS]


def _bump(tier: Tier, steps: int) -> Tier:
    i = _TIER_ORDER.index(tier)
    i = max(0, min(len(_TIER_ORDER) - 1, i + steps))
    return _TIER_ORDER[i]


# ---------------------------------------------------------------------------
# Router
# ---------------------------------------------------------------------------

@dataclass
class RouterConfig:
    model_map: dict[Tier, str] = field(default_factory=lambda: dict(DEFAULT_MODEL_MAP))
    # Limiares para "escalar" (subir tier) e "rebaixar" (descer tier)
    escalate_at: float = 0.55     # complexidade/risco combinados que forçam subir
    downgrade_latency_at: float = 0.5  # preferência de latência que força descer
    # Trava um piso de tier para tarefas de risco alto (nunca abaixo disso)
    risk_floor_at: float = 0.4
    # Nº de turnos travado em DEBUG antes de escalar p/ OPUS
    stuck_debug_turns: int = 2
    # Permite ao chamador vetar/forçar
    hard_override: Optional[Callable[[str, Signals], Optional[Tier]]] = None


class Router:
    def __init__(self, config: Optional[RouterConfig] = None):
        self.cfg = config or RouterConfig()

    def route(self, message: str, session: Optional[SessionState] = None) -> Decision:
        session = session or SessionState()
        sig = extract_signals(message, session)
        reasons: list[str] = []

        # Override explícito do chamador (ex.: usuário fixou modelo)
        if self.cfg.hard_override:
            forced = self.cfg.hard_override(message, sig)
            if forced:
                return self._decide(forced, sig, ["hard_override do chamador"],
                                    confidence=1.0, overridden_by="hard_override")

        # 1) Tier base pela FASE de trabalho
        tier = _PHASE_BASE_TIER[sig.phase]
        reasons.append(f"fase={sig.phase.value} -> base={tier.value}")

        # 2) Escalada por complexidade + escopo + autonomia
        pressure = sig.complexity * 0.5 + sig.scope * 0.3 + sig.autonomy * 0.2
        if pressure >= self.cfg.escalate_at:
            tier = _bump(tier, +1)
            reasons.append(f"pressão={pressure:.2f}>= {self.cfg.escalate_at} -> +1 tier")
        if pressure >= self.cfg.escalate_at + 0.25:
            tier = _bump(tier, +1)
            reasons.append(f"pressão muito alta ({pressure:.2f}) -> +1 tier extra")

        # 3) DEBUG travado: sobe pra OPUS após N turnos no mesmo bug.
        #    É uma escalada comportamental FORÇADA — a histerese (passo 6) não pode desfazê-la.
        forced_escalation = False
        if sig.phase == WorkPhase.DEBUG and session.consecutive_debug_turns >= self.cfg.stuck_debug_turns:
            tier = Tier.OPUS
            forced_escalation = True
            reasons.append(f"debug travado há {session.consecutive_debug_turns} turnos -> OPUS")

        # 4) Piso de risco: risco alto nunca roda em HAIKU
        if sig.risk >= self.cfg.risk_floor_at and tier == Tier.HAIKU:
            tier = Tier.SONNET
            reasons.append(f"risco={sig.risk:.2f} -> piso SONNET")
        if sig.risk >= 0.7:
            tier = _bump(tier, +1)
            forced_escalation = True
            reasons.append(f"risco crítico ({sig.risk:.2f}) -> +1 tier")

        # 5) Rebaixamento por latência: só quando risco e complexidade são baixos
        if (sig.latency_pref >= self.cfg.downgrade_latency_at
                and sig.risk < self.cfg.risk_floor_at
                and sig.complexity < 0.4
                and sig.phase not in (WorkPhase.DESIGN, WorkPhase.REVIEW)):
            tier = _bump(tier, -1)
            reasons.append(f"latência preferida={sig.latency_pref:.2f} + baixo risco -> -1 tier")

        # 6) Histerese: evita zigue-zague de modelo a cada turno.
        #    Se mudou 1 tier só e o sinal é fraco, mantém o tier anterior.
        #    NUNCA aplica sobre escalada forçada (debug travado / risco crítico) —
        #    senão o sinal comportamental que motivou a subida seria silenciosamente revertido.
        if session.last_tier and session.last_tier != tier and not forced_escalation:
            dist = abs(_TIER_ORDER.index(tier) - _TIER_ORDER.index(session.last_tier))
            if dist == 1 and pressure < 0.35 and sig.risk < 0.3:
                reasons.append(f"histerese: sinal fraco, mantém {session.last_tier.value}")
                tier = session.last_tier

        confidence = self._confidence(sig, tier)
        return self._decide(tier, sig, reasons, confidence)

    def _decide(self, tier, sig, reasons, confidence, overridden_by=None) -> Decision:
        return Decision(
            tier=tier,
            model_id=self.cfg.model_map[tier],
            confidence=round(confidence, 3),
            signals=sig,
            reasons=reasons,
            overridden_by=overridden_by,
        )

    @staticmethod
    def _confidence(sig: Signals, tier: Tier) -> float:
        # Confiança alta quando a fase venceu por margem clara
        scores = sorted(sig.phase_scores.values(), reverse=True)
        top = scores[0] if scores else 0.0
        second = scores[1] if len(scores) > 1 else 0.0
        margin = top - second
        base = 0.5 + min(margin, 0.5)
        return max(0.3, min(base, 0.99))

    def update_session(self, session: SessionState, decision: Decision,
                       assistant_reply: str = "",
                       files_touched_delta: int = 0,
                       tokens_in_context: Optional[int] = None) -> SessionState:
        """
        Chamar depois de cada turno para manter o estado comportamental.

        - `files_touched_delta`: nº de arquivos que ESTE turno tocou (o orquestrador
          sabe disso; o router não). Acumula em `session.files_touched` -> alimenta o
          sinal de escopo nos próximos turnos.
        - `tokens_in_context`: se o orquestrador tem a contagem real de contexto, passe-a
          (sobrescreve). Senão, acumulamos uma estimativa em chars a partir da resposta.
        """
        session.turn += 1
        session.last_tier = decision.tier
        session.last_phase = decision.signals.phase
        if decision.signals.phase == WorkPhase.DEBUG:
            session.consecutive_debug_turns += 1
        else:
            session.consecutive_debug_turns = 0
        session.error_seen_recently = bool(_STACKTRACE.search(assistant_reply))
        session.files_touched += max(0, files_touched_delta)
        if tokens_in_context is not None:
            session.tokens_in_context = tokens_in_context
        else:
            session.tokens_in_context += len(assistant_reply)
        return session


# ---------------------------------------------------------------------------
# CLI de teste rápido
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import sys
    # Console Windows default (cp1252) não engole acentos/aspas unicode — força UTF-8.
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    r = Router()
    sess = SessionState()
    if len(sys.argv) > 1:
        msg = " ".join(sys.argv[1:])
        d = r.route(msg, sess)
        print(d.to_json())
    else:
        # Demo com fases variadas
        demos = [
            "o que é um race condition?",
            "planeja a arquitetura de um sistema de filas distribuído em prod",
            "troca o nome dessa variável pra userId",
            "não funciona, dá ORA-00001 quando insere",
            "audita esse código de pagamento buscando vulnerabilidades de segurança",
            "resume esse log pra mim em 3 linhas",
            "refatora todo o módulo de auth pra OAuth2 no projeto inteiro",
        ]
        for m in demos:
            d = r.route(m, SessionState())
            print(f"[{d.tier.value.upper():6}] conf={d.confidence:.2f}  «{m[:55]}»")
            print(f"         fase={d.signals.phase.value} cplx={d.signals.complexity:.2f} "
                  f"risco={d.signals.risk:.2f} lat={d.signals.latency_pref:.2f}")
