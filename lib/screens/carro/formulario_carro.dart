import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/carro.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import 'widgets_carro.dart';

/// Abre o formulário "Adicionar carro". Devolve o carro guardado (ou null).
/// Depois de guardar pede ao servidor para refazer o calendário
/// (`ObrigacoesStore.recalcular`) — o IUC, a inspeção e o seguro entram lá.
Future<Carro?> mostrarFormularioCarro(BuildContext context, {required String userId, required DateTime hoje}) {
  final carros = context.read<CarrosStore>();
  final obrig = context.read<ObrigacoesStore>();
  final regras = context.read<RegrasStore>();
  return showModalBottomSheet<Carro>(
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
      child: FormularioCarro(userId: userId, hoje: hoje),
    ),
  );
}

class FormularioCarro extends StatefulWidget {
  final String userId;
  final DateTime hoje;
  const FormularioCarro({super.key, required this.userId, required this.hoje});

  @override
  State<FormularioCarro> createState() => _FormularioCarroState();
}

class _FormularioCarroState extends State<FormularioCarro> {
  final _nome = TextEditingController();
  final _matricula = TextEditingController();
  final _ano = TextEditingController();
  final _cilindrada = TextEditingController();
  final _co2 = TextEditingController();
  final _seguradora = TextEditingController();
  int? _mes;
  Combustivel _combustivel = Combustivel.gasolina;
  DateTime? _seguroRenova;
  DateTime? _ultimaIpo;
  String _categoria = 'proprio';
  bool _tvde = false;
  DateTime? _carta;
  String? _erro;
  bool _aTrabalhar = false;

  @override
  void dispose() {
    for (final c in [_nome, _matricula, _ano, _cilindrada, _co2, _seguradora]) {
      c.dispose();
    }
    super.dispose();
  }

  String _rotuloComb(AppLocalizations l, Combustivel c) => switch (c) {
        Combustivel.gasolina => l.carroCombGasolina,
        Combustivel.gasoleo => l.carroCombGasoleo,
        Combustivel.eletrico => l.carroCombEletrico,
        Combustivel.hibrido => l.carroCombHibrido,
        Combustivel.gpl => l.carroCombGpl,
        Combustivel.outro => l.carroCombOutro,
      };

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final matricula = _matricula.text.trim().toUpperCase();
    if (matricula.isEmpty) {
      setState(() => _erro = l.carroFaltaMatricula);
      return;
    }
    if (_mes == null) {
      setState(() => _erro = l.carroFaltaMesMatricula);
      return;
    }
    final ano = int.tryParse(_ano.text.trim());
    if (ano == null || ano < 1950 || ano > widget.hoje.year + 1) {
      setState(() => _erro = l.carroFaltaAnoMatricula);
      return;
    }
    setState(() {
      _erro = null;
      _aTrabalhar = true;
    });
    final nome = _nome.text.trim();
    final seguradora = _seguradora.text.trim();
    final carro = Carro(
      id: '',
      userId: widget.userId,
      nome: nome.isEmpty ? null : nome,
      matricula: matricula,
      mesMatricula: _mes,
      anoMatricula: ano,
      categoria: _categoria,
      usoTvde: _tvde,
      combustivel: _combustivel,
      cilindradaCc: int.tryParse(_cilindrada.text.trim()),
      co2: int.tryParse(_co2.text.trim()),
      seguradora: seguradora.isEmpty ? null : seguradora,
      seguroRenovaEm: _seguroRenova,
      ultimaIpo: _ultimaIpo,
      cartaValidade: _carta,
    );
    final store = context.read<CarrosStore>();
    final obrig = context.read<ObrigacoesStore>();
    final guardado = await store.guardarCarro(carro);
    if (!mounted) return;
    if (guardado == null) {
      setState(() {
        _aTrabalhar = false;
        _erro = l.carroErroGuardar;
      });
      return;
    }
    // O calendário (IUC, inspeção, seguro, carta) é gerado pelo servidor.
    await obrig.recalcular(widget.userId);
    if (!mounted) return;
    Navigator.of(context).pop(guardado);
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
          Text(l.carroNovoTitulo, style: t.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _nome,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.carroNome),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _matricula,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(labelText: l.carroMatricula, hintText: l.carroMatriculaDica),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<int>(
                  initialValue: _mes,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l.carroMesMatricula),
                  items: [
                    for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(nomeMes(m))),
                  ],
                  onChanged: (v) => setState(() => _mes = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _ano,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: InputDecoration(labelText: l.carroAnoMatricula),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l.carroMatriculaAjuda, style: t.bodySmall),
          const SizedBox(height: 16),
          Text(l.carroCombustivel, style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in Combustivel.values)
                ChoiceChip(
                  label: Text(_rotuloComb(l, c)),
                  selected: _combustivel == c,
                  showCheckmark: false,
                  labelStyle: TextStyle(color: _combustivel == c ? AppColors.primaryDark : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _combustivel = c),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cilindrada,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l.carroCilindrada),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _co2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: l.carroCo2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(l.carroCilindradaAjuda, style: t.bodySmall),
          const SizedBox(height: 16),
          TextField(
            controller: _seguradora,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l.carroSeguradora),
          ),
          const SizedBox(height: 12),
          CampoData(
            rotulo: l.carroSeguroRenova,
            valor: _seguroRenova,
            hoje: widget.hoje,
            aoEscolher: (d) => setState(() => _seguroRenova = d),
          ),
          const SizedBox(height: 12),
          CampoData(
            rotulo: l.carroUltimaIpo,
            valor: _ultimaIpo,
            hoje: widget.hoje,
            ultima: widget.hoje,
            aoEscolher: (d) => setState(() => _ultimaIpo = d),
          ),
          const SizedBox(height: 16),
          Text(l.onbProprioOuFrota, style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (chave, rotulo) in [('proprio', l.onbProprio), ('alugado_frota', l.onbAlugadoFrota)])
                ChoiceChip(
                  label: Text(rotulo),
                  selected: _categoria == chave,
                  showCheckmark: false,
                  labelStyle: TextStyle(color: _categoria == chave ? AppColors.primaryDark : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _categoria = chave),
                ),
            ],
          ),
          Interruptor(rotulo: l.carroUsoTvde, valor: _tvde, aoMudar: (v) => setState(() => _tvde = v)),
          CampoData(
            rotulo: l.carroCartaValidade,
            valor: _carta,
            hoje: widget.hoje,
            aoEscolher: (d) => setState(() => _carta = d),
          ),
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
