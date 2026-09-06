#!/bin/bash
# Grava, num emulador Android (emulator-5554), a entrada completa no Em Dia:
# instalar o APK → pedir código → Turnstile → ler o código na Resend → escrever
# → onboarding (5 perguntas) → simulação → guia → painel. Tudo com `adb`.
#
# Porquê à mão com coordenadas: a app é Flutter (sem ids de vista) e o Pixel 6
# do AVD `emdia` tem 1080×2400 a 420 dpi = 411 dp de largura, o mesmo desenho
# que a web a 412 px. As coordenadas abaixo foram lidas em capturas de ecrã
# reais (docs/provas/entrada-emulador-2026-09-06/). Se o desenho mudar, mudam.
#
# A gravação é feita DENTRO do aparelho com `nohup screenrecord … &`: um
# `adb shell screenrecord` lançado em segundo plano no PC morre quando o
# stdin fecha (cicatriz 2026-09-06: três "gravações" que nunca existiram).
#
# Uso: bash tool/provas/emulador_entrada.sh <apk> <email> <pasta-de-saida>
set -u
APK="$1"; EMAIL="$2"; OUT="$3"
A=/c/Users/danil/AppData/Local/Android/Sdk/platform-tools/adb.exe
RK=$(tr -d '\r\n' < /c/BoraLocal/_segredos/em-dia/resend.key)
mkdir -p "$OUT"
sh() { MSYS_NO_PATHCONV=1 "$A" -e shell "$@"; }
tap() { "$A" -e shell input tap "$1" "$2"; sleep "${3:-1.5}"; }
foto() { "$A" -e exec-out screencap -p > "$OUT/$1.png"; }
grava() { sh "nohup screenrecord --time-limit 180 --bit-rate 4000000 /sdcard/$1.mp4 >/dev/null 2>&1 &"; sleep 1; }

T0=$(date -u +%s)
sh "am force-stop pt.emdia.app; pm uninstall pt.emdia.app" >/dev/null 2>&1
sh "input keyevent 3"; sleep 1
grava seg1
"$A" -e install -r "$APK" | tail -1
sleep 1; foto 01-instalado
"$A" -e shell am start -n pt.emdia.app/.MainActivity >/dev/null; sleep 7; foto 02-entrada
tap 537 945 1; "$A" -e shell input text "$EMAIL"; "$A" -e shell input keyevent 111; sleep 1; foto 03-email
tap 537 1140 24; foto 04-turnstile          # o invisível espera 20 s antes de mostrar a caixa
# A caixa "Verify you are human": toca-se e espera-se até o botão ficar verde
# (o pixel do botão diz se está ligado). Até 4 tentativas.
verde() { "$A" -e exec-out screencap -p > "$OUT/_p.png"; python -c "
from PIL import Image; r,g,b=Image.open(r'$OUT/_p.png').convert('RGB').getpixel((537,1572))[:3]; print(1 if g>120 and r<80 else 0)"; }
for t in 1 2 3 4; do
  tap 105 1152 7
  [ "$(verde)" = "1" ] && break
  sleep 5
done
foto 05-turnstile-caixa
tap 537 1572 8; foto 06-codigo-pedido         # Enviar código (posição com a caixa visível)

# O código: lê-se na Resend (o e-mail chega em segundos)
CODIGO=""
for i in $(seq 1 20); do
  CODIGO=$(python - "$RK" "$EMAIL" "$T0" <<'PY'
import sys, json, re, time, urllib.request
k, email, t0 = sys.argv[1], sys.argv[2].lower(), int(sys.argv[3])
req = urllib.request.Request("https://api.resend.com/emails?limit=6", headers={"Authorization": "Bearer " + k, "User-Agent": "em-dia-prova/1"})
d = json.load(urllib.request.urlopen(req, timeout=20))
for e in d.get("data", []):
    if email in [t.lower() for t in (e.get("to") or [])]:
        criado = time.mktime(time.strptime(e["created_at"][:19], "%Y-%m-%d %H:%M:%S")) if " " in e["created_at"][:19] else time.mktime(time.strptime(e["created_at"][:19], "%Y-%m-%dT%H:%M:%S"))
        if True:  # o mais recente para este endereço chega (o endereço é novo por passagem)
            r2 = urllib.request.Request("https://api.resend.com/emails/" + e["id"], headers={"Authorization": "Bearer " + k, "User-Agent": "em-dia-prova/1"})
            c = json.load(urllib.request.urlopen(r2, timeout=20))
            txt = c.get("text") or re.sub(r"<[^>]+>", " ", c.get("html") or "")
            m = re.search(r"\b(\d{6})\b", txt)
            if m:
                print(m.group(1)); print(e["id"], e["created_at"], e.get("last_event"), file=sys.stderr)
            break
PY
)
  [ -n "$CODIGO" ] && break
  sleep 3
done
echo "codigo=$CODIGO"
[ -z "$CODIGO" ] && { echo "sem código na Resend"; exit 1; }

grava seg2
tap 123 1020 1; "$A" -e shell input text "$CODIGO"; sleep 10; foto 07-onboarding-boas-vindas
tap 537 2220 2; foto 08-q1
tap 537 527 2; foto 09-q2                     # Motorista TVDE → avança sozinho
tap 332 695 2; tap 165 945 1.5                # Mês → março
tap 837 695 2; tap 750 207 1.5; foto 10-q2-preenchida   # Ano → 2026
tap 537 2220 2; foto 11-q3
tap 537 965 1.5; tap 537 2220 2; foto 12-q4   # IVA: Não → Continuar
tap 790 515 1.5; tap 537 2220 2; foto 13-q5   # Carro: Não → Continuar
tap 415 927 1.5; tap 537 2220 7; foto 14-simulacao   # 1.200 € → Continuar
grava seg3
tap 537 2220 5; foto 15-guia-1                # Entrar na app
tap 537 2220 2; foto 16-guia-2                # Seguinte
tap 537 2220 2; foto 17-guia-3                # Seguinte
tap 537 2220 8; foto 18-painel                # Começar → painel
sleep 4
sh "pkill -INT screenrecord" ; sleep 4
for s in seg1 seg2 seg3; do MSYS_NO_PATHCONV=1 "$A" -e pull "/sdcard/$s.mp4" "$OUT/$s.mp4" >/dev/null && ls -la "$OUT/$s.mp4" | awk '{print $5, $9}'; done
