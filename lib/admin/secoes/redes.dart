// Secção «Redes Em Dia» (2026-09-24, ordem do Danilo): o que o robô diário da VPS
// publicou no Instagram (@em_dia_app) e no Facebook («Em Dia: Recibos e Impostos»),
// o que está agendado e o que falhou (fiscal de vídeo abaixo de 90, erro da Meta…).
// Lê as RPCs só-admin admin_redes_resumo e admin_redes; quem escreve é o robô
// (RPC redes_registar com chave no Vault). Separado das redes do Bora.
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class RedesSeccao extends StatefulWidget {
  final AdminDados dados;
  const RedesSeccao({super.key, required this.dados});

  @override
  State<RedesSeccao> createState() => _RedesSeccaoState();
}

class _RedesSeccaoState extends State<RedesSeccao> {
  late Future<List<Linha>> _f;
  late Future<Linha?> _r;
  String? _filtro; // null = todas | publicada | agendada | falhou | saltada

  @override
  void initState() {
    super.initState();
    _ler();
  }

  void _ler() {
    _f = widget.dados.redes();
    _r = widget.dados.redesResumo();
  }

  void _recarregar() => setState(_ler);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admRdTitulo,
      subtitulo: l.admRdSub,
      acoes: [
        BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true),
      ],
      children: [
        Leitura<Linha?>(
          future: _r,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x == null,
          builder: (context, r) => _Resumo(resumo: r!),
        ),
        const SizedBox(height: 12),
        ChipsFiltro<String>(
          opcoes: [
            (null, l.admRdTodas),
            for (final e in const ['publicada', 'agendada', 'falhou', 'saltada']) (e, rotuloEstadoRede(l, e)),
          ],
          valor: _filtro,
          aoMudar: (v) => setState(() => _filtro = v),
        ),
        const SizedBox(height: 12),
        Leitura<List<Linha>>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => _Tabela(lista: filtrarRedes(lista, _filtro)),
        ),
        const SizedBox(height: 12),
        Aviso(l.admRdNota, tom: Semaforo.amarelo),
      ],
    );
  }
}

class _Resumo extends StatelessWidget {
  final Linha resumo;
  const _Resumo({required this.resumo});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cartoes = <Widget>[
      CartaoNumero(rotulo: l.admRdPub7, valor: texto(resumo['publicadas_7d']), icone: Icons.check_circle_rounded, cor: AppColors.info),
      CartaoNumero(rotulo: l.admRdAgend, valor: texto(resumo['agendadas']), icone: Icons.schedule_rounded),
      CartaoNumero(rotulo: l.admRdFalh7, valor: texto(resumo['falhadas_7d']), icone: Icons.error_rounded, cor: AppColors.cadeado),
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

class _Tabela extends StatelessWidget {
  final List<Linha> lista;
  const _Tabela({required this.lista});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (lista.isEmpty) return Aviso(l.admRdVazio, tom: Semaforo.amarelo);
    return TabelaAdmin(
      titulo: l.admRdTabela(lista.length),
      colunas: [
        l.admRdColQuando,
        l.admRdColPeca,
        l.admRdColFormato,
        l.admRdColRede,
        l.admRdColEstado,
        l.admRdColFiscal,
        l.admRdColLink,
        l.admRdColErro,
      ],
      linhas: [
        for (final r in lista)
          DataRow(
            cells: [
              celula(dataOuTraco(lerData(r['publicada_em'] ?? r['agendada_para']))),
              celula(texto(r['peca'])),
              celula(texto(r['formato'])),
              celula(texto(r['rede'])),
              DataCell(Pilula(texto(r['estado']), texto: rotuloEstadoRede(l, texto(r['estado'])))),
              celula(r['nota_fiscal'] == null ? '—' : '${r['nota_fiscal']}/100'),
              celula(texto(r['link']), max: 60),
              celula(texto(r['erro']), max: 60),
            ],
          ),
      ],
    );
  }
}

/// Rótulo PT-BR de cada estado (o robô grava em código).
String rotuloEstadoRede(AppLocalizations l, String estado) => switch (estado) {
      'publicada' => l.admRdEstPublicada,
      'agendada' => l.admRdEstAgendada,
      'falhou' => l.admRdEstFalhou,
      'saltada' => l.admRdEstSaltada,
      _ => estado,
    };

/// Filtro por estado (null = todas).
List<Linha> filtrarRedes(List<Linha> todas, String? estado) =>
    estado == null ? todas : todas.where((r) => r['estado'] == estado).toList();
