import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import '../../widgets/widgets.dart';

/// Ícone por tipo de obrigação (o círculo à esquerda de cada linha).
IconData iconeDoTipo(String tipo) => switch (tipo) {
      'ss_declaracao' || 'ss_pagamento' || 'fim_isencao_ss' => Icons.health_and_safety_rounded,
      'iva_declaracao' || 'iva_pagamento' || 'irs_entrega' || 'irs_pagamento_conta' => Icons.account_balance_rounded,
      'efatura_validar' || 'recibos_comunicar' => Icons.receipt_long_rounded,
      'iuc' || 'ipo' || 'seguro' || 'revisao' || 'tvde_licenca' => Icons.directions_car_rounded,
      'carta' || 'troca_carta' || 'tvde_certificado' => Icons.badge_rounded,
      'residencia' => Icons.home_rounded,
      'multa' || 'portagem' => Icons.local_police_rounded,
      _ => Icons.event_note_rounded,
    };

/// Nome sem jargão: siglas (IUC, IVA) e "pagamento por conta" levam a
/// explicação entre parênteses (regra do fiscal visual).
String nomeHumano(AppLocalizations l, ObrigacaoItem o) => switch (o.tipo) {
      'iuc' => l.painelNomeIuc,
      'iva_pagamento' => l.painelNomeIva,
      'irs_pagamento_conta' => l.painelNomeIrsConta,
      _ => o.nomeCurto,
    };

/// Cartão "Este mês pagas": total no topo, lista com valor e dia.
/// Sem laranja aqui — o estado "a vencer" já está no semáforo.
class CartaoEsteMes extends StatelessWidget {
  final List<ObrigacaoItem> itens; // só as de pagamento (ehPagamento) do mês
  final DateTime hoje;
  const CartaoEsteMes({super.key, required this.itens, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final total = itens.fold<double>(0, (s, o) => s + (o.valorEstimado ?? 0));

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.cartaoEsteMesPagas, style: t.titleMedium),
          const SizedBox(height: 4),
          if (itens.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  const Icon(Icons.sentiment_satisfied_alt_rounded, color: AppColors.emDia, size: 28),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.nadaAPagarEsteMes, style: t.bodyMedium)),
                ],
              ),
            )
          else ...[
            Text(moeda(total), style: t.headlineMedium!.copyWith(color: AppColors.primaryDark)),
            const SizedBox(height: 8),
            for (var i = 0; i < itens.length; i++) ...[
              if (i > 0) const Divider(height: 12),
              _LinhaObrigacao(item: itens[i], hoje: hoje),
            ],
          ],
        ],
      ),
    );
  }
}

class _LinhaObrigacao extends StatelessWidget {
  final ObrigacaoItem item;
  final DateTime hoje;
  const _LinhaObrigacao({required this.item, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final passou = item.passou(hoje);
    // Cor do estado sem laranja: pago = verde, passou = vermelho, resto = neutro.
    final cor = item.pago
        ? AppColors.emDia
        : passou
            ? AppColors.passou
            : AppColors.textSubtle;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(color: AppColors.surface2, shape: BoxShape.circle),
            child: Icon(item.pago ? Icons.check_rounded : iconeDoTipo(item.tipo), size: 20, color: cor == AppColors.textSubtle ? AppColors.textSecondary : cor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nomeHumano(l, item), style: t.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(
                  item.pago
                      ? l.painelPago
                      : passou
                          ? l.painelHeroiPassouHa(-item.diasParaPrazo(hoje))
                          : l.painelAteDia(item.dataLimite.day),
                  style: t.bodySmall!.copyWith(color: item.pago || passou ? cor : AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (item.valorEstimado != null)
            Text(moeda(item.valorEstimado!), style: t.titleMedium),
        ],
      ),
    );
  }
}

/// Cartão "Guardar para o IRS": o valor a guardar por mês, grande, e a frase
/// "não é tudo teu" (Artur).
class CartaoIrs extends StatelessWidget {
  final ProvisaoIrs? provisao; // null = ainda não sei quanto ganhas
  final double minimoExistencia;
  const CartaoIrs({super.key, required this.provisao, required this.minimoExistencia});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final p = provisao;
    // O que a voz lê: o mesmo que está escrito no cartão, do título à frase
    // do fim. Quem não lê ouve exactamente a mesma explicação.
    final falado = p == null
        ? '${l.cartaoGuardarIrs}. ${l.painelIrsSemRendimento}'
        : '${l.cartaoGuardarIrs}. ${moeda(p.guardarPorMes)} ${l.painelIrsPorMes}. '
            '${p.guardarPorMes <= 0 ? l.painelIrsZero(moeda(minimoExistencia, casas: 0)) : l.painelIrsLinha}';

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.cartaoGuardarIrs, style: t.titleMedium)),
              if (p != null && !p.escaloesConfirmados)
                Etiqueta(l.painelIrsAproximado, cor: AppColors.surface2, corTexto: AppColors.textSecondary),
              BotaoOuvir(etiqueta: 'painel-irs', texto: falado, soIcone: true),
            ],
          ),
          const SizedBox(height: 4),
          if (p == null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l.painelIrsSemRendimento, style: t.bodyMedium),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(moeda(p.guardarPorMes), style: t.displayMedium!.copyWith(color: AppColors.primaryDark)),
                const SizedBox(width: 8),
                Text(l.painelIrsPorMes, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              p.guardarPorMes <= 0 ? l.painelIrsZero(moeda(minimoExistencia, casas: 0)) : l.painelIrsLinha,
              style: t.bodyMedium!.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Vigia do IVA compacta: barra + "Estás em X de 15.000 €".
/// No painel a barra só é verde ou vermelha (passou o limite); o nível
/// "aviso" vai no texto. O único laranja do ecrã é o semáforo.
class CartaoVigiaIva extends StatelessWidget {
  final VigiaIva vigia;
  const CartaoVigiaIva({super.key, required this.vigia});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final passouLimite = vigia.nivel == NivelIva.alarme || vigia.nivel == NivelIva.critico;
    final cor = passouLimite ? AppColors.passou : AppColors.emDia;
    final texto = switch (vigia.nivel) {
      NivelIva.ok => l.painelVigiaFaltam(moeda(vigia.faltaParaLimite, casas: 0)),
      NivelIva.aviso => l.vigiaIvaAviso,
      NivelIva.alarme => l.vigiaIvaAlarme,
      NivelIva.critico => l.vigiaIvaCritico,
    };

    // A regra do IVA é a que mais assusta quem começa: fica toda na voz.
    final falado = '${l.vigiaIvaTitulo}. '
        '${l.vigiaIvaBarra(moeda(vigia.acumuladoAno, casas: 0), moeda(vigia.limite, casas: 0))}. $texto';

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l.vigiaIvaTitulo, style: t.titleMedium)),
              BotaoOuvir(etiqueta: 'painel-vigia-iva', texto: falado, soIcone: true),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: vigia.fracao,
              minHeight: 12,
              color: cor,
              backgroundColor: AppColors.divider,
            ),
          ),
          const SizedBox(height: 8),
          Text(l.vigiaIvaBarra(moeda(vigia.acumuladoAno, casas: 0), moeda(vigia.limite, casas: 0)), style: t.titleSmall),
          const SizedBox(height: 4),
          Text(texto, style: t.bodySmall),
        ],
      ),
    );
  }
}

/// Esqueleto cinzento enquanto os dados não chegam (nunca spinner a meio).
class SkeletonPainel extends StatelessWidget {
  const SkeletonPainel({super.key});

  Widget _bloco(double altura) => Container(
        width: double.infinity,
        height: altura,
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: AppTheme.cantos),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _bloco(150),
        const SizedBox(height: 12),
        _bloco(210),
        const SizedBox(height: 12),
        _bloco(120),
        const SizedBox(height: 12),
        _bloco(120),
      ],
    );
  }
}
