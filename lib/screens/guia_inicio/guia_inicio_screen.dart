import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/fala.dart';
import '../../stores/perfil_store.dart';
import '../../widgets/widgets.dart';

/// Um dos ecrãs do guia: o desenho (feito só com ícones, não há imagens),
/// o título curto e as frases.
class _PassoGuia {
  final String etiqueta; // identifica o botão de ouvir deste ecrã
  final IconData icone;
  final IconData selo; // ícone pequeno no canto, para o desenho não ser só um círculo
  final Color cor;
  final Color fundo;
  final String titulo;
  final String texto;

  const _PassoGuia({
    required this.etiqueta,
    required this.icone,
    required this.selo,
    required this.cor,
    required this.fundo,
    required this.titulo,
    required this.texto,
  });
}

/// Guia de primeira utilização: três ecrãs, um de cada vez, mostrados uma só
/// vez — depois das 5 perguntas do onboarding e antes do painel.
///
/// Fica marcado no perfil (`viu_guia_inicio`), que é do servidor de propósito:
/// quem trocar de telemóvel não leva com isto outra vez.
class GuiaInicioScreen extends StatefulWidget {
  /// Ecrã em que arranca (serve para as fotos). 0 = o primeiro.
  final int passoInicial;

  const GuiaInicioScreen({super.key, this.passoInicial = 0});

  @override
  State<GuiaInicioScreen> createState() => _GuiaInicioScreenState();
}

class _GuiaInicioScreenState extends State<GuiaInicioScreen> {
  static const int _total = 3;

  late int _passo;
  bool _aTrabalhar = false;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _passo = widget.passoInicial.clamp(0, _total - 1);
  }

  @override
  void dispose() {
    // A voz não vai atrás de quem sai do ecrã.
    Fala.instancia.parar();
    super.dispose();
  }

  List<_PassoGuia> _passos(AppLocalizations l) => [
        // Único laranja do ecrã: é o aviso a chegar antes do prazo, e no
        // Em Dia laranja quer sempre dizer "está a vencer".
        _PassoGuia(
          etiqueta: 'guia-inicio-aviso',
          icone: Icons.notifications_active_rounded,
          selo: Icons.event_available_rounded,
          cor: AppColors.aVencer,
          fundo: AppColors.aVencerClaro,
          titulo: l.guiaIniAvisoTitulo,
          texto: l.guiaIniAvisoTexto,
        ),
        _PassoGuia(
          etiqueta: 'guia-inicio-ganhos',
          icone: Icons.edit_note_rounded,
          selo: Icons.euro_rounded,
          cor: AppColors.emDia,
          fundo: AppColors.emDiaClaro,
          titulo: l.guiaIniGanhosTitulo,
          texto: l.guiaIniGanhosTexto,
        ),
        _PassoGuia(
          etiqueta: 'guia-inicio-pergunta',
          icone: Icons.chat_bubble_rounded,
          selo: Icons.auto_awesome_rounded,
          cor: AppColors.emDia,
          fundo: AppColors.emDiaClaro,
          titulo: l.guiaIniPerguntaTitulo,
          texto: l.guiaIniPerguntaTexto,
        ),
      ];

  void _avancar() {
    // Trocar de ecrã cala o que estava a ser lido: senão a voz do ecrã
    // anterior continua por cima do novo.
    Fala.instancia.parar();
    setState(() {
      _passo++;
      _erro = null;
    });
  }

  /// Marca no perfil que já viu o guia. O RaizNavegador troca sozinho para a
  /// Shell quando o campo ficar a `true`.
  Future<void> _terminar() async {
    final l = AppLocalizations.of(context);
    final perfilStore = context.read<PerfilStore>();
    final perfil = perfilStore.perfil;
    if (perfil == null) {
      setState(() => _erro = l.erroRede);
      return;
    }
    setState(() {
      _aTrabalhar = true;
      _erro = null;
    });
    Fala.instancia.parar();
    final ok = await perfilStore.guardar(perfil.copyWith(viuGuiaInicio: true));
    // Se falhou, fica aqui a dizer porquê — nunca uma roda a girar sem fim.
    if (!ok && mounted) {
      setState(() {
        _aTrabalhar = false;
        _erro = l.erroRede;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final passos = _passos(l);
    final p = passos[_passo];
    final ultimo = _passo == _total - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                children: [
                  const Spacer(),
                  // Saltar discreto: quem já percebeu não fica preso aqui.
                  if (!ultimo)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: TextButton(
                        key: const Key('guia_inicio_saltar'),
                        onPressed: _aTrabalhar ? null : _terminar,
                        style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                        child: Text(l.guiaIniSaltar),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: ListView(
                    padding: paddingEcra,
                    children: [
                      const SizedBox(height: 8),
                      _Desenho(passo: p),
                      const SizedBox(height: 28),
                      Text(p.titulo, textAlign: TextAlign.center, style: t.headlineLarge),
                      const SizedBox(height: 12),
                      Text(
                        p.texto,
                        textAlign: TextAlign.center,
                        style: t.bodyLarge!.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: BotaoOuvir(
                          key: Key('guia_inicio_ouvir_$_passo'),
                          etiqueta: p.etiqueta,
                          texto: '${p.titulo}. ${p.texto}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _Pontos(passo: _passo, total: _total, etiqueta: l.guiaIniPasso(_passo + 1, _total)),
            const SizedBox(height: 16),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: [
                      if (_erro != null) ...[
                        Aviso(_erro!, tom: Semaforo.vermelho),
                        const SizedBox(height: 12),
                      ],
                      BotaoGrande(
                        key: const Key('guia_inicio_seguinte'),
                        texto: ultimo ? l.guiaIniComecar : l.guiaIniSeguinte,
                        icone: ultimo ? Icons.check_rounded : null,
                        aTrabalhar: _aTrabalhar,
                        aoTocar: ultimo ? _terminar : _avancar,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O desenho de cada ecrã: um círculo grande com o ícone e um selo pequeno no
/// canto. Só ícones — a app não traz ficheiros de imagem.
class _Desenho extends StatelessWidget {
  final _PassoGuia passo;
  const _Desenho({required this.passo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 168,
        height: 168,
        child: Stack(
          children: [
            Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(color: passo.fundo, shape: BoxShape.circle),
              child: Icon(passo.icone, size: 84, color: passo.cor),
            ),
            Positioned(
              right: 4,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.sombraCartao,
                ),
                child: Icon(passo.selo, size: 24, color: passo.cor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Os pontos que dizem em que ecrã se está. O ponto de agora é uma barrinha,
/// para se ver bem mesmo de longe.
class _Pontos extends StatelessWidget {
  final int passo;
  final int total;
  final String etiqueta;
  const _Pontos({required this.passo, required this.total, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: etiqueta,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == passo ? 28 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: i == passo ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
