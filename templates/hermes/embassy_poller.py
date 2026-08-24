#!/usr/bin/env python3
"""
embassy_poller.py — Substituto PULL do Embassy Dispatch (GitHub Actions)

Consulta a API REST do GitHub (chamadas de API não consomem minuto de
Actions, mesmo com billing/spending-limit zerado) por push/issue-fechada/
release novos em cada corpo listado no manifest do sub-plano D
(~/embassy/sheldon.json) e cria a mesma issue [embassy] no repo agregador
que o workflow reusável `embassy-dispatch.yml` criava.

Motivo: conta GitHub bloqueada por billing (Actions), 2026-08-24 — decisão
registrada em Amilcar-Constellation/adr/adr-016-embassy-poller-substitui-actions.md.

`embassy_sentinel.py` (mesma pasta) não muda — continua consumindo estas
issues [embassy] pra gerar o digest semanal e fechá-las.

Cron sugerido: */15 * * * *  no Oráculo-VPS (nexus-vps01).

Uso:
    EMBASSY_PAT=xxx python3 embassy_poller.py [--dry-run]
"""

import argparse
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone

API = "https://api.github.com"
CONSTELLATION_REPO = os.environ.get("EMBASSY_REPO", "paulinett1508-dev/Amilcar-Constellation")
GH_TOKEN = os.environ.get("EMBASSY_PAT") or os.environ.get("GITHUB_TOKEN")
MANIFEST_PATH = os.path.expanduser(os.environ.get("EMBASSY_MANIFEST", "~/embassy/sheldon.json"))
STATE_PATH = os.path.expanduser(os.environ.get("EMBASSY_POLLER_STATE", "~/embassy/poller_state.json"))

# Mesma exclusão de ruído do embassy.yml original (paths-ignore) — evita
# disparar embassy por commit só de doc/config.
_NOISE_SUFFIXES = (".md", ".lock", ".log")
_NOISE_PREFIXES = (".github/", "docs/")


def _gh_api(path: str):
    req = urllib.request.Request(
        f"{API}{path}",
        headers={
            "Authorization": f"Bearer {GH_TOKEN}",
            "Accept": "application/vnd.github+json",
            "User-Agent": "embassy-poller",
            "X-GitHub-Api-Version": "2022-11-28",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            body = r.read().decode()
            return json.loads(body) if body else None
    except urllib.error.HTTPError as exc:
        if exc.code == 404:
            return None
        raise


def _load_repos() -> list[str]:
    if not os.path.exists(MANIFEST_PATH):
        print(f"[embassy_poller] manifest ausente: {MANIFEST_PATH}", file=sys.stderr)
        return []
    with open(MANIFEST_PATH, encoding="utf-8") as f:
        manifest = json.load(f)
    return sorted({entry["repo"] for entry in manifest if entry.get("repo")})


def _load_state() -> dict:
    if os.path.exists(STATE_PATH):
        with open(STATE_PATH, encoding="utf-8") as f:
            return json.load(f)
    return {}


def _save_state(state: dict) -> None:
    os.makedirs(os.path.dirname(STATE_PATH), exist_ok=True)
    with open(STATE_PATH, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)


def _corpo_name(repo: str) -> str:
    return repo.split("/", 1)[-1]


def _is_noise_path(path: str) -> bool:
    return path.endswith(_NOISE_SUFFIXES) or path.startswith(_NOISE_PREFIXES)


def _push_worth_dispatch(commit: dict) -> bool:
    files = commit.get("files")
    if not files:
        return True  # sem info de arquivo (ex.: merge commit grande) — não arrisca omitir
    return any(not _is_noise_path(f["filename"]) for f in files)


def _dispatch(dry_run: bool, corpo: str, resumo: str, tipo: str, origem_url: str, ator: str, data: str) -> None:
    title = f"[embassy] {corpo} — {resumo}"
    body = (
        f"**Corpo:** {corpo}\n"
        f"**Evento:** {tipo}\n"
        f"**Data:** {data or datetime.now(timezone.utc).isoformat(timespec='seconds')}\n"
        f"**Ator:** {ator}\n"
        f"**Origem:** {origem_url}\n\n"
        f"{resumo}"
    )
    if dry_run:
        print(f"[dry-run] criaria issue em {CONSTELLATION_REPO}: {title}")
        return
    subprocess.run(
        ["gh", "issue", "create", "--repo", CONSTELLATION_REPO,
         "--title", title, "--label", "embassy", "--body", body],
        check=True, env={**os.environ, "GH_TOKEN": GH_TOKEN},
    )


def _poll_push(repo: str, state: dict, dry_run: bool) -> None:
    repo_state = state.setdefault(repo, {})
    default_branch = repo_state.get("default_branch")
    if not default_branch:
        meta = _gh_api(f"/repos/{repo}") or {}
        default_branch = meta.get("default_branch", "main")
        repo_state["default_branch"] = default_branch

    commit = _gh_api(f"/repos/{repo}/commits/{default_branch}")
    if not commit:
        return
    sha = commit["sha"]
    is_first_run = "last_push_sha" not in repo_state
    if repo_state.get("last_push_sha") == sha:
        return
    repo_state["last_push_sha"] = sha
    if is_first_run:
        return  # só grava baseline — não dispara o histórico inteiro na 1a rodada
    if not _push_worth_dispatch(commit):
        return

    msg = commit["commit"]["message"].splitlines()[0]
    author = (commit.get("author") or {}).get("login") or commit["commit"]["author"]["name"]
    date = commit["commit"]["author"]["date"]
    resumo = f"push em `{default_branch}` — {msg} ({sha[:7]})"
    _dispatch(dry_run, _corpo_name(repo), resumo, "push", commit["html_url"], author, date)


def _poll_closed_issues(repo: str, state: dict, dry_run: bool) -> None:
    repo_state = state.setdefault(repo, {})
    since = repo_state.get("last_issue_check")
    is_first_run = since is None
    now_iso = datetime.now(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
    if is_first_run:
        repo_state["last_issue_check"] = now_iso
        return  # baseline — não varre issues fechadas no passado

    issues = _gh_api(
        f"/repos/{repo}/issues?state=closed&since={since}&sort=updated&direction=asc&per_page=50"
    ) or []
    dispatched = set(repo_state.get("dispatched_issue_keys", []))
    for issue in issues:
        if "pull_request" in issue:
            continue
        closed_at = issue.get("closed_at")
        if not closed_at or closed_at < since:
            continue
        key = f"{issue['number']}:{closed_at}"
        if key in dispatched:
            continue
        resumo = f"issue #{issue['number']} fechada — {issue['title']}"
        _dispatch(dry_run, _corpo_name(repo), resumo, "issue_closed",
                  issue["html_url"], (issue.get("user") or {}).get("login", "?"), closed_at)
        dispatched.add(key)
    repo_state["dispatched_issue_keys"] = sorted(dispatched)[-200:]  # não crescer pra sempre
    repo_state["last_issue_check"] = now_iso


def _poll_release(repo: str, state: dict, dry_run: bool) -> None:
    repo_state = state.setdefault(repo, {})
    release = _gh_api(f"/repos/{repo}/releases/latest")
    if not release:
        return
    tag = release["tag_name"]
    is_first_run = "last_release_tag" not in repo_state
    if repo_state.get("last_release_tag") == tag:
        return
    repo_state["last_release_tag"] = tag
    if is_first_run:
        return

    resumo = f"release `{tag}` publicado — {release.get('name') or tag}"
    _dispatch(dry_run, _corpo_name(repo), resumo, "release", release["html_url"],
              (release.get("author") or {}).get("login", "?"), release.get("published_at", ""))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="imprime o que seria despachado, sem criar issues")
    args = parser.parse_args()

    if not GH_TOKEN:
        print("[embassy_poller] EMBASSY_PAT/GITHUB_TOKEN ausente no ambiente", file=sys.stderr)
        sys.exit(1)

    repos = _load_repos()
    if not repos:
        print("[embassy_poller] nenhum repo no manifest — nada a fazer")
        return

    state = _load_state()
    for repo in repos:
        try:
            _poll_push(repo, state, args.dry_run)
            _poll_closed_issues(repo, state, args.dry_run)
            _poll_release(repo, state, args.dry_run)
        except Exception as exc:  # um repo com problema não derruba os demais
            print(f"[embassy_poller] falha em {repo}: {exc}", file=sys.stderr)

    if args.dry_run:
        print("[dry-run] estado não persistido")
    else:
        _save_state(state)


if __name__ == "__main__":
    main()
