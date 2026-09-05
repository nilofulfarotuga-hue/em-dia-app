# DESIGN SYSTEM — Em Dia

> Escrito ANTES da primeira tela (adenda B da missão, 2026-09-06 00:40), a partir das capturas REAIS
> em `docs/referencias/` (MEI Fácil, MaisMei, Drivvo, Rocket Money — Play Store) e do site do Artur
> (appartur.pt, texto indexado). Regra: copiar a ESTRUTURA e a clareza, nunca o visual literal. Marca própria.
> O fiscal visual compara cada tela com a referência da mesma função e reprova se ficar mais confusa que a original.

## 1. O que cada referência ensina (e o que se copia)

| Referência | Captura | O que faz bem | O que o Em Dia copia (estrutura) |
|---|---|---|---|
| **MEI Fácil** | `referencias/mei-facil/01.png` | Cartão-herói escuro "PRÓXIMO DAS — Em 11 dias — 20 de julho — R$ 82,50" com dois botões (**Marcar pago** / Boleto); alerta vermelho "6 DAS atrasados" com a consequência escrita; barra "0,2% do limite de R$ 81.000" | O cartão **Próximo prazo** do painel (contagem regressiva + valor + botão "Já paguei"); o alerta vermelho com consequência ("perdes a isenção"); a barra da **Vigia do IVA** ("estás em X de 15.000 €") |
| **MaisMei** | `referencias/maismei/01.png` | "Oi, Juliana 👋"; **Acessos rápidos** em grelha de 2 colunas com ícone; guias em "stories" | Saudação humana no topo do painel; grelha 2×N do ecrã **Mais** e dos **Guias** |
| **Drivvo** | `referencias/drivvo/01.png` | Selector de carro no topo ("Meu carro · Toyota Corolla · 83 765 km"); **lembretes** em cartões com barra colorida à esquerda ("Troca de óleo · Em 205 km · Hoje"; "Seguro · Em 2 dias"); linha do tempo com resumo do mês ("R$ 1 632 · 950 km · 11,45 km/L") e ícones redondos por tipo; FAB "+" | O ecrã **O Carro**: selector de carro, cartões de lembrete com barra lateral na cor do semáforo, linha do tempo de abastecimentos/despesas com resumo mensal (€, km, €/km), botão "+" |
| **Rocket Money** | `referencias/rocket-money/01.png` | "Coming up: **4** recurring charges in the next 7 days for **$2,459**" com mini-calendário; listas por horizonte (**COMING UP** / **COMING LATER**); cada linha: ícone, nome, "in 6 days", valor | O **Calendário**: frase-resumo no topo ("Este mês pagas N coisas: X €"), mini-calendário com os dias marcados, secções **Hoje · Esta semana · Este mês · Mais tarde**; linha = ícone + nome + "faltam N dias" + valor |
| **Artur** (appartur.pt) | texto indexado | "O dinheiro do Estado não é teu": separa **IVA a entregar / Segurança Social a reservar / IRS estimado** com valores; "IVA · entregar até 20 mai — Faltam 12 dias"; passos 1-2-3 (emites o recibo → separa os impostos → avisa-te a tempo); "Saldo 6 219 € — não é tudo teu" | A **calculadora de recibo** (bruto → retenção → IVA → "o que recebes" e "o que é teu"); o cartão **Guardar para o IRS**; a frase "não é tudo teu" na provisão; o site com a calculadora aberta |
| **SS Direta / Portal das Finanças** | (capturas nos guias, bloco 6) | Só para os guias "como pagar" | Passo a passo com captura real, texto para copiar |

O que NÃO se copia: fundos escuros com brilhos (MEI Fácil), amarelo-limão/azul (MaisMei), teal (Drivvo), vermelho-magenta (Rocket). A cor do Em Dia é o semáforo.

## 2. Paleta

| Nome | Hex | Uso |
|---|---|---|
| **Em dia (verde)** | `#16A34A` | primário, botões, semáforo verde, "pago" |
| verde escuro | `#15803D` / `#065F46` | texto sobre verde claro, hover |
| verde claro | `#DCFCE7` / `#F0FDF4` | fundos de cartão "em dia", chips selecionados |
| **A vencer (laranja)** | `#F97316` | semáforo amarelo/laranja, "faltam N dias" ≤ 5, barras de lembrete |
| laranja claro | `#FFEDD5` | fundo de aviso |
| **Passou (vermelho)** | `#DC2626` | semáforo vermelho, prazo passado, erros |
| vermelho claro | `#FEE2E2` | fundo do alerta |
| fundo | `#F6F7F4` | scaffold (claro, ligeiramente verde-acinzentado) |
| superfície | `#FFFFFF` | cartões |
| superfície 2 | `#F1F3EF` | chips, tiles de acesso rápido |
| divisor | `#E5E7EB` | linhas, bordos de input |
| texto | `#111827` / `#6B7280` / `#9CA3AF` | principal / secundário / subtil |
| informação | `#2563EB` / `#DBEAFE` | dicas, links |
| cadeado (Pro) | `#7C3AED` / `#EDE9FE` | funcionalidades trancadas |

Regra do laranja: **1 elemento laranja por ecrã** (herdada do Bora) — o laranja é o "a vencer", não decoração.
Sem modo escuro nesta fase (fundo claro, decisão da missão). Contraste mínimo 4,5:1 em texto.

## 3. Tipografia — Inter, sempre explícita

`fontFamily: 'Inter'` em TODOS os estilos (lição do Bora: um `fontFamily: null` num botão troca para Roboto só ali).

| Papel | Tamanho / peso | Onde |
|---|---|---|
| display | 40 / 800 | número gigante (contagem "Em 11 dias", valor a guardar) |
| headlineLarge | 28 / 800 | título de ecrã do onboarding ("O que fazes?") |
| headlineMedium | 24 / 700 | título do semáforo |
| headlineSmall | 20 / 700 | títulos de secção/dialog |
| titleLarge/Medium | 18 / 16 · 700 / 600 | nomes de itens, valores |
| bodyLarge/Medium | 17 / 15 · 400, altura 1,45 | texto corrido (grande de propósito: público pouco digital) |
| bodySmall | 13 / 400 cinzento | ajuda, rodapés |
| label | 16 / 600 | botões |

Mínimo em qualquer texto útil: **13 px**. Nada de maiúsculas gritadas em títulos (só nas etiquetas de secção, 12 px, espaçadas).

## 4. Espaçamento, cantos, sombras

- Grelha de 4: espaços 4 · 8 · 12 · 16 · 20 · 24 · 32. Padding do ecrã **20 px** laterais.
- Entre cartões: 12 px. Dentro do cartão: 16 px (herói: 20/24).
- Cantos: cartões **16**, inputs/chips **12**, pílulas 999, bottom sheet 24 no topo.
- Sombras: cartão `0 2 8 rgba(15,23,42,.08)`; grande `0 8 24 rgba(15,23,42,.12)`. Sem elevação Material (elevation 0 + sombra própria).
- Alvo de toque mínimo **48 px**; botões principais **56 px** de altura, largura total.

## 5. Componentes (em `lib/widgets/widgets.dart`)

- **SemaforoGrande** — bloco colorido de topo do painel: ícone 56, título 24/700 branco, subtítulo. Verde "Está tudo em dia" · laranja "Tens 1 coisa a vencer em 5 dias" · vermelho "Tens 1 prazo passado — resolve agora".
- **Cartao** — branco, cantos 16, sombra de cartão; variante com bordo (selecionado) e tocável.
- **Cartão-herói do próximo prazo** (MEI Fácil): fundo na cor do semáforo do item, etiqueta "PRÓXIMO PRAZO", número grande "Em 11 dias", linha "20 de julho · 149,80 €", botões "Já paguei" (branco) + "Como pagar" (contorno branco).
- **Linha de obrigação** (Rocket/Drivvo): círculo com ícone do tipo, nome curto, "faltam N dias / é hoje / passou há N dias", valor à direita, barra lateral 4 px na cor do estado.
- **BotaoGrande** — primário verde 56 px; secundário contorno; estado a trabalhar com spinner.
- **BotaoEscolha** — opção do onboarding: ícone 30, texto 16/600, ajuda 13, check quando selecionado; uma pergunta por ecrã, 2–6 opções empilhadas.
- **Cadeado** — conteúdo baço a 45% + pílula roxa "Isto é do plano Pro · Ativa o Pro para…" (explicação de UMA linha).
- **Aviso** — caixa colorida (tom do semáforo) com ícone e texto; a consequência escrita ("perdes a isenção JÁ").
- **Etiqueta** — pílula pequena (estado, plano, "aproximado").
- **LinhaValor** — "nome … valor" alinhado, com destaque para o total ("O que recebes mesmo").
- **Vazio** — ícone cinzento + frase humana + ação.
- **Barra da vigia** — LinearProgress 12 px, cantos 6, cor pelo nível (verde/laranja/vermelho), texto "Estás em 8.000 € de 15.000 €".

## 6. Navegação

5 abas (NavigationBar, ícones Material *rounded*): **Painel · Recibos · Calendário · Carro · Mais**. O ecrã **Mais** é a grelha 2×N (MaisMei): Reforma e direitos, Guias, Pergunta ao Em Dia, Ajuda, O teu plano, Definições, Sair. Sem gavetas laterais. Onboarding sem barra de abas, com barra de progresso fina no topo (6 passos).

## 7. Tom das mensagens

- Tratamento por **tu**, frases curtas, uma ideia por frase, como para uma criança de 5 anos. Jargão só com explicação entre parênteses: "IUC (o imposto do carro)", "retenção (o que o cliente guarda para as Finanças)".
- Nunca assustar sem solução: "Passou o dia 20 e não marcaste como pago. Não é o fim do mundo: paga hoje, os juros são pequenos."
- Cada aviso termina com o passo concreto e o prazo.
- Números: `1.234,56 €`; datas `dd/mm/aaaa` ou "20 de julho"; "faltam 5 dias" em vez de "5d".
- PT-PT na app; PT-BR no admin; a IA responde na variante de quem pergunta.

## 8. Estados obrigatórios por ecrã

Carregar (skeleton cinzento, nunca spinner a meio de tudo) · vazio (Vazio) · erro de rede ("Sem ligação. Tenta outra vez daqui a bocado.") · sem dados do perfil (convite a completar) · cadeado (plano).

## 9. Golden tests (fábrica de fotos)

Cada ecrã fotografado a **360×780, 390×844, 430×932** (pequeno/médio/grande), com e sem teclado (viewInsets 300), em **PT-PT e PT-BR** (textos maiores partem layouts). Overflow = falha. Fotos em `test/golden/_fotos/`; o juiz de visão lê-as.

## 10. Critério do fiscal visual (reprovação)

Reprova se: (1) o ecrã tiver mais elementos que a referência da mesma função; (2) o número mais importante não for o maior do ecrã; (3) houver mais de um laranja; (4) um botão principal não estiver visível sem scroll; (5) um texto útil < 13 px; (6) faltar o passo concreto num aviso; (7) um jargão sem explicação.
