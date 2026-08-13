# CSS Governance (Anti-Frankenstein)

Previne CSS Frankenstein — código que duplica o que já existe, ignora tokens de design,
viola convenções de escopo e acumula dívida técnica invisível. Use como auto-revisão antes
de commitar qualquer mudança de estilo, ou como critério de aprovação em code review de
frontend.

---

## Checklist de 5 Pontos

CHECK 1 - Já Existe?
- [ ] Busquei por arquivos CSS existentes para este conceito
- [ ] Busquei pela classe, animação ou variável que vou criar
- [ ] Verificado: não existe duplicata (seletor, `@keyframes`, token)

CHECK 2 - Onde Vive?
- [ ] Identifiquei o arquivo CSS correto para esta mudança
- [ ] Mudanças de escopo global → arquivo global/tokens
- [ ] Mudanças de módulo específico → arquivo do módulo (não copiei/colei de outro arquivo)

CHECK 3 - Usa Tokens?
- [ ] Cores via `var(--color-*)` — sem `#hex` ou `rgb()`/`rgba()` diretamente
- [ ] Espaçamentos via `var(--space-*)` — sem `px` mágico
- [ ] Fontes via `var(--font-family-*)` — sem `font-family` literal
- [ ] Sombras via `var(--shadow-*)`, bordas via `var(--radius-*)`, transições via `var(--transition-*)`
- [ ] Se o token não existe: criei o token primeiro, depois usei `var()`

CHECK 4 - Segue Convenções?
- [ ] Nome de arquivo em kebab-case; comentário no topo (propósito, dependência)
- [ ] Sem `!important` (exceto override documentado de biblioteca terceira)
- [ ] Sem `style=""` em HTML (exceção: elemento criado 100% via JS com classe descartável)
- [ ] Media queries usando breakpoints dos tokens, não valores mágicos
- [ ] CSS de componente/módulo SPA tem prefixo ou escopo adequado; seletores genéricos
      (`h1`, `button`) não vazam pra fora do módulo — CSS de página standalone pode usar
      seletores globais

CHECK 5 - É Necessário?
- [ ] Não é um ajuste que poderia ir no arquivo existente
- [ ] Tem volume suficiente para justificar arquivo próprio (>50 linhas)
- [ ] Não é uma preferência pessoal de organização

---

## Sinais de Alerta em Code Review

Se qualquer um dos itens abaixo aparecer no diff, investigar antes de aprovar:

```
style=""               → inline style em HTML
#[0-9a-fA-F]{3,8}      → cor hardcoded sem var()
rgba?\(                 → cor hardcoded sem var()
@keyframes              → verificar se já existe globalmente
!important              → problema de especificidade ou override indevido
font-family:            → verificar se usa var(--font-family-*)
```

---

## O que Não é Frankenstein (Exceções Válidas)

- `style=""` em elementos criados 100% via JavaScript com classe descartável
- `!important` documentado para override de biblioteca de terceiro (ex: react-datepicker)
- Arquivo CSS novo com justificativa clara e volume suficiente
- `rgba()` em valor de fallback para browsers antigos (com `var()` principal)

---

## Ferramentas de Verificação Rápida

```bash
# Buscar seletor existente antes de criar novo
grep -rn "\.nome-da-classe" src/

# Detectar cores hardcoded
grep -rn "#[0-9a-fA-F]\{3,8\}" src/css/
grep -rn "rgba\?\(" src/css/

# Buscar inline styles em HTML/JSX
grep -rn 'style="' src/components/
grep -rn 'style={{' src/components/   # JSX

# Verificar !important
grep -rn "!important" src/css/

# CSS lint
npx stylelint "**/*.css"
```

---

## Referências

- https://bradfrost.com/blog/post/atomic-web-design/
- https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Cascading_variables/Using_custom_properties
- BEM methodology: https://getbem.com/
