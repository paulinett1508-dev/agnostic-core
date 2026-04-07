# menos-e-mais

> Auditoria de inchaço de código frontend e backend.
> Elimina o que não agrega valor real — CSS morto, wrapper hell, lógica duplicada, queries gordas.

---

## Quando usar

- Componente novo sendo revisado antes de PR
- Reclamação de "código grande demais" ou "muito CSS"
- Onboarding em codebase legado
- Sprint de refatoração ou limpeza técnica
- Qualquer menção a: "enxugar", "simplificar", "remover o que não usa", "código inchado"

**Ordem de aplicação:** rode esta skill *depois* de `ux-ui/navegacao-sem-redundancia.md`.
Não adianta limpar o CSS de um botão que vai ser removido pela auditoria de UX.

---

## Fase 1 — Mapeamento Rápido

Antes de qualquer julgamento, entender o escopo:

1. **O que esse arquivo/componente deveria fazer?** (responsabilidade declarada)
2. **Quem o consome?** (outros componentes, rotas, usuário final)
3. **Qual a stack?** (React/Vue/Vanilla, CSS puro/Tailwind/Styled-components)

Se não estiver claro, pergunte **uma vez** e de forma direta.

---

## Fase 2 — Checklist de Inchaço (Frontend)

### CSS / Tailwind / Styled-components

- [ ] Classes repetidas no mesmo elemento ou entre elementos irmãos
- [ ] Propriedades que se sobrescrevem (`mt-4` e `mt-8` no mesmo elemento)
- [ ] Breakpoints sem impacto visual real no contexto do projeto
- [ ] Animações/transições sem propósito funcional declarado
- [ ] Variáveis CSS declaradas e nunca usadas
- [ ] Especificidade excessiva (`!important`, seletores triplos)
- [ ] Media queries duplicadas ou que nunca ativam para a base de usuários real
- [ ] Mais de 8–10 classes Tailwind no mesmo elemento (candidato a `@apply` ou componente)

### HTML / JSX

- [ ] `<div>` e `<span>` sem estilo próprio e sem papel semântico (wrapper hell)
- [ ] Elementos permanentemente ocultos com `hidden` ou `display:none`
- [ ] Props repassadas para baixo sem serem usadas no componente intermediário
- [ ] Componente que só renderiza outro componente sem adicionar lógica
- [ ] Blocos inteiros copiados entre componentes (copypaste sem extração)
- [ ] Código comentado disfarçado de comentário de documentação
- [ ] `key={index}` em listas dinâmicas onde a ordem pode mudar

### Componentes / Estrutura

- [ ] Componente com mais de uma responsabilidade claramente identificável
- [ ] `useState` para valor que pode ser derivado de outro estado ou prop
- [ ] `useEffect` que poderia ser `useMemo`, `useCallback` ou computação inline
- [ ] Imports declarados e não utilizados no arquivo
- [ ] Arquivos criados "para o futuro" mas vazios ou com stub sem uso
- [ ] Lógica condicional que sempre resolve para o mesmo branch em runtime

---

## Fase 3 — Checklist de Inchaço (Backend)

### Rotas / Controllers

- [ ] Endpoints com lógica idêntica ou quase idêntica registrados em rotas diferentes
- [ ] Middleware global aplicado onde apenas 1–2 rotas o necessitam
- [ ] Validações repetidas que poderiam ser um schema centralizado (Zod, Joi, etc.)
- [ ] Campos na resposta JSON que o frontend nunca lê ou exibe
- [ ] `SELECT *` onde apenas 2–3 colunas são efetivamente usadas

### Banco de Dados / Queries

- [ ] N+1: loop com query dentro sem batch ou join
- [ ] Dados filtrados em memória que poderiam ser filtrados na query
- [ ] Joins para tabelas não utilizadas no resultado retornado
- [ ] Índices declarados mas não utilizados pelas queries reais do sistema

---

## Fase 4 — Diagnóstico e Relatório

Formato de entrega obrigatório após análise:

```
## Diagnóstico — [Arquivo / Componente / Módulo]

### 🔴 Crítico (remove agora)
- [item + localização exata]
- Motivo: [por que é desnecessário]

### 🟡 Atenção (simplifica ou consolida)
- [item]
- Sugestão: [como resolver]

### 🟢 OK (mantém)
- [o que está correto e por quê]

### Estimativa de impacto
- CSS: ~X% de linhas eliminadas
- JSX/HTML: ~X nós removidos
- Componentes: X arquivos candidatos à fusão/remoção
- Queries: X campos ou joins removidos
```

---

## Fase 5 — Refatoração Cirúrgica

Após aprovação do diagnóstico:

1. **Por seção/componente** — nunca reescreva tudo de uma vez
2. **Preservar funcionalidade** — cada remoção deve ser testável
3. **Mostrar antes/depois** para cada bloco significativo
4. **Não adicionar abstração nova** durante a limpeza — o objetivo é remover, não reorganizar com complexidade equivalente

---

## Princípios

| Princípio | Aplicação prática |
|-----------|-------------------|
| Menos nós = mais velocidade | Cada `div` sem função é custo de render |
| CSS morto é dívida técnica | Cresce, ninguém remove, vira medo de mexer |
| Componente = responsabilidade única | Se não nomeia em 3 palavras, está errado |
| Prop que desce mas não sobe valor | Prop drilling sem retorno = design ruim |
| Backend serve o frontend | Se o frontend filtra o que o backend retorna, o backend está errado |

---

## Padrões de referência — Antes/Depois

### Wrapper Hell

```jsx
// ❌ Antes
<div className="container">
  <div className="wrapper">
    <div className="inner">
      <div className="content">
        <p>Texto</p>
      </div>
    </div>
  </div>
</div>

// ✅ Depois
<div className="content">
  <p>Texto</p>
</div>
```

**Regra:** Se o `div` não tem estilo próprio nem papel semântico, não existe.

---

### Tailwind Class Explosion

```jsx
// ❌ Antes
<button className="flex items-center justify-center px-4 py-2 bg-blue-500
  text-white rounded-md hover:bg-blue-600 focus:outline-none focus:ring-2
  focus:ring-blue-500 focus:ring-offset-2 transition-colors duration-200
  ease-in-out font-medium text-sm shadow-sm">

// ✅ Depois
<button className="btn-primary">  {/* extraído via @apply ou componente */}
```

---

### Estado derivado desnecessário

```jsx
// ❌ Antes
const [fullName, setFullName] = useState('');
useEffect(() => {
  setFullName(`${firstName} ${lastName}`);
}, [firstName, lastName]);

// ✅ Depois
const fullName = `${firstName} ${lastName}`;
```

---

### Prop drilling sem uso

```jsx
// ❌ Antes — Card só repassa, não usa nada
<Card user={user} theme={theme} config={config} onAction={onAction} />
const Card = ({ user, theme, config, onAction }) => (
  <Avatar user={user} theme={theme} config={config} onAction={onAction} />
)

// ✅ Depois — composição ou Context
<Card><Avatar /></Card>
```

---

### SELECT * com filtro no frontend

```js
// ❌ Antes
const users = await db.query('SELECT * FROM users');
const active = users.filter(u => u.active); // filtro no JS

// ✅ Depois
const users = await db.query(
  'SELECT id, name, email FROM users WHERE active = true'
);
```

---

### Endpoints duplicados

```js
// ❌ Antes
router.get('/users/active', getActiveUsers);
router.get('/users/list', getActiveUsers); // mesma função, duas rotas

// ✅ Depois
router.get('/users', getUsers); // ?status=active como query param
```

---

## Métricas de antes/depois

```bash
# Linhas de CSS por arquivo (top 20)
find . -name "*.css" -not -path "*/node_modules/*" \
  | xargs wc -l | sort -rn | head -20

# Componentes com menos de 5 linhas (possíveis stubs)
find src -name "*.jsx" -o -name "*.tsx" \
  | xargs wc -l | awk '$1 < 5' | sort

# Imports não utilizados (requer ESLint)
npx eslint src --rule '{"no-unused-vars": "error"}' --quiet
```

| Tipo de página | Nodes DOM saudável | Problemático |
|----------------|-------------------|--------------|
| Landing simples | < 500 | > 1000 |
| Dashboard | < 1200 | > 2500 |
| Lista paginada | < 800 | > 2000 |
| Formulário | < 400 | > 1000 |
