# Fluxo de Edição de Imagens: Claude Code + Nano Banana + Canva

Fluxo para criar e editar imagens com precisão cirúrgica combinando Claude Code,
o MCP do Nano Banana e o Magic Layers do Canva. Aplique quando quiser gerar ou
refinar assets visuais sem sair do terminal.

Fonte: [@charlieautomates no Instagram](https://www.instagram.com/p/DWheO3YGNMV/?img_index=3)

---

## O Segredo

> "Stack Nano Banana with Claude Code. Claude understands your project, your brand context,
> your files. It writes the prompts FOR you based on everything it already knows.
> Then bring it to Canva. Magic Layers lets you separate every element and edit with precision.
> One terminal. One design tool. Scalpel level editing."

---

## As três ferramentas

| Ferramenta | Papel no fluxo |
|---|---|
| **Claude Code** | Entende o contexto do projeto, da marca e dos arquivos. Escreve o prompt de edição automaticamente. |
| **Nano Banana (MCP)** | Executa a geração/edição da imagem via terminal usando o modelo `gemini-2.0-flash-exp-image-generation` do Google. |
| **Canva — Magic Layers** | Recebe a imagem gerada e permite separar e editar cada elemento individualmente com precisão. |

---

## Pré-requisito: Google API Key (gratuita)

O Nano Banana usa o **Google Gemini** para geração de imagens. É necessário uma
`GOOGLE_API_KEY` — disponível gratuitamente no Google AI Studio, sem cartão de crédito.

### 1. Obter a chave

Acesse [aistudio.google.com/apikey](https://aistudio.google.com/apikey), crie uma chave e copie.

### 2. Configurar como variável de ambiente

Adicione no seu `~/.bashrc`, `~/.zshrc` ou equivalente:

```bash
export GOOGLE_API_KEY="sua-chave-aqui"
```

Recarregue o shell:

```bash
source ~/.zshrc  # ou source ~/.bashrc
```

### 3. Verificar

```bash
echo $GOOGLE_API_KEY
```

> Sem essa variável definida, o MCP falha silenciosamente ao tentar gerar imagens.

---

## Instalação do MCP Nano Banana

Com a `GOOGLE_API_KEY` configurada, instale o MCP via npx (sem instalação global necessária):

```bash
claude mcp add nano-banana -- npx -y nano-banana-mcp
```

Verifique se foi registrado:

```bash
claude mcp list
```

O MCP expõe a ferramenta `mcp__nano-banana__edit_image` para uso direto no Claude Code.

---

## Fluxo completo

```
[Você descreve o que precisa visualmente]
          ↓
Claude Code lê o contexto do projeto (CLAUDE.md, brand files, assets)
          ↓
Claude Code escreve o prompt ideal para o Nano Banana
          ↓
Nano Banana chama Gemini → gera/edita a imagem (mcp__nano-banana__edit_image)
          ↓
[Você recebe a imagem gerada no terminal]
          ↓
Imagem é levada para o Canva → Magic Layers
          ↓
[Separação e edição cirúrgica de cada elemento]
          ↓
[Asset final pronto]
```

---

## Prompt base para o Claude Code

Copie, cole e adapte no Claude Code com o MCP do Nano Banana configurado:

```
Você é meu assistente de design e edição de imagens.
O MCP do Nano Banana está configurado via `mcp__nano-banana__edit_image`.

Com base no contexto do projeto atual — incluindo @CLAUDE.md, arquivos de brand
e assets existentes que você já conhece:

1. Analise o que precisamos criar ou editar visualmente para esta tarefa.
2. Escreva o prompt ideal para o Nano Banana, garantindo alinhamento
   com a identidade visual do projeto.
3. Execute a edição/geração da imagem usando o Nano Banana.
4. Salve a imagem gerada e informe o caminho.

O próximo passo será levar essa imagem para o Canva e usar o
"Magic Layers" para separação e edição final dos elementos.
```

---

## Boas práticas

- Quanto mais contexto de marca estiver no `CLAUDE.md` (cores, fontes, tom), mais preciso o resultado
- Use `@` para injetar arquivos de referência visual diretamente no prompt
- Valide a imagem gerada antes de levar para o Canva — ajustes no terminal são mais rápidos
- No Canva, o **Magic Layers** funciona melhor com imagens que têm elementos bem definidos (fundo, texto, ícone)
- Combine com `paper-mcp-workflow.md` quando o objetivo final for um componente de UI

---

## Ver também

- `skills/design/paper-mcp-workflow.md` — design de interfaces via MCP no Paper
- `skills/mcp/ideias-de-mcp.md` — outros MCPs úteis no fluxo de desenvolvimento
- `skills/workflow/claude-code-productivity.md` — produtividade geral no Claude Code
- `exemplos/prompts-prontos.md` — prompts prontos para uso imediato
