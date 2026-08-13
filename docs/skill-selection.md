# Seleção de skills — catálogo compacto

`metadata/skills.catalog.json` é um índice gerado (não escrito à mão) com metadados
de cada skill em `skills/`: `path`, `category`, `tipo`, `tags`, `summary`, `related`
(quando a skill tem uma seção `## Skills Relacionadas` explícita) e
`superpowers_equivalent` (quando `docs/precedencia-de-skills.md` já mapeia a skill
equivalente do plugin).

## Por quê

Selecionar skills pra um projeto consumidor (ex.: "quais skills preciso pra uma API
NestJS com JWT, Redis, Docker e CI/CD?") não exige abrir os 112 arquivos de
`skills/` nem consultar um MCP externo — o catálogo já responde "quais são
candidatas" em uma leitura de ~poucos KB. Abrir o Markdown completo fica reservado
pras 3–8 skills que sobrarem depois do filtro.

Isso é diferente do papel do NotebookLM (`skills/mcp/notebooklm-harness.md`):
o catálogo resolve "quais skills existem e são candidatas" (mecânico, sem
síntese); o NotebookLM resolve pergunta de arquitetura/histórico sobre o acervo
como um todo (ver `docs/references/notebooklm-knowledge-base.md`). Um não substitui
o outro.

## Como usar (Claude Code ou qualquer agente)

1. Ler `metadata/skills.catalog.json` (JSON compacto, cabe inteiro no contexto).
2. Filtrar por `tags`/`category` batendo com a stack e as features do projeto atual.
3. Abrir (`Read`) só as skills candidatas — não o acervo inteiro.
4. Conferir `related` das candidatas abertas — pode revelar uma skill complementar
   que o filtro de tags sozinho não pegaria.
5. Se uma candidata aparecer em `superpowers_equivalent` e o projeto usa o plugin
   `superpowers`, aplicar a precedência de `docs/precedencia-de-skills.md` (a do
   plugin ganha) em vez de instalar as duas.
6. Traduzir a escolha final em padrões no `.agnostic-skills` do projeto consumidor
   (`docs/skills-index.md` documenta a sintaxe).

## Regenerar o catálogo

```bash
node scripts/build-skill-catalog.js
# ou
npm run build-catalog
```

Rodar depois de: adicionar/remover skill em `skills/`, editar `docs/keywords/*.md`,
editar `docs/precedencia-de-skills.md`, ou adicionar/editar uma seção
`## Skills Relacionadas` em alguma skill. O script não inventa tag, dependência ou
conflito que não esteja em alguma dessas três fontes — uma skill sem cobertura em
`docs/keywords/` sai do catálogo com `tags: []` e `summary` extraído direto do
primeiro parágrafo do próprio arquivo (nunca fabricado).

## Limitações conhecidas

- **Cobertura parcial de tags:** 12 das 112 skills (majoritariamente
  `behavioral`/`workflow`, invocadas por instrução direta, não por keyword) não
  têm entrada em `docs/keywords/*.md` — ficam no catálogo com `tags: []`. Não é bug,
  é reflexo de não precisarem de roteamento por palavra-chave.
- **`related` é conservador:** só existe quando o próprio arquivo já documentava a
  relação (9 de 112 skills hoje). Não há grafo de dependência transitiva nem
  detecção automática de sobreposição semântica — isso seria trabalho de síntese
  (bom candidato pra uma consulta pontual ao NotebookLM, materializada de volta
  aqui depois, não um processo automático rodando a cada geração).
- **Escopo é `skills/`.** `agents/`, `commands/`, `templates/` não entram no
  catálogo — são selecionados por categoria funcional (reviewer/generator/
  validator/specialist), não por stack, e a lista já cabe inteira em
  `docs/skills-index.md`.
