// Secção 6 — Avisos: eventos_push (últimos 200, filtros tipo/resultado),
// avisos_massa (criar/listar) e e2e_log (últimos 100).
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class AvisosSeccao extends StatefulWidget {
  final AdminDados dados;
  const AvisosSeccao({super.key, required this.dados});

  @override
  State<AvisosSeccao> createState() => _AvisosSeccaoState();
}

class _AvisosSeccaoState extends State<AvisosSeccao> {
  String? _tipo;
  String? _resultado;
  late Future<List<Linha>> _push;
  late Future<List<Linha>> _massa;
  late Future<List<Linha>> _e2e;
  Set<String> _tipos = {};

  static const _resultados = ['ok', 'sem_token', 'erro', 'pendente'];

  @override
  void initState() {
    super.initState();
    _ler();
  }

  void _ler() {
    _push = widget.dados.eventosPush(tipo: _tipo, resultado: _resultado).then((r) {
      if (_tipo == null && _resultado == null) _tipos = {for (final e in r) texto(e['tipo'])};
      return r;
    });
    _massa = widget.dados.avisosMassa();
    _e2e = widget.dados.e2eLog();
  }

  void _recarregar() => setState(_ler);

  Future<void> _novoMassa() async {
    final l = AppLocalizations.of(context);
    final titulo = TextEditingController();
    final corpo = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.admAvNovoMassa),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CampoAdmin(controlador: titulo, rotulo: l.admAvColTitulo),
              CampoAdmin(controlador: corpo, rotulo: l.admAvColCorpo, linhas: 4),
              Aviso(l.admAvMassaNota, tom: Semaforo.amarelo, icone: Icons.info_outline_rounded),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: Text(l.cancelar)),
          BotaoPequeno(l.admConfirmar, aoTocar: () => Navigator.of(c).pop(true)),
        ],
      ),
    );
    if (ok != true) return;
    if (titulo.text.trim().isEmpty || corpo.text.trim().isEmpty) {
      if (mounted) await mostrarErro(context, l.admAvMassaVazio);
      return;
    }
    try {
      await widget.dados.criarAvisoMassa(titulo.text, corpo.text);
      if (!mounted) return;
      avisar(context, l.admAvMassaCriado);
      _recarregar();
    } catch (e) {
      if (mounted) await mostrarErro(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return PaginaAdmin(
      titulo: l.admAvTitulo,
      subtitulo: l.admAvSub,
      acoes: [
        BotaoPequeno(l.admAvNovoMassa, icone: Icons.campaign_rounded, aoTocar: _novoMassa),
        BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true),
      ],
      children: [
        Cartao(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.admAvFiltroResultado, style: t.labelMedium),
              const SizedBox(height: 6),
              ChipsFiltro<String>(
                opcoes: [(null, l.admTodos), for (final r in _resultados) (r, r)],
                valor: _resultado,
                aoMudar: (v) => setState(() {
                  _resultado = v;
                  _ler();
                }),
              ),
              if (_tipos.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(l.admAvFiltroTipo, style: t.labelMedium),
                const SizedBox(height: 6),
                ChipsFiltro<String>(
                  opcoes: [(null, l.admTodos), for (final x in _tipos.toList()..sort()) (x, x)],
                  valor: _tipo,
                  aoMudar: (v) => setState(() {
                    _tipo = v;
                    _ler();
                  }),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Leitura<List<Linha>>(
          future: _push,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admAvPush(lista.length),
            colunas: [l.admAvColDia, l.admAvColTipo, l.admAvColTitulo, l.admAvColCorpo, l.admAvColResultado, l.admAvColEnviadoEm, l.admAvColErro],
            linhas: [
              for (final e in lista)
                DataRow(cells: [
                  celula(dataOuTraco(lerData(e['dia']))),
                  celula(texto(e['tipo'])),
                  celula(texto(e['titulo']), max: 34, estilo: const TextStyle(fontWeight: FontWeight.w600)),
                  celula(texto(e['corpo']), max: 50),
                  DataCell(Pilula(texto(e['resultado']).isEmpty ? 'pendente' : texto(e['resultado']))),
                  celula(dataHoraPt(lerData(e['enviado_em']))),
                  celula(texto(e['erro']), max: 30),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Leitura<List<Linha>>(
          future: _massa,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          textoVazio: l.admAvMassaVazioLista,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admAvMassa,
            colunas: [l.admAvColCriadoEm, l.admAvColTitulo, l.admAvColCorpo, l.admAvColSegmento, l.admAvColEnviados, l.admAvColEnviadoEm],
            linhas: [
              for (final m in lista)
                DataRow(cells: [
                  celula(dataHoraPt(lerData(m['criado_em']))),
                  celula(texto(m['titulo']), max: 34, estilo: const TextStyle(fontWeight: FontWeight.w600)),
                  celula(texto(m['corpo']), max: 60),
                  celula(texto(m['segmento'])),
                  celula(texto(m['total_enviados'])),
                  celula(m['enviado_em'] == null ? l.admAvNaoEnviado : dataHoraPt(lerData(m['enviado_em']))),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Leitura<List<Linha>>(
          future: _e2e,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admAvE2e,
            colunas: [l.admAvColCriadoEm, l.admAvColFluxo, l.admAvColPasso, l.admAvColEstado, l.admAvColDetalhe, l.admAvColDevice],
            linhas: [
              for (final e in lista)
                DataRow(cells: [
                  celula(dataHoraPt(lerData(e['created_at']))),
                  celula(texto(e['fluxo'])),
                  celula(texto(e['passo']), max: 30),
                  DataCell(Pilula(texto(e['estado']))),
                  celula(texto(e['detalhe']), max: 50),
                  celula(texto(e['device']), max: 20),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}
