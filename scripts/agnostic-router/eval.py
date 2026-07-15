"""
eval.py — harness de calibração do agnostic-router.

Roda o router sobre um conjunto de casos rotulados (mensagem -> tier esperado)
e reporta acurácia, matriz de confusão e custo relativo estimado. Use para
ajustar os limiares de RouterConfig ao SEU tráfego real.

Formato do dataset (JSON): lista de objetos
    {"msg": "...", "expected": "haiku|sonnet|opus", "session": {opcional}}

Uso:
    python eval.py cases.json
    python eval.py            # usa o conjunto embutido de smoke tests
"""

from __future__ import annotations
import json
import sys
from router import Router, RouterConfig, SessionState, Tier, WorkPhase


# Custo relativo aproximado por tier (normalizado; ajuste ao seu pricing real).
REL_COST = {Tier.HAIKU: 1.0, Tier.SONNET: 5.0, Tier.OPUS: 25.0}


SMOKE_CASES = [
    {"msg": "o que é idempotência?", "expected": "haiku"},
    {"msg": "resume esse changelog em 3 bullets", "expected": "haiku"},
    {"msg": "extrai os emails desse texto", "expected": "haiku"},
    {"msg": "renomeia a variável x pra count", "expected": "sonnet"},
    {"msg": "adiciona um endpoint GET /users no fastapi", "expected": "sonnet"},
    {"msg": "não funciona, retorna 500 quando salva", "expected": "sonnet"},
    {"msg": "planeja a arquitetura de um pipeline de ETL distribuído em produção", "expected": "opus"},
    {"msg": "audita esse código de pagamento buscando falhas de segurança", "expected": "opus"},
    {"msg": "qual a melhor estratégia pra migrar 200GB de Oracle sem downtime?", "expected": "opus"},
    {"msg": "só me diz rápido: qual comando lista os containers docker?", "expected": "haiku"},
    # sessão: debug travado deve escalar
    {"msg": "continua o mesmo erro", "expected": "opus",
     "session": {"consecutive_debug_turns": 2}},
    # sessão: debug travado NÃO pode ser desfeito pela histerese mesmo com last_tier=sonnet
    # e sinal fraco na mensagem (regressão do bug histerese-vs-debug-travado).
    {"msg": "continua o mesmo erro", "expected": "opus",
     "session": {"consecutive_debug_turns": 2, "last_tier": "sonnet"}},
]


def load_cases(path: str | None):
    if not path:
        return SMOKE_CASES
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def make_session(spec: dict | None) -> SessionState:
    if not spec:
        return SessionState()
    s = SessionState()
    for k, v in spec.items():
        if k == "last_tier" and v:
            v = Tier(v)
        if k == "last_phase" and v:
            v = WorkPhase(v)
        setattr(s, k, v)
    return s


def run(path: str | None = None, cfg: RouterConfig | None = None):
    router = Router(cfg)
    cases = load_cases(path)

    hits = 0
    confusion: dict[tuple[str, str], int] = {}
    total_cost = 0.0
    baseline_cost = 0.0  # se tudo rodasse em Opus

    print(f"{'exp':6} {'got':6} {'ok':3}  msg")
    print("-" * 70)
    for c in cases:
        sess = make_session(c.get("session"))
        d = router.route(c["msg"], sess)
        exp = c["expected"]
        got = d.tier.value
        ok = exp == got
        hits += ok
        confusion[(exp, got)] = confusion.get((exp, got), 0) + 1
        total_cost += REL_COST[d.tier]
        baseline_cost += REL_COST[Tier.OPUS]
        mark = "✓" if ok else "✗"
        print(f"{exp:6} {got:6} {mark:3}  {c['msg'][:52]}")

    n = len(cases)
    print("-" * 70)
    print(f"Acurácia: {hits}/{n} = {hits/n:.1%}")
    print(f"Custo relativo: {total_cost:.0f} (vs {baseline_cost:.0f} se tudo fosse Opus "
          f"→ economia {1 - total_cost/baseline_cost:.0%})")

    errs = {k: v for k, v in confusion.items() if k[0] != k[1]}
    if errs:
        print("\nErros (esperado → obtido):")
        for (exp, got), cnt in sorted(errs.items()):
            print(f"  {exp} → {got}: {cnt}")
    return hits / n


if __name__ == "__main__":
    # Console Windows default (cp1252) não engole os marcadores ✓/✗ — força UTF-8.
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass
    path = sys.argv[1] if len(sys.argv) > 1 else None
    run(path)
