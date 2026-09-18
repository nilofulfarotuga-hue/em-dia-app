import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../services/arranque.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import 'recibos_widgets.dart';

/// Passar uma fatura-recibo certificada de dentro da app (B2b, InvoiceXpress).
///
/// Só se chega aqui quando o interruptor `faturacao_certificada` está ligado
/// no servidor (`PlanoStore.ligadaParaAlguem`) — o cartão em Recibos nem
/// aparece sem isso. Quem faz a conta é a Edge Function `emitir-recibo`; o
/// telemóvel só recolhe as quatro coisas que a pessoa sabe: para quem, o quê,
/// quanto, e se leva retenção. O regime de IVA vem do perfil.
class EmitirReciboScreen extends StatefulWidget {
  /// Só para fotos: começa com o formulário já escrito.
  final String? nomeInicial;
  final String? descricaoInicial;
  final String? valorInicial;
  const EmitirReciboScreen({super.key, this.nomeInicial, this.descricaoInicial, this.valorInicial});

  @override
  State<EmitirReciboScreen> createState() => _EmitirReciboScreenState();
}

class _EmitirReciboScreenState extends State<EmitirReciboScreen> {
  late final _nome = TextEditingController(text: widget.nomeInicial);
  final _nif = TextEditingController();
  late final _descricao = TextEditingController(text: widget.descricaoInicial);
  late final _valor = TextEditingController(text: widget.valorInicial);
  bool _comRetencao = false;
  bool _aEmitir = false;
  String? _numero;
  String? _pdfUrl;
  bool _feito = false;

  @override
  void dispose() {
    _nome.dispose();
    _nif.dispose();
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  void _snack(String texto) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _emitir(AppLocalizations l, RegrasLegais r) async {
    final nome = _nome.text.trim();
    final descricao = _descricao.text.trim();
    final valor = lerNumero(_valor.text);
    if (nome.length < 2) return _snack(l.faturaFaltaNome);
    if (descricao.length < 2) return _snack(l.faturaFaltaDescricao);
    if (valor == null || valor <= 0) return _snack(l.faturaValorInvalido);
    final nif = _nif.text.trim();
    if (nif.isNotEmpty && !nifValido(nif)) return _snack(l.faturaNifInvalido);

    setState(() => _aEmitir = true);
    try {
      final res = await sb.functions.invoke('emitir-recibo', body: {
        'modo': 'emitir',
        'cliente': {'nome': nome, if (nif.isNotEmpty) 'nif': nif},
        'descricao': descricao,
        'valor': valor,
        'retencao': _comRetencao ? r.n('retencao_padrao') : 0,
      });
      final d = Map<String, dynamic>.from(res.data as Map);
      setState(() {
        _feito = true;
        _numero = d['numero'] as String?;
        _pdfUrl = d['pdf_url'] as String?;
      });
    } catch (e) {
      final codigo = _codigoDoErro(e);
      _snack(switch (codigo) {
        'desligada' => l.faturaErroDesligada,
        'sem_conta' => l.faturaErroSemConta,
        'plano' => l.faturaErroPlano,
        'nif_invalido' => l.faturaNifInvalido,
        'invoicexpress_recusou' || 'nao_fechou' || 'resposta_estranha' || 'resposta_sem_id' => l.faturaErroRecusou,
        _ => l.erroRede,
      });
    } finally {
      if (mounted) setState(() => _aEmitir = false);
    }
  }

  /// O código de erro vem no corpo da resposta (`{"erro": "…"}`), que o
  /// cliente do Supabase embrulha numa exceção.
  static String _codigoDoErro(Object e) {
    final s = e.toString();
    final m = RegExp(r'erro[":\s]+([a-z_]+)').firstMatch(s);
    return m?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final regras = context.watch<RegrasStore>().regras;
    final perfil = context.watch<PerfilStore>().perfil;
    final isento = perfil?.regimeIva != RegimeIva.normal;
    final pctRetencao = pct(regras.n('retencao_padrao'), casas: 0).replaceAll(' %', '').replaceAll('%', '');

    return Scaffold(
      appBar: AppBar(title: Text(l.faturaTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(l.faturaExplica, style: t.bodyLarge)),
              BotaoOuvir(etiqueta: 'fatura-explica', texto: '${l.faturaExplica} ${isento ? l.faturaIsento : l.faturaComIva}', soIcone: true),
            ],
          ),
          const SizedBox(height: 16),
          if (_feito) ...[
            Aviso(
              _numero == null || _numero!.isEmpty ? l.faturaFeitaSemNumero : l.faturaFeita(_numero!),
              tom: Semaforo.verde,
              icone: Icons.check_circle_rounded,
            ),
            const SizedBox(height: 10),
            if (_pdfUrl != null)
              BotaoGrande(
                texto: l.faturaAbrirPdf,
                icone: Icons.picture_as_pdf_rounded,
                aoTocar: () => launchUrl(Uri.parse(_pdfUrl!), mode: LaunchMode.externalApplication),
              )
            else
              NotaInfo(l.faturaSemPdf),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _nome,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l.faturaClienteNome, prefixIcon: const Icon(Icons.person_outline_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nif,
            keyboardType: TextInputType.number,
            maxLength: 9,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l.faturaClienteNif, prefixIcon: const Icon(Icons.badge_outlined), counterText: ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descricao,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.faturaDescricao, prefixIcon: const Icon(Icons.work_outline_rounded)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.faturaValor, prefixIcon: const Icon(Icons.euro_rounded)),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              value: _comRetencao,
              onChanged: (v) => setState(() => _comRetencao = v),
              contentPadding: EdgeInsets.zero,
              title: Text(l.faturaRetencao(pctRetencao), style: t.bodyMedium),
              activeThumbColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          NotaInfo(isento ? l.faturaIsento : l.faturaComIva),
          const SizedBox(height: 20),
          BotaoGrande(
            texto: _aEmitir ? l.faturaAEmitir : l.faturaEmitir,
            icone: Icons.receipt_long_rounded,
            aTrabalhar: _aEmitir,
            aoTocar: _aEmitir ? null : () => _emitir(l, regras),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// NIF português: 9 dígitos com dígito de controlo (módulo 11).
bool nifValido(String nif) {
  if (!RegExp(r'^\d{9}$').hasMatch(nif)) return false;
  final n = nif.split('').map(int.parse).toList();
  var soma = 0;
  for (var i = 0; i < 8; i++) {
    soma += n[i] * (9 - i);
  }
  final resto = soma % 11;
  final controlo = resto < 2 ? 0 : 11 - resto;
  return controlo == n[8];
}
