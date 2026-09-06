# Prova — a suspeita de fuga pelas funções do administrador (2026-09-06, 16h30)

O Danilo escreveu: *"FUGA POR CONFIRMAR: `admin_resumo()` e
`admin_ia_top_perguntas()` são chamáveis por QUALQUER utilizador com sessão. Se
não verificam `is_admin()` lá dentro, qualquer pessoa registada lê o resumo do
administrador."*

**Resposta curta: não havia fuga. Mas mudei uma das duas na mesma, e ficou tudo
provado com pedidos a sério.**

## Como se prova isto sem enganar ninguém

As duas contas do Danilo são **ambas** administrador (a migração 0004 põe-nas lá
pelo e-mail). Uma prova feita com elas não valia nada: responderiam sempre.

Por isso criei um utilizador de verdade que **não** é administrador —
`prova.fuga@emdia.pt`, com palavra-passe, confirmado, fora da tabela `admins` —
e entrei com ele pela porta normal:

```
POST /auth/v1/token?grant_type=password  ->  200  (access_token de utilizador normal)
POST /rest/v1/rpc/is_admin               ->  200  false
```

## O que respondiam ANTES de eu mexer

```
POST /rest/v1/rpc/admin_resumo            ->  403  {"code":"42501","message":"so_admin"}
POST /rest/v1/rpc/admin_ia_top_perguntas  ->  200  []
```

O `admin_resumo` já recusava. O outro filtrava tudo por dentro
(`where public.is_admin()`), por isso a lista vinha vazia — **nenhum dos dois
deixava ler o que quer que fosse**.

## O que mudei, e porquê

Responder "200, nada" é ambíguo. Lê-se como "não há perguntas", e não como "não
és tu que perguntas". Quem venha a mexer nisto amanhã pode ver a lista vazia,
concluir que a guarda não existe, e tirá-la. Passa a recusar como o irmão:

```
POST /rest/v1/rpc/admin_resumo            ->  403  {"code":"42501","message":"so_admin"}
POST /rest/v1/rpc/admin_ia_top_perguntas  ->  403  {"code":"42501","message":"so_admin"}
```

## Não fiquei por aí: varri a base toda com esse utilizador

Uma tabela vazia responde "0 linhas" a toda a gente, inclusive a quem não devia
lá chegar — uma prova assim não prova nada. Por isso **meti primeiro dados de
outra pessoa** na base: uma obrigação, uma conversa com o assistente, um ticket,
um rendimento e uma linha de auditoria, todos com a palavra `SEGREDO` no texto e
todos pertencentes à outra conta. Só depois perguntei.

| tabela ou vista | resposta ao utilizador normal | leu o segredo? |
|---|---|---|
| `admins` | 200, 0 linhas | não |
| `profiles` | 200, **1 linha** (a dele) | não |
| `obrigacoes` | 200, 0 linhas | não |
| `conversas_ia` | 200, 0 linhas | não |
| `tickets_suporte` | 200, 0 linhas | não |
| `entradas` | 200, 0 linhas | não |
| `admin_audit_log` | 200, 0 linhas | não |
| `avisos_massa` | 200, 0 linhas | não |
| `e2e_log` | 200, 0 linhas | não |
| `v_custo_ia_diario` | 200, 0 linhas | não |
| `assinaturas` | 200, 0 linhas | não |
| `eventos_push` | 200, 0 linhas | não |

## E a escrever?

| tentativa | resposta | o que aconteceu de facto |
|---|---|---|
| apagar a obrigação de outra pessoa | 204 | **a obrigação continuou lá** (SELECT: 1 linha) |
| tornar-se administrador | **403** `new row violates row-level security policy for table "admins"` | nada |
| pôr o próprio plano em `familia` | 200 | **continuou `free`** |
| esticar o próprio mês grátis até 2099 | 200 | **continuou 06/10/2026** |

Os dois 200 do fim merecem uma frase. O PostgREST responde 200 porque o `UPDATE`
correu; o gatilho `protege_campos_servidor` é que põe de volta os campos que são
do servidor. O resultado está certo — o plano e o mês grátis não mexeram — mas
para quem olha só para o código HTTP parece que resultou. Fica anotado: **nunca
confiar no 200 para dizer que uma escrita passou; ler de volta.**

## Base no fim

O utilizador de prova e todos os dados com `SEGREDO` foram apagados. Ficaram as
duas contas reais do Danilo, com tudo a zero:

```
utilizadores 2 · obrigações 0 · conversas 0 · tickets 0 · entradas 0
auditoria 0 · perfis com onboarding feito 0
```

Migração: `20260906_0020_admin_ia_recusa.sql`.
