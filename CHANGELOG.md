# Changelog

Todas as mudanças notáveis deste projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/),
versionamento [SemVer](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Alterado

- **`docs/keywords-map.md` fatiado em `docs/keywords/<categoria>.md`** (19
  categorias, 100 skills). O `keywords-map.md` continua sendo o ponto de entrada
  — e continua no mesmo path, então nenhum consumidor precisa mudar o próprio
  `CLAUDE.md` — mas virou índice: protocolo de invocação + tabela categoria →
  arquivo, de **41 KB para 3 KB**. As categorias são lidas sob demanda. Um repo
  cujo `CLAUDE.md` manda ler o mapa no início de cada sessão deixa de pagar
  ~10k tokens por sessão para carregar 100 blocos de keywords, 99% deles sem
  relação com o assunto em pauta.
- `CLAUDE.md` e os três templates de `project-bootstrap` descrevem o novo
  carregamento sob demanda.

### Corrigido

- **`install.sh` grava `.agnostic-skills` pré-preenchido pelo stack detectado.**
  O gerador só filtra o que espelha quando esse arquivo existe, e nada o criava:
  na prática quase nenhum consumidor tinha um, e o acervo inteiro ia para o
  system prompt de toda sessão. Nunca sobrescreve um arquivo existente — seleção
  é decisão do projeto. Efeito medido num projeto React+Tailwind+Vitest+Vercel:
  51 skills espelhadas em vez de 112.
- **`generate-claude-skills.sh`: a poda agora alcança o legado.** Um diretório é
  removido quando não foi gerado agora e é comprovadamente nosso, por qualquer
  das três provas: está no manifesto anterior, carrega a marca
  `agnostic-core:generated` no corpo (nova, gravada em toda skill gerada), ou o
  nome é derivável de um arquivo do acervo sob o esquema atual (basename) ou o
  legado (caminho completo, até `e9fa143`). Fecha os dois vazamentos que o
  manifesto sozinho não cobria — troca de esquema de nomes e adoção tardia de
  `.agnostic-skills`. Num repo real: 223 diretórios espelhados, 112 deles órfãos
  do esquema antigo (`caveman` **e** `behavioral-caveman`, `code-review` **e**
  `audit-code-review`, …) consumindo 8,4 KB de descrição duplicada em cada
  sessão. Skill escrita à mão não satisfaz nenhuma das três provas e não é
  tocada.
- **`generate-claude-skills.sh` ignora material de apoio de skill-diretório.**
  Arquivo dentro de um diretório que tem `SKILL.md` (`references/`, `assets/`)
  é suporte da skill, não skill. Sem isso,
  `skills/audit/dead-code-auditor/references/checklist.md` virava uma skill de
  topo chamada `checklist` no prompt de todo consumidor.
- **`generate-claude-skills.sh` normaliza a description extraída.** Marcação
  Markdown crua (blockquote, marcador de lista, negrito, crase, espaço duplo)
  vazava para dentro do frontmatter e ocupava os 130 caracteres úteis sem
  informar o roteamento.

### Adicionado

- **Hooks técnicos do agnostic-router** (`UserPromptSubmit` + `Stop`) —
  `scripts/hooks/user-prompt-router.js` declara `[router: <tier> | fase=<fase> |
  conf=<conf>]` via `systemMessage` a cada prompt; `scripts/hooks/stop-router-update.js`
  fecha o ciclo lendo o transcript (resposta do assistente + arquivos tocados via
  `Edit`/`Write`/`NotebookEdit`) e chamando `update_session`. Implementa a lacuna
  que a própria skill do agnostic-router já apontava ("hooks tornam isso visível",
  antes só aspiracional). Estado de sessão persiste em
  `<tmp>/agnostic-router-state/<session_id>.json` entre os dois hooks.
- **`scripts/agnostic-router/router.js`** — porte 1:1 de `router.py` pra Node.js,
  sem dependências externas. Necessário porque os hooks do Claude Code rodam no
  processo local do usuário, que pode não ter `python3` instalado (Node é garantido,
  já que o próprio Claude Code roda sobre ele). Mesmo léxico, mesmos limiares,
  mesma lógica de fase/pressão/histerese/escalada forçada — validado rodando os
  casos de demo de `router.py` e comparando os tiers resultantes.
- Registrado automaticamente por `install.sh`/`install.ps1` em
  `~/.claude/settings.json` (respeita `--no-hook`).

## [1.2.0] - 2026-07-14

### Adicionado

- **Nova skill `skills/ai/agnostic-router.md`** — roteamento comportamental de
  modelo: decide o tier (haiku/sonnet/opus) pela **fase de trabalho**
  (explore/design/implement/debug/review/operate) + sinais + estado de sessão,
  em vez de keyword map. Determinístico, provider-agnostic, roda no orquestrador
  antes da chamada à API. Motor de referência em `scripts/agnostic-router/`
  (`router.py` + harness `eval.py`); racional e casos de borda em
  `docs/agnostic-router-design.md`.
- Roteamento **mesclado** nos comandos de sessão existentes
  (`skills/workflow/abrirsessao.md`, `fecharsessao.md`) — sem duplicar comandos.
- Protocolo de roteamento declarado no `CLAUDE.md` (o repo dogfooda a skill).
- Entradas em `docs/skills-index.md` e `docs/keywords-map.md`.

### Corrigido

- **`scripts/generate-claude-skills.sh`** — um comentário `# ...` dentro de um
  bloco ``` não é mais tratado como heading Markdown H1 ao extrair
  título/descrição (gerava descrição lixo na camada nativa).

### Alterado

- `npm run lint` exclui `.claude/skills` (camada gerada; o source-of-truth é
  `skills/`), evitando falsos positivos MD003 herdados.

## [1.1.1] - 2026-04-20

### Corrigido

- **CLAUDE.md curado para consumo público** — removido conteúdo autoral
  específico (lista de projetos pessoais em rollout de Eruda, workflow
  hardcoded nos orgs `paulinett1508-dev`/`Lab-Sobral-Dev`). Mantidas as
  regras genéricas (convenção de branch, uso de subagents, verificação
  antes de concluir, elegância). Conteúdo pessoal movido para
  `CLAUDE.internal.md` (gitignored, não distribuído).

## [1.1.0] - 2026-04-20

### Adicionado

- **Nova categoria `skills/communication/`** com `response-contract.md` —
  contrato de resposta para IA em desenvolvimento profissional: conciso,
  decisivo, sem firulas, anuncia antes de executar. Inclui bloco de
  instalação pronto pra copiar em `~/.claude/CLAUDE.md` com marcadores
  BEGIN/END idempotentes. Aplicável a Claude Code, Cursor, Copilot e similares.
- Entry em `docs/skills-index.md`, `commands/claude-code/COMMANDS.md` e
  `README.md` referenciando a nova categoria.

## [1.0.0] - 2026-04-18

Primeira versão pública distribuível.

### Adicionado

- **Instalador universal** `scripts/install.sh` com detecção automática de stack,
  flags `--template`, `--no-hook`, `--no-commit`, `--no-claude-skills`.
- **Instalador PowerShell** `scripts/install.ps1` (espelho do `.sh` para Windows).
- **Wrapper npm** `package.json` + `scripts/npx-entry.js` — permite
  `npx agnostic-core@latest init` em qualquer projeto Node.
- **Gerador de camada nativa** `scripts/generate-claude-skills.sh` — cria
  `.claude/skills/<nome>/SKILL.md` com frontmatter YAML para autodescoberta
  no Claude Code, mantendo os Markdown em `skills/` como fonte única da verdade.
- **Validação de integridade** `scripts/check-refs.sh` — verifica paths
  referenciados e frontmatter de `SKILL.md`.
- **CI GitHub Actions**:
  - `lint-markdown.yml` — markdownlint-cli2 em todo `**/*.md`.
  - `check-links.yml` — lychee para links internos e externos.
  - `check-refs.yml` — roda `check-refs.sh` a cada push/PR.
- **Convenções de projeto**: `.gitattributes`, `.editorconfig`, `.markdownlint.json`.

### Conteúdo

- 81+ skills em 18 categorias (security, frontend, backend, devops, audit, ai…).
- 16 agents especializados (reviewers, validators, generators, specialists).
- 18+ commands para Claude Code + 4 workflows (brainstorm, create, debug, deploy).
- 3 templates de bootstrap (`api-backend`, `frontend`, `fullstack`).
- 1 skill nativa Claude Code (`.claude/skills/eruda`).

### Corrigido

- Refs quebradas para `.agnostic-core/compliance/checklists/pre-deploy.md` em
  templates e commands — apontadas agora para
  `skills/devops/pre-deploy-checklist.md` (local canônico).
- Caminho `templates/project-bootstrap/CLAUDE.md` sem subpasta (não existia) —
  `docs/integration-guide.md` agora aponta para `fullstack/CLAUDE.md`.
- Referência `docs/CONTRIBUTING.md` em `skills-index.md` corrigida para
  `CONTRIBUTING.md` na raiz.
