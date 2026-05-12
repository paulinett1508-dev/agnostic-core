# Skill: browser-mcp

## Auto-Ativação

Esta skill é ativada **automaticamente** quando qualquer uma das condições abaixo for detectada no projeto:

- Presença de `next.config.*`, `vite.config.*`, `package.json` com scripts `dev` ou `start`
- Arquivos `.tsx`, `.jsx`, `.vue`, `.svelte` no root ou em `src/`
- Projeto com `"framework"` em `vercel.json`
- Qualquer menção a erro de rota, 404, bug visual, comportamento inesperado no browser

> Não aguarde instrução explícita do usuário. Se o projeto é web e há problema de UI/rota/comportamento, ative esta skill.

---

## O que esta skill faz

Integra dois servidores MCP ao workflow do Claude Code para inspecionar e automatizar o browser diretamente:

| Servidor | Melhor para |
|---|---|
| **Browser MCP** | Automação real do browser (cliques, formulários, navegação, screenshots, logs) usando a sessão autenticada do usuário |
| **Chrome DevTools MCP** | Debug técnico (console errors, network requests, performance traces, inspeção de DOM) |

---

## Pré-requisitos

1. Node.js instalado (verifique: `node -v`)
2. Chrome instalado
3. Extensão **Browser MCP** instalada no Chrome:
   - https://chromewebstore.google.com/detail/browser-mcp-automate-your/bjfgambnhccakkhmkepdoekmckoijdlc
4. Extensão conectada (ícone → botão **Connect**)

---

## Setup (primeira vez)

Execute o script de setup no PowerShell **como Administrador**:

```powershell
C:\PROJETOS\CONTA PESSOAL\agnostic-core\skills\browser-mcp\setup.ps1
```

O script instala os servidores e injeta a configuração no `.mcp.json` do projeto ativo.

---

## Configuração MCP

Os dois servidores ficam em `.mcp.json` na raiz do projeto (ou globalmente em `~/.claude/mcp.json`):

```json
{
  "mcpServers": {
    "browsermcp": {
      "command": "npx",
      "args": ["@browsermcp/mcp@latest"]
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["chrome-devtools-mcp@latest", "--slim"]
    }
  }
}
```

> `--slim` no Chrome DevTools reduz de 29 para 3 ferramentas essenciais, economizando ~12k tokens por chamada. Remova a flag se precisar de performance profiling ou emulação de dispositivo.

---

## Como usar após setup

### Debug de erro de rota / 404

```
Abra http://localhost:3000/admin/rca/123 no browser conectado,
capture o console, os network requests e me mostre o erro.
```

### Teste de fluxo completo

```
Navegue até /login, preencha com usuário "admin" e senha "test",
capture screenshot após o redirect e verifique erros no console.
```

### Inspeção visual

```
Tire screenshot da rota /dashboard e me diga se o layout
está quebrando em viewport mobile (375px).
```

---

## Ferramentas disponíveis

### Browser MCP
- `navigate(url)` — navega para uma URL
- `screenshot()` — captura a tela atual
- `getConsoleLogs()` — retorna logs do console
- `click(selector)` — clica em elemento
- `fill(selector, value)` — preenche input
- `getNetworkRequests()` — lista requisições de rede

### Chrome DevTools MCP (modo `--slim`)
- Inspeção de console errors
- Análise de network requests
- Debug autônomo sem intervenção manual

---

## Troubleshooting

| Problema | Solução |
|---|---|
| Extensão não conecta | Clique em **Connect** no ícone da extensão no Chrome |
| Servidor não inicia | Execute `npx @browsermcp/mcp@latest` no terminal para testar |
| Conflito de porta | Verifique se outra aplicação usa a mesma porta do servidor |
| Erro no Chrome DevTools MCP | Adicione `--browserUrl http://localhost:9222` se já tiver Chrome rodando |

---

## Referências

- Browser MCP Docs: https://docs.browsermcp.io/welcome
- Chrome DevTools MCP: https://github.com/ChromeDevTools/chrome-devtools-mcp
- Chrome Extension: https://chromewebstore.google.com/detail/browser-mcp-automate-your/bjfgambnhccakkhmkepdoekmckoijdlc
