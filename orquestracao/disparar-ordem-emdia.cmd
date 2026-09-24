@echo off
setlocal EnableExtensions
chcp 65001 >NUL
REM ===========================================================================
REM  disparar-ordem-emdia.cmd <nome-da-ordem>
REM
REM  Escrito 2026-09-24 (missao em-dia-grupos-virais-2026-09-23).
REM  E o mesmo esquema provado do Bora (disparar-ordem-fixa.cmd, 07/09), mas
REM  com ordens proprias do EM DIA e janelas que NAO colidem com as do Bora:
REM
REM     Bora:   09:30  14:30  18:30
REM     Em Dia: 10:15  13:45  19:45  21:15   (+ relatorio as 22:30)
REM
REM  PORQUE NAO SE REAPROVEITA O DO BORA: as ordens do Bora leem o estado dos
REM  grupos do Bora na VPS e publicam como "Bora App Guarda". O Em Dia le o
REM  grupos.csv deste repo e publica como "Em Dia: Recibos e Impostos".
REM  Misturar as duas marcas e falha grave (regra da marca, 23/09).
REM
REM  O executor e o mesmo, e passa --chrome ao claude -- sem essa bandeira a
REM  sessao nasce sem navegador e nenhuma publicacao em grupo e possivel.
REM ===========================================================================

set "NOME=%~1"
if "%NOME%"=="" ( echo ERRO: falta o nome da ordem. Uso: disparar-ordem-emdia.cmd emdia-manha & exit /b 2 )

set "RAIZ=C:\BoraLocal\projetosflutter\em_dia"
set "ORDEM=%RAIZ%\orquestracao\ordens-fixas\%NOME%.md"
set "EXECUTOR=C:\BoraLocal\Desktop-PC-antigo\produtividade-ia\hermes-bridge\run-claude-loop-pcnovo-limpo.cmd"
set "DIARIO=%RAIZ%\docs\marketing\redes-em-dia\grupos\relogio-emdia.log"

if not exist "%ORDEM%" ( echo ERRO: ordem "%ORDEM%" nao existe & exit /b 3 )
if not exist "%EXECUTOR%" ( echo ERRO: executor "%EXECUTOR%" nao existe & exit /b 4 )

REM O executor le a tarefa de %TEMP%\bora_loop_task.txt. UTF-8 SEM BOM, porque o BOM
REM aparecia na primeira linha e comia o "[MODELO: OPUS]" -- sem esse marcador o
REM executor cai para sonnet em silencio.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$t = Get-Content -LiteralPath '%ORDEM%' -Raw -Encoding UTF8; [IO.File]::WriteAllText($env:TEMP + '\bora_loop_task.txt', $t, (New-Object Text.UTF8Encoding($false)))"
if errorlevel 1 ( echo ERRO: nao consegui escrever a tarefa & exit /b 5 )

echo [%date% %time%] disparo "%NOME%" >> "%DIARIO%"
call "%EXECUTOR%" --jaentregue >> "%DIARIO%" 2>&1
set "RC=%ERRORLEVEL%"
echo [%date% %time%] fim "%NOME%" rc=%RC% >> "%DIARIO%"
exit /b %RC%
