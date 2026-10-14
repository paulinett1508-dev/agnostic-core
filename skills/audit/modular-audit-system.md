# Modular Audit System

Padrão DRY para criar sistemas de auditoria escaláveis: uma skill orquestradora central + arquivos de rules separados por domínio + registry de módulos. Elimina duplicação e garante consistência entre auditorias de diferentes partes do sistema.

---

## Problema que resolve

Sem esse padrão, cada módulo tem sua própria checklist duplicada — mudanças de padrão precisam ser propagadas manualmente para N arquivos. Com ele:

| Abordagem | Custo de atualização |
|-----------|---------------------|
| Checklist por módulo | Editar N arquivos, inconsistências inevitáveis |
| Skill única + rules | Editar 1 arquivo de rule — todos os módulos refletem |

---

## Arquitetura

```
docs/
├── rules/
│   ├── audit-security.md      # Checklist de segurança (reutilizável)
│   ├── audit-performance.md   # Checklist de performance
│   ├── audit-ui.md            # Checklist de interface
│   ├── audit-business.md      # Checklist de regras de negócio
│   └── audit-financial.md     # Checklist de operações financeiras
├── modules-registry.json      # Catálogo: quais rules aplicar a cada módulo
└── auditorias/                # Relatórios gerados
    └── AUDITORIA-<modulo>-<data>.md
```

A skill orquestradora (este documento ou um comando) lê o registry, carrega as rules aplicáveis e executa os checklists.

---

## Registry de módulos

```json
{
  "nome-do-modulo": {
    "name": "Nome Exibido",
    "category": "ranking | financeiro | conteudo | configuracao",
    "complexity": "low | medium | high | critical",
    "files": {
      "controller": "src/controllers/modulo-controller.js",
      "model": "src/models/Modulo.js",
      "frontend": "src/components/Modulo.tsx"
    },
    "audits": ["security", "performance", "ui", "business"]
  }
}
```

Campos obrigatórios: `name`, `category`, `complexity`, `audits`.

Adicionar novo módulo = uma linha no JSON. Sem criar nova checklist.

---

## Formato de rule file

Cada `docs/rules/audit-<tipo>.md` deve seguir este template:

```markdown
# AUDIT RULE: <Nome>

## Objetivo
Descrição do propósito desta auditoria.

---

## Checklist

### 1. Item Principal
- [ ] Sub-check 1
- [ ] Sub-check 2

**Exemplo correto:**
\`\`\`
código de exemplo
\`\`\`

---

## Red Flags Críticos

| Problema | Severidade | Ação |
|----------|-----------|------|
| Descrição | CRÍTICO/ALTO/MÉDIO/BAIXO | Ação corretiva |

---

**Última atualização:** DD/MM/AAAA
```

---

## Severidades

| Nível | Quando usar | Ação |
|-------|-------------|------|
| CRÍTICO | Segurança, perda de dados, financeiro | Bloquear merge |
| ALTO | UX ruim, bugs funcionais | Corrigir antes de produção |
| MÉDIO | Performance, code smell | Corrigir no próximo sprint |
| BAIXO | Nice-to-have, otimizações | Backlog |

---

## Score de conformidade

```
Score = (Checks Passed / Total Checks) × 100
```

| Score | Status |
|-------|--------|
| 90–100% | Aprovado |
| 70–89% | Aceitável — revisar warnings |
| 50–69% | Precisa melhorias |
| < 50% | Crítico — não mergear |

---

## Workflow de auditoria (5 passos)

1. **Identificar módulo** → buscar no registry
2. **Carregar rules** → a partir do campo `audits` do módulo
3. **Executar checklists** → para cada rule, verificar arquivos do módulo
4. **Gerar relatório** → salvar em `docs/auditorias/`
5. **Re-auditar** após corrigir issues críticas

---

## Template de relatório

```markdown
# AUDITORIA: <Nome do Módulo>

**Data:** DD/MM/AAAA
**Complexidade:** low/medium/high/critical

## Resumo Executivo

| Categoria   | Score | Status      |
|-------------|-------|-------------|
| Security    | 9/10  | Aprovado    |
| Performance | 7/10  | Melhorias   |
| UI          | 8/10  | Warnings    |

**Score Geral:** 80/100 (Aceitável)

---

## Security: 9/10 checks passed

### Issues encontrados
- **Linha 89:** Rate limiting ausente
  - Correção: adicionar middleware de rate limit

---

## Ações Recomendadas

**Prioridade ALTA (antes de produção):**
1. Adicionar rate limiting (security)

**Prioridade MÉDIA (próximo sprint):**
2. Otimizar query N+1 (performance)
```

---

## Quando auditar

- **Novo módulo:** antes do primeiro merge
- **Refatoração significativa:** após mudanças > 100 linhas
- **Antes de releases:** módulos críticos
- **Auditoria periódica:** mensal para módulos financeiros, trimestral para demais
- **Após bugs reportados:** validar correção + prevenir regressão

---

## Agnóstico de IA

O sistema funciona com qualquer IA com acesso ao contexto do projeto:

```
/auditar-modulo nome-do-modulo
/auditar-modulo nome-do-modulo --security
/auditar-modulo --category financeiro
```

Requisito: IA deve ter acesso ao `modules-registry.json` e aos arquivos em `docs/rules/`.

---

Ver também: `skills/audit/code-review.md`, `skills/audit/validation-checklist.md`
