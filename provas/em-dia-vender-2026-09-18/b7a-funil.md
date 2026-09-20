# B7a — Funil no painel admin (servidor + secção) — 2026-09-19/20

> Missão `em-dia-vender-2026-09-18`, Bloco 7 («contar: quantos abrem, acabam o onboarding, experimentam e pagam»),
> parte a (servidor + painel). Parte b (interruptor de consentimento na app e registo de eventos) vem a seguir.

## Quem fez o quê
- **GLM (glm-5.2, plano Go)** por `~/.claude/motores/delegar.ps1 glm … -Id b7a-funil -MaxMin 20`
  (tarefa em `tarefas/b7-funil-servidor-admin.md`). Tentativa 1 fez o trabalho todo mas estourou os 20 min
  (goldens lentos); tentativa 2 (262 s, anti-mentira PASSOU) verificou peça a peça e correu analyze + goldens.
  Pasta: `~/.claude/delegacoes/2026-09-19/b7a-funil/` (`diff.patch`, 11 ficheiros, +525/−21).
- **Claude Code (maestro)**: leu o diff com contexto limpo, conferiu a migração contra o esquema vivo
  (`profiles.user_id/criado_em/ultimo_acesso/onboarding_concluido/trial_ate`, `assinaturas.estado/comecou_em/terminou_em`,
  `estado in ('pendente','ativa','cancelada','expirada','pausa')`, `is_admin()` da 0001), aplicou o patch,
  correu analyze + goldens, aplicou a migração em produção e provou a RPC.

## O que ficou
- `supabase/migrations/20260919_0040_funil.sql` — `profiles.consentiu_estatisticas` (default false), tabela
  `eventos_uso` (6 tipos, índice `(tipo, criado_em)`, RLS: o próprio insere só com consentimento, lê os seus;
  admin lê tudo), RPC `admin_funil(p_semanas)` security definer + `is_admin()`, semanas de segunda, Europe/Lisbon.
- `lib/admin/secoes/funil.dart` («Funil», depois de Assinaturas; 5 cartões da semana mais recente, tabela de 8
  colunas, nota amarela, «Baixar CSV» e «Atualizar»); `admin_dados.dart` (`funil()`, `funilCsv`, `DadosTeste.funil`);
  `admin_shell.dart` (10 secções, índices regras 4 … auditoria 9); l10n PT/BR (`admNavFunil`, `admFu*`);
  golden `admin_funil` (`test/golden/_fotos/admin_funil_desktop_br.png`).

## Provas literais (2026-09-20, checker = Claude Code)

`flutter analyze --no-fatal-infos`
```
   info - 'anonKey' is deprecated … lib\services\arranque.dart:64:5 - deprecated_member_use
1 issue found. (ran in 21.1s)
```
`flutter test test/golden/admin_test.dart -r compact`
```
00:20 +16: admin_funil: da conta criada ao pagamento, semana a semana (B7a)
00:22 +19: All tests passed!
```
Migração aplicada por MCP Supabase (`tgdmgtmknbwhcqoxtjbs`, `apply_migration 20260919_0040_funil`) → `{"success":true}`.

Leitura de volta (papel postgres, sem admin → 0 linhas, como deve ser):
```
eventos=0 consentiram=0 politicas=2 secdef=true linhas_sem_admin=0
```
Com claims de um admin (transação com `set_config('request.jwt.claims', …)`, `rollback`) — dados reais:
```
semana      c  o  a  t  p  cs e
2026-09-14  1  1  3  6  0  0  0
2026-09-07  1  0  0  5  0  0  0
2026-08-31 10  5  3  5  0  0  0
```
(c contas criadas · o onboarding · a abriram · t em trial · p pagam · cs consentiram · e eventos)

## Ficou por fazer (B7b)
Interruptor «estatísticas de utilização» nas Definições (PT/BR), `lib/services/uso.dart` a escrever `eventos_uso`
só com consentimento, chamadas no arranque, fim do onboarding, ecrã do plano e compra.
