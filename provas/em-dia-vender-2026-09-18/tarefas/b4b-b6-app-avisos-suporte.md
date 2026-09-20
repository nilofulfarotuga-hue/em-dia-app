# Tarefa B4b + B6 — Na app: aviso «não é aconselhamento fiscal», ligações aos papéis, suporte com prazo e caminho para humano, reembolso em 14 dias

Projeto Flutter «Em Dia». App em PT-PT (tratamento por «tu») com variante PT-BR. Textos SEMPRE em `lib/l10n/partes/*.arb`
(PT e BR, as duas), nunca no código. Sem emojis. Sem inglês nos textos.
Lê primeiro: `lib/widgets/widgets.dart` (`Aviso`, `Cartao`, `BotaoGrande`, `BotaoPequeno`, `TituloSeccao`),
`lib/screens/suporte/suporte_screen.dart` (as 3 portas + `SuporteReembolsoScreen`), `lib/screens/plano/plano_screen.dart`,
`lib/screens/recibos/`, `lib/screens/cofre/`, `lib/screens/vale_a_pena/`, `lib/screens/reforma/`, `lib/screens/prova/`,
`test/golden/suporte_test.dart`, `test/golden/plano_test.dart`, `test/golden/recibos_test.dart`.

Os papéis do site (feitos noutra tarefa) ficam em https://emdia.boraguarda.com/termos, /privacidade, /reclamacoes,
/apagar-conta. E-mail de apoio: `emdia@boraguarda.com`. Prazo de resposta do suporte: 2 dias úteis. Política de
devolução: quem assina tem 14 dias para desistir sem dar razões e recebe tudo de volta (DL 24/2014, art. 10.º e 12.º).

## O que fazer

### 1. Widget `AvisoNaoFiscal` (em `lib/widgets/widgets.dart`, ao pé de `Aviso`)
Uma linha pequena (`bodySmall`, cor `AppColors.textoFraco` ou equivalente que já exista), ícone `Icons.info_outline_rounded`
à esquerda, com `Semantics(label: …)`, texto `l.avisoNaoFiscal`:
- PT: «Isto é informação geral, não é aconselhamento fiscal. Os números vêm de fontes oficiais e podem mudar. Confirma
  com o teu contabilista, a Segurança Social ou as Finanças.»
- BR: «Isto é informação geral, não é aconselhamento fiscal. Os números vêm de fontes oficiais e podem mudar. Confirme
  com seu contador, a Segurança Social ou as Finanças.»
Coloca-o **no fim** (antes do último espaço) destes ecrãs, uma vez cada: calculadora de recibos (onde mostra SS e IRS),
cofre, vale a pena, reforma, prova de rendimento. Key `aviso_nao_fiscal` em cada um.

### 2. Ligações aos papéis
- `lib/config/ligacoes.dart` (novo, ou junta-te a um ficheiro de constantes que já exista): `urlTermos`, `urlPrivacidade`,
  `urlReclamacoes`, `urlApagarConta`, `emailSuporte` — os valores acima.
- Ecrã **Ajuda** (`SuporteScreen`): a seguir às 3 portas e antes de «Os meus pedidos», um `Cartao` «Os nossos papéis»
  (`l.suportePapeis`) com 3 linhas tocáveis (`ListTile` compacto ou `BotaoPequeno` secundário): Termos e condições
  (`l.suporteTermos`), Privacidade (`l.suportePrivacidade`), Reclamações (`l.suporteReclamacoes`) → `launchUrl` externo.
  Keys `suporte_termos`, `suporte_privacidade`, `suporte_reclamacoes`.
- Ecrã do **Plano** (`PlanoScreen`): por baixo dos botões de assinar, uma linha pequena `l.planoAntesDeAssinar`:
  PT «Ao assinares aceitas os termos. Cancelas quando quiseres na Google Play. Tens 14 dias para desistir e receber tudo
  de volta.» (BR com «você») com a palavra «termos» tocável (`launchUrl` para `urlTermos`) — usa `RichText`/`TextSpan`
  com `TapGestureRecognizer` ou um `TextButton` pequeno a seguir; Key `plano_termos`.

### 3. Suporte com prazo e caminho para humano (B6)
- Em `SuporteScreen`, por baixo de `l.suporteIntro`, um `Aviso` de tom neutro/azul (o que `Aviso` já tiver) com
  `l.suportePrazo`: PT «Respondemos em 2 dias úteis. Se for urgente, escreve para emdia@boraguarda.com.» — o e-mail
  tocável (abre `mailto:` com assunto «Em Dia — preciso de ajuda»), Key `suporte_email`.
- Na porta «Algo não funciona» (`SuporteBugScreen`), depois de enviar, o ecrã de confirmação diz também o prazo
  (`l.suporteEnviadoPrazo`: PT «Recebemos. Respondemos em 2 dias úteis, aqui em «Os meus pedidos».»).
- `SuporteReembolsoScreen`: acrescenta a linha 4 (`l.suporteReembolsoLinha4`): PT «Assinaste há menos de 14 dias?
  Devolvemos tudo. Pede na Google Play ou escreve-nos para emdia@boraguarda.com.» e um `BotaoGrande` secundário
  «Escrever-nos» (`l.suporteEscreverNos`) que abre `mailto:emdia@boraguarda.com?subject=Em Dia — reembolso` (Key
  `suporte_reembolso_email`). Mantém o ticket 'reembolso' como está.
- «Os meus pedidos»: cada pedido mostra o estado com palavras simples (`aberto` → «Recebido», `em_curso` → «A tratar»,
  `fechado` → «Respondido») — se já mostra, deixa; se não, acrescenta (`l.suporteEstadoAberto/EmCurso/Fechado`).

### 4. Testes
- Goldens: `test/golden/suporte_test.dart` — atualiza o teste do ecrã principal (procura `suporte_email` e o texto do
  prazo) e o do reembolso (procura `suporte_reembolso_email`); `test/golden/plano_test.dart` — procura `plano_termos`;
  `test/golden/recibos_test.dart` (ou o da calculadora) — procura `aviso_nao_fiscal`. Fotos PT e BR como os outros.
- Corre `python tool/l10n/merge.py`, `flutter gen-l10n`, `flutter analyze --no-fatal-infos` (só o aviso pré-existente
  de `anonKey`) e `flutter test test/golden/suporte_test.dart test/golden/plano_test.dart test/golden/recibos_test.dart
  test/golden/cofre_e_radar_test.dart test/golden/reforma_test.dart test/golden/vale_e_fala_test.dart
  test/golden/caixa_e_prova_test.dart -r compact`. Cola as saídas literais na resposta final.

## Critério de feito
Aviso em 5 ecrãs; 3 ligações na Ajuda; linha dos termos no Plano; prazo + e-mail no suporte; linha 4 + botão no
reembolso; l10n PT e BR; analyze limpo; goldens verdes.

## Proibido
Mexer em `lib/services/compras.dart`, `lib/regras/`, `supabase/`, preços, git. Não inventes prazos nem valores para lá
dos que estão aqui. Não uses «em breve».
