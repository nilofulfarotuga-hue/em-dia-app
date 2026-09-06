/// Widgets partilhados do Em Dia. Os ecrãs compõem ISTO — não reinventam
/// cartões, botões nem o semáforo.
library;

export 'botao_ouvir.dart';

import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';

/// Estado do semáforo do painel.
enum Semaforo { verde, amarelo, vermelho }

extension SemaforoCor on Semaforo {
  Color get cor => switch (this) {
        Semaforo.verde => AppColors.emDia,
        Semaforo.amarelo => AppColors.aVencer,
        Semaforo.vermelho => AppColors.passou,
      };
  Color get corClara => switch (this) {
        Semaforo.verde => AppColors.emDiaClaro,
        Semaforo.amarelo => AppColors.aVencerClaro,
        Semaforo.vermelho => AppColors.passouClaro,
      };
  IconData get icone => switch (this) {
        Semaforo.verde => Icons.check_circle_rounded,
        Semaforo.amarelo => Icons.error_rounded,
        Semaforo.vermelho => Icons.warning_rounded,
      };
}

/// O semáforo grande do painel "Estás em dia?".
class SemaforoGrande extends StatelessWidget {
  final Semaforo estado;
  final String titulo;
  final String? subtitulo;
  const SemaforoGrande({super.key, required this.estado, required this.titulo, this.subtitulo});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: estado.cor,
        borderRadius: AppTheme.cantos,
        boxShadow: AppTheme.sombraCartao,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(estado.icone, color: Colors.white, size: 56),
          const SizedBox(height: 12),
          Text(titulo,
              style: t.headlineMedium!.copyWith(color: Colors.white, fontFamily: AppTheme.fonte)),
          if (subtitulo != null) ...[
            const SizedBox(height: 6),
            Text(subtitulo!,
                style: t.bodyLarge!.copyWith(color: Colors.white.withValues(alpha: 0.92), fontFamily: AppTheme.fonte)),
          ],
        ],
      ),
    );
  }
}

/// Cartão branco de cantos 16 (o bloco base de todos os ecrãs).
class Cartao extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? cor;
  final VoidCallback? aoTocar;
  final Color? bordo;
  const Cartao({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.cor,
    this.aoTocar,
    this.bordo,
  });

  @override
  Widget build(BuildContext context) {
    final conteudo = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cor ?? AppColors.surface,
        borderRadius: AppTheme.cantos,
        boxShadow: AppTheme.sombraCartao,
        border: bordo == null ? null : Border.all(color: bordo!, width: 1.5),
      ),
      child: child,
    );
    if (aoTocar == null) return conteudo;
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: AppTheme.cantos, onTap: aoTocar, child: conteudo),
    );
  }
}

/// Título de secção pequeno, em maiúsculas discretas.
class TituloSeccao extends StatelessWidget {
  final String texto;
  final Widget? acao;
  const TituloSeccao(this.texto, {super.key, this.acao});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(texto,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      letterSpacing: 0.8,
                      fontFamily: AppTheme.fonte,
                    ).apply(fontSizeFactor: 1.05),
                overflow: TextOverflow.ellipsis),
          ),
          if (acao != null) acao!,
        ],
      ),
    );
  }
}

/// Botão grande de uma ação (o botão do onboarding e dos ecrãs simples).
class BotaoGrande extends StatelessWidget {
  final String texto;
  final VoidCallback? aoTocar;
  final bool secundario;
  final IconData? icone;
  final bool aTrabalhar;
  final Color? cor;
  const BotaoGrande({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.secundario = false,
    this.icone,
    this.aTrabalhar = false,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final filho = aTrabalhar
        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icone != null) ...[Icon(icone, size: 22), const SizedBox(width: 10)],
              Flexible(child: Text(texto, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis)),
            ],
          );
    if (secundario) {
      return OutlinedButton(onPressed: aTrabalhar ? null : aoTocar, child: filho);
    }
    return ElevatedButton(
      onPressed: aTrabalhar ? null : aoTocar,
      style: cor == null ? null : ElevatedButton.styleFrom(backgroundColor: cor),
      child: filho,
    );
  }
}

/// Botão de escolha grande (uma pergunta por ecrã, botões grandes).
class BotaoEscolha extends StatelessWidget {
  final String texto;
  final String? ajuda;
  final IconData? icone;
  final bool selecionado;
  final VoidCallback aoTocar;
  const BotaoEscolha({
    super.key,
    required this.texto,
    this.ajuda,
    this.icone,
    this.selecionado = false,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Cartao(
      aoTocar: aoTocar,
      cor: selecionado ? AppColors.primaryLight : AppColors.surface,
      bordo: selecionado ? AppColors.primary : AppColors.divider,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          if (icone != null) ...[
            Icon(icone, size: 30, color: selecionado ? AppColors.primaryDark : AppColors.textSecondary),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(texto, style: t.titleMedium),
                if (ajuda != null) ...[
                  const SizedBox(height: 2),
                  Text(ajuda!, style: t.bodySmall),
                ],
              ],
            ),
          ),
          Icon(selecionado ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: selecionado ? AppColors.primary : AppColors.textSubtle),
        ],
      ),
    );
  }
}

/// Etiqueta pequena colorida (estado, plano).
class Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;
  final Color corTexto;
  final IconData? icone;
  const Etiqueta(this.texto, {super.key, required this.cor, this.corTexto = Colors.white, this.icone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[Icon(icone, size: 14, color: corTexto), const SizedBox(width: 4)],
          Text(texto,
              style: TextStyle(fontFamily: AppTheme.fonte, fontSize: 12, fontWeight: FontWeight.w700, color: corTexto)),
        ],
      ),
    );
  }
}

/// Cadeado de funcionalidade Pro: mostra o filho baço + explicação de uma linha.
class Cadeado extends StatelessWidget {
  final bool trancado;
  final String linha; // explicação de uma linha
  final Widget child;
  final VoidCallback? aoTocar;
  const Cadeado({super.key, required this.trancado, required this.linha, required this.child, this.aoTocar});

  @override
  Widget build(BuildContext context) {
    if (!trancado) return child;
    return Stack(
      children: [
        IgnorePointer(child: Opacity(opacity: 0.45, child: child)),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppTheme.cantos,
              onTap: aoTocar,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cadeadoClaro,
                    borderRadius: AppTheme.cantosPequenos,
                    border: Border.all(color: AppColors.cadeado.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_rounded, color: AppColors.cadeado, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(linha,
                            style: const TextStyle(
                                fontFamily: AppTheme.fonte,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cadeado)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Linha "chave: valor" alinhada (para os resultados das calculadoras).
class LinhaValor extends StatelessWidget {
  final String nome;
  final String valor;
  final bool destaque;
  final Color? cor;
  const LinhaValor(this.nome, this.valor, {super.key, this.destaque = false, this.cor});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(nome, style: destaque ? t.titleMedium : t.bodyMedium)),
          const SizedBox(width: 12),
          Text(valor,
              style: (destaque ? t.titleLarge : t.titleMedium)!.copyWith(color: cor ?? (destaque ? AppColors.primaryDark : null))),
        ],
      ),
    );
  }
}

/// Estado vazio amigável.
class Vazio extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Widget? acao;
  const Vazio({super.key, required this.icone, required this.texto, this.acao});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 56, color: AppColors.textSubtle),
          const SizedBox(height: 12),
          Text(texto, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppColors.textSecondary)),
          if (acao != null) ...[const SizedBox(height: 16), acao!],
        ],
      ),
    );
  }
}

/// Aviso colorido em caixa (dica, atenção, erro).
class Aviso extends StatelessWidget {
  final String texto;
  final Semaforo tom;
  final IconData? icone;
  const Aviso(this.texto, {super.key, this.tom = Semaforo.amarelo, this.icone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: tom.corClara, borderRadius: AppTheme.cantosPequenos),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone ?? tom.icone, color: tom.cor, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Padding padrão dos ecrãs.
const EdgeInsets paddingEcra = EdgeInsets.fromLTRB(20, 12, 20, 24);
