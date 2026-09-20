# Tarefa B7b — «estatísticas de utilização»: interruptor nas Definições + registo de eventos na app

Projeto Flutter «Em Dia» (Supabase). App em PT-PT (tratamento por «tu», linguagem simples) com variante PT-BR
(`variante_pt`). Textos SEMPRE em `lib/l10n/partes/*.arb` (PT e BR), nunca no código.
Lê primeiro: `lib/screens/mais/definicoes_screen.dart`, `lib/models/perfil.dart`, `lib/stores/perfil_store.dart`,
`lib/services/compras.dart`, `lib/screens/onboarding/onboarding_screen.dart` (função `_concluir`),
`lib/screens/plano/plano_screen.dart`, `lib/services/arranque.dart`, `test/golden/mais_test.dart`,
`supabase/migrations/20260919_0040_funil.sql` (JÁ APLICADA em produção — não a mexas).

## Contexto do servidor (já existe)
- `profiles.consentiu_estatisticas boolean not null default false`.
- Tabela `public.eventos_uso (user_id, tipo, criado_em)` com `tipo in ('abriu_app','concluiu_onboarding','viu_plano',
  'iniciou_compra','comprou','cancelou')`. RLS: o próprio só consegue INSERIR se `profiles.consentiu_estatisticas` for true;
  se não for, o insert falha com erro de RLS — a app nunca deve sequer tentar sem consentimento.

## O que fazer

### 1. Modelo e store
- `lib/models/perfil.dart`: campo `final bool consentiuEstatisticas` (default false), no `fromMap`
  (`m['consentiu_estatisticas']`), no `toUpdate` (`'consentiu_estatisticas'`) e no `copyWith`.
- Nada a mudar em `PerfilStore.guardar` (já faz `update(...).eq('user_id', …)`).

### 2. Serviço `lib/services/uso.dart`
```dart
/// Estatísticas de utilização (B7b). Só escreve se a pessoa ligou o
/// interruptor nas Definições (profiles.consentiu_estatisticas); sem
/// consentimento não há pedido nenhum ao servidor. Nunca lança: um erro
/// de rede ou de RLS fica em silêncio (é estatística, não é dado da conta).
enum EventoUso { abriuApp, concluiuOnboarding, viuPlano, iniciouCompra, comprou, cancelou }
class Uso { static Future<void> registar(EventoUso e, {required Perfil? perfil, SupabaseClient? cliente}) … }
```
- Converte o enum para o texto da tabela (`abriu_app`, …). Se `perfil == null || !perfil.consentiuEstatisticas` → return sem
  tocar na rede. Insert em `eventos_uso` com `user_id` = `perfil.userId`. `try/catch` a engolir tudo (com `debugPrint`).
- Chamada `abriuApp` **uma vez por arranque** com sessão (onde o `PerfilStore` acaba de carregar o perfil — segue o
  padrão do `ultimo_acesso` em `perfil_store.dart`, mas SÓ depois de o perfil estar carregado, e sem bloquear o arranque:
  `unawaited`).
- `concluiuOnboarding` no fim de `_concluir` do onboarding, depois de `guardar(... onboardingConcluido: true)` dar ok.
- `viuPlano` no `initState` do ecrã do plano (`plano_screen.dart`).
- `iniciouCompra` no início de `ComprasService.comprar` (antes de abrir a loja) e `comprou` quando a compra fica validada
  (procura o sítio onde o estado passa a «feito/ativo» depois do `validar-compra-play`). `cancelou` quando a loja devolve
  cancelado pelo utilizador (se o plugin o distinguir; se não, não inventes — deixa um comentário a dizer porquê).
- O serviço recebe o `Perfil` (ou lê-o do `PerfilStore` via `context.read`) — escolhe o que for menos invasivo, mas não
  cries singletons novos com estado global.

### 3. Interruptor nas Definições (`definicoes_screen.dart`)
- Secção nova entre «Conta» e o botão de sair (ou logo a seguir ao idioma): título `l.defsEstatisticas`, texto de ajuda
  `l.defsEstatisticasAjuda`, `SwitchListTile.adaptive` (Key `defs_estatisticas`) ligado a `perfil.consentiuEstatisticas`;
  ao mudar → `perfilStore.guardar(perfil.copyWith(consentiuEstatisticas: v))`; se falhar, mostra `Aviso(l.erroRede,
  tom: Semaforo.vermelho)` e volta ao valor anterior. Usa `BotaoOuvir` como nas outras secções (etiqueta
  `definicoes-estatisticas`). Sem perfil (`defsSemPerfil`) o interruptor não aparece.
- Textos (PT em `lib/l10n/partes/60_mais_pt.arb`, BR em `60_mais_pt_BR.arb`):
  - `defsEstatisticas`: PT «Estatísticas de utilização» / BR «Estatísticas de uso»
  - `defsEstatisticasAjuda`: PT «Se ligares isto, contamos só quando abres a app, acabas o início, vês o plano e compras.
    Nada do que escreves, nem valores, nem faturas. Serve para percebermos onde as pessoas desistem. Podes desligar
    quando quiseres.» / BR a mesma ideia em PT-BR com «você».
  - `defsEstatisticasLigadas`: PT «Ligadas. Obrigado por ajudares.» / BR «Ligadas. Obrigado por ajudar.»
  - `defsEstatisticasDesligadas`: PT «Desligadas. Não contamos nada.» / BR «Desligadas. Não contamos nada.»
  Depois: `python tool/l10n/merge.py` e `flutter gen-l10n`.

### 4. Testes
- `test/unit/uso_test.dart`: (a) sem consentimento não chama o cliente (usa um `Perfil` com `consentiuEstatisticas:false`
  e um cliente que, se fosse chamado, falharia — ou passa `cliente: null` e confirma que não lança); (b) a conversão
  enum → texto dá exatamente os 6 valores da tabela; (c) com consentimento e cliente que lança, `registar` não propaga.
- `test/golden/mais_test.dart`: um teste `definicoes_estatisticas` (mesmo padrão dos goldens do ecrã de Definições que lá
  existem: `fotografaTela`/`comStores`) com o interruptor visível, ligado, PT e BR (as duas fotos).
- Corre `flutter analyze --no-fatal-infos` (só o aviso pré-existente de `anonKey`), `flutter test test/unit -r compact`
  e `flutter test test/golden/mais_test.dart -r compact`. Cola as saídas literais na resposta final.

## Critério de feito
Interruptor a gravar em `profiles.consentiu_estatisticas`; `Uso.registar` só faz rede com consentimento; os 6 pontos de
chamada; l10n nas duas línguas; analyze limpo; unit + goldens de `mais` verdes. Nada de emojis. Nada em inglês nos textos.

## Proibido
Aplicar migrações, mexer em git, tocar em `lib/regras/`, `supabase/functions/`, `lib/services/compras.dart` para lá de
inserir as duas chamadas (não mudes a lógica de compra), preços, ou apagar testes.
