# Publica o site público (site/) no Cloudflare Pages, projeto em-dia-site.
# Lê o token do .env do bora-site (nunca do repo). Uso:
#   powershell -ExecutionPolicy Bypass -File tool/site/publicar.ps1 [-Verificar]
# -Verificar corre depois o site/testes/verifica.mjs contra o site no ar.
param([switch]$Verificar)

$ErrorActionPreference = 'Stop'
$Raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$Site = Join-Path $Raiz 'site'
$EnvFile = 'C:\BoraLocal\Desktop-PC-antigo\bora-site\bora-site\.env'
$Conta = '2cd0212b0f5e5c8284aa227f629c050a'
$Projeto = 'em-dia-site'

if (-not (Test-Path $EnvFile)) { throw "Não encontro $EnvFile (o token da Cloudflare vive aí, fora do repo)." }
$linha = Get-Content $EnvFile | Where-Object { $_ -match '^CLOUDFLARE_API_TOKEN=' } | Select-Object -First 1
if (-not $linha) { throw 'CLOUDFLARE_API_TOKEN não está no .env.' }
$token = $linha.Substring('CLOUDFLARE_API_TOKEN='.Length).Trim().Trim('"')

# Regenerar media se faltar o vídeo (regenerável; o Bora Studio substitui depois)
if (-not (Test-Path (Join-Path $Site 'assets\video\heroi.mp4'))) {
  & 'C:\Users\danil\AppData\Local\Programs\Python\Python312\python.exe' (Join-Path $Raiz 'tool\site\preparar_media.py')
}

# Garantir que o projeto existe (idempotente)
$cab = @{ Authorization = "Bearer $token"; 'Content-Type' = 'application/json' }
try {
  Invoke-RestMethod -Method Get -Uri "https://api.cloudflare.com/client/v4/accounts/$Conta/pages/projects/$Projeto" -Headers $cab | Out-Null
  Write-Host "Projeto $Projeto já existe."
} catch {
  Write-Host "A criar o projeto $Projeto..."
  $corpo = @{ name = $Projeto; production_branch = 'main' } | ConvertTo-Json
  Invoke-RestMethod -Method Post -Uri "https://api.cloudflare.com/client/v4/accounts/$Conta/pages/projects" -Headers $cab -Body $corpo | Out-Null
}

$env:CLOUDFLARE_API_TOKEN = $token
$env:CLOUDFLARE_ACCOUNT_ID = $Conta
Push-Location $Raiz
try {
  npx -y wrangler pages deploy $Site --project-name=$Projeto --branch=main --commit-dirty=true
} finally {
  Pop-Location
  Remove-Item Env:CLOUDFLARE_API_TOKEN -ErrorAction SilentlyContinue
}

if ($Verificar) {
  Start-Sleep -Seconds 8   # o Pages demora uns segundos a servir a versão nova (regra 8.4 da skill)
  node (Join-Path $Site 'testes\verifica.mjs') "https://$Projeto.pages.dev"
}
