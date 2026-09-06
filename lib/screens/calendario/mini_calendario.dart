import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';

/// Mini-calendário do mês (Rocket Money "Coming up"): grelha de 7 colunas,
/// semana a começar à segunda, hoje a cheio, dia escolhido com bordo verde e
/// um ponto na cor do semáforo nos dias com obrigações. Sem pacotes externos.
class MiniCalendario extends StatelessWidget {
  /// Qualquer dia do mês a mostrar.
  final DateTime mes;
  final DateTime hoje;
  final DateTime? selecionado;

  /// dia do mês → cor do ponto.
  final Map<int, Color> pontos;

  /// 7 rótulos, de segunda a domingo.
  final List<String> diasSemana;
  final ValueChanged<DateTime> aoTocarDia;

  const MiniCalendario({
    super.key,
    required this.mes,
    required this.hoje,
    required this.pontos,
    required this.diasSemana,
    required this.aoTocarDia,
    this.selecionado,
  });

  @override
  Widget build(BuildContext context) {
    final primeiro = DateTime(mes.year, mes.month, 1);
    final ultimo = DateTime(mes.year, mes.month + 1, 0).day;
    final vazios = primeiro.weekday - 1; // segunda = 0 vazios
    final celulas = <Widget>[];
    for (var i = 0; i < vazios; i++) {
      celulas.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= ultimo; d++) {
      final data = DateTime(mes.year, mes.month, d);
      celulas.add(_Dia(
        numero: d,
        ehHoje: data.year == hoje.year && data.month == hoje.month && data.day == hoje.day,
        selecionado: selecionado != null &&
            selecionado!.year == data.year &&
            selecionado!.month == data.month &&
            selecionado!.day == data.day,
        ponto: pontos[d],
        aoTocar: () => aoTocarDia(data),
      ));
    }
    while (celulas.length % 7 != 0) {
      celulas.add(const SizedBox.shrink());
    }

    final linhas = <Widget>[
      Row(
        children: [
          for (final r in diasSemana.take(7))
            Expanded(
              child: Center(
                child: Text(r,
                    style: const TextStyle(
                        fontFamily: AppTheme.fonte,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
              ),
            ),
        ],
      ),
      const SizedBox(height: 4),
    ];
    for (var i = 0; i < celulas.length; i += 7) {
      linhas.add(Row(
        children: [for (final c in celulas.sublist(i, i + 7)) Expanded(child: SizedBox(height: 42, child: c))],
      ));
    }
    return Column(children: linhas);
  }
}

class _Dia extends StatelessWidget {
  final int numero;
  final bool ehHoje;
  final bool selecionado;
  final Color? ponto;
  final VoidCallback aoTocar;
  const _Dia({
    required this.numero,
    required this.ehHoje,
    required this.selecionado,
    required this.ponto,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final Color fundo;
    final Color texto;
    if (ehHoje) {
      fundo = AppColors.textPrimary;
      texto = Colors.white;
    } else if (selecionado) {
      fundo = AppColors.primaryLight;
      texto = AppColors.primaryDark;
    } else {
      fundo = Colors.transparent;
      texto = AppColors.textPrimary;
    }
    return Center(
      child: Material(
        color: fundo,
        shape: CircleBorder(side: selecionado ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: aoTocar,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text('$numero',
                    style: TextStyle(
                        fontFamily: AppTheme.fonte,
                        fontSize: 14,
                        fontWeight: ehHoje || ponto != null ? FontWeight.w700 : FontWeight.w500,
                        color: texto)),
                if (ponto != null)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: ehHoje ? Colors.white : ponto, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
