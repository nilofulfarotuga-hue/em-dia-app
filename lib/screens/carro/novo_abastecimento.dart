import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../widgets/widgets.dart';
import 'widgets_carro.dart';

/// Abre o formulário de abastecimento. Devolve `true` se ficou guardado.
Future<bool?> mostrarNovoAbastecimento(
  BuildContext context, {
  required String userId,
  required String carroId,
  required DateTime hoje,
}) {
  final carros = context.read<CarrosStore>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => ChangeNotifierProvider<CarrosStore>.value(
      value: carros,
      child: NovoAbastecimento(userId: userId, carroId: carroId, hoje: hoje),
    ),
  );
}

/// Data · litros · valor total · km · depósito cheio · posto · com NIF.
class NovoAbastecimento extends StatefulWidget {
  final String userId;
  final String carroId;
  final DateTime hoje;
  const NovoAbastecimento({super.key, required this.userId, required this.carroId, required this.hoje});

  @override
  State<NovoAbastecimento> createState() => _NovoAbastecimentoState();
}

class _NovoAbastecimentoState extends State<NovoAbastecimento> {
  final _litros = TextEditingController();
  final _valor = TextEditingController();
  final _km = TextEditingController();
  final _posto = TextEditingController();
  late DateTime _data = widget.hoje;
  bool _cheio = true;
  bool _nif = false;
  String? _erro;
  bool _aTrabalhar = false;

  @override
  void dispose() {
    for (final c in [_litros, _valor, _km, _posto]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final valor = lerNumero(_valor.text);
    if (valor == null || valor < 0) {
      setState(() => _erro = l.carroFaltaValor);
      return;
    }
    setState(() {
      _erro = null;
      _aTrabalhar = true;
    });
    final litros = lerNumero(_litros.text);
    final posto = _posto.text.trim();
    final ok = await context.read<CarrosStore>().guardarAbastecimento(widget.userId, {
      'carro_id': widget.carroId,
      'data': dataPtIso(_data),
      'litros': (litros == null || litros <= 0) ? null : litros,
      'valor_total': valor,
      'km': int.tryParse(_km.text.trim()),
      'deposito_cheio': _cheio,
      'posto': posto.isEmpty ? null : posto,
      'com_nif': _nif,
    });
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _aTrabalhar = false;
        _erro = l.carroErroGuardar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.carroNovoAbastecimento, style: t.headlineSmall),
          const SizedBox(height: 16),
          CampoData(
            rotulo: l.carroData,
            valor: _data,
            hoje: widget.hoje,
            ultima: widget.hoje,
            aoEscolher: (d) => setState(() => _data = d),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _litros,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.carroLitros, suffixText: 'L'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _valor,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l.carroValorTotal, suffixText: l.euros),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _km,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l.carroKmConta, suffixText: 'km'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _posto,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l.carroPosto),
          ),
          Interruptor(rotulo: l.carroDepositoCheio, valor: _cheio, aoMudar: (v) => setState(() => _cheio = v)),
          Interruptor(rotulo: l.carroComNif, valor: _nif, aoMudar: (v) => setState(() => _nif = v)),
          if (_erro != null) ...[
            const SizedBox(height: 12),
            Aviso(_erro!, tom: Semaforo.vermelho),
          ],
          const SizedBox(height: 20),
          BotaoGrande(texto: l.guardar, icone: Icons.check_rounded, aTrabalhar: _aTrabalhar, aoTocar: _guardar),
        ],
      ),
    );
  }
}
