import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/cofre_movimento.dart';
import '../../regras/regras.dart';
import '../../stores/cofre_store.dart';
import '../../widgets/widgets.dart';

/// Abre a folha de anotação do cofre. Devolve `true` se ficou apontado.
///
/// [poe] só escolhe a razão que já vem marcada: `true` quando se chega aqui
/// pelo botão "Pus de lado", `false` pelo "Tirei de lá". A folha mostra sempre
/// as quatro razões — quem carregou no botão errado corrige com um toque, sem
/// fechar nada.
///
/// A store volta a ser dada à folha de propósito: assim a folha pode ser
/// aberta sozinha num teste, sem montar a app inteira à volta dela.
Future<bool?> mostrarNovoMovimento(
  BuildContext context, {
  required String userId,
  required DateTime hoje,
  required bool poe,
}) {
  final cofre = context.read<CofreStore>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => ChangeNotifierProvider<CofreStore>.value(
      value: cofre,
      child: NovoMovimento(userId: userId, hoje: hoje, poe: poe),
    ),
  );
}

/// A folha, pela ordem por que a pessoa pensa: **quanto** → porquê → apontar.
///
/// O valor vem primeiro porque é o único campo obrigatório. A câmara não
/// aparece (`aoLerDocumento` a nulo): aqui não se fotografa documento nenhum —
/// isto é o que a pessoa separou, não uma fatura que alguém lhe passou.
class NovoMovimento extends StatefulWidget {
  final String userId;
  final DateTime hoje;
  final bool poe;
  const NovoMovimento({
    super.key,
    required this.userId,
    required this.hoje,
    required this.poe,
  });

  @override
  State<NovoMovimento> createState() => _NovoMovimentoState();
}

class _NovoMovimentoState extends State<NovoMovimento> {
  final _valor = TextEditingController();
  late RazaoCofre _razao;
  String? _erro;
  bool _aGuardar = false;

  @override
  void initState() {
    super.initState();
    // O botão por onde se entrou marca a primeira razão do lado certo: quem
    // carregou em "Pus de lado" fica com "guardei", quem carregou em "Tirei de
    // lá" fica com o pagamento à Segurança Social, que é a razão mais comum
    // para se tirar dinheiro de um cofre de impostos.
    _razao = widget.poe ? razoesQuePoem().first : razoesQueTiram().first;
  }

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final quantia = valorEscrito(_valor.text);
    if (quantia == null || quantia <= 0) {
      setState(() => _erro = l.cofreFaltaValor);
      return;
    }
    setState(() {
      _erro = null;
      _aGuardar = true;
    });
    final ok = await context.read<CofreStore>().apontar(
          CofreMovimento.doQueAPessoaEscreveu(
            userId: widget.userId,
            data: widget.hoje,
            quantia: quantia,
            razao: _razao,
          ),
        );
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _aGuardar = false;
        _erro = l.cofreErroGuardar;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final quantia = valorEscrito(_valor.text) ?? 0;

    // O aviso de estar a tirar mais do que se apontou. Não trava nada — o
    // caderno pode ficar negativo se a pessoa começou a apontar a meio — mas
    // apanha o zero a mais que se escreve sem dar por isso.
    final saldo = context.watch<CofreStore>().saldo;
    final tiraDemais = !_razao.poe && quantia > 0 && quantia > saldo;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // O título segue a razão escolhida, não o botão por onde se entrou:
          // assim nunca diz "Pus de lado" por cima de um "Paguei o IRS".
          Text(_razao.poe ? l.cofreFolhaPor : l.cofreFolhaTirar, style: t.headlineSmall),
          const SizedBox(height: 16),

          // 1. Quanto foi. Sem câmara: `aoLerDocumento` fica a nulo.
          CampoValor(
            key: const Key('novo_movimento_valor'),
            controlador: _valor,
            rotulo: l.cofreQuanto,
            autofocus: true,
            aoMudar: (_) => setState(() {
              if (_erro != null) _erro = null;
            }),
          ),

          // 2. Porquê. É a razão que decide o sinal — não há interruptor de
          // "mais ou menos" nenhum para alguém enganar.
          const SizedBox(height: 20),
          Text(l.cofrePorque, style: t.titleMedium),
          const SizedBox(height: 10),
          for (final r in razoesCofre) ...[
            BotaoEscolha(
              key: Key('razao_${r.chave}'),
              texto: rotuloRazaoCofre(l, r.chave),
              ajuda: ajudaRazaoCofre(l, r.chave),
              icone: iconeRazaoCofre(r.chave),
              selecionado: _razao.chave == r.chave,
              aoTocar: () => setState(() => _razao = r),
            ),
            const SizedBox(height: 8),
          ],

          // 3. O que vai ficar escrito, em palavras. Antes de guardar, a
          // pessoa lê a frase inteira e vê se é mesmo aquilo.
          if (quantia > 0) ...[
            const SizedBox(height: 8),
            Text(
              _razao.poe
                  ? l.cofreVaiApontarPor(moeda(centimos(quantia)))
                  : l.cofreVaiApontarTirar(moeda(centimos(quantia))),
              style: t.titleMedium!.copyWith(color: AppColors.primaryDeep),
            ),
          ],
          if (tiraDemais) ...[
            const SizedBox(height: 8),
            Text(l.cofreTirasMaisDoQueTens,
                style: t.bodySmall!.copyWith(color: AppColors.info)),
          ],

          if (_erro != null) ...[
            const SizedBox(height: 12),
            Aviso(_erro!, tom: Semaforo.vermelho),
          ],

          // 4. Apontar.
          const SizedBox(height: 20),
          BotaoGrande(
            key: const Key('novo_movimento_guardar'),
            texto: l.guardar,
            icone: Icons.check_rounded,
            aTrabalhar: _aGuardar,
            aoTocar: _guardar,
          ),
        ],
      ),
    );
  }
}

// ---- as palavras de uma razão (usadas pela folha e pela lista do ecrã) ----

String rotuloRazaoCofre(AppLocalizations l, String chave) => switch (chave) {
      'guardei' => l.cofreMotivoGuardei,
      'paguei_ss' => l.cofreMotivoPagueiSs,
      'paguei_irs' => l.cofreMotivoPagueiIrs,
      'precisei' => l.cofreMotivoPrecisei,
      _ => l.cofreMotivoAcerto,
    };

String ajudaRazaoCofre(AppLocalizations l, String chave) => switch (chave) {
      'guardei' => l.cofreMotivoGuardeiAjuda,
      'paguei_ss' => l.cofreMotivoPagueiSsAjuda,
      'paguei_irs' => l.cofreMotivoPagueiIrsAjuda,
      _ => l.cofreMotivoPreciseiAjuda,
    };

IconData iconeRazaoCofre(String chave) => switch (chave) {
      'guardei' => Icons.savings_rounded,
      'paguei_ss' => Icons.shield_rounded,
      'paguei_irs' => Icons.receipt_long_rounded,
      'precisei' => Icons.north_east_rounded,
      _ => Icons.tune_rounded,
    };

/// O nome de uma linha da lista. Um movimento que não veio da app (um `acerto`
/// escrito do lado do servidor) não tem razão nossa — e mesmo assim tem de
/// aparecer com nome, senão a lista mostrava uma linha muda.
String rotuloMovimentoCofre(AppLocalizations l, CofreMovimento m) =>
    rotuloRazaoCofre(l, m.razao?.chave ?? 'acerto');

IconData iconeMovimentoCofre(CofreMovimento m) =>
    iconeRazaoCofre(m.razao?.chave ?? 'acerto');
