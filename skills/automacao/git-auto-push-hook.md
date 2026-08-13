# Hook de Auto-Push após Commit do Claude

Configura push automático depois de cada `git commit` executado pelo Claude Code.
Elimina o `git push` manual em sessões de desenvolvimento assistido por IA.

Fonte: padrão extraído de projeto real em produção.

---

## O que faz

Após cada commit do Claude, o hook:
1. Detecta a branch atual
2. Faz push para o remote correspondente
3. Em caso de falha de rede: retry com backoff exponencial

---

## Configuração

### Automática (via install.sh/install.ps1)

`scripts/install.sh` (passo 6/7) e `scripts/install.ps1` (passo 5/6) já registram este
hook em `~/.claude/settings.json` (global, todos os projetos) apontando pro script deste
mesmo acervo: `.agnostic-core/scripts/hooks/post-tool-use-autopush`. Se você instalou o
acervo pelo instalador, nada a fazer aqui — pule para "Comportamento esperado".

### Manual (sem o instalador, ou harness diferente do Claude Code)

O hook lê o payload do `PostToolUse` via **stdin como JSON** (não env vars — é assim que
o Claude Code entrega o payload; ver `scripts/hooks/post-tool-use-autopush` no acervo para
a implementação de referência, que usa `node` pra parsear porque o próprio Claude Code
roda sobre Node e por isso está sempre disponível).

Registrar em `.claude/settings.json` (projeto) ou `~/.claude/settings.json` (global):

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".agnostic-core/scripts/hooks/post-tool-use-autopush"
          }
        ]
      }
    ]
  }
}
```

Se o acervo não estiver como submódulo neste projeto, copie o script de
`.agnostic-core/scripts/hooks/post-tool-use-autopush` para `.claude/hooks/` e ajuste o
`command` acima, mantendo `chmod +x`.

---

## Comportamento esperado

- Após `git commit` pelo Claude → push automático para a branch atual
- Falha de rede → 4 tentativas com espera crescente
- Falha definitiva → mensagem clara, sem silêncio

---

## Quando NÃO usar

- Branches de feature com PRs que exigem review antes do push
- Projetos com CI/CD que dispara deploy no push (verificar antes)
- Repos com branch protection que requer PR

---

## Ver também

- `skills/automacao/automacoes-uteis.md` — outros hooks e automações
- `skills/git/commit-conventions.md` — padrão de commits
- `skills/git/branching-strategy.md` — estratégia de branches
