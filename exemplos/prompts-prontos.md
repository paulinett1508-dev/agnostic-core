# Prompts de exemplo

Exemplos de como usar as ideias do acervo em ferramentas de IA como Claude Code, Cursor,
GitHub Copilot ou qualquer assistente com suporte a contexto.

Adapte conforme o caminho real das skills no seu ambiente.

---

## Segurança

```
Revise os arquivos em src/routes/ e src/controllers/ consultando as ideias em
.agnostic-core/skills/security/api-hardening.md.
Liste o que for relevante para este projeto.
```

```
Usando .agnostic-core/skills/security/owasp-checklist.md como referência,
avalie os pontos que se aplicam a esta API.
```

---

## Frontend

```
Analise os arquivos CSS em src/styles/ considerando as ideias de governança em
.agnostic-core/skills/frontend/css-governance.md.
```

```
Revise os componentes em src/components/ com base nas ideias de
.agnostic-core/skills/ux-ui/principios-de-interface.md.
```

---

## Design sem cara de IA (obrigatório em todo layout)

Prompt robusto para qualquer assistente com suporte a contexto. Cole e preencha os
`[placeholders]`. Ele força o protocolo completo da skill: conteúdo real → cerne
inspirador → 3 opções em light/dark no preview → escolha → só então implementação.

```
Objetivo: projetar [TELA/LANDING/DASHBOARD/COMPONENTE] para [PRODUTO] no domínio de
[DOMÍNIO], para [USUÁRIO-ALVO].

Regra inegociável: siga .agnostic-core/skills/design/sem-cara-de-ia.md do início ao fim.
Nada pode ter "cara de IA" (genericidade por omissão de decisão). NÃO comece a codar
a tela final antes de eu escolher uma opção no preview.

Antes de qualquer markup, responda o Protocolo pré-flight:
1. Conteúdo real desta tela (textos, dados, telas verdadeiras — sem lorem/filler).
2. Restrição de cor (neutros + no máx. 2 cores de marca; PROIBIDO gradiente índigo-violeta default).
3. Ponto de vista tipográfico (par display + texto, e a escala).
4. Cerne inspirador: nomeie um sistema consolidado mundialmente (de preferência 90s/2000s)
   cuja LÓGICA será herdada (proporção, affordance, densidade honesta, restrição de paleta),
   com execução modernizada (ícones vetoriais, tokens de tema, acessibilidade, responsivo).
5. Onde está o ponto focal / a assimetria.
6. Densidade apropriada ao domínio.

Depois, gere UM artefato de preview (HTML self-contained, sem dependências externas) com:
- 3 opções de design genuinamente distintas — cada uma herdando um cerne consolidado
  diferente e indicando qual é. Não são 3 variações de cor da mesma ideia.
- Cada opção renderizada em tema CLARO e ESCURO (toggle ou exibição pareada), via tokens
  (prefers-color-scheme + override), nunca cor hardcoded.
- Conteúdo de exemplo plausível do domínio, aparência real (não descrição textual).
- Acessibilidade: contraste WCAG AA, foco visível, alvos de toque adequados.

Aplique o "teste da troca" em cada opção: se trocar logo/texto/domínio não faz o design
protestar, refaça — está genérico.

Só depois que eu escolher uma das 3 opções, implemente-a de verdade no projeto,
consultando .agnostic-core/skills/frontend/css-governance.md,
.agnostic-core/skills/frontend/css-governance.md e
.agnostic-core/skills/frontend/accessibility.md durante a implementação.
```

Variante curta (quando o contexto do projeto já está carregado):

```
Aplique .agnostic-core/skills/design/sem-cara-de-ia.md para [TELA] de [PRODUTO].
Gere o artefato de preview obrigatório: 3 opções distintas (cada uma herdando um cerne
consolidado 90s/2000s + execução moderna), todas em light E dark. Sem cara de IA.
Aguarde minha escolha antes de implementar.
```

---

## Banco de dados

```
Revise as queries em src/repositories/ consultando
.agnostic-core/skills/database/query-compliance.md.
```

---

## Performance

```
Analise src/services/ em busca de oportunidades de melhoria.
Use .agnostic-core/skills/performance/performance-audit.md como referência.
```

```
Avalie as estratégias de cache do projeto considerando as ideias em
.agnostic-core/skills/cache/estrategias-de-cache.md.
```

---

## Revisão de código

```
Revise o PR consultando .agnostic-core/skills/audit/code-review.md.
Identifique o que for relevante para este contexto.
```

---

## Agents

```
Atue como o padrão de agent descrito em
.agnostic-core/agents/reviewers/security-reviewer.md
e analise os arquivos em src/.
```

```
Use o padrão em .agnostic-core/agents/reviewers/code-inspector.md
para inspecionar src/services/pagamento.js.
```

---

## Design com Paper MCP

```
Atue como o padrão de agent descrito em .agnostic-core/agents/generators/ui-designer.md
Consulte .agnostic-core/skills/design/paper-mcp-workflow.md para referência das ferramentas.

Crie uma tela de [DESCRIÇÃO DA TELA] no projeto Paper: [LINK DO PROJETO]
```

```
Com base no design no projeto Paper: [LINK DO PROJETO]
implemente o artboard "[NOME DO ARTBOARD]" como [React/Vue/HTML+CSS].

Consulte .agnostic-core/skills/frontend/html-css-audit.md e
.agnostic-core/skills/ux-ui/principios-de-interface.md durante a implementação.
Respeite cores, tipografia, espaçamentos e hierarquia visual do design.
```

---

## Automação e MCP

```
Consulte .agnostic-core/skills/automacao/automacoes-uteis.md
e sugira automações que façam sentido para o setup atual do projeto.
```

```
Leia .agnostic-core/skills/mcp/ideias-de-mcp.md e avalie
quais MCPs poderiam beneficiar o fluxo de desenvolvimento deste projeto.
```
