# Zombie Code Auditor — Comandos por Fase

Comandos genéricos (bash), adaptar por stack quando necessário. Todos são de leitura — nenhum aplica mudança.

---

## Fase 1 — Kill incompleto

### Achar candidatos: commits que "removeram"/"desativaram" algo

```bash
git log --oneline -i --grep='remov\|desliga\|desativ\|descontinu\|disable\|remove\|deprecat' | head -30
```

Para cada commit achado, ler o diff completo (`git show <hash>`) e listar TODOS os arquivos que
tocam o mesmo comportamento (não só os que o commit tocou) — buscar por outros callers:

```bash
# Exemplo: uma feature "removida" chamada featureX — buscar todo caminho que ainda a alcança
grep -rn "featureX" --include="*.js" --include="*.ts" --include="*.html" \
  --exclude-dir=node_modules --exclude-dir=.git .
```

### Rota/endpoint sem guarda depois de remover do menu

```bash
# Listar rotas Express/Fastify definidas
grep -rn "router\.\(get\|post\|put\|delete\|patch\)\|app\.\(get\|post\|put\|delete\|patch\)" \
  --include="*.js" --include="*.ts" --exclude-dir=node_modules .

# Para cada rota suspeita, confirmar se tem middleware de auth/feature-flag
# comparando com rotas vizinhas no mesmo arquivo
```

### Tool removida de um LLM sem instrução de recusa no prompt

```bash
# Achar onde a lista de tools é montada
grep -rln "tools\s*[:=]\s*\[" --include="*.js" --include="*.ts" --exclude-dir=node_modules .

# Conferir se o SYSTEM PROMPT tem instrução explícita de recusa
# equivalente à tool removida (busca manual — não há grep genérico confiável aqui)
grep -rn "SYSTEM_PROMPT\|systemPrompt" --include="*.js" --include="*.ts" --exclude-dir=node_modules .
```

---

## Fase 2 — Flag substitui em vez de somar

### Padrão de sobrescrita de destino/lista

```bash
# Procura atribuições diretas a variáveis de destino/destinatário condicionadas por flag de teste/modo
grep -rn "MODO_TESTE\|TEST_MODE\|DRY_RUN\|modoTeste" --include="*.js" --include="*.ts" \
  --exclude-dir=node_modules -A2 -B2 .
```

Para cada ocorrência, verificar manualmente: a linha seguinte faz `destino = X` (substitui) ou
`destino.push(X)` / `destino = [...destino, X]` (soma)? Susbtituição é o padrão zumbi.

### Variável de teste reaproveitando chave de produção

```bash
# Comparar nomes de env vars de teste vs produção — se aparecerem juntas na mesma
# linha condicional, suspeitar de reaproveitamento
grep -rn "process.env\." --include="*.js" --include="*.ts" --exclude-dir=node_modules . \
  | grep -i "test\|teste"
```

---

## Fase 3 — Ressurreição via build/geração/sincronização

### Diff entre artefato gerado e a fonte que o alimenta

```bash
# Exemplo: skills geradas a partir de um acervo upstream (submodule)
# Rodar o script de geração em modo dry-run/diff e comparar com o estado atual
git diff --stat HEAD -- .claude/skills/ 2>/dev/null

# Se o projeto tem script de geração, rodar e comparar antes de aceitar a saída:
bash scripts/generate-claude-skills.sh --dry-run 2>/dev/null || true
git status --short .claude/skills/
```

### Fix aplicado só na cópia, nunca promovido à fonte

```bash
# Se existir uma cópia local de algo que também vive num submodule/acervo upstream,
# comparar os dois:
diff <(cat caminho/local/arquivo.md) <(cat caminho/upstream/equivalente.md)
```

### Migration/seed reexecutando por engano

```bash
grep -rln "seed\|migration" --include="*.js" --include="*.ts" scripts/ 2>/dev/null \
  | xargs grep -l "upsert\|insertMany\|create(" 2>/dev/null
```

Confirmar se o script tem guarda de idempotência (checa se já rodou) antes de aceitar
que reexecução em todo deploy é segura.

---

## Fase 4 — Doc/handoff órfão ainda alcançável

### Achar docs datados órfãos

```bash
# Diretórios comuns de handoff/changelog
find docs/handoffs docs/changelogs -type f -name "*.md" 2>/dev/null | sort

# Data do arquivo mais recente vs data do handoff "oficial" atual do projeto
# (comparar manualmente com o que o CLAUDE.md do projeto aponta como fonte viva)
```

### Comentário citando mecanismo já substituído

```bash
grep -rn "TODO\|FIXME\|deprecated\|legado\|antigo\|obsoleto" --include="*.js" --include="*.ts" \
  --include="*.md" --exclude-dir=node_modules . | head -40
```

### Duas fontes de verdade pra mesma decisão

```bash
# Buscar o mesmo termo/decisão em múltiplos arquivos de doc — sinal de fonte duplicada
grep -rln "<termo-chave-da-decisao>" --include="*.md" docs/ .claude/ 2>/dev/null
```

---

## Fase 5 — Recorrência (causa raiz não morta)

### Mesmo incidente 2+ vezes no histórico

```bash
# Ajustar o termo pra cada investigação (ex: "CRLF", "cache stale", "timeout")
grep -in "<termo-do-incidente>" .claude/LESSONS.md CHANGELOG.md docs/estado-historico.md 2>/dev/null
```

Se o mesmo termo aparecer em 2+ datas diferentes com fixes distintos, é candidato forte
a causa raiz não eliminada — reportar como zumbi de recorrência, não como incidente novo.

### Bug "corrigido" sem verificação end-to-end

```bash
# Buscar por linguagem de "declarado resolvido por leitura de código" no histórico —
# sinal fraco, mas útil como ponto de partida pra entrevista com quem reportou
grep -in "verificado por leitura\|nao verificado ao vivo\|nao testado em producao" \
  .claude/LESSONS.md docs/estado-historico.md 2>/dev/null
```
