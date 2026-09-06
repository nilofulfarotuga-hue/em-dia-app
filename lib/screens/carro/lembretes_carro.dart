/// Lembretes do carro (Drivvo adaptado a Portugal): IUC, inspeção, seguro,
/// carta e revisão. As datas vêm das regras (`lib/regras/carro.dart`) ou, se
/// o servidor já gerou a obrigação (mesmo tipo + carro), da própria obrigação
/// — que é a fonte de verdade e traz o valor, o "como pagar" e o "já paguei".
library;

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/carro.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import '../../widgets/widgets.dart';
import '../calendario/tipos_obrigacao.dart';
import 'widgets_carro.dart';

class Lembrete {
  final String tipo; // iuc | ipo | seguro | carta | revisao
  final String titulo;
  final DateTime? data;
  final int? faltamKm; // revisão por km
  final double? valor;
  final bool aproximado;
  final String? detalhe;
  final ObrigacaoItem? obrigacao;
  final int diasAviso; // a partir de quantos dias fica laranja

  const Lembrete({
    required this.tipo,
    required this.titulo,
    this.data,
    this.faltamKm,
    this.valor,
    this.aproximado = false,
    this.detalhe,
    this.obrigacao,
    this.diasAviso = 5,
  });

  bool get pago => obrigacao?.pago == true;
  int? dias(DateTime hoje) => data == null ? null : diasAte(data!, hoje);

  /// Cor do semáforo: pago → verde; passou → vermelho; dentro do aviso →
  /// laranja; senão verde.
  Color cor(DateTime hoje) {
    if (pago) return AppColors.emDia;
    final d = dias(hoje);
    if (d == null) return AppColors.emDia;
    if (d < 0) return AppColors.passou;
    if (d <= diasAviso) return AppColors.aVencer;
    return AppColors.emDia;
  }
}

/// A obrigação pendente mais próxima deste tipo para este carro (ou null).
ObrigacaoItem? obrigacaoDoCarro(List<ObrigacaoItem> obrigacoes, String carroId, String tipo, DateTime hoje) {
  final xs = obrigacoes.where((o) => o.tipo == tipo && o.carroId == carroId && !o.passou(hoje)).toList()
    ..sort((a, b) => a.dataLimite.compareTo(b.dataLimite));
  return xs.isEmpty ? null : xs.first;
}

List<Lembrete> lembretesDoCarro(
  AppLocalizations l, {
  required Carro carro,
  required RegrasLegais r,
  required List<ObrigacaoItem> obrigacoes,
  required DateTime hoje,
}) {
  final out = <Lembrete>[];
  final m = carro.matriculaEfetiva;
  ObrigacaoItem? obrig(String tipo) => obrigacaoDoCarro(obrigacoes, carro.id, tipo, hoje);

  // IUC — todos os anos, até ao fim do mês da matrícula.
  if (m != null) {
    final o = obrig('iuc');
    final est = estimarIuc(
        matricula: m, combustivel: carro.combustivel, cilindradaCc: carro.cilindradaCc, co2: carro.co2, r: r);
    out.add(Lembrete(
      tipo: 'iuc',
      titulo: l.carroTipoIuc, // "IUC" curto; "imposto do carro" vai no detalhe
      data: o?.dataLimite ?? proximoIuc(mesMatricula: m.month, hoje: hoje),
      valor: o?.valorEstimado ?? est?.valor,
      aproximado: est?.aproximado ?? true,
      detalhe: est == null && o?.valorEstimado == null ? l.carroIucSemEstimativa : l.carroIucOnde,
      obrigacao: o,
    ));
  }

  // Inspeção — 4/6/8 anos e depois anual (TVDE: anual, por confirmar).
  {
    final o = obrig('ipo');
    final data = o?.dataLimite ??
        carro.proximaIpo ??
        (m == null ? null : proximaIpo(matricula: m, ultimaIpo: carro.ultimaIpo, hoje: hoje, tvde: carro.usoTvde, r: r));
    final avisos = avisosIpo(r);
    if (data != null) {
      out.add(Lembrete(
        tipo: 'ipo',
        titulo: l.carroIpo,
        data: data,
        valor: o?.valorEstimado,
        aproximado: true,
        detalhe: carro.usoTvde
            ? l.carroIpoTvde
            : (avisos.length >= 2 ? l.carroIpoAvisos(avisos[0], avisos[1]) : null),
        obrigacao: o,
        diasAviso: avisos.isEmpty ? 30 : avisos.first,
      ));
    }
  }

  // Seguro — renova todos os anos; 45 dias antes é a altura de comparar.
  if (carro.seguroRenovaEm != null) {
    final o = obrig('seguro');
    var s = soDia(carro.seguroRenovaEm!);
    while (s.isBefore(hoje)) {
      s = adicionarAnos(s, 1);
    }
    final data = o?.dataLimite ?? s;
    final aviso = r.n('seguro_aviso_dias').toInt();
    final d = diasAte(data, hoje);
    out.add(Lembrete(
      tipo: 'seguro',
      titulo: l.carroSeguro,
      data: data,
      valor: o?.valorEstimado,
      detalhe: d >= 0 && d <= aviso
          ? l.carroSeguroCompara
          : (carro.seguradora == null || carro.seguradora!.isEmpty ? null : l.carroSeguradoraLinha(carro.seguradora!)),
      obrigacao: o,
      diasAviso: aviso,
    ));
  }

  // Carta de condução — 15 anos até aos 60, 5 até aos 70, depois 2.
  if (carro.cartaValidade != null) {
    final o = obrig('carta');
    final v = r.json('carta_validade') as Map;
    out.add(Lembrete(
      tipo: 'carta',
      titulo: l.carroCarta,
      data: o?.dataLimite ?? carro.cartaValidade,
      detalhe: l.carroCartaRegra(
          (v['ate_60'] as num).toInt(), (v['60_a_70'] as num).toInt(), (v['mais_70'] as num).toInt()),
      obrigacao: o,
      diasAviso: 30,
    ));
  }

  // Revisão — por data ou por km.
  if (carro.revisaoProxima != null || carro.revisaoKm != null) {
    final o = obrig('revisao');
    final faltam = (carro.revisaoKm != null && carro.kmAtual != null) ? carro.revisaoKm! - carro.kmAtual! : null;
    out.add(Lembrete(
      tipo: 'revisao',
      titulo: l.carroRevisao,
      data: o?.dataLimite ?? carro.revisaoProxima,
      faltamKm: faltam,
      detalhe: carro.revisaoKm == null ? null : l.carroRevisaoAosKm(kmTxt(carro.revisaoKm!)),
      obrigacao: o,
      diasAviso: 30,
    ));
  }

  out.sort((a, b) {
    final da = a.data, db = b.data;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  });
  return out;
}

/// "faltam N dias · 24/10/2026" · "é hoje" · "passou há N dias" · "faltam N km".
String textoLembrete(AppLocalizations l, Lembrete x, DateTime hoje) {
  if (x.pago) return l.calPago;
  final partes = <String>[];
  final d = x.dias(hoje);
  if (d != null) {
    if (d < 0) {
      partes.add(l.calPassouHa(-d));
    } else if (d == 0) {
      partes.add(l.calEhHoje);
    } else if (d <= 365) {
      partes.add(l.calFaltamDias(d)); // a mais de um ano "faltam 1709 dias" não ajuda: só a data
    }
    partes.add(dataPt(x.data!));
  }
  if (x.faltamKm != null) partes.add(l.carroFaltamKm(x.faltamKm!));
  if (partes.isEmpty) partes.add(l.carroSemData);
  return partes.join(' · ');
}

/// Cartão de lembrete: barra lateral de 4 px na cor do estado, círculo com
/// o ícone do tipo, título, detalhe, "faltam N dias" e o valor à direita
/// com a etiqueta "aproximado" quando é estimativa.
class CartaoLembrete extends StatelessWidget {
  final Lembrete lembrete;
  final DateTime hoje;
  final VoidCallback aoTocar;
  const CartaoLembrete({super.key, required this.lembrete, required this.hoje, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final x = lembrete;
    final cor = x.cor(hoje);

    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTheme.cantos, boxShadow: AppTheme.sombraCartao),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.cantos,
          onTap: aoTocar,
          child: ClipRRect(
            borderRadius: AppTheme.cantos,
            child: Stack(
              children: [
                Positioned(left: 0, top: 0, bottom: 0, width: 4, child: ColoredBox(color: cor)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: x.pago ? AppColors.emDiaClaro : AppColors.surface2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(x.pago ? Icons.check_rounded : iconeDoTipo(x.tipo),
                            size: 22, color: x.pago ? AppColors.primaryDark : AppColors.textPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(x.titulo, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (x.detalhe != null) ...[
                              const SizedBox(height: 2),
                              Text(x.detalhe!, style: t.bodySmall, maxLines: 3, overflow: TextOverflow.ellipsis),
                            ],
                            const SizedBox(height: 4),
                            Text(textoLembrete(l, x, hoje),
                                style: TextStyle(
                                    fontFamily: AppTheme.fonte, fontSize: 13, fontWeight: FontWeight.w700, color: cor)),
                          ],
                        ),
                      ),
                      if (x.valor != null) ...[
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(moeda(x.valor!), style: t.titleMedium),
                            if (x.aproximado) ...[
                              const SizedBox(height: 4),
                              Etiqueta(l.calAproximado, cor: AppColors.surface2, corTexto: AppColors.textSecondary),
                            ],
                          ],
                        ),
                      ],
                    ],
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

/// Folha simples com a informação do lembrete (quando ainda não há obrigação
/// no calendário para abrir o detalhe completo).
Future<void> mostrarInfoLembrete(BuildContext context, {required Lembrete lembrete, required DateTime hoje}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      final l = AppLocalizations.of(ctx);
      final t = Theme.of(ctx).textTheme;
      final x = lembrete;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(x.titulo, style: t.headlineSmall),
            const SizedBox(height: 8),
            Text(textoLembrete(l, x, hoje),
                style: t.titleMedium!.copyWith(color: x.cor(hoje), fontWeight: FontWeight.w700)),
            if (x.valor != null) ...[
              const SizedBox(height: 8),
              LinhaValor(l.calValorEstimado, moeda(x.valor!), destaque: true),
            ],
            if (x.detalhe != null) ...[
              const SizedBox(height: 8),
              Text(x.detalhe!, style: t.bodyMedium),
            ],
            const SizedBox(height: 12),
            Aviso(l.carroSoInformacao, tom: Semaforo.verde, icone: Icons.info_outline_rounded),
          ],
        ),
      );
    },
  );
}
