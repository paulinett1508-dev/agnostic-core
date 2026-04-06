## Debug Mobile — Padrão Obrigatório

Todo projeto web **DEVE** incluir o Eruda Debug Report.
- Projetos Vite: plugin no `vite.config.ts` (auto em dev, `?debug=true` em prod)
- Outros projetos: script direto no HTML principal
- Inclui aba "Report" para copiar relatório Markdown direto pro Claude Code
- Use a skill `/eruda` para injetar automaticamente

### Projetos que já têm Eruda
- [x] f1-pulse

### Projetos pendentes
- [ ] sbr-monorepo
- [ ] AlgodaoAtelie
- [ ] SuperCartolaManagerv5-production
- [ ] sicefsus-sistema
- [ ] joguinhos-jose
- [ ] SBR-ocomon-5.0
- [ ] temperodemamae
- [ ] pedidomobile
- [ ] agnvendas-painelsbr
- [ ] florianorun
- [ ] CertiSYS
- [ ] FinanceFlow
- [ ] banana-prompts-firebase
- [ ] CRM-SBR

## Uso de Subagents

- Use subagents para pesquisar boas práticas externas, comparar padrões entre frameworks e analisar skills existentes em paralelo
- Offload análise de consistência entre skills relacionadas e verificação de duplicação para subagents
- Para criação de nova categoria de skill: subagent de pesquisa de referências antes de escrever

## Verificação antes de Concluir

- Nunca marque uma skill como concluída sem verificar: exemplos concretos incluídos, linguagem agnóstica (sem amarrar a stack específica), formatação Markdown consistente com as demais skills
- Pergunta padrão: *"Um desenvolvedor de qualquer stack conseguiria aplicar isso no próprio projeto?"*
- Confirmar que a nova skill está referenciada em `docs/skills-index.md`

## Elegância (features não-triviais)

- Para skills que cobrem 3+ conceitos distintos: pause e avalie se deve ser dividida em skills menores
- Se uma skill está prescritiva demais para uma stack específica: extrair a parte genérica como regra e a específica como exemplo
- **Exceção:** adições pontuais de exemplos ou referências — não reestruturar uma skill inteira por um detalhe
