import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/fala.dart';
import '../../services/ouvir.dart';
import '../../stores/ia_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import '../plano/plano_screen.dart';

/// Etiqueta da voz nesta tela. Tem de ser a MESMA na leitura automática e no
/// [BotaoOuvir], senão o botão não sabe que é ele que está a falar e mostra
/// "Ouvir" enquanto a app já está a ler.
const String _etiquetaResposta = 'fala-resposta';

/// Abaixo disto foi um toque, acima foi um dedo em cima. Meio segundo é o que
/// separa quem toca de quem segura sem que nenhum dos dois tenha de pensar.
const Duration _toqueCurto = Duration(milliseconds: 500);

/// "Fala comigo" — a porta pelo lado de lá.
///
/// Muita gente a quem esta app serve escreve mal e lê pior: imigrantes
/// recém-chegados, quem passou a vida a trabalhar com as mãos, gente de 60
/// anos. Para essas, escrever uma pergunta num telemóvel é uma parede. Aqui
/// carrega-se num botão, fala-se, e a app responde por escrito E em voz alta —
/// a resposta lê-se sozinha, porque quem falou provavelmente não vai ler.
///
/// É do plano pago (`feature_flags.fala_comigo`: grátis não, Pro sim).
class FalaScreen extends StatefulWidget {
  /// Para fotos e testes: um ouvido de mentira (`Ouvir.paraTeste`). Na app
  /// nasce aqui.
  final Ouvir? ouvir;

  /// Para fotos e testes: conversa já feita (`IaStore.paraTeste`).
  final IaStore? store;

  /// O que fazer quando se toca no cadeado. Por omissão abre o ecrã do plano.
  final VoidCallback? aoAbrirPlano;

  const FalaScreen({super.key, this.ouvir, this.store, this.aoAbrirPlano});

  @override
  State<FalaScreen> createState() => _FalaScreenState();
}

class _FalaScreenState extends State<FalaScreen> {
  late final Ouvir _ouvir;
  late final IaStore _store;
  late final bool _ouvirEMeu;
  late final bool _storeEMeu;

  /// As duas fontes de mudança do ecrã, numa só. Fica em campo (e não dentro
  /// do `build`) porque o anel do microfone redesenha muitas vezes por segundo
  /// e não vale a pena voltar a assinar tudo a cada frame.
  late final Listenable _mudancas;

  final _escrever = TextEditingController();

  /// A pessoa está a escrever em vez de falar (por escolha, ou porque o
  /// microfone não dá).
  bool _modoEscrita = false;

  /// Quantas mensagens já passaram por aqui. Serve para ler em voz alta a
  /// resposta nova UMA vez — e não a cada redesenho do ecrã.
  int _lidasAte = 0;

  DateTime? _premidoEm;

  /// O toque que fecha uma escuta começada por toque não pode, ao largar,
  /// fechá-la outra vez.
  bool _ignoraLargar = false;

  @override
  void initState() {
    super.initState();
    _ouvirEMeu = widget.ouvir == null;
    _storeEMeu = widget.store == null;
    _ouvir = widget.ouvir ?? Ouvir();
    _store = widget.store ?? IaStore(modo: 'chat');
    _mudancas = Listenable.merge([_store, _ouvir]);
    _lidasAte = _store.mensagens.length;
    _ouvir.aoTerminar = _perguntar;
    _ouvir.addListener(_aoMudarOuvido);
    _store.addListener(_aoMudarConversa);
  }

  @override
  void dispose() {
    _store.removeListener(_aoMudarConversa);
    _ouvir.removeListener(_aoMudarOuvido);
    _ouvir.aoTerminar = null;
    // Sair da tela cala a app. Deixar a voz a ler num ecrã que já não se vê é
    // assustador, sobretudo para quem não percebe de onde vem o som.
    Fala.instancia.parar();
    if (_ouvirEMeu) _ouvir.dispose();
    if (_storeEMeu) _store.dispose();
    _escrever.dispose();
    super.dispose();
  }

  String get _variante =>
      context.read<PerfilStore>().perfil?.variantePt ??
      (Localizations.localeOf(context).countryCode == 'BR' ? 'br' : 'pt');

  /// Sem microfone ou sem motor de voz, a tela abre sozinha o caminho da
  /// escrita: não se deixa ninguém à frente de um botão que não faz nada.
  void _aoMudarOuvido() {
    if (!mounted) return;
    if (_ouvir.impedido && !_modoEscrita) setState(() => _modoEscrita = true);
  }

  void _aoMudarConversa() {
    if (!mounted) return;
    final devolvida = _store.tomarPerguntaDevolvida();
    if (devolvida != null && _escrever.text.trim().isEmpty) {
      // A pergunta falhou (rede, limite, assistente a descansar). Volta escrita
      // para não obrigar a pessoa a dizer tudo outra vez.
      _escrever.text = devolvida;
      setState(() => _modoEscrita = true);
    }
    final mensagens = _store.mensagens;
    if (mensagens.length < _lidasAte) _lidasAte = mensagens.length;
    if (mensagens.length <= _lidasAte) return;
    _lidasAte = mensagens.length;
    final ultima = mensagens.last;
    if (ultima.doUtilizador || ultima.texto.trim().isEmpty) return;
    // Quem falou provavelmente não vai ler: a resposta lê-se sozinha, de uma
    // vez, sem ninguém ter de encontrar o botão do altifalante.
    Fala.instancia.ler(_etiquetaResposta, ultima.texto, variante: _variante);
  }

  Future<void> _perguntar(String frase) async {
    final p = frase.trim();
    if (p.isEmpty) return;
    _escrever.clear();
    _ouvir.limparRecados();
    await _store.perguntar(p);
  }

  void _premir() {
    if (_ouvir.ocupado) {
      // Já estava a ouvir por toque simples: este toque é o "já acabei".
      _ignoraLargar = true;
      _ouvir.parar();
      return;
    }
    _ignoraLargar = false;
    _premidoEm = DateTime.now();
    _ouvir.limparRecados();
    _ouvir.comecar(variante: _variante);
  }

  void _largar() {
    if (_ignoraLargar) {
      _ignoraLargar = false;
      return;
    }
    final inicio = _premidoEm;
    _premidoEm = null;
    if (inicio == null) return;
    // Dedo em cima: acabou quando o dedo sai. Toque curto: fica a ouvir até ao
    // toque seguinte — há muita gente que não consegue manter o dedo premido.
    if (DateTime.now().difference(inicio) >= _toqueCurto) _ouvir.parar();
  }

  void _abrirPlano() {
    if (widget.aoAbrirPlano != null) {
      widget.aoAbrirPlano!();
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const PlanoScreen()));
  }

  String? get _ultimaResposta {
    for (var i = _store.mensagens.length - 1; i >= 0; i--) {
      if (!_store.mensagens[i].doUtilizador) return _store.mensagens[i].texto;
    }
    return null;
  }

  String? get _ultimaPergunta {
    for (var i = _store.mensagens.length - 1; i >= 0; i--) {
      if (_store.mensagens[i].doUtilizador) return _store.mensagens[i].texto;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final trancado = !context.watch<PlanoStore>().permitida('fala_comigo');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(l.falaTitulo)),
      body: SafeArea(
        child: Cadeado(
          trancado: trancado,
          linha: l.falaCadeado,
          aoTocar: _abrirPlano,
          child: ListenableBuilder(
            listenable: _mudancas,
            builder: (context, _) {
              final aPensar = _store.aPensar;
              final resposta = aPensar ? null : _ultimaResposta;
              final podeFalar = !trancado && !aPensar && !_store.limite;
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: paddingEcra,
                      children: [
                        if (resposta == null && !_ouvir.ocupado && !aPensar) ...[
                          Text(l.falaSubtitulo,
                              style: t.bodyMedium!
                                  .copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                        ],
                        ..._notas(l),
                        if (_ouvir.ocupado)
                          _AOuvirAgora(palavras: _ouvir.texto, aEspera: l.falaDizLa)
                        else if (aPensar)
                          _APensar(texto: l.falaAPensar)
                        else if (resposta != null)
                          _Resposta(
                            pergunta: _ultimaPergunta,
                            rotuloPergunta: l.falaPerguntaste,
                            texto: resposta,
                          ),
                        if (_store.limite) ...[
                          const SizedBox(height: 12),
                          _CartaoPlano(
                            texto: l.falaLimite,
                            acao: l.iaVerPlano,
                            aoTocar: _abrirPlano,
                          ),
                        ],
                        if (!_ouvir.ocupado && !aPensar && !_store.limite) ...[
                          const SizedBox(height: 16),
                          // Não é TituloSeccao de propósito: essa etiqueta são
                          // 12 px e uma linha só, e isto é uma frase inteira
                          // que tem de se ler (mínimo da casa: 13 px).
                          Text(l.falaExemplosTitulo,
                              style: t.bodyMedium!
                                  .copyWith(color: AppColors.textSecondary)),
                          const SizedBox(height: 10),
                          for (final (i, exemplo) in [
                            l.falaExemplo1,
                            l.falaExemplo2,
                            l.falaExemplo3,
                          ].indexed) ...[
                            BotaoEscolha(
                              key: Key('fala_exemplo_${i + 1}'),
                              texto: exemplo,
                              icone: Icons.help_outline_rounded,
                              aoTocar: () => _perguntar(exemplo),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ],
                    ),
                  ),
                  _modoEscrita
                      ? _BlocoEscrita(
                          controlador: _escrever,
                          dica: l.iaEscreve,
                          enviar: l.suporteEnviar,
                          voltarAFalar: l.falaVoltarAFalar,
                          podeEnviar: !aPensar && !_store.limite,
                          podeVoltar: !trancado,
                          aoEnviar: () => _perguntar(_escrever.text),
                          // Limpar o recado ANTES de voltar: quem foi às
                          // definições dar o microfone tem de poder tentar
                          // outra vez sem fechar a app. Se continuar recusado,
                          // a tela volta sozinha para a escrita.
                          aoVoltar: () {
                            _ouvir.limparRecados();
                            setState(() => _modoEscrita = false);
                          },
                        )
                      : _BlocoMicrofone(
                          aOuvir: _ouvir.ocupado,
                          ativo: podeFalar,
                          volume: _ouvir.volume,
                          rotulo: _ouvir.ocupado
                              ? l.falaBotaoParar
                              : l.falaBotaoFalar,
                          ajuda: _ouvir.ocupado
                              ? l.falaAOuvir
                              : l.falaCarregaEFala,
                          ajudaExtra:
                              _ouvir.ocupado ? null : l.falaTambemPorToque,
                          escrever: l.falaPreferoEscrever,
                          aoPremir: podeFalar ? _premir : null,
                          aoLargar: _largar,
                          aoEscrever: () => setState(() => _modoEscrita = true),
                        ),
                  _Rodape(texto: l.iaRodape),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Os recados que a tela pode ter de dar: sem microfone, sem motor de voz,
  /// língua trocada, assistente a descansar, sem rede.
  ///
  /// Regra da casa: um só elemento laranja por ecrã. O único laranja aqui é o
  /// [Aviso] do assistente a descansar — os recados do microfone são azuis
  /// (informação), porque não são urgência nenhuma e culpar o aparelho a
  /// laranja fazia a pessoa achar que fez asneira.
  List<Widget> _notas(AppLocalizations l) {
    final notas = <Widget>[];
    if (_ouvir.estado == EstadoOuvir.semPermissao) {
      notas.add(_Nota(
        key: const Key('fala_sem_microfone'),
        icone: Icons.mic_off_rounded,
        texto: l.falaSemMicrofone,
        ajuda: l.falaSemMicrofoneComo,
      ));
    } else if (_ouvir.estado == EstadoOuvir.semServico) {
      notas.add(_Nota(
        key: const Key('fala_sem_servico'),
        icone: Icons.hearing_disabled_rounded,
        texto: l.falaSemServico,
      ));
    } else if (_ouvir.naoOuviuNada) {
      notas.add(_Nota(
        key: const Key('fala_nao_percebi'),
        icone: Icons.info_outline_rounded,
        texto: l.falaNaoPercebi,
      ));
    } else if (_ouvir.localeAproximado) {
      notas.add(_Nota(
        key: const Key('fala_lingua'),
        icone: Icons.translate_rounded,
        texto: l.falaLinguaAproximada,
      ));
    }
    if (_store.aDescansar) {
      notas.add(Aviso(l.iaDescansar,
          tom: Semaforo.amarelo, icone: Icons.bedtime_outlined));
    } else if (_store.erro != null) {
      notas.add(Aviso(l.erroRede,
          tom: Semaforo.vermelho, icone: Icons.wifi_off_rounded));
    }
    if (notas.isEmpty) return const [];
    return [
      for (final n in notas) ...[n, const SizedBox(height: 12)],
    ];
  }
}

/// As palavras a aparecer enquanto a pessoa fala. É a prova de que a app está
/// mesmo a ouvir — sem isto, um botão a pulsar não diz nada a ninguém.
class _AOuvirAgora extends StatelessWidget {
  final String palavras;
  final String aEspera;
  const _AOuvirAgora({required this.palavras, required this.aEspera});

  @override
  Widget build(BuildContext context) {
    final vazio = palavras.trim().isEmpty;
    return Cartao(
      key: const Key('fala_palavras'),
      cor: AppColors.primaryWash,
      bordo: AppColors.primaryLight,
      padding: const EdgeInsets.all(20),
      child: Text(
        vazio ? aEspera : palavras,
        style: TextStyle(
          fontFamily: AppTheme.fonte,
          fontSize: 22,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: vazio ? AppColors.textSubtle : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _APensar extends StatelessWidget {
  final String texto;
  const _APensar({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Cartao(
      key: const Key('fala_a_pensar'),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(texto, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

/// A resposta, em letras grandes, com o botão de a ouvir outra vez.
class _Resposta extends StatelessWidget {
  final String? pergunta;
  final String rotuloPergunta;
  final String texto;
  const _Resposta({
    required this.pergunta,
    required this.rotuloPergunta,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Cartao(
      key: const Key('fala_resposta'),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pergunta != null) ...[
            Text(rotuloPergunta, style: t.bodySmall),
            const SizedBox(height: 4),
            Text(
              pergunta!,
              style: t.titleMedium!.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            texto,
            style: const TextStyle(
              fontFamily: AppTheme.fonte,
              fontSize: 20,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
          BotaoOuvir(etiqueta: _etiquetaResposta, texto: texto),
        ],
      ),
    );
  }
}

/// O botão grande e redondo, com o anel que pulsa ao ritmo da voz.
class _BlocoMicrofone extends StatelessWidget {
  final bool aOuvir;
  final bool ativo;
  final double volume;
  final String rotulo;
  final String ajuda;
  final String? ajudaExtra;
  final String escrever;
  final VoidCallback? aoPremir;
  final VoidCallback aoLargar;
  final VoidCallback aoEscrever;

  const _BlocoMicrofone({
    required this.aOuvir,
    required this.ativo,
    required this.volume,
    required this.rotulo,
    required this.ajuda,
    required this.ajudaExtra,
    required this.escrever,
    required this.aoPremir,
    required this.aoLargar,
    required this.aoEscrever,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Microfone(
            aOuvir: aOuvir,
            ativo: ativo,
            volume: volume,
            rotulo: rotulo,
            aoPremir: aoPremir,
            aoLargar: aoLargar,
          ),
          const SizedBox(height: 10),
          Text(ajuda, textAlign: TextAlign.center, style: t.bodyMedium),
          if (ajudaExtra != null) ...[
            const SizedBox(height: 4),
            Text(ajudaExtra!, textAlign: TextAlign.center, style: t.bodySmall),
          ],
          TextButton.icon(
            key: const Key('fala_prefiro_escrever'),
            onPressed: aoEscrever,
            icon: const Icon(Icons.keyboard_alt_outlined, size: 20),
            label: Text(escrever),
          ),
        ],
      ),
    );
  }
}

class _Microfone extends StatefulWidget {
  final bool aOuvir;
  final bool ativo;
  final double volume;
  final String rotulo;
  final VoidCallback? aoPremir;
  final VoidCallback aoLargar;

  const _Microfone({
    required this.aOuvir,
    required this.ativo,
    required this.volume,
    required this.rotulo,
    required this.aoPremir,
    required this.aoLargar,
  });

  @override
  State<_Microfone> createState() => _MicrofoneState();
}

class _MicrofoneState extends State<_Microfone>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    if (widget.aOuvir) _anim.repeat();
  }

  @override
  void didUpdateWidget(_Microfone velho) {
    super.didUpdateWidget(velho);
    if (widget.aOuvir && !_anim.isAnimating) {
      _anim.repeat();
    } else if (!widget.aOuvir && _anim.isAnimating) {
      _anim.stop();
      _anim.value = 0;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = !widget.ativo
        ? AppColors.divider
        : (widget.aOuvir ? AppColors.primaryDark : AppColors.primary);
    return Semantics(
      button: true,
      label: widget.rotulo,
      child: GestureDetector(
        key: const Key('fala_microfone'),
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.aoPremir == null ? null : (_) => widget.aoPremir!(),
        onTapUp: (_) => widget.aoLargar(),
        onTapCancel: widget.aoLargar,
        child: SizedBox(
          width: 168,
          height: 168,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              // O anel cresce com o pulsar e mais um bocado com a voz: é assim
              // que a pessoa vê que o microfone a está a apanhar.
              final pulso = 1 - (_anim.value * 2 - 1).abs();
              final escala = widget.aOuvir
                  ? 1 + 0.16 * pulso + 0.20 * widget.volume
                  : 1.0;
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.aOuvir)
                    Container(
                      width: 128 * escala,
                      height: 128 * escala,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryLight.withValues(alpha: 0.7),
                      ),
                    ),
                  Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cor,
                      boxShadow: widget.ativo ? AppTheme.sombraGrande : null,
                    ),
                    child: Icon(
                      widget.aOuvir ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// O caminho de quem prefere (ou tem de) escrever.
class _BlocoEscrita extends StatelessWidget {
  final TextEditingController controlador;
  final String dica;
  final String enviar;
  final String voltarAFalar;
  final bool podeEnviar;
  final bool podeVoltar;
  final VoidCallback aoEnviar;
  final VoidCallback aoVoltar;

  const _BlocoEscrita({
    required this.controlador,
    required this.dica,
    required this.enviar,
    required this.voltarAFalar,
    required this.podeEnviar,
    required this.podeVoltar,
    required this.aoEnviar,
    required this.aoVoltar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('fala_campo_escrita'),
            controller: controlador,
            enabled: podeEnviar,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => aoEnviar(),
            decoration: InputDecoration(hintText: dica),
          ),
          const SizedBox(height: 10),
          BotaoGrande(
            texto: enviar,
            icone: Icons.send_rounded,
            aoTocar: podeEnviar ? aoEnviar : null,
          ),
          if (podeVoltar)
            TextButton.icon(
              key: const Key('fala_voltar_a_falar'),
              onPressed: aoVoltar,
              icon: const Icon(Icons.mic_rounded, size: 20),
              label: Text(voltarAFalar),
            ),
        ],
      ),
    );
  }
}

/// Recado azul de informação (não é urgência, não leva a cor do semáforo).
class _Nota extends StatelessWidget {
  final IconData icone;
  final String texto;
  final String? ajuda;
  const _Nota({super.key, required this.icone, required this.texto, this.ajuda});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Cartao(
      cor: AppColors.infoClaro,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: AppColors.info, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto, style: t.bodyMedium),
                if (ajuda != null) ...[
                  const SizedBox(height: 4),
                  Text(ajuda!, style: t.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartaoPlano extends StatelessWidget {
  final String texto;
  final String acao;
  final VoidCallback aoTocar;
  const _CartaoPlano({
    required this.texto,
    required this.acao,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    return Cartao(
      cor: AppColors.cadeadoClaro,
      bordo: AppColors.cadeado.withValues(alpha: 0.35),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lock_rounded, color: AppColors.cadeado, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  texto,
                  style: const TextStyle(
                    fontFamily: AppTheme.fonte,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: aoTocar,
              style: TextButton.styleFrom(foregroundColor: AppColors.cadeado),
              icon: const Icon(Icons.workspace_premium_rounded, size: 18),
              label: Text(
                acao,
                style: const TextStyle(
                  fontFamily: AppTheme.fonte,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Rodape extends StatelessWidget {
  final String texto;
  const _Rodape({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: AppTheme.fonte,
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
