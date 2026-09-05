# telegram.ps1 — manda um recado curto ao Danilo pelo bot de Telegram do Bora.
#
# O token do bot vive SÓ na VPS (/opt/data/.env). Nunca vem para este PC: o texto vai em
# base64 como ARGUMENTO do comando remoto (o stdin do ssh a partir do PowerShell chega
# estropiado — provado 2026-09-05 23:55) e o script /root/em-dia-telegram.sh faz o curl lá
# dentro, devolvendo só "ok=True msg_id=N erro=None".
# (O oneshot.py do Hermes NÃO tem ferramenta de Telegram — provado 2026-09-05 23:44.)
#
# Uso: powershell -File tool\vigia\telegram.ps1 -Texto "linha1`nlinha2`nlinha3"
param([Parameter(Mandatory=$true)][string]$Texto)
$chave = 'C:\Users\danil\.ssh\id_ed25519_vps'
$alvo  = 'root@srv1786862.hstgr.cloud'
$log   = 'C:\BoraLocal\projetosflutter\em_dia\docs\telegram.log'
$msg   = "EM DIA (missao, modo noite)`n" + $Texto
$b64   = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($msg))
$resp  = (ssh -i $chave -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=20 $alvo "bash /root/em-dia-telegram.sh $b64" 2>&1 | Out-String).Trim()
"[{0}] {1} || {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $resp, ($Texto -replace "`r?`n", ' / ') | Out-File -Append -Encoding utf8 $log
Write-Output $resp
