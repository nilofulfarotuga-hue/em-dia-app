# B2 - ficha da loja e acesso do revisor

## Feito no repo

Atualizei `docs/PLAY-FICHA-RESPOSTAS.md` para a decisao da missao: primeira submissao gratis, sem compras dentro da app enquanto nao existirem produtos publicados na Google Play.

Linhas alteradas em conteudo:

- descricao pt-PT: deixou de prometer assinatura pela Google Play.
- descricao pt-BR: deixou de prometer assinatura pela Google Play.
- seguranca dos dados: trocar `Historico de compras` por `Nao declarar compras nesta submissao`.
- notas de revisao: `Nesta primeira versao nao ha compras dentro da app`.
- produtos de subscricao: ficaram marcados como futuros, nao para esta submissao.

Registei a decisao nova em `docs/DECISOES.md` como D76.

## Acesso do revisor no codigo

Prova lida no codigo:

```text
lib/stores/sessao_store.dart:38-39
- So o e-mail do revisor da Google Play ([emailRevisor]) entra com palavra-passe — o revisor nao tem caixa de e-mail para receber o codigo.

lib/stores/sessao_store.dart:163-166
bool ehRevisor(String email) { ... return r.isNotEmpty && email.trim().toLowerCase() == r; }

lib/stores/sessao_store.dart:388-421
Future<bool> entrarComPalavraPasse(...) ... sb.auth.signInWithPassword(email: limpo, password: palavraPasse, captchaToken: token)
```

Conclusao: a app ja tem caminho de revisor por palavra-passe, condicionado ao `EMAIL_REVISOR` da build; a palavra-passe nao fica na app.

## Bloqueios

Nao consegui colar a ficha na Play Console porque B-1/B0 provaram que a consola nao abriu autenticada.

Nao consegui abrir `registo_aberto` nem criar/provar conta nova de raiz nesta sessao. Tentativa de login local para escrever no Supabase falhou por captcha:

```text
auth_failed status=400 body={"code":400,"error_code":"captcha_failed","msg":"captcha protection: request disallowed (no captcha_token found)"}
```

Nao usei UPDATE direto por fora das permissoes nem contornei RLS.

## Estado real do B2

Preparacao textual da consola: feita no repo.

Aplicacao na Play Console: bloqueada por navegador.

Registo aberto e prova de conta nova: bloqueados por Auth/captcha e sem canal seguro de escrita nesta sessao.

## e2e_log

Nao gravado por esta sessao: a Auth local recusou login com `captcha_failed` no B-1.
