// Secção 7 — Auditoria: admin_audit_log (últimas 300) com filtros por ação e
// tipo de alvo; detalhe com o antes/depois em JSON.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class AuditoriaSeccao extends StatefulWidget {
  final AdminDados dados;
  const AuditoriaSeccao({super.key, required this.dados});

  @override
  State<AuditoriaSeccao> createState() => _AuditoriaSeccaoState();
}

class _AuditoriaSeccaoState extends State<AuditoriaSeccao> {
  final _acao = TextEditingController();
  String? _alvo;
  late Future<List<Linha>> _f;

  static const _alvos = ['profiles', 'regras_legais', 'irs_escaloes', 'feature_flags', 'tickets_suporte', 'avisos_massa', 'guias'];

  @override
  void initState() {
    super.initState();
    _ler();
  }

  @override
  void dispose() {
    _acao.dispose();
    super.dispose();
  }

  void _ler() => _f = widget.dados.auditoria(acao: _acao.text, alvoTipo: _alvo);
  void _recarregar() => setState(_ler);

  void _abrir(Linha a) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    folhaLateral<void>(
      context,
      titulo: l.admAuDetalhe(texto(a['id'])),
      builder: (ctx) => ListView(
        children: [
          LinhaDetalhe(l.admAuColQuando, dataHoraPt(lerData(a['criado_em']))),
          LinhaDetalhe(l.admAuColAdmin, texto(a['admin_id'])),
          LinhaDetalhe(l.admAuColAcao, texto(a['acao'])),
          LinhaDetalhe(l.admAuColAlvo, '${texto(a['alvo_tipo'])} · ${texto(a['alvo_id'])}'),
          const SizedBox(height: 12),
          Text(l.admAuColAntes, style: t.titleMedium),
          const SizedBox(height: 4),
          _Json(jsonBonito(a['antes'])),
          const SizedBox(height: 12),
          Text(l.admAuColDepois, style: t.titleMedium),
          const SizedBox(height: 4),
          _Json(jsonBonito(a['depois'])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admAuTitulo,
      subtitulo: l.admAuSub,
      acoes: [BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true)],
      children: [
        Cartao(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _acao,
                onSubmitted: (_) => _recarregar(),
                decoration: InputDecoration(
                  hintText: l.admAuFiltroAcao,
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                  suffixIcon: IconButton(onPressed: _recarregar, icon: const Icon(Icons.arrow_forward_rounded)),
                ),
              ),
              const SizedBox(height: 10),
              ChipsFiltro<String>(
                opcoes: [(null, l.admTodos), for (final a in _alvos) (a, a)],
                valor: _alvo,
                aoMudar: (v) => setState(() {
                  _alvo = v;
                  _ler();
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Leitura<List<Linha>>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admAuTabela(lista.length),
            colunas: [l.admAuColQuando, l.admAuColAdmin, l.admAuColAcao, l.admAuColAlvo, l.admAuColAntes, l.admAuColDepois],
            linhas: [
              for (final a in lista)
                DataRow(
                  onSelectChanged: (_) => _abrir(a),
                  cells: [
                    celula(dataHoraPt(lerData(a['criado_em']))),
                    celula(texto(a['admin_id']), max: 12),
                    celula(texto(a['acao']), estilo: const TextStyle(fontWeight: FontWeight.w600)),
                    celula('${texto(a['alvo_tipo'])} · ${texto(a['alvo_id'])}', max: 40),
                    celula(a['antes'] == null ? '—' : jsonBonito(a['antes']), max: 36),
                    celula(a['depois'] == null ? '—' : jsonBonito(a['depois']), max: 36),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Json extends StatelessWidget {
  final String texto;
  const _Json(this.texto);

  @override
  Widget build(BuildContext context) {
    return Cartao(
      cor: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(12),
      child: SelectableText(texto, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
    );
  }
}
