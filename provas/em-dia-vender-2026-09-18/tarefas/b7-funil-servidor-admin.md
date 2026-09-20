# Tarefa B7a — Funil «quantos abrem, acabam o onboarding, experimentam e pagam» (servidor + painel admin)

Projeto Flutter «Em Dia» (Supabase). Painel admin em `lib/admin/` (PT-BR). Migrações em `supabase/migrations/`.
Lê primeiro: `lib/admin/admin_dados.dart` (camada de dados, modo `paraTeste`), `lib/admin/secoes/assinaturas.dart`
(uma secção recente, copia o padrão), `lib/admin/admin_shell.dart` (menu), `test/golden/admin_test.dart` (fotos),
`supabase/migrations/20260918_0038_admin_assinaturas_erros.sql` (padrão de RPC só-admin).

## O que fazer

### 1. Migração `supabase/migrations/20260919_0040_funil.sql` (NÃO a apliques — só o ficheiro)
- `alter table public.profiles add column if not exists consentiu_estatisticas boolean not null default false;`
- Tabela `public.eventos_uso (id bigserial pk, user_id uuid references auth.users(id) on delete cascade, tipo text not null check (tipo in ('abriu_app','concluiu_onboarding','viu_plano','iniciou_compra','comprou','cancelou')), criado_em timestamptz not null default now())` + índice em `(tipo, criado_em)` + RLS: o próprio insere (`auth.uid() = user_id`) só se `profiles.consentiu_estatisticas` for true (subquery na policy), o próprio lê os seus, admin lê tudo (`public.is_admin()`).
- RPC `public.admin_funil(p_semanas integer default 8) returns setof jsonb`, `security definer`, `set search_path = public`, `where public.is_admin()`: uma linha por semana (segunda-feira, `date_trunc('week', …)`, fuso Europe/Lisbon) com:
  `semana` (date), `contas_criadas` (profiles.criado_em na semana), `onboarding_concluido` (profiles com onboarding_concluido e criado_em na semana), `abriram` (profiles com ultimo_acesso na semana), `em_trial` (profiles com trial_ate > fim da semana e onboarding_concluido e criado_em ≤ fim), `pagam` (assinaturas ativas com comecou_em ≤ fim da semana e (terminou_em nulo ou > fim)), `eventos_consentidos` (count de eventos_uso na semana), `consentiram` (profiles com consentiu_estatisticas). Últimas `p_semanas` semanas, mais recente primeiro. `revoke all … from public; grant execute … to authenticated, service_role;` como na 0038.

### 2. Camada de dados `lib/admin/admin_dados.dart`
- `Future<List<Linha>> funil({int semanas = 8})` → `sb.rpc('admin_funil', params: {'p_semanas': semanas})`; em modo de teste devolve `DadosTeste.funil` (campo novo `List<Linha> funil`, com cópia mutável como as outras).
- `String funilCsv(List<Linha>)` com as colunas acima (separador `;`).

### 3. Secção `lib/admin/secoes/funil.dart` («Funil», PT-BR)
- `PaginaAdmin` com título, subtítulo a explicar em uma frase o que cada coluna é, botão «Baixar CSV» (usa `../util/descarregar.dart` como em assinaturas.dart) e «Atualizar».
- Em cima, 5 `CartaoNumero` da semana mais recente: contas criadas, acabaram o onboarding, abriram, em trial, pagam.
- Tabela `TabelaAdmin` com as semanas (colunas: Semana, Contas, Onboarding, Abriram, Em trial, Pagam, Consentiram, Eventos).
- Uma nota (`Aviso` tom amarelo) a dizer: «Instalações vêm da Play Console (Estatísticas). Os eventos só contam quem ligou "estatísticas de utilização" nas Definições; os números das contas não precisam de consentimento porque são os dados da conta.»
- Entrada no menu de `admin_shell.dart` DEPOIS de «Assinaturas» (ícone `Icons.stacked_bar_chart_rounded`, rótulo `l.admNavFunil`) — atualiza os índices do `switch` e os índices usados em `test/golden/admin_test.dart` (regras passa a 4, tickets 5, erros 6, IA 7, avisos 8, auditoria 9; `admin_vazio` usa tickets).
- Textos em `lib/l10n/partes/90_admin_pt_BR.arb` e `90_admin_pt.arb` (as duas, chaves `admNavFunil`, `admFuTitulo`, `admFuSub`, `admFuCol…`, `admFuNota`, `admFuTabela` com placeholder `n`). Depois: `python tool/l10n/merge.py` e `flutter gen-l10n`.

### 4. Testes
- `test/golden/admin_test.dart`: dados de exemplo `funil` (8 semanas com números plausíveis) e um teste `admin_funil` (foto `admin_funil`, `moldura(3)`), a verificar o título e um número.
- Corre `flutter analyze --no-fatal-infos` (só pode ficar o aviso pré-existente de `anonKey`) e `flutter test test/golden/admin_test.dart -r compact` — tem de dar «All tests passed!». Cola a saída literal na tua resposta final.

## Critério de feito
- Migração escrita (não aplicada), RPC com `is_admin()`, secção «Funil» no painel, l10n nas duas línguas, goldens do admin verdes, analyze limpo. Nada de emojis nos textos.

## Proibido
- Aplicar migrações, mexer em git, tocar em `lib/regras/`, `supabase/functions/`, dinheiro, ou apagar testes. Não inventes números legais. Não escrevas em inglês nos textos do painel.
