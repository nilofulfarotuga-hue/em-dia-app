import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/carro.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import 'widgets_carro.dart';

/// Abre o formulário de despesa. Devolve `true` se ficou guardada.
/// Portagem/multa: a data da notificação dá o prazo (15 dias úteis, regra
/// `multa_pagamento_voluntario_dias_uteis`) e entra também no calendário
/// como obrigação manual, com aviso na véspera útil.
Future<bool?> mostrarNovaDespesa(
  BuildContext context, {
  required String userId,
  required Carro carro,
  required DateTime hoje,
}) {
  final carros = context.read<CarrosStore>();
  final obrig = context.read<ObrigacoesStore>();
  final regras = context.read<RegrasStore>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider<CarrosStore>.value(value: carros),
        ChangeNotifierProvider<ObrigacoesStore>.value(value: obrig),
        ChangeNotifierProvider<RegrasStore>.value(value: regras),
      ],
      child: NovaDespesa(userId: userId, carro: carro, hoje: hoje),
    ),
  );
}

class NovaDespesa extends StatefulWidget {
  final String userId;
  final Carro carro;
  final DateTime hoje;
  const NovaDespesa({super.key, required this.userId, required this.carro, required this.hoje});

  @override
  State<NovaDespesa> createState() => _NovaDespesaState();
}

class _NovaDespesaState extends State<NovaDespesa> {
  String _tipo = 'outro';
  final _valor = TextEditingController();
  final _nota = TextEditingController();
  late DateTime _data = widget.hoje;
  late DateTime _notificacao = widget.hoje;
  bool _nif = true;
  String? _erro;
  bool _aTrabalhar = false;

  bool get _temPrazo => tiposComPrazo.contains(_tipo);

  @override
  void dispose() {
    _valor.dispose();
    _nota.dispose();
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
    final r = context.read<RegrasStore>().regras;
    final limite = _temPrazo ? prazoMulta(_notificacao, r) : null;
    final nota = _nota.text.trim();
    final store = context.read<CarrosStore>();
    final ok = await store.guardarDespesa(widget.userId, {
      'carro_id': widget.carro.id,
      'data': dataPtIso(_data),
      'tipo': _tipo,
      'valor': valor,
      'descricao': nota.isEmpty ? null : nota,
      'com_nif': _nif,
      'data_limite': limite == null ? null : dataPtIso(limite),
      'pago': !_temPrazo,
    });
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _aTrabalhar = false;
        _erro = l.carroErroGuardar;
      });
      return;
    }
    if (limite != null) {
      // Entra no calendário para avisar na véspera útil do prazo.
      final descricao = nota.isEmpty ? '${rotuloDespesa(l, _tipo)} · ${widget.carro.matricula}' : nota;
      await context.read<ObrigacoesStore>().adicionarManual(
            userId: widget.userId,
            tipo: _tipo,
            descricao: descricao,
            data: limite,
            valor: valor,
            feriados: r.feriados,
          );
      if (!mounted) return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = context.read<RegrasStore>().regras;
    final diasUteis = r.n('multa_pagamento_voluntario_dias_uteis').toInt();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.carroNovaDespesa, style: t.headlineSmall),
          const SizedBox(height: 16),
          Text(l.carroTipoDespesa, style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tipo in tiposDespesa)
                ChoiceChip(
                  label: Text(rotuloDespesa(l, tipo)),
                  avatar: Icon(iconeDespesa(tipo), size: 18, color: _tipo == tipo ? AppColors.primaryDark : AppColors.textSecondary),
                  selected: _tipo == tipo,
                  showCheckmark: false,
                  labelStyle: TextStyle(color: _tipo == tipo ? AppColors.primaryDark : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _tipo = tipo),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.carroValor, suffixText: l.euros),
          ),
          const SizedBox(height: 12),
          CampoData(
            rotulo: l.carroData,
            valor: _data,
            hoje: widget.hoje,
            ultima: widget.hoje,
            aoEscolher: (d) => setState(() => _data = d),
          ),
          if (_temPrazo) ...[
            const SizedBox(height: 12),
            CampoData(
              rotulo: l.carroDataNotificacao,
              valor: _notificacao,
              hoje: widget.hoje,
              ultima: widget.hoje,
              aoEscolher: (d) => setState(() => _notificacao = d),
            ),
            const SizedBox(height: 10),
            Aviso(
              '${l.carroPrazoMulta(dataPt(prazoMulta(_notificacao, r)), diasUteis)} ${l.carroMultaNoCalendario}',
              tom: Semaforo.verde,
              icone: Icons.event_available_rounded,
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _nota,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.carroNota, hintText: l.carroNotaDica),
          ),
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
