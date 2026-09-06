import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../stores/sessao_store.dart';
import 'entradas_screen.dart';
import 'nova_entrada.dart';
import 'resumo_screen.dart';
import 'saidas_screen.dart';

/// Tela "A minha vida": **Entra, Sai, Sobra**.
///
/// São três abas e não três ecrãs porque é a mesma pergunta feita em três
/// pedaços: *o que ganhei*, *o que tenho de pagar* e *o que fica no fim*. Quem
/// escreve o que ganhou está a um toque de escrever o que tem para pagar, e a
/// dois de ver como acaba o mês.
///
/// A ordem das abas é a ordem do dinheiro, não a ordem alfabética.
class VidaScreen extends StatelessWidget {
  /// Só para fotos/testes: fixa o "hoje". Na app é sempre a data de Lisboa.
  final DateTime? hoje;
  const VidaScreen({super.key, this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l.vidaTitulo),
            bottom: TabBar(
              tabs: [
                Tab(key: const Key('aba_entra'), text: l.vidaAbaEntra),
                Tab(key: const Key('aba_sai'), text: l.vidaAbaSai),
                Tab(key: const Key('aba_sobra'), text: l.vidaAbaSobra),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              EntradasScreen(hoje: hoje),
              SaidasScreen(hoje: hoje),
              ResumoScreen(
                hoje: hoje,
                // O convite do ecrã vazio ("escreve a primeira coisa") abre a
                // mesma folha da aba Entra. Sem isto era um botão que não
                // fazia nada — pior do que não ter botão nenhum.
                aoEscreverPrimeira: () => _escreverPrimeira(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _escreverPrimeira(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final userId = context.read<SessaoStore>().userId;
    final mensageiro = ScaffoldMessenger.of(context);
    if (userId == null) {
      mensageiro.showSnackBar(SnackBar(content: Text(l.vidaSemSessao)));
      return;
    }
    final ok = await mostrarNovaEntrada(
      context,
      userId: userId,
      hoje: hoje ?? hojeLisboa(),
    );
    if (ok == true) {
      mensageiro.showSnackBar(SnackBar(content: Text(l.vidaGuardado)));
      if (context.mounted) DefaultTabController.of(context).animateTo(0);
    }
  }
}
