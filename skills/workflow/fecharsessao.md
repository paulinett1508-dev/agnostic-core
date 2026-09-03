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

### 5. Rotinas persistentes — registrar cadência nova, auditar órfãs

Qualquer cadência recorrente que surgiu na sessão ("toda semana", "todo dia às X",
"sempre que Y acontecer") é candidata a virar **rotina persistente** (cloud agent via
`RemoteTrigger`) — não só trabalho que precise rodar sem sessão aberta. **Não confundir
com `CronCreate`**: aquele é efêmero, session-only, some quando a sessão termina e mesmo
as recorrentes expiram em 7 dias — não serve pra nada que precise "ficar salvo".

**5a. Criar a rotina nova:**

1. `ToolSearch select:RemoteTrigger` (se ainda não carregado nesta sessão).
2. Escrever o prompt como se fosse pra uma sessão nova — a rotina roda numa sandbox cloud
   isolada, zero contexto desta conversa. Incluir a **origem explícita dentro do texto do
   prompt** (nº da issue/decisão que motivou, data, repo) — a API não tem campo estruturado
   de "origem", então isso é o único jeito de uma auditoria futura (5b) reconhecer o
   propósito da rotina.
3. `RemoteTrigger {action: "create", body: {...}}` — cron em UTC, intervalo mínimo 1h.
4. **Confirmar a criação de verdade antes de declarar feito** — nunca assumir que o
   `create` funcionou só pelo retorno da chamada:
   `RemoteTrigger {action: "list"}` ou `{action: "get", trigger_id: "..."}`.
5. Registrar em dois lugares além do painel de rotinas (não depender só dele):
   - Handoff desta sessão: link `https://claude.ai/code/routines/<trigger_id>`.
   - Uma memória (`project_*`/`reference_*`) com o propósito e a origem.

**5b. Auditar rotinas órfãs (toda vez que fechar sessão, não só quando criar uma nova):**

`RemoteTrigger {action: "list"}` e, pra cada rotina cujo prompt referencia uma
issue/decisão/estado deste repo: conferir se ainda é válido (ex.: `gh issue view <N>
--json state` se o prompt cita uma issue). Se a issue já fechou ou a decisão que motivou
a rotina não vale mais, **sinalizar pro usuário no resumo de encerramento** — a API não
permite deletar rotina (só via `https://claude.ai/code/routines`), então o máximo que dá
pra fazer aqui é apontar a órfã, nunca deixá-la rodando sem ninguém perceber que perdeu
o propósito.

### 6. Promoção pro agnostic-core

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

### 7. Auditoria periódica de overengineering

Checar `docs/debt-ledger.md` na raiz do repo:

- Não existe, ou a entrada mais recente tem mais de 3 dias → rodar
  `skills/audit/repo-overengineering-audit.md` antes de encerrar.
- Entrada mais recente tem 3 dias ou menos → pular, já foi feito recentemente.

Isso mantém a auditoria de overengineering rodando com regularidade real, sem
depender de lembrar manualmente nem de infra de automação (CI/API key) — se
apoia no mesmo hábito de fechar sessão que já é seguido sempre.

### 8. Handoff — gerar automaticamente

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

### 9. Memórias — salvar contexto novo

Verificar se algo aprendido nesta sessão deve ser persistido em memória:
- Novas credenciais ou endpoints
- Feedback do usuário sobre abordagem
- Decisões de projeto não óbvias pelo código
- Contexto de próxima sessão

### 10. Verificações passivas (sem ação)

Executar apenas se aplicável ao projeto:

- **Docker:** `docker ps` nos hosts relevantes — registrar qualquer container Down no handoff
- **Vercel:** `vercel list --limit 3` — registrar status do último deploy

### 11. Confirmação final

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
- `CronCreate` nunca substitui uma rotina persistente — é efêmero (session-only, recorrentes expiram em 7 dias); "ficar salvo" exige `RemoteTrigger`
- Rotina criada com `RemoteTrigger` só conta como "feito" depois de confirmada com `list`/`get` — nunca assumir que `create` funcionou só pelo retorno da chamada
