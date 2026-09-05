# telegram.ps1 — manda um recado curto ao Danilo pelo Hermes (bot de Telegram do Bora).
#
# O token do bot vive só na VPS. O cano é o mesmo dos alarmes do site do Guarda FC:
# SSH com a chave id_ed25519_vps → /root/hermes-shim/oneshot.py (prompt por stdin).
#
# Uso: powershell -File tool\vigia\telegram.ps1 -Texto "linha1`nlinha2`nlinha3"
param([Parameter(Mandatory=$true)][string]$Texto)
$chave = 'C:\Users\danil\.ssh\id_ed25519_vps'
$alvo  = 'root@srv1786862.hstgr.cloud'
$prompt = "Recado da missao Em Dia (app nova, Claude Code no PC do Danilo). Envia ao Danilo no Telegram, tal e qual, sem comentarios teus:`n$Texto"
$tmp = [IO.Path]::GetTempFileName()
[IO.File]::WriteAllText($tmp, $prompt, (New-Object System.Text.UTF8Encoding($false)))
$log = 'C:\BoraLocal\projetosflutter\em_dia\docs\telegram.log'
try {
  $resp = (Get-Content $tmp -Raw | ssh -i $chave -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=20 $alvo 'python3 /root/hermes-shim/oneshot.py' 2>&1 | Out-String).Trim()
  "[{0}] ENVIADO: {1} || resposta: {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), ($Texto -replace "`r?`n", ' / '), ($resp -replace "`r?`n", ' / ') | Out-File -Append -Encoding utf8 $log
  Write-Output $resp
} finally { Remove-Item $tmp -ErrorAction SilentlyContinue }
