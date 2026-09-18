import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../stores/perto_store.dart';
import '../../widgets/widgets.dart';

/// «Perto de mim» (B2e): o combustível mais barato num raio de 10 km (DGEG,
/// dados abertos, grátis para toda a gente) e os centros de inspeção mais
/// próximos (lista do IMT). Sem mapa: uma lista do mais barato para o mais
/// caro e um botão que abre o caminho no Google Maps.
///
/// A localização é pedida só quando a pessoa carrega no botão, em primeiro
/// plano, e não fica guardada. Sem ela, escreve-se o concelho.
class PertoScreen extends StatefulWidget {
  const PertoScreen({super.key});

  @override
  State<PertoScreen> createState() => _PertoScreenState();
}

class _PertoScreenState extends State<PertoScreen> {
  final _concelho = TextEditingController();

  @override
  void dispose() {
    _concelho.dispose();
    super.dispose();
  }

  Future<void> _abrirMapa(double lat, double lng, String nome) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).erroRede)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final perto = context.watch<PertoStore>();

    final erro = switch (perto.erro) {
      'sem_permissao' => l.pertoErroPermissao,
      'sem_gps' => l.pertoErroGps,
      'concelho_desconhecido' => l.pertoErroConcelho,
      'rede' => l.erroRede,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.pertoTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(l.pertoExplica, style: t.bodyLarge)),
              BotaoOuvir(etiqueta: 'perto-explica', texto: '${l.pertoExplica} ${l.pertoPrivacidade}', soIcone: true),
            ],
          ),
          const SizedBox(height: 12),
          BotaoGrande(
            texto: perto.origem == OrigemLocal.gps ? l.pertoAtualizarLocal : l.pertoUsarLocal,
            icone: Icons.my_location_rounded,
            aTrabalhar: perto.aCarregar && perto.origem != OrigemLocal.concelho,
            aoTocar: perto.aCarregar ? null : perto.usarLocalizacao,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _concelho,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(labelText: l.pertoConcelho, prefixIcon: const Icon(Icons.place_outlined)),
                  onSubmitted: perto.usarConcelho,
                ),
              ),
              const SizedBox(width: 8),
              // O tema dá aos botões largura infinita (BotaoGrande); numa
              // Row ao lado de um campo isso rebenta — fixa-se a largura.
              SizedBox(
                width: 64,
                height: 56,
                child: FilledButton.tonal(
                  onPressed: perto.aCarregar ? null : () => perto.usarConcelho(_concelho.text),
                  child: Semantics(label: l.pertoProcurar, button: true, child: const Icon(Icons.search_rounded)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(l.pertoPrivacidade, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
          ),
          if (erro != null) ...[
            const SizedBox(height: 12),
            Aviso(erro, tom: Semaforo.amarelo, icone: Icons.info_outline_rounded),
          ],
          if (perto.temLocal) ...[
            const SizedBox(height: 20),
            if (perto.origem == OrigemLocal.concelho && perto.concelho != null)
              Text(l.pertoAPartirDe(perto.concelho!), style: t.bodySmall),
            TituloSeccao(l.pertoCombustivelTitulo),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in perto.combustiveis) ...[
                    ChoiceChip(
                      label: Text(c),
                      selected: perto.combustivel == c,
                      onSelected: (_) => perto.escolherCombustivel(c),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (perto.aCarregar)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
            else if (perto.postos.isEmpty)
              Cartao(child: Text(l.pertoSemPostos, style: t.bodyMedium))
            else
              for (final (i, p) in perto.postos.indexed) ...[
                Cartao(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  aoTocar: () => _abrirMapa(p.lat, p.lng, p.nome),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 84,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${p.preco.toStringAsFixed(3).replaceAll('.', ',')} €',
                                style: t.titleLarge!.copyWith(color: i == 0 ? AppColors.primaryDark : AppColors.textPrimary)),
                            Text(l.pertoPorLitro, style: t.bodySmall),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.nome, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${p.localidade ?? p.municipio ?? ''} · ${p.distanciaKm.toStringAsFixed(1).replaceAll('.', ',')} km',
                                style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      if (i == 0) Etiqueta(l.pertoMaisBarato, cor: AppColors.emDiaClaro, corTexto: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      const Icon(Icons.directions_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            Text(l.pertoFonteDgeg, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            TituloSeccao(l.pertoCentrosTitulo),
            if (perto.aCarregar)
              const SizedBox.shrink()
            else if (perto.centros.isEmpty)
              Cartao(child: Text(l.pertoSemCentros, style: t.bodyMedium))
            else
              for (final c in perto.centros) ...[
                Cartao(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  aoTocar: () => _abrirMapa(c.lat, c.lng, c.nome),
                  child: Row(
                    children: [
                      const Icon(Icons.car_repair_rounded, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.nome, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${c.localidade ?? c.distrito} · ${c.distanciaKm.toStringAsFixed(1).replaceAll('.', ',')} km', style: t.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.directions_rounded, color: AppColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            Text(l.pertoFonteImt, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
