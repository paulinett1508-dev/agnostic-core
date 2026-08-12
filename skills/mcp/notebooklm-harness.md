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

- MCP `gemini-notebook-mcp` acessível (ferramentas `notebook_*`, `source_*`, `research_*`).
- Projeto já tem um arquivo de instrução do agente (`CLAUDE.md`/`AGENTS.md`) e, idealmente, uma pasta de documentação de referência (`docs/references/`, `docs/architecture/` ou equivalente) — reaproveitar a convenção existente, não inventar uma nova.

---

## Passo 1 — Autenticação

`nlm login` autentica via Chrome. Se falhar com `FileExistsError`/"Acesso negado" ao criar a pasta de perfil (`~/.notebooklm-mcp-cli/profiles` no Windows): é ACL restritiva na pasta, não um bug do MCP. Fix: pedir ao usuário pra deletar a pasta manualmente numa sessão **elevada** (Administrador) — comandos read-only não elevados (`Remove-Item`, `takeown`) falham mesmo rodando como o próprio usuário dono. Depois de deletada, `nlm login` recria do zero.

Nunca tente rodar comandos de administrador sozinho nem peça pro usuário desabilitar UAC — é ação do usuário, fora do alcance do agente.

## Passo 2 — Criar o notebook

`notebook_create(title=...)` com nome descritivo do projeto (não genérico tipo "docs" ou "notas"). Um notebook por projeto, não um notebook compartilhado entre vários — mistura contexto de domínios diferentes na hora da consulta.

Repositório privado no GitHub **não pode** virar fonte via `source_type=url` diretamente (o NotebookLM busca a URL sem autenticação e recebe 404) — precisa virar fontes de texto/arquivo curadas manualmente (Passo 3).

## Passo 3 — Curadoria de fontes

Curadoria é o trabalho real desta skill — não é "jogar o repo inteiro pra dentro".

**Incluir:** README, arquivo de instrução do agente, docs de arquitetura, docs de referência/guias operacionais vigentes, regras de negócio (configs declarativos de módulos/features), manifests de dependência (`package.json` e equivalentes), arquivos de infraestrutura (Dockerfile, compose, scripts de deploy), `.env.example` (nunca `.env` real), lições aprendidas / histórico de decisões, e auditorias/investigações já validadas quando o usuário confirmar que quer esse histórico (pedir explicitamente antes de assumir — auditorias tendem a ser volumosas).

**Excluir por padrão:** código-fonte de implementação (fica no repo, não precisa de cópia), artefatos de sessão (planos, specs de feature pontual, PRDs individuais — múltiplos aos dezenas/centenas em projetos ativos), documentação já marcada como deprecated/arquivada, lockfiles, backups, dumps de dados, qualquer coisa com segredo (mesmo que "só" seria um `.env` com valor real). Declarar a lista de exclusão explicitamente ao usuário antes de rodar — sujeito a correção dele (ex.: usuário pode pedir pra incluir auditorias que você tinha excluído por padrão).

**Restrição de formato:** `source_type=file` só aceita uma lista fixa de extensões (documentos comuns, imagens, áudio/vídeo — checar a lista exata na ferramenta disponível). `.json`, `.yml`, scripts sem extensão de texto reconhecida, etc. **não podem** ser upload direto — precisam virar `source_type=text` com o conteúdo lido e colado, com título = caminho relativo do arquivo original. Resumir/estruturar o conteúdo em vez de colar bruto quando o arquivo for muito verboso (ex.: um JSON de config longo vira um parágrafo descritivo do que ele configura, não o JSON literal).

**Execução em lote:** disparar as chamadas de `source_add` em paralelo (múltiplas por mensagem) em vez de uma por vez — a curadoria costuma envolver dezenas de arquivos.

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

1. `notebook_describe` (ou query simples) confirma que as fontes foram ingeridas e o resumo reflete o conteúdo esperado.
2. Uma consulta de teste pedindo resumo arquitetural retorna resposta com citações às fontes corretas (`sources_used`) — sinal de que a curadoria capturou o que importa.
3. Simular um conflito real conhecido do projeto (ex.: uma regra documentada que diverge do código) e confirmar que a resposta da consulta identifica a divergência em vez de apresentá-la como verdade única.
4. Revisar o parágrafo adicionado ao `CLAUDE.md`/`AGENTS.md`: alguém que não participou da sessão consegue, só lendo aquele trecho, saber quando consultar o notebook e o que fazer em caso de conflito?

## Notebooks grandes (50+ fontes)

Consultas em notebooks com muitas fontes podem estourar timeout síncrono. Usar o fluxo assíncrono (`*_start` + polling de status) em vez do síncrono, e aguardar via processo em background em vez de sleeps sequenciais bloqueantes.
