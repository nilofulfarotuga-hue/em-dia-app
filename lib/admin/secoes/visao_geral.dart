// Secção 1 — Visão geral: cartões com os números de agora (RPC admin_resumo).
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class VisaoGeralSeccao extends StatefulWidget {
  final AdminDados dados;
  const VisaoGeralSeccao({super.key, required this.dados});

  @override
  State<VisaoGeralSeccao> createState() => _VisaoGeralSeccaoState();
}

class _VisaoGeralSeccaoState extends State<VisaoGeralSeccao> {
  late Future<ResumoAdmin> _f;

  @override
  void initState() {
    super.initState();
    _f = widget.dados.resumo();
  }

  void _recarregar() => setState(() => _f = widget.dados.resumo());

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admVgTitulo,
      subtitulo: l.admVgSub,
      acoes: [BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true)],
      children: [
        Leitura<ResumoAdmin>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          linhasEsqueleto: 10,
          builder: (context, r) => _Conteudo(r),
        ),
      ],
    );
  }
}

class _Conteudo extends StatelessWidget {
  final ResumoAdmin r;
  const _Conteudo(this.r);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final alarmeTxt = r.alarmeEur == null ? '—' : moeda(r.alarmeEur!);
    final cartoes = <Widget>[
      CartaoNumero(
        rotulo: l.admVgUsuarios,
        valor: '${r.usuariosTotal}',
        sub: l.admVgAtivos7(r.usuariosAtivos7d),
        icone: Icons.people_rounded,
      ),
      CartaoNumero(rotulo: l.admVgTrial, valor: '${r.planos['trial'] ?? 0}', icone: Icons.hourglass_top_rounded, cor: AppColors.info),
      CartaoNumero(rotulo: l.admVgFree, valor: '${r.planos['free'] ?? 0}', icone: Icons.person_outline_rounded, cor: AppColors.textSecondary),
      CartaoNumero(rotulo: l.admVgPro, valor: '${r.planos['pro'] ?? 0}', icone: Icons.workspace_premium_rounded, cor: AppColors.cadeado),
      CartaoNumero(rotulo: l.admVgFamilia, valor: '${r.planos['familia'] ?? 0}', icone: Icons.family_restroom_rounded, cor: AppColors.primaryDeep),
      CartaoNumero(
        rotulo: l.admVgReceita,
        valor: moeda(r.receitaMensalEur),
        sub: l.admVgReceitaSub(r.assinaturasAtivas),
        icone: Icons.payments_rounded,
      ),
      CartaoNumero(
        rotulo: l.admVgTickets,
        valor: '${r.ticketsAbertos}',
        sub: l.admVgTicketsSub(r.ticketsEscalados),
        icone: Icons.support_agent_rounded,
        cor: r.ticketsEscalados > 0 ? AppColors.aVencer : AppColors.primary,
      ),
      CartaoNumero(
        rotulo: l.admVgCustoHoje,
        valor: moeda(r.custoIaHoje, casas: 3),
        sub: l.admVgCustoSub(alarmeTxt),
        icone: Icons.smart_toy_rounded,
        alarme: r.alarme,
      ),
      CartaoNumero(
        rotulo: l.admVgCusto7,
        valor: moeda(r.custoIa7d, casas: 3),
        sub: l.admVgCusto7Sub(r.conversas7d),
        icone: Icons.timeline_rounded,
      ),
      CartaoNumero(
        rotulo: l.admVgPassadas,
        valor: '${r.obrigacoesPassadas}',
        sub: l.admVgPassadasSub,
        icone: Icons.event_busy_rounded,
        cor: r.obrigacoesPassadas > 0 ? AppColors.passou : AppColors.primary,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (r.alarme) ...[
          Aviso(l.admVgAlarme(moeda(r.custoIaHoje, casas: 3), alarmeTxt), tom: Semaforo.vermelho),
          const SizedBox(height: 12),
        ],
        LayoutBuilder(
          builder: (context, c) {
            const gap = 12.0;
            final colunas = c.maxWidth >= 900 ? 5 : (c.maxWidth >= 600 ? 3 : 2);
            final w = (c.maxWidth - gap * (colunas - 1)) / colunas;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [for (final x in cartoes) SizedBox(width: w, child: x)],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final estreito = c.maxWidth < 760;
            final custo = TabelaAdmin(
              titulo: l.admVgCusto7,
              colunas: [l.admVgTabDia, l.admVgTabConversas, l.admVgTabCusto],
              linhas: [
                for (final x in r.custoIa)
                  DataRow(cells: [
                    celula(dataOuTraco(lerData(x['dia']))),
                    celula(texto(x['conversas'])),
                    celula(moeda(numero(x['custo_eur']) ?? 0, casas: 4, comSimbolo: false)),
                  ]),
              ],
            );
            final push = r.pushHoje.isEmpty
                ? Cartao(child: Vazio(icone: Icons.notifications_off_outlined, texto: l.admVgPushVazio))
                : TabelaAdmin(
                    titulo: l.admVgPushHoje,
                    colunas: [l.admVgResultado, l.admVgQuantidade],
                    linhas: [
                      for (final e in r.pushHoje.entries)
                        DataRow(cells: [DataCell(Pilula(e.key)), celula('${e.value}')]),
                    ],
                  );
            if (estreito) return Column(children: [custo, const SizedBox(height: 12), push]);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: custo), const SizedBox(width: 12), Expanded(child: push)],
            );
          },
        ),
      ],
    );
  }
}
