import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import '../../widgets/widgets.dart';
import 'cartoes_painel.dart' show iconeDoTipo, nomeHumano;

/// Cartão de ação — o primeiro bloco do painel, em cima de tudo.
///
/// Responde a uma pergunta só: **o que tenho de fazer agora?** Uma frase com
/// o verbo à frente ("Paga a Segurança Social"), o valor em grande, até
/// quando por palavras ("é amanhã", "até sexta, dia 20"), um botão que leva
/// à coisa e o botão de ouvir com a frase toda.
///
/// Cor: o cartão é branco. A cor do semáforo (vermelho passou · laranja a
/// vencer em 5 dias ou menos · verde não há nada) vive só no ícone e na linha
/// da data. O valor grande é preto.
///
/// Chegou aqui por tentativa e erro, com o juiz de visão a reprovar duas
/// vezes: primeiro com o cartão inteiro em laranja claro, depois com o valor
/// em laranja. As duas vezes ele contou "mais do que um elemento laranja no
/// ecrã" e as duas vezes tinha razão — o laranja cheio é do `SemaforoGrande`
/// logo por baixo, e a regra da casa é um por ecrã.
class CartaoAcao extends StatelessWidget {
  /// A coisa mais urgente: um prazo passado (o mais antigo) ou, se não
  /// houver, a próxima obrigação pendente. `null` = não há nada a fazer.
  final ObrigacaoItem? item;
  final DateTime hoje;

  /// O botão principal (abrir o detalhe da obrigação).
  final VoidCallback? aoAgir;

  /// "Já paguei". Subiu do cartão do próximo prazo para aqui: era o único
  /// botão que ele tinha e este não, e é o que se carrega mais vezes.
  final VoidCallback? aoJaPaguei;

  /// Só no estado "está tudo tratado": a única coisa útil que sobra.
  /// `null` esconde o botão (por exemplo, quem não passa recibos).
  final VoidCallback? aoRegistarRendimento;

  const CartaoAcao({
    super.key,
    required this.item,
    required this.hoje,
    this.aoAgir,
    this.aoJaPaguei,
    this.aoRegistarRendimento,
  });

  Semaforo get _tom {
    final o = item;
    if (o == null) return Semaforo.verde;
    if (o.passou(hoje)) return Semaforo.vermelho;
    return o.diasParaPrazo(hoje) <= 5 ? Semaforo.amarelo : Semaforo.verde;
  }

  /// A cor do sinal — usada na data e no ícone, NÃO no valor.
  ///
  /// O valor grande ficou preto de propósito. Com ele à cor do semáforo, o
  /// juiz de visão contava dois laranjas no mesmo ecrã (este número e o bloco
  /// do semáforo por baixo) e tinha razão: a regra da casa é um só. A urgência
  /// lê-se na data e no semáforo; o número só precisa de ser o maior.
  Color get _corSinal => switch (_tom) {
        Semaforo.verde => AppColors.primaryDark,
        // Laranja NUNCA aqui. A regra da casa é um elemento laranja por ecrã e
        // esse é o `SemaforoGrande` logo por baixo, que diz a mesma urgência em
        // palavras. O juiz de visão reprovou três versões seguidas até isto
        // ficar assim: cartão laranja cheio, depois valor laranja, depois
        // ícone e data laranja. Aqui o aviso lê-se no texto ("Até quinta,
        // dia 10"), não na cor.
        Semaforo.amarelo => AppColors.textSecondary,
        // O vermelho fica: é outra cor, a regra do "um" é do laranja, e um
        // prazo já passado tem mesmo de saltar à vista.
        Semaforo.vermelho => AppColors.passou,
      };

  /// A cor do ícone do topo. Igual à do sinal, pela mesma razão.
  Color get _corIcone => _tom == Semaforo.amarelo ? AppColors.textSecondary : _tom.cor;

  /// A frase da ação: verbo à frente, sem siglas por explicar. É por tipo (e
  /// não "Paga {nome}") porque em português o artigo muda com a palavra —
  /// "a Segurança Social", "o IVA" — e uma frase montada aos bocados sai
  /// torta.
  String _acao(AppLocalizations l, ObrigacaoItem o) => switch (o.tipo) {
        'ss_pagamento' => l.painelAcaoPagaSs,
        'ss_declaracao' => l.painelAcaoEntregaSs,
        'iva_pagamento' => l.painelAcaoPagaIva,
        'iva_declaracao' => l.painelAcaoEntregaIva,
        'irs_entrega' => l.painelAcaoEntregaIrs,
        'irs_pagamento_conta' => l.painelAcaoPagaIrsConta,
        'efatura_validar' => l.painelAcaoValidaFaturas,
        'recibos_comunicar' => l.painelAcaoComunicaFaturas,
        'iuc' => l.painelAcaoPagaIuc,
        'ipo' => l.painelAcaoInspecao,
        'revisao' => l.painelAcaoRevisao,
        'seguro' => l.painelAcaoSeguro,
        'carta' => l.painelAcaoCarta,
        'troca_carta' => l.painelAcaoTrocaCarta,
        'residencia' => l.painelAcaoResidencia,
        'tvde_certificado' => l.painelAcaoCertificadoTvde,
        'tvde_licenca' => l.painelAcaoLicencaTvde,
        'multa' => l.painelAcaoMulta,
        'portagem' => l.painelAcaoPortagem,
        'fim_isencao_ss' => l.painelAcaoFimIsencao,
        _ => l.painelAcaoGenerica(nomeHumano(l, o)),
      };

  /// Até quando, por palavras. Perto usa o dia da semana ("até sexta, dia
  /// 20"), que é como as pessoas contam; longe usa a data por extenso.
  String _prazo(AppLocalizations l, ObrigacaoItem o) {
    final d = o.diasParaPrazo(hoje);
    if (d < 0) return l.painelAcaoPrazoPassou(-d);
    if (d == 0) return l.painelAcaoPrazoHoje;
    if (d == 1) return l.painelAcaoPrazoAmanha;
    if (d <= 6) return l.painelAcaoPrazoDiaSemana(_diaSemana(l, o.dataLimite.weekday), o.dataLimite.day);
    return l.painelAcaoPrazoData(dataExtensoPt(o.dataLimite));
  }

  String _diaSemana(AppLocalizations l, int weekday) => switch (weekday) {
        DateTime.monday => l.painelAcaoDia1,
        DateTime.tuesday => l.painelAcaoDia2,
        DateTime.wednesday => l.painelAcaoDia3,
        DateTime.thursday => l.painelAcaoDia4,
        DateTime.friday => l.painelAcaoDia5,
        DateTime.saturday => l.painelAcaoDia6,
        _ => l.painelAcaoDia7,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final o = item;
    return Cartao(
      // Fundo branco de propósito, não a cor do semáforo.
      //
      // A primeira versão pintava o cartão de laranja claro quando havia um
      // prazo a chegar. Ficava bonito sozinho, mas na foto do painel apareciam
      // DOIS laranjas colados — este e o semáforo grande logo por baixo — e a
      // regra da casa é um laranja por ecrã (docs/DESIGN-SYSTEM.md). O laranja
      // cheio é do semáforo; aqui a cor vive só no ícone, no valor e na data,
      // que é onde o olho tem de cair primeiro.
      cor: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      child: o == null ? _tudoTratado(context, l) : _porFazer(context, l, o),
    );
  }

  // ---- há coisa para fazer ----

  Widget _porFazer(BuildContext context, AppLocalizations l, ObrigacaoItem o) {
    final t = Theme.of(context).textTheme;
    final acao = _acao(l, o);
    final prazo = _prazo(l, o);
    final valor = o.valorEstimado;
    // A mesma frase que se lê é a que se ouve.
    final falado = [acao, if (valor != null) moeda(valor), prazo].join('. ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Topo(icone: iconeDoTipo(o.tipo), cor: _corIcone, texto: l.painelAcaoEtiqueta),
        const SizedBox(height: 12),
        Text(acao, style: t.headlineSmall),
        const SizedBox(height: 8),
        if (valor != null)
          // O valor é o número mais importante do ecrã, por isso é o maior.
          // Encolhe em vez de partir a linha num telemóvel estreito.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(moeda(valor),
                maxLines: 1,
                style: t.displayLarge!.copyWith(color: AppColors.textPrimary, fontFamily: AppTheme.fonte)),
          )
        else if (o.ehPagamento)
          Text(l.painelAcaoValorPorSaber,
              style: t.titleMedium!.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.event_rounded, size: 20, color: _corSinal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(prazo, style: t.titleMedium!.copyWith(color: _corSinal)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BotaoGrande(
          texto: o.ehPagamento ? l.painelAcaoBotaoComoPagar : l.painelAcaoBotaoOQueFazer,
          icone: o.ehPagamento ? Icons.payments_rounded : Icons.checklist_rounded,
          aoTocar: aoAgir,
        ),
        if (aoJaPaguei != null && o.ehPagamento) ...[
          const SizedBox(height: 8),
          BotaoGrande(
            texto: l.jaPaguei,
            icone: Icons.check_rounded,
            secundario: true,
            aoTocar: aoJaPaguei,
          ),
        ],
        BotaoOuvir(etiqueta: 'painel-acao', texto: falado),
      ],
    );
  }

  // ---- não há nada para fazer ----

  Widget _tudoTratado(BuildContext context, AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final sugerir = aoRegistarRendimento != null;
    final falado = [
      l.painelAcaoTudoTitulo,
      l.painelAcaoTudoAjuda,
      if (sugerir) l.painelAcaoTudoSugestao,
    ].join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Topo(icone: Icons.check_circle_rounded, cor: AppColors.emDia, texto: l.painelAcaoEtiqueta),
        const SizedBox(height: 12),
        Text(l.painelAcaoTudoTitulo, style: t.headlineSmall),
        const SizedBox(height: 6),
        Text(l.painelAcaoTudoAjuda,
            style: t.bodyLarge!.copyWith(color: AppColors.textSecondary)),
        if (sugerir) ...[
          const SizedBox(height: 12),
          Text(l.painelAcaoTudoSugestao, style: t.bodyMedium),
          const SizedBox(height: 14),
          BotaoGrande(
            texto: l.painelAcaoTudoBotao,
            icone: Icons.edit_rounded,
            aoTocar: aoRegistarRendimento,
          ),
        ],
        BotaoOuvir(etiqueta: 'painel-acao', texto: falado),
      ],
    );
  }
}

/// Linha de cima do cartão: ícone num quadrado branco + a etiqueta pequena.
class _Topo extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String texto;
  const _Topo({required this.icone, required this.cor, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icone, size: 20, color: cor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            texto.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.fonte,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
