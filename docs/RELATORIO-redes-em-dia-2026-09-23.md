# RELATÓRIO — redes-em-dia-2026-09-23

**Porta:** Claude Code (nuvem), repo `em-dia-app`, ramo `redes-em-dia-2026-09-23` (a partir de `main` 23b7e4b).
**Nada foi publicado em rede nenhuma.** Tudo em `docs/marketing/redes-em-dia/`.

## Feito

| # | Entrega | Onde | Prova |
|---|---|---|---|
| 1 | Livro de regras (referências de 12 marcas, formatos, ganchos, cores, ritmo, o que converte, juiz) | `docs/marketing/redes-em-dia/LIVRO-DE-REGRAS-REDES.md` | fontes na tabela; limites da pesquisa na secção 0 |
| 2 | Calendário 30 dias (28/09 → 27/10/2026): 66 publicações — 21 reels, 15 carrosséis, 30 stories — com data, hora, rede, formato, público, gancho, texto final, hashtags e ficheiro | `…/CALENDARIO-30-DIAS.md` | gerado por `tool/redes/gerar.py` |
| 3 | Peças: 15 carrosséis (99 lâminas 1080×1350), 21 reels MP4 9:16 com som (12,0–13,8 s, nenhum plano > 4 s), 30 stories, foto de perfil, capa do Facebook (1640×624 e 851×315), 6 capas de destaques, cartaz A5 com QR, bio | `…/pecas/`, `…/BIO-INSTAGRAM.md` | `docs/provas/redes-em-dia-2026-09-23.md` (ffprobe, contagens, medidas) |
| 4 | CSV para o carregamento em massa (36 linhas de feed; lotes de 25 + 11) + conversor para os cabeçalhos exatos da Meta | `…/meta-carregamento-em-massa*.csv`, `tool/redes/csv_meta.py` | ver «Bloqueado» abaixo |
| 5 | 27 grupos de Facebook com link, textos base PT-PT e PT-BR, ritmo humano e calendário de 1 grupo/dia | `…/GRUPOS-PORTUGAL.md` | tamanho e regras por confirmar (facebook.com bloqueado) |
| 6 | Relatório + linha no `e2e_log` (fluxo `redes-em-dia-2026-09-23`) + linha em `docs/MARCOS.md` | este ficheiro | SELECT na prova |

**Ecrãs verdadeiros:** a app não estava acessível pela rede (`app.emdia.boraguarda.com` bloqueado pelo proxy), por isso
os 19 ecrãs foram tirados da app a sério, compilada aqui (Flutter 3.47.2, o do CI), no modo exemplo (a Maria), com o dia
de hoje: `tool/redes/capturas_test.dart` → `docs/marketing/redes-em-dia/capturas/` (1170×2532). Nenhum dado de pessoa real.

**Números legais:** todos de `docs/REGRAS-PT-2026.md`, com a fonte na lâmina e na legenda. Regras `por_confirmar` não
entraram. Exemplo de conta usado: 1.200 € × 70 % × 21,4 % = 179,76 € (é o mesmo valor que a app mostra à Maria).

**Promessa** («Por agora está tudo aberto e não se paga nada. Quando as assinaturas abrirem, avisamos com 30 dias de
antecedência e ninguém é cobrado sem dizer que sim.») + «grátis, sem cartão»: nas 36 legendas, na última lâmina dos 15
carrosséis, no fim dos 21 reels, no cartaz e na bio da página. Um só link: `https://app.emdia.boraguarda.com`.

**Imagens de IA:** não usadas. O texto, os ecrãs e o logótipo entram por código; não houve cenários fotográficos nesta leva.

## Bloqueado (saltado, segui)

1. **Formato oficial do CSV da Meta não confirmado.** `facebook.com` (ajuda da Meta, Biblioteca de Anúncios, grupos) está
   bloqueado pelo proxy desta sessão (`EGRESS_BLOCKED`). Fontes secundárias: Planeador → Carregamento em massa →
   «Transferir ficheiro de exemplo»; até 25 publicações por carregamento. O CSV usa nomes descritivos e o
   `tool/redes/csv_meta.py` reescreve-o com os cabeçalhos exatos do ficheiro de exemplo (1 comando). Se o carregamento em
   massa não aceitar carrosséis/Instagram, o `README.md` da pasta diz como agendar à mão.
2. **Biblioteca de Anúncios e perfis de Instagram das referências:** não abertos (mesmo bloqueio). A tabela do livro vem
   de resultados de pesquisa com fonte; falta guardar capturas (5 minutos com sessão no Facebook — está no livro, secção 0).
3. **Grupos:** nomes e links encontrados; membros e regras por confirmar ao entrar.
4. **Imagens dos ficheiros no CSV** apontam para `raw.githubusercontent.com/…/main/…`: só funcionam depois do merge para
   `main` (o repositório é público).

## Fora de scope (encontrado, não corrigido)

1. **Etiqueta «Mês grátis até dd/mm» no painel** (`painelEtiquetaTrial`, `lib/l10n/partes/20_painel_pt.arb`) e
   «Nos próximos 30 dias tens tudo aberto» no fim do onboarding contradizem a promessa atual «por agora está tudo aberto e
   não se paga nada». Nas peças, o painel foi cortado abaixo do cabeçalho.
2. **Inspeção TVDE:** o ecrã do carro diz «TVDE: inspeção todos os anos (ainda por confirmar)», mas
   `docs/REGRAS-PT-2026.md` dá-a como verificada a 2026-09-18 (Lei 45/2018, art. 12.º). Uma das duas está desatualizada.
   As peças não usam esta regra.
3. **`docs/loja/play/captura-1.png`** mostra «Olá, Danilo» (nome de pessoa real) numa captura da loja; o resto das peças
   usa a Maria do modo exemplo.
4. Declaração trimestral da SS: a agenda da app conta o prazo até 02/11 (31/10 sábado + 1/11 feriado, dia útil seguinte);
   as peças dizem, por prudência, «31 é sábado: trata até sexta, 30». Não é erro — fica anotado para ninguém estranhar.

## Como continuar

1. Merge do PR para `main` (os ficheiros ficam públicos para o CSV).
2. Business Suite: transferir o ficheiro de exemplo → `python tool/redes/csv_meta.py <exemplo>.csv` → carregar os lotes.
3. Criar o Instagram com `BIO-INSTAGRAM.md`, foto e destaques de `pecas/perfil/`; ligar à página.
4. Grupos: seguir `GRUPOS-PORTUGAL.md` (2 semanas a ajudar antes de publicar link).
5. Ao fim de 7 dias: ver guardados, envios e cliques por peça; medir contas novas no admin.
