## Filosofia do Repo — Distribuição Pública + Camada Interna

Este repo tem **duas camadas permanentes**:

### Camada pública (distribuída)
Tudo que está em `skills/`, `agents/`, `commands/`, `docs/`, `templates/`, `scripts/install.*`, `scripts/npx-entry.js` e `scripts/generate-*.sh` **é parte do produto público**.
- Deve ser agnóstico de stack e de autor
- Deve passar em `npm run lint` e `npm run check-refs`
- Deve funcionar para qualquer desenvolvedor que rode `npx agnostic-core@latest init`

### Camada interna do autor (não distribuída)
Scripts pessoais, utilitários de manutenção em massa e automações específicas dos repos do autor ficam em `scripts/internal/` — **gitignored, nunca no tarball npm**.

Exemplos do que vai em `scripts/internal/`:
- `update-all-repos.ps1` — atualiza submodule em todos os projetos locais
- Scripts de deploy em massa, patches por repo, utilitários de ambiente

**Regra:** antes de commitar qualquer script novo em `scripts/`, pergunte:
*"Um usuário externo precisaria disso?"* Se não → `scripts/internal/`.

### Checklist antes de publicar nova versão
1. `npm run lint` passa
2. `npm run check-refs` passa
3. `npm pack --dry-run` não inclui `settings.local.json`, `scripts/internal/` nem arquivos pessoais
4. `CHANGELOG.md` atualizado
5. `package.json` version bumped
6. `npm publish --access public`

---

## Debug Mobile — Padrão Obrigatório

Todo projeto web **DEVE** incluir o Eruda Debug Report.
- Projetos Vite: plugin no `vite.config.ts` (auto em dev, `?debug=true` em prod)
- Outros projetos: script direto no HTML principal
- Inclui aba "Report" para copiar relatório Markdown direto pro Claude Code
- Use a skill `/eruda` para injetar automaticamente

### Projetos que já têm Eruda
- [x] f1-pulse
- [x] SbrTask (Lab-Sobral-Dev)

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

## Convenção Git — Branch e Commits

**Branch principal: `master` em todos os repos.**
- Default branch dos repos paulinett1508-dev e Lab-Sobral-Dev é sempre `master`
- Nunca usar `main` em repos novos
- Repos legados em `main` devem ser renomeados (`git branch -m main master` + `gh repo edit --default-branch master` + `git push origin --delete main`)

**Workflow de mudanças (Claude SEMPRE segue, sem perguntar):**
1. **Repo próprio (paulinett1508-dev) — commit direto em master** quando a mudança é trivial/exploratória (docs, fixes pontuais, ajustes de configuração)
2. **Repo de organização (Lab-Sobral-Dev e outros) — SEMPRE criar branch automática** antes de qualquer commit:
   - Prefixos: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`
   - Nome descritivo curto: `chore/agnostic-core-integration`, `feat/brutal-theme`, `fix/login-a11y`
3. **PR sempre tem `master` como base**
4. **Após push da branch, abrir PR via `gh pr create`** com summary + test plan
5. **Não fazer merge automático** — deixar o usuário decidir

**Auto-push hook (PostToolUse) já push pra branch atual** — funciona para qualquer nome de branch (master ou feature).
