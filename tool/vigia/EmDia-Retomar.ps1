# EmDia-Retomar.ps1 — o vigia da noite (adenda A.4 da missão, 2026-09-05)
#
# Corre de 20 em 20 minutos pela tarefa agendada `EmDia-Retomar`.
#   1. Se docs/MARCOS.md tiver a linha MISSAO-CONCLUIDA → apaga a própria tarefa e sai.
#   2. Se a tranca docs/.sessao-viva foi renovada há menos de 20 min → "sessão viva, saio".
#   3. Se já há uma retoma a correr (docs/.vigia-pid com processo vivo) → sai.
#   4. Senão: git pull (a rotina cloud pode ter empurrado), e lança
#      `claude --resume <sessão> -p "Lê docs/MARCOS.md e continua do PRÓXIMO. Modo noite."`
#      Se o limite do plano ainda não repôs, o claude falha depressa e fica no log;
#      daqui a 20 min tenta outra vez. Quando repuser, retoma sozinho.
#
# "Result 0" da tarefa não é prova: prova é docs/vigia.log com linhas novas.

$ErrorActionPreference = 'Continue'
$Repo      = 'C:\BoraLocal\projetosflutter\em_dia'
$Docs      = Join-Path $Repo 'docs'
$Log       = Join-Path $Docs 'vigia.log'
$Tranca    = Join-Path $Docs '.sessao-viva'
$Marcos    = Join-Path $Docs 'MARCOS.md'
$PidFile   = Join-Path $Docs '.vigia-pid'
$SessaoId  = 'c51cb931-0ec0-4bb4-bb6f-e956090318aa'
$ClaudeCmd = 'C:\Users\danil\AppData\Roaming\npm\claude.cmd'
$TokenEnv  = 'C:\BoraLocal\_segredos\em-dia\claude-oauth.env'
$TrancaMin = 20   # minutos sem renovação = sessão parada

function L([string]$m) {
  $linha = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m
  $linha | Out-File -Append -Encoding utf8 $Log
}

New-Item -ItemType Directory -Force $Docs | Out-Null
# preciso disto já no passo 2 (procura do transcript), não só no passo 4
$env:CLAUDE_CONFIG_DIR = 'C:\Users\danil\.claude'
L ("arranque (origem: {0})" -f $(if ($args.Count -gt 0) { $args -join ' ' } else { 'agendador' }))

# 1. missão concluída → desligar-se
if ((Test-Path $Marcos) -and (Select-String -Path $Marcos -Pattern '^MISSAO-CONCLUIDA' -Quiet)) {
  L 'MISSAO-CONCLUIDA encontrada: apago a tarefa EmDia-Retomar e saio'
  try { Unregister-ScheduledTask -TaskName 'EmDia-Retomar' -Confirm:$false -ErrorAction Stop; L 'tarefa apagada' } catch { L ("nao consegui apagar a tarefa: " + $_.Exception.Message) }
  exit 0
}

# 2. sessão viva?
#
# CICATRIZ (2026-09-06): a tranca só é renovada quando a sessão se LEMBRA de o
# fazer, e entre respostas passam-se facilmente 20 minutos. Bastou isso para o
# vigia achar que a sessão tinha morrido e lançar outra POR CIMA de uma viva —
# duas sessões a escrever no mesmo repositório e na mesma base de dados de
# produção ao mesmo tempo. Nesse dia todos os dados de utilizador desapareceram
# (docs/provas/apagao-dados-2026-09-06.md).
#
# Por isso agora há DUAS provas de vida, e basta uma:
#   a) a tranca docs/.sessao-viva;
#   b) o transcript da sessão, que CRESCE sempre que a sessão trabalha, seja ela
#      interactiva ou lançada por este vigia — essa não depende de ninguém se
#      lembrar de nada.
$vivo = $false
if (Test-Path $Tranca) {
  $idade = (Get-Date) - (Get-Item $Tranca).LastWriteTime
  if ($idade.TotalMinutes -lt $TrancaMin) {
    L ("sessão viva, saio (tranca renovada há {0:N1} min)" -f $idade.TotalMinutes)
    $vivo = $true
  } else {
    L ("tranca velha ({0:N0} min)" -f $idade.TotalMinutes)
  }
} else {
  L 'sem tranca'
}

if (-not $vivo) {
  $padrao = Join-Path $env:CLAUDE_CONFIG_DIR ('projects\*\' + $SessaoId + '.jsonl')
  $transcript = Get-ChildItem $padrao -ErrorAction SilentlyContinue |
                Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($transcript) {
    $idadeT = (Get-Date) - $transcript.LastWriteTime
    if ($idadeT.TotalMinutes -lt $TrancaMin) {
      L ("sessão viva pelo transcript, saio (escreveu há {0:N1} min)" -f $idadeT.TotalMinutes)
      $vivo = $true
    } else {
      L ("transcript parado há {0:N0} min: a sessão parou mesmo" -f $idadeT.TotalMinutes)
    }
  } else {
    L 'sem transcript: a sessão parou (ou nunca existiu)'
  }
}
if ($vivo) { exit 0 }

# 3. retoma anterior ainda a correr?
if (Test-Path $PidFile) {
  $p = (Get-Content $PidFile | Select-Object -First 1)
  if ($p -and (Get-Process -Id ([int]$p) -ErrorAction SilentlyContinue)) {
    L "retoma anterior ainda a correr (pid $p), saio"
    exit 0
  }
  Remove-Item $PidFile -ErrorAction SilentlyContinue
}

# 4. ambiente
$env:CLAUDE_CONFIG_DIR = 'C:\Users\danil\.claude'
$env:HOME = 'C:\Users\danil'
if (Test-Path $TokenEnv) {
  Get-Content $TokenEnv | Where-Object { $_ -match '^CLAUDE_CODE_OAUTH_TOKEN=' } | ForEach-Object {
    $env:CLAUDE_CODE_OAUTH_TOKEN = $_.Split('=', 2)[1].Trim()
  }
  L ("token OAuth carregado do ficheiro (len={0})" -f $env:CLAUDE_CODE_OAUTH_TOKEN.Length)
} else {
  L 'sem ficheiro de token: uso as credenciais do perfil'
}

# 5. git pull — a rotina cloud pode ter empurrado trabalho
Set-Location $Repo
$pull = (git pull --rebase --autostash origin main 2>&1 | Out-String).Trim()
L ("git pull: " + ($pull -replace "`r?`n", ' | '))

# 6. lançar a retoma
$prompt = 'Le docs/MARCOS.md e continua do PROXIMO. Modo noite: nunca pares a espera de resposta; regista marcos em docs/MARCOS.md; renova docs/.sessao-viva.'
$carimbo = Get-Date -Format 'yyyyMMdd-HHmmss'
$saida = Join-Path $Docs ("vigia-retoma-{0}.log" -f $carimbo)
$erro  = Join-Path $Docs ("vigia-retoma-{0}.err" -f $carimbo)
L "sessão parada: lanço claude --resume $SessaoId"
try {
  $proc = Start-Process -FilePath $ClaudeCmd `
    -ArgumentList @('--resume', $SessaoId, '-p', ('"' + $prompt + '"'), '--dangerously-skip-permissions', '--output-format', 'text') `
    -WorkingDirectory $Repo -RedirectStandardOutput $saida -RedirectStandardError $erro -PassThru -WindowStyle Hidden
  $proc.Id | Out-File -Encoding ascii $PidFile
  L ("claude lançado pid={0} saída={1}" -f $proc.Id, $saida)
  # enquanto corre, renovo a tranca por ele (o transcript também cresce)
  while (-not $proc.HasExited) {
    Start-Sleep -Seconds 120
    (Get-Date).ToString('o') | Out-File -Encoding ascii $Tranca
  }
  L ("claude terminou exit={0}" -f $proc.ExitCode)
  if (Test-Path $erro) {
    $e = (Get-Content $erro -Tail 3 | Out-String).Trim()
    if ($e) { L ("stderr: " + ($e -replace "`r?`n", ' | ')) }
  }
} catch {
  L ("falhou a lançar o claude: " + $_.Exception.Message)
}
Remove-Item $PidFile -ErrorAction SilentlyContinue
exit 0
