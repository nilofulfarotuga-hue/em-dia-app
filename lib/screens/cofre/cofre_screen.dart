import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cofre_movimento.dart';
import '../../regras/regras.dart';
import '../../stores/cofre_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import 'novo_movimento.dart';

/// O cofre do imposto.
///
/// O buraco que este ecrã tapa: a recibos verdes o dinheiro entra todo de uma
/// vez, gasta-se todo, e em abril chega a conta do IRS e da Segurança Social
/// sem nada de lado. Aqui a pessoa aponta o que já separou, e a app diz-lhe
/// quanto DEVIA ter — a tempo de ainda dar para guardar.
///
/// **A primeira coisa que se lê no ecrã é que isto não mexe em dinheiro
/// nenhum.** Não há banco, não há transferência, não há nada automático. É um
/// caderno. Está lá em cima, uma vez, por palavras — e não se tira dali.
///
/// A ordem do ecrã segue a pergunta que a pessoa traz: *quanto tenho?* (número
/// grande), *quanto devia ter?*, *estou bem ou mal?* (a única cor forte do
/// ecrã), e só depois os dois botões e a lista. Como cheguei ao número fica a
/// seguir aos botões — quem confia não tem de o ler, quem desconfia encontra-o.
///
/// A regra do laranja: o ÚNICO elemento laranja possível é a linha do
/// resultado, e só no estado "falta pouco". Tudo o resto é verde, cinzento ou
/// azul de informação.
///
/// Está aberto no plano grátis (`feature_flags.cofre_imposto`, `free = true`):
/// não há cadeado nenhum neste ecrã de propósito — quem mais precisa de pôr
/// dinheiro de lado é quem ainda não paga nada.
class CofreScreen extends StatefulWidget {
  /// Dia de referência (testes/fotos). Na app é sempre `hojeLisboa()`.
  final DateTime? hoje;

  /// Para onde vai o convite do estado "ainda não sei quanto ganhaste".
  /// O orquestrador liga isto ao ecrã de escrever uma entrada; sem ele o
  /// convite fica só com o texto, nunca com um botão que não faz nada.
  final VoidCallback? aoEscreverPrimeira;

  const CofreScreen({super.key, this.hoje, this.aoEscreverPrimeira});

  @override
  State<CofreScreen> createState() => _CofreScreenState();
}

class _CofreScreenState extends State<CofreScreen> {
  DateTime get _hoje => widget.hoje ?? hojeLisboa();

  @override
  void initState() {
    super.initState();
    // Depois da primeira pintura, para não mandar notificações a meio de um
    // `build` (foi assim que outros ecrãs ficaram a piscar).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = context.read<SessaoStore>().userId;
      if (userId != null) {
        context.read<CofreStore>().carregarSePreciso(userId, ano: _hoje.year);
      }
    });
  }

  Future<void> _carregar() async {
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) return;
    await context.read<CofreStore>().carregar(userId, ano: _hoje.year);
  }

  void _snack(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _novo({required bool poe}) async {
    final l = AppLocalizations.of(context);
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) {
      _snack(l.cofreSemSessao);
      return;
    }
    final ok = await mostrarNovoMovimento(context, userId: userId, hoje: _hoje, poe: poe);
    if (ok == true && mounted) _snack(l.cofreGuardado);
  }

  /// Apagar é para sempre: pergunta-se sempre, e a pergunta diz o valor e o
  /// dia para não se apagar a linha errada.
  Future<bool> _confirmarApagar(CofreMovimento m) async {
    final l = AppLocalizations.of(context);
    final sim = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.cofreApagarPergunta(moeda(m.quantia), dataPt(m.data))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancelar)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.apagar)),
        ],
      ),
    );
    return sim == true;
  }

  Future<void> _apagar(CofreMovimento m) async {
    final l = AppLocalizations.of(context);
    final ok = await context.read<CofreStore>().apagar(m);
    if (!mounted) return;
    _snack(ok ? l.cofreApagado : l.erroRede);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = context.watch<CofreStore>();
    final regras = context.watch<RegrasStore>().regras;
    final perfil = context.watch<PerfilStore>().perfil;
    final semSessao = context.watch<SessaoStore>().userId == null;

    // O dia em que abriu atividade decide a isenção do 1.º ano da Segurança
    // Social. Fica numa variável porque é lido duas vezes — e com `?.` a duas
    // linhas de distância o analisador deixava de saber que já não é nulo.
    final abertura = perfil?.dataAbertura;

    final conta = store.conta(
      regras: regras,
      tipo: perfil?.tipoRendimento ?? TipoRendimento.servicos,
      dataAbertura: abertura,
      ajusteSsPct: perfil?.ajusteSsPct ?? 0,
    );
    final saldo = store.saldo;

    // Enquanto não há nada para mostrar: esqueleto cinzento, nunca uma roda a
    // girar sem fim.
    final aCarregarPrimeira = store.aCarregar && !store.temDados;
    final erroSemDados = !store.aCarregar && store.erro != null && !store.temDados;

    return Scaffold(
      appBar: AppBar(title: Text(l.cofreTitulo)),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: paddingEcra,
          children: [
            if (semSessao)
              // Azul e não amarelo: "entra na app" é uma informação, não um
              // aviso — e o laranja deste ecrã está guardado para o resultado.
              _NotaAzul(
                l.cofreSemSessao,
                icone: Icons.person_outline_rounded,
                chave: const Key('cofre_sem_sessao'),
              )
            else if (aCarregarPrimeira)
              const _Esqueleto()
            else if (erroSemDados) ...[
              Aviso(l.erroRede, tom: Semaforo.vermelho, icone: Icons.wifi_off_rounded),
              const SizedBox(height: 12),
              BotaoGrande(texto: l.tentarOutraVez, secundario: true, aoTocar: _carregar),
            ] else ...[
              // Houve rede antes e falhou agora: mostra-se o aviso mas
              // guardam-se os números de há um minuto. Ecrã preso, nunca.
              if (store.erro != null) ...[
                Aviso(l.erroRede, tom: Semaforo.vermelho, icone: Icons.wifi_off_rounded),
                const SizedBox(height: 8),
                BotaoGrande(texto: l.tentarOutraVez, secundario: true, aoTocar: _carregar),
                const SizedBox(height: 16),
              ],

              // 1. O que isto é, antes de qualquer número.
              _NotaAzul(
                l.cofreNaoMexe,
                icone: Icons.menu_book_rounded,
                chave: const Key('cofre_nao_mexe'),
              ),
              const SizedBox(height: 12),

              // 2. O número grande, o que devia estar lá, e o resultado.
              _CartaoDoCofre(
                saldo: saldo,
                conta: conta,
                aoEscreverPrimeira: widget.aoEscreverPrimeira,
              ),

              // 3. Os dois botões, à vista sem rolar o ecrã.
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BotaoGrande(
                      key: const Key('cofre_por'),
                      texto: l.cofreBotaoPor,
                      icone: Icons.add_rounded,
                      aoTocar: () => _novo(poe: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BotaoGrande(
                      key: const Key('cofre_tirar'),
                      texto: l.cofreBotaoTirar,
                      icone: Icons.remove_rounded,
                      secundario: true,
                      aoTocar: () => _novo(poe: false),
                    ),
                  ),
                ],
              ),

              // 4. De onde saiu o número. Quem confia salta; quem desconfia lê.
              if (!conta.semRendimento) ...[
                TituloSeccao(l.cofreComoContei),
                _CartaoDaConta(
                  conta: conta,
                  regras: regras,
                  ano: store.ano,
                  // A data em que a isenção do 1.º ano acaba, escrita para se
                  // ler. Sai da mesma função que o resto da app usa — não se
                  // conta meses à mão em ecrã nenhum.
                  fimDaIsencaoSs: abertura == null
                      ? null
                      : dataExtensoPt(ultimoDiaIsencaoSS(abertura, regras)),
                ),
              ],

              // 5. O caderno.
              TituloSeccao(l.cofreListaTitulo),
              if (store.movimentos.isEmpty)
                Vazio(
                  key: const Key('cofre_vazio'),
                  icone: Icons.savings_outlined,
                  texto: l.cofreVazio,
                )
              else
                for (final m in store.movimentos) ...[
                  _LinhaMovimento(
                    movimento: m,
                    aoConfirmarApagar: () => _confirmarApagar(m),
                    aoApagar: () => _apagar(m),
                  ),
                  const SizedBox(height: 8),
                ],
            ],
          ],
        ),
      ),
    );
  }
}

/// O cartão de cima: quanto tens, quanto devias ter, e como estás.
class _CartaoDoCofre extends StatelessWidget {
  final double saldo;
  final ContaDoCofre conta;
  final VoidCallback? aoEscreverPrimeira;
  const _CartaoDoCofre({
    required this.saldo,
    required this.conta,
    this.aoEscreverPrimeira,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    // Sem rendimento escrito não há resultado nenhum a dar: dizer "faltam
    // 0,00 €" a quem ainda não escreveu nada era inventar um número.
    if (conta.semRendimento) {
      return Cartao(
        key: const Key('cofre_cartao'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Saldo(saldo: saldo),
            const SizedBox(height: 16),
            Text(l.cofreSemContas, style: t.titleMedium),
            const SizedBox(height: 4),
            Text(l.cofreSemContasAjuda, style: t.bodyMedium),
            if (aoEscreverPrimeira != null) ...[
              const SizedBox(height: 12),
              BotaoGrande(
                key: const Key('cofre_escrever_primeira'),
                texto: l.cofreEscreverGanhei,
                icone: Icons.add_rounded,
                secundario: true,
                aoTocar: aoEscreverPrimeira,
              ),
            ],
            const SizedBox(height: 4),
            BotaoOuvir(
              etiqueta: 'cofre-resumo',
              texto: '${l.cofreSemContas} ${l.cofreSemContasAjuda}',
            ),
          ],
        ),
      );
    }

    final estado = conta.estado(saldo);
    final tom = switch (estado) {
      EstadoCofre.chega => Semaforo.verde,
      EstadoCofre.faltaPouco => Semaforo.amarelo,
      EstadoCofre.faltaMuito => Semaforo.vermelho,
    };
    final fecho = switch (estado) {
      EstadoCofre.chega => l.cofreChega(moeda(conta.diferenca(saldo))),
      EstadoCofre.faltaPouco => l.cofreFaltaPouco(moeda(conta.falta(saldo))),
      EstadoCofre.faltaMuito => l.cofreFaltaMuito(moeda(conta.falta(saldo))),
    };
    final ajuda = switch (estado) {
      EstadoCofre.chega => l.cofreChegaAjuda,
      EstadoCofre.faltaPouco => l.cofreFaltaPoucoAjuda,
      EstadoCofre.faltaMuito => l.cofreFaltaMuitoAjuda,
    };

    return Cartao(
      key: const Key('cofre_cartao'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Saldo(saldo: saldo),
          const SizedBox(height: 8),
          LinhaValor(l.cofreDeviasTerNome, moeda(conta.total)),
          const SizedBox(height: 8),
          // A ÚNICA cor forte do ecrã. É aqui que mora o laranja, quando ele
          // aparece — e é por isso que mais nada neste ecrã pode ser laranja.
          Aviso(fecho, tom: tom),
          const SizedBox(height: 8),
          Text(ajuda, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          BotaoOuvir(
            etiqueta: 'cofre-resumo',
            texto: l.cofreOuvir(moeda(saldo), moeda(conta.total), '$fecho $ajuda'),
          ),
        ],
      ),
    );
  }
}

/// O número grande. É o maior do ecrã de propósito: é a pergunta com que a
/// pessoa abre isto ("quanto é que eu tenho de lado?").
class _Saldo extends StatelessWidget {
  final double saldo;
  const _Saldo({required this.saldo});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.cofreTens, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        // Encolhe em vez de partir: "1.234.567,89 €" num telemóvel pequeno
        // rebentava a linha e o número mais importante do ecrã ficava cortado.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            moeda(saldo),
            key: const Key('cofre_saldo'),
            style: t.displayMedium!.copyWith(color: AppColors.primaryDeep),
          ),
        ),
      ],
    );
  }
}

/// "Como cheguei a este número": o rendimento do ano, as duas parcelas, o
/// total, e as ressalvas — a isenção do 1.º ano, o mínimo da Segurança Social
/// e os escalões que ainda não estão confirmados na tabela.
class _CartaoDaConta extends StatelessWidget {
  final ContaDoCofre conta;
  final RegrasLegais regras;
  final int ano;

  /// Último dia coberto pela isenção do 1.º ano, já escrito por extenso. A
  /// nulo quando não se sabe a data de abertura de atividade.
  final String? fimDaIsencaoSs;

  const _CartaoDaConta({
    required this.conta,
    required this.regras,
    required this.ano,
    this.fimDaIsencaoSs,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    // O mínimo mensal da Segurança Social vem da tabela `regras_legais`, como
    // tudo o resto. Se um dia lá faltar, a linha não aparece — mais vale calar
    // do que escrever um número que ninguém confirmou.
    final temMinimo = regras.regra('ss_minimo_mensal')?.valorNum != null;

    return Cartao(
      key: const Key('cofre_conta'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinhaValor(l.cofreDoAno, moeda(conta.rendimento)),
          const Divider(height: 20, color: AppColors.divider),
          LinhaValor(l.cofreParteSs, moeda(conta.segurancaSocial)),
          LinhaValor(l.cofreParteIrs, moeda(conta.irs)),
          LinhaValor(l.cofreParteTotal, moeda(conta.total), destaque: true),
          if (conta.temIsencaoSs && fimDaIsencaoSs != null) ...[
            const SizedBox(height: 8),
            Text(l.cofreIsentoSs(fimDaIsencaoSs!), style: t.bodySmall),
          ],
          if (conta.ssNoMinimo && temMinimo) ...[
            const SizedBox(height: 8),
            Text(l.cofreMinimoSs(moeda(regras.n('ss_minimo_mensal'))), style: t.bodySmall),
          ],
          if (conta.irsAproximado) ...[
            const SizedBox(height: 8),
            Text(l.cofreAproximado('$ano'), style: t.bodySmall),
          ],
          const SizedBox(height: 8),
          Text(l.cofreEstimativa, style: t.bodySmall),
        ],
      ),
    );
  }
}

/// Uma linha do caderno: o que foi, o dia, e quanto. Desliza para a esquerda
/// para apagar; quem não souber deslizar tem o caixote do lixo ao lado — as
/// duas maneiras fazem o mesmo.
class _LinhaMovimento extends StatelessWidget {
  final CofreMovimento movimento;
  final Future<bool> Function() aoConfirmarApagar;
  final VoidCallback aoApagar;
  const _LinhaMovimento({
    required this.movimento,
    required this.aoConfirmarApagar,
    required this.aoApagar,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final m = movimento;

    return Dismissible(
      key: ValueKey('cofre_${m.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => aoConfirmarApagar(),
      onDismissed: (_) => aoApagar(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.passou, borderRadius: AppTheme.cantos),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: Cartao(
        padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: m.poe ? AppColors.primaryWash : AppColors.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconeMovimentoCofre(m),
                size: 22,
                color: m.poe ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rotuloMovimentoCofre(l, m),
                      style: t.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(dataPt(m.data), style: t.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // O sinal está antes do número (e não a cor sozinha a dizê-lo):
            // quem não distingue bem as cores tem de perceber isto na mesma.
            Text(
              '${m.poe ? '+' : '−'} ${moeda(m.quantia)}',
              style: t.titleMedium!.copyWith(
                color: m.poe ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
            IconButton(
              onPressed: () async {
                if (await aoConfirmarApagar()) aoApagar();
              },
              tooltip: l.apagar,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSubtle),
            ),
          ],
        ),
      ),
    );
  }
}

/// Caixa azul de informação (o tom "informação" do design system: nem alarme,
/// nem "está tudo bem" — é só uma explicação).
class _NotaAzul extends StatelessWidget {
  final String texto;
  final IconData icone;

  /// A chave vai para o [Cartao] de dentro — é por ela que os testes e as
  /// fotos apanham esta caixa.
  final Key? chave;
  const _NotaAzul(this.texto, {required this.icone, this.chave});

  @override
  Widget build(BuildContext context) {
    return Cartao(
      key: chave,
      cor: AppColors.infoClaro,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppColors.info, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Esqueleto cinzento da primeira leitura. Blocos do tamanho do que vem a
/// seguir, para o ecrã não saltar quando os números chegam.
class _Esqueleto extends StatelessWidget {
  const _Esqueleto();

  @override
  Widget build(BuildContext context) {
    Widget bloco(double altura, {double largura = double.infinity}) => Container(
          width: largura,
          height: altura,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: AppTheme.cantosPequenos,
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bloco(72),
        const SizedBox(height: 12),
        bloco(180),
        const SizedBox(height: 12),
        bloco(56),
      ],
    );
  }
}
