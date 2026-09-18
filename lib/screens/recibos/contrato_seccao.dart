import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/perfil.dart';
import '../../regras/regras.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import 'recibos_widgets.dart';

/// O separador Recibos de quem tem CONTRATO (B3): o recibo de vencimento
/// explicado, o IRS do ano (reembolso ou acerto), o IRS Jovem, as faturas com
/// NIF e o que fazer se ficar desempregado. Tudo com «abre a página certa».
class ContratoSeccao extends StatelessWidget {
  final DateTime hoje;
  const ContratoSeccao({super.key, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = context.watch<RegrasStore>().regras;
    final perfil = context.watch<PerfilStore>().perfil;
    final salario = perfil?.salarioBrutoMensal;
    final idade = perfil?.idadeEm31Dez(hoje.year);
    final jovem = idade == null ? null : irsJovem(idadeEm31Dez: idade, anoDeRendimentos: 1, r: r);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Atalho(
          chave: 'recibo_vencimento',
          icone: Icons.receipt_rounded,
          titulo: l.contratoReciboTitulo,
          sub: salario == null ? l.contratoReciboSub : l.contratoReciboSubComSalario(moeda(salario, casas: 0)),
          aoTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ReciboVencimentoScreen(hoje: hoje))),
        ),
        const SizedBox(height: 12),
        if (jovem != null && jovem.elegivel) ...[
          Cartao(
            key: const Key('irs_jovem_card'),
            cor: AppColors.emDiaClaro,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CabecalhoCartao(icone: Icons.celebration_rounded, titulo: l.contratoIrsJovemTitulo),
                const SizedBox(height: 8),
                Text(l.contratoIrsJovemTexto(moeda(jovem.limiteEur, casas: 0)), style: t.bodyMedium),
                const SizedBox(height: 10),
                BotaoLigacao(texto: l.contratoAbrirPagina, url: 'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/questoes_frequentes/pages/faqs-00053.aspx'),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _CartaoFaturasNif(regras: r),
        const SizedBox(height: 12),
        _Atalho(
          chave: 'desemprego',
          icone: Icons.work_off_rounded,
          titulo: l.contratoDesempregoTitulo,
          sub: l.contratoDesempregoSub,
          aoTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DesempregoScreen(hoje: hoje))),
        ),
        const SizedBox(height: 12),
        _Atalho(
          chave: 'horas_extra',
          icone: Icons.more_time_rounded,
          titulo: l.contratoHorasExtraTitulo,
          sub: l.contratoHorasExtraSub,
          aoTocar: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => HorasExtraScreen(hoje: hoje))),
        ),
      ],
    );
  }
}

class _Atalho extends StatelessWidget {
  final String chave;
  final IconData icone;
  final String titulo;
  final String sub;
  final VoidCallback aoTocar;
  const _Atalho({required this.chave, required this.icone, required this.titulo, required this.sub, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Cartao(
      key: Key('contrato_$chave'),
      aoTocar: aoTocar,
      child: Row(
        children: [
          Icon(icone, color: AppColors.primaryDark, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: t.titleMedium),
                const SizedBox(height: 2),
                Text(sub, style: t.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
        ],
      ),
    );
  }
}

/// Um botão pequeno que abre uma página oficial no navegador.
class BotaoLigacao extends StatelessWidget {
  final String texto;
  final String url;
  const BotaoLigacao({super.key, required this.texto, required this.url});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(texto),
        ),
      );
}

class _CartaoFaturasNif extends StatelessWidget {
  final RegrasLegais regras;
  const _CartaoFaturasNif({required this.regras});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final d = regras.json('deducoes_irs') as Map;
    String linha(String chave) {
      final x = d[chave] as Map;
      return l.contratoDeducaoLinha('${x['pct']}', moeda((x['max'] as num).toDouble(), casas: 0));
    }

    return Cartao(
      key: const Key('faturas_nif_card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CabecalhoCartao(
            icone: Icons.receipt_long_rounded,
            titulo: l.contratoFaturasTitulo,
            direita: BotaoOuvir(etiqueta: 'faturas-nif', texto: '${l.contratoFaturasTexto} ${l.contratoFaturasPrazo}', soIcone: true),
          ),
          const SizedBox(height: 6),
          Text(l.contratoFaturasTexto, style: t.bodyMedium),
          const SizedBox(height: 10),
          _Linha(l.contratoDeducaoSaude, linha('saude')),
          _Linha(l.contratoDeducaoEducacao, linha('educacao')),
          _Linha(l.contratoDeducaoRendas, linha('rendas')),
          _Linha(l.contratoDeducaoIva, linha('iva_faturas')),
          _Linha(l.contratoDeducaoGerais, linha('gerais_familiares')),
          const SizedBox(height: 6),
          Text(l.contratoFaturasPrazo, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
          BotaoLigacao(texto: l.contratoAbrirEfatura, url: 'https://faturas.portaldasfinancas.gov.pt/'),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String esq;
  final String dir;
  const _Linha(this.esq, this.dir);
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(esq, style: t.bodyMedium)),
          Text(dir, style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- recibo de vencimento

/// O recibo de vencimento, linha a linha, e a estimativa do IRS do ano.
class ReciboVencimentoScreen extends StatefulWidget {
  final DateTime hoje;
  final String? brutoInicial;
  final String? retidoInicial;
  const ReciboVencimentoScreen({super.key, required this.hoje, this.brutoInicial, this.retidoInicial});

  @override
  State<ReciboVencimentoScreen> createState() => _ReciboVencimentoScreenState();
}

class _ReciboVencimentoScreenState extends State<ReciboVencimentoScreen> {
  late final TextEditingController _bruto;
  late final TextEditingController _retido;

  @override
  void initState() {
    super.initState();
    final salario = context.read<PerfilStore>().perfil?.salarioBrutoMensal;
    _bruto = TextEditingController(text: widget.brutoInicial ?? (salario == null ? '' : moeda(salario, comSimbolo: false, casas: 0)));
    _retido = TextEditingController(text: widget.retidoInicial ?? '');
  }

  @override
  void dispose() {
    _bruto.dispose();
    _retido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = context.watch<RegrasStore>().regras;
    final bruto = lerNumero(_bruto.text) ?? 0;
    final retido = lerNumero(_retido.text) ?? 0;
    final rv = lerReciboVencimento(bruto: bruto, irsRetido: retido, r: r);
    final e = estimarIrsContrato(brutoMensal: bruto, irsRetidoMensal: retido, ano: widget.hoje.year, r: r);

    return Scaffold(
      appBar: AppBar(title: Text(l.contratoReciboTitulo), actions: const [BotaoPalavras(termos: ['irs', 'ss', 'retencao', 'anexo_a', 'ias'])]),
      body: ListView(
        padding: paddingEcra,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(l.reciboExplica, style: t.bodyLarge)),
              BotaoOuvir(
                etiqueta: 'recibo-explica',
                texto: bruto > 0
                    ? '${l.reciboExplica} ${l.reciboLinhaLiquido}: ${moeda(rv.liquido)}. ${e.reembolso ? l.reciboAnoReembolso(moeda(e.diferenca)) : l.reciboAnoAcerto(moeda(-e.diferenca))}.'
                    : l.reciboExplica,
                soIcone: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bruto,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.reciboBruto, suffixText: l.euros, prefixIcon: const Icon(Icons.payments_outlined)),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _retido,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l.reciboIrsRetido, suffixText: l.euros, prefixIcon: const Icon(Icons.account_balance_outlined)),
            onChanged: (_) => setState(() {}),
          ),
          if (bruto > 0) ...[
            const SizedBox(height: 16),
            Cartao(
              key: const Key('recibo_linhas'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LinhaRecibo(l.reciboLinhaBruto, moeda(rv.bruto), l.reciboLinhaBrutoAjuda),
                  _LinhaRecibo(l.reciboLinhaSs(moeda(rv.pctSs, comSimbolo: false, casas: 0)), '− ${moeda(rv.ssTrabalhador)}', l.reciboLinhaSsAjuda),
                  _LinhaRecibo(l.reciboLinhaIrs, '− ${moeda(rv.irsRetido)}', l.reciboLinhaIrsAjuda),
                  const Divider(height: 20),
                  Row(
                    children: [
                      Expanded(child: Text(l.reciboLinhaLiquido, style: t.titleMedium)),
                      Text(moeda(rv.liquido), style: t.headlineSmall!.copyWith(color: AppColors.primaryDark)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Cartao(
              key: const Key('recibo_irs_ano'),
              cor: e.reembolso ? AppColors.emDiaClaro : AppColors.aVencerClaro,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CabecalhoCartao(
                    icone: e.reembolso ? Icons.savings_rounded : Icons.warning_amber_rounded,
                    titulo: e.reembolso ? l.reciboAnoReembolso(moeda(e.diferenca)) : l.reciboAnoAcerto(moeda(-e.diferenca)),
                  ),
                  const SizedBox(height: 8),
                  Text(l.reciboAnoTexto(moeda(e.brutoAnual, casas: 0), moeda(e.imposto), moeda(e.retidoAnual)), style: t.bodyMedium),
                  const SizedBox(height: 6),
                  Text(l.reciboAnoNota, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          NotaInfo(l.reciboFonte),
        ],
      ),
    );
  }
}

class _LinhaRecibo extends StatelessWidget {
  final String nome;
  final String valor;
  final String ajuda;
  const _LinhaRecibo(this.nome, this.valor, this.ajuda);
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(nome, style: t.titleSmall)),
              Text(valor, style: t.titleSmall),
            ],
          ),
          Text(ajuda, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- desemprego

class DesempregoScreen extends StatefulWidget {
  final DateTime hoje;
  const DesempregoScreen({super.key, required this.hoje});
  @override
  State<DesempregoScreen> createState() => _DesempregoScreenState();
}

class _DesempregoScreenState extends State<DesempregoScreen> {
  int _meses = 24;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = context.watch<RegrasStore>().regras;
    final salario = context.watch<PerfilStore>().perfil?.salarioBrutoMensal ?? r.n('smn');
    final d = estimarDesemprego(diasDeDescontosEm24Meses: _meses * 30, salarioBrutoMensal: salario, dataDesemprego: widget.hoje, r: r);

    return Scaffold(
      appBar: AppBar(title: Text(l.contratoDesempregoTitulo), actions: const [BotaoPalavras(termos: ['ss', 'ss_direta', 'iefp', 'ias'])]),
      body: ListView(
        padding: paddingEcra,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(l.desempregoExplica, style: t.bodyLarge)),
              BotaoOuvir(
                etiqueta: 'desemprego-explica',
                texto: '${l.desempregoExplica} ${d.temDireito ? l.desempregoTemDireito : l.desempregoFaltam(d.diasQueFaltam)} ${l.desempregoPedirAte(dataPt(d.pedirAte))}',
                soIcone: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(l.desempregoMesesPergunta, style: t.titleMedium),
          Slider(
            value: _meses.toDouble(),
            min: 0,
            max: 24,
            divisions: 24,
            label: '$_meses',
            onChanged: (v) => setState(() => _meses = v.round()),
          ),
          Text(l.desempregoMeses(_meses), style: t.bodyMedium),
          const SizedBox(height: 12),
          Cartao(
            key: const Key('desemprego_resultado'),
            cor: d.temDireito ? AppColors.emDiaClaro : AppColors.aVencerClaro,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.temDireito ? l.desempregoTemDireito : l.desempregoFaltam(d.diasQueFaltam), style: t.titleMedium),
                if (d.temDireito) ...[
                  const SizedBox(height: 8),
                  Text(l.desempregoValor(moeda(d.valorMensalEstimado), moeda(salario, casas: 0)), style: t.bodyMedium),
                ],
                const SizedBox(height: 8),
                Text(l.desempregoPedirAte(dataPt(d.pedirAte)), style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TituloSeccao(l.desempregoPassosTitulo),
          _Passo(1, l.desempregoPasso1),
          _Passo(2, l.desempregoPasso2),
          _Passo(3, l.desempregoPasso3),
          const SizedBox(height: 8),
          BotaoLigacao(texto: l.desempregoAbrirSs, url: 'https://app.seg-social.pt/sso/login'),
          BotaoLigacao(texto: l.desempregoAbrirIefp, url: 'https://iefponline.iefp.pt/'),
          const SizedBox(height: 8),
          NotaInfo(l.desempregoFonte),
        ],
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  final int n;
  final String texto;
  const _Passo(this.n, this.texto);
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Text('$n', style: t.titleSmall!.copyWith(color: AppColors.primaryDark)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: t.bodyMedium)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- horas extra

class HorasExtraScreen extends StatefulWidget {
  final DateTime hoje;
  const HorasExtraScreen({super.key, required this.hoje});
  @override
  State<HorasExtraScreen> createState() => _HorasExtraScreenState();
}

class _HorasExtraScreenState extends State<HorasExtraScreen> {
  bool _maisDe100 = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = context.watch<RegrasStore>().regras;
    final salario = context.watch<PerfilStore>().perfil?.salarioBrutoMensal ?? r.n('smn');
    final h = valorHoraExtra(brutoMensal: salario, maisDe100hNoAno: _maisDe100, r: r);
    final ferias = r.n('ferias_dias_uteis').toInt();

    return Scaffold(
      appBar: AppBar(title: Text(l.contratoHorasExtraTitulo), actions: const [BotaoPalavras(termos: ['horas_extra', 'subsidio_natal', 'proporcional'])]),
      body: ListView(
        padding: paddingEcra,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(l.horasExplica(moeda(salario, casas: 0), moeda(h.base)), style: t.bodyLarge)),
              BotaoOuvir(
                etiqueta: 'horas-explica',
                texto: '${l.horasExplica(moeda(salario, casas: 0), moeda(h.base))} ${l.horasPrimeira}: ${moeda(h.primeiraHora)}. ${l.horasSeguintes}: ${moeda(h.horaSeguinte)}. ${l.horasFimSemana}: ${moeda(h.descansoOuFeriado)}.',
                soIcone: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              value: _maisDe100,
              onChanged: (v) => setState(() => _maisDe100 = v),
              contentPadding: EdgeInsets.zero,
              title: Text(l.horasMaisDe100, style: t.bodyMedium),
              activeThumbColor: AppColors.primary,
            ),
          ),
          Cartao(
            key: const Key('horas_extra_valores'),
            child: Column(
              children: [
                _LinhaValor(l.horasPrimeira, moeda(h.primeiraHora)),
                _LinhaValor(l.horasSeguintes, moeda(h.horaSeguinte)),
                _LinhaValor(l.horasFimSemana, moeda(h.descansoOuFeriado)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TituloSeccao(l.feriasTitulo),
          Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.feriasTexto(ferias), style: t.bodyMedium),
                const SizedBox(height: 8),
                Text(l.subsidiosTexto, style: t.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: 8),
          NotaInfo(l.horasFonte),
        ],
      ),
    );
  }
}

class _LinhaValor extends StatelessWidget {
  final String nome;
  final String valor;
  const _LinhaValor(this.nome, this.valor);
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(nome, style: t.bodyMedium)),
          Text(valor, style: t.titleMedium!.copyWith(color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}

/// Só para saber se o perfil tem contrato (usado pelo separador Recibos).
bool perfilTemContrato(Perfil? p) => p != null && p.temContrato;
