CSS Governance (Anti-Frankenstein)

Objetivo: Prevenir CSS Frankenstein — codigo que duplica o que ja existe, ignora tokens de design, viola convencoes e acumula divida tecnica.

Quando usar:
- ANTES de criar ou modificar qualquer arquivo CSS (checklist preventivo)
- Code review de PRs com mudancas de estilo
- Auditoria de base de codigo frontend existente
- Ao integrar novo membro ao time de frontend

Regras Absolutas (Zero Tolerancia)

R1 - Nunca criar arquivo CSS sem verificar o que ja existe
- [ ] Busquei no projeto se ja existe CSS para este conceito
- [ ] Se existe: editei o arquivo existente (nao criei um novo)
- [ ] Se criei arquivo novo: ha justificativa valida (novo modulo, nova pagina)

R2 - Nunca usar cor hardcoded
- [ ] Todas as cores usam variaveis CSS (var(--nome-do-token))
- [ ] Sem #hex, rgb(), rgba() diretamente nos valores
- [ ] Se o token nao existe: criei o token primeiro, depois usei var()

R3 - Nunca duplicar animacoes definidas globalmente
- [ ] Verifiquei se @keyframes ja existe no arquivo de tokens/global
- [ ] Se existe: referenciei pelo nome (animation: fade-in 0.3s ease)
- [ ] Nao redefinir keyframes identicos em arquivos de modulos

R4 - Nunca usar inline styles em HTML
- [ ] Sem atributo style="" em elementos HTML
- [ ] Excecao unica: elementos criados dinamicamente via JS com classe single-use
- [ ] Substituido por classe CSS com nome semantico

R5 - Nunca duplicar seletores entre arquivos
- [ ] Busquei se .nome-da-classe ja existe em outro arquivo
- [ ] Se existe: reusei ou criei modificador (.componente--variante) no arquivo correto
- [ ] Sem copiar/colar blocos de CSS de outro arquivo

R6 - Escopo de seletores em modulos SPA
- [ ] CSS de componentes/modulos carregados dinamicamente usa prefixo do modulo
- [ ] Seletores genericos (h1, p, button) escopados ao modulo (.modulo-nome h1)
- [ ] CSS de paginas standalone pode usar seletores globais

Checklist de 5 Pontos (rodar antes de qualquer mudanca CSS)

CHECK 1 - Ja Existe?
- [ ] Busquei por arquivos CSS existentes para este conceito
- [ ] Busquei pela classe ou seletor que vou criar
- [ ] Verificado: nao existe duplicata

CHECK 2 - Onde Vive?
- [ ] Identifiquei o arquivo CSS correto para esta mudanca
- [ ] Mudancas de escopo global → arquivo global/tokens
- [ ] Mudancas de modulo especifico → arquivo do modulo

CHECK 3 - Usa Tokens?
- [ ] Todas as cores via var(--color-*)
- [ ] Espacamentos via var(--space-*)
- [ ] Fontes via var(--font-family-*)
- [ ] Sombras via var(--shadow-*)
- [ ] Bordas via var(--radius-*)
- [ ] Transicoes via var(--transition-*)

CHECK 4 - Segue Convencoes?
- [ ] Nome de arquivo em kebab-case
- [ ] Comentario no topo do arquivo (nome, proposito, dependencia)
- [ ] Sem !important (exceto override de biblioteca terceira)
- [ ] Media queries usando breakpoints dos tokens (nao valores magicos)
- [ ] Seletores escopados se modulo SPA

CHECK 5 - E Necessario?
- [ ] Nao e um ajuste que poderia ir no arquivo existente
- [ ] Tem volume suficiente para justificar arquivo proprio (>50 linhas)
- [ ] Nao e uma preferencia pessoal de organizacao

Red Flags (Deteccao Rapida)
- style="" em HTML → CRITICO
- #hex ou rgba() sem var() → CRITICO
- @keyframes identico ao global redefinido → ALTO
- Seletor .btn {} sem escopo em SPA → MEDIO
- !important no CSS do modulo → MEDIO
- font-family sem var() → MEDIO
- Novo arquivo CSS sem justificativa → ALTO

Ferramentas
- Busca de seletor existente: grep -rn "\.nome-da-classe" src/
- Deteccao de cor hardcoded: grep -rn "#[0-9a-fA-F]\{3,8\}" src/css/
- CSS lint: npx stylelint "**/*.css"
- Design tokens: ver arquivo de tokens do projeto

Referencias
- https://bradfrost.com/blog/post/atomic-web-design/
- https://www.smashingmagazine.com/2021/02/css-custom-properties-design-systems/
- BEM methodology: https://getbem.com/
