## ⛔ Regra #0 — Nunca design com cara de IA

Regra de topo para qualquer trabalho de frontend/telas/layout **neste repositório**. Ela não é imposta a quem instala o acervo: o `install.sh` usa os modelos neutros de `templates/project-bootstrap/`, não este arquivo. Um projeto consumidor adota a regra espelhando `skills/design/sem-cara-de-ia.md` e copiando este bloco para o próprio `CLAUDE.md` — deliberadamente, não por herança. Dito isso: nenhuma interface pode parecer gerada por IA por omissão de decisão. "Cara de IA" = genericidade (a média de landing pages de SaaS). Skill de referência: `skills/design/sem-cara-de-ia.md`. Proibido por default: gradiente índigo-violeta, Inter-em-tudo, tudo centralizado, 3 cards idênticos, glassmorphism/blobs/glow, cópia de preenchimento, emoji como ícone, badges "AI-Powered". Obrigatório: conteúdo real, paleta e par tipográfico decididos, ponto focal, densidade do domínio, e o "teste da troca". **Obrigatório em todo layout: gerar artefato de preview com 3 opções distintas, cada uma em light E dark, antes de implementar — usuário escolhe primeiro, código depois.** Cerne inspirador: ancorar em sistema consolidado mundialmente (de preferência 90s/2000s) — herdar a lógica da era (proporção, affordance, densidade honesta, restrição de paleta) e modernizar a execução (ícones, tokens, a11y, responsivo).

## Uso deste repo

Este é o **agnostic-core**: acervo de skills, agents e commands em Markdown puro, agnósticos de stack.

- **Skills em `skills/`** são a fonte da verdade — não duplicar em outros formatos.
- **Mudanças em skills existentes** devem preservar linguagem agnóstica: sem amarrar a framework ou linguagem específicos; extrair a parte genérica como regra e a específica como exemplo.
- **Antes de commitar**: `npm run lint` e `npm run check-refs` devem passar.

## Uso de Subagents

- Use subagents para pesquisar boas práticas externas, comparar padrões entre frameworks e analisar skills existentes em paralelo.
- Offload análise de consistência entre skills relacionadas e verificação de duplicação para subagents.
- Para criação de nova categoria de skill: subagent de pesquisa de referências antes de escrever.

## Verificação antes de Concluir

- Nunca marque uma skill como concluída sem verificar: exemplos concretos incluídos, linguagem agnóstica (sem amarrar a stack específica), formatação Markdown consistente com as demais skills.
- Pergunta padrão: *"Um desenvolvedor de qualquer stack conseguiria aplicar isso no próprio projeto?"*
- Confirmar que a nova skill está referenciada em `docs/skills-index.md`.

## Elegância (features não-triviais)

- Para skills que cobrem 3+ conceitos distintos: pause e avalie se deve ser dividida em skills menores.
- Se uma skill está prescritiva demais para uma stack específica: extrair a parte genérica como regra e a específica como exemplo.
- **Exceção:** adições pontuais de exemplos ou referências — não reestruturar uma skill inteira por um detalhe.

## Convenção Git

- Branch principal: `master`.
- Commits seguem [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`.
- PRs têm `master` como base, com summary + test plan.

## Princípios básicos

- **Simplicidade primeiro**: faça cada mudança em uma skill a mais simples possível; evite reescrever a skill inteira por um detalhe.
- **Sem previsão**: encontre causas-raiz; sem fixes temporários para passar lint/check-refs; padrões de dev sênior.
- **Impacto mínimo**: toque apenas no que é necessário; sem efeitos colaterais que quebrem skills relacionadas.

## Modo de Output

**Caveman ativo por padrão em toda sessão.**

O que isso significa:
- Respostas diretas e densas — sem introduções, sem conclusões, sem repetição de contexto
- Frases curtas. Código > explicação. Decisão > raciocínio exposto.
- Análise pode ser profunda internamente; o que aparece no output é só o essencial.
- Modos cognitivos (steelman, red team, etc.) são ortogonais: pensamento aprofundado, output comprimido.

Para desativar: `modo normal` | `full output` | `sem caveman`
→ Execute: `echo normal > .claude/output-mode`

Para reativar: `caveman` | `comprimir` | `modo comprimido`
→ Execute: `echo caveman > .claude/output-mode`

O status line do Claude Code reflete o modo ativo da sessão.

## Auto-invocação de skills

Este projeto usa agnostic-core. `docs/keywords-map.md` é o **índice** (protocolo +
tabela de categorias); o mapa em si vive fatiado em `docs/keywords/<categoria>.md`.

Regras:
- Leia o índice `docs/keywords-map.md` no início da sessão — ele é curto de propósito
- Leia `docs/keywords/comportamentais.md` para saber o que está ativo em silêncio
- As demais categorias são **sob demanda**: abra a do assunto quando o assunto surgir,
  não todas de uma vez
- Skills técnicas: entre em plan mode e aguarde confirmação antes de executar
- Skills behavioral: ative silenciosamente, sem notificação

## Roteamento de modelo (agnostic-router)

Este repo dogfooda a própria skill `skills/ai/agnostic-router.md`. Em sessão interativa,
resolva o tier pela FASE de trabalho (explore/design/implement/debug/review/operate),
não por keyword, e declare no início da resposta: `[router: <tier> | fase=<fase>]`.
Reavalie a cada turno; debug travado (≥2 turnos no mesmo erro) → escalar. Motor de
referência: `scripts/agnostic-router/router.py`.

## MCPs Disponíveis

**NotebookLM (`gemini-notebook-mcp`)** — base de conhecimento curada, notebook "agnostic-core". Consultar (`ask_question`) só para contexto de arquitetura/decisão de design/histórico que não esteja evidente lendo o arquivo direto (ex.: "por que a Regra #0 existe") — nunca para achar uma skill específica ou dúvida de conteúdo atual (`grep`/`Read` resolve mais rápido e sem risco de resposta desatualizada). Código/skills no repo são sempre a fonte de verdade; se o notebook divergir, sinalizar e propor atualizar — nunca editar skill pra obedecer notebook desatualizado. Atualizar só em skill nova relevante ou decisão de arquitetura significativa, nunca por commit trivial. Instrução explícita sua sempre prevalece sobre esse roteamento automático. Pergunta sobre histórico/autoria/commits/PRs → Git/GitHub, não NotebookLM. Detalhes: [`docs/references/notebooklm-knowledge-base.md`](docs/references/notebooklm-knowledge-base.md).
