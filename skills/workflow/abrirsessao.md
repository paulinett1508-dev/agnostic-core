# /abrirsessao — Retomada robusta de sessão

Reconstrói o contexto completo da sessão anterior em menos de 60 segundos.
Substitui `/newsession`. Invoque com `/abrirsessao` ao iniciar qualquer sessão.

---

## Sequência obrigatória (executar na ordem)

### 1. Hora real — PRIMEIRO, SEMPRE

```bash
date   # hora local da máquina
```

Se o projeto tiver servidor autoritativo de tempo (ex.: servidor de produção):

```bash
ssh <user>@<host> "TZ='<fuso>' date"
```

Nunca operar com timestamp de contexto — ele envelhece sem aviso.
Se houver divergência entre fontes → usar o servidor como verdade.

### 2. Git pull — repo em evidência

```bash
git pull
git log --oneline -5
git status
```

Verificar se há conflitos ou mudanças remotas não esperadas antes de qualquer ação.

### 3. Issues agendadas — prioridade máxima

```bash
gh issue list --label scheduled --state open
```

Issues com `scheduled` cuja data chegou ou passou → topo da fila imediato.
Verificar o campo **Quando:** no corpo de cada issue.

### 4. Alertas do Observatório

```bash
gh issue list --label observatory-alert --state open
```

Se houver qualquer issue com `observatory-alert` → **parar tudo, relatar ao responsável antes de qualquer ação.**

```bash
gh issue list --label observatory --state open
```

Comunicados do Observatório: ler e incorporar no contexto.

### 5. Backlog vivo

```bash
gh issue list --state open --limit 30
```

Issues são o backlog ativo. `TASKS_PENDENTES.md` (se existir) é histórico/detalhe — não backlog.

### 6. Handoff mais recente

Ler o handoff mais recente em `docs/handoffs/` (arquivo com maior data).

Atenção: o handoff é um **retrato datado**, não verdade viva.
Antes de agir em qualquer guard-rail destrutivo — verificar estado atual em produção.

### 7. Memórias do projeto

Ler `MEMORY.md` (ou índice de memórias) para contexto persistido de sessões anteriores.
Priorizar: credenciais, decisões arquiteturais, feedback do usuário, guard-rails permanentes.

> **ESCOPO MÍNIMO:** passos 6 e 7 leem APENAS os arquivos explicitados (handoff + MEMORY.md + CLAUDE.md do repo em evidência). PROIBIDO vasculhar domínios, planetas, satélites, PDFs avulsos, ou qualquer outro documento. O cortex/nucleo é suficiente para retomada. Qualquer leitura adicional exige solicitação explícita do usuário.

### 8. Status de serviços críticos (se aplicável)

Para projetos com infraestrutura ativa, verificação passiva dos serviços críticos:

```bash
# Exemplo para projetos com systemd
ssh <host> "systemctl is-active <servico-principal> <servico-secundario>"

# Exemplo para projetos Docker
ssh <host> "docker ps --format 'table {{.Names}}\t{{.Status}}'"
```

Apenas leitura — nenhuma ação corretiva durante o `/abrirsessao`.
Anomalias detectadas aqui → registrar e propor ação, não executar.

### 9. Saída estruturada

Emitir resumo de retomada:

```
SESSÃO RETOMADA — <data/hora real>

ONDE PARAMOS
<2-3 linhas do estado em voo do handoff — já verificado vs. produção>

ISSUES PRIORITÁRIAS
- [scheduled] #N título — VENCIDA (Quando: ...)
- [blocked] #N título — bloqueador: ...
- #N, #N, #N — próximas na fila

GUARD-RAILS ATIVOS
- <o que NÃO fazer e por quê>

PRÓXIMA AÇÃO PROPOSTA
<ação específica — anunciar e aguardar "sim" se tocar infra>
```

---

## Regras invioláveis

- Hora real ANTES de qualquer análise — nunca confiar no timestamp do contexto
- `observatory-alert` aberto → relatar ANTES de tudo, sem exceção
- Git pull ANTES de qualquer edição — nunca trabalhar em branch desatualizado
- Handoff é ponto de partida, não verdade absoluta — verificar estado atual antes de agir em guard-rails
- A saída do `/abrirsessao` é um briefing, não uma autorização de execução — propor, aguardar "sim"
- **ESCOPO MÍNIMO — não vasculhar.** Durante o `/abrirsessao`, leituras de arquivo se limitam a: (1) handoff mais recente, (2) MEMORY.md do projeto, (3) CLAUDE.md do repo em evidência. Domínios, planetas, satélites, PDFs e quaisquer outros documentos ficam fora. Essa restrição evita esgotamento da janela de tokens na abertura de sessão.
