# B4 - submeter

## Estado

Nao submetido.

## Motivo provado

B-1 e B0 provaram que a Play Console nao abriu autenticada nesta sessao:

```text
robocopy returncode=9
URL aberta: https://google.play/business/
cdp_failed Não é possível estabelecer ligação com o servidor remoto
```

Provas ligadas:

```text
docs/provas/em-dia-publicar-2026-09-21/b-1-play-console-smoke.png
docs/provas/em-dia-publicar-2026-09-21/b-1-play-console-smoke.json
docs/provas/em-dia-publicar-2026-09-21/b-1-arranque.md
docs/provas/em-dia-publicar-2026-09-21/b0-portao.md
```

## Checklist da consola

Nao consegui confirmar `11 de 11`, criar lancamento de producao, carregar AAB nem capturar estado `Em revisão`, porque a consola nao ficou autenticada.

## Robots/noindex

Nao mexi no site nesta sessao. A prova de site nao foi repetida neste bloco.

## e2e_log

Nao gravado por esta sessao: a Auth local recusou login com `captcha_failed` no B-1.
