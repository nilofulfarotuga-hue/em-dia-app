// Secção 2 — Usuários: lista (v_admin_usuarios), pesquisa, detalhe em folha
// lateral e ações (banir/reativar, plano manual, estender trial, pedir apagar,
// exportar CSV). Cada ação escreve em admin_audit_log.
import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/widgets.dart';
import '../admin_dados.dart';
import '../admin_widgets.dart';

class UsuariosSeccao extends StatefulWidget {
  final AdminDados dados;
  const UsuariosSeccao({super.key, required this.dados});

  @override
  State<UsuariosSeccao> createState() => _UsuariosSeccaoState();
}

class _UsuariosSeccaoState extends State<UsuariosSeccao> {
  final _pesquisa = TextEditingController();
  late Future<List<UsuarioAdmin>> _f;
  List<UsuarioAdmin> _ultima = const [];

  @override
  void initState() {
    super.initState();
    _f = _ler();
  }

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  Future<List<UsuarioAdmin>> _ler() async {
    final r = await widget.dados.usuarios(pesquisa: _pesquisa.text);
    _ultima = r;
    return r;
  }

  void _recarregar() => setState(() => _f = _ler());

  Future<void> _exportar() async {
    final l = AppLocalizations.of(context);
    final csv = widget.dados.usuariosCsv(_ultima);
    await mostrarTextoCopiavel(context, titulo: l.admUsCsvTitulo(_ultima.length), texto: csv, nota: l.admUsCsvNota);
  }

  void _abrir(UsuarioAdmin u) {
    final l = AppLocalizations.of(context);
    folhaLateral<void>(
      context,
      titulo: '${l.admUsDetalhe} · ${u.email ?? u.userId}',
      largura: 640,
      builder: (ctx) => _DetalheUsuario(dados: widget.dados, usuario: u, aoMudar: _recarregar),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PaginaAdmin(
      titulo: l.admUsTitulo,
      subtitulo: l.admUsSub,
      acoes: [
        BotaoPequeno(l.admUsExportar, icone: Icons.download_rounded, aoTocar: _ultima.isEmpty ? null : _exportar, secundario: true),
        BotaoPequeno(l.admAtualizar, icone: Icons.refresh_rounded, aoTocar: _recarregar, secundario: true),
      ],
      children: [
        Cartao(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _pesquisa,
            onSubmitted: (_) => _recarregar(),
            decoration: InputDecoration(
              hintText: l.admUsPesquisa,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
              suffixIcon: IconButton(onPressed: _recarregar, icon: const Icon(Icons.arrow_forward_rounded)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Leitura<List<UsuarioAdmin>>(
          future: _f,
          aoTentarDeNovo: _recarregar,
          vazio: (x) => x.isEmpty,
          builder: (context, lista) => TabelaAdmin(
            titulo: l.admUsTabela(lista.length),
            colunas: [l.admColEmail, l.admColNome, l.admColAtividade, l.admColPlano, l.admColTrialAte, l.admColUltimoAcesso, l.admColEstado, l.admColCriadoEm],
            linhas: [
              for (final u in lista)
                DataRow(
                  onSelectChanged: (_) => _abrir(u),
                  cells: [
                    celula(u.email, max: 36),
                    celula(u.nome, max: 24),
                    celula(u.tipoAtividade),
                    DataCell(Pilula(u.planoEfetivo)),
                    celula(dataOuTraco(u.trialAte)),
                    celula(dataHoraPt(u.ultimoAcesso)),
                    DataCell(Pilula(u.banido ? 'banido' : 'ativa', texto: u.banido ? l.admUsBanido : l.admUsAtivo)),
                    celula(dataOuTraco(u.criadoEm)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetalheUsuario extends StatefulWidget {
  final AdminDados dados;
  final UsuarioAdmin usuario;
  final VoidCallback aoMudar;
  const _DetalheUsuario({required this.dados, required this.usuario, required this.aoMudar});

  @override
  State<_DetalheUsuario> createState() => _DetalheUsuarioState();
}

class _DetalheUsuarioState extends State<_DetalheUsuario> {
  late Future<DetalheUsuario> _f;
  bool _aTrabalhar = false;

  @override
  void initState() {
    super.initState();
    _f = widget.dados.detalheUsuario(widget.usuario.userId);
  }

  Future<void> _executar(Future<void> Function() acao) async {
    final l = AppLocalizations.of(context);
    setState(() => _aTrabalhar = true);
    try {
      await acao();
      widget.aoMudar();
      if (!mounted) return;
      avisar(context, l.admUsFeito);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) await mostrarErro(context, e);
    } finally {
      if (mounted) setState(() => _aTrabalhar = false);
    }
  }

  Future<void> _banir() async {
    final l = AppLocalizations.of(context);
    final u = widget.usuario;
    if (u.banido) return _executar(() => widget.dados.banir(u, false));
    final ok = await confirmar(context, titulo: l.admUsBanir, texto: l.admUsBanirConfirma(u.email ?? u.userId), perigo: true);
    if (ok) await _executar(() => widget.dados.banir(u, true));
  }

  Future<void> _plano() async {
    final l = AppLocalizations.of(context);
    final p = await showDialog<String>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(l.admUsAlterarPlano),
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(24, 0, 24, 8), child: Text(l.admUsPlanoManualNota, style: Theme.of(c).textTheme.bodySmall)),
          for (final o in const ['free', 'pro', 'familia'])
            SimpleDialogOption(onPressed: () => Navigator.of(c).pop(o), child: Row(children: [Pilula(o), const SizedBox(width: 8), Text(o)])),
        ],
      ),
    );
    if (p != null && p != widget.usuario.plano) await _executar(() => widget.dados.alterarPlano(widget.usuario, p));
  }

  Future<void> _trial() async {
    final l = AppLocalizations.of(context);
    final dias = await showDialog<int>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(l.admUsEstenderTrial),
        children: [
          for (final n in const [7, 30, 90])
            SimpleDialogOption(onPressed: () => Navigator.of(c).pop(n), child: Text(l.admUsEstenderDias(n))),
        ],
      ),
    );
    if (dias == null) return;
    final agora = DateTime.now();
    final base = (widget.usuario.trialAte != null && widget.usuario.trialAte!.isAfter(agora)) ? widget.usuario.trialAte! : agora;
    await _executar(() => widget.dados.estenderTrial(widget.usuario, base.add(Duration(days: dias))));
  }

  Future<void> _apagar() async {
    final l = AppLocalizations.of(context);
    final ok = await confirmar(context, titulo: l.admUsApagar, texto: l.admUsApagarConfirma(widget.usuario.email ?? widget.usuario.userId), perigo: true);
    if (ok) await _executar(() => widget.dados.pedirApagarConta(widget.usuario));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final u = widget.usuario;
    return ListView(
      children: [
        Text(l.admUsAcoes, style: t.titleMedium),
        const SizedBox(height: 8),
        Text(l.admUsPlanoAtual(u.plano, u.planoEfetivo), style: t.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            BotaoPequeno(u.banido ? l.admUsReativar : l.admUsBanir,
                icone: u.banido ? Icons.lock_open_rounded : Icons.block_rounded, aoTocar: _aTrabalhar ? null : _banir, perigo: !u.banido, secundario: true),
            BotaoPequeno(l.admUsAlterarPlano, icone: Icons.workspace_premium_rounded, aoTocar: _aTrabalhar ? null : _plano, secundario: true),
            BotaoPequeno(l.admUsEstenderTrial, icone: Icons.more_time_rounded, aoTocar: _aTrabalhar ? null : _trial, secundario: true),
            BotaoPequeno(l.admUsApagar, icone: Icons.delete_forever_rounded, aoTocar: _aTrabalhar ? null : _apagar, perigo: true, secundario: true),
          ],
        ),
        const SizedBox(height: 8),
        Aviso(l.admUsApagarNota, tom: Semaforo.amarelo, icone: Icons.info_outline_rounded),
        const SizedBox(height: 16),
        Leitura<DetalheUsuario>(
          future: _f,
          linhasEsqueleto: 8,
          builder: (context, d) {
            final p = d.perfil;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.admUsPerfil, style: t.titleMedium),
                const SizedBox(height: 6),
                LinhaDetalhe('user_id', texto(p['user_id'])),
                LinhaDetalhe(l.admColEmail, texto(p['email'])),
                LinhaDetalhe(l.admColNome, texto(p['nome'])),
                LinhaDetalhe('telefone', texto(p['telefone'])),
                LinhaDetalhe('tipo_atividade', texto(p['tipo_atividade'])),
                LinhaDetalhe('data_abertura', texto(p['data_abertura'])),
                LinhaDetalhe('regime_iva', texto(p['regime_iva'])),
                LinhaDetalhe('retencao_opcao', texto(p['retencao_opcao'])),
                LinhaDetalhe('rendimento_mensal_estimado', moedaOuTraco(p['rendimento_mensal_estimado'])),
                LinhaDetalhe('variante_pt', texto(p['variante_pt'])),
                LinhaDetalhe('plano', texto(p['plano'])),
                LinhaDetalhe('trial_ate', dataHoraPt(lerData(p['trial_ate']))),
                LinhaDetalhe('onboarding_concluido', texto(p['onboarding_concluido'])),
                LinhaDetalhe('imigrante', texto(p['imigrante'])),
                LinhaDetalhe('banido', texto(p['banido'])),
                LinhaDetalhe('ultimo_acesso', dataHoraPt(lerData(p['ultimo_acesso']))),
                LinhaDetalhe('criado_em', dataHoraPt(lerData(p['criado_em']))),
                const SizedBox(height: 16),
                Text(l.admUsObrigacoes(d.obrigacoes.length), style: t.titleMedium),
                const SizedBox(height: 6),
                if (d.obrigacoes.isEmpty) Text('—', style: t.bodySmall),
                for (final o in d.obrigacoes.take(20))
                  _Linha([
                    Pilula(texto(o['estado'])),
                    Text(texto(o['tipo']), style: t.bodyMedium),
                    Text(dataOuTraco(lerData(o['data_limite'])), style: t.bodySmall),
                    Text(moedaOuTraco(o['valor_estimado']), style: t.bodyMedium),
                  ]),
                const SizedBox(height: 16),
                Text(l.admUsRendimentos(d.rendimentos.length), style: t.titleMedium),
                const SizedBox(height: 6),
                if (d.rendimentos.isEmpty) Text('—', style: t.bodySmall),
                for (final r in d.rendimentos)
                  _Linha([
                    Text(texto(r['mes']).length >= 7 ? texto(r['mes']).substring(0, 7) : texto(r['mes']), style: t.bodyMedium),
                    Text(texto(r['plataforma']), style: t.bodySmall),
                    Text(moedaOuTraco(r['valor_bruto']), style: t.bodyMedium),
                  ]),
                const SizedBox(height: 16),
                Text(l.admUsAssinaturas(d.assinaturas.length), style: t.titleMedium),
                const SizedBox(height: 6),
                if (d.assinaturas.isEmpty) Text('—', style: t.bodySmall),
                for (final a in d.assinaturas)
                  _Linha([
                    Pilula(texto(a['estado'])),
                    Text(texto(a['produto_id']), style: t.bodyMedium),
                    Text(texto(a['plataforma']), style: t.bodySmall),
                    Text(dataOuTraco(lerData(a['renova_em'])), style: t.bodySmall),
                  ]),
                const SizedBox(height: 16),
                Text(l.admUsConversas(d.conversas.length), style: t.titleMedium),
                const SizedBox(height: 6),
                if (d.conversas.isEmpty) Text('—', style: t.bodySmall),
                for (final c in d.conversas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Pilula(texto(c['variante'])),
                          const SizedBox(width: 8),
                          Text(dataHoraPt(lerData(c['criado_em'])), style: t.bodySmall),
                          if (c['fora_das_regras'] == true) ...[const SizedBox(width: 8), const Icon(Icons.flag_rounded, size: 16, color: AppColors.aVencer)],
                        ]),
                        Text(texto(c['pergunta']), style: t.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Linha extends StatelessWidget {
  final List<Widget> filhos;
  const _Linha(this.filhos);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(spacing: 10, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: filhos),
    );
  }
}
