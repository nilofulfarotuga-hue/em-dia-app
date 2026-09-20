// Secção Funil (B7a, 2026-09-19): «quantos abrem, acabam o onboarding,
// experimentam e pagam», semana a semana (RPC admin_funil, só admin). Os
// cartões do alto são da semana mais recente; a tabela traz as últimas
// semanas (mais recente primeiro). Os eventos só contam quem ligou as
// «estatísticas de utilização» — as contas e as assinaturas não precisam de
// consentimento, porque são dados da conta.
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';
import '../util/descarregar.dart';

class FunilSeccao extends StatefulWidget {
  final AdminDados dados;
  const FunilSeccao({super.key, required this.dados});

  @override
  State<FunilSeccao> createState() => _FunilSeccaoState();
}

class _FunilSeccaoState extends State<FunilSeccao> {
  late Future<List<Linha>> _f;
  List<Linha> _ultima = const [];

  @override
  void initState() {
    super.initState();
    _ler();
  }

  // A última lista fica guardada para o CSV; o rebuild quando ela chega liga
  // o botão «Baixar CSV» (o mesmo padrão de assinaturas.dart).
  void _ler() => _f = widget.dados.funil().then((x) {
        _ultima = x;
        if (mounted) WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? setState(() {}) : null);
        return x;
      });
  void _recarregar() => setState(_ler);

  Future<void> _exportar() async {
    final l = AppLocalizations.of(context);
    final csv = widget.dados.funilCsv(_ultima);
    const nome = 'funil.csv';
    if (await descarregarTexto(nome: nome, conteudo: csv)) {
      if (mounted) avisar(context, l.admBaixado(nome));
      return;
    }
    if (mounted) await mostrarTextoCopiavel(context, titulo: l.admFuTabela(_ultima.length), texto: csv, nota: l.admUsCsvNota);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admFuTitulo,
      subtitulo: l.admFuSub,
      acoes: [
        BotaoPequeno(l.admBaixarCsv, icone: Icons.download_rounded, aoTocar: _ultima.isEmpty ? null : _exportar, secundario: true),
        BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true),
      ],
      children: [
        Leitura<List<Linha>>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => _ConteudoFunil(lista: lista),
        ),
      ],
    );
  }
}

class _ConteudoFunil extends StatelessWidget {
  final List<Linha> lista;
  const _ConteudoFunil({required this.lista});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ultima = lista.first; // a RPC devolve a semana mais recente primeiro
    final cartoes = <Widget>[
      CartaoNumero(rotulo: l.admFuColContas, valor: texto(ultima['contas_criadas']), icone: Icons.person_add_rounded),
      CartaoNumero(rotulo: l.admFuColOnboarding, valor: texto(ultima['onboarding_concluido']), icone: Icons.how_to_reg_rounded),
      CartaoNumero(rotulo: l.admFuColAbriram, valor: texto(ultima['abriram']), icone: Icons.login_rounded, cor: AppColors.info),
      CartaoNumero(rotulo: l.admFuColTrial, valor: texto(ultima['em_trial']), icone: Icons.hourglass_top_rounded, cor: AppColors.info),
      CartaoNumero(rotulo: l.admFuColPagam, valor: texto(ultima['pagam']), icone: Icons.card_membership_rounded, cor: AppColors.cadeado),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            const gap = 12.0;
            final colunas = c.maxWidth >= 900 ? 5 : (c.maxWidth >= 600 ? 3 : 2);
            final w = (c.maxWidth - gap * (colunas - 1)) / colunas;
            return Wrap(spacing: gap, runSpacing: gap, children: [for (final x in cartoes) SizedBox(width: w, child: x)]);
          },
        ),
        const SizedBox(height: 12),
        TabelaAdmin(
          titulo: l.admFuTabela(lista.length),
          colunas: [
            l.admFuColSemana,
            l.admFuColContas,
            l.admFuColOnboarding,
            l.admFuColAbriram,
            l.admFuColTrial,
            l.admFuColPagam,
            l.admFuColConsentiram,
            l.admFuColEventos,
          ],
          linhas: [
            for (final f in lista)
              DataRow(
                cells: [
                  celula(dataOuTraco(lerData(f['semana']))),
                  celula(texto(f['contas_criadas'])),
                  celula(texto(f['onboarding_concluido'])),
                  celula(texto(f['abriram'])),
                  celula(texto(f['em_trial'])),
                  celula(texto(f['pagam'])),
                  celula(texto(f['consentiram'])),
                  celula(texto(f['eventos_consentidos'])),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),
        Aviso(l.admFuNota, tom: Semaforo.amarelo),
      ],
    );
  }
}
