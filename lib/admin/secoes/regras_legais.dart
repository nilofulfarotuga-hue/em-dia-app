// Secção 3 — Regras legais: a tabela regras_legais editável sem código, os
// escalões de IRS e os cadeados por plano (feature_flags). Guardar = update +
// admin_audit_log. Botão "Aviso em massa: o IAS mudou" cria avisos_massa.
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class RegrasLegaisSeccao extends StatefulWidget {
  final AdminDados dados;
  final int abaInicial;
  const RegrasLegaisSeccao({super.key, required this.dados, this.abaInicial = 0});

  @override
  State<RegrasLegaisSeccao> createState() => _RegrasLegaisSeccaoState();
}

class _RegrasLegaisSeccaoState extends State<RegrasLegaisSeccao> {
  late int _aba;
  final _pesquisa = TextEditingController();
  late Future<List<Linha>> _regras;
  late Future<List<Linha>> _escaloes;
  late Future<List<Linha>> _flags;
  List<Linha> _regrasLidas = const [];

  @override
  void initState() {
    super.initState();
    _aba = widget.abaInicial;
    _ler();
  }

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  void _ler() {
    _regras = widget.dados.regras().then((r) => _regrasLidas = r);
    _escaloes = widget.dados.escaloes();
    _flags = widget.dados.flags();
  }

  void _recarregar() => setState(_ler);

  Future<void> _avisoIas() async {
    final l = AppLocalizations.of(context);
    Linha? ias;
    for (final r in _regrasLidas) {
      if (r['chave'] == 'ias') ias = r;
    }
    final valor = ias == null ? '—' : moeda(numero(ias['valor_num']) ?? 0);
    final titulo = TextEditingController(text: l.admRgAvisoIasTitulo);
    final corpo = TextEditingController(text: l.admRgAvisoIasCorpo(valor));
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.admRgAvisoIas),
        content: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CampoAdmin(controlador: titulo, rotulo: l.admRgAvisoTituloCampo),
              CampoAdmin(controlador: corpo, rotulo: l.admRgAvisoCorpoCampo, linhas: 4),
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
    try {
      await widget.dados.criarAvisoMassa(titulo.text, corpo.text);
      if (mounted) avisar(context, l.admRgAvisoCriado);
    } catch (e) {
      if (mounted) await mostrarErro(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admRgTitulo,
      subtitulo: l.admRgSub,
      acoes: [
        BotaoPequeno(l.admRgAvisoIas, icone: Icons.campaign_rounded, aoTocar: _avisoIas),
        BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true),
      ],
      children: [
        ChipsFiltro<int>(
          opcoes: [(0, l.admRgAba1), (1, l.admRgAba2), (2, l.admRgAba3)],
          valor: _aba,
          aoMudar: (v) => setState(() => _aba = v ?? 0),
        ),
        const SizedBox(height: 12),
        if (_aba == 0) ...[
          Cartao(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _pesquisa,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(hintText: l.admRgPesquisa, prefixIcon: const Icon(Icons.search_rounded), isDense: true),
            ),
          ),
          const SizedBox(height: 12),
          Leitura<List<Linha>>(
            future: _regras,
            aoTentarDeNovo: _recarregar,
            vazio: (x) => x.isEmpty,
            builder: (context, lista) {
              final p = _pesquisa.text.trim().toLowerCase();
              final filtradas = lista
                  .where((r) => p.isEmpty || texto(r['chave']).toLowerCase().contains(p) || texto(r['descricao']).toLowerCase().contains(p))
                  .toList();
              return TabelaAdmin(
                titulo: l.admRgTabela(filtradas.length, lista.length),
                colunas: [l.admRgColChave, l.admRgColDescricao, l.admRgColValor, l.admRgColUnidade, l.admRgColAno, l.admRgColConfianca, l.admRgColVerificado, l.admRgColFonte],
                linhas: [
                  for (final r in filtradas)
                    DataRow(
                      onSelectChanged: (_) => _editarRegra(r),
                      cells: [
                        celula(texto(r['chave']), max: 34, estilo: const TextStyle(fontWeight: FontWeight.w600)),
                        celula(texto(r['descricao']), max: 44),
                        celula(_valorRegra(r), max: 28),
                        celula(texto(r['unidade'])),
                        celula(texto(r['ano'])),
                        DataCell(Pilula(texto(r['confianca']))),
                        celula(texto(r['verificado_em'])),
                        celula(texto(r['fonte_url']), max: 30),
                      ],
                    ),
                ],
              );
            },
          ),
        ],
        if (_aba == 1)
          Leitura<List<Linha>>(
            future: _escaloes,
            aoTentarDeNovo: _recarregar,
            vazio: (x) => x.isEmpty,
            builder: (context, lista) => TabelaAdmin(
              colunas: [l.admRgColAno, l.admRgEscOrdem, l.admRgEscAte, l.admRgEscTaxa, l.admRgEscParcela],
              linhas: [
                for (final e in lista)
                  DataRow(
                    onSelectChanged: (_) => _editarEscalao(e),
                    cells: [
                      celula(texto(e['ano'])),
                      celula(texto(e['ordem'])),
                      celula(e['ate'] == null ? l.admRgEscSemLimite : moeda(numero(e['ate']) ?? 0)),
                      celula(pct((numero(e['taxa']) ?? 0) * 100, casas: 2)),
                      celula(moeda(numero(e['parcela_abater']) ?? 0)),
                    ],
                  ),
              ],
            ),
          ),
        if (_aba == 2)
          Leitura<List<Linha>>(
            future: _flags,
            aoTentarDeNovo: _recarregar,
            vazio: (x) => x.isEmpty,
            builder: (context, lista) => TabelaAdmin(
              colunas: [l.admRgFlagChave, l.admRgFlagDescricao, l.admRgFlagFree, l.admRgFlagPro, l.admRgFlagFamilia, l.admRgFlagLimFree, l.admRgFlagLimPro, l.admRgFlagLimFamilia],
              linhas: [
                for (final f in lista)
                  DataRow(
                    onSelectChanged: (_) => _editarFlag(f),
                    cells: [
                      celula(texto(f['chave']), estilo: const TextStyle(fontWeight: FontWeight.w600)),
                      celula(texto(f['descricao']), max: 40),
                      DataCell(_Check(f['free'] == true)),
                      DataCell(_Check(f['pro'] == true)),
                      DataCell(_Check(f['familia'] == true)),
                      celula(f['limite_free'] == null ? '∞' : texto(f['limite_free'])),
                      celula(f['limite_pro'] == null ? '∞' : texto(f['limite_pro'])),
                      celula(f['limite_familia'] == null ? '∞' : texto(f['limite_familia'])),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  static String _valorRegra(Linha r) {
    if (r['valor_num'] != null) return texto(r['valor_num']);
    if (r['valor_txt'] != null) return texto(r['valor_txt']);
    if (r['valor_json'] != null) return jsonEncode(r['valor_json']);
    return '—';
  }

  Future<void> _guardar(Future<void> Function() acao) async {
    final l = AppLocalizations.of(context);
    try {
      await acao();
      if (!mounted) return;
      Navigator.of(context).pop();
      avisar(context, l.admSalvo);
      _recarregar();
    } catch (e) {
      if (mounted) await mostrarErro(context, e);
    }
  }

  void _editarRegra(Linha r) {
    final l = AppLocalizations.of(context);
    final descricao = TextEditingController(text: texto(r['descricao']));
    final valorNum = TextEditingController(text: texto(r['valor_num']));
    final valorTxt = TextEditingController(text: texto(r['valor_txt']));
    final valorJson = TextEditingController(text: r['valor_json'] == null ? '' : jsonBonito(r['valor_json']));
    final unidade = TextEditingController(text: texto(r['unidade']));
    final ano = TextEditingController(text: texto(r['ano']));
    final fonte = TextEditingController(text: texto(r['fonte_url']));
    final verificado = TextEditingController(text: texto(r['verificado_em']));
    var confianca = texto(r['confianca']).isEmpty ? 'oficial' : texto(r['confianca']);
    folhaLateral<void>(
      context,
      titulo: '${l.admRgEditar} · ${texto(r['chave'])}',
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => ListView(
          children: [
            CampoAdmin(controlador: descricao, rotulo: l.admRgColDescricao, linhas: 2),
            CampoAdmin(controlador: valorNum, rotulo: l.admRgValorNum, tipo: const TextInputType.numberWithOptions(decimal: true)),
            CampoAdmin(controlador: valorTxt, rotulo: l.admRgValorTxt, linhas: 2),
            CampoAdmin(controlador: valorJson, rotulo: l.admRgValorJson, linhas: 5),
            Row(children: [
              Expanded(child: CampoAdmin(controlador: unidade, rotulo: l.admRgColUnidade)),
              const SizedBox(width: 12),
              Expanded(child: CampoAdmin(controlador: ano, rotulo: l.admRgColAno, tipo: TextInputType.number)),
            ]),
            CampoAdmin(controlador: fonte, rotulo: l.admRgFonteUrl),
            CampoAdmin(controlador: verificado, rotulo: l.admRgVerificadoEm),
            Text(l.admRgConfianca, style: Theme.of(ctx).textTheme.labelMedium),
            const SizedBox(height: 6),
            ChipsFiltro<String>(
              opcoes: const [('oficial', 'oficial'), ('aproximado', 'aproximado'), ('por_confirmar', 'por_confirmar')],
              valor: confianca,
              aoMudar: (v) => setS(() => confianca = v ?? 'oficial'),
            ),
            const SizedBox(height: 20),
            Row(children: [
              BotaoPequeno(l.admSalvar, icone: Icons.save_rounded, aoTocar: () async {
                dynamic json;
                if (valorJson.text.trim().isNotEmpty) {
                  try {
                    json = jsonDecode(valorJson.text);
                  } catch (_) {
                    await mostrarErro(ctx, l.admRgJsonInvalido);
                    return;
                  }
                }
                final depois = <String, dynamic>{
                  'descricao': descricao.text.trim(),
                  'valor_num': valorNum.text.trim().isEmpty ? null : lerNumero(valorNum.text),
                  'valor_txt': valorTxt.text.trim().isEmpty ? null : valorTxt.text.trim(),
                  'valor_json': json,
                  'unidade': unidade.text.trim().isEmpty ? null : unidade.text.trim(),
                  'ano': int.tryParse(ano.text.trim()) ?? r['ano'],
                  'confianca': confianca,
                  'fonte_url': fonte.text.trim().isEmpty ? null : fonte.text.trim(),
                  'verificado_em': verificado.text.trim().isEmpty ? null : verificado.text.trim(),
                };
                await _guardar(() => widget.dados.guardarRegra(r, depois));
              }),
              const SizedBox(width: 8),
              BotaoPequeno(l.cancelar, aoTocar: () => Navigator.of(ctx).pop(), secundario: true),
            ]),
          ],
        ),
      ),
    );
  }

  void _editarEscalao(Linha e) {
    final l = AppLocalizations.of(context);
    final ate = TextEditingController(text: texto(e['ate']));
    final taxa = TextEditingController(text: texto(e['taxa']));
    final parcela = TextEditingController(text: texto(e['parcela_abater']));
    folhaLateral<void>(
      context,
      titulo: '${l.admRgEscEditar} · ${texto(e['ano'])} #${texto(e['ordem'])}',
      builder: (ctx) => ListView(
        children: [
          CampoAdmin(controlador: ate, rotulo: l.admRgEscAte, ajuda: l.admRgEscSemLimiteAjuda, tipo: const TextInputType.numberWithOptions(decimal: true)),
          CampoAdmin(controlador: taxa, rotulo: l.admRgEscTaxaAjuda, tipo: const TextInputType.numberWithOptions(decimal: true)),
          CampoAdmin(controlador: parcela, rotulo: l.admRgEscParcela, tipo: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 12),
          Row(children: [
            BotaoPequeno(l.admSalvar, icone: Icons.save_rounded, aoTocar: () async {
              final depois = <String, dynamic>{
                'ate': ate.text.trim().isEmpty ? null : lerNumero(ate.text),
                'taxa': lerNumero(taxa.text) ?? e['taxa'],
                'parcela_abater': lerNumero(parcela.text) ?? e['parcela_abater'],
              };
              await _guardar(() => widget.dados.guardarEscalao(e, depois));
            }),
            const SizedBox(width: 8),
            BotaoPequeno(l.cancelar, aoTocar: () => Navigator.of(ctx).pop(), secundario: true),
          ]),
        ],
      ),
    );
  }

  void _editarFlag(Linha f) {
    final l = AppLocalizations.of(context);
    var free = f['free'] == true;
    var pro = f['pro'] == true;
    var familia = f['familia'] == true;
    final limFree = TextEditingController(text: texto(f['limite_free']));
    final limPro = TextEditingController(text: texto(f['limite_pro']));
    final limFamilia = TextEditingController(text: texto(f['limite_familia']));
    folhaLateral<void>(
      context,
      titulo: '${l.admRgFlagEditar} · ${texto(f['chave'])}',
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => ListView(
          children: [
            Text(texto(f['descricao']), style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 12),
            SwitchListTile(value: free, onChanged: (v) => setS(() => free = v), title: Text(l.admRgFlagFree)),
            SwitchListTile(value: pro, onChanged: (v) => setS(() => pro = v), title: Text(l.admRgFlagPro)),
            SwitchListTile(value: familia, onChanged: (v) => setS(() => familia = v), title: Text(l.admRgFlagFamilia)),
            const SizedBox(height: 12),
            CampoAdmin(controlador: limFree, rotulo: l.admRgFlagLimFree, ajuda: l.admRgFlagLimiteAjuda, tipo: TextInputType.number),
            CampoAdmin(controlador: limPro, rotulo: l.admRgFlagLimPro, ajuda: l.admRgFlagLimiteAjuda, tipo: TextInputType.number),
            CampoAdmin(controlador: limFamilia, rotulo: l.admRgFlagLimFamilia, ajuda: l.admRgFlagLimiteAjuda, tipo: TextInputType.number),
            const SizedBox(height: 12),
            Row(children: [
              BotaoPequeno(l.admSalvar, icone: Icons.save_rounded, aoTocar: () async {
                final depois = <String, dynamic>{
                  'free': free,
                  'pro': pro,
                  'familia': familia,
                  'limite_free': int.tryParse(limFree.text.trim()),
                  'limite_pro': int.tryParse(limPro.text.trim()),
                  'limite_familia': int.tryParse(limFamilia.text.trim()),
                };
                await _guardar(() => widget.dados.guardarFlag(f, depois));
              }),
              const SizedBox(width: 8),
              BotaoPequeno(l.cancelar, aoTocar: () => Navigator.of(ctx).pop(), secundario: true),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  final bool ok;
  const _Check(this.ok);
  @override
  Widget build(BuildContext context) =>
      Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 20, color: ok ? AppColors.emDia : AppColors.textSubtle);
}
