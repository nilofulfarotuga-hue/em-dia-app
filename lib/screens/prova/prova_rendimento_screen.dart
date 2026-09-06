import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/regras.dart';
import '../../services/prova_rendimento.dart';
import '../../stores/entradas_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import '../plano/plano_screen.dart';
import '../vida/nova_entrada.dart' show nomePlataformaEntrada, rotuloTipoEntrada;

/// Os três períodos. Três chega: menos não prova nada, mais não cabe no ecrã
/// nem na cabeça de quem está a decidir depressa.
const List<int> _periodos = [3, 6, 12];

/// Seis meses é o meio-termo e o que senhorios e bancos costumam pedir.
const int _periodoPorOmissao = 6;

/// O NIF português tem sempre 9 números. Não é uma regra legal com valor (não
/// vem da tabela `regras_legais`), é o formato do campo — como o número de
/// casas de um código postal.
const int _digitosDoNif = 9;

/// A prova de rendimento (invenção 2 de 5).
///
/// Escolhe-se o período, vê-se a média mensal em grande ANTES de gerar seja o
/// que for, e só depois se faz a folha. A ordem importa: quem chega aqui está
/// à espera de um número para dizer ao senhorio, e devolver-lhe esse número em
/// dois toques vale mais do que um PDF que ele ainda não sabe se lhe serve.
class ProvaRendimentoScreen extends StatefulWidget {
  /// Só para fotos e testes: fixa o "hoje".
  final DateTime? hoje;
  const ProvaRendimentoScreen({super.key, this.hoje});

  @override
  State<ProvaRendimentoScreen> createState() => _ProvaRendimentoScreenState();
}

class _ProvaRendimentoScreenState extends State<ProvaRendimentoScreen> {
  int _meses = _periodoPorOmissao;
  bool _aFazer = false;

  final TextEditingController _nome = TextEditingController();
  final TextEditingController _nif = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Depois da primeira pintura, como nos outros ecrãs: mandar notificações a
    // meio de um `build` foi o que já pôs telas a piscar nesta app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // O nome copia-se do perfil UMA só vez. Se ficasse a ouvir o perfil, um
      // carregamento a chegar tarde apagava o que a pessoa já tinha escrito.
      final doPerfil = (context.read<PerfilStore>().perfil?.nome ?? '').trim();
      if (doPerfil.isNotEmpty && _nome.text.isEmpty) _nome.text = doPerfil;

      // O arranque da app não puxa a tabela das entradas — quem a precisa é
      // este ecrã (e a aba "Entra").
      final userId = context.read<SessaoStore>().userId;
      if (userId != null) context.read<EntradasStore>().carregarSePreciso(userId);
    });
  }

  @override
  void dispose() {
    _nome.dispose();
    _nif.dispose();
    super.dispose();
  }

  void _snack(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final entradas = context.watch<EntradasStore>();
    final plano = context.watch<PlanoStore>();
    final hoje = widget.hoje ?? hojeLisboa();

    final dados = ProvaRendimento.contar(
      entradas: entradas.itens,
      meses: _meses,
      hoje: hoje,
    );
    final trancado = !plano.permitida('prova_rendimento');
    final semNada = entradas.itens.isEmpty;

    // O que o botão de ouvir lê. É o mesmo que os olhos veem, pela mesma ordem.
    final falado = [
      l.provaTitulo,
      l.provaSubtitulo,
      if (dados.podeFazer) '${l.provaMediaRotulo}: ${moeda(dados.mediaMensal)}',
      if (dados.podeFazer) '${l.provaTotalRotulo}: ${moeda(dados.total)}',
      if (!semNada && dados.mesesEmFalta > 0) l.provaFaltam(dados.mesesEmFalta),
      if (semNada) l.provaVazio,
    ].join('. ');

    return Scaffold(
      appBar: AppBar(title: Text(l.provaTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(l.provaSubtitulo, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
          BotaoOuvir(etiqueta: 'prova-rendimento', texto: falado),
          TituloSeccao(l.provaEscolhePeriodo),
          Row(
            children: [
              for (final m in _periodos) ...[
                Expanded(
                  child: _BotaoPeriodo(
                    meses: m,
                    escolhido: m == _meses,
                    aoTocar: () => setState(() => _meses = m),
                  ),
                ),
                if (m != _periodos.last) const SizedBox(width: 10),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Cadeado(
            trancado: trancado,
            linha: l.provaCadeadoLinha,
            aoTocar: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => const PlanoScreen())),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (semNada)
                  Cartao(
                    child: Vazio(icone: Icons.description_outlined, texto: l.provaVazio),
                  )
                else if (dados.mesesEmFalta > 0)
                  // O único elemento laranja do ecrã. Quando ele aparece, o
                  // cartão da média não aparece — nunca há dois laranjas.
                  Aviso(l.provaFaltam(dados.mesesEmFalta), tom: Semaforo.amarelo)
                else
                  _CartaoDaMedia(dados: dados),
                const SizedBox(height: 16),
                _CamposDaPessoa(nome: _nome, nif: _nif),
                const SizedBox(height: 16),
                BotaoGrande(
                  key: const Key('prova_fazer'),
                  texto: l.provaBotaoFazer,
                  icone: Icons.picture_as_pdf_rounded,
                  aTrabalhar: _aFazer,
                  aoTocar: dados.podeFazer ? () => _fazer(dados) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // A mesma frase honesta que vai no rodapé do papel. Está aqui de
          // propósito: quem faz a folha tem de saber o que está a entregar,
          // antes de a entregar.
          Text(l.provaPdfHonesto, style: t.bodySmall),
        ],
      ),
    );
  }

  Future<void> _fazer(DadosProva dados) async {
    final l = AppLocalizations.of(context);
    final perfilStore = context.read<PerfilStore>();
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      _snack(l.provaFaltaNome);
      return;
    }

    setState(() => _aFazer = true);
    try {
      final bytes = await ProvaRendimento.folha(
        dados: dados,
        pessoa: PessoaProva(nome: nome, nif: _nif.text.trim()),
        textos: _textos(l, dados),
      );
      final ficheiro = '${l.provaFicheiro}-${_meses}m-${_carimbo(dados.feitaEm)}.pdf';

      if (kIsWeb) {
        // No browser não há folha de partilha do telemóvel. O `printing`
        // descarrega o ficheiro, que é o que o browser sabe fazer.
        await Printing.sharePdf(bytes: bytes, filename: ficheiro);
      } else {
        // `fileNameOverrides` não é enfeite: sem ele o nome do XFile é
        // ignorado no Android e a folha chega com um nome ao acaso.
        await Share.shareXFiles(
          [XFile.fromData(bytes, name: ficheiro, mimeType: 'application/pdf')],
          fileNameOverrides: [ficheiro],
          subject: l.provaPdfTitulo,
        );
      }
      if (!mounted) return;
      _snack(l.provaFeita);

      // Guardar o nome no perfil é só conforto: quem o escreveu uma vez não o
      // deve ter de escrever outra. Fica DEPOIS da folha e sem esperar pelo
      // resultado — se o servidor recusar, a pessoa já tem o que veio buscar.
      final p = perfilStore.perfil;
      if (p != null && (p.nome ?? '').trim() != nome) {
        await perfilStore.guardar(p.copyWith(nome: nome));
      }
    } catch (e) {
      // Uma folha que não sai tem de deixar rasto. Sem esta linha, uma fonte
      // partida ou uma partilha recusada ficavam só num "tenta outra vez" sem
      // causa nenhuma — e quem vier a seguir não tinha por onde pegar.
      debugPrint('prova_rendimento: a folha não saiu ($e)');
      if (mounted) _snack(l.provaErro);
    } finally {
      if (mounted) setState(() => _aFazer = false);
    }
  }

  /// Todos os textos que vão para o papel, já traduzidos. O serviço do PDF não
  /// conhece uma única palavra em português — vêm todas daqui.
  TextosProva _textos(AppLocalizations l, DadosProva d) => TextosProva(
        titulo: l.provaPdfTitulo,
        app: l.appNome,
        rotuloNome: l.provaPdfNome,
        rotuloNif: l.provaPdfNif,
        rotuloPeriodo: l.provaPdfPeriodo,
        periodo: l.provaDeAte(dataExtensoPt(d.inicio), dataExtensoPt(d.fim)),
        rotuloMedia: l.provaPdfMedia,
        ajudaMedia: l.provaPdfMediaAjuda(d.meses.length),
        colunaMes: l.provaPdfColunaMes,
        colunaValor: l.provaPdfColunaValor,
        rotuloTotal: l.provaPdfTotal,
        rotuloOrigem: l.provaPdfOrigem,
        origem: _origem(l, d),
        feitaEm: l.provaPdfFeitaEm(dataPt(d.feitaEm)),
        honesto: l.provaPdfHonesto,
      );

  /// "Recibo verde, App de trabalho (Uber, Bolt)". Os rótulos são os mesmos do
  /// formulário de escrever o que entrou — a pessoa reconhece as palavras.
  String _origem(AppLocalizations l, DadosProva d) {
    final tipos = [
      for (final o in d.origens)
        if (!o.startsWith('plataforma:')) rotuloTipoEntrada(l, o),
    ];
    final apps = [
      for (final o in d.origens)
        if (o.startsWith('plataforma:')) nomePlataformaEntrada(l, o.substring('plataforma:'.length)),
    ];
    final base = tipos.isEmpty ? l.vidaTipoOutro : tipos.join(', ');
    if (apps.isEmpty) return base;
    return '$base (${apps.join(', ')})';
  }

  /// "2026-08" — para o nome do ficheiro. Sem acentos nem espaços, que viajam
  /// mal por WhatsApp e por e-mail.
  String _carimbo(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
}

/// Um dos três períodos. É um [Cartao] tocável, como o [BotaoEscolha], mas
/// deitado: três em linha ocupam a altura de um e deixam o botão principal
/// visível sem scroll.
class _BotaoPeriodo extends StatelessWidget {
  final int meses;
  final bool escolhido;
  final VoidCallback aoTocar;
  const _BotaoPeriodo({required this.meses, required this.escolhido, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      aoTocar: aoTocar,
      cor: escolhido ? AppColors.primaryLight : AppColors.surface,
      bordo: escolhido ? AppColors.primary : AppColors.divider,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Text(
            '$meses',
            style: t.headlineSmall!.copyWith(
              color: escolhido ? AppColors.primaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l.provaMeses,
            textAlign: TextAlign.center,
            style: t.bodySmall!.copyWith(
              color: escolhido ? AppColors.primaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// A média em grande, o total por baixo e nada mais. O número maior do ecrã é
/// o que a pessoa vai dizer em voz alta ao senhorio — é essa a regra.
class _CartaoDaMedia extends StatelessWidget {
  final DadosProva dados;
  const _CartaoDaMedia({required this.dados});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      key: const Key('prova_media'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.provaMediaRotulo, style: t.labelSmall),
          const SizedBox(height: 2),
          Text(
            moeda(dados.mediaMensal),
            style: t.displayMedium!.copyWith(color: AppColors.primaryDeep),
          ),
          Text(
            l.provaMediaAjuda(dados.meses.length),
            style: t.bodySmall!.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          LinhaValor(l.provaTotalRotulo, moeda(dados.total)),
          Text(
            l.provaDeAte(dataExtensoPt(dados.inicio), dataExtensoPt(dados.fim)),
            style: t.bodySmall!.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Nome e NIF. Não vêm do servidor porque `profiles` não tem coluna de NIF; o
/// nome vem do perfil quando lá está, e volta para lá quando a folha sai.
class _CamposDaPessoa extends StatelessWidget {
  final TextEditingController nome;
  final TextEditingController nif;
  const _CamposDaPessoa({required this.nome, required this.nif});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('prova_nome'),
          controller: nome,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l.provaNomeCampo),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('prova_nif'),
          controller: nif,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(_digitosDoNif),
          ],
          decoration: InputDecoration(
            labelText: l.provaNifCampo,
            helperText: l.provaNifAjuda,
            // Sem isto, a ajuda fica numa linha só e o InputDecoration corta-a
            // em silêncio: lia-se "Podes deixar em branco. Com ele, a folha
            // vale mais..." e a parte que interessa nunca aparecia (fábrica de
            // fotos, prova_com_dados_grande_pt).
            helperMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
