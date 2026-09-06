# Prova — auditoria de segurança da base de dados (2026-09-06, noite)

Sem browser nesta sessão, o bloco da Play travou. Usei a noite no que mais custa
depois de lançar: o que a chave pública da app consegue alcançar.

Ferramenta: `get_advisors` do Supabase (o mesmo linter que a consola usa). Cada
aviso foi **confirmado ou desmentido com um pedido real** à API — nenhum foi
tratado como verdadeiro só porque o linter o disse.

## Antes: 1 erro e 21 avisos

## Fuga 1 (a séria) — o custo da IA estava à vista de qualquer utilizador

`v_custo_ia_diario` não tinha `security_invoker`, por isso corria como dona e
passava por cima do RLS de `conversas_ia`. E tinha `SELECT` para
`authenticated`. Resultado: **qualquer pessoa com conta** via o negócio todo.

Entrei com um utilizador normal de teste (`teste@emdia.pt`) e pedi. Veio isto,
tal e qual:

```
GET /rest/v1/v_custo_ia_diario?select=*&limit=3
HTTP 200  [{"dia":"2026-09-06","conversas":37,"custo_eur":0.170677}]
```

Depois da migração `20260906_0009_fecho_avisos_seguranca.sql`:

```
mesmo utilizador, mesmo pedido
HTTP 200  []
```

E o painel de administração continua a funcionar — fiz-me passar pelo
administrador `boraappbora@gmail.com`, pelo mesmo caminho que o painel usa:

```
quem                 eh_admin  dias_com_custo  conversas_do_1o_dia  custo_do_1o_dia
ADMIN boraappbora@   true      1               37                   0.170677
```

## Fuga 2 — sem sessão dava para perguntar o plano de outra pessoa

`plano_efetivo(uid)`, `feature_permitida(uid, flag)` e `feature_limite(uid, flag)`
são `SECURITY DEFINER`, aceitam o uid de qualquer pessoa, e estavam ao alcance de
quem não tem sessão nenhuma:

```
POST /rest/v1/rpc/plano_efetivo      {"uid":"500f99a2-…"}   HTTP 200  "trial"
POST /rest/v1/rpc/feature_permitida  {"uid":"500f99a2-…"}   HTTP 200  true
```

Depois:

```
POST /rest/v1/rpc/plano_efetivo      HTTP 401  permission denied for function plano_efetivo
POST /rest/v1/rpc/feature_permitida  HTTP 401  permission denied for function feature_permitida
POST /rest/v1/rpc/feature_limite     HTTP 401  permission denied for function feature_limite
```

E nada partiu — o que tinha de continuar a funcionar continua:

```
sem sessão   regras_legais (a calculadora do site)   HTTP 200  [{"chave":"ias"}]
sem sessão   guias                                   HTTP 200  [{"slug":"abrir-atividade"}]
com sessão   plano_efetivo (o seu próprio uid)       HTTP 200  "trial"
com sessão   feature_flags                           HTTP 200  [{"chave":"painel"},{"chave":"calculadora"}]
com sessão   profiles                                HTTP 200  [{"email":"teste@emdia.pt"}]
com sessão   obrigacoes                              HTTP 200  [{"tipo":"multa"},{"tipo":"efatura_validar"}]
```

## Também arrumado

Quatro funções sem `search_path` fixo (`set_atualizado_em`,
`protege_campos_servidor`, `eh_dia_util`, `dia_util_anterior_ou_igual`) passaram
a tê-lo. Nenhuma é `SECURITY DEFINER`, por isso o risco era pequeno — mas era de
graça.

## Depois: 0 erros, 13 avisos, todos explicados

O que **ficou de propósito**, com a razão:

- **`is_admin()` continua ao alcance de todos.** Não leva argumentos e responde
  sobre quem chama — a quem não tem sessão responde `false`. Provado:
  `POST /rest/v1/rpc/is_admin` sem sessão → `HTTP 200 false`. E 31 políticas de
  RLS chamam-na, incluindo as de `regras_legais` e `guias` que o site lê sem
  sessão: tirar-lhe a permissão partia a calculadora do site.
- **`handle_new_user()` e `admin_automatico()`** são funções de gatilho e a API
  recusa-as: `HTTP 404 PGRST202`. Mexer nas permissões delas arriscava partir o
  registo de contas no mesmo dia em que se arranjou o login, para calar um aviso
  que não corresponde a buraco nenhum.
- **`admin_resumo()` e `admin_ia_top_perguntas()`** aparecem como chamáveis por
  quem tem sessão, mas defendem-se por dentro. Provado com um utilizador normal:
  `admin_resumo` → `HTTP 403 {"message":"so_admin"}`;
  `admin_ia_top_perguntas` → `HTTP 200 []` (tem `where public.is_admin()`).
- **`pg_net` no schema `public`**: movê-la parte os trabalhos do pg_cron.
- **Proteção contra palavras-passe vazadas desligada**: a app entra por código
  no e-mail, não tem palavras-passe. Só as duas contas de teste é que têm.

## Desempenho: 66 avisos, nenhum mexido esta noite

| Aviso | Quantos | O que é |
|---|---|---|
| `multiple_permissive_policies` | 40 | tabelas com duas políticas permissivas para o mesmo papel (`admins`, `assinaturas`, `guias`, `regras_legais`, …) |
| `auth_rls_initplan` | 16 | políticas que chamam `auth.uid()` sem `(select …)` — é reavaliado linha a linha |
| `unindexed_foreign_keys` | 7 | chaves estrangeiras sem índice |
| `unused_index` | 2 | índices que ainda ninguém usou |

**Não toquei em nada disto**, e a razão é simples: são reescritas de políticas de
RLS, e uma política de RLS mal escrita não fica lenta — fica aberta. Isso não se
faz sozinho de madrugada, com a app já no teste interno e cinco utilizadores. O
ganho hoje é zero. A proposta pronta a aplicar, com revisão, está em
`docs/proposta-desempenho-rls.sql` — fora de `supabase/migrations/` de propósito,
para ninguém a aplicar sem querer.
