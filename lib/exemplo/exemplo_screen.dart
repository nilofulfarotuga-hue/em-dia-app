import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../screens/shell/shell_screen.dart';
import '../stores/banco_store.dart';
import '../stores/caixa_store.dart';
import '../stores/cofre_store.dart';
import '../stores/dados_store.dart';
import '../stores/entradas_store.dart';
import '../stores/perfil_store.dart';
import '../stores/perto_store.dart';
import '../stores/radar_store.dart';
import '../stores/regras_store.dart';
import '../stores/resumo_store.dart';
import '../stores/saidas_store.dart';
import '../stores/sessao_store.dart';
import 'dados_exemplo.dart';
import 'stores_exemplo.dart';

/// «Vê como fica» (B2f): a app inteira, cheia, com a Maria de exemplo.
///
/// É a mesma [ShellScreen] de sempre, embrulhada em stores de exemplo, com
/// uma faixa fixa em cima a dizer que é um exemplo e um botão para sair.
/// Precisa de um [RegrasStore] e de uma `Fala` acima (a app já os dá).
///
/// Os ecrãs de dentro abrem outros ecrãs com `Navigator.of(context).push`;
/// para esses continuarem a ver as stores de exemplo, há aqui um navegador
/// próprio por baixo dos providers. O botão de recuar do telemóvel fecha
/// primeiro os ecrãs de dentro; só depois sai do exemplo.
class ExemploScreen extends StatefulWidget {
  /// Só para testes e fotos: fixar o «hoje» do exemplo.
  final DateTime? hoje;
  const ExemploScreen({super.key, this.hoje});

  @override
  State<ExemploScreen> createState() => _ExemploScreenState();
}

class _ExemploScreenState extends State<ExemploScreen> {
  final _navegador = GlobalKey<NavigatorState>();
  final _mensageiro = GlobalKey<ScaffoldMessengerState>();
  late final DadosExemplo _dados;
  DateTime? _ultimoAviso;

  @override
  void initState() {
    super.initState();
    _dados = DadosExemplo.montar(hoje: widget.hoje, regras: context.read<RegrasStore>().regras);
  }

  /// Alguém carregou em «guardar» dentro do exemplo: diz-se uma vez, sem
  /// martelar — dois toques seguidos dão um só aviso.
  void _avisar() {
    final agora = DateTime.now();
    if (_ultimoAviso != null && agora.difference(_ultimoAviso!) < const Duration(seconds: 3)) return;
    _ultimoAviso = agora;
    final l = AppLocalizations.of(context);
    _mensageiro.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l.exemploNaoGrava)));
  }

  void _sair() => Navigator.of(context, rootNavigator: true).pop();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = _dados;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessaoStore>(create: (_) => SessaoExemplo()),
        ChangeNotifierProvider<PlanoStore>(create: (_) => PlanoExemplo()),
        ChangeNotifierProvider<PerfilStore>(create: (_) => PerfilExemplo(d.perfil, _avisar)),
        ChangeNotifierProvider<ObrigacoesStore>(create: (_) => ObrigacoesExemplo(d.obrigacoes, _avisar)),
        ChangeNotifierProvider<RendimentosStore>(create: (_) => RendimentosExemplo(d.rendimentos, _avisar)),
        ChangeNotifierProvider<CarrosStore>(create: (_) => CarrosExemplo([d.carro], d.abastecimentos, d.despesasCarro, _avisar)),
        ChangeNotifierProvider<EntradasStore>(create: (_) => EntradasExemplo(d.entradas, _avisar)),
        ChangeNotifierProvider<SaidasStore>(create: (_) => SaidasExemplo(d.saidas, d.pagamentos, _avisar)),
        ChangeNotifierProvider<ResumoStore>(create: (_) => ResumoExemplo(d.resumoMes, d.resumoAno)),
        ChangeNotifierProvider<CofreStore>(create: (_) => CofreExemplo(d.cofre, d.resumoAno.entrouParaIrs, _avisar)),
        ChangeNotifierProvider<RadarStore>(create: (_) => RadarExemplo(d.fidelizacoes)),
        ChangeNotifierProvider<CaixaStore>(create: (_) => CaixaExemplo(_avisar)),
        ChangeNotifierProvider<BancoStore>(create: (_) => BancoExemplo(d.movimentosBanco, d.operadores, _avisar)),
        ChangeNotifierProvider<PertoStore>(create: (_) => PertoExemplo(d.postos, d.centros)),
      ],
      child: ScaffoldMessenger(
        key: _mensageiro,
        child: Scaffold(
          body: Column(
            children: [
              // A faixa: laranja é a cor de «atenção» da casa, e aqui é a
              // única coisa laranja do ecrã.
              Material(
                color: AppColors.aVencer,
                child: SafeArea(
                  bottom: false,
                  child: Semantics(
                    container: true,
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l.exemploFaixa,
                              style: t.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: _sair,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              minimumSize: const Size(48, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Text(l.exemploSair),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NavigatorPopHandler(
                  onPopWithResult: (_) => _navegador.currentState?.maybePop(),
                  child: Navigator(
                    key: _navegador,
                    onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => const ShellScreen()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O botão «Vê como fica» que abre o exemplo por cima do ecrã atual.
class BotaoVerComoFica extends StatelessWidget {
  final bool discreto;
  const BotaoVerComoFica({super.key, this.discreto = false});

  static Future<void> abrir(BuildContext context) => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => const ExemploScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (discreto) {
      return TextButton.icon(
        onPressed: () => abrir(context),
        icon: const Icon(Icons.visibility_rounded),
        label: Text(l.exemploVerComoFica),
      );
    }
    return OutlinedButton.icon(
      onPressed: () => abrir(context),
      icon: const Icon(Icons.visibility_rounded),
      label: Text(l.exemploVerComoFica),
    );
  }
}
