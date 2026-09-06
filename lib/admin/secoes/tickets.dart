// Secção 4 — Tickets de suporte: filtros (estado, escalados), detalhe com
// descrição/logs/resposta da IA, mudar estado, e o contacto do parceiro
// (regras_legais.contacto_parceiro_contabilista).
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class TicketsSeccao extends StatefulWidget {
  final AdminDados dados;
  const TicketsSeccao({super.key, required this.dados});

  @override
  State<TicketsSeccao> createState() => _TicketsSeccaoState();
}

class _TicketsSeccaoState extends State<TicketsSeccao> {
  String? _estado;
  bool _soEscalados = false;
  late Future<List<Linha>> _f;
  late Future<String?> _contacto;
  final _contactoCtl = TextEditingController();
  bool _contactoCarregado = false;

  @override
  void initState() {
    super.initState();
    _ler();
    _contacto = widget.dados.lerContactoParceiro().then((v) {
      if (!_contactoCarregado) {
        _contactoCtl.text = v ?? '';
        _contactoCarregado = true;
      }
      return v;
    });
  }

  @override
  void dispose() {
    _contactoCtl.dispose();
    super.dispose();
  }

  void _ler() => _f = widget.dados.tickets(estado: _estado, escalar: _soEscalados ? true : null);
  void _recarregar() => setState(_ler);

  Future<void> _guardarContacto() async {
    final l = AppLocalizations.of(context);
    try {
      await widget.dados.guardarContactoParceiro(_contactoCtl.text.trim());
      if (mounted) avisar(context, l.admTkParceiroSalvo);
    } catch (e) {
      if (mounted) await mostrarErro(context, e);
    }
  }

  void _abrir(Linha t) {
    final l = AppLocalizations.of(context);
    final id = texto(t['id']);
    folhaLateral<void>(
      context,
      titulo: l.admTkDetalhe(id.length >= 8 ? id.substring(0, 8) : id),
      builder: (ctx) => _DetalheTicket(dados: widget.dados, ticket: t, aoMudar: _recarregar),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return PaginaAdmin(
      titulo: l.admTkTitulo,
      subtitulo: l.admTkSub,
      acoes: [BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true)],
      children: [
        Cartao(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ChipsFiltro<String>(
                opcoes: [(null, l.admTodos), ('aberto', l.admTkEstadoAberto), ('em_curso', l.admTkEstadoEmCurso), ('fechado', l.admTkEstadoFechado)],
                valor: _estado,
                aoMudar: (v) => setState(() {
                  _estado = v;
                  _ler();
                }),
              ),
              FilterChip(
                label: Text(l.admTkEscalados),
                selected: _soEscalados,
                onSelected: (v) => setState(() {
                  _soEscalados = v;
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
            titulo: l.admTkTabela(lista.length),
            colunas: [l.admTkColQuando, l.admTkColTipo, l.admTkColAssunto, l.admTkColEstado, l.admTkColEscalar, l.admTkColUsuario],
            linhas: [
              for (final x in lista)
                DataRow(
                  onSelectChanged: (_) => _abrir(x),
                  cells: [
                    celula(dataHoraPt(lerData(x['criado_em']))),
                    celula(texto(x['tipo'])),
                    celula(texto(x['assunto']), max: 56, estilo: const TextStyle(fontWeight: FontWeight.w600)),
                    DataCell(Pilula(texto(x['estado']))),
                    DataCell(x['escalar_humano'] == true ? Pilula('em_curso', texto: l.admSim) : Text(l.admNao)),
                    celula(texto(x['user_id']), max: 12),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.admTkParceiro, style: t.titleMedium),
              const SizedBox(height: 4),
              Text(l.admTkParceiroAjuda, style: t.bodySmall),
              const SizedBox(height: 12),
              FutureBuilder<String?>(
                future: _contacto,
                builder: (context, snap) {
                  if (snap.hasError) return Aviso(l.admErroLer(snap.error.toString()), tom: Semaforo.vermelho);
                  if (!snap.hasData && snap.connectionState != ConnectionState.done) return const Esqueleto(linhas: 2);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CampoAdmin(controlador: _contactoCtl, rotulo: l.admTkParceiroCampo, linhas: 2),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BotaoPequeno(l.admSalvar, icone: Icons.save_rounded, aoTocar: _guardarContacto),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetalheTicket extends StatefulWidget {
  final AdminDados dados;
  final Linha ticket;
  final VoidCallback aoMudar;
  const _DetalheTicket({required this.dados, required this.ticket, required this.aoMudar});

  @override
  State<_DetalheTicket> createState() => _DetalheTicketState();
}

class _DetalheTicketState extends State<_DetalheTicket> {
  bool _aTrabalhar = false;

  Future<void> _mudar(String estado) async {
    final l = AppLocalizations.of(context);
    setState(() => _aTrabalhar = true);
    try {
      await widget.dados.mudarEstadoTicket(widget.ticket, estado);
      widget.aoMudar();
      if (!mounted) return;
      avisar(context, l.admTkEstadoMudado);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) await mostrarErro(context, e);
    } finally {
      if (mounted) setState(() => _aTrabalhar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final x = widget.ticket;
    return ListView(
      children: [
        Text(texto(x['assunto']), style: t.titleLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Pilula(texto(x['estado'])),
          Pilula('', texto: texto(x['tipo'])),
          if (x['escalar_humano'] == true) Pilula('em_curso', texto: l.admTkColEscalar),
          Text(dataHoraPt(lerData(x['criado_em'])), style: t.bodySmall),
        ]),
        const SizedBox(height: 16),
        Text(l.admTkMudarEstado, style: t.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (e, r) in [('aberto', l.admTkEstadoAberto), ('em_curso', l.admTkEstadoEmCurso), ('fechado', l.admTkEstadoFechado)])
            BotaoPequeno(r, aoTocar: _aTrabalhar || x['estado'] == e ? null : () => _mudar(e), secundario: x['estado'] != e),
        ]),
        const SizedBox(height: 16),
        LinhaDetalhe('id', texto(x['id'])),
        LinhaDetalhe(l.admTkColUsuario, texto(x['user_id'])),
        if (texto(x['motivo_escala']).isNotEmpty) LinhaDetalhe(l.admTkMotivo, texto(x['motivo_escala'])),
        const SizedBox(height: 12),
        Text(l.admTkDescricao, style: t.titleMedium),
        const SizedBox(height: 4),
        SelectableText(texto(x['descricao']).isEmpty ? '—' : texto(x['descricao']), style: t.bodyMedium),
        const SizedBox(height: 12),
        Text(l.admTkRespostaIa, style: t.titleMedium),
        const SizedBox(height: 4),
        SelectableText(texto(x['resposta_ia']).isEmpty ? '—' : texto(x['resposta_ia']), style: t.bodyMedium),
        const SizedBox(height: 12),
        Text(l.admTkLogs, style: t.titleMedium),
        const SizedBox(height: 4),
        SelectableText(texto(x['logs']).isEmpty ? '—' : texto(x['logs']), style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
      ],
    );
  }
}
