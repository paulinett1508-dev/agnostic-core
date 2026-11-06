# OCR de livro rasterizado: páginas giradas e tabelas

Lições de converter um livro de gráfica (PDF/X só com imagens de 300 ppi, sem camada de texto) em
texto web com tesseract. Foco nas páginas que o OCR comum destrói: tabelas impressas na horizontal.

Origem: centroculturalsbr, 2026-11-06 (`scripts/livro-pipeline/tabela.py`, `limpar_ruido.py`).

---

## Sintoma de página girada

Texto "de cabeça para baixo" no resultado: `096T` (= 1960), `656T` (= 1959), `Jopeafes wo sour 7`
(= "7 anos em Salvador"). A página foi impressa em paisagem (tabela larga) e o OCR leu na orientação
errada.

## Achar todas de uma vez

```bash
tesseract pagina.png - --psm 0 -l osd   # "Rotate: 90" e "Orientation confidence: N"
```

Rodar em todas as páginas em paralelo (`xargs -P`, `OMP_THREAD_LIMIT=1`). Confiança baixa (< ~2) em
página de foto é falso positivo; conferir olhando a página em baixa resolução antes de corrigir.
Cuidado ao esperar o lote com `pgrep -f "<padrão>"`: o próprio laço contém o padrão e casa consigo.

## Tabela: extrair pela grade, não pelo texto corrido

OCR da página inteira mistura colunas. O que funcionou:

1. Girar a imagem (`cv2.rotate`) conforme o OSD.
2. Linhas da tabela por morfologia (OpenCV): `MORPH_OPEN` com kernel horizontal longo e vertical.
   - Horizontais **da tabela**: as que não ocupam a largura toda da página (essas são borda do scan);
     a extensão delas dá as bordas esquerda/direita.
   - Verticais: só dentro dessa faixa e contínuas em ≥ ~55% da altura (faixas de seção mescladas
     interrompem as verticais; 85% perde todas). Kernel vertical curto pega traço de letra.
3. OCR **por célula** (`--psm 6`, cai para `--psm 7` se vier vazio: célula grande com texto curto
   como "1 ano"), depois de binarizar com Otsu (faixa cinza de cabeçalho/seção vira lixo sem isso).
4. Linha sem verticais internas = faixa de seção (colspan).
5. Cabeçalho passado à mão (conferido na imagem) e a linha impressa do cabeçalho descartada.
6. Texto fora da grade (resumo abaixo da tabela) em região separada; marcadores Wingdings saem como
   `ü`/`U`: converter para item de lista.
7. Regras pontuais conhecidas do OCR: `-Pl` → `-PI` (sigla de estado).

Saída em pipe-table Markdown; no leitor, `<br>` como única marcação aceita na célula (quebra de linha
da célula impressa) e o resto escapado.

## Limpeza de ruído (conservadora, revisada linha a linha)

Remover só linha **sem nenhuma palavra real**: resto do cabeçalho corrente (nome do livro solto, nome
do autor com letras espaçadas), fragmentos de símbolos lidos dentro de fotos (`<`, `+— Z Q`), e eco
do título impresso (linha em maiúsculas cujas letras estão contidas no título, ou ≥ 88% parecida —
**exceto se trouxer números que o título não tem**: datas são informação). Listar tudo antes de
aplicar e revisar: "Jáciteiacima" é texto real colado ("Já citei acima"), não lixo.

## Outras lições

- Capitular (letra grande do início) some no OCR: "ideia de escrever" em vez de "A ideia". OCR de
  caractere único na região da capitular **errou** a letra; corrigir à mão (são poucas).
- Detector de "lixo" por dicionário dá muitos falsos positivos com nomes próprios e listas; serve
  para priorizar a revisão, não para apagar.
- Parser de tabela só abre tabela se a linha seguinte for o separador `|---|`: linhas de OCR que
  começam e terminam com `|` não podem virar tabela por acidente.
