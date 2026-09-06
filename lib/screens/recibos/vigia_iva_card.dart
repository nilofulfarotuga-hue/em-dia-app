import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../widgets/widgets.dart';
import 'recibos_widgets.dart';

/// Vigia do IVA: "estás em X € de 15.000 €" (MEI Fácil: barra do limite).
/// A barra é o ÚNICO laranja possível deste ecrã (nível aviso).
class VigiaIvaCard extends StatelessWidget {
  final RegrasLegais regras;
  final double acumuladoAno;
  final bool temDados;
  const VigiaIvaCard({super.key, required this.regras, required this.acumuladoAno, required this.temDados});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final v = vigiaIva(acumuladoAno: acumuladoAno, r: regras);
    final cor = switch (v.nivel) {
      NivelIva.ok => AppColors.emDia,
      NivelIva.aviso => AppColors.aVencer,
      NivelIva.alarme || NivelIva.critico => AppColors.passou,
    };
    final texto = switch (v.nivel) {
      NivelIva.ok => l.vigiaIvaOk,
      NivelIva.aviso => l.vigiaIvaAviso,
      NivelIva.alarme => l.vigiaIvaAlarme,
      NivelIva.critico => l.vigiaIvaCritico,
    };

    // A voz diz o mesmo que o cartão: onde estás, e o que acontece se passares.
    final falado = [
      l.vigiaIvaTitulo,
      l.vigiaIvaBarra(moeda(v.acumuladoAno, casas: 0), moeda(v.limite, casas: 0)),
      if (v.nivel == NivelIva.ok && !temDados) l.vigiaIvaSemDados else texto,
      if (v.nivel == NivelIva.ok && temDados) l.vigiaIvaFalta(moeda(v.faltaParaLimite, casas: 0)),
    ].join('. ');

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoCartao(
            icone: Icons.visibility_rounded,
            titulo: l.vigiaIvaTitulo,
            direita: BotaoOuvir(etiqueta: 'recibos-vigia-iva', texto: falado, soIcone: true),
          ),
          const SizedBox(height: 12),
          Text(
            l.vigiaIvaBarra(moeda(v.acumuladoAno, casas: 0), moeda(v.limite, casas: 0)),
            style: t.titleMedium,
          ),
          const SizedBox(height: 10),
          BarraProgresso(fracao: v.fracao, cor: cor),
          const SizedBox(height: 12),
          if (v.nivel == NivelIva.ok) ...[
            Text(temDados ? texto : l.vigiaIvaSemDados, style: t.bodyMedium),
            if (temDados) ...[
              const SizedBox(height: 4),
              Text(l.vigiaIvaFalta(moeda(v.faltaParaLimite, casas: 0)), style: t.bodySmall),
            ],
          ] else if (v.nivel == NivelIva.aviso)
            Text(texto, style: t.bodyMedium)
          else
            Aviso(texto, tom: Semaforo.vermelho),
        ],
      ),
    );
  }
}
