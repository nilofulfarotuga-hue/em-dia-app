import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../stores/resumo_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';

/// Tela "Como está o meu mês" — o resumo do mês e do ano.
///
/// Em cima, o único número que interessa mesmo: COMO ACABA O MÊS. Verde se
/// sobra, vermelho se falta — e, quando falta, é o único alarme do ecrã, com a
/// sugestão do que fazer a seguir. Por baixo, os quatro números (entrou, saiu,
/// falta pagar contas, falta pagar ao Estado), o cofre do imposto e um botão
/// de ouvir com a frase toda.
///
/// Em baixo, o ano para o IRS: quanto entrou, quanto disso conta, de onde veio
/// o dinheiro e um gráfico de doze barras, mês a mês.
///
/// A regra do laranja: o cartão de cima já é verde ou vermelho, por isso o
/// ÚNICO elemento laranja do ecrã é o aviso "ainda tens de pagar X" — e esse
/// só aparece quando o mês acaba bem. Se o mês acabar mal, o alarme é o cartão
/// vermelho e mais nada.
class ResumoScreen extends StatefulWidget {
  /// Dia de referência (testes/fotos). Na app é sempre `hojeLisboa()`.
  final DateTime? hoje;

  /// Para onde vai o botão do estado vazio ("escrever a primeira coisa").
  /// O orquestrador liga isto ao ecrã de escrever uma entrada; sem ele o
  /// convite fica só com o texto, nunca com um botão que não faz nada.
  final VoidCallback? aoEscreverPrimeira;

  const ResumoScreen({super.key, this.hoje, this.aoEscreverPrimeira});

  @override
  State<ResumoScreen> createState() => _ResumoScreenState();
}

class _ResumoScreenState extends State<ResumoScreen> {
  /// A primeira leitura manda o ano de hoje; as seguintes respeitam o ano que
  /// a pessoa escolheu no seletor (puxar para baixo não pode desfazer isso).
  bool _primeiraLeitura = true;

  DateTime get _hoje => widget.hoje ?? hojeLisboa();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) return;
    final store = context.read<ResumoStore>();
    await store.carregar(userId, ano: _primeiraLeitura ? _hoje.year : null);
    _primeiraLeitura = false;
  }

  Future<void> _mudarAno(int ano) async {
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) return;
    await context.read<ResumoStore>().escolherAno(userId, ano);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = context.watch<ResumoStore>();
    final semSessao = context.watch<SessaoStore>().userId == null;

    // Enquanto não há nada para mostrar: esqueleto cinzento, nunca uma roda a
    // girar sem fim.
    final aCarregarPrimeira = store.aCarregar && !store.temDados;
    final erroSemDados = !store.aCarregar && store.erro != null && !store.temDados;

    // Sem Scaffold nem AppBar proprios: esta tela vive DENTRO da aba "Sobra" da
    // tela da vida, que ja tem barra de titulo e barra de separadores. Com os
    // dois, ficavam ~150 px de cabecalhos empilhados antes do primeiro numero —
    // apanhado pela fabrica de fotos em vida_sobra_bom_*.
    return RefreshIndicator(
      onRefresh: _carregar,
      child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: paddingEcra,
          children: [
            if (semSessao)
              Aviso(l.resumoSemSessao, tom: Semaforo.amarelo, icone: Icons.person_outline_rounded)
            else if (aCarregarPrimeira)
              const _Esqueleto()
            else if (erroSemDados) ...[
              Aviso(l.erroRede, tom: Semaforo.vermelho, icone: Icons.wifi_off_rounded),
              const SizedBox(height: 12),
              BotaoGrande(texto: l.tentarOutraVez, secundario: true, aoTocar: _carregar),
            ] else if (store.semNada) ...[
              const SizedBox(height: 24),
              Vazio(
                icone: Icons.edit_note_rounded,
                texto: l.resumoVazioTexto,
                acao: widget.aoEscreverPrimeira == null
                    ? null
                    : BotaoGrande(
                        texto: l.resumoVazioBotao,
                        icone: Icons.add_rounded,
                        aoTocar: widget.aoEscreverPrimeira,
                      ),
              ),
            ] else ...[
              // Houve rede antes e falhou agora: mostra-se o aviso mas
              // guardam-se os números de há um minuto. Ecrã preso, nunca.
              if (store.erro != null) ...[
                Aviso(l.erroRede, tom: Semaforo.vermelho, icone: Icons.wifi_off_rounded),
                const SizedBox(height: 8),
                BotaoGrande(texto: l.tentarOutraVez, secundario: true, aoTocar: _carregar),
                const SizedBox(height: 16),
              ],
              if (store.mes != null) ..._blocoMes(l, store.mes!),
              const SizedBox(height: 8),
              TituloSeccao(
                l.resumoAnoSeccao,
                acao: _SeletorAno(
                  anoEscolhido: store.anoEscolhido,
                  esteAno: _hoje.year,
                  aoEscolher: _mudarAno,
                ),
              ),
              if (store.aCarregarAno)
                const _EsqueletoAno()
              else if (store.ano != null)
                ..._blocoAno(l, store.ano!),
            ],
          ],
        ),
    );
  }

  // ------------------------------------------------------------------ o mês
  List<Widget> _blocoMes(AppLocalizations l, ResumoMes m) {
    final t = Theme.of(context).textTheme;
    final fim = m.comoAcabaOMes;
    final mau = fim < 0;
    // O laranja só entra quando o cartão de cima é verde: se o mês acaba mal,
    // o alarme já está dado e um segundo alarme só atrapalha.
    final mostrarLaranja = !mau && m.faltaPagarTudo > 0;

    return [
      TituloSeccao(l.resumoMesSeccao(nomeMes(m.mes.month))),
      SemaforoGrande(
        estado: mau ? Semaforo.vermelho : Semaforo.verde,
        titulo: mau
            ? l.resumoFalta(moeda(fim.abs()))
            : fim > 0
                ? l.resumoSobra(moeda(fim))
                : l.resumoZero,
        subtitulo: mau
            ? l.resumoFaltaAjuda
            : fim > 0
                ? l.resumoSobraAjuda
                : l.resumoZeroAjuda,
      ),
      const SizedBox(height: 12),
      Cartao(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Numero(rotulo: l.resumoEntrou, valor: moeda(m.entrou))),
                Expanded(child: _Numero(rotulo: l.resumoSaiu, valor: moeda(m.saiu))),
              ],
            ),
            const Divider(height: 24, color: AppColors.divider),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Numero(rotulo: l.resumoFaltaContas, valor: moeda(m.faltaPagarContas))),
                Expanded(child: _Numero(rotulo: l.resumoFaltaEstado, valor: moeda(m.faltaPagarEstado))),
              ],
            ),
          ],
        ),
      ),
      if (mostrarLaranja) ...[
        const SizedBox(height: 12),
        // O ÚNICO elemento laranja do ecrã.
        Aviso(l.resumoAindaFalta(moeda(m.faltaPagarTudo)), tom: Semaforo.amarelo),
      ],
      const SizedBox(height: 12),
      Cartao(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.savings_rounded, color: AppColors.primaryDark, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.resumoCofre, style: t.titleMedium),
                  const SizedBox(height: 2),
                  Text(m.noCofre > 0 ? l.resumoCofreAjuda : l.resumoCofreVazio, style: t.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(moeda(m.noCofre), style: t.titleLarge!.copyWith(color: AppColors.primaryDark)),
          ],
        ),
      ),
      BotaoOuvir(etiqueta: 'resumo-mes', texto: _fraseDoMes(l, m)),
    ];
  }

  /// A frase toda do mês, para quem prefere ouvir a ler.
  String _fraseDoMes(AppLocalizations l, ResumoMes m) {
    final fim = m.comoAcabaOMes;
    final fecho = fim > 0
        ? l.resumoFraseSobra(moeda(fim))
        : fim < 0
            ? l.resumoFraseFalta(moeda(fim.abs()))
            : l.resumoFraseZero;
    return l.resumoOuvirMes(
      fecho,
      moeda(m.entrou),
      moeda(m.saiu),
      moeda(m.faltaPagarContas),
      moeda(m.faltaPagarEstado),
      moeda(m.noCofre),
    );
  }

  // ------------------------------------------------------------------ o ano
  List<Widget> _blocoAno(AppLocalizations l, ResumoAno a) {
    final t = Theme.of(context).textTheme;
    final ano = '${a.ano}';

    if (a.semNada) {
      return [
        Cartao(child: Vazio(icone: Icons.bar_chart_rounded, texto: l.resumoAnoVazio(ano))),
      ];
    }

    return [
      Cartao(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Numero(rotulo: l.resumoAnoEntrou(ano), valor: moeda(a.entrouTotal))),
                Expanded(
                  child: _Numero(
                    rotulo: l.resumoAnoIrs,
                    valor: moeda(a.entrouParaIrs),
                    cor: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(l.resumoAnoIrsAjuda, style: t.bodySmall),
            BotaoOuvir(etiqueta: 'resumo-ano', texto: l.resumoAnoIrsAjuda),
            if (a.saiuTotal > 0) Text(l.resumoAnoSaiu(moeda(a.saiuTotal)), style: t.bodySmall),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (a.tiposPorTamanho.isNotEmpty) ...[
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.resumoAnoPorTipo, style: t.titleMedium),
              const SizedBox(height: 4),
              for (final e in a.tiposPorTamanho) LinhaValor(_nomeTipo(l, e.key), moeda(e.value)),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
      Cartao(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.resumoAnoPorMes, style: t.titleMedium),
            const SizedBox(height: 16),
            _GraficoMeses(
              meses: a.porMes,
              // Só se marca o mês de hoje quando se está mesmo a ver o ano de
              // hoje — no ano passado não há "mês atual".
              mesEmDestaque: a.ano == _hoje.year ? _hoje.month : null,
            ),
          ],
        ),
      ),
    ];
  }
}

/// O nome humano de cada tipo de entrada. O que vem do servidor são chaves
/// (`recibo_verde`, `dinheiro_mao`); ninguém tem de ler isso.
String _nomeTipo(AppLocalizations l, String tipo) => switch (tipo) {
      'recibo_verde' => l.resumoTipoReciboVerde,
      'plataforma' => l.resumoTipoPlataforma,
      'salario' => l.resumoTipoSalario,
      'dinheiro_mao' => l.resumoTipoDinheiroMao,
      'arrendamento' => l.resumoTipoArrendamento,
      'subsidio' => l.resumoTipoSubsidio,
      'pensao' => l.resumoTipoPensao,
      _ => l.resumoTipoOutro,
    };

/// Um número com o seu rótulo por cima. Cor neutra por omissão: a cor é para
/// o cartão de cima e para o aviso laranja, não para quatro números seguidos.
class _Numero extends StatelessWidget {
  final String rotulo;
  final String valor;
  final Color? cor;
  const _Numero({required this.rotulo, required this.valor, this.cor});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(valor, style: t.titleLarge!.copyWith(color: cor ?? AppColors.textPrimary)),
      ],
    );
  }
}

/// Seletor de ano discreto: este ano e o anterior, nada mais.
class _SeletorAno extends StatelessWidget {
  final int anoEscolhido;
  final int esteAno;
  final ValueChanged<int> aoEscolher;
  const _SeletorAno({required this.anoEscolhido, required this.esteAno, required this.aoEscolher});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Pilula(texto: l.resumoAnoPassado, ligada: anoEscolhido == esteAno - 1, aoTocar: () => aoEscolher(esteAno - 1)),
        const SizedBox(width: 6),
        _Pilula(texto: l.resumoEsteAno, ligada: anoEscolhido == esteAno, aoTocar: () => aoEscolher(esteAno)),
      ],
    );
  }
}

class _Pilula extends StatelessWidget {
  final String texto;
  final bool ligada;
  final VoidCallback aoTocar;
  const _Pilula({required this.texto, required this.ligada, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ligada ? AppColors.primaryLight : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            texto,
            style: TextStyle(
              fontFamily: AppTheme.fonte,
              fontSize: 13,
              fontWeight: ligada ? FontWeight.w700 : FontWeight.w500,
              color: ligada ? AppColors.primaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Doze barras, uma por mês. Mês sem nada fica a zero, mas com o lugar
/// desenhado a cinzento — assim vê-se logo que o mês existe e está vazio.
class _GraficoMeses extends StatelessWidget {
  final List<double> meses;
  final int? mesEmDestaque;
  const _GraficoMeses({required this.meses, this.mesEmDestaque});

  @override
  Widget build(BuildContext context) {
    final maior = meses.fold<double>(0, (m, v) => v > m ? v : m);
    // Sem nenhum valor, o topo tem de ser > 0 ou o gráfico não desenha nada.
    final topo = maior <= 0 ? 1.0 : maior * 1.15;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          minY: 0,
          maxY: topo,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (valor, meta) {
                  final i = valor.toInt();
                  if (i < 0 || i > 11) return const SizedBox.shrink();
                  final destaque = mesEmDestaque == i + 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      nomesMesesCurtos[i],
                      style: TextStyle(
                        fontFamily: AppTheme.fonte,
                        fontSize: 10,
                        fontWeight: destaque ? FontWeight.w700 : FontWeight.w500,
                        color: destaque ? AppColors.primaryDark : AppColors.textSubtle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < 12; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: meses[i],
                    width: 12,
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: topo,
                      color: AppColors.surface2,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Esqueleto cinzento enquanto os números não chegam (nunca uma roda a girar).
class _Esqueleto extends StatelessWidget {
  const _Esqueleto();

  static Widget _bloco(double altura) => Container(
        width: double.infinity,
        height: altura,
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: AppTheme.cantos),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _bloco(24),
        const SizedBox(height: 12),
        _bloco(160),
        const SizedBox(height: 12),
        _bloco(130),
        const SizedBox(height: 12),
        _bloco(80),
        const SizedBox(height: 24),
        _bloco(200),
      ],
    );
  }
}

/// O mesmo, mas só para o cartão do ano (quando se troca de ano o mês fica).
class _EsqueletoAno extends StatelessWidget {
  const _EsqueletoAno();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Esqueleto._bloco(110),
        const SizedBox(height: 12),
        _Esqueleto._bloco(220),
      ],
    );
  }
}
