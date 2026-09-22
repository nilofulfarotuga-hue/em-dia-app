# B0 - portao Play Console

Objetivo da missao: abrir o painel da app e tirar captura do Painel de Controlo e do separador Producao para saber se a producao esta aberta.

## Conta/perfil correto

Comando executado:

```powershell
powershell -NoProfile -File "$env:USERPROFILE\.claude\contas\abrir-site.ps1" play-console -SoDizer
```

Saida literal:

```json
{"site":"play-console","url":"https://play.google.com/console","perfil":"chrome-bora","pasta_perfil":"Profile 1","nome_perfil":"Bora","deviceId":"d9e862e0-a5ea-486f-b054-f333ef51b46a","browser_nome_visto":"Browser 2","conta":"boraappbora@gmail.com","plano":"conta de programador (abre /u/0/developers)","reserva":null,"proibido":"chrome-danilo (nilofulfarotuga cai em 'Creating a developer account')","nota":null,"confirmado":"2026-09-17","aviso":null,"instrucao_agente":"select_browser deviceId=d9e862e0-a5ea-486f-b054-f333ef51b46a; confirmar no ecra a conta e o plano antes de agir; nunca sair de contas."}
```

## Resultado

Bloqueado por B-1: a Play Console nao abriu autenticada nesta sessao.

Provas do bloqueio:

- `docs/provas/em-dia-publicar-2026-09-21/b-1-play-console-smoke.png`
- `docs/provas/em-dia-publicar-2026-09-21/b-1-play-console-smoke.json`
- `docs/provas/em-dia-publicar-2026-09-21/b-1-arranque.md`

Nao ha captura valida do Painel de Controlo nem do separador Producao nesta sessao. Nao vou inventar estado da consola.

## e2e_log

A tentativa de gravar via Auth local falhou no B-1 por captcha:

```text
auth_failed status=400 body={"code":400,"error_code":"captcha_failed","msg":"captcha protection: request disallowed (no captcha_token found)"}
```

Por isso o B0 tambem nao teve linha material no `e2e_log` nesta sessao.
