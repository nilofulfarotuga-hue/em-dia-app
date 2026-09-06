import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';

/// Abre o formulário de obrigação manual. Devolve `true` se ficou guardada.
Future<bool?> mostrarNovaObrigacao(BuildContext context, {required String userId, required DateTime hoje}) {
  final obrig = context.read<ObrigacoesStore>();
  final regras = context.read<RegrasStore>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider<ObrigacoesStore>.value(value: obrig),
        ChangeNotifierProvider<RegrasStore>.value(value: regras),
      ],
      child: NovaObrigacao(userId: userId, hoje: hoje),
    ),
  );
}

/// Multa · Portagem · Outra coisa — descrição, data e valor (opcional).
class NovaObrigacao extends StatefulWidget {
  final String userId;
  final DateTime hoje;
  const NovaObrigacao({super.key, required this.userId, required this.hoje});

  @override
  State<NovaObrigacao> createState() => _NovaObrigacaoState();
}

class _NovaObrigacaoState extends State<NovaObrigacao> {
  String _tipo = 'multa';
  final _descricao = TextEditingController();
  final _valor = TextEditingController();
  DateTime? _data;
  String? _erro;
  bool _aTrabalhar = false;

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _data ?? widget.hoje,
      firstDate: DateTime(widget.hoje.year - 1),
      lastDate: DateTime(widget.hoje.year + 2, 12, 31),
    );
    if (d != null && mounted) setState(() => _data = soDia(d));
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final desc = _descricao.text.trim();
    if (desc.isEmpty) {
      setState(() => _erro = l.calNovaFaltaDescricao);
      return;
    }
    final data = _data;
    if (data == null) {
      setState(() => _erro = l.calNovaFaltaData);
      return;
    }
    setState(() {
      _erro = null;
      _aTrabalhar = true;
    });
    final store = context.read<ObrigacoesStore>();
    final feriados = context.read<RegrasStore>().regras.feriados;
    final ok = await store.adicionarManual(
      userId: widget.userId,
      tipo: _tipo,
      descricao: desc,
      data: data,
      valor: lerNumero(_valor.text),
      feriados: feriados,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _aTrabalhar = false;
        _erro = l.calErroGuardar;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final tipos = [('multa', l.calTipoMulta), ('portagem', l.calTipoPortagem), ('outro', l.calTipoOutro)];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.calNovaTitulo, style: t.headlineSmall),
          const SizedBox(height: 16),
          Text(l.calNovaTipo, style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (chave, rotulo) in tipos)
                ChoiceChip(
                  label: Text(rotulo),
                  selected: _tipo == chave,
                  showCheckmark: false,
                  labelStyle: TextStyle(color: _tipo == chave ? AppColors.primaryDark : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _tipo = chave),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descricao,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.calNovaDescricao, hintText: l.calNovaDescricaoDica),
          ),
          const SizedBox(height: 12),
          Text(l.calNovaData, style: t.titleSmall),
          const SizedBox(height: 8),
          Cartao(
            aoTocar: _escolherData,
            bordo: _data == null ? AppColors.divider : AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.event_rounded, color: AppColors.primaryDark),
                const SizedBox(width: 12),
                Expanded(child: Text(_data == null ? l.calNovaEscolherData : dataExtensoPt(_data!), style: t.titleMedium)),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.calNovaValor, suffixText: l.euros),
          ),
          if (_erro != null) ...[
            const SizedBox(height: 12),
            Aviso(_erro!, tom: Semaforo.vermelho),
          ],
          const SizedBox(height: 20),
          BotaoGrande(texto: l.calAdicionar, icone: Icons.add_rounded, aTrabalhar: _aTrabalhar, aoTocar: _guardar),
        ],
      ),
    );
  }
}
