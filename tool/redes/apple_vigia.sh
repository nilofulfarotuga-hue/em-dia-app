#!/bin/bash
# E0 da missao emdia-redes-2026-09-28: de 6 em 6 h ve se o Em Dia ja esta na App Store (pagina publica,
# sem chave). No dia em que aparecer avisa o Danilo UMA vez. A troca do texto promocional e feita pelo
# workflow ios-ficha do GitHub (tem a chave da Apple). Fim verificavel: ficheiro apple_aprovada.flag.
D=/opt/data/emdia-redes; F=$D/apple_aprovada.flag
[ -f "$F" ] && { echo "$(date -Is) ja avisado"; exit 0; }
J=$(curl -s --max-time 30 "https://itunes.apple.com/lookup?id=6814807320&country=pt")
N=$(echo "$J" | jq -r ".resultCount // \"erro\"")
echo "$(date -Is) lookup resultCount=$N"
if [ "$N" = "erro" ]; then exit 1; fi
if [ "$N" -ge 1 ]; then
  V=$(echo "$J" | jq -r ".results[0].version")
  /opt/data/scripts/gritar.sh "Em Dia: a Apple aprovou e a app ja esta na App Store (versao $V). O texto promocional novo entra sozinho na proxima volta do ios-ficha (ate 6 h). Link: https://apps.apple.com/pt/app/id6814807320" && date -Is > "$F"
  echo "- [$(date -Is)] apple-vigia: na loja (versao $V), Danilo avisado" >> $D/log.md
fi
