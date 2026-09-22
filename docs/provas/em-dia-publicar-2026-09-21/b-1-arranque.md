# B-1 - arranque

Data/hora local: 2026-09-21 23:05.

## Auth do OpenCode/ChatGPT

Ficheiro lido: `C:\Users\danil\.codex\auth.json`.

Resultado confirmado sem copiar tokens: `email=nilofulfaro@gmail.com`, `chatgpt_plan_type=plus`, `auth_mode=chatgpt`.

## PC nao adormece

Comandos executados:

```powershell
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE
powercfg /query SCHEME_CURRENT SUB_VIDEO VIDEOIDLE
```

Saida literal relevante:

```text
Current AC Power Setting Index: 0x00000000
Current DC Power Setting Index: 0x00000000
Current AC Power Setting Index: 0x00000000
Current DC Power Setting Index: 0x00000000
exit_standby=0 exit_monitor=0
```

## Git push fora do navegador

Comando executado: `git push origin HEAD:refs/heads/opencode-push-test-em-dia-publicar-20260921` e depois apagado o ramo temporario.

Saida literal:

```text
To https://github.com/nilofulfarotuga-hue/em-dia-app.git
 * [new branch]      HEAD -> opencode-push-test-em-dia-publicar-20260921
To https://github.com/nilofulfarotuga-hue/em-dia-app.git
 - [deleted]         opencode-push-test-em-dia-publicar-20260921
push_exit=0 delete_exit=0 branch=opencode-push-test-em-dia-publicar-20260921
```

## Telegram

Comando executado: `powershell -ExecutionPolicy Bypass -File tool\vigia\telegram.ps1 -Texto "B-1 teste: ..."`.

Saida literal:

```text
ok=True msg_id=8159 erro=None
```

## Fumo Chrome / Play Console

Caminho 1 executado com `python tool\provas\play_console_smoke.py --out docs\provas\em-dia-publicar-2026-09-21`.

Provas geradas:

- `docs/provas/em-dia-publicar-2026-09-21/b-1-play-console-smoke.png`
- `docs/provas/em-dia-publicar-2026-09-21/b-1-play-console-smoke.json`

Saida literal relevante:

```text
"copy": { "returncode": 9, "ok": false }
"title": "Google Play para empresas | Lance e monetize seus apps | Google Play Console"
"url": "https://google.play/business/"
```

Interpretacao: a copia do perfil nao abriu a Play Console autenticada. A captura mostra a pagina publica/nao autenticada.

Caminho 2 executado uma vez com Chrome real e CDP em `--remote-debugging-port=9222`.

Saida literal:

```text
cdp_failed Nao e possivel estabelecer ligacao com o servidor remoto
```

Conclusao: Play Console bloqueada nesta sessao por falta de acesso ao Chrome autenticado/depurador. A missao segue nos blocos que nao precisam de consola, e os passos de consola ficam em `docs/PENDENTE-DANILO.md` com a prova acima.

## e2e_log e Telegram de bloco

Tentativa de inserir `b-1-arranque` no `e2e_log` por PostgREST com credenciais locais de teste:

```text
auth_failed status=400 body={"code":400,"error_code":"captcha_failed","msg":"captcha protection: request disallowed (no captcha_token found)"}
```

Conclusao: a linha do `e2e_log` nao foi gravada nesta fase porque a Auth bloqueou login por falta de captcha_token. Nao usei escrita direta nem contornei RLS.

Telegram de fecho do bloco:

```text
ok=True msg_id=8160 erro=None
```
