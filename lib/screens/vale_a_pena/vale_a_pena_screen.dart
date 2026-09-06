import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/carro.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/perfil_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';

/// "Vale a pena esta corrida?" — a porta de entrada da app.
///
/// Um motorista ou um estafeta olha para uma corrida no telemóvel e quer saber,
/// em três segundos, se depois de tudo pago ainda lhe sobra alguma coisa. Por
/// isso o ecrã é curto: o que te pagam, os quilómetros, os minutos (se
/// souberes) — e a resposta num cartão que tem a cor da resposta.
///
/// Está aberta no plano grátis (`feature_flags.vale_a_pena`, free = true): sem
/// cadeado nenhum, de propósito. É também a página que vive no site e traz
/// gente da Google — seria estranho estar fechada aqui.
///
/// A conta em si não vive aqui: está em `lib/regras/vale_a_pena.dart`, pura e
/// testada. Este ficheiro só pergunta, mostra e explica.
///
/// **A regra do laranja:** o cartão da resposta é verde, cinzento ou vermelho —
/// nunca laranja. O único laranja possível neste ecrã é o aviso de que falta um
/// número do carro, e esse só aparece quando não há nenhum outro.
class ValeAPenaScreen extends StatefulWidget {
  /// Só para fotos/testes: fixa o "hoje". Na app é sempre [hojeLisboa].
  final DateTime? hoje;
  const ValeAPenaScreen({super.key, this.hoje});

  @override
  State<ValeAPenaScreen> createState() => _ValeAPenaScreenState();
}

class _ValeAPenaScreenState extends State<ValeAPenaScreen> {
  final _pagam = TextEditingController();
  final _km = TextEditingController();
  final _minutos = TextEditingController();
  final _consumo = TextEditingController();
  final _preco = TextEditingController();
  final _desgaste = TextEditingController();

  Retencao _retencao = Retencao.padrao;
  bool _leuOPerfil = false;

  /// Dia do abastecimento de onde veio o preço. `null` = o preço é escrito
  /// pela pessoa, e aí o ecrã explica-lhe porquê.
  DateTime? _precoDe;

  DateTime get _hoje => widget.hoje ?? hojeLisboa();

  @override
  void dispose() {
    _pagam.dispose();
    _km.dispose();
    _minutos.dispose();
    _consumo.dispose();
    _preco.dispose();
    _desgaste.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Corre antes do primeiro desenho E outra vez sempre que os carros chegam
    // do servidor (o `watch` do build faz o aviso). Como só preenche campos
    // vazios, pode correr as vezes que forem precisas sem pisar o que a pessoa
    // escreveu.
    _preencherOQueJaSabemos();
  }

  void _preencherOQueJaSabemos() {
    final l = AppLocalizations.of(context);
    final carros = context.read<CarrosStore>().carros;
    final linhas = carros.isEmpty
        ? const <AbastecimentoLinha>[]
        : context
            .read<CarrosStore>()
            .abastecimentosDe(carros.first.id)
            .map((a) => a.linha)
            .toList();

    if (_desgaste.text.isEmpty) _desgaste.text = l.vpDesgasteSugerido;

    if (_consumo.text.isEmpty) {
      final consumo = consumoDosAbastecimentos(linhas);
      if (consumo != null) _consumo.text = _escreve(consumo, 1);
    }
    if (_preco.text.isEmpty) {
      final preco = precoDoUltimoAbastecimento(linhas);
      if (preco != null) {
        _preco.text = _escreve(preco.valor, 3);
        _precoDe = preco.data;
      }
    }
    if (!_leuOPerfil) {
      final perfil = context.read<PerfilStore>().perfil;
      if (perfil != null) {
        _leuOPerfil = true;
        // A escolha que a pessoa já fez nos recibos dela vale aqui também.
        _retencao = switch (perfil.retencaoOpcao) {
          '25' => Retencao.vinteCinco,
          'dispensa' => Retencao.dispensa,
          _ => Retencao.padrao,
        };
      }
    }
  }

  /// Número com vírgula, como se escreve em Portugal (e como o campo o lê).
  String _escreve(double valor, int casas) =>
      valor.toStringAsFixed(casas).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final r = context.watch<RegrasStore>().regras;
    final carrosStore = context.watch<CarrosStore>();
    final perfil = context.watch<PerfilStore>().perfil;

    // O carro por omissão é o primeiro, como no ecrã do carro. Quem tem dois
    // troca lá; aqui a pergunta é da corrida, não do carro.
    final Carro? carro = carrosStore.carros.isEmpty ? null : carrosStore.carros.first;
    final eletrico = carro?.combustivel == Combustivel.eletrico;

    final pagam = lerNumero(_pagam.text);
    final km = lerNumero(_km.text);
    final minutos = int.tryParse(_minutos.text.trim());
    final consumo = lerNumero(_consumo.text);
    final preco = lerNumero(_preco.text);
    final desgaste = lerNumero(_desgaste.text) ?? 0.0;

    final faltaConsumo = consumo == null || consumo <= 0;
    final faltaPreco = preco == null || preco <= 0;
    final jaEscreveu = pagam != null && pagam > 0;

    // Quem está nos 12 primeiros meses de atividade não paga Segurança Social.
    final abertura = perfil?.dataAbertura;
    final isentoSs =
        abertura != null && mesesDeIsencaoRestantes(abertura, _hoje, r) > 0;

    // O IRS estimado precisa de saber o ano da pessoa. Se o onboarding não
    // guardou nada, a conta usa o escalão mais baixo e diz-o.
    final mensal = perfil?.rendimentoMensalEstimado;
    final rendimentoAnual = mensal == null ? null : mensal * 12;

    // Os testes de "não é nulo" estão todos escritos aqui, e não escondidos
    // nas variáveis de cima, porque o Dart só deixa usar um número que pode ser
    // nulo depois de o ver testado no mesmo sítio onde é usado.
    final conta = (pagam != null &&
            pagam > 0 &&
            km != null &&
            km >= 0 &&
            consumo != null &&
            consumo > 0 &&
            preco != null &&
            preco > 0)
        ? calcularValeAPena(
            pagam: pagam,
            km: km,
            minutos: minutos,
            consumoPor100: consumo,
            precoUnidade: preco,
            desgastePorKm: desgaste,
            retencao: _retencao,
            rendimentoAnualEstimado: rendimentoAnual,
            tipo: perfil?.tipoRendimento ?? TipoRendimento.servicos,
            isentoSs: isentoSs,
            ano: _hoje.year,
            r: r,
          )
        : null;

    final String? falta = (faltaConsumo && faltaPreco)
        ? l.vpFaltaOsDois
        : faltaPreco
            ? l.vpFaltaPreco
            : faltaConsumo
                ? l.vpFaltaConsumo
                : null;

    // Com o teclado aberto, a resposta ficava TODA abaixo da dobra a 360 e a
    // 390 px: a pessoa escrevia os 18 € e os 12 km e não via número nenhum —
    // e escrever com o teclado aberto é exactamente o que ela faz. Apanhado
    // pela fábrica de fotos (vale_sobra_bem_pequeno_teclado_br).
    //
    // A barra em baixo só existe ENQUANTO o teclado está aberto: assim não
    // repete o número quando ele já se vê no cartão.
    final tecladoAberto = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(title: Text(l.vpTitulo)),
      bottomNavigationBar: (conta != null && tecladoAberto)
          ? _BarraResposta(conta: conta)
          : null,
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(l.vpSubtitulo, style: t.bodyLarge),
          TituloSeccao(l.vpACorrida),
          Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CampoValor(
                  controlador: _pagam,
                  rotulo: l.vpQuantoPagam,
                  autofocus: false,
                  aoMudar: (_) => setState(() {}),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 14),
                  child: Text(l.vpQuantoPagamAjuda, style: t.bodySmall),
                ),
                _CampoNumero(
                  chave: const Key('vp_km'),
                  controlador: _km,
                  rotulo: l.vpQuantosKm,
                  sufixo: l.vpKmSufixo,
                  aoMudar: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                _CampoNumero(
                  chave: const Key('vp_minutos'),
                  controlador: _minutos,
                  rotulo: l.vpQuantosMinutos,
                  sufixo: l.vpMinutosSufixo,
                  ajuda: l.vpMinutosAjuda,
                  inteiro: true,
                  aoMudar: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (conta != null)
            _CartaoResposta(
              conta: conta,
              eletrico: eletrico,
              retencao: _retencao,
              regras: r,
              aoTrocarRetencao: (nova) => setState(() => _retencao = nova),
            )
          else if (jaEscreveu && falta != null)
            // O único laranja possível neste ecrã — e só quando não há resposta
            // nenhuma para mostrar no lugar dele.
            Aviso(falta, tom: Semaforo.amarelo)
          else
            Cartao(
              child: Text(l.vpEscreveParaVer,
                  style: t.bodyLarge!.copyWith(color: AppColors.textSecondary)),
            ),
          TituloSeccao(l.vpOTeuCarro),
          Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CampoNumero(
                  chave: const Key('vp_consumo'),
                  controlador: _consumo,
                  rotulo: l.vpConsumo,
                  sufixo: eletrico ? l.vpConsumoSufixoKwh : l.vpConsumoSufixoLitros,
                  ajuda: l.vpConsumoAjuda,
                  aoMudar: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                _CampoNumero(
                  chave: const Key('vp_preco'),
                  controlador: _preco,
                  rotulo: eletrico ? l.vpPrecoKwh : l.vpPrecoLitro,
                  sufixo: l.euros,
                  aoMudar: (_) => setState(() {}),
                ),
                const SizedBox(height: 6),
                Text(
                  _precoDe == null
                      ? '${l.vpPrecoEscreveTu} ${l.vpPrecoPorque}'
                      : l.vpPrecoDoAbastecimento(dataPt(_precoDe!)),
                  style: t.bodySmall,
                ),
                const SizedBox(height: 14),
                _CampoNumero(
                  chave: const Key('vp_desgaste'),
                  controlador: _desgaste,
                  rotulo: l.vpDesgastePorKm,
                  sufixo: l.vpDesgasteSufixo,
                  ajuda: l.vpDesgasteAjuda,
                  aoMudar: (_) => setState(() {}),
                ),
                if (conta != null) ...[
                  const SizedBox(height: 10),
                  Text(l.vpCadaKmCusta(moeda(conta.custoPorKm)), style: t.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A resposta: o número grande na cor do resultado e, por baixo, para onde foi
/// cada euro. Tudo no mesmo cartão de propósito — quem lê o número quer logo a
/// seguir saber quem lho comeu.
class _CartaoResposta extends StatelessWidget {
  final ContaDaCorrida conta;
  final bool eletrico;
  final Retencao retencao;
  final RegrasLegais regras;
  final ValueChanged<Retencao> aoTrocarRetencao;

  const _CartaoResposta({
    required this.conta,
    required this.eletrico,
    required this.retencao,
    required this.regras,
    required this.aoTrocarRetencao,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    // Fundo em tom claro e texto forte por cima: em verde forte com letras
    // brancas as linhas pequenas ficavam abaixo do contraste mínimo (4,5:1).
    final fundo = switch (conta.nivel) {
      NivelSobra.bem => AppColors.emDiaClaro,
      NivelSobra.pouco => AppColors.surface2,
      NivelSobra.perde => AppColors.passouClaro,
    };
    final forte = switch (conta.nivel) {
      NivelSobra.bem => AppColors.primaryDark,
      NivelSobra.pouco => AppColors.textPrimary,
      NivelSobra.perde => AppColors.passou,
    };
    final frase = switch (conta.nivel) {
      NivelSobra.bem => l.vpNivelBem,
      NivelSobra.pouco => l.vpNivelPouco,
      NivelSobra.perde => l.vpNivelPerde,
    };

    final notas = <String>[
      if (conta.isentoSs) l.vpSsIsentoNota,
      if (conta.irsRetidoNaHora) l.vpIrsRetidoNota else l.vpIrsEstimadoNota,
      if (conta.irsNoMinimo) l.vpIrsNoMinimoNota,
      if (conta.semIrsAPagar) l.vpSemIrsNota,
      l.vpDesgasteNota,
    ];

    // A frase toda para quem prefere ouvir a ler — e é muita gente aqui.
    final falado = [
      l.vpTitulo,
      l.vpFraseConta(
        moeda(conta.pagam),
        moeda(conta.combustivel),
        moeda(conta.desgaste),
        moeda(conta.segurancaSocial),
        moeda(conta.irs),
        moeda(conta.sobra),
      ),
      if (conta.porHora != null && conta.minutos != null)
        l.vpFrasePorHora(conta.minutos!, moeda(conta.porHora!)),
      frase,
      l.vpEstimativa,
    ].join(' ');

    return Cartao(
      cor: fundo,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.vpFicaParaTi, style: t.titleSmall!.copyWith(color: forte)),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(moeda(conta.sobra),
                key: const Key('vp_sobra'),
                style: t.displayMedium!.copyWith(color: forte)),
          ),
          const SizedBox(height: 4),
          Text(frase, style: t.bodyLarge),
          const SizedBox(height: 6),
          Text(
            conta.porHora == null
                ? l.vpPorHoraFalta
                : l.vpPorHora(moeda(conta.porHora!)),
            style: conta.porHora == null ? t.bodySmall : t.titleMedium,
          ),
          const Divider(height: 28),
          TituloSeccao(l.vpParaOndeFoi),
          LinhaValor(l.vpPagamTe, moeda(conta.pagam)),
          LinhaValor(eletrico ? l.vpEnergia : l.vpCombustivel,
              _menos(conta.combustivel)),
          LinhaValor(l.vpDesgaste, _menos(conta.desgaste)),
          LinhaValor(l.vpSs, _menos(conta.segurancaSocial)),
          LinhaValor(l.vpIrs, _menos(conta.irs)),
          const SizedBox(height: 8),
          Text(notas.join('\n'), style: t.bodySmall),
          TituloSeccao(l.vpImposto),
          Text(l.vpImpostoAjuda, style: t.bodySmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pilula(
                texto: l.vpSemRetencao,
                selecionado: retencao == Retencao.dispensa,
                aoTocar: () => aoTrocarRetencao(Retencao.dispensa),
              ),
              _Pilula(
                texto: l.vpRetencaoTiram(pct(regras.n('retencao_padrao'), casas: 0)),
                selecionado: retencao == Retencao.padrao,
                aoTocar: () => aoTrocarRetencao(Retencao.padrao),
              ),
              _Pilula(
                texto: l.vpRetencaoTiram(pct(regras.n('retencao_opcao'), casas: 0)),
                selecionado: retencao == Retencao.vinteCinco,
                aoTocar: () => aoTrocarRetencao(Retencao.vinteCinco),
              ),
            ],
          ),
          const SizedBox(height: 4),
          BotaoOuvir(etiqueta: 'vale-a-pena', texto: falado),
          Text(l.vpEstimativa, style: t.bodySmall),
        ],
      ),
    );
  }

  /// Zero escreve-se "0,00 €"; o resto leva o sinal de menos, para se ver que
  /// aquilo saiu do bolso.
  // O MESMO sinal de menos do resto do cartao. Estava aqui o menos tipografico
  // (U+2212) e no numero grande o hifen do moeda(): lado a lado no mesmo cartao
  // viam-se dois tracos de larguras diferentes (fabrica de fotos,
  // vale_perde_pequeno_br).
  String _menos(double valor) => valor == 0 ? moeda(0) : '-${moeda(valor)}';
}

/// Campo de número com rótulo, sufixo e ajuda. Aceita vírgula e ponto, porque
/// quem escreve 6,4 e quem escreve 6.4 têm os dois razão.
class _CampoNumero extends StatelessWidget {
  final Key chave;
  final TextEditingController controlador;
  final String rotulo;
  final String sufixo;
  final String? ajuda;
  final bool inteiro;
  final ValueChanged<String> aoMudar;

  const _CampoNumero({
    required this.chave,
    required this.controlador,
    required this.rotulo,
    required this.sufixo,
    required this.aoMudar,
    this.ajuda,
    this.inteiro = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: chave,
      controller: controlador,
      keyboardType: TextInputType.numberWithOptions(decimal: !inteiro),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(inteiro ? r'[0-9]' : r'[0-9.,]')),
      ],
      style: Theme.of(context).textTheme.titleLarge,
      decoration: InputDecoration(
        labelText: rotulo,
        helperText: ajuda,
        // A ajuda é uma frase inteira: sem isto ficava cortada a 360 px.
        helperMaxLines: 3,
        suffixText: sufixo,
      ),
      onChanged: aoMudar,
    );
  }
}

/// Pílula de escolha. Não é um `ChoiceChip` pela mesma razão que a dos recibos:
/// o texto tem de QUEBRAR linha em vez de ser cortado a 360 px e em PT-BR.
class _Pilula extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback aoTocar;

  const _Pilula({required this.texto, required this.selecionado, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selecionado ? AppColors.primaryLight : AppColors.surface,
      borderRadius: AppTheme.cantosPequenos,
      child: InkWell(
        borderRadius: AppTheme.cantosPequenos,
        onTap: aoTocar,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selecionado) ...[
                const Icon(Icons.check_rounded, size: 20, color: AppColors.primaryDeep),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontFamily: AppTheme.fonte,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selecionado ? AppColors.primaryDeep : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A resposta em pequeno, colada ao teclado.
///
/// Não é um resumo bonito: é o número que a pessoa está a tentar ver enquanto
/// escreve. Mesma cor e mesma palavra do cartão grande, para não parecerem
/// duas contas diferentes.
class _BarraResposta extends StatelessWidget {
  final ContaDaCorrida conta;
  const _BarraResposta({required this.conta});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final fundo = switch (conta.nivel) {
      NivelSobra.bem => AppColors.emDiaClaro,
      NivelSobra.pouco => AppColors.surface2,
      NivelSobra.perde => AppColors.passouClaro,
    };
    final forte = switch (conta.nivel) {
      NivelSobra.bem => AppColors.primaryDark,
      NivelSobra.pouco => AppColors.textPrimary,
      NivelSobra.perde => AppColors.passou,
    };
    return Material(
      color: fundo,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(l.vpFicaParaTi,
                    style: t.titleSmall!.copyWith(color: forte),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 10),
              Text(moeda(conta.sobra),
                  key: const Key('vp_sobra_barra'),
                  style: t.headlineSmall!.copyWith(color: forte, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
