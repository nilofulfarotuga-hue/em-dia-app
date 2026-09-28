# Redes do Em Dia — pasta de trabalho

Missão `redes-em-dia-2026-09-23`. Marca separada do Bora. **Nada foi publicado**: tudo aqui está pronto a agendar.

## O que há aqui

| Ficheiro / pasta | O que é |
|---|---|
| `LIVRO-DE-REGRAS-REDES.md` | Referências (Artur, MaisMei, Keeper, …), formatos, ganchos, cores, ritmo, o que converte, o que o juiz reprovou |
| `CALENDARIO-30-DIAS.md` | 66 publicações de 28/09 a 27/10/2026: data, hora, rede, formato, público, gancho, **texto final**, hashtags, ficheiro |
| `meta-carregamento-em-massa.csv` | As 36 publicações de feed (15 carrosséis + 21 reels) para o carregamento em massa. Também partido em `…-lote1.csv` (25) e `…-lote2.csv` (11) |
| `GRUPOS-PORTUGAL.md` | 27 grupos de Facebook (TVDE, estafetas, recibos verdes, brasileiros, freelancers, empresários), textos base e ritmo |
| `BIO-INSTAGRAM.md` | Nome, bio (112 caracteres), link, e os textos da página do Facebook |
| `pecas/carrosseis/C01…C15/` | 15 carrosséis, 99 lâminas PNG 1080×1350 |
| `pecas/reels/R01…R21.mp4` | 21 reels MP4 1080×1920, 12-14 s (12,0–13,8), com música própria, + a capa de cada um (`-capa.jpg`) |
| `pecas/stories/S01…S30.png` | 30 stories 1080×1920 |
| `pecas/perfil/` | Foto de perfil, capa do Facebook (1640×624 e 851×315), 6 capas de destaques, cartaz A5 com QR para imprimir |
| `capturas/` | 19 ecrãs verdadeiros da app no modo exemplo (a Maria), 1170×2532 |
| `revisao/` | Folhas de contacto para rever tudo de uma vez |

## Como agendar (Meta Business Suite)

1. **Antes:** o ramo tem de estar no `main` (os ficheiros ficam públicos em `raw.githubusercontent.com/…/main/…`,
   que é o endereço que está na coluna das imagens do CSV). O repositório é público.
2. business.facebook.com → página **Em Dia: Recibos e Impostos** → ligar o Instagram quando existir
   (Definições → Contas ligadas).
3. **Planeador → Carregamento em massa → Transferir ficheiro de exemplo.** Guarda-o.
4. Os nomes das colunas do exemplo da Meta **não foram confirmados** nesta sessão (facebook.com bloqueado). Por isso:
   `python tool/redes/csv_meta.py ~/Downloads/<exemplo>.csv` → cria `meta-carregamento-em-massa-FORMATO-META.csv`
   com os cabeçalhos exatos da Meta (o script diz que colunas não conseguiu preencher).
   Sem Python: abre o exemplo e o nosso CSV lado a lado e copia coluna a coluna (Título, Descrição, Ligação, Média, Data/hora).
5. Carrega o CSV (no máximo 25 de cada vez — usa os lotes). Confere 2-3 publicações no calendário antes de confirmar.
6. Se o carregamento em massa **não aceitar carrosséis ou Instagram**: esses agendam-se à mão no mesmo Planeador
   (Criar publicação → escolher as duas contas → carregar as lâminas por ordem → colar o texto do `CALENDARIO-30-DIAS.md`).
7. **Stories:** Criar story → carregar o PNG do dia → pôr o autocolante de link (`app.emdia.boraguarda.com`) e, nos de
   sondagem/perguntas, o autocolante indicado no calendário → agendar.
8. Música dos reels: é original (gerada por código, sem direitos de terceiros). Se quiseres, troca na app do Instagram
   por um som em tendência antes de publicar — o texto dos reels não depende do som.

## Como se refaz

Ver secção 9 do `LIVRO-DE-REGRAS-REDES.md`. Todo o conteúdo está em `tool/redes/conteudo.py`.
