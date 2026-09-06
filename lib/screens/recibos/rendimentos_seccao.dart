import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/rendimento.dart';
import '../../regras/regras.dart';
import '../../services/arranque.dart';
import '../../stores/dados_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import 'recibos_widgets.dart';

/// Rendimentos mensais: a lista dos últimos meses, "Registar rendimento"
/// (bottom sheet) e "Ler extrato por foto" (Photo Picker → `ler-extrato`).
class RendimentosSeccao extends StatefulWidget {
  final DateTime hoje;
  const RendimentosSeccao({super.key, required this.hoje});

  @override
  State<RendimentosSeccao> createState() => _RendimentosSeccaoState();
}

class _RendimentosSeccaoState extends State<RendimentosSeccao> {
  bool _aLerFoto = false;
  String? _avisoFoto;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final rend = context.watch<RendimentosStore>();
    final plano = context.watch<PlanoStore>();
    final itens = rend.itens.take(6).toList();
    final total = rend.totalDoAno(widget.hoje.year);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CabecalhoCartao(icone: Icons.payments_rounded, titulo: l.rendTitulo),
              if (rend.erro != null) ...[
                const SizedBox(height: 12),
                Aviso(l.erroRede, tom: Semaforo.vermelho),
              ],
              if (itens.isEmpty)
                Vazio(icone: Icons.receipt_long_outlined, texto: l.rendSemDados)
              else ...[
                const SizedBox(height: 12),
                Text(l.rendUltimos, style: t.bodySmall),
                for (final r in itens) _LinhaRendimento(r, aoApagar: () => _apagar(context, r)),
                const SizedBox(height: 8),
                Text(l.rendTotalAno(moeda(total)), style: t.titleSmall),
              ],
              const SizedBox(height: 14),
              BotaoGrande(texto: l.rendAdicionar, icone: Icons.add_rounded, aoTocar: () => _abrirFormulario(context)),
              const SizedBox(height: 10),
              Cadeado(
                trancado: !plano.permitida('ler_extrato_foto'),
                linha: l.rendFotoCadeado,
                child: BotaoGrande(
                  texto: l.rendFoto,
                  secundario: true,
                  icone: Icons.photo_camera_outlined,
                  aoTocar: _aLerFoto ? null : () => _lerFoto(context),
                ),
              ),
              if (_aLerFoto) ...[
                const SizedBox(height: 8),
                Row(children: [
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.rendFotoALer, style: t.bodySmall)),
                ]),
              ],
              if (_avisoFoto != null) ...[
                const SizedBox(height: 10),
                NotaInfo(_avisoFoto!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _abrirFormulario(BuildContext context, {_Prefill? inicial}) async {
    final l = AppLocalizations.of(context);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FormularioRendimento(hoje: widget.hoje, inicial: inicial),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.rendGuardado)));
    }
  }

  Future<void> _apagar(BuildContext context, Rendimento r) async {
    final l = AppLocalizations.of(context);
    final store = context.read<RendimentosStore>();
    final sim = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.rendApagarPergunta('${nomeMes(r.mes.month)} ${r.mes.year}')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancelar)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.apagar)),
        ],
      ),
    );
    if (sim != true) return;
    final ok = await store.apagar(r);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? l.rendApagado : l.erroRede)));
  }

  /// Foto do extrato (Photo Picker do Android) → base64 → `ler-extrato` →
  /// pré-preenche o formulário. 402 = cadeado, 503 = sem chave: mensagem
  /// humana, nunca crash.
  Future<void> _lerFoto(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final XFile? foto;
    try {
      foto = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    } catch (_) {
      if (mounted) setState(() => _avisoFoto = l.rendFotoNaoLi);
      return;
    }
    if (foto == null || !mounted) return;
    setState(() {
      _aLerFoto = true;
      _avisoFoto = null;
    });
    _Prefill? lido;
    String? aviso;
    try {
      final bytes = await foto.readAsBytes();
      final res = await sb.functions.invoke('ler-extrato', body: {
        'imagem_base64': base64Encode(bytes),
        'mime': _mime(foto),
      });
      final d = Map<String, dynamic>.from(res.data as Map);
      final mes = DateTime.parse('${d['mes']}-01');
      final valor = (d['valor_bruto'] as num).toDouble();
      final confianca = (d['confianca'] as num?)?.toDouble();
      lido = _Prefill(
        mes: DateTime(mes.year, mes.month, 1),
        valor: valor,
        plataforma: _plataformaConhecida(d['plataforma'] as String?),
        confianca: confianca,
        origem: 'foto',
      );
    } on FunctionException catch (e) {
      aviso = switch (e.status) {
        402 => l.rendFotoCadeado,
        503 => l.rendFotoIndisponivel,
        _ => l.rendFotoNaoLi,
      };
    } catch (_) {
      aviso = l.rendFotoNaoLi;
    }
    if (!mounted) return;
    setState(() {
      _aLerFoto = false;
      _avisoFoto = aviso;
    });
    if (lido != null && context.mounted) await _abrirFormulario(context, inicial: lido);
  }

  static String _mime(XFile f) {
    if (f.mimeType != null && f.mimeType!.isNotEmpty) return f.mimeType!;
    final nome = f.name.toLowerCase();
    if (nome.endsWith('.png')) return 'image/png';
    if (nome.endsWith('.webp')) return 'image/webp';
    if (nome.endsWith('.heic')) return 'image/heic';
    return 'image/jpeg';
  }
}

const List<String> _plataformas = ['uber', 'bolt', 'glovo', 'uber_eats', 'outro'];

String? _plataformaConhecida(String? p) => (p != null && _plataformas.contains(p)) ? p : (p == null ? null : 'outro');

String _nomePlataforma(AppLocalizations l, String? p) => switch (p) {
      'uber' => 'Uber',
      'bolt' => 'Bolt',
      'glovo' => 'Glovo',
      'uber_eats' => 'Uber Eats',
      'outro' => l.rendPlataformaOutra,
      _ => l.rendClienteDireto,
    };

String _mesExtenso(DateTime m) {
  final n = nomeMes(m.month);
  return '${n[0].toUpperCase()}${n.substring(1)} ${m.year}';
}

class _LinhaRendimento extends StatelessWidget {
  final Rendimento r;
  final VoidCallback aoApagar;
  const _LinhaRendimento(this.r, {required this.aoApagar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final sub = r.origem == 'foto' ? '${_nomePlataforma(l, r.plataforma)} · ${l.rendOrigemFoto}' : _nomePlataforma(l, r.plataforma);
    return InkWell(
      onLongPress: aoApagar,
      borderRadius: AppTheme.cantosPequenos,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.surface2, shape: BoxShape.circle),
              child: const Icon(Icons.euro_rounded, size: 20, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_mesExtenso(r.mes), style: t.titleMedium),
                  Text(sub, style: t.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(moeda(r.valorBruto), style: t.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _Prefill {
  final DateTime mes;
  final double valor;
  final String? plataforma;
  final double? confianca;
  final String origem;
  const _Prefill({required this.mes, required this.valor, this.plataforma, this.confianca, this.origem = 'manual'});
}

/// Bottom sheet: mês, valor, tipo (serviços/vendas), plataforma.
class _FormularioRendimento extends StatefulWidget {
  final DateTime hoje;
  final _Prefill? inicial;
  const _FormularioRendimento({required this.hoje, this.inicial});

  @override
  State<_FormularioRendimento> createState() => _FormularioRendimentoState();
}

class _FormularioRendimentoState extends State<_FormularioRendimento> {
  late final TextEditingController _valor;
  late DateTime _mes;
  late String _tipo;
  late String? _plataforma;
  bool _aGuardar = false;
  String? _erro;

  List<DateTime> get _meses => List.generate(12, (i) => adicionarMeses(DateTime(widget.hoje.year, widget.hoje.month, 1), -i));

  @override
  void initState() {
    super.initState();
    final i = widget.inicial;
    _valor = TextEditingController(text: i == null ? '' : moeda(i.valor, comSimbolo: false));
    _mes = i?.mes ?? adicionarMeses(DateTime(widget.hoje.year, widget.hoje.month, 1), -1);
    _tipo = 'servicos';
    _plataforma = i?.plataforma;
    if (!_meses.any((m) => m == _mes)) _mes = _meses.first;
  }

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final i = widget.inicial;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.rendAdicionar, style: t.headlineSmall),
            if (i?.confianca != null) ...[
              const SizedBox(height: 12),
              NotaInfo(l.rendLidoDaFoto(pct(i!.confianca! * 100, casas: 0))),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<DateTime>(
              // ignore: deprecated_member_use
              value: _mes,
              decoration: InputDecoration(labelText: l.rendMes),
              items: [for (final m in _meses) DropdownMenuItem(value: m, child: Text(_mesExtenso(m)))],
              onChanged: (m) => setState(() => _mes = m ?? _mes),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valor,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              style: t.titleLarge,
              decoration: InputDecoration(labelText: l.rendValor, suffixText: l.euros, errorText: _erro),
            ),
            const SizedBox(height: 16),
            Text(l.rendTipo, style: t.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ChipEscolha(texto: l.rendTipoServicos, selecionado: _tipo == 'servicos', aoTocar: () => setState(() => _tipo = 'servicos')),
              ChipEscolha(texto: l.rendTipoVendas, selecionado: _tipo == 'vendas', aoTocar: () => setState(() => _tipo = 'vendas')),
            ]),
            const SizedBox(height: 16),
            Text(l.rendPlataforma, style: t.titleSmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ChipEscolha(texto: l.rendClienteDireto, selecionado: _plataforma == null, aoTocar: () => setState(() => _plataforma = null)),
              for (final p in _plataformas)
                ChipEscolha(texto: _nomePlataforma(l, p), selecionado: _plataforma == p, aoTocar: () => setState(() => _plataforma = p)),
            ]),
            const SizedBox(height: 20),
            BotaoGrande(texto: l.rendGuardar, aTrabalhar: _aGuardar, aoTocar: _guardar),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final valor = lerNumero(_valor.text);
    if (valor == null || valor <= 0) {
      setState(() => _erro = l.rendValorInvalido);
      return;
    }
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) {
      setState(() => _erro = l.erroRede);
      return;
    }
    setState(() {
      _aGuardar = true;
      _erro = null;
    });
    final store = context.read<RendimentosStore>();
    final ok = await store.guardar(Rendimento(
      id: '',
      userId: userId,
      mes: _mes,
      valorBruto: centimos(valor),
      tipo: _tipo,
      origem: widget.inicial?.origem ?? 'manual',
      plataforma: _plataforma,
    ));
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _aGuardar = false;
        _erro = l.erroRede;
      });
    }
  }
}
