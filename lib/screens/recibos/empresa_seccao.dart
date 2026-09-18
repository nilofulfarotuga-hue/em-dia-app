import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../services/arranque.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../widgets/widgets.dart';
import '../calendario/detalhe_obrigacao.dart';
import 'contrato_seccao.dart' show BotaoLigacao;
import 'recibos_widgets.dart';

/// O separador Recibos de quem tem EMPRESA (B3): ENI ou sociedade em duas
/// frases, o calendário que vem a seguir, e a pasta do contabilista.
/// A app não substitui o contabilista — poupa-lhe as horas de juntar papéis.
class EmpresaSeccao extends StatelessWidget {
  final DateTime hoje;
  const EmpresaSeccao({super.key, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final perfil = context.watch<PerfilStore>().perfil;
    final obrig = context.watch<ObrigacoesStore>();
    final sociedade = perfil?.empresaTipo == 'sociedade';
    final tiposEmpresa = {'iva_declaracao', 'iva_pagamento', 'saft', 'dmr', 'ss_empresa', 'irc_modelo22', 'irc_pagamento_conta', 'ies'};
    final proximas = obrig.pendentes(hoje).where((o) => tiposEmpresa.contains(o.tipo)).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Cartao(
          key: const Key('empresa_card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CabecalhoCartao(
                icone: sociedade ? Icons.apartment_rounded : Icons.person_rounded,
                titulo: sociedade ? l.empresaSociedadeTitulo : l.empresaEniTitulo,
                direita: BotaoOuvir(
                  etiqueta: 'empresa-tipo',
                  texto: '${sociedade ? l.empresaSociedadeTexto : l.empresaEniTexto} ${l.empresaNaoSubstitui}',
                  soIcone: true,
                ),
              ),
              const SizedBox(height: 8),
              Text(sociedade ? l.empresaSociedadeTexto : l.empresaEniTexto, style: t.bodyMedium),
              const SizedBox(height: 6),
              Text(l.empresaNaoSubstitui, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Cartao(
          key: const Key('empresa_calendario'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CabecalhoCartao(icone: Icons.calendar_month_rounded, titulo: l.empresaCalendarioTitulo),
              const SizedBox(height: 6),
              if (proximas.isEmpty)
                Text(l.empresaCalendarioVazio, style: t.bodyMedium)
              else
                for (final o in proximas)
                  InkWell(
                    key: Key('empresa_obrigacao_${o.tipo}_${o.dataLimite.month}'),
                    borderRadius: AppTheme.cantosPequenos,
                    onTap: () => mostrarDetalheObrigacao(context, obrigacao: o, hoje: hoje),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(width: 56, child: Text(dataPt(o.prazoEfetivo).substring(0, 5), style: t.titleSmall)),
                          Expanded(child: Text(o.descricao, style: t.bodyMedium, maxLines: 2, overflow: TextOverflow.ellipsis)),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 6),
              Text(proximas.isEmpty ? l.empresaCalendarioNota : '${l.empresaCalendarioToca} ${l.empresaCalendarioNota}', style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
              BotaoLigacao(texto: l.empresaAbrirAgenda, url: 'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/Quadro_res_Decl_2026.aspx'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const PastaContabilistaCard(),
      ],
    );
  }
}

/// «Pasta do contabilista»: todo o dia 1 a app junta o mês anterior (o que
/// entrou, o que saiu, o extrato, as faturas, os recibos) e envia por e-mail.
/// Aqui liga-se, muda-se o e-mail e manda-se já a do mês passado.
class PastaContabilistaCard extends StatefulWidget {
  const PastaContabilistaCard({super.key});

  @override
  State<PastaContabilistaCard> createState() => _PastaContabilistaCardState();
}

class _PastaContabilistaCardState extends State<PastaContabilistaCard> {
  late final TextEditingController _email;
  bool _aGuardar = false;
  bool _aEnviar = false;
  String? _resultado;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: context.read<PerfilStore>().perfil?.contabilistaEmail ?? '');
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  bool get _emailValido => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(_email.text.trim());

  Future<void> _guardar(bool ativa) async {
    final l = AppLocalizations.of(context);
    final store = context.read<PerfilStore>();
    final perfil = store.perfil;
    if (perfil == null) return;
    final email = _email.text.trim();
    if (ativa && !_emailValido) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.pastaEmailInvalido)));
      return;
    }
    setState(() => _aGuardar = true);
    final ok = await store.guardar(perfil.copyWith(
      contabilistaEmail: email.isEmpty ? null : email,
      limparContabilista: email.isEmpty,
      pastaContabilistaAtiva: ativa && email.isNotEmpty,
    ));
    if (!mounted) return;
    setState(() => _aGuardar = false);
    if (!ok) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.erroRede)));
  }

  Future<void> _enviarAgora() async {
    final l = AppLocalizations.of(context);
    if (!_emailValido) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.pastaEmailInvalido)));
      return;
    }
    setState(() {
      _aEnviar = true;
      _resultado = null;
    });
    try {
      final res = await sb.functions.invoke('pasta-contabilista', body: {'modo': 'agora'});
      final d = Map<String, dynamic>.from(res.data as Map);
      final itens = Map<String, dynamic>.from((d['itens'] as Map?) ?? {});
      final total = itens.values.fold<int>(0, (t, v) => t + ((v as num?)?.toInt() ?? 0));
      setState(() => _resultado = l.pastaEnviada(d['para']?.toString() ?? _email.text.trim(), total));
    } catch (e) {
      setState(() => _resultado = l.pastaFalhou);
    } finally {
      if (mounted) setState(() => _aEnviar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final perfil = context.watch<PerfilStore>().perfil;
    final ativa = perfil?.pastaContabilistaAtiva ?? false;
    return Cartao(
      key: const Key('pasta_contabilista_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoCartao(icone: Icons.folder_shared_rounded, titulo: l.pastaTitulo),
          const SizedBox(height: 6),
          Text(l.pastaTexto, style: t.bodyMedium),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(labelText: l.onbContabilistaEmail, prefixIcon: const Icon(Icons.mail_outline_rounded)),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _guardar(ativa),
          ),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              value: ativa,
              onChanged: _aGuardar ? null : (v) => _guardar(v),
              contentPadding: EdgeInsets.zero,
              title: Text(l.pastaLigar, style: t.bodyMedium),
              subtitle: Text(l.pastaLigarAjuda, style: t.bodySmall),
              activeThumbColor: AppColors.primary,
            ),
          ),
          BotaoGrande(
            texto: _aEnviar ? l.pastaAEnviar : l.pastaEnviarAgora,
            icone: Icons.send_rounded,
            secundario: true,
            aTrabalhar: _aEnviar,
            aoTocar: _aEnviar || !_emailValido ? null : _enviarAgora,
          ),
          if (_resultado != null) ...[
            const SizedBox(height: 10),
            NotaInfo(_resultado!),
          ],
        ],
      ),
    );
  }
}
