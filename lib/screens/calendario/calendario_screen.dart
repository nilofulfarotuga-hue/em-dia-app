import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import 'detalhe_obrigacao.dart';
import 'linha_obrigacao.dart';
import 'mini_calendario.dart';
import 'nova_obrigacao.dart';
import 'tipos_obrigacao.dart';

/// Tela 3 — Calendário de Obrigações (estrutura do Rocket Money "Coming up"):
/// frase-resumo "Este mês pagas N coisas: X €", mini-calendário do mês que
/// filtra por dia, chips por tipo e a lista por horizontes
/// Passou · Hoje · Esta semana · Este mês · Mais tarde (até 12 meses).
/// Toque numa linha abre o detalhe; "+" adiciona multa/portagem/outra.
class CalendarioScreen extends StatefulWidget {
  /// Só para fotos/testes: fixa o "hoje". Na app é sempre [hojeLisboa].
  final DateTime? hoje;
  const CalendarioScreen({super.key, this.hoje});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime? _dia;
  GrupoObrigacao _grupo = GrupoObrigacao.tudo;
  bool _aRecalcular = false;

  DateTime get _hoje => widget.hoje ?? hojeLisboa();

  bool _noGrupo(ObrigacaoItem o) => _grupo == GrupoObrigacao.tudo || grupoDoTipo(o.tipo) == _grupo;

  bool _mesmoDia(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void _snack(String texto) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _recalcular() async {
    final l = AppLocalizations.of(context);
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) {
      _snack(l.calSemSessao);
      return;
    }
    setState(() => _aRecalcular = true);
    final ok = await context.read<ObrigacoesStore>().recalcular(userId);
    if (!mounted) return;
    setState(() => _aRecalcular = false);
    _snack(ok ? l.calRecalculado : l.calErro);
  }

  Future<void> _adicionar() async {
    final l = AppLocalizations.of(context);
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) {
      _snack(l.calSemSessao);
      return;
    }
    final ok = await mostrarNovaObrigacao(context, userId: userId, hoje: _hoje);
    if (ok == true && mounted) _snack(l.calNovaGuardada);
  }

  Future<void> _atualizar() async {
    final userId = context.read<SessaoStore>().userId;
    if (userId != null) await context.read<ObrigacoesStore>().carregar(userId);
  }

  /// dia → cor do ponto (o pior estado do dia ganha: passou > a vencer > em dia).
  Map<int, Color> _pontos(List<ObrigacaoItem> itens, DateTime hoje) {
    int peso(Color c) => c == AppColors.passou ? 3 : (c == AppColors.aVencer ? 2 : 1);
    final out = <int, Color>{};
    for (final o in itens) {
      if (o.dataLimite.year != hoje.year || o.dataLimite.month != hoje.month) continue;
      final c = corDaObrigacao(o, hoje);
      final atual = out[o.dataLimite.day];
      if (atual == null || peso(c) > peso(atual)) out[o.dataLimite.day] = c;
    }
    return out;
  }

  /// Horizontes: Passou (só por pagar) · Hoje · Esta semana (7 dias) ·
  /// Este mês · Mais tarde · Já pagaste (pagas com data passada).
  List<_Seccao> _seccoes(AppLocalizations l, List<ObrigacaoItem> itens, DateTime hoje) {
    final passou = <ObrigacaoItem>[];
    final hojeL = <ObrigacaoItem>[];
    final semana = <ObrigacaoItem>[];
    final mes = <ObrigacaoItem>[];
    final tarde = <ObrigacaoItem>[];
    final pagas = <ObrigacaoItem>[];
    for (final o in itens) {
      final d = o.diasParaPrazo(hoje);
      if (d < 0) {
        (o.pago ? pagas : passou).add(o);
      } else if (d == 0) {
        hojeL.add(o);
      } else if (d <= 7) {
        semana.add(o);
      } else if (o.dataLimite.year == hoje.year && o.dataLimite.month == hoje.month) {
        mes.add(o);
      } else {
        tarde.add(o);
      }
    }
    return [
      if (passou.isNotEmpty) _Seccao(l.calPassou, passou, cor: AppColors.passou),
      if (hojeL.isNotEmpty) _Seccao(l.hoje, hojeL),
      if (semana.isNotEmpty) _Seccao(l.calEstaSemana, semana),
      if (mes.isNotEmpty) _Seccao(l.calEsteMes, mes),
      if (tarde.isNotEmpty) _Seccao(l.calMaisTarde, tarde),
      if (pagas.isNotEmpty) _Seccao(l.calJaPagaste, pagas, cor: AppColors.primaryDark),
    ];
  }

  /// "Este mês pagas 3 coisas: 312,40 €" com o valor a verde e maior.
  /// O espaço antes do "€" é inquebrável, para o símbolo nunca cair sozinho.
  Widget _fraseResumo(AppLocalizations l, TextTheme t, int n, double total) {
    final valor = moeda(total).replaceAll(' ', ' ');
    final frase = l.calResumo(n, valor);
    final base = t.titleLarge!;
    final i = n == 0 ? -1 : frase.indexOf(valor);
    if (i < 0) return Text(frase, style: base);
    return Text.rich(TextSpan(style: base, children: [
      TextSpan(text: frase.substring(0, i)),
      TextSpan(
          text: valor, style: base.copyWith(color: AppColors.primaryDark, fontSize: 22, fontWeight: FontWeight.w800)),
      TextSpan(text: frase.substring(i + valor.length)),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final store = context.watch<ObrigacoesStore>();
    final hoje = _hoje;
    final limite = adicionarMeses(hoje, 12);

    final todos = store.itens.where((o) => !o.dataLimite.isAfter(limite)).toList();
    final pagamentosDoMes = store.doMes(hoje).where((o) => o.ehPagamento).toList();
    final totalMes = pagamentosDoMes.fold<double>(0, (s, o) => s + (o.valorEstimado ?? 0));
    final doGrupo = todos.where(_noGrupo).toList();
    final visiveis = _dia == null ? doGrupo : doGrupo.where((o) => _mesmoDia(o.dataLimite, _dia!)).toList();
    final seccoes = _seccoes(l, visiveis, hoje);
    final nomeMesTitulo = nomeMes(hoje.month);
    final tituloMes = '${nomeMesTitulo[0].toUpperCase()}${nomeMesTitulo.substring(1)} ${hoje.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(l.calTitulo),
        actions: [
          // "+" no topo (Rocket Money): nunca tapa o valor de uma linha.
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _adicionar,
              icon: const Icon(Icons.add_circle_rounded, size: 26),
              label: Text(l.calAdicionar),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: paddingEcra,
          children: [
            // ---- "Coming up": frase-resumo + mini-calendário ----
            Cartao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A frase que resume o mês é a explicação deste ecrã — logo
                  // leva o botão de ouvir, encostado ao canto para não roubar
                  // espaço ao número.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _fraseResumo(l, t, pagamentosDoMes.length, totalMes)),
                      BotaoOuvir(
                        etiqueta: 'calendario-resumo-mes',
                        texto: l.calResumo(pagamentosDoMes.length, moeda(totalMes)),
                        soIcone: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(tituloMes, style: t.titleSmall!.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  MiniCalendario(
                    mes: hoje,
                    hoje: hoje,
                    selecionado: _dia,
                    pontos: _pontos(doGrupo, hoje),
                    diasSemana: l.calDiasSemana.split(','),
                    aoTocarDia: (d) => setState(() => _dia = (_dia != null && _mesmoDia(_dia!, d)) ? null : d),
                  ),
                  if (_dia != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Expanded(child: Text(l.calDiaSelecionado(dataPt(_dia!)), style: t.bodySmall)),
                          TextButton(onPressed: () => setState(() => _dia = null), child: Text(l.calLimparFiltro)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ---- chips por tipo (em Wrap: nada fica cortado nem escondido) ----
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final g in GrupoObrigacao.values)
                  ChoiceChip(
                    label: Text(rotuloDoGrupo(l, g)),
                    selected: _grupo == g,
                    showCheckmark: false,
                    labelStyle: TextStyle(color: _grupo == g ? AppColors.primaryDark : AppColors.textPrimary),
                    onSelected: (_) => setState(() => _grupo = g),
                  ),
              ],
            ),

            // ---- estados ----
            if (store.erro != null) ...[
              const SizedBox(height: 12),
              Aviso(l.calErro, tom: Semaforo.vermelho),
            ],
            if (store.aCarregar && store.itens.isEmpty)
              const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
            else if (todos.isEmpty)
              Vazio(
                icone: Icons.event_available_rounded,
                texto: l.calSemObrigacoes,
                acao: BotaoGrande(
                  texto: l.calRecalcular,
                  icone: Icons.refresh_rounded,
                  aTrabalhar: _aRecalcular,
                  aoTocar: _recalcular,
                ),
              )
            else if (visiveis.isEmpty)
              Vazio(
                icone: Icons.filter_list_off_rounded,
                texto: l.calSemNesteFiltro,
                acao: TextButton(
                  onPressed: () => setState(() {
                    _dia = null;
                    _grupo = GrupoObrigacao.tudo;
                  }),
                  child: Text(l.calLimparFiltro),
                ),
              )
            else
              for (final s in seccoes) ...[
                _Cabecalho(s.titulo, cor: s.cor),
                for (final o in s.itens)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LinhaObrigacao(
                      key: ValueKey('obrig-${o.id}'),
                      obrigacao: o,
                      hoje: hoje,
                      aoTocar: () => mostrarDetalheObrigacao(context, obrigacao: o, hoje: hoje),
                    ),
                  ),
              ],
          ],
        ),
      ),
    );
  }
}

class _Seccao {
  final String titulo;
  final List<ObrigacaoItem> itens;
  final Color? cor;
  const _Seccao(this.titulo, this.itens, {this.cor});
}

/// Título de horizonte ("PASSOU", "HOJE", …) — 13 px, cor do estado.
class _Cabecalho extends StatelessWidget {
  final String texto;
  final Color? cor;
  const _Cabecalho(this.texto, {this.cor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(texto.toUpperCase(),
          style: TextStyle(
              fontFamily: AppTheme.fonte,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: cor ?? AppColors.textSecondary)),
    );
  }
}
