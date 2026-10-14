Orcamento de leituras de banco: sentinela de cota diaria

Objetivo: Estimar e acompanhar quantas operacoes de leitura um app faz no banco por dia, para nao estourar a cota de um plano com limite diario (ex.: plano gratuito de bancos hospedados, com cota de leituras por dia).

Aviso de medicao: o contador e uma estimativa. O numero oficial e o painel de uso do proprio provedor. Registre essa ressalva junto do numero.

---

QUANDO APLICAR

- Plano com cota diaria de leituras ou escritas (o estouro gera erro ou bloqueio, nao so cobranca)
- Varios clientes ou telas que fazem leitura em tempo real (listeners, polling)
- Antes de subir para um plano pago, para dimensionar o consumo real

---

REGRAS GENERICAS

- [ ] Contar so o que vem do servidor. Leitura servida por cache local geralmente nao consome cota. O contador deve descartar resultados marcados como vindos do cache (ex.: `metadata.fromCache === true`)
- [ ] Envolver a API de leitura, nao a logica de negocio. A troca deve ser so no import ou no ponto de criacao do cliente, para o resto do codigo nao mudar
- [ ] Agregar em memoria e enviar em lote (ex.: a cada minuto e ao ocultar a aba). Uma requisicao por leitura dobraria o consumo que se quer medir
- [ ] Falha do contador nunca afeta a leitura. Isolar o contador em try/catch e nao propagar erro para o chamador
- [ ] Dia da cota no fuso em que ela zera. Ex.: o plano Spark do Firestore zera a cota a meia-noite do Pacifico, nao do fuso local do usuario
- [ ] Endpoint de gravacao exige usuario autenticado e tem teto por envio (ex.: 2000 contagens), para que um cliente nao consiga inflar o numero
- [ ] Colecao de metricas fechada para leitura direta do cliente. So o servidor grava e so um perfil administrativo le
- [ ] Mostrar o numero so para o perfil que precisa dele (ex.: painel do super admin)

---

EXEMPLO (Firestore, JavaScript)

Ilustrativo. O padrao vale para qualquer SDK que tenha leitura por documento e por consulta em tempo real.

```javascript
// contador.js: wrapper fino sobre o SDK. Mesma API, so muda o import.
import * as sdk from 'firebase/firestore'

let pendente = 0
const enviar = () => {
  if (!pendente) return
  const total = pendente
  pendente = 0
  // falha do envio e descartada: medir nunca pode quebrar o app
  fetch('/api/metricas/leituras', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ total }),
  }).catch(() => {})
}
setInterval(enviar, 60_000)
document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'hidden') enviar()
})

const contar = (snap) => {
  try {
    if (!snap.metadata.fromCache) pendente += snap.size ?? 1
  } catch { /* contador nunca interfere */ }
  return snap
}

export const getDocs = async (q) => contar(await sdk.getDocs(q))
export const getDoc = async (ref) => {
  const snap = await sdk.getDoc(ref)
  try { if (!snap.metadata.fromCache) pendente += 1 } catch {}
  return snap
}
export * from 'firebase/firestore' // demais funcoes passam direto
```

Os demais arquivos do projeto trocam `from 'firebase/firestore'` por `from './contador'`. Para `onSnapshot`, conte a cada entrega do servidor, nao a cada inscricao.

---

ENDPOINT DE GRAVACAO (esboco)

- `POST`: aceita `{ total }`, exige sessao valida, rejeita `total` acima do teto, soma no contador do dia (chave = data no fuso de reset da cota)
- `GET`: restrito ao perfil administrativo, devolve o total do dia

---

ANTI-PATTERNS

  ✗ Contar leituras do cache como se fossem da cota
  ✗ Enviar uma requisicao por leitura
  ✗ Deixar falha do contador subir para a tela
  ✗ Usar fuso local do usuario para o dia da cota
  ✗ Colecao de metricas legivel pelo cliente
  ✗ Tratar o numero estimado como se fosse o oficial sem calibrar contra o painel do provedor

---

CHECKLIST

- [ ] Contagem so de resultados vindos do servidor
- [ ] Wrapper com a mesma API do SDK e troca restrita ao import
- [ ] Envio em lote, com flush ao ocultar a aba
- [ ] Falha do contador isolada
- [ ] Dia da cota no fuso de reset do provedor
- [ ] Endpoint autenticado, com teto por envio
- [ ] Metricas legiveis so pelo perfil administrativo
- [ ] Numero calibrado contra o painel oficial do provedor, com ressalva registrada

---

SKILLS A CONSULTAR

  skills/database/query-compliance.md       Queries seguras, indices e transacoes
  skills/devops/observabilidade.md          Metricas, alertas e caminho de falha
  skills/audit/senior-verification-protocol.md  Verificar antes de declarar concluido
