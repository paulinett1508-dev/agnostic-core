# NotebookLM — Base de Conhecimento Curada

## O que é

Notebook Google NotebookLM (`gemini-notebook-mcp`) com cópia curada de todo o acervo — skills, agents, commands, docs — deste repositório. Não é código, não substitui o repo.

- **Nome:** agnostic-core
- **ID local:** `48518cc5-b169-40b6-adfc-ed8b07077c05`
- **Google notebook id:** `c127038c-1321-4ed3-8c31-30ad0231657c`
- **Conteúdo (188 fontes, 183 saudáveis):** README/CLAUDE.md/CONTRIBUTING/ONBOARDING/CHANGELOG, `docs/*.md` (incluindo as 19 categorias de `docs/keywords/`), todos os `skills/*.md` (118), `agents/*.md` (17), `commands/*.md` (7), `templates/*.md` (4), `exemplos/*.md` (2) — praticamente o acervo inteiro, porque aqui o "produto" do repo são os próprios arquivos de skill, não código de implementação separado.
- **Deliberadamente fora:** nada foi excluído por padrão desta curadoria — decisão explícita do usuário de curar tudo, dado que o repo já é 100% documentação/skills (ver decisão registrada abaixo).
- **Fontes conhecidas com falha (2, aceitas como gap permanente):**
  - `skills/backend/error-handling.md` — 3 entradas fantasma em `status: "error"`, sem card na UI real do NotebookLM (não contam contra cota, nada a apagar).
  - `docs/skills-index.md` — 2 entradas travadas em `status: "indexing"` por horas (não é lentidão normal — NotebookLM indexa em 5-30s). Retry único já tentado (política: nunca mais de 1 retry), sem sucesso.
  - Em ambos os casos o conteúdo real está no arquivo do repo — ler direto quando precisar; não é fonte de comportamento atual mesmo quando funciona.

## Hierarquia de fontes de verdade

| Fonte | Autoridade sobre |
|---|---|
| **Código local + testes** | Comportamento ATUAL do sistema — sempre vence em caso de conflito |
| **Git/GitHub** | Histórico, autoria, branches, commits, issues, PRs |
| **NotebookLM** | Arquitetura, regra de negócio, decisões e contexto curados — não é fonte de comportamento atual |
| **CLAUDE.md + skills** | Instruções de como o agente deve trabalhar neste repo |

**Conflito NotebookLM × código:** o código local é autoritativo. Sinalizar a divergência ao usuário e propor atualizar a doc/notebook — nunca alterar código pra obedecer documentação desatualizada. Como este acervo é só Markdown (skills são o próprio "código"), divergência aqui tende a ser skill desatualizada vs. skill atual no repo — mesma regra: o arquivo no repo vence, o notebook é o que fica pra trás.

## Quando consultar (`ask_question`)

Só quando a pergunta exigir contexto de **arquitetura, decisão de design ou histórico** que não esteja evidente lendo o arquivo direto — ex.: "por que a Regra #0 existe", "que skills foram consolidadas e por quê", "resumo arquitetural do acervo pra alguém novo".

**Não consultar** para: encontrar uma skill específica (`grep`/`Read` é mais rápido e mais confiável), dúvida sobre o conteúdo atual de um arquivo (ler o arquivo, não perguntar ao notebook uma cópia que pode estar desatualizada), tarefas simples de edição.

## Quando atualizar o notebook

Adicionar/atualizar fonte só em: skill nova relevante, consolidação/reestruturação significativa, decisão de arquitetura documentada (ex.: nova regra dura tipo Regra #0), correção cuja causa deva ser lembrada no futuro.

**Nunca** por: commit trivial, fix de link, ajuste de formatação, typo. O notebook não é espelho de cada alteração — é curadoria, não backup. Atualização é sempre manual e revisada (sem hook automático).
