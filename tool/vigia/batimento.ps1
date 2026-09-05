# batimento.ps1 — renova a tranca docs/.sessao-viva enquanto a sessão local TRABALHA.
#
# "Viva" não é "processo aberto": quando o limite do plano acaba, a janela fica
# aberta mas parada. Por isso a tranca só se renova se o transcript da sessão
# (o .jsonl que o Claude Code escreve a cada passo) mudou nos últimos 10 min.
# Sessão parada → transcript quieto → tranca envelhece → o vigia retoma.
#
# Termina sozinho quando docs/MARCOS.md tiver MISSAO-CONCLUIDA.

$Repo       = 'C:\BoraLocal\projetosflutter\em_dia'
$Tranca     = Join-Path $Repo 'docs\.sessao-viva'
$Marcos     = Join-Path $Repo 'docs\MARCOS.md'
$Transcript = 'C:\Users\danil\.claude\projects\C--BoraLocal-projetosflutter\c51cb931-0ec0-4bb4-bb6f-e956090318aa.jsonl'
$LogB       = Join-Path $Repo 'docs\batimento.log'

"[{0}] batimento arrancou pid={1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $PID | Out-File -Append -Encoding utf8 $LogB
while ($true) {
  if ((Test-Path $Marcos) -and (Select-String -Path $Marcos -Pattern '^MISSAO-CONCLUIDA' -Quiet)) {
    "[{0}] MISSAO-CONCLUIDA: batimento termina" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Out-File -Append -Encoding utf8 $LogB
    break
  }
  if (Test-Path $Transcript) {
    $idade = (Get-Date) - (Get-Item $Transcript).LastWriteTime
    if ($idade.TotalMinutes -lt 10) {
      (Get-Date).ToString('o') | Out-File -Encoding ascii $Tranca
    }
  }
  Start-Sleep -Seconds 120
}
