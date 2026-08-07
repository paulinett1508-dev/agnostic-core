#!/usr/bin/env python3
"""
embassy_sentinel.py — Sentinel da caixa postal entre repositórios

Combina PULL de issues via GitHub API com Embassy Dispatch (PUSH events).
Roda em cron num host próprio. Gera digest semanal como issue no repo agregador
e fecha as embassy já processadas.

Cron sugerido: 0 8 * * 1  (toda segunda, 08h)

Template: ajuste `CONSTELLATION_REPO` para o seu repo agregador — aquele que
recebe as issues de todos os outros — ou exporte `EMBASSY_REPO` no ambiente.
"""

import os
import json
import subprocess
from datetime import datetime, timezone
from collections import defaultdict

# Repo agregador que recebe as issues de embassy. Sem `EMBASSY_REPO` no
# ambiente, o placeholder abaixo falha alto na primeira chamada ao `gh` — o que
# é melhor que rodar apontando para o repo de outra pessoa.
CONSTELLATION_REPO = os.environ.get("EMBASSY_REPO", "SUA_ORG/SEU_REPO_AGREGADOR")
GH_TOKEN = os.environ["EMBASSY_PAT"]


def gh(args: list[str]) -> list | dict:
    result = subprocess.run(
        ["gh"] + args + ["--json", "number,title,body,createdAt,labels,url"],
        capture_output=True, text=True,
        env={**os.environ, "GH_TOKEN": GH_TOKEN}
    )
    return json.loads(result.stdout) if result.stdout.strip() else []


def close_issue(number: int):
    subprocess.run(
        ["gh", "issue", "close", str(number),
         "--repo", CONSTELLATION_REPO,
         "--comment", "Processado pelo Embassy Sentinel e incluído no digest semanal."],
        env={**os.environ, "GH_TOKEN": GH_TOKEN}
    )


def fetch_embassy_issues() -> list[dict]:
    return gh([
        "issue", "list",
        "--repo", CONSTELLATION_REPO,
        "--label", "embassy",
        "--state", "open",
        "--limit", "100",
    ])


def fetch_sheldon_manifest() -> list[dict]:
    """Lê o sheldon.json gerado pelo gen-issues-manifest do sub-plano D."""
    manifest_path = os.path.expanduser("~/embassy/sheldon.json")
    if not os.path.exists(manifest_path):
        return []
    with open(manifest_path) as f:
        return json.load(f)


def group_by_corpo(issues: list[dict]) -> dict[str, list]:
    groups = defaultdict(list)
    for issue in issues:
        title = issue.get("title", "")
        # Formato: [embassy] NomeCorpo — resumo
        if title.startswith("[embassy]"):
            parts = title[len("[embassy]"):].strip().split("—", 1)
            corpo = parts[0].strip() if parts else "desconhecido"
        else:
            corpo = "desconhecido"
        groups[corpo].append(issue)
    return dict(groups)


def build_digest_body(embassy_issues: list[dict], sheldon_manifest: list[dict]) -> str:
    week = datetime.now(timezone.utc).strftime("%Y-W%W")
    lines = [f"## Embassy Digest — {week}\n"]

    # PUSH events (embassy issues)
    if embassy_issues:
        lines.append("### Eventos ativos (PUSH)")
        groups = group_by_corpo(embassy_issues)
        for corpo, events in sorted(groups.items()):
            lines.append(f"\n**{corpo}** ({len(events)} evento{'s' if len(events)>1 else ''})")
            for e in events:
                title = e["title"].split("—", 1)[-1].strip() if "—" in e["title"] else e["title"]
                date = e["createdAt"][:10]
                lines.append(f"- `{date}` {title} ([#{ e['number']}]({e['url']}))")

    # Sub-plano D: issues abertas por condado (PULL)
    if sheldon_manifest:
        lines.append("\n### Backlog por condado (PULL — sub-plano D)")
        for entry in sheldon_manifest[:20]:  # top 20 para não inflar
            repo = entry.get("repo", "?")
            count = entry.get("open_issues", 0)
            lines.append(f"- **{repo}**: {count} issue{'s' if count!=1 else ''} aberta{'s' if count!=1 else ''}")

    lines.append(f"\n---\n*Gerado automaticamente pelo Embassy Sentinel em {datetime.now(timezone.utc).isoformat()}*")
    return "\n".join(lines)


def create_digest_issue(body: str):
    week = datetime.now(timezone.utc).strftime("%Y-W%W")
    subprocess.run([
        "gh", "issue", "create",
        "--repo", CONSTELLATION_REPO,
        "--title", f"[embassy-digest] {week}",
        "--label", "embassy-digest,observatory",
        "--body", body,
    ], env={**os.environ, "GH_TOKEN": GH_TOKEN})


def main():
    print(f"[embassy_sentinel] {datetime.now().isoformat()} — iniciando")

    embassy_issues = fetch_embassy_issues()
    sheldon_manifest = fetch_sheldon_manifest()

    print(f"  embassy issues abertas: {len(embassy_issues)}")
    print(f"  entradas sheldon.json: {len(sheldon_manifest)}")

    if not embassy_issues and not sheldon_manifest:
        print("  nada a reportar — saindo.")
        return

    body = build_digest_body(embassy_issues, sheldon_manifest)
    create_digest_issue(body)
    print("  digest criado.")

    # Fechar issues embassy processadas
    for issue in embassy_issues:
        close_issue(issue["number"])
    print(f"  {len(embassy_issues)} issue(s) embassy fechadas.")


if __name__ == "__main__":
    main()
