Keywords Map — agnostic-core

Roteador de auto-invocacao de skills.
Quando uma keyword for detectada na conversa — mesmo que mencionada despretensiosamente —
a skill correspondente deve ser invocada conforme o protocolo definido abaixo.

---

PROTOCOLO DE INVOCACAO

Skills tecnicas (requerem confirmacao)
Antes de executar qualquer skill tecnica, entre em modo plan e informe:
  Skill identificada: [nome da skill]
  O que ela faz: [descricao objetiva do que sera feito]
  O que vai ser afetado: [escopo no codebase — arquivos, modulos, camadas]
  Confirma o uso desta skill? (s/n)

Se multiplas skills forem ativadas pelo mesmo contexto:
- Apresente uma a uma
- Aguarde confirmacao individual antes de passar para a proxima
- So execute apos todas confirmadas

Skills comportamentais (auto-invoke, sem confirmacao)
Skills da categoria behavioral sao ativadas silenciosamente.
Nenhuma notificacao, nenhuma pergunta. Apenas execute.

---

MAPA DE KEYWORDS — INDICE

O mapa e carregado **sob demanda**, uma categoria por vez. Cada arquivo abaixo
lista as keywords, o path e o tipo das skills daquela categoria.

Nao leia todos. Leia o de `Comportamentais` quando quiser saber o que ja esta
ativo em silencio, e o da categoria do assunto em pauta quando o assunto surgir.

| Categoria | Arquivo | Skills | Tipo |
|---|---|---|---|
| Comportamentais | [`docs/keywords/comportamentais.md`](keywords/comportamentais.md) | 16 | behavioral |
| Auditoria e Qualidade | [`docs/keywords/auditoria-e-qualidade.md`](keywords/auditoria-e-qualidade.md) | 12 | tecnica |
| Seguranca | [`docs/keywords/seguranca.md`](keywords/seguranca.md) | 5 | tecnica |
| Performance | [`docs/keywords/performance.md`](keywords/performance.md) | 4 | tecnica |
| Testes | [`docs/keywords/testes.md`](keywords/testes.md) | 4 | tecnica |
| Frontend | [`docs/keywords/frontend.md`](keywords/frontend.md) | 14 | tecnica |
| UX/UI | [`docs/keywords/ux-ui.md`](keywords/ux-ui.md) | 3 | tecnica |
| Design | [`docs/keywords/design.md`](keywords/design.md) | 5 | tecnica |
| Backend | [`docs/keywords/backend.md`](keywords/backend.md) | 7 | tecnica |
| Banco de Dados | [`docs/keywords/banco-de-dados.md`](keywords/banco-de-dados.md) | 2 | tecnica |
| DevOps | [`docs/keywords/devops.md`](keywords/devops.md) | 7 | tecnica |
| Git | [`docs/keywords/git.md`](keywords/git.md) | 4 | tecnica |
| Documentacao | [`docs/keywords/documentacao.md`](keywords/documentacao.md) | 2 | tecnica |
| Node.js | [`docs/keywords/nodejs.md`](keywords/nodejs.md) | 2 | tecnica |
| Python | [`docs/keywords/python.md`](keywords/python.md) | 2 | tecnica |
| AI / LLM Tecnico | [`docs/keywords/ai-llm-tecnico.md`](keywords/ai-llm-tecnico.md) | 2 | tecnica |
| MCP | [`docs/keywords/mcp.md`](keywords/mcp.md) | 3 | tecnica |
| Plataformas | [`docs/keywords/plataformas.md`](keywords/plataformas.md) | 3 | tecnica |
| Automacao | [`docs/keywords/automacao.md`](keywords/automacao.md) | 3 | tecnica |

Total: 100 skills mapeadas em 19 categorias.
