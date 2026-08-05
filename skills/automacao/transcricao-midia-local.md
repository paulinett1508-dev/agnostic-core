# Transcricao de Midia Local (Audio/Video)

Claude Code nao tem leitura nativa de audio nem video — a unica entrada multimodal
nativa e imagem (e PDF). Ferramentas de linha de comando locais e gratuitas resolvem
isso sem gastar tokens multimodais e sem enviar a midia para nenhum provedor externo —
importante quando o conteudo e sensivel (dados institucionais, PII, LGPD/GDPR).

---

## Por que nao tentar "descrever" a midia via API

- O agente nao recebe audio/video bruto neste ambiente. Qualquer tentativa de contornar
  isso via chamadas repetidas de API de transcricao paga o mesmo trabalho, mas em nuvem
  e com custo de tokens por minuto de midia.
- Transcrever localmente e ler o `.txt` resultante custa uma fracao do que custaria
  qualquer pipeline multimodal — o custo em tokens passa a ser o do texto da fala, nao
  da midia.
- Dados sensiveis (audio de WhatsApp, video institucional, gravacao de reuniao) nunca
  saem da maquina.

## Pre-requisitos

- `ffmpeg` — decodifica containers de audio/video e extrai frames. Builds recentes
  (ex. gyan.dev no Windows) frequentemente ja vem com um filtro `whisper` embutido
  (`ffmpeg -h filter=whisper`), mas exige baixar um modelo `ggml` separado — o caminho
  mais simples continua sendo o pacote Python abaixo.
- `openai-whisper` (`pip install openai-whisper` — roda 100% local, sem chamada de API).

Nunca assumir que faltam — confirmar antes de tratar como limitacao do agente:
```bash
command -v ffmpeg && ffmpeg -version | head -1
pip show openai-whisper   # Windows: py -m pip show openai-whisper
```

## Audio -> texto

```bash
whisper "<arquivo>" --model small --language Portuguese --output_format txt --output_dir <dir_de_saida>
```

- `--model small` e o equilibrio padrao velocidade/qualidade para fala; só subir para
  `medium`/`large` se a transcricao de `small` sair claramente errada.
- Ler apenas o `.txt` gerado — nunca o audio.

### Armadilhas no Windows

- O executavel do `whisper` normalmente fica em `<python>/Scripts/`, fora do PATH
  padrao do git-bash — adicionar ao PATH da sessao ou chamar pelo caminho completo.
- Saida verbose (`--help`, `--verbose True`) pode lancar `UnicodeEncodeError`: o console
  do Windows usa cp1252 e a lista de idiomas do whisper tem caracteres fora dessa
  tabela. Prefixar `PYTHONUTF8=1` resolve sem tocar no comando em si.

## Video -> texto + frames

O `whisper` aceita o arquivo de video diretamente — usa `ffmpeg` por baixo para extrair
a trilha de audio de qualquer contêiner, então o mesmo comando de audio funciona sem
adaptacao nenhuma.

Para o conteudo visual (o que nenhuma transcricao de fala captura), extrair frames
representativos e olhar so esses — nunca o video bruto:

```bash
ffmpeg -i "<video>" -vf fps=1/10 "<dir_de_saida>/frame_%03d.png"
```

- `fps=1/10` = 1 frame a cada 10s — ajustar a taxa pela densidade do conteudo (tela de
  codigo muda pouco; slide de apresentacao pode exigir mais frequencia).
- Alternativa por deteccao de corte de cena (menos frames redundantes, quando o video
  tem cortes claros em vez de movimento continuo):
```bash
ffmpeg -i "<video>" -vf "select='gt(scene,0.3)',showinfo" -vsync vfr "<dir_de_saida>/scene_%03d.png"
```
- Ler os PNGs resultantes com a ferramenta nativa de leitura de imagem do agente.

## Anti-patterns

```
✗ Assumir que o agente "nao pode" processar audio/video sem checar antes se
  whisper/ffmpeg existem na maquina
✗ Extrair 1 frame por segundo de um video longo "pra nao perder nada" — infla o
  numero de imagens sem ganho proporcional de informacao; ajustar a taxa ao conteudo
✗ Rodar whisper com --model large por padrao — custo de tempo/memoria desnecessario
  na maioria das transcricoes de fala cotidiana
✗ Deixar midia sensivel sair da maquina para transcricao em nuvem quando o pipeline
  local resolve
```

---

Ver tambem: `skills/automacao/automacoes-uteis.md`, `skills/devops/eruda-mobile-debug.md`
