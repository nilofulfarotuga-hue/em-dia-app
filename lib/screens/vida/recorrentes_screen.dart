import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/movimento_banco.dart';
import '../../models/saida.dart';
import '../../regras/extrato_banco.dart';
import '../../regras/regras.dart';
import '../../stores/banco_store.dart';
import '../../stores/saidas_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import 'importar_extrato_screen.dart';

/// «Coisas que se repetem» (B2c): o que o extrato mostra a sair todos os meses
/// com o mesmo nome e mais ou menos o mesmo valor — assinaturas, débitos
/// diretos, ginásio, telemóvel. Em cima, «pagas X por mês em coisas que se
/// repetem»; em cada uma, «como cancelar» com o caminho do operador e o botão
/// que a transforma numa conta da app (para os avisos da véspera, D34).
class RecorrentesScreen extends StatefulWidget {
  final DateTime? hoje;
  const RecorrentesScreen({super.key, this.hoje});

  @override
  State<RecorrentesScreen> createState() => _RecorrentesScreenState();
}

class _RecorrentesScreenState extends State<RecorrentesScreen> {
  final Set<String> _aTrabalhar = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final banco = context.read<BancoStore>();
      final userId = context.read<SessaoStore>().userId;
      if (userId != null && !banco.temDados && !banco.aCarregar) banco.carregar(userId);
    });
  }

  /// Transforma uma coisa que se repete numa conta da app (`saidas`), com
  /// débito direto: a partir daqui a app avisa na véspera.
  Future<void> _criarConta(Recorrente r) async {
    final l = AppLocalizations.of(context);
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) return;
    final saidas = context.read<SaidasStore>();
    final banco = context.read<BancoStore>();
    final mensageiro = ScaffoldMessenger.of(context);
    setState(() => _aTrabalhar.add(r.chave));
    final categoria = categoriasSaida.contains(r.categoria) ? r.categoria : 'outro';
    final guardada = await saidas.guardar(Saida(
      id: '',
      userId: userId,
      nome: r.fornecedor ?? r.nome,
      categoria: categoria,
      valor: r.valorMedio,
      diaDoMes: r.diaHabitual.clamp(1, 28),
      meio: 'debito_direto',
      fornecedor: r.fornecedor,
      notas: l.recorrentesNotaConta,
    ));
    if (guardada != null) await banco.ligarSaida(userId, r, guardada.id);
    if (!mounted) return;
    setState(() => _aTrabalhar.remove(r.chave));
    mensageiro.showSnackBar(SnackBar(content: Text(guardada == null ? l.erroRede : l.recorrentesContaCriada)));
  }

  Future<void> _abrir(String url) async {
    final l = AppLocalizations.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok) mensageiro.showSnackBar(SnackBar(content: Text(l.erroRede)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final banco = context.watch<BancoStore>();
    final saidas = context.watch<SaidasStore>();
    final lista = banco.recorrentes;
    final total = totalMensalRecorrente(lista);
    final ligadas = saidas.todas.map((s) => s.id).toSet();
    final movimentosLigados = banco.movimentos.where((m) => m.saidaId != null && ligadas.contains(m.saidaId)).map((m) => normalizarDescricao(m.descricao)).toSet();

    return Scaffold(
      appBar: AppBar(title: Text(l.recorrentesTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          if (banco.aCarregar && !banco.temDados)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (banco.movimentos.isEmpty) ...[
            Vazio(
              icone: Icons.repeat_rounded,
              texto: l.recorrentesVazio,
              acao: BotaoGrande(
                texto: l.importarTitulo,
                icone: Icons.upload_file_rounded,
                aoTocar: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportarExtratoScreen())),
              ),
            ),
          ] else ...[
            Cartao(
              cor: AppColors.emDiaClaro,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lista.isEmpty ? l.recorrentesNenhuma : l.recorrentesTotal(moeda(total)), style: t.headlineSmall!.copyWith(color: AppColors.primaryDeep)),
                  const SizedBox(height: 6),
                  Text(l.recorrentesExplica, style: t.bodyMedium),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: BotaoOuvir(etiqueta: 'recorrentes', texto: '${lista.isEmpty ? l.recorrentesNenhuma : l.recorrentesTotal(moeda(total))} ${l.recorrentesExplica}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            for (final r in lista) ...[
              _CartaoRecorrente(
                r: r,
                operador: OperadorCancelar.para(banco.operadores, fornecedor: r.fornecedor, descricao: r.nome) ?? OperadorCancelar.generico(banco.operadores),
                jaEhConta: movimentosLigados.contains(r.chave),
                aTrabalhar: _aTrabalhar.contains(r.chave),
                aoCriarConta: () => _criarConta(r),
                aoAbrir: _abrir,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
            BotaoGrande(
              texto: l.importarEscolherOutro,
              icone: Icons.upload_file_rounded,
              secundario: true,
              aoTocar: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ImportarExtratoScreen())),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartaoRecorrente extends StatefulWidget {
  final Recorrente r;
  final OperadorCancelar? operador;
  final bool jaEhConta;
  final bool aTrabalhar;
  final VoidCallback aoCriarConta;
  final ValueChanged<String> aoAbrir;
  const _CartaoRecorrente({
    required this.r,
    required this.operador,
    required this.jaEhConta,
    required this.aTrabalhar,
    required this.aoCriarConta,
    required this.aoAbrir,
  });

  @override
  State<_CartaoRecorrente> createState() => _CartaoRecorrenteState();
}

class _CartaoRecorrenteState extends State<_CartaoRecorrente> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = widget.r;
    final op = widget.operador;
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.fornecedor ?? r.nome, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(l.recorrentesVezes(r.vezes, r.diaHabitual), style: t.bodySmall),
                  ],
                ),
              ),
              Text('${moeda(r.valorMedio)} ${l.onbPorMes}', style: t.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _aberto = !_aberto),
                  icon: Icon(_aberto ? Icons.expand_less_rounded : Icons.help_outline_rounded, size: 20),
                  label: Text(l.recorrentesComoCancelar),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: widget.jaEhConta
                    ? Etiqueta(l.recorrentesJaEhConta, cor: AppColors.emDiaClaro, corTexto: AppColors.primaryDark, icone: Icons.notifications_active_outlined)
                    : FilledButton.tonalIcon(
                        onPressed: widget.aTrabalhar ? null : widget.aoCriarConta,
                        icon: const Icon(Icons.notifications_active_outlined, size: 20),
                        label: Text(l.recorrentesAvisar),
                      ),
              ),
            ],
          ),
          if (_aberto) ...[
            const SizedBox(height: 12),
            Text(op?.comoCancelar ?? l.recorrentesSemOperador, style: t.bodyMedium),
            if (op?.url != null) ...[
              const SizedBox(height: 8),
              BotaoGrande(texto: l.recorrentesAbrirPagina(op!.nome), icone: Icons.open_in_new_rounded, secundario: true, aoTocar: () => widget.aoAbrir(op.url!)),
            ],
            if (op?.telefone != null) ...[
              const SizedBox(height: 6),
              Text(l.recorrentesTelefone(op!.telefone!), style: t.bodySmall),
            ],
          ],
        ],
      ),
    );
  }
}
