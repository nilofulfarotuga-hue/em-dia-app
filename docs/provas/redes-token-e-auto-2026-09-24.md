# Redes Em Dia — token do robô guardado e publicação automática ligada (24/09/2026)

Ordem do Danilo: "Guarda esse token do robô do Em Dia. E liga publicação automática."

## Token
- Meta `debug_token`: tipo SYSTEM_USER "robo-redes", app "Robo Redes Em Dia", `is_valid: True`, `expires_at: 0` (não expira).
  Permissões incluem `instagram_content_publish` e `pages_manage_posts`.
- Vê a página "Em Dia: Recibos e Impostos" (1371012642767049) e o Instagram @em_dia_app (17841424019153606).
- Token da página tirado dele: tipo PAGE, `expires_at: 0`. O robô usa este (`EMDIA_META_TOKEN`).
- Guardado em `C:\BoraLocal\_segredos\em-dia\redes.env` e em `/opt/data/emdia-redes/.env` na VPS (permissões 600). Nunca no repo.
- Teste de leitura na VPS: IG 200 `em_dia_app`, FB 200 `Em Dia: Recibos e Impostos`.

## Ensaio sem publicar
- URL público do R01: `https://social.srv1786862.hstgr.cloud/emdia-R01.mp4` → 200.
- Rascunho de Reel no Instagram (não publicado): contentor 18119111707800639, estado FINISHED.
- Facebook: não ensaiado sem publicar; a primeira prova real é a publicação desta noite.

## Fiscal de vídeo (mínimo 90)
Os 21 Reels chumbaram: notas de 64 a 89 (o R16 teve 89). Quase sempre por "movimento" baixo (mínimo 12, os vídeos têm 3 a 9).
A regra dos 90 não foi mexida.

## Defeito corrigido (tool/redes/emdia_redes.py)
Antes: quando um vídeo chumbava, o `hoje` voltava a escolhê-lo todas as noites e não publicava nada.
Agora: passa à peça seguinte; se a falha for da Meta ou da rede, pára (não publica outra).
As notas dos 21 Reels ficaram registadas (`redes_publicacoes`: 21 falhou IG + 21 falhou FB, notas 64–89).
Fila agora: 15 carrosséis (C01…C15) → `stock: 15 dias de pecas prontas`.

## Publicação automática
O relógio na VPS já estava ligado (hora a hora aos :05, `hoje` às 21:05 de Lisboa, stock às 08:15). Só faltavam as chaves da Meta.
Hoje às 21:05 sai o C01 no Instagram e no Facebook, depois um carrossel por dia.

## PARA O DANILO
Nenhum vídeo passa nos 90. Tens duas saídas: refazer os Reels com mais movimento, ou baixar o mínimo (por exemplo para 80, e aí passam 15 dos 21).
Até decidires, só saem carrosséis.
