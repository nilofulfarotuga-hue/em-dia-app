// Secção «Convites» (2026-09-24): quem convidou quem, prémios dados (30 dias a
// cada um), e os melhores convidadores. Lê as RPCs só-admin admin_convites e
// admin_convites_top; ninguém escreve aqui — o prémio é automático no servidor.
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class ConvitesSeccao extends StatefulWidget {
  final AdminDados dados;
  const ConvitesSeccao({super.key, required this.dados});

  @override
  State<ConvitesSeccao> createState() => _ConvitesSeccaoState();
}

class _ConvitesSeccaoState extends State<ConvitesSeccao> {
  late Future<List<Linha>> _f;
  late Future<List<Linha>> _top;

  @override
  void initState() {
    super.initState();
    _ler();
  }

  void _ler() {
    _f = widget.dados.convites();
    _top = widget.dados.convitesTop();
  }

  void _recarregar() => setState(_ler);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admCvTitulo,
      subtitulo: l.admCvSub,
      acoes: [BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true)],
      children: [
        Leitura<List<Linha>>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => _Resumo(lista: lista),
        ),
        const SizedBox(height: 12),
        Leitura<List<Linha>>(
          future: _top,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, top) => TabelaAdmin(
            titulo: l.admCvTop,
            colunas: [l.admCvColConvidador, l.admCvColCodigo, l.admCvColConvidados, l.admCvColPremiados, l.admCvColMeses],
            linhas: [
              for (final r in top)
                DataRow(cells: [
                  celula(texto(r['convidador'])),
                  celula(texto(r['codigo'])),
                  celula(texto(r['convidados'])),
                  celula(texto(r['premiados'])),
                  celula(texto(r['meses_ganhos'])),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Leitura<List<Linha>>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admCvTabela(lista.length),
            colunas: [l.admCvColQuando, l.admCvColConvidador, l.admCvColConvidado, l.admCvColEstado, l.admCvColPremio, l.admCvColMotivo],
            linhas: [
              for (final r in lista)
                DataRow(cells: [
                  celula(dataOuTraco(lerData(r['quando']))),
                  celula(texto(r['convidador'])),
                  celula(texto(r['convidado'])),
                  DataCell(Pilula(texto(r['estado']), texto: rotuloEstadoConvite(l, texto(r['estado'])))),
                  celula(premioTexto(l, r)),
                  celula(texto(r['motivo']), max: 40),
                ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Aviso(l.admCvNota, tom: Semaforo.amarelo),
      ],
    );
  }
}

class _Resumo extends StatelessWidget {
  final List<Linha> lista;
  const _Resumo({required this.lista});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final premiados = lista.where((r) => r['estado'] == 'premiado').length;
    final pendentes = lista.where((r) => r['estado'] == 'pendente').length;
    final cartoes = <Widget>[
      CartaoNumero(rotulo: l.admCvCardConvites, valor: '${lista.length}', icone: Icons.group_add_rounded),
      CartaoNumero(rotulo: l.admCvCardPremiados, valor: '$premiados', icone: Icons.card_giftcard_rounded, cor: AppColors.info),
      CartaoNumero(rotulo: l.admCvCardPendentes, valor: '$pendentes', icone: Icons.hourglass_top_rounded),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 12.0;
        final colunas = c.maxWidth >= 600 ? 3 : 1;
        final w = (c.maxWidth - gap * (colunas - 1)) / colunas;
        return Wrap(spacing: gap, runSpacing: gap, children: [for (final x in cartoes) SizedBox(width: w, child: x)]);
      },
    );
  }
}

String rotuloEstadoConvite(AppLocalizations l, String estado) => switch (estado) {
      'premiado' => l.admCvEstPremiado,
      'pendente' => l.admCvEstPendente,
      'anulado' => l.admCvEstAnulado,
      _ => estado,
    };

/// «convidador + convidado», «só convidado» ou «—».
String premioTexto(AppLocalizations l, Linha r) {
  final a = r['premio_convidador'] == true;
  final b = r['premio_convidado'] == true;
  if (a && b) return l.admCvPremioAmbos;
  if (b) return l.admCvPremioSoConvidado;
  return '—';
}
