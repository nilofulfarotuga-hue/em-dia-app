import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/perfil.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../widgets/widgets.dart';
import 'recibos_widgets.dart';

/// Provisão de IRS (regime simplificado): quanto guardar este mês, a
/// estimativa do ano, o mínimo de existência, o aviso das despesas e os três
/// pagamentos por conta. Estimativa, não declaração.
class IrsCard extends StatelessWidget {
  final RegrasLegais regras;
  final Perfil perfil;
  final RendimentosStore rendimentos;
  final DateTime hoje;
  const IrsCard({super.key, required this.regras, required this.perfil, required this.rendimentos, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = regras;
    final media = rendimentos.mediaMensal() ?? perfil.rendimentoMensalEstimado;

    if (media == null || media <= 0) {
      return Cartao(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CabecalhoCartao(
              icone: Icons.savings_rounded,
              titulo: l.irsTitulo,
              direita: BotaoOuvir(
                etiqueta: 'recibos-irs',
                texto: '${l.irsTitulo}. ${l.irsSemDados}',
                soIcone: true,
              ),
            ),
            const SizedBox(height: 12),
            NotaInfo(l.irsSemDados),
          ],
        ),
      );
    }

    final p = calcularIrs(rendimentoBrutoAnual: media * 12, tipo: perfil.tipoRendimento, ano: hoje.year, r: r);
    final datas = datasPagamentosPorConta(hoje.year, r);
    // O cartão inteiro numa frase, para quem prefere ouvir a ler.
    final falado = [
      l.irsTitulo,
      l.irsGuardarEsteMes(moeda(p.guardarPorMes)),
      l.irsBase(moeda(media)),
      l.irsEstimativaAno(moeda(p.impostoEstimado)),
      if (p.abaixoMinimoExistencia) l.irsMinimoExistencia(moeda(r.n('irs_minimo_existencia'), casas: 0)),
      if (p.justificarDespesas) l.irsAvisoDespesas(moeda(r.n('irs_despesas_justificar_limite'), casas: 0)),
      if (p.impostoEstimado > 0) l.irsPagamentosContaAjuda,
      l.irsEstimativaNota,
    ].join('. ');

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoCartao(
            icone: Icons.savings_rounded,
            titulo: l.irsTitulo,
            direita: BotaoOuvir(etiqueta: 'recibos-irs', texto: falado, soIcone: true),
          ),
          if (!p.escaloesConfirmados) ...[
            const SizedBox(height: 8),
            Etiqueta(l.irsEscaloesPorConfirmar(p.anoEscaloes), cor: AppColors.surface2, corTexto: AppColors.textSecondary),
          ],
          const SizedBox(height: 12),
          CaixaDestaque(
            child: Text(l.irsGuardarEsteMes(moeda(p.guardarPorMes)),
                style: t.headlineSmall!.copyWith(color: AppColors.primaryDeep)),
          ),
          const SizedBox(height: 6),
          Text(l.irsBase(moeda(media)), style: t.bodySmall),
          const SizedBox(height: 10),
          Text(l.irsEstimativaAno(moeda(p.impostoEstimado)), style: t.titleMedium),
          if (p.abaixoMinimoExistencia) ...[
            const SizedBox(height: 10),
            Aviso(l.irsMinimoExistencia(moeda(r.n('irs_minimo_existencia'), casas: 0)), tom: Semaforo.verde),
          ],
          if (p.justificarDespesas) ...[
            const SizedBox(height: 10),
            NotaInfo(l.irsAvisoDespesas(moeda(r.n('irs_despesas_justificar_limite'), casas: 0))),
          ],
          if (p.impostoEstimado > 0) ...[
            const SizedBox(height: 14),
            Text(l.irsPagamentosContaTitulo, style: t.titleSmall),
            const SizedBox(height: 4),
            for (final d in datas) LinhaValor(dataExtensoPt(d), moeda(p.pagamentoPorContaCada)),
            Text(l.irsPagamentosContaAjuda, style: t.bodySmall),
          ],
          const SizedBox(height: 10),
          Text(l.irsEstimativaNota, style: t.bodySmall),
        ],
      ),
    );
  }
}
