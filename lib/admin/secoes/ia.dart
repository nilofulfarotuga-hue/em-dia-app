// Secção 5 — IA: perguntas mais feitas (RPC admin_ia_top_perguntas), as que
// ficaram fora das regras (candidatas a guia), custo por dia (v_custo_ia_diario).
// "Criar guia" cria um rascunho em guias (publicado=false).
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class IaSeccao extends StatefulWidget {
  final AdminDados dados;
  const IaSeccao({super.key, required this.dados});

  @override
  State<IaSeccao> createState() => _IaSeccaoState();
}

class _IaSeccaoState extends State<IaSeccao> {
  late Future<List<Linha>> _top;
  late Future<List<Linha>> _fora;
  late Future<List<Linha>> _custo;

  @override
  void initState() {
    super.initState();
    _ler();
  }

  void _ler() {
    _top = widget.dados.topPerguntas();
    _fora = widget.dados.foraDasRegras();
    _custo = widget.dados.custoIaPorDia();
  }

  void _recarregar() => setState(_ler);

  Future<void> _criarGuia(String pergunta) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmar(context, titulo: l.admIaCriarGuia, texto: '${l.admIaGuiaConfirma}\n\n"$pergunta"');
    if (!ok) return;
    try {
      final slug = await widget.dados.criarGuia(pergunta);
      if (mounted) avisar(context, l.admIaGuiaCriado(slug));
    } catch (e) {
      if (mounted) await mostrarErro(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admIaTitulo,
      subtitulo: l.admIaSub,
      acoes: [BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true)],
      children: [
        Leitura<List<Linha>>(
          future: _top,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          textoVazio: l.admIaVazio,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admIaTop,
            colunas: [l.admIaColPergunta, l.admIaColVezes, l.admIaColFora, l.admIaColBr, l.admIaColUltima, ''],
            linhas: [
              for (final p in lista)
                DataRow(cells: [
                  celula(texto(p['pergunta']), max: 70),
                  celula(texto(p['n']), estilo: const TextStyle(fontWeight: FontWeight.w700)),
                  celula(texto(p['fora_das_regras'])),
                  celula(texto(p['variante_br'])),
                  celula(dataHoraPt(lerData(p['ultima']))),
                  DataCell(BotaoPequeno(l.admIaCriarGuia, icone: Icons.menu_book_rounded, aoTocar: () => _criarGuia(texto(p['pergunta'])), secundario: true)),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Leitura<List<Linha>>(
          future: _fora,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          textoVazio: l.admIaForaVazio,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admIaFora(lista.length),
            colunas: [l.admIaColUltima, l.admIaColVariante, l.admIaColPergunta, l.admIaColResposta, ''],
            linhas: [
              for (final c in lista)
                DataRow(cells: [
                  celula(dataHoraPt(lerData(c['criado_em']))),
                  DataCell(Pilula(texto(c['variante']))),
                  celula(texto(c['pergunta']), max: 60),
                  celula(texto(c['resposta']), max: 50),
                  DataCell(BotaoPequeno(l.admIaCriarGuia, icone: Icons.menu_book_rounded, aoTocar: () => _criarGuia(texto(c['pergunta'])), secundario: true)),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Leitura<List<Linha>>(
          future: _custo,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admIaCusto,
            colunas: [l.admIaColDia, l.admIaColConversas, l.admIaColCusto],
            linhas: [
              for (final d in lista)
                DataRow(cells: [
                  celula(dataOuTraco(lerData(d['dia']))),
                  celula(texto(d['conversas'])),
                  celula(moeda(numero(d['custo_eur']) ?? 0, casas: 4, comSimbolo: false)),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}
