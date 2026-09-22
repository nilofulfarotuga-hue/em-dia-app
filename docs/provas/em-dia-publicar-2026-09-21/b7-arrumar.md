# B7 - arrumar o que ficou a meio

## Migração 0042 no repo

Criei o ficheiro:

```text
supabase/migrations/20260921_0042_cadeados_anon_e_search_path.sql
```

Conteudo que espelha a migracao aplicada em producao descrita na missao:

```text
revoke execute de anon em:
- admin_apagar_conta_simular(uuid)
- admin_assinaturas(integer)
- admin_erros(integer)
- admin_fechos_mensais(integer)
- admin_funil(integer)

alter function set search_path = public em:
- distancia_km(double precision, double precision, double precision, double precision)
- dia_util_seguinte_ou_igual(date)
```

Nao apliquei esta migracao, porque a propria missao diz que ja foi aplicada em producao e manda nao voltar a aplicar.

## RPCs de perto de mim

Procura no repo:

```text
lib/stores/perto_store.dart chama:
- centro_do_municipio
- postos_perto
- centros_perto
- combustiveis_disponiveis

site publico: sem chamadas encontradas por grep.
supabase/migrations/20260918_0034_dgeg_ligada_e_perto_de_mim.sql ja concede execute a authenticated.
```

Decisao: estas RPCs pertencem a app com sessao; nao sao necessarias para anon.

Criei o ficheiro:

```text
supabase/migrations/20260921_0043_perto_de_mim_sem_anon.sql
```

Conteudo:

```text
revoke execute from anon em:
- postos_perto(...)
- centros_perto(...)
- centro_do_municipio(text)
- combustiveis_disponiveis()

grant execute to authenticated nos mesmos quatro pontos.
```

Nao apliquei a base nesta sessao: nao havia canal seguro de SQL/Supabase, e a Auth local falhou por captcha no B-1.

## e2e_log

Nao gravado por esta sessao: a Auth local recusou login com `captcha_failed` no B-1.
