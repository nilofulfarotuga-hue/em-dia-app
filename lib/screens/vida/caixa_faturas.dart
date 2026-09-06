import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fatura_recebida.dart';
import '../../regras/regras.dart';
import '../../services/leitor_documento.dart';
import '../../stores/caixa_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import 'nova_saida.dart';

/// A caixa de correio das faturas (decisão D24).
///
/// A app **não** pede a palavra-passe do e-mail a ninguém e não liga à API do
/// Gmail. Cada pessoa tem aqui um endereço só dela, e reencaminha para lá as
/// faturas que já lhe chegam. É a diferença entre "dá-me as chaves da tua
/// caixa" e "manda-me o que quiseres que eu trate".
///
/// Enquanto o domínio não existir, a caixa está desligada — e o ecrã diz isso,
/// em vez de mostrar um endereço que não recebe nada. Quem manda é o servidor
/// (`minha_caixa_de_faturas` devolve `ligada`), não o telemóvel.
class CaixaFaturasScreen extends StatefulWidget {
  /// Só para fotos/testes: fixa o "hoje".
  final DateTime? hoje;
  const CaixaFaturasScreen({super.key, this.hoje});

  @override
  State<CaixaFaturasScreen> createState() => _CaixaFaturasScreenState();
}

class _CaixaFaturasScreenState extends State<CaixaFaturasScreen> {
  bool _arrancou = false;
  String? _aLer; // id da fatura que está a ser lida

  DateTime get _hoje => widget.hoje ?? hojeLisboa();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_arrancou) return;
    _arrancou = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CaixaStore>().carregarSePreciso();
    });
  }

  void _snack(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final caixa = context.watch<CaixaStore>();
    return Scaffold(
      appBar: AppBar(title: Text(l.caixaTitulo)),
      body: RefreshIndicator(
        onRefresh: () => context.read<CaixaStore>().carregar(),
        child: ListView(
          padding: paddingEcra,
          children: [
            if (caixa.ligada) _CartaoEndereco(endereco: caixa.endereco ?? '') else const _CaixaDesligada(),
            const SizedBox(height: 18),
            if (caixa.erro != null) ...[
              Aviso(l.caixaErroCarregar, tom: Semaforo.vermelho),
              const SizedBox(height: 12),
            ],
            if (caixa.aCarregar && caixa.faturas.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (caixa.faturas.isEmpty)
              Vazio(icone: Icons.mark_email_unread_outlined, texto: l.caixaVazia)
            else ...[
              TituloSeccao(l.caixaPorVer(caixa.porVer)),
              const SizedBox(height: 8),
              for (final f in caixa.faturas)
                _LinhaFatura(
                  fatura: f,
                  aLer: _aLer == f.id,
                  aoAbrir: () => _abrir(f),
                  aoFazerConta: () => _fazerConta(f),
                  aoPorDeLado: () => _porDeLado(f),
                  aoApagar: () => _apagar(f),
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Abre o PDF/foto no telemóvel, por um endereço que morre em 5 minutos.
  Future<void> _abrir(FaturaRecebida f) async {
    final l = AppLocalizations.of(context);
    if (!f.temAnexo) {
      _snack(l.caixaSemAnexo);
      return;
    }
    final url = await context.read<CaixaStore>().enderecoParaAbrir(f);
    if (!mounted) return;
    if (url == null || !await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (mounted) _snack(l.caixaAbrirFalhou);
    }
  }

  /// O atalho que faz esta caixa valer a pena: ler a fatura e abrir a folha da
  /// conta já preenchida. Gasta uma das leituras do mês — por isso é um botão
  /// que a pessoa carrega, e nunca uma coisa que o servidor faz sozinho.
  Future<void> _fazerConta(FaturaRecebida f) async {
    final l = AppLocalizations.of(context);
    final userId = context.read<SessaoStore>().userId;
    final caixa = context.read<CaixaStore>();
    if (userId == null) return;
    if (!f.temAnexo) {
      _snack(l.caixaSemAnexo);
      return;
    }

    setState(() => _aLer = f.id);
    final r = await LeitorDocumento.lerDoBalde(
      balde: 'faturas',
      caminho: f.anexoCaminho!,
      tipoEsperado: 'fatura',
    );
    if (!mounted) return;
    setState(() => _aLer = null);

    if (!r.correu) {
      _snack(switch (r.erro!) {
        ErroLeitura.cadeado => l.valorFotoCadeado,
        ErroLeitura.semServico => l.valorFotoIndisponivel,
        ErroLeitura.fotoGrande => l.valorFotoGrande,
        ErroLeitura.rede => l.erroRede,
        _ => l.valorFotoNaoLi,
      });
      return;
    }

    _snack(l.caixaLida);
    final guardada = await mostrarNovaSaida(
      context,
      userId: userId,
      hoje: _hoje,
      lido: r.documento,
      aoGuardar: (s) => caixa.marcarLigada(f, s.id),
    );
    if (guardada == true && mounted) _snack(l.saidasContaGuardada);
  }

  Future<void> _porDeLado(FaturaRecebida f) async {
    final l = AppLocalizations.of(context);
    final ok = await context.read<CaixaStore>().ignorar(f);
    if (mounted && ok) _snack(l.caixaPostaDeLado);
  }

  Future<void> _apagar(FaturaRecebida f) async {
    final l = AppLocalizations.of(context);
    final sim = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: Text(l.caixaApagarPergunta),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancelar)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.apagar)),
        ],
      ),
    );
    if (sim != true || !mounted) return;
    final ok = await context.read<CaixaStore>().apagar(f);
    if (mounted && ok) _snack(l.caixaApagada);
  }
}

/// O endereço da pessoa, para copiar. É a única coisa desta tela que ela tem
/// mesmo de fazer: copiar isto e colar no reencaminhamento do seu e-mail.
class _CartaoEndereco extends StatelessWidget {
  final String endereco;
  const _CartaoEndereco({required this.endereco});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      cor: AppColors.infoClaro,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.caixaOTeuEndereco, style: t.labelLarge!.copyWith(color: AppColors.info)),
          const SizedBox(height: 8),
          SelectableText(
            endereco,
            key: const Key('caixa_endereco'),
            style: t.titleMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          BotaoGrande(
            key: const Key('caixa_copiar'),
            texto: l.caixaCopiar,
            icone: Icons.copy_rounded,
            secundario: true,
            aoTocar: () async {
              await Clipboard.setData(ClipboardData(text: endereco));
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(l.caixaCopiado)));
              }
            },
          ),
          const SizedBox(height: 6),
          // O endereço tem oito letras ao acaso: lido de seguida não se percebe
          // nada, por isso vai letra a letra.
          BotaoOuvir(
            etiqueta: 'caixa-$endereco',
            texto: '${l.caixaOTeuEndereco}: ${endereco.split('').join(' ')}',
          ),
          const SizedBox(height: 10),
          Text(l.caixaComoFunciona, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

/// Sem domínio não há endereço. Diz-se, em vez de mostrar um que não recebe.
class _CaixaDesligada extends StatelessWidget {
  const _CaixaDesligada();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_empty_rounded, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(child: Text(l.caixaDesligadaTitulo, style: t.titleMedium)),
            ],
          ),
          const SizedBox(height: 8),
          Text(l.caixaDesligadaTexto, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _LinhaFatura extends StatelessWidget {
  final FaturaRecebida fatura;
  final bool aLer;
  final VoidCallback aoAbrir;
  final VoidCallback aoFazerConta;
  final VoidCallback aoPorDeLado;
  final VoidCallback aoApagar;

  const _LinhaFatura({
    required this.fatura,
    required this.aLer,
    required this.aoAbrir,
    required this.aoFazerConta,
    required this.aoPorDeLado,
    required this.aoApagar,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final (rotulo, cor) = switch (fatura.estado) {
      'ligada' => (l.caixaEstadoLigada, AppColors.emDia),
      'ignorada' => (l.caixaEstadoIgnorada, AppColors.textSecondary),
      'falhou' => (l.caixaEstadoFalhou, AppColors.passou),
      _ => (l.caixaEstadoNova, AppColors.info),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Cartao(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    fatura.assunto?.trim().isNotEmpty == true
                        ? fatura.assunto!
                        : l.caixaSemAssunto,
                    style: t.titleSmall,
                  ),
                ),
                const SizedBox(width: 8),
                Etiqueta(rotulo, cor: cor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${l.caixaDe(fatura.deQuem)} · ${dataPt(fatura.recebidoEm)}',
              style: t.bodySmall!.copyWith(color: AppColors.textSecondary),
            ),
            if (fatura.erro != null) ...[
              const SizedBox(height: 8),
              Text(fatura.erro!, style: t.bodySmall!.copyWith(color: AppColors.passou)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (fatura.temAnexo)
                  TextButton.icon(
                    onPressed: aoAbrir,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(l.caixaAbrir),
                  ),
                if (fatura.temAnexo && fatura.estado != 'ligada')
                  aLer
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(l.caixaALer, style: t.bodySmall),
                            ],
                          ),
                        )
                      : TextButton.icon(
                          key: Key('caixa_fazer_conta_${fatura.id}'),
                          onPressed: aoFazerConta,
                          icon: const Icon(Icons.playlist_add_rounded, size: 18),
                          label: Text(l.caixaFazerConta),
                        ),
                if (fatura.porVer)
                  TextButton(onPressed: aoPorDeLado, child: Text(l.caixaPorDeLado)),
                TextButton(
                  onPressed: aoApagar,
                  child: Text(l.caixaApagar, style: TextStyle(color: AppColors.passou)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
