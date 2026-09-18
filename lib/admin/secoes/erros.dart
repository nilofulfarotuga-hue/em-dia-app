// Secção Erros de leitura e importação (B7, 2026-09-18): o que a máquina não
// conseguiu ler bem, numa lista só — OCR (sem valor, pouca confiança ou
// corrigido pela pessoa), extratos que não importaram, e-mails de fatura que
// não deram, recibos recusados. Filtro por tipo, detalhe na folha lateral,
// CSV. Lê a RPC admin_erros (só admin).
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';
import '../util/descarregar.dart';

class ErrosSeccao extends StatefulWidget {
  final AdminDados dados;
  const ErrosSeccao({super.key, required this.dados});

  @override
  State<ErrosSeccao> createState() => _ErrosSeccaoState();
}

class _ErrosSeccaoState extends State<ErrosSeccao> {
  String? _tipo;
  late Future<List<Linha>> _f;
  List<Linha> _ultima = const [];

  @override
  void initState() {
    super.initState();
    _ler();
  }

  // Guarda a última lista (CSV e contagens) e força um rebuild quando ela
  // chega: o botão do CSV e o resumo leem `_ultima` fora do FutureBuilder.
  void _ler() => _f = widget.dados.erros(tipo: _tipo).then((x) {
        _ultima = x;
        if (mounted) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? setState(() {}) : null);
        return x;
      });
  void _recarregar() => setState(_ler);

  Future<void> _exportar() async {
    final l = AppLocalizations.of(context);
    final csv = widget.dados.errosCsv(_ultima);
    const nome = 'erros-leitura.csv';
    if (await descarregarTexto(nome: nome, conteudo: csv)) {
      if (mounted) avisar(context, l.admBaixado(nome));
      return;
    }
    if (mounted) await mostrarTextoCopiavel(context, titulo: l.admErTabela(_ultima.length), texto: csv, nota: l.admUsCsvNota);
  }

  String _nomeTipo(AppLocalizations l, String tipo) => switch (tipo) {
        'ocr' => l.admErTipoOcr,
        'importacao' => l.admErTipoImportacao,
        'fatura' => l.admErTipoFatura,
        'recibo' => l.admErTipoRecibo,
        _ => tipo,
      };

  void _abrir(Linha e) {
    final l = AppLocalizations.of(context);
    folhaLateral<void>(
      context,
      titulo: l.admErDetalhe,
      builder: (_) => _DetalheErro(e: e, nomeTipo: _nomeTipo(l, texto(e['tipo']))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admErTitulo,
      subtitulo: l.admErSub,
      acoes: [
        BotaoPequeno(l.admBaixarCsv, icone: Icons.download_rounded, aoTocar: _ultima.isEmpty ? null : _exportar, secundario: true),
        BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true),
      ],
      children: [
        Cartao(
          padding: const EdgeInsets.all(12),
          child: ChipsFiltro<String>(
            opcoes: [
              (null, l.admTodos),
              ('ocr', l.admErTipoOcr),
              ('importacao', l.admErTipoImportacao),
              ('fatura', l.admErTipoFatura),
              ('recibo', l.admErTipoRecibo),
            ],
            valor: _tipo,
            aoMudar: (v) => setState(() {
              _tipo = v;
              _ler();
            }),
          ),
        ),
        const SizedBox(height: 12),
        Leitura<List<Linha>>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admErTabela(lista.length),
            colunas: [l.admErColQuando, l.admErColTipo, l.admErColUsuario, l.admErColResumo, l.admErColErro],
            linhas: [
              for (final e in lista)
                DataRow(
                  onSelectChanged: (_) => _abrir(e),
                  cells: [
                    celula(dataHoraPt(lerData(e['quando']))),
                    DataCell(Pilula('em_curso', texto: _nomeTipo(l, texto(e['tipo'])))),
                    celula(texto(e['email']).isEmpty ? texto(e['user_id']) : texto(e['email']), max: 28),
                    celula(texto(e['resumo']), max: 56, estilo: const TextStyle(fontWeight: FontWeight.w600)),
                    DataCell(Pilula('erro', texto: texto(e['erro']).isEmpty ? '?' : texto(e['erro']))),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetalheErro extends StatelessWidget {
  final Linha e;
  final String nomeTipo;
  const _DetalheErro({required this.e, required this.nomeTipo});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final detalhe = e['detalhe'];
    final bonito = detalhe == null ? '—' : const JsonEncoder.withIndent('  ').convert(detalhe);
    return ListView(
      children: [
        Text(texto(e['resumo']), style: t.titleLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Pilula('em_curso', texto: nomeTipo),
          Pilula('erro', texto: texto(e['erro'])),
          Text(dataHoraPt(lerData(e['quando'])), style: t.bodySmall),
        ]),
        const SizedBox(height: 16),
        LinhaDetalhe('id', texto(e['id'])),
        LinhaDetalhe(l.admErColUsuario, '${texto(e['email'])} · ${texto(e['user_id'])}'),
        const SizedBox(height: 12),
        Text(l.admErDetalhe, style: t.titleMedium),
        const SizedBox(height: 4),
        SelectableText(bonito, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
      ],
    );
  }
}
