# project-status

Exibe um painel visual de contexto do projeto no terminal do Claude Code.  
Ativa automaticamente no início de cada sessão e sob demanda via `/status`.

---

## Ativação

| Modo | Como funciona |
|------|--------------|
| **Auto** | Claude exibe o painel na primeira mensagem de cada sessão |
| **Manual** | Usuário chama `/status` a qualquer momento |

Para ativar o modo automático, declare no `CLAUDE.md` do projeto:

```md
## Comportamento
Ao iniciar cada sessão, execute automaticamente o comando `/status`
antes de qualquer outra ação.
```

---

## Coleta de dados

Execute os comandos abaixo em sequência para montar o painel:

```bash
# Path local
pwd

# Repositório GitHub
git remote get-url origin 2>/dev/null \
  | sed 's|git@github.com:|github.com/|; s|https://github.com/||; s|\.git$||'

# Branch atual
git branch --show-current 2>/dev/null || echo "sem branch"

# Docker
ls Dockerfile docker-compose.yml docker-compose.yaml 2>/dev/null | head -1

# Ambiente de produção — verificar nesta ordem
ls fly.toml vercel.json railway.toml render.yaml \
   netlify.toml .do/app.yaml Procfile \
   wrangler.toml coolify.yaml caprover.json 2>/dev/null | head -1
```

**Modelo e uso de contexto:** lidos diretamente do ambiente Claude Code
(variáveis internas `$CLAUDE_MODEL` e `$CONTEXT_USAGE_PCT`).

---

## Mapeamento de arquivos → ambiente

| Arquivo detectado | Label exibida |
|-------------------|---------------|
| `fly.toml` | `Fly.io` |
| `vercel.json` | `Vercel` |
| `railway.toml` | `Railway` |
| `render.yaml` | `Render` |
| `netlify.toml` | `Netlify` |
| `.do/app.yaml` | `DigitalOcean App Platform` |
| `Procfile` | `Heroku` |
| `wrangler.toml` | `Cloudflare Workers` |
| `coolify.yaml` | `Coolify (self-hosted)` |
| `caprover.json` | `CapRover (VPS)` |
| Nenhum encontrado | `Não detectado` |

---

## Formato visual do painel

Renderize exatamente neste formato, substituindo os valores coletados:

```
╔══════════════════════════════════════════════════════════╗
║  PROJECT STATUS                                          ║
╠══════════════════════════════════════════════════════════╣
║  📁 Path      /caminho/para/o/projeto                    ║
║  🐙 Repo      github.com/usuario/repositorio             ║
║  🌿 Branch    main                                       ║
║  🧠 Modelo    claude-sonnet-5                            ║
║  📊 Contexto  ████████░░  78%                            ║
║  🐳 Docker    ✓  docker-compose.yml                      ║
║  🚀 Prod      Fly.io  (fly.toml)                         ║
╚══════════════════════════════════════════════════════════╝
```

### Barra de contexto

Gere a barra proporcional ao percentual de uso (10 blocos totais):

| Uso | Barra | Cor sugerida |
|-----|-------|--------------|
| 0–50% | `█████░░░░░` | normal |
| 51–75% | `████████░░` | amarelo `⚠` |
| 76–90% | `█████████░` | laranja `⚠` |
| 91–100% | `██████████` | vermelho `🔴` |

Acima de 75%, adicione aviso abaixo do painel:

```
  ⚠  Contexto acima de 75% — considere /compact ou nova sessão.
```

### Docker

| Situação | Exibição |
|----------|----------|
| Arquivo encontrado | `✓  nome-do-arquivo` |
| Nenhum encontrado | `✗  não detectado` |

### Prod

| Situação | Exibição |
|----------|----------|
| Arquivo encontrado | `NomeAmbiente  (arquivo)` |
| Nenhum encontrado | `Não detectado` |

---

## Exemplo de saída

```
╔══════════════════════════════════════════════════════════╗
║  PROJECT STATUS                                          ║
╠══════════════════════════════════════════════════════════╣
║  📁 Path      /Users/miranda/projects/finance-api        ║
║  🐙 Repo      github.com/miranda/finance-api             ║
║  🌿 Branch    main                                       ║
║  🧠 Modelo    claude-sonnet-5                            ║
║  📊 Contexto  ████████░░  78%                            ║
║  🐳 Docker    ✓  docker-compose.yml                      ║
║  🚀 Prod      Fly.io  (fly.toml)                         ║
╚══════════════════════════════════════════════════════════╝

  ⚠  Contexto acima de 75% — considere /compact ou nova sessão.
```

---

## Desativação

Para desativar o modo automático, remova ou comente a instrução
de comportamento no `CLAUDE.md` do projeto. O comando `/status`
continua disponível manualmente.

---

*Referência: agnostic-core · skills/ai/project-status.md*
