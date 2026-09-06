import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/carro.dart';
import '../../regras/regras.dart';
import '../../stores/dados_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import '../calendario/detalhe_obrigacao.dart';
import 'formulario_carro.dart';
import 'lembretes_carro.dart';
import 'nova_despesa.dart';
import 'novo_abastecimento.dart';
import 'widgets_carro.dart';

/// Tela 4 — O Carro (estrutura do Drivvo, adaptada a Portugal):
/// selector de carro no topo · lembretes em cartões com barra lateral na cor
/// do semáforo (IUC, inspeção, seguro, carta, revisão) · linha do tempo dos
/// abastecimentos com resumo do mês (€, km, €/km, L/100 km) · despesas com
/// NIF para o IRS · portagens e multas por pagar · "em breve" (centros de
/// inspeção, combustível mais barato). Sem carro: estado vazio + botão.
class CarroScreen extends StatefulWidget {
  /// Só para fotos/testes: fixa o "hoje". Na app é sempre [hojeLisboa].
  final DateTime? hoje;
  const CarroScreen({super.key, this.hoje});

  @override
  State<CarroScreen> createState() => _CarroScreenState();
}

class _CarroScreenState extends State<CarroScreen> {
  String? _carroId;

  DateTime get _hoje => widget.hoje ?? hojeLisboa();

  void _snack(String texto) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  String? _userIdOuAviso() {
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) _snack(AppLocalizations.of(context).carroSemSessao);
    return userId;
  }

  Future<void> _adicionarCarro() async {
    final l = AppLocalizations.of(context);
    final userId = _userIdOuAviso();
    if (userId == null) return;
    final carro = await mostrarFormularioCarro(context, userId: userId, hoje: _hoje);
    if (carro == null || !mounted) return;
    setState(() => _carroId = carro.id);
    final erroCalendario = context.read<ObrigacoesStore>().erro;
    _snack(erroCalendario == null ? l.carroGuardadoRecalculado : l.carroGuardadoSemCalendario);
  }

  Future<void> _adicionarAbastecimento(Carro carro) async {
    final l = AppLocalizations.of(context);
    final userId = _userIdOuAviso();
    if (userId == null) return;
    final ok = await mostrarNovoAbastecimento(context, userId: userId, carroId: carro.id, hoje: _hoje);
    if (ok == true && mounted) _snack(l.carroAbastecimentoGuardado);
  }

  Future<void> _adicionarDespesa(Carro carro) async {
    final l = AppLocalizations.of(context);
    final userId = _userIdOuAviso();
    if (userId == null) return;
    final ok = await mostrarNovaDespesa(context, userId: userId, carro: carro, hoje: _hoje);
    if (ok == true && mounted) _snack(l.carroDespesaGuardada);
  }

  Future<void> _atualizar() async {
    final userId = context.read<SessaoStore>().userId;
    if (userId != null) await context.read<CarrosStore>().carregar(userId);
  }

  void _abrirLembrete(Lembrete x) {
    final o = x.obrigacao;
    if (o != null) {
      mostrarDetalheObrigacao(context, obrigacao: o, hoje: _hoje);
    } else {
      mostrarInfoLembrete(context, lembrete: x, hoje: _hoje);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = context.watch<CarrosStore>();
    final plano = context.watch<PlanoStore>();
    final carros = store.carros;
    final limite = plano.limite('carros');
    final trancado = limite != null && carros.length >= limite;

    if (carros.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l.carroTitulo)),
        body: RefreshIndicator(
          onRefresh: _atualizar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: paddingEcra,
            children: [
              if (store.erro != null) ...[Aviso(l.erroRede, tom: Semaforo.vermelho), const SizedBox(height: 12)],
              const SizedBox(height: 40),
              Vazio(
                icone: Icons.directions_car_rounded,
                texto: l.carroSemCarro,
                acao: BotaoGrande(texto: l.carroAdicionar, icone: Icons.add_rounded, aoTocar: _adicionarCarro),
              ),
              const SizedBox(height: 24),
              _EmBreve(l: l),
            ],
          ),
        ),
      );
    }

    final carro = carros.firstWhere((c) => c.id == _carroId, orElse: () => carros.first);
    final hoje = _hoje;
    final r = context.watch<RegrasStore>().regras;
    final obrigacoes = context.watch<ObrigacoesStore>().itens;
    final lembretes = lembretesDoCarro(l, carro: carro, r: r, obrigacoes: obrigacoes, hoje: hoje);
    final abastecimentos = store.abastecimentosDe(carro.id).reversed.toList(); // mais recente primeiro
    final despesas = store.despesasDe(carro.id);
    final porPagar = despesas.where((d) => tiposComPrazo.contains(d.tipo) && !d.pago).toList()
      ..sort((a, b) => (a.dataLimite ?? a.data).compareTo(b.dataLimite ?? b.data));
    final diasUteisMulta = r.n('multa_pagamento_voluntario_dias_uteis').toInt();

    return Scaffold(
      appBar: AppBar(title: Text(l.carroTitulo)),
      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: paddingEcra,
          children: [
            if (store.erro != null) ...[Aviso(l.erroRede, tom: Semaforo.vermelho), const SizedBox(height: 12)],

            // ---- selector de carro (Drivvo: "Meu carro · Toyota Corolla · 83 765 km") ----
            _SelectorCarro(
              carros: carros,
              selecionado: carro,
              trancado: trancado,
              aoEscolher: (c) => setState(() => _carroId = c.id),
              aoAdicionar: _adicionarCarro,
            ),

            // ---- lembretes ----
            TituloSeccao(l.carroLembretes),
            if (lembretes.isEmpty)
              Cartao(child: Text(l.carroSemLembretes, style: Theme.of(context).textTheme.bodyMedium))
            else
              for (final x in lembretes)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CartaoLembrete(
                    key: ValueKey('lembrete-${x.tipo}'),
                    lembrete: x,
                    hoje: hoje,
                    aoTocar: () => _abrirLembrete(x),
                  ),
                ),

            // ---- abastecimentos ----
            const SizedBox(height: 6),
            TituloComMais(l.carroAbastecimentos,
                key: const ValueKey('sec-abastecimentos'),
                rotuloMais: l.calAdicionar,
                aoAdicionar: () => _adicionarAbastecimento(carro)),
            _CartaoAbastecimentos(
              abastecimentos: abastecimentos,
              custo: store.custoKm(carro.id),
              hoje: hoje,
            ),

            // ---- despesas com NIF ----
            const SizedBox(height: 14),
            TituloComMais(l.carroDespesas,
                key: const ValueKey('sec-despesas'),
                rotuloMais: l.calAdicionar,
                aoAdicionar: () => _adicionarDespesa(carro)),
            _CartaoDespesas(despesas: despesas, hoje: hoje),

            // ---- portagens e multas ----
            const SizedBox(height: 14),
            TituloSeccao(l.carroMultas),
            _CartaoMultas(porPagar: porPagar, diasUteis: diasUteisMulta, hoje: hoje),

            // ---- em breve ----
            const SizedBox(height: 14),
            _EmBreve(l: l),
          ],
        ),
      ),
    );
  }
}

/// Cartão do carro selecionado + chips para trocar + "Adicionar carro"
/// (com cadeado quando o plano já não deixa mais).
class _SelectorCarro extends StatelessWidget {
  final List<Carro> carros;
  final Carro selecionado;
  final bool trancado;
  final ValueChanged<Carro> aoEscolher;
  final VoidCallback aoAdicionar;
  const _SelectorCarro({
    required this.carros,
    required this.selecionado,
    required this.trancado,
    required this.aoEscolher,
    required this.aoAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final c = selecionado;
    final linha2 = c.kmAtual == null ? c.matricula : l.carroMatriculaKm(c.matricula, kmTxt(c.kmAtual!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Cartao(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                    child: const Icon(Icons.directions_car_rounded, color: AppColors.primaryDark, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.carroOTeuCarro, style: t.labelSmall),
                        Text(c.nomeOuMatricula, style: t.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(linha2, style: t.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (c.usoTvde) ...[
                    const SizedBox(width: 8),
                    Etiqueta('TVDE', cor: AppColors.emDiaClaro, corTexto: AppColors.primaryDeep, icone: Icons.local_taxi_rounded),
                  ],
                ],
              ),
              if (carros.length > 1 || !trancado) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (carros.length > 1)
                      for (final x in carros)
                        ChoiceChip(
                          label: Text(x.nomeOuMatricula),
                          selected: x.id == c.id,
                          showCheckmark: false,
                          labelStyle: TextStyle(color: x.id == c.id ? AppColors.primaryDark : AppColors.textPrimary),
                          onSelected: (_) => aoEscolher(x),
                        ),
                    if (!trancado)
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded, size: 18, color: AppColors.primaryDark),
                        label: Text(l.carroAdicionar),
                        labelStyle: const TextStyle(color: AppColors.primaryDark),
                        onPressed: aoAdicionar,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (trancado) ...[
          const SizedBox(height: 10),
          Cadeado(
            trancado: true,
            linha: l.carroCadeadoLinha,
            child: BotaoEscolha(
              texto: l.carroAdicionar,
              ajuda: l.carroAdicionarAjuda,
              icone: Icons.add_circle_outline_rounded,
              aoTocar: () {},
            ),
          ),
        ],
        const SizedBox(height: 6),
      ],
    );
  }
}

/// Resumo do mês (Drivvo: "R$ 1 632 · 950 km · 11,45 km/L") + linha do tempo.
class _CartaoAbastecimentos extends StatelessWidget {
  final List<Abastecimento> abastecimentos; // mais recente primeiro
  final CustoKm? custo;
  final DateTime hoje;
  const _CartaoAbastecimentos({required this.abastecimentos, required this.custo, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final doMes = abastecimentos.where((a) => a.data.year == hoje.year && a.data.month == hoje.month).toList();
    final gastoMes = doMes.fold<double>(0, (s, a) => s + a.valorTotal);
    final kms = doMes.where((a) => a.km != null).map((a) => a.km!).toList();
    final kmMes = kms.length >= 2 ? kms.reduce((a, b) => a > b ? a : b) - kms.reduce((a, b) => a < b ? a : b) : null;
    final nomeMesTitulo = nomeMes(hoje.month);
    final ultimos = abastecimentos.take(8).toList();

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface2, borderRadius: AppTheme.cantosPequenos),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.carroResumoMes('$nomeMesTitulo ${hoje.year}').toUpperCase(),
                    style: t.labelSmall!.copyWith(letterSpacing: 0.8)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    Estatistica(valor: moeda(gastoMes), rotulo: l.carroResumoGasto),
                    Estatistica(valor: kmMes == null ? '—' : kmTxt(kmMes), rotulo: l.carroResumoKm),
                    Estatistica(
                        valor: custo == null ? '—' : moeda(custo!.custoPorKm, comSimbolo: false),
                        rotulo: l.carroResumoEuroKm),
                    Estatistica(valor: custo == null ? '—' : litrosTxt(custo!.litrosPor100Km), rotulo: l.carroResumoL100),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(custo == null ? l.carroSemCustoKm : l.carroCompensa, style: t.bodySmall)),
                    BotaoOuvir(
                      etiqueta: 'carro-custo-km',
                      texto: custo == null ? l.carroSemCustoKm : l.carroCompensa,
                      soIcone: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (ultimos.isEmpty)
            Text(l.carroSemAbastecimentos, style: t.bodyMedium)
          else
            for (var i = 0; i < ultimos.length; i++) _linha(l, ultimos[i], ultimo: i == ultimos.length - 1),
        ],
      ),
    );
  }

  Widget _linha(AppLocalizations l, Abastecimento a, {required bool ultimo}) {
    final partes = <String>[
      if (a.km != null) l.carroKmCurto(kmTxt(a.km!)),
      if (a.litros != null && a.litros! > 0) l.carroPrecoLitro(moeda(a.valorTotal / a.litros!, comSimbolo: false, casas: 3)),
      if (a.posto != null && a.posto!.isNotEmpty) a.posto!,
    ];
    return ItemLinhaTempo(
      key: ValueKey('abast-${a.id}'),
      icone: Icons.local_gas_station_rounded,
      corFundo: AppColors.primaryLight,
      corIcone: AppColors.primaryDark,
      titulo: a.litros == null ? l.carroAbastecimentos : l.carroLitrosCurto(litrosTxt(a.litros!)),
      subtitulo: partes.join(' · '),
      valor: moeda(a.valorTotal),
      data: dataPt(a.data),
      etiqueta: a.comNif ? const EtiquetaNif() : null,
      ultimo: ultimo,
    );
  }
}

/// Total do ano com NIF em destaque + linha do tempo das despesas.
class _CartaoDespesas extends StatelessWidget {
  final List<DespesaCarro> despesas; // mais recente primeiro
  final DateTime hoje;
  const _CartaoDespesas({required this.despesas, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final comNifAno = despesas.where((d) => d.comNif && d.data.year == hoje.year).fold<double>(0, (s, d) => s + d.valor);
    final ultimas = despesas.take(8).toList();

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.carroDespesasAnoNif(hoje.year), style: t.labelSmall),
          const SizedBox(height: 2),
          Text(moeda(comNifAno), style: t.headlineMedium!.copyWith(color: AppColors.primaryDark)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(l.carroDespesasIrs, style: t.bodySmall)),
              BotaoOuvir(etiqueta: 'carro-despesas-nif', texto: l.carroDespesasIrs, soIcone: true),
            ],
          ),
          const SizedBox(height: 16),
          if (ultimas.isEmpty)
            Text(l.carroSemDespesas, style: t.bodyMedium)
          else
            for (var i = 0; i < ultimas.length; i++) _linha(l, ultimas[i], ultimo: i == ultimas.length - 1),
        ],
      ),
    );
  }

  Widget _linha(AppLocalizations l, DespesaCarro d, {required bool ultimo}) {
    final porPagar = tiposComPrazo.contains(d.tipo) && !d.pago;
    return ItemLinhaTempo(
      key: ValueKey('desp-${d.id}'),
      icone: iconeDespesa(d.tipo),
      corFundo: porPagar ? AppColors.passouClaro : AppColors.surface2,
      corIcone: porPagar ? AppColors.passou : AppColors.textPrimary,
      titulo: rotuloDespesa(l, d.tipo),
      subtitulo: d.descricao ?? (porPagar && d.dataLimite != null ? l.carroPagarAte(dataPt(d.dataLimite!)) : null),
      valor: moeda(d.valor),
      data: dataPt(d.data),
      etiqueta: d.comNif ? const EtiquetaNif() : null,
      ultimo: ultimo,
    );
  }
}

/// Portagens e multas ainda por pagar, com o prazo dos 15 dias úteis.
class _CartaoMultas extends StatelessWidget {
  final List<DespesaCarro> porPagar;
  final int diasUteis;
  final DateTime hoje;
  const _CartaoMultas({required this.porPagar, required this.diasUteis, required this.hoje});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(l.carroMultasNota(diasUteis), style: t.bodySmall)),
              BotaoOuvir(
                etiqueta: 'carro-multas-prazo',
                texto: l.carroMultasNota(diasUteis),
                soIcone: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (porPagar.isEmpty)
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.emDia, size: 22),
                const SizedBox(width: 8),
                Text(l.carroSemMultas, style: t.titleSmall),
              ],
            )
          else
            for (final d in porPagar) ...[
              Builder(builder: (context) {
                final limite = d.dataLimite;
                final dias = limite == null ? null : diasAte(limite, hoje);
                final cor = dias == null
                    ? AppColors.textSecondary
                    : (dias < 0 ? AppColors.passou : (dias <= 5 ? AppColors.aVencer : AppColors.emDia));
                final prazo = dias == null
                    ? l.carroSemData
                    : (dias < 0 ? l.calPassouHa(-dias) : (dias == 0 ? l.calEhHoje : l.calFaltamDias(dias)));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(width: 4, height: 40, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 12),
                      Icon(iconeDespesa(d.tipo), size: 22, color: AppColors.textPrimary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.descricao ?? rotuloDespesa(l, d.tipo), style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(
                              limite == null ? prazo : '$prazo · ${l.carroPagarAte(dataPt(limite))}',
                              style: TextStyle(fontFamily: AppTheme.fonte, fontSize: 13, fontWeight: FontWeight.w700, color: cor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(moeda(d.valor), style: t.titleMedium),
                    ],
                  ),
                );
              }),
            ],
        ],
      ),
    );
  }
}

/// Fase 2 (dados abertos): centros de inspeção perto e combustível mais
/// barato. Um cartão "Em breve" com uma linha de explicação cada.
class _EmBreve extends StatelessWidget {
  final AppLocalizations l;
  const _EmBreve({required this.l});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    Widget linha(IconData icone, String titulo, String texto) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: AppColors.textSubtle, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: t.titleSmall!.copyWith(color: AppColors.textSecondary)),
                  Text(texto, style: t.bodySmall),
                ],
              ),
            ),
          ],
        );
    return Cartao(
      cor: AppColors.surface2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Etiqueta(l.carroEmBreve, cor: AppColors.divider, corTexto: AppColors.textSecondary, icone: Icons.schedule_rounded),
          const SizedBox(height: 12),
          linha(Icons.map_rounded, l.carroCentrosInspecao, l.carroCentrosInspecaoLinha),
          const SizedBox(height: 12),
          linha(Icons.local_gas_station_outlined, l.carroCombustivelBarato, l.carroCombustivelBaratoLinha),
        ],
      ),
    );
  }
}
