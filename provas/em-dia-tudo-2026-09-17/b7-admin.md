# BLOCO 7 — Painel admin PT-BR (2026-09-18)

> Missão `em-dia-tudo-2026-09-17`. Ordem: «utilizadores, assinaturas, obrigações por pessoa, erros
> OCR/importação, regras editáveis, exportar, apagar/banir».

## O que já existia (Bloco anterior, confirmado no código)

| Pedido | Onde | Estado |
|---|---|---|
| Utilizadores | `lib/admin/secoes/usuarios.dart` — lista `v_admin_usuarios` com pesquisa, folha lateral com perfil, **obrigações (60)**, rendimentos, assinaturas da pessoa, conversas com a IA; banir/reativar, plano manual, estender trial | ✅ já estava |
| Regras editáveis | `secoes/regras_legais.dart` — `regras_legais` (valor, fonte, confiança, verificado_em), `irs_escaloes`, `feature_flags` (cadeados por plano); tudo com linha em `admin_audit_log` | ✅ já estava |
| Auditoria | `secoes/auditoria.dart` | ✅ já estava |

## O que ficou feito neste bloco

| Pedido | Feito |
|---|---|
| **Assinaturas** (de todos) | Secção nova «Assinaturas»: RPC `admin_assinaturas` (assinaturas × profiles.email × `plano_efetivo`), filtro por estado, contagens (ativas/expiradas/canceladas/pendentes), folha de detalhe, CSV |
| **Erros OCR/importação** | Secção nova «Erros de leitura»: RPC `admin_erros` junta 4 fontes — `leituras_ocr` (sem valor, confiança < 0,6 ou corrigido pela pessoa), `importacoes_extrato.erro`, `faturas_recebidas` (erro/`nao_deu`/`sem_anexo`), `recibos_emitidos` (erro) — com tipo, quando, pessoa, resumo, erro e o detalhe em JSON; filtro por tipo; CSV |
| **Exportar** | Download a sério na web (`lib/admin/util/descarregar.dart`: Blob + `<a download>`, BOM UTF-8 para o Excel) nos três CSV — usuários, assinaturas, erros; fora da web fica a caixa de copiar |
| **Apagar** | Apagar a sério (D70): confirmar → **simulação** (`admin_apagar_conta_simular`: linhas por tabela + ficheiros no Storage) → motivo obrigatório → Edge Function **`admin-apagar-conta`** (service role: apaga ficheiros pela API do Storage, `auth.admin.deleteUser`, auditoria `usuario_apagado`). Nunca um admin, nunca a própria conta, nunca sem motivo |
| **Banir** | Já existia; mantém-se (`profiles.banido`, auditoria `usuario_banir`) |

Menu do painel agora: Visão geral · Usuários · **Assinaturas** · Regras legais · Tickets · **Erros de leitura** · IA · Avisos · Auditoria.

Migrações no repo e aplicadas: `20260918_0038_admin_assinaturas_erros.sql`, `20260918_0039_admin_simular_service_role.sql`
(todas as funções `SECURITY DEFINER` + `is_admin()`; a simulação aceita também a service role, para a Edge Function).

## Provas (saída literal)

### As RPC só respondem a admin (rollback no fim, nada ficou escrito)

```sql
-- sem JWT (postgres): 0 linhas
select count(*) from public.admin_assinaturas(10);   -- 0
select count(*) from public.admin_erros(10);         -- 0

-- com as claims de admin numa transação (set local request.jwt.claims … app_metadata.role = admin), depois rollback
is_admin            → true
assinaturas         → 0        (ainda não há assinaturas na base: a Play Billing só entra com o «vai» do Danilo — regra 12)
erros               → 0        (ainda não há leituras/importações falhadas na base)
simular_conta_teste → {"email":"boraappbora+emulador@gmail.com","existe":true,"linhas":{"profiles":1,"obrigacoes":11,"eventos_push":1,"pastas_contabilista":1,…},"eh_admin":false,"ficheiros_storage":0}
simular_inexistente → {"existe":false,…}
```

### Edge Function `admin-apagar-conta` v1 no ar (deploy 15:02; chamada por `pg_net` com o segredo do Vault)

| id | pedido | resposta |
|---|---|---|
| 311 | QA + `{"user_id": conta de teste, "simular": true}` | **200** `{"ok":true,"simulado":true,"simulacao":{…"obrigacoes":11,"pastas_contabilista":1…,"ficheiros_storage":0}}` |
| 312 | QA + uuid inexistente + simular | **404** `{"erro":"nao_existe",…}` |
| 309 | QA a tentar apagar de vez (`"motivo":"teste"`) | **403** `{"erro":"qa_so_simula","mensagem":"A porta de QA só simula; apagar exige um admin com sessão."}` |
| 310 | sem admin (só a chave anónima) | **401** `{"erro":"nao_autorizado","mensagem":"Só um admin pode apagar contas."}` |
| 308 | (antes da 0039) simular pela service role | 500 `so_admin` → corrigido na migração 0039, depois 200 (id 311) |

A conta de teste `80266540-…` **não foi apagada** (só simulação); o apagar a sério exige o admin com sessão no
painel — fica para o Danilo experimentar numa conta descartável se quiser ver o botão funcionar até ao fim.

### Testes

```
$ flutter analyze --no-fatal-infos
1 issue found.   ← o aviso pré-existente de `anonKey`

$ flutter test test/unit -r compact
00:17 +179: All tests passed!

$ flutter test test/golden/admin_test.dart -r compact
00:16 +18: All tests passed!   ← 5 fotos novas: admin_assinaturas, admin_assinatura_detalhe, admin_erros, admin_erro_detalhe, admin_usuario_apagar
```

A foto `admin_usuario_apagar_desktop_br.png` mostra a caixa «Apagar joao.tvde@gmail.com: o que vai embora» com
`profiles: 1 · obrigacoes: 11 · rendimentos: 3 · entradas: 8 · saidas: 12 · cofre_movimentos: 2`, «Arquivos no
Storage: 2», o campo do motivo e o botão vermelho «Apagar de vez».

## O que fica de fora, e porquê

- «Obrigações por pessoa» já estava (folha do utilizador, 60 linhas com estado e data); não se fez uma secção
  separada — seria repetir.
- Não há botão «marcar como paga» no painel: pagar é ato da pessoa na app; o admin vê, não altera dinheiro dos outros.
- As secções novas aparecem vazias na base de produção porque ainda não há assinaturas nem erros registados — a
  prova de conteúdo é a foto com dados de exemplo e a RPC com as claims de admin.

## Decisões

D70 (apagar a sério com simulação) e D71 (assinaturas e erros por RPC só-admin) em `docs/DECISOES.md`.
