import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/perfil.dart';
import '../../regras/regras.dart';
import '../../widgets/widgets.dart';
import 'recibos_widgets.dart';

/// Calculadora de recibo verde (Artur: "o dinheiro do Estado não é teu").
/// Valor → bruto, IVA, retenção, o que recebes na conta, o que é mesmo teu.
/// Só faz contas com [calcularRecibo]; nunca crava números legais.
class CalculadoraRecibo extends StatefulWidget {
  final RegrasLegais regras;
  final Perfil? perfil;
  final double faturacaoAnoAnterior;
  const CalculadoraRecibo({
    super.key,
    required this.regras,
    required this.perfil,
    required this.faturacaoAnoAnterior,
  });

  @override
  State<CalculadoraRecibo> createState() => _CalculadoraReciboState();
}

class _CalculadoraReciboState extends State<CalculadoraRecibo> {
  final _valor = TextEditingController();
  late Retencao _retencao;
  late bool _isento;

  /// Dispensa só se no ano anterior faturou menos do limite (art. 101.º-B) e
  /// o perfil não diz o contrário.
  bool get _podeDispensar =>
      podeDispensarRetencao(faturacaoAnoAnterior: widget.faturacaoAnoAnterior, r: widget.regras) &&
      !(widget.perfil?.faturouMais15kAnoAnterior ?? false);

  @override
  void initState() {
    super.initState();
    _isento = widget.perfil?.regimeIva != RegimeIva.normal;
    _retencao = switch (widget.perfil?.retencaoOpcao) {
      '25' => Retencao.vinteCinco,
      'dispensa' when _podeDispensar => Retencao.dispensa,
      _ => Retencao.padrao,
    };
  }

  @override
  void dispose() {
    _valor.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final valor = lerNumero(_valor.text);
    final calc = (valor == null || valor <= 0)
        ? null
        : calcularRecibo(valor: valor, retencao: _retencao, isentoIva: _isento, r: widget.regras);

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoCartao(icone: Icons.calculate_rounded, titulo: l.calcTitulo),
          const SizedBox(height: 14),
          TextField(
            key: const Key('calc_valor'),
            controller: _valor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: t.titleLarge,
            decoration: InputDecoration(
              labelText: l.calcValorRecibo,
              helperText: l.calcAjudaValor,
              suffixText: l.euros,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text(l.calcRetencao, style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChipEscolha(
                texto: l.calcRetencaoPadrao,
                selecionado: _retencao == Retencao.padrao,
                aoTocar: () => setState(() => _retencao = Retencao.padrao),
              ),
              ChipEscolha(
                texto: l.calcRetencao25,
                selecionado: _retencao == Retencao.vinteCinco,
                aoTocar: () => setState(() => _retencao = Retencao.vinteCinco),
              ),
              if (_podeDispensar)
                ChipEscolha(
                  texto: l.calcRetencaoDispensaCurta,
                  selecionado: _retencao == Retencao.dispensa,
                  aoTocar: () => setState(() => _retencao = Retencao.dispensa),
                ),
            ],
          ),
          if (_retencao == Retencao.dispensa) ...[
            const SizedBox(height: 8),
            Text('${l.calcRetencaoDispensa} ${l.calcDispensaAjuda}', style: t.bodySmall),
          ],
          const SizedBox(height: 16),
          Text(l.calcIva, style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChipEscolha(
                texto: l.calcIvaIsentoCurto,
                selecionado: _isento,
                aoTocar: () => setState(() => _isento = true),
              ),
              ChipEscolha(
                texto: l.calcIvaNormalCurto,
                selecionado: !_isento,
                aoTocar: () => setState(() => _isento = false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          if (calc == null)
            Text(l.calcSemValor, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary))
          else ...[
            // O número mais importante primeiro (e o maior do ecrã).
            CaixaDestaque(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.calcFicaTeu, style: t.titleSmall!.copyWith(color: AppColors.primaryDeep)),
                  const SizedBox(height: 2),
                  Text(moeda(calc.ficaTeu), style: t.displayMedium!.copyWith(color: AppColors.primaryDark)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            LinhaValor(l.calcBrutoExplicado, moeda(calc.valorSemIva)),
            LinhaValor(l.calcIvaValor, calc.isentoIva ? moeda(0) : '+ ${moeda(calc.iva)}'),
            LinhaValor(l.calcRetencaoValor, calc.retencao == 0 ? moeda(0) : '− ${moeda(calc.retencao)}'),
            LinhaValor(l.calcRecebesNaConta, moeda(calc.recebesNaConta)),
            const SizedBox(height: 4),
            Text(l.calcNaoETudoTeu, style: t.bodySmall),
            if (calc.mencaoIsencao != null) ...[
              const SizedBox(height: 12),
              CaixaCopiar(titulo: l.calcMencaoIsencao, texto: calc.mencaoIsencao!),
            ],
          ],
        ],
      ),
    );
  }
}
