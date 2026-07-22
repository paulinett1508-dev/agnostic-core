Commit Conventions

Objetivo: Padronizar commits com Conventional Commits para gerar changelogs automaticos, facilitar code review e manter historico legivel.

---

FORMATO

  <type>(<scope>): <descricao em imperativo>

  [corpo opcional]

  [rodape opcional: BREAKING CHANGE, Closes #issue]

Exemplos:
  feat(auth): adicionar autenticacao via OAuth Google
  fix(api): corrigir status 500 ao deletar usuario inexistente
  docs(readme): atualizar instrucoes de instalacao
  refactor(cartService): extrair calculo de desconto para helper
  test(auth): adicionar cenarios de token expirado
  chore(deps): atualizar express para 4.19.2
  ci(actions): adicionar job de lint no pipeline de PR
  perf(queries): adicionar index em orders.userId

---

TIPOS

| Tipo | Quando usar |
|---|---|
| feat | Nova funcionalidade visivel ao usuario |
| fix | Correcao de bug |
| docs | Apenas documentacao (README, JSDoc, ADR) |
| style | Formatacao sem mudanca de logica (prettier, whitespace) |
| refactor | Mudanca de codigo sem nova feature nem bug fix |
| test | Adicionar ou corrigir testes |
| chore | Manutencao: deps, configs, gitignore |
| ci | Mudancas em CI/CD (GitHub Actions, Dockerfile, scripts) |
| perf | Melhoria de performance sem mudanca de comportamento |
| revert | Reverte commit anterior (referenciar hash) |

Regras de tipo:
- [ ] Um unico tipo por commit
- [ ] `feat` implica que o usuario percebe a mudanca — nao usar para codigo interno
- [ ] `fix` tem issue ou reproducao documentada no corpo ou rodape
- [ ] `chore` nunca afeta runtime da aplicacao

---

ESCOPO

O escopo e opcional mas recomendado. Indica o modulo ou area afetada:

  feat(auth): ...      → modulo de autenticacao
  fix(checkout): ...   → fluxo de checkout
  docs(api): ...       → documentacao de API
  test(user): ...      → testes do modulo de usuario

Convencao de escopo para este projeto:
- [ ] Definir lista de escopos validos no CONTRIBUTING.md
- [ ] Usar nome da pasta ou modulo: `auth`, `user`, `order`, `db`, `infra`, `ui`

---

DESCRICAO

- [ ] Imperativo: "adicionar", "corrigir", "remover" — nao "adicionando", "adicionei"
- [ ] Minusculo, sem ponto final
- [ ] Maximo 72 caracteres na primeira linha
- [ ] Em portugues (ou idioma do time — definir no CONTRIBUTING.md)

  Bom:  feat(auth): adicionar refresh token com rotacao automatica
  Ruim: feat(auth): Added refresh token with automatic rotation.
  Ruim: feat(auth): Adicionando refresh token

---

CORPO E RODAPE

Corpo (quando necessario):
  Explica o POR QUE, nao o que — o diff ja mostra o que.
  Use quando a mudanca nao e obvie ou tem contexto importante.

  fix(auth): corrigir expiração de token em timezone diferente

  Tokens eram validados com Date.now() sem conversão para UTC,
  causando expiração prematura em servidores fora de UTC-3.
  Corrigido para usar Date.UTC() consistentemente.

  Closes #142

Rodape:
  - Closes #123 / Fixes #123 — fecha issue automaticamente no GitHub
  - BREAKING CHANGE: descricao — obrigatorio para breaking changes
  - Co-authored-by: Nome <email> — para pair programming

---

BREAKING CHANGES

- [ ] Adicionar `!` apos o tipo: `feat(api)!: remover campo legado userId`
- [ ] Adicionar rodape `BREAKING CHANGE: descricao detalhada`
- [ ] Documentar migration path no corpo do commit

  feat(api)!: substituir userId por userUuid em todos os endpoints

  BREAKING CHANGE: campo userId removido. Use userUuid (formato UUID v4).
  Clientes devem atualizar requests e parsers de response.
  Migration: buscar userId antigo com GET /users/legacy/{userId}

---

CONFIGURACAO (commitlint + husky)

Instalar:
  npm install --save-dev @commitlint/cli @commitlint/config-conventional husky

commitlint.config.js:
  module.exports = { extends: ['@commitlint/config-conventional'] }

.husky/commit-msg:
  npx --no -- commitlint --edit $1

Ativar husky:
  npx husky init

---

TROUBLESHOOTING: CRLF QUEBRA HOOKS HUSKY

Sintoma: `git commit` falha com `Missing script: <nome>` ou `command not found`,
mesmo com o script existindo em `package.json`/`node_modules/.bin`.

Causa: `.husky/<hook>` (ex. `pre-commit`) foi checkado com terminação de linha
CRLF (comum em pastas sincronizadas com um ambiente Windows — OneDrive, unidade
de rede, WSL apontando pra um mount `/mnt/c/...`). O dispatcher do husky roda o
hook via `sh -e`, que não normaliza `\r` — o `\r` final vira parte do último
argumento do comando (`lint-staged\r`), quebrando a resolução do script.

Diagnóstico:
  cat -A .husky/pre-commit   # ^M no fim da linha = CRLF

Fix (não é só reescrever o arquivo — git pode reintroduzir CRLF no próximo
checkout se o mount/sync continuar tocando o arquivo por fora do git):
  # 1. Reescrever com LF puro
  printf 'pnpm run lint-staged\n' > .husky/pre-commit

  # 2. Forçar LF permanentemente via .gitattributes (raiz do repo)
  echo '.husky/pre-commit text eol=lf' >> .gitattributes
  git add --renormalize .gitattributes .husky/pre-commit

Sem o passo 2, o bug volta silenciosamente a cada novo checkout/clone nesse
tipo de ambiente.

---

CHECKLIST PRE-COMMIT

- [ ] Tipo correto para a mudanca
- [ ] Descricao em imperativo, minusculo, sem ponto final
- [ ] Escopo informado para mudancas em modulo especifico
- [ ] Breaking changes documentadas com `!` e rodape
- [ ] Issues referenciadas no rodape quando aplicavel
- [ ] Commit atomico: uma mudanca logica por commit (nao misturar feat + fix)
