# Lições aprendidas

> ## ⛔ Regra #0 — Nunca design com cara de IA
>
> Nenhuma tela, HTML, CSS ou layout pode parecer gerado por IA por omissão de decisão.
> "Cara de IA" = genericidade: reproduzir a média de landing pages de SaaS em vez de
> escolhas específicas ao domínio. Antes de gerar frontend, aplicar
> `skills/design/sem-cara-de-ia.md`.
> - **Padrão observado**: frontend sai genérico — gradiente índigo-violeta, Inter-em-tudo,
>   tudo centralizado, 3 cards idênticos, glassmorphism/blobs/glow, cópia de preenchimento.
> - **Regra para si mesmo**: conteúdo real primeiro; paleta e par tipográfico decididos;
>   ponto focal; densidade do domínio; aplicar o "teste da troca" antes de aprovar.
> - **Obrigatório em todo layout**: gerar artefato de preview com 3 opções distintas,
>   cada uma em light E dark, antes de implementar. Usuário escolhe primeiro, código depois.
> - **Cerne inspirador**: ancorar em sistema consolidado mundialmente (de preferência
>   90s/2000s) — herdar a lógica da era (proporção, affordance, densidade honesta,
>   restrição de paleta) e modernizar a execução (ícones, tokens, a11y, responsivo).

Capture aqui padrões identificados em correções do usuário, para evitar repetição em sessões futuras.

Formato sugerido para cada lição:

- **Padrão observado**: o que foi feito de errado.
- **Correção aplicada**: o que o usuário pediu para mudar.
- **Regra para si mesmo**: como evitar o mesmo erro no futuro.

## Next.js `<Image>` — `sizes` fora da lista configurada quebra em silêncio (visual, não build)

- **Padrão observado**: `<Image fill sizes="200px">` (ou uma expressão `vw` que resolve pra
  uma largura arbitrária) num projeto sem `images.imageSizes`/`deviceSizes` customizado no
  `next.config`. O componente renderiza normalmente em dev/build, mas em produção
  `/_next/image?...&w=200` responde 400 ("w parameter ... is not allowed") porque o Next só
  otimiza larguras que estejam na união de `imageSizes` (default
  `[16,32,48,64,96,128,256,384]`) e `deviceSizes` (default
  `[640,750,828,1080,1200,1920,2048,3840]`). O resultado visível é foto quebrada — sem erro
  nenhum no build, nenhum teste automatizado pega isso.
- **Correção aplicada**: trocar `sizes` por um valor fixo que já esteja na lista padrão
  (ex.: `"256px"`) para imagens pequenas tipo card/thumbnail, em vez de um valor "redondo"
  arbitrário ou uma expressão `vw` sem checar contra a config.
- **Regra para si mesmo**: ao definir `sizes` num `<Image>`, ou usar valores fixos que
  batam com o default do Next (16/32/48/64/96/128/256/384 pra imagens pequenas;
  640/750/828/1080/1200/1920/2048/3840 pra full-bleed), ou customizar
  `images.imageSizes`/`deviceSizes` no `next.config` pra cobrir o tamanho real desejado — e
  testar com `curl -I` no endpoint `/_next/image?...` em produção (ou build local), nunca
  assumir que "renderizou no browser" = "o otimizador aceita essa largura".

## Next.js + Docker: página com fetch de banco quebra o build se não for marcada dinâmica

- **Padrão observado**: um Server Component público (sem `auth()`/`cookies()`/`redirect()`
  — nada que force renderização dinâmica) faz uma query direta (ex.: `prisma.reward.findMany`)
  no corpo da função. Localmente com `npm run dev`/`npm run build` + `.env.local` presente,
  funciona sem erro algum. Mas no `docker build` de um Dockerfile multi-stage típico
  (`RUN npx prisma generate && RUN npm run build` no estágio `builder`, sem acesso às
  credenciais de banco — essas só chegam via `env_file` no `docker-compose` em runtime), o
  Next tenta pré-renderizar a página estaticamente nesse estágio e o build inteiro quebra
  com `PrismaClientInitializationError: Environment variable not found: DATABASE_URL`.
- **Correção aplicada**: adicionar `export const dynamic = "force-dynamic";` logo após
  `export const metadata` na página — mesmo padrão que já existia em outra página do mesmo
  projeto (`blog/page.tsx`) e que ninguém tinha replicado na página nova.
- **Regra para si mesmo**: qualquer Server Component público que faça fetch direto de banco
  (Prisma, ORM, etc.) sem nenhum outro sinal de dinamismo precisa de
  `export const dynamic = "force-dynamic"` (ou `noStore()`/`cookies()`) explícito — e o teste
  real disso é rodar `docker build` (ou `npm run build` com as env vars de banco
  **removidas** do shell) antes de assumir que "buildou local" prova que vai buildar no
  Dockerfile. Checar se o projeto já tem outras páginas com o mesmo padrão de fetch e copiar
  a solução, em vez de assumir que a primeira página nova com Prisma vai funcionar igual.

## `whitespace-pre-line` + template literal quebrado em várias linhas no código-fonte = bug visual

- **Padrão observado**: um array de conteúdo estático com strings longas escritas como
  template literal, quebradas em várias linhas só por legibilidade no arquivo-fonte (ex.:
  \`corpo: \`Frase que continua\n    na linha de baixo do arquivo\`\`), renderizado com
  `className="whitespace-pre-line"` pra preservar parágrafos reais (`\n\n`). Resultado: cada
  quebra de linha do CÓDIGO-FONTE (não intencional, só formatação) virou uma quebra visual
  real na página — o texto parece truncado numa coluna estreita mesmo com o container
  ocupando a largura inteira da tela. Sintoma enganoso: parece bug de CSS/largura de
  container (e a correção errada, mais óbvia, é mexer em `max-w`), quando na real é
  whitespace sendo preservado literalmente.
- **Correção aplicada**: remover `whitespace-pre-line` (não é mais necessário quando cada
  parágrafo real já vira um elemento `<p>` separado via `.split("\n\n")`) e normalizar
  espaço em branco de cada parágrafo com `.replace(/\s+/g, " ")` antes de renderizar.
- **Regra para si mesmo**: `whitespace-pre-line`/`white-space: pre-line` só é seguro em
  conteúdo onde CADA quebra de linha do valor da string é semanticamente intencional (ex.:
  vindo de um textarea de usuário). Nunca usar em conjunto com um template literal
  multi-linha só por legibilidade de código — ou remover os saltos de linha do
  código-fonte, ou não usar `pre-line`, ou normalizar o whitespace antes de renderizar.
  Ao investigar "texto não usa a largura da tela", checar primeiro se há preservação de
  whitespace ativa antes de mexer em `max-width`/container.

## Carrossel com sensação de "loop infinito contínuo" (não paginado)

- **Padrão observado**: usuário pede pra um carrossel parar de "pular tela a tela" (scroll
  ou `setInterval` com salto discreto de largura fixa) e ficar parecendo um loop contínuo
  de verdade, tipo esteira, mas mantendo controles manuais (setas) pra quem quiser adiantar.
- **Solução aplicada**: sem lib nova — (1) duplicar a lista de itens no DOM (renderizar o
  array duas vezes seguidas); (2) marcar a segunda cópia com `aria-hidden="true"` (não
  duplica pra leitor de tela); (3) em vez de `setInterval` + salto fixo, usar
  `requestAnimationFrame` incrementando `scrollLeft` por uma fração de pixel por quadro
  (ritmo lento e suave); (4) quando `scrollLeft` passa da largura de UMA cópia da lista
  (`trilha.scrollWidth / 2`), subtrair essa largura de `scrollLeft` sem transição — como o
  conteúdo dali em diante é idêntico (é a duplicata), o corte é imperceptível e dá a
  ilusão de loop infinito. Pausar o `requestAnimationFrame` em hover/foco (WCAG 2.2.2) e
  não rodar se `prefers-reduced-motion: reduce`. As setas continuam chamando `scrollBy` com
  um salto maior, funcionando em cima da posição que o loop automático já está mantendo.
- **Regra para si mesmo**: scroll-snap discreto (`snap-x snap-mandatory` + salto de ~1
  tela por vez) dá sensação de "slide a slide"; duplicar a lista + scroll contínuo por
  quadro dá sensação de "esteira"/loop infinito. São UX diferentes — perguntar qual o
  usuário quer antes de escolher a implementação, em vez de assumir que scroll-snap serve
  pra qualquer pedido de "carrossel".
