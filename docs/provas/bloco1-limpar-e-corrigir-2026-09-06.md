# Prova — BLOCO 1: limpar e corrigir (2026-09-06, 14h05 Lisboa)

## 1. Dados de teste apagados

Antes e depois, contados na base de dados:

| tabela | antes | depois |
|---|---:|---:|
| utilizadores (`auth.users`) | 7 | 2 |
| perfis | 7 | 2 |
| obrigações | 47 | 0 |
| rendimentos | 1 | 0 |
| carros | 2 | 0 |
| abastecimentos | 0 | 0 |
| conversas com a IA | 38 | 0 |
| tickets de suporte | 11 | 0 |
| eventos de aviso | 13 | 0 |
| registos de teste ponta-a-ponta | 10 | 0 |

Contas inventadas durante os testes, apagadas com tudo o que lhes pertencia:
`teste@emdia.pt`, `teste2@emdia.pt`, `test@emdia.pt`, `demo@emdia.pt`,
`test@gmail.com`. Ficaram as duas contas reais do Danilo
(`nilofulfarotuga@gmail.com` e `boraappbora@gmail.com`), que são também as
contas de administrador — apagá-las tirava o acesso ao painel.

Os perfis dessas duas contas foram apagados e voltados a criar só com o e-mail,
para todos os valores por omissão do schema entrarem. É exatamente o estado de
quem acaba de se registar: sem nome, sem atividade, sem carro, plano `free`,
mês grátis a contar a partir de agora, onboarding por fazer.

O carro **AA-11-BB** desapareceu com a tabela `carros` (0 linhas), e as
obrigações com "verif"/"teste" desapareceram com a tabela `obrigacoes` (0 linhas).

## 2. O painel escolhe o prazo mais próximo, sempre

O erro estava corrigido de manhã (a lista vinha do servidor ao contrário). Agora
ficou preso por testes, e as leituras deixaram de depender da ordem por que os
itens chegam:

- `proxima()` escolhe pelo mínimo da data, não pela posição.
- `passadas()`, `aVencer()`, `pendentes()` e `doMes()` saem sempre ordenadas
  pela data, da mais perto para a mais longe.
- `ObrigacoesStore.comoVeioDoServidor(...)` existe só para os testes poderem
  entregar a lista ao contrário de propósito.

`test/unit/painel_prazos_test.dart`, 8 testes, todos verdes:

```
P01 CICATRIZ: o próximo prazo é o mais perto, mesmo com a lista ao contrário
P02 as listas do painel saem sempre por ordem de data
P03 laranja: há coisas a menos de 5 dias, logo NÃO está tudo em dia
P04 o dia exato conta: 5 dias entra, 6 dias não
P05 vermelho: um prazo passado, e o primeiro da lista é o mais antigo
P06 o que já foi pago não conta para nada
P07 verde: sem nada pendente não há próximo prazo
P08 o que vence hoje ainda não passou, mas é urgente
```

O semáforo fica assim, e está escrito nos testes:
vermelho se houver prazo passado · laranja se houver algo a 5 dias ou menos ·
verde só se não houver nada.

## 3. Duplicados: apagados e proibidos

Havia um par repetido (mesmo utilizador, tipo `outro`, dia 11 de setembro).
Desapareceu com a limpeza. A proibição ficou em dois índices, porque as
obrigações não nascem todas da mesma maneira:

- `obrigacoes_calculadas_uma_so` — as que o servidor calcula (têm `origem_regra`):
  uma por utilizador + tipo + dia.
- `obrigacoes_manuais_uma_so` — as escritas à mão: uma por utilizador + tipo +
  dia + descrição, para "outro" no dia 11 poder ser a renda e o ginásio.

Prova: a segunda inserção igual foi recusada com a mensagem literal do Postgres.

```
ERROR: 23505: duplicate key value violates unique constraint "obrigacoes_calculadas_uma_so"
DETAIL: Key (user_id, tipo, data_limite)=(500f99a2-…, ss_pagamento, 2099-01-20) already exists.
```

## 4. Avisos de segurança do Supabase, fechados

O linter deu 13 avisos de manhã. Ficaram 6, todos da mesma família e todos
sobre funções que só um administrador com sessão consegue aproveitar.

**`pg_net` saiu do schema `public`.** A extensão estava registada em `public`
mas as funções sempre viveram em `net`, por isso `net.http_post(...)` não mudou
de nome e o trabalho de hora a hora do `pg_cron` não precisou de tocar em nada.

```
extname=pg_net · schema_da_extensao=extensions · onde_esta_a_funcao=net
net.http_post(...) -> id_do_pedido=1
net._http_response -> id=1 status_code=404 {"code":"NOT_FOUND","message":"Requested function was not found"}
```

(O 404 era o esperado: apontei de propósito a uma função que não existe. O que
interessa é que o trabalhador de fundo pegou no pedido e escreveu a resposta.)

**`is_admin()` saiu do alcance de quem não tem sessão.** A migração anterior
tinha deixado isto de fora com uma razão boa: 31 políticas chamam a função, e o
site lê cinco tabelas sem sessão. Em vez de repetir a razão, tirei a razão — as
31 políticas de administrador passaram a exigir sessão (`to authenticated`), e a
leitura pública das guias deixou de chamar a função. Só depois se tirou a
permissão.

```
sem sessão:  regras_legais 200 · irs_escaloes 200 · feriados 200 · feature_flags 200 · guias 200
sem sessão:  POST /rest/v1/rpc/is_admin -> 401 {"code":"42501","message":"permission denied for function is_admin"}
com sessão, admin:      3 perfis, 11 guias, 66 regras, is_admin=true
com sessão, não-admin:  1 perfil,  11 guias, 66 regras, is_admin=false
```

**`handle_new_user()` e `admin_automatico()`** deixaram de ter permissão para
toda a gente. São funções de gatilho e um gatilho não precisa que quem escreve
na tabela tenha permissão nelas. Prova de que o registo não partiu: uma conta
nova criada às **14:01:08**, depois do corte, apanhou perfil com plano `free` e
**30 dias** de mês grátis.

**Palavras-passe fugidas.** Ligada a verificação contra o HaveIBeenPwned e o
mínimo subiu de 6 para 8 letras.

```
PATCH /v1/projects/tgdmgtmknbwhcqoxtjbs/config/auth -> HTTP 200
leitura de volta: hibp -> true , minimo -> 8
```

**Perguntar pelo plano dos outros deixou de dar.** `plano_efetivo(uid)`,
`feature_permitida(uid, flag)` e `feature_limite(uid, flag)` aceitavam o
identificador de qualquer pessoa. Agora só respondem sobre quem pergunta, ou a
um administrador, ou ao servidor.

A primeira tentativa de prova não valia nada — as duas contas do Danilo são
ambas administrador, por isso respondiam sempre. Repetida com alguém que não é:

```
sou admin?               -> false
plano de outra pessoa    -> recusou com 42501
cadeado de outra pessoa  -> recusou com 42501
limite de outra pessoa   -> recusou com 42501
service_role pelo plano de um utilizador -> trial
service_role por um cadeado              -> true
```

## O que ficou de propósito

Seis avisos, todos do mesmo tipo: funções `SECURITY DEFINER` que quem tem sessão
consegue chamar. São `admin_resumo()`, `admin_ia_top_perguntas(limite)`,
`is_admin()`, `plano_efetivo(uid)`, `feature_permitida(...)` e
`feature_limite(...)`. Todas verificam por dentro quem está a perguntar: as duas
primeiras respondem com erro a quem não é administrador, e as outras já só falam
sobre quem pergunta. Tirar-lhes a permissão partia o painel de administração e
os cadeados dos planos, para calar um aviso que já não corresponde a um buraco.

## Migrações

`20260906_0010_obrigacoes_sem_duplicados.sql` ·
`20260906_0011_seguranca_is_admin_anon.sql` ·
`20260906_0012_pg_net_fora_do_public.sql` ·
`20260906_0013_plano_so_sobre_si_proprio.sql`
