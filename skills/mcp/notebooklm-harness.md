---
name: notebooklm-harness
description: Use quando o usuário quiser conectar um projeto a uma base de conhecimento curada via NotebookLM (gemini-notebook-mcp) — criar notebook, curar fontes, e definir a política de quando consultá-lo vs. código local vs. Git. Acionar em pedidos como "cria um NotebookLM pra esse projeto", "integra o Gemini Notebook", "quero uma base de conhecimento curada", ou quando `gemini-notebook-mcp` estiver disponível e a tarefa envolver arquitetura/regra de negócio que pode se beneficiar de contexto curado.
---

# NotebookLM Harness — Convergência de Conhecimento MCP

Objetivo: transformar um NotebookLM (via `gemini-notebook-mcp`) em uma camada de conhecimento curada e governada para um projeto, com regras explícitas de quando consultá-la, quando atualizá-la, e qual fonte vence em caso de conflito com o código.

Um MCP conectado não decide sozinho quando deve ser usado — isso exige política escrita no arquivo de instrução do agente (`CLAUDE.md`, `AGENTS.md` ou equivalente). Sem essa política, dois riscos simétricos: o agente ignora o notebook mesmo quando ele teria a resposta certa, ou passa a tratá-lo como fonte de verdade e propõe mudar código pra obedecer documentação desatualizada.

---

## Quando usar esta skill

- Projeto tem (ou vai ter) `gemini-notebook-mcp` disponível e ainda não tem política de quando consultá-lo.
- Usuário pede pra "criar uma base de conhecimento", "conectar o NotebookLM", "curar a documentação num notebook".
- Notebook já existe mas está sendo usado sem critério (consultado em toda tarefa, ou nunca).

## Pré-requisitos

- Node.js ≥ 22.13 e Chrome instalado (canal estável; se o Chrome não abrir, o servidor cai pra um Chromium empacotado via `BROWSER_CHANNEL=chromium`).
- Windows: precisa de WSL2 + WSLg (WSL1 não roda o Chromium). Servidor Linux headless: `setup_auth` (Passo 1) exige display na primeira vez — rodar sob `xvfb-run` nesse caso.
- MCP `gemini-notebook-mcp` conectado (ver "Conectar o MCP" abaixo) — ferramentas `ask_question`, `add_source`, `add_notebook`, `select_notebook`, `setup_auth`, etc.
- Projeto já tem um arquivo de instrução do agente (`CLAUDE.md`/`AGENTS.md`) e, idealmente, uma pasta de documentação de referência (`docs/references/`, `docs/architecture/` ou equivalente) — reaproveitar a convenção existente, não inventar uma nova.

### Conectar o MCP

O pacote publicado é `@charlie.act7/gemini-notebook-mcp` (fork ativo de
`PleasePrompto/notebooklm-mcp`). Ele não precisa de instalação prévia — `npx` baixa e
mantém em cache. **Antes de conectar, perguntar ao usuário qual conta Google deve
autenticar este notebook** (ver Passo 1) — a escolha do slug de conta abaixo depende
dessa resposta.

Claude Code (CLI):

```bash
claude mcp add gemini-notebook -- npx @charlie.act7/gemini-notebook-mcp@latest
```

Manual, em `~/.claude.json` (global) ou `.mcp.json` na raiz do projeto (escopo local):

```json
{
  "mcpServers": {
    "gemini-notebook": {
      "command": "npx",
      "args": ["@charlie.act7/gemini-notebook-mcp@latest"]
    }
  }
}
```

Cursor usa o mesmo formato em `~/.cursor/mcp.json`; Codex CLI: `codex mcp add gemini-notebook npx @charlie.act7/gemini-notebook-mcp@latest`.

**Múltiplas contas Google na mesma máquina** (ex.: notebook pessoal vs. de trabalho em
projetos diferentes): nomear o servidor por conta e passar `NOTEBOOKLM_ACCOUNT=<slug>`
no `env` — cada slug isola cookies/perfil de Chrome numa subpasta própria, sem misturar:

```json
{
  "mcpServers": {
    "gemini-notebook-pessoal": {
      "command": "npx",
      "args": ["@charlie.act7/gemini-notebook-mcp@latest"],
      "env": { "NOTEBOOKLM_ACCOUNT": "pessoal" }
    },
    "gemini-notebook-trabalho": {
      "command": "npx",
      "args": ["@charlie.act7/gemini-notebook-mcp@latest"],
      "env": { "NOTEBOOKLM_ACCOUNT": "trabalho" }
    }
  }
}
```

Sem `NOTEBOOKLM_ACCOUNT`/`--account`, o servidor usa o perfil default (single) —
suficiente quando só há uma conta Google envolvida.

---

## Passo 1 — Autenticação

**Antes de autenticar: perguntar ao usuário qual conta Google deve autenticar este
notebook.** Não existe comando `nlm login` — a autenticação é a ferramenta MCP
`setup_auth`: ela abre um Chrome visível, o usuário loga manualmente uma vez, e os
cookies persistem no perfil (path por plataforma — Linux
`~/.local/share/notebooklm-mcp/chrome_profile/`, macOS
`~/Library/Application Support/notebooklm-mcp/chrome_profile/`, Windows
`%APPDATA%\notebooklm-mcp\chrome_profile\`, ou a subpasta `accounts/<slug>/`
correspondente quando `NOTEBOOKLM_ACCOUNT` estiver configurado). Rodadas seguintes
reaproveitam o perfil sem pedir login de novo.

Se o projeto usa uma conta diferente da que já está autenticada (perfil default sem
slug, já usado por outro projeto nesta máquina): configurar `NOTEBOOKLM_ACCOUNT=<slug>`
pra esta conexão (seção acima) e rodar `setup_auth` — cada slug tem seu próprio
primeiro login, isolado do perfil default e dos demais slugs. Para reautenticar uma
conta já configurada (sessão expirada, ou trocar de fato a conta daquele slug): usar
`re_auth`, que apaga o auth salvo e força login do zero.

Se a pasta de perfil não puder ser criada por ACL restritiva (comum em Windows
corporativo): pedir ao usuário pra ajustar a permissão da pasta numa sessão
**elevada** (Administrador) — comandos read-only não elevados (`Remove-Item`,
`takeown`) falham mesmo rodando como o próprio usuário dono. Nunca tente rodar
comandos de administrador sozinho nem peça pro usuário desabilitar UAC — é ação do
usuário, fora do alcance do agente.

## Passo 2 — Criar (manual) e registrar o notebook

**Não existe ferramenta MCP que crie um notebook novo do zero.** A criação é manual,
no site (`notebook.google.com` → "New notebook"), com nome descritivo do projeto (não
genérico tipo "docs" ou "notas"). Um notebook por projeto, não um notebook
compartilhado entre vários — mistura contexto de domínios diferentes na hora da
consulta. Pedir ao usuário pra criar (ou apontar um já existente) antes de prosseguir.

Depois de criado, registrar na biblioteca local por um dos dois caminhos:

- **Com link de compartilhamento:** usuário faz Share → "Anyone with the link" →
  copiar link → `add_notebook(url, name, description, topics, ...)`. A própria
  ferramenta exige confirmação explícita do usuário antes de registrar — nunca chamar
  sem essa confirmação.
- **Direto da conta autenticada:** `list_account_notebooks` lê a grade de notebooks da
  conta logada; `import_account_notebook(google_notebook_id, ...)` importa sem
  precisar copiar link. Preferir este caminho quando o notebook já existe na mesma
  conta que acabou de autenticar.

Depois de registrado: `select_notebook(id)` define o notebook como padrão ativo, para
não precisar passar `notebook_id` em toda chamada de `ask_question`/`add_source`.

Repositório privado no GitHub **não pode** virar fonte via `add_source(type="url")` diretamente (o NotebookLM busca a URL sem autenticação e recebe 404) — precisa virar fonte de texto curada manualmente (Passo 3).

## Passo 3 — Curadoria de fontes

Curadoria é o trabalho real desta skill — não é "jogar o repo inteiro pra dentro".

**Incluir:** README, arquivo de instrução do agente, docs de arquitetura, docs de referência/guias operacionais vigentes, regras de negócio (configs declarativos de módulos/features), manifests de dependência (`package.json` e equivalentes), arquivos de infraestrutura (Dockerfile, compose, scripts de deploy), `.env.example` (nunca `.env` real), lições aprendidas / histórico de decisões, e auditorias/investigações já validadas quando o usuário confirmar que quer esse histórico (pedir explicitamente antes de assumir — auditorias tendem a ser volumosas, mas por isso mesmo são uma boa candidata: uma vez curadas, consultas futuras usam `ask_question`, processado pelo Gemini, em vez do agente reler o documento inteiro no próprio contexto a cada pergunta).

**Excluir por padrão:** código-fonte de implementação (fica no repo, não precisa de cópia), artefatos de sessão (planos, specs de feature pontual, PRDs individuais — múltiplos aos dezenas/centenas em projetos ativos), documentação já marcada como deprecated/arquivada, lockfiles, backups, dumps de dados, qualquer coisa com segredo (mesmo que "só" seria um `.env` com valor real). Declarar a lista de exclusão explicitamente ao usuário antes de rodar — sujeito a correção dele (ex.: usuário pode pedir pra incluir auditorias que você tinha excluído por padrão).

**Restrição de formato:** `add_source` só aceita `type: "url"` (crawl público), `type: "youtube"` (URL pública) ou `type: "text"` (colado) — **não existe upload de arquivo nem integração com Drive picker**. Todo arquivo que não for uma URL pública vira `type: "text"`, com o conteúdo lido e colado, e `title` = caminho relativo do arquivo original. Resumir/estruturar o conteúdo em vez de colar bruto quando o arquivo for muito verboso (ex.: um JSON de config longo vira um parágrafo descritivo do que ele configura, não o JSON literal).

**Execução em lote:** usar `batch_add_sources` (aceita de 1 a 25 fontes por chamada, mesmos campos `type`/`content`/`title` de `add_source`) em vez de uma chamada individual por arquivo — dividir em grupos de até 25 quando a curadoria passar disso. Não repetir automaticamente uma fonte com `correlation.status` `accepted_unverified` ou `ambiguous` (pode já ter sido criada) — chamar `list_sources` pra reconciliar o inventário antes de tentar de novo.

**Gap conhecido — sem remoção de fonte:** o MCP não expõe nenhuma tool `remove_source` (só `remove_notebook`, que apaga o notebook inteiro). Se uma fonte cair em `status: "error"` (diferente de `accepted_unverified`/`ambiguous`, que resolvem sozinhas), tentar reenviar o mesmo título no máximo uma vez — reenvios adicionais tendem a herdar o mesmo erro em vez de corrigir. A entrada travada costuma ser só inventário interno do MCP, sem card correspondente na UI real do NotebookLM (nada pra apagar manualmente, não conta contra cota) — aceitar como lixo inofensivo e seguir; o conteúdo da fonte que falhou continua acessível via leitura direta do arquivo no repo.

## Passo 4 — Governança: hierarquia de fontes de verdade

Criar um arquivo de referência (seguindo a convenção de docs já usada pelo projeto — ex. `docs/references/notebooklm-knowledge-base.md`) com:

| Fonte | Autoridade sobre |
|---|---|
| **Código local + testes** | Comportamento ATUAL do sistema — sempre vence em caso de conflito |
| **Git/GitHub** | Histórico, autoria, branches, commits, issues, PRs |
| **NotebookLM** | Arquitetura, regra de negócio, decisões e contexto curados — não é fonte de comportamento atual |
| **Arquivo de instrução do agente** (`CLAUDE.md`/`AGENTS.md`) | Como o agente deve trabalhar neste repo |

**Regra de conflito:** o código local é autoritativo. Sinalizar a divergência ao usuário e propor atualizar a doc/notebook — nunca alterar código pra obedecer documentação desatualizada. Documentar no arquivo de referência pelo menos um exemplo real de divergência já encontrado no projeto, se houver — prova de que a regra não é teórica.

**Quando consultar:** só quando a pergunta exigir contexto de negócio/arquitetura/decisão histórica que não esteja evidente lendo o código (ex.: "por que essa regra existe", "que decisões já foram tomadas sobre X"). Não consultar pra tarefa simples de código, bug fix direto, ou dúvida que `grep`/leitura de arquivo resolve mais rápido e com mais confiança.

**Quando atualizar o notebook:** só em conclusão de feature significativa, decisão arquitetural relevante, mudança de infraestrutura, ou correção cuja causa deva ser lembrada no futuro. Nunca por commit trivial, refactor interno ou ajuste cosmético — o notebook é curadoria, não espelho de cada commit.

## Passo 5 — Registrar no arquivo de instrução do agente

Adicionar um parágrafo curto (não uma seção nova extensa — a extensa já está no doc de referência) na seção de MCPs/ferramentas do `CLAUDE.md`/`AGENTS.md`, cobrindo em poucas linhas: quando consultar, regra de conflito, e apontando pro doc de referência do Passo 4. Incluir explicitamente:

- **Instrução direta do usuário sempre vence o roteamento automático** — em português natural ("consulte o notebook primeiro", "não use nisso"), sem necessidade de sintaxe especial (ver "O que não fazer" abaixo).
- **Pergunta sobre histórico/autoria/commits/branches/issues/PRs vai pro Git/GitHub, não pro NotebookLM** — completa a hierarquia sem deixar ambiguidade sobre esse caso comum.

---

## O que NÃO fazer

Cada item abaixo foi proposto e descartado numa integração real — documentado aqui pra não reaparecer disfarçado de "melhoria":

- **Sintaxe de prefixos tipo `[NLM]`/`[LOCAL]`/`[GIT]`** — resolve um problema que não existe. Instrução em português direto já é suficiente pro agente entender e priorizar; formalizar uma tag cria fricção pro usuário lembrar, sem ganho de precisão.
- **"Modos" nomeados (automático/obrigatório/local) como taxonomia formal** — é a mesma regra dita três vezes com rótulo. "Modo obrigatório" é só o usuário pedindo explicitamente; não precisa virar categoria documentada.
- **Hook automático que envia código/commits ao notebook sem confirmação** — viola controle humano sobre upload a serviço terceiro. Toda atualização do notebook é ação manual e revisada.
- **ADR, guia de contribuição, ou qualquer ritual de processo que o projeto não usa hoje** — não introduzir ceremônia nova só porque a integração é nova. Se o projeto não usa ADR, não cria ADR "porque parece robusto".
- **Skills/comandos novos "de roteamento" que dupliquem skills/agents já existentes** (ex.: mapeador de projeto, investigador de regressão) — checar o catálogo existente antes de propor qualquer skill nova. A resposta certa quase sempre é "já existe, só falta usar".
- **Diagnóstico redundante** — se o agente já tem o mapeamento do projeto (via `CLAUDE.md`, sessão anterior, ou skills já carregadas), não repita uma fase de "inventário completo" que já está escrita em outro lugar.

Regra geral: uma proposta de processo chega quase sempre inflada. Filtrar o que resolve um problema real do que só parece robusto é parte do trabalho, não um passo opcional.

---

## Checklist de validação

1. `list_sources` confirma que as fontes foram ingeridas (`status` de cada uma pronto, não pendente) e `get_notebook`/`get_library_stats` reflete a contagem esperada.
2. Uma consulta de teste (`ask_question` com `source_format: "footnotes"`) pedindo resumo arquitetural retorna resposta com citações às fontes corretas no array `sources` (`source_name`/`title` batendo com o que foi curado) — sinal de que a curadoria capturou o que importa.
3. Simular um conflito real conhecido do projeto (ex.: uma regra documentada que diverge do código) e confirmar que a resposta da consulta identifica a divergência em vez de apresentá-la como verdade única.
4. Revisar o parágrafo adicionado ao `CLAUDE.md`/`AGENTS.md`: alguém que não participou da sessão consegue, só lendo aquele trecho, saber quando consultar o notebook e o que fazer em caso de conflito?

## Notebooks grandes (50+ fontes)

`ask_question` é síncrono, com teto em `ANSWER_TIMEOUT_MS` (padrão 600000ms/10min,
configurável) — não existe uma variante assíncrona com polling pra pergunta/resposta.
Notebook muito grande pode deixar a resposta lenta, mas ainda dentro desse teto; não
esperar um padrão `*_start` + polling que não existe pra `ask_question`. O único fluxo
assíncrono real do servidor é o de artefato de Studio (`generate_artifact` retorna
`job_id`, consultado depois via `get_artifact_status`/`download_artifact`) — usar esse
padrão só para geração de Audio Overview, não para consulta de conhecimento.
