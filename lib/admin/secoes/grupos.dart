// Bloco «Grupos do Facebook» dentro da secção Redes (2026-09-28, missão emdia-redes-2026-09-28, E2).
// A lista vive na VPS (grupos_emdia_estado.json) e é espelhada na tabela grupos_divulgacao pelo
// grupos_emdia_sync.py. Aqui só se lê e se pausa (um grupo ou tudo) — RPCs só-admin admin_grupos,
// admin_grupos_resumo e admin_grupos_pausar (esta fica no admin_audit_log). Nada aqui adere nem
// publica: isso acontece um a um, depois do «sim» do Danilo.
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class GruposBloco extends StatefulWidget {
  final AdminDados dados;
  const GruposBloco({super.key, required this.dados});

  @override
  State<GruposBloco> createState() => _GruposBlocoState();
}

class _GruposBlocoState extends State<GruposBloco> {
  late Future<List<Linha>> _f;
  late Future<Linha?> _r;
  String? _filtro; // null = todos | candidato | pedido | aceite | publicado | proibe

  @override
  void initState() {
    super.initState();
    _ler();
  }

  void _ler() {
    _f = widget.dados.grupos();
    _r = widget.dados.gruposResumo();
  }

  void _recarregar() => setState(_ler);

  Future<void> _pausar(String? link, bool pausado) async {
    final l = AppLocalizations.of(context);
    if (link == null && pausado) {
      final ok = await confirmar(context, titulo: l.admGrPausarTudo, texto: l.admGrConfirmarTudo, perigo: true);
      if (!ok || !mounted) return;
    }
    try {
      await widget.dados.pausarGrupos(link, pausado);
      if (!mounted) return;
      avisar(context, l.admGrFeito);
      _recarregar();
    } catch (e) {
      if (mounted) await mostrarErro(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.admGrTitulo, style: t.titleLarge),
        const SizedBox(height: 4),
        Text(l.admGrSub, style: t.bodyMedium),
        const SizedBox(height: 12),
        Leitura<Linha?>(
          future: _r,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x == null,
          builder: (context, r) => _Resumo(resumo: r!, aoPausarTudo: (p) => _pausar(null, p)),
        ),
        const SizedBox(height: 12),
        ChipsFiltro<String>(
          opcoes: [
            (null, l.admGrTodos),
            for (final e in const ['candidato', 'pedido', 'aceite', 'publicado', 'proibe']) (e, rotuloEstadoGrupo(l, e)),
          ],
          valor: _filtro,
          aoMudar: (v) => setState(() => _filtro = v),
        ),
        const SizedBox(height: 12),
        Leitura<List<Linha>>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => _Tabela(
            lista: filtrarGrupos(lista, _filtro),
            aoPausar: (link, p) => _pausar(link, p),
          ),
        ),
      ],
    );
  }
}

class _Resumo extends StatelessWidget {
  final Linha resumo;
  final void Function(bool pausado) aoPausarTudo;
  const _Resumo({required this.resumo, required this.aoPausarTudo});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tudo = resumo['pausado_tudo'] == true;
    final aviso = texto(resumo['ultimo_aviso']);
    final cartoes = <Widget>[
      CartaoNumero(rotulo: l.admGrTotal, valor: texto(resumo['total']), icone: Icons.groups_rounded),
      CartaoNumero(rotulo: l.admGrPedidos, valor: texto(resumo['pedidos']), icone: Icons.hourglass_top_rounded),
      CartaoNumero(rotulo: l.admGrAceites, valor: texto(resumo['aceites']), icone: Icons.check_circle_rounded, cor: AppColors.info),
      CartaoNumero(rotulo: l.admGrPub7, valor: texto(resumo['publicacoes_7d']), icone: Icons.campaign_rounded),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            const gap = 12.0;
            final colunas = c.maxWidth >= 800 ? 4 : (c.maxWidth >= 500 ? 2 : 1);
            final w = (c.maxWidth - gap * (colunas - 1)) / colunas;
            return Wrap(spacing: gap, runSpacing: gap, children: [for (final x in cartoes) SizedBox(width: w, child: x)]);
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l.admGrTecto(texto(resumo['tecto_hoje']).isEmpty ? '—' : texto(resumo['tecto_hoje']), texto(resumo['dias_limpos']).isEmpty ? '0' : texto(resumo['dias_limpos']))),
            tudo
                ? BotaoPequeno(l.admGrRetomarTudo, icone: Icons.play_arrow_rounded, aoTocar: () => aoPausarTudo(false))
                : BotaoPequeno(l.admGrPausarTudo, icone: Icons.pause_rounded, aoTocar: () => aoPausarTudo(true), secundario: true, perigo: true),
          ],
        ),
        if (tudo) ...[const SizedBox(height: 12), Aviso(l.admGrTudoPausado, tom: Semaforo.vermelho)],
        if (aviso.isNotEmpty) ...[const SizedBox(height: 12), Aviso(l.admGrUltimoAviso(aviso), tom: Semaforo.amarelo)],
      ],
    );
  }
}

class _Tabela extends StatelessWidget {
  final List<Linha> lista;
  final void Function(String link, bool pausado) aoPausar;
  const _Tabela({required this.lista, required this.aoPausar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (lista.isEmpty) return Aviso(l.admGrVazio, tom: Semaforo.amarelo);
    return TabelaAdmin(
      titulo: l.admGrTabela(lista.length),
      colunas: [
        l.admGrColNome,
        l.admGrColSegmento,
        l.admGrColDistrito,
        l.admGrColMembros,
        l.admGrColEstado,
        l.admGrColPromo,
        l.admGrColUltima,
        l.admGrColAcao,
      ],
      linhas: [
        for (final g in lista)
          DataRow(
            cells: [
              celula(texto(g['nome']), max: 42),
              celula(texto(g['segmento'])),
              celula(texto(g['distrito'])),
              celula(texto(g['membros'])),
              DataCell(g['pausado'] == true
                  ? Pilula('erro', texto: l.admGrPausadoEtiqueta)
                  : Pilula(corDoEstadoGrupo(texto(g['estado'])), texto: rotuloEstadoGrupo(l, texto(g['estado'])))),
              celula(rotuloPromo(l, texto(g['permite_publicidade']))),
              celula(dataOuTraco(lerData(g['ultima_publicacao_em']))),
              DataCell(g['pausado'] == true
                  ? BotaoPequeno(l.admGrRetomar, aoTocar: () => aoPausar(texto(g['link']), false), secundario: true)
                  : BotaoPequeno(l.admGrPausar, aoTocar: () => aoPausar(texto(g['link']), true), secundario: true, perigo: true)),
            ],
          ),
      ],
    );
  }
}

/// Rótulo PT-BR de cada estado (a VPS grava em código).
String rotuloEstadoGrupo(AppLocalizations l, String estado) => switch (estado) {
      'candidato' => l.admGrEstCandidato,
      'pedido' => l.admGrEstPedido,
      'aceite' => l.admGrEstAceite,
      'publicado' => l.admGrEstPublicado,
      'proibe' => l.admGrEstProibe,
      _ => estado,
    };

/// Estado do grupo -> chave de cor do [corEstado] do painel.
String corDoEstadoGrupo(String estado) => switch (estado) {
      'pedido' => 'pendente',
      'aceite' || 'publicado' => 'ok',
      'proibe' => 'erro',
      _ => estado,
    };

String rotuloPromo(AppLocalizations l, String v) => switch (v) {
      'sim' => l.admGrPromoSim,
      'nao' => l.admGrPromoNao,
      _ => l.admGrPromoPorConfirmar,
    };

/// Filtro por estado (null = todos).
List<Linha> filtrarGrupos(List<Linha> todos, String? estado) =>
    estado == null ? todos : todos.where((g) => g['estado'] == estado).toList();
