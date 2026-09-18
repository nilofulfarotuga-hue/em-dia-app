// Secção Assinaturas (B7, 2026-09-18): todas as assinaturas da Play Billing
// numa tabela — produto, plataforma, estado, datas, plano efetivo — com filtro
// por estado, contagens em cima, detalhe na folha lateral e CSV (download na
// web; caixa de copiar fora dela). Lê a RPC admin_assinaturas (só admin).
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';
import '../util/descarregar.dart';

class AssinaturasSeccao extends StatefulWidget {
  final AdminDados dados;
  const AssinaturasSeccao({super.key, required this.dados});

  @override
  State<AssinaturasSeccao> createState() => _AssinaturasSeccaoState();
}

class _AssinaturasSeccaoState extends State<AssinaturasSeccao> {
  String? _estado;
  late Future<List<Linha>> _f;
  List<Linha> _ultima = const [];

  @override
  void initState() {
    super.initState();
    _ler();
  }

  // Guarda a última lista (CSV e contagens) e força um rebuild quando ela
  // chega: o botão do CSV e o resumo leem `_ultima` fora do FutureBuilder.
  void _ler() => _f = widget.dados.assinaturas(estado: _estado).then((x) {
        _ultima = x;
        if (mounted) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? setState(() {}) : null);
        return x;
      });
  void _recarregar() => setState(_ler);

  Future<void> _exportar() async {
    final l = AppLocalizations.of(context);
    final csv = widget.dados.assinaturasCsv(_ultima);
    const nome = 'assinaturas.csv';
    if (await descarregarTexto(nome: nome, conteudo: csv)) {
      if (mounted) avisar(context, l.admBaixado(nome));
      return;
    }
    if (mounted) await mostrarTextoCopiavel(context, titulo: l.admAsTabela(_ultima.length), texto: csv, nota: l.admUsCsvNota);
  }

  void _abrir(Linha a) {
    final l = AppLocalizations.of(context);
    final id = texto(a['id']);
    folhaLateral<void>(
      context,
      titulo: l.admAsDetalhe(id.length >= 8 ? id.substring(0, 8) : id),
      builder: (_) => _DetalheAssinatura(a: a),
    );
  }

  int _conta(List<Linha> x, String estado) => x.where((a) => a['estado'] == estado).length;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return PaginaAdmin(
      titulo: l.admAsTitulo,
      subtitulo: l.admAsSub,
      acoes: [
        BotaoPequeno(l.admBaixarCsv, icone: Icons.download_rounded, aoTocar: _ultima.isEmpty ? null : _exportar, secundario: true),
        BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true),
      ],
      children: [
        Cartao(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ChipsFiltro<String>(
                opcoes: [
                  (null, l.admTodos),
                  ('ativa', l.admAsEstadoAtiva),
                  ('expirada', l.admAsEstadoExpirada),
                  ('cancelada', l.admAsEstadoCancelada),
                  ('pendente', l.admAsEstadoPendente),
                ],
                valor: _estado,
                aoMudar: (v) => setState(() {
                  _estado = v;
                  _ler();
                }),
              ),
              if (_estado == null && _ultima.isNotEmpty)
                Text(
                  l.admAsResumo(_conta(_ultima, 'ativa'), _conta(_ultima, 'expirada'), _conta(_ultima, 'cancelada'), _conta(_ultima, 'pendente')),
                  style: t.bodySmall,
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
            titulo: l.admAsTabela(lista.length),
            colunas: [l.admAsColUsuario, l.admAsColProduto, l.admAsColPlataforma, l.admAsColEstado, l.admAsColPlano, l.admAsColComecou, l.admAsColRenova, l.admAsColTerminou],
            linhas: [
              for (final a in lista)
                DataRow(
                  onSelectChanged: (_) => _abrir(a),
                  cells: [
                    celula(texto(a['email']).isEmpty ? texto(a['user_id']) : texto(a['email']), max: 32, estilo: const TextStyle(fontWeight: FontWeight.w600)),
                    celula(texto(a['produto_id'])),
                    celula(texto(a['plataforma'])),
                    DataCell(Pilula(texto(a['estado']))),
                    DataCell(Pilula(texto(a['plano_efetivo']))),
                    celula(dataOuTraco(lerData(a['comecou_em']))),
                    celula(dataOuTraco(lerData(a['renova_em']))),
                    celula(dataOuTraco(lerData(a['terminou_em']))),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetalheAssinatura extends StatelessWidget {
  final Linha a;
  const _DetalheAssinatura({required this.a});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return ListView(
      children: [
        Text(texto(a['produto_id']), style: t.titleLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Pilula(texto(a['estado'])),
          Pilula(texto(a['plano_efetivo'])),
          Pilula('', texto: texto(a['plataforma'])),
          if (a['tem_comprovativo'] == true) Pilula('ok', texto: l.admAsComprovativo),
        ]),
        const SizedBox(height: 16),
        LinhaDetalhe('id', texto(a['id'])),
        LinhaDetalhe(l.admAsColUsuario, '${texto(a['email'])} · ${texto(a['user_id'])}'),
        if (texto(a['nome']).isNotEmpty) LinhaDetalhe('nome', texto(a['nome'])),
        LinhaDetalhe(l.admAsColComecou, dataHoraPt(lerData(a['comecou_em']))),
        LinhaDetalhe(l.admAsColRenova, dataHoraPt(lerData(a['renova_em']))),
        LinhaDetalhe(l.admAsColTerminou, dataHoraPt(lerData(a['terminou_em']))),
        LinhaDetalhe('criado_em', dataHoraPt(lerData(a['criado_em']))),
        LinhaDetalhe('atualizado_em', dataHoraPt(lerData(a['atualizado_em']))),
      ],
    );
  }
}
