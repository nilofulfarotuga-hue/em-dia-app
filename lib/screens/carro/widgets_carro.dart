/// Peças visuais da Tela 4 (O Carro): formatos de km/litros, tipos de
/// despesa (ícone + rótulo), linha do tempo (Drivvo) e o campo de data.
/// Só apresentação — as contas vêm de `lib/regras` e das stores.
library;

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../widgets/widgets.dart';

/// "84 120" — milhares separados por espaço fino (como nos conta-quilómetros).
String kmTxt(int km) {
  final s = km.abs().toString();
  final sb = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final resto = s.length - i;
    sb.write(s[i]);
    if (resto > 1 && resto % 3 == 1) sb.write(' ');
  }
  return '${km < 0 ? '-' : ''}$sb';
}

/// "38,5" — uma casa decimal, vírgula.
String litrosTxt(double l) => l.toStringAsFixed(1).replaceAll('.', ',');

/// Tipos de despesa (a ordem é a das chips do formulário). Mesmos valores da
/// tabela `despesas_carro.tipo`.
const List<String> tiposDespesa = [
  'portagem', 'multa', 'estacionamento', 'reparacao', 'revisao', 'pneus',
  'lavagem', 'seguro', 'iuc', 'ipo', 'outro',
];

const Set<String> tiposComPrazo = {'portagem', 'multa'};

String rotuloDespesa(AppLocalizations l, String tipo) => switch (tipo) {
      'iuc' => l.carroTipoIuc,
      'ipo' => l.carroTipoIpo,
      'seguro' => l.carroTipoSeguro,
      'revisao' => l.carroTipoRevisao,
      'pneus' => l.carroTipoPneus,
      'reparacao' => l.carroTipoReparacao,
      'portagem' => l.carroTipoPortagem,
      'multa' => l.carroTipoMulta,
      'estacionamento' => l.carroTipoEstacionamento,
      'lavagem' => l.carroTipoLavagem,
      _ => l.carroTipoOutro,
    };

IconData iconeDespesa(String tipo) => switch (tipo) {
      'iuc' => Icons.directions_car_rounded,
      'ipo' => Icons.car_repair_rounded,
      'seguro' => Icons.shield_rounded,
      'revisao' => Icons.build_rounded,
      'pneus' => Icons.tire_repair_rounded,
      'reparacao' => Icons.handyman_rounded,
      'portagem' => Icons.toll_rounded,
      'multa' => Icons.gavel_rounded,
      'estacionamento' => Icons.local_parking_rounded,
      'lavagem' => Icons.local_car_wash_rounded,
      _ => Icons.receipt_rounded,
    };

/// Um item da linha do tempo (Drivvo): círculo com ícone sobre a linha
/// vertical, título, subtítulo, valor à direita e data por baixo.
class ItemLinhaTempo extends StatelessWidget {
  final IconData icone;
  final Color corFundo;
  final Color corIcone;
  final String titulo;
  final String? subtitulo;
  final String valor;
  final String data;
  final Widget? etiqueta;
  final bool ultimo;
  const ItemLinhaTempo({
    super.key,
    required this.icone,
    required this.titulo,
    this.subtitulo,
    required this.valor,
    required this.data,
    this.corFundo = AppColors.surface2,
    this.corIcone = AppColors.textPrimary,
    this.etiqueta,
    this.ultimo = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: 0,
                  bottom: ultimo ? null : 0,
                  height: ultimo ? 20 : null,
                  child: Container(width: 2, color: AppColors.divider),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: corFundo, shape: BoxShape.circle),
                  child: Icon(icone, size: 20, color: corIcone),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultimo ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(titulo, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (subtitulo != null && subtitulo!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(subtitulo!, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(valor, style: t.titleMedium),
                          const SizedBox(height: 2),
                          Text(data, style: t.bodySmall!.copyWith(color: AppColors.textSubtle)),
                        ],
                      ),
                    ],
                  ),
                  if (etiqueta != null) ...[const SizedBox(height: 6), etiqueta!],
                  if (!ultimo) ...[const SizedBox(height: 12), const Divider()],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta pequena "NIF" (a fatura tem NIF — conta para o IRS).
class EtiquetaNif extends StatelessWidget {
  const EtiquetaNif({super.key});
  @override
  Widget build(BuildContext context) => Etiqueta(
        AppLocalizations.of(context).carroNif,
        cor: AppColors.emDiaClaro,
        corTexto: AppColors.primaryDeep,
        icone: Icons.receipt_long_rounded,
      );
}

/// Um número com rótulo por baixo (para o resumo do mês).
class Estatistica extends StatelessWidget {
  final String valor;
  final String rotulo;
  const Estatistica({super.key, required this.valor, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(valor, style: t.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
        Text(rotulo, style: t.labelSmall),
      ],
    );
  }
}

/// Campo de data em cartão (mesmo padrão do calendário): toca → seletor.
class CampoData extends StatelessWidget {
  final String rotulo;
  final DateTime? valor;
  final DateTime hoje;
  final ValueChanged<DateTime> aoEscolher;
  final DateTime? primeira;
  final DateTime? ultima;
  const CampoData({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.hoje,
    required this.aoEscolher,
    this.primeira,
    this.ultima,
  });

  Future<void> _escolher(BuildContext context) async {
    final d = await showDatePicker(
      context: context,
      initialDate: valor ?? hoje,
      firstDate: primeira ?? DateTime(hoje.year - 30),
      lastDate: ultima ?? DateTime(hoje.year + 20, 12, 31),
    );
    if (d != null) aoEscolher(soDia(d));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Cartao(
      aoTocar: () => _escolher(context),
      bordo: valor == null ? AppColors.divider : AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, color: AppColors.primaryDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rotulo, style: t.bodySmall),
                const SizedBox(height: 2),
                Text(valor == null ? AppLocalizations.of(context).carroEscolherData : dataExtensoPt(valor!),
                    style: t.titleMedium),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
        ],
      ),
    );
  }
}

/// Interruptor em linha (sem o padding do ListTile).
class Interruptor extends StatelessWidget {
  final String rotulo;
  final bool valor;
  final ValueChanged<bool> aoMudar;
  const Interruptor({super.key, required this.rotulo, required this.valor, required this.aoMudar});

  @override
  Widget build(BuildContext context) => SwitchListTile(
        value: valor,
        onChanged: aoMudar,
        contentPadding: EdgeInsets.zero,
        title: Text(rotulo, style: Theme.of(context).textTheme.titleSmall),
      );
}

/// Título de secção com o "+" à direita (o FAB do Drivvo, por secção).
class TituloComMais extends StatelessWidget {
  final String texto;
  final String rotuloMais;
  final VoidCallback? aoAdicionar;
  const TituloComMais(this.texto, {super.key, required this.rotuloMais, this.aoAdicionar});

  @override
  Widget build(BuildContext context) => TituloSeccao(
        texto,
        acao: aoAdicionar == null
            ? null
            : TextButton.icon(
                onPressed: aoAdicionar,
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8), visualDensity: VisualDensity.compact),
                icon: const Icon(Icons.add_circle_rounded, size: 22),
                label: Text(rotuloMais, style: const TextStyle(fontFamily: AppTheme.fonte, fontSize: 14)),
              ),
      );
}
