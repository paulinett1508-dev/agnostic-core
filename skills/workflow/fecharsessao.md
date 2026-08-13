# /fecharsessao — Encerramento robusto de sessão

Executa auditoria completa, empacota o estado da sessão e garante zero limbo.
Invoque com `/fecharsessao` antes de encerrar qualquer sessão de trabalho.

---

## Sequência obrigatória (executar na ordem)

### 1. Auditoria Git — repo em evidência

```bash
git status
git diff --stat
git log --oneline origin/HEAD..HEAD
```

- Arquivos não commitados → commitar agora com mensagem descritiva
- Commits locais não pushed → `git push`
- Nunca encerrar com working tree suja ou commits presos localmente

### 2. Issues — fechar concluídas

Para cada issue que foi resolvida nesta sessão:

```bash
gh issue close <N> --comment "feito em <commit-hash>. <1 linha do que foi feito>"
```

Se o projeto usa versionamento por issue (ex.: `scripts/version-bump.sh`):

```bash
bash scripts/version-bump.sh <N>
```

### 3. Issues — criar pendências

Todo trabalho discutido mas não implementado DEVE virar issue antes de sair.
Sem issue = limbo = invisível na próxima sessão.

```bash
gh issue create \
  --title "[DOMÍNIO] título curto" \
  --label <task|feature|improvement|bug|blocked> \
  --body $'**O quê:** ...\n**Por quê:** ...\n**Done:** <critério verificável>'
```

**Cross-repo:** se o trabalho pertence a outro projeto, detectar o repo correto e usar `--repo <owner/repo>`.

### 4. Issues agendadas — criar com label `scheduled`

Para trabalho com janela de execução específica (ex.: deploy em horário OFF, tarefa na segunda):

```bash
gh issue create \
  --title "[DOMÍNIO] título" \
  --label "scheduled" \
  --body $'**O quê:** ...\n**Quando:** YYYY-MM-DD HH:MM (fuso local)\n**Por quê:** ...\n**Done:** <critério>'
```

O `/abrirsessao` prioriza issues com label `scheduled` cuja data chegou.

### 5. Promoção pro agnostic-core

Se algo produzido nesta sessão é um padrão de código genuinamente reutilizável entre corpos (não lógica de negócio específica deste repo), promover pro `.agnostic-core` antes de encerrar — versionado uma vez ali, puxável por qualquer repo com o submódulo, em vez de ficar enterrado só neste projeto.

Se `.agnostic-core` não existir como submódulo neste repo ainda, ver `skills/behavioral/agnostic-core-obrigatorio.md` (nunca codar sem o submódulo presente) — adicionar antes de prosseguir. **Exceção:** se este repo É o próprio `agnostic-core`, não adicionar o submódulo (auto-referência recursiva) — promover direto na árvore do repo.

**Sincronizar a camada nativa de skills (se este repo a expõe).** O Claude Code só
autodescobre skills em `<repo>/.claude/skills/` — ele não varre o submódulo. Se o repo
expõe as skills do agnostic-core por essa camada gerada **e** o submódulo foi atualizado
nesta sessão (`git submodule update --remote` ou bump do ponteiro), regenerar antes de fechar:

```bash
bash .agnostic-core/scripts/generate-claude-skills.sh
```

Depois, **podar** as skills geradas que dupliquem comandos próprios do repo — ex.: se o
repo mantém seus próprios `abrirsessao`/`fecharsessao` em `.claude/commands/`, remover
`.claude/skills/workflow-abrirsessao` e `.claude/skills/workflow-fecharsessao` para não
conflitar. Commitar a camada gerada. Repos que consomem só a fonte (`.agnostic-core/skills/`)
sem a camada gerada podem pular este passo.

### 6. Auditoria periódica de overengineering

Checar `docs/debt-ledger.md` na raiz do repo:

- Não existe, ou a entrada mais recente tem mais de 3 dias → rodar
  `skills/audit/repo-overengineering-audit.md` antes de encerrar.
- Entrada mais recente tem 3 dias ou menos → pular, já foi feito recentemente.

Isso mantém a auditoria de overengineering rodando com regularidade real, sem
depender de lembrar manualmente nem de infra de automação (CI/API key) — se
apoia no mesmo hábito de fechar sessão que já é seguido sempre.

### 7. Handoff — gerar automaticamente

Criar `docs/handoffs/YYYY-MM-DD-HHh.md` com:

```markdown
# Handoff — YYYY-MM-DD HHhMM

## Estado em voo
<o que estava sendo feito no momento de encerrar — específico o suficiente para retomar sem contexto>

## Estado do router (para retomada)
<preserva o roteamento comportamental — ver skills/ai/agnostic-router.md>
- tier_final: <barato|médio|caro>
- fase_final: <explore|design|implement|debug|review|operate>
- debug_travado: <n turnos, ou 0>
- arquivos_tocados: <n>
- risco_corrente: <baixo|alto>

## Issues abertas relevantes
<listar #N + título das issues em progresso ou bloqueadas>

## Guard-rails ativos
<o que NÃO fazer na próxima sessão e por quê — decisões técnicas, janelas de manutenção, dependências externas>

## Próxima ação recomendada
<ação exata, não vaga — ex: "rodar bash scripts/deploy.sh às 18h30" ou "verificar resposta do fornecedor X antes de qualquer ação no sistema Y">

## Decisões desta sessão
<decisões arquiteturais ou de negócio tomadas que não estão óbvias no código>
```

> Se `debug_travado ≥ 2` OU `risco_corrente = alto`, a próxima sessão NUNCA deve retomar
> num tier menor que o registrado. O handoff carrega esse estado; a sessão seguinte o
> herda no primeiro turno de trabalho, em vez de reclassificar do zero.

### 8. Memórias — salvar contexto novo

Verificar se algo aprendido nesta sessão deve ser persistido em memória:
- Novas credenciais ou endpoints
- Feedback do usuário sobre abordagem
- Decisões de projeto não óbvias pelo código
- Contexto de próxima sessão

### 9. Verificações passivas (sem ação)

Executar apenas se aplicável ao projeto:

- **Docker:** `docker ps` nos hosts relevantes — registrar qualquer container Down no handoff
- **Vercel:** `vercel list --limit 3` — registrar status do último deploy

### 10. Confirmação final

Emitir resumo de encerramento:

```
SESSÃO ENCERRADA
- Commits pushed: <N>
- Issues fechadas: #X, #Y
- Issues criadas: #A, #B
- Handoff: docs/handoffs/YYYY-MM-DD-HHh.md
- Versão: vX.Y.Z (se versionamento ativo)
```

---

## Regras invioláveis

- Nunca sair com working tree suja
- Nunca sair com trabalho discutido sem issue correspondente
- O handoff é o contrato com a próxima sessão — ser específico, não genérico
- Issues cross-repo: usar `--repo` correto; nunca criar no repo errado por conveniência
- Guard-rails no handoff são MAIS importantes que o estado em voo — são o que evita ações destrutivas
