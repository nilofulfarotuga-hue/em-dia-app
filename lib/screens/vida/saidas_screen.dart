import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/saida.dart';
import '../../regras/regras.dart';
import '../../stores/saidas_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import 'caixa_faturas.dart';
import 'detalhe_conta.dart';
import 'nova_saida.dart';

/// "O que sai" — as contas a pagar.
///
/// É o corpo da aba "Sai" da tela da vida: não traz Scaffold nem barra de
/// título, como a irmã das entradas, porque quem os põe é a tela de cima.
///
/// Três partes, por esta ordem, que é a ordem da pergunta que a pessoa traz:
///  1. **Quanto falta pagar este mês** — um número grande e mais nada;
///  2. **as contas deste mês**, pela data-limite, com o estado à direita;
///  3. **as contas em si** (o que se repete todos os meses), com o "+".
///
/// A regra do laranja: só o cartão de cima muda de cor. As linhas usam verde
/// para o que está pago e vermelho para o que passou do dia — assim nunca há
/// mais do que um elemento laranja no ecrã.
class SaidasScreen extends StatefulWidget {
  /// Só para fotos/testes: fixa o "hoje". Na app é sempre [hojeLisboa].
  final DateTime? hoje;
  const SaidasScreen({super.key, this.hoje});

  @override
  State<SaidasScreen> createState() => _SaidasScreenState();
}

class _SaidasScreenState extends State<SaidasScreen> {
  bool _arrancou = false;

  DateTime get _hoje => widget.hoje ?? hojeLisboa();

  @override
  void initState() {
    super.initState();
    // O primeiro carregamento não pode acontecer dentro do build (o build não
    // pode pedir nada ao servidor), por isso espera-se pelo primeiro quadro.
    WidgetsBinding.instance.addPostFrameCallback((_) => _arrancar());
  }

  Future<void> _arrancar() async {
    if (_arrancou || !mounted) return;
    _arrancou = true;
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) return;
    final store = context.read<SaidasStore>();
    await store.carregar(userId, hoje: _hoje);
    if (!mounted) return;
    // Mês novo, contas novas: se há contas a repetir e este mês ainda não tem
    // nenhuma linha, é o servidor que as gera. Sem isto o ecrã ficava vazio
    // no dia 1 até alguém mexer em alguma coisa.
    if (store.ativas.isNotEmpty && store.doMes(_hoje).isEmpty) {
      await store.gerarDoMes(userId, mes: _hoje);
    }
  }

  void _snack(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  String? _userIdOuAviso() {
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) _snack(AppLocalizations.of(context).saidasSemSessao);
    return userId;
  }

  Future<void> _atualizar() async {
    final userId = context.read<SessaoStore>().userId;
    if (userId != null) await context.read<SaidasStore>().carregar(userId, hoje: _hoje);
  }

  Future<void> _novaConta() async {
    final l = AppLocalizations.of(context);
    final userId = _userIdOuAviso();
    if (userId == null) return;
    final ok = await mostrarNovaSaida(context, userId: userId, hoje: _hoje);
    if (ok == true && mounted) _snack(l.saidasContaGuardada);
  }

  Future<void> _mudarConta(Saida s) async {
    final l = AppLocalizations.of(context);
    final userId = _userIdOuAviso();
    if (userId == null) return;
    final ok = await mostrarNovaSaida(context, userId: userId, hoje: _hoje, saida: s);
    if (ok == true && mounted) _snack(l.saidasContaGuardada);
  }

  void _abrirPagamento(SaidaPagamento p) {
    final store = context.read<SaidasStore>();
    mostrarDetalheConta(context, pagamento: p, saida: store.saidaDe(p), hoje: _hoje);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = context.watch<SaidasStore>();
    final doMes = store.doMes(_hoje);
    final atrasadas = store.atrasadasDeAntes(_hoje);
    final contas = store.ativas;

    return RefreshIndicator(
      onRefresh: _atualizar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: paddingEcra,
        children: [
          if (store.erro != null) ...[
            Aviso(l.erroRede, tom: Semaforo.vermelho),
            const SizedBox(height: 12),
          ],
          _CartaoFaltaPagar(
            falta: store.faltaPagarDoMes(_hoje),
            semValor: store.semValorDoMes(_hoje),
            temAtrasadas: store.temAtrasadas(_hoje),
          ),

          // O que ficou de meses anteriores vem antes do mês corrente: é o
          // que mais custa e o que a pessoa tem de resolver primeiro.
          if (atrasadas.isNotEmpty) ...[
            const SizedBox(height: 8),
            TituloSeccao(l.saidasAtrasadasDeAntes),
            for (final p in atrasadas) ...[
              _LinhaPagamento(
                pagamento: p,
                saida: store.saidaDe(p),
                hoje: _hoje,
                aoTocar: () => _abrirPagamento(p),
              ),
              const SizedBox(height: 8),
            ],
          ],

          const SizedBox(height: 8),
          TituloSeccao(l.saidasContasDoMes),
          if (doMes.isEmpty)
            Cartao(
              child: Text(l.saidasSemContasMes,
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            for (final p in doMes) ...[
              _LinhaPagamento(
                pagamento: p,
                saida: store.saidaDe(p),
                hoje: _hoje,
                aoTocar: () => _abrirPagamento(p),
              ),
              const SizedBox(height: 8),
            ],

          const SizedBox(height: 12),
          TituloSeccao(
            l.saidasAsTuasContas,
            acao: TextButton.icon(
              key: const Key('saidas_nova'),
              onPressed: _novaConta,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.add_circle_rounded, size: 22),
              label: Text(l.saidasNova),
            ),
          ),
          if (contas.isEmpty)
            Vazio(
              icone: Icons.receipt_long_rounded,
              texto: l.saidasSemContas,
              acao: BotaoGrande(
                texto: l.saidasNova,
                icone: Icons.add_rounded,
                aoTocar: _novaConta,
              ),
            )
          else
            for (final s in contas) ...[
              _LinhaConta(saida: s, hoje: _hoje, aoTocar: () => _mudarConta(s)),
              const SizedBox(height: 8),
            ],

          // A porta da caixa de correio fica NO FIM, e não em cima: escrever
          // uma conta à mão é o caminho de toda a gente; reencaminhar faturas
          // é o atalho de quem já percebeu a app.
          const SizedBox(height: 16),
          Cartao(
            key: const Key('saidas_atalho_caixa'),
            aoTocar: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CaixaFaturasScreen(hoje: widget.hoje),
            )),
            child: Row(
              children: [
                const Icon(Icons.forward_to_inbox_rounded, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.caixaAtalho, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(l.caixaAtalhoAjuda,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSubtle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// O número grande do topo. É o único sítio do ecrã que muda de cor:
/// vermelho se há prazo passado, laranja se ainda falta pagar, verde se está
/// tudo feito.
class _CartaoFaltaPagar extends StatelessWidget {
  final double falta;
  final int semValor;
  final bool temAtrasadas;
  const _CartaoFaltaPagar({
    required this.falta,
    required this.semValor,
    required this.temAtrasadas,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final tudoFeito = falta <= 0 && semValor == 0 && !temAtrasadas;
    final tom = temAtrasadas
        ? Semaforo.vermelho
        : (tudoFeito ? Semaforo.verde : Semaforo.amarelo);

    return Cartao(
      cor: tom.corClara,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.saidasFaltaPagar, style: t.titleSmall),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(moeda(falta), style: t.headlineLarge!.copyWith(color: tom.cor)),
          ),
          if (semValor > 0) ...[
            const SizedBox(height: 6),
            Text(l.saidasMaisSemValor(semValor), style: t.bodyMedium),
          ],
          if (temAtrasadas) ...[
            const SizedBox(height: 8),
            Text(l.saidasTemAtrasadas, style: t.bodyMedium),
          ] else if (tudoFeito) ...[
            const SizedBox(height: 8),
            Text(l.saidasTudoPago, style: t.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Uma conta deste mês: nome, dia, valor e a marca do estado.
class _LinhaPagamento extends StatelessWidget {
  final SaidaPagamento pagamento;
  final Saida? saida;
  final DateTime hoje;
  final VoidCallback aoTocar;
  const _LinhaPagamento({
    required this.pagamento,
    required this.saida,
    required this.hoje,
    required this.aoTocar,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final passou = pagamento.passou(hoje);
    final cor = pagamento.pago
        ? AppColors.emDia
        : (passou ? AppColors.passou : AppColors.textSecondary);
    final categoria = saida?.categoria ?? 'outro';

    return Cartao(
      aoTocar: aoTocar,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              pagamento.pago ? Icons.check_rounded : iconeCategoria(categoria),
              color: cor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saida?.nome.isNotEmpty == true ? saida!.nome : rotuloCategoria(l, categoria),
                  style: t.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitulo(l),
                  style: t.bodySmall!.copyWith(color: passou ? AppColors.passou : null),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pagamento.valor == null ? l.saidasValorPorSaber : moeda(pagamento.valor!),
                style: pagamento.valor == null ? t.bodySmall : t.titleMedium,
              ),
              if (pagamento.pago) ...[
                const SizedBox(height: 4),
                Etiqueta(l.saidasEstadoPago,
                    cor: AppColors.emDiaClaro,
                    corTexto: AppColors.primaryDeep,
                    icone: Icons.check_rounded),
              ] else if (pagamento.saltado) ...[
                const SizedBox(height: 4),
                Etiqueta(l.saidasEstadoSaltado,
                    cor: AppColors.surface2, corTexto: AppColors.textSecondary),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// A linha por baixo do nome diz sempre a mesma coisa: quando é.
  String _subtitulo(AppLocalizations l) {
    if (pagamento.pago) {
      return pagamento.pagoEm == null
          ? l.saidasDia(pagamento.dataLimite.day)
          : l.saidasPagoEm(dataPt(pagamento.pagoEm!));
    }
    if (pagamento.saltado) return l.saidasDia(pagamento.dataLimite.day);
    if (pagamento.passou(hoje)) return l.saidasEstadoPassou;
    final dias = pagamento.diasParaPrazo(hoje);
    if (dias == 0) return l.eHoje;
    if (dias <= 5) return l.faltamDias(dias);
    return l.saidasDia(pagamento.dataLimite.day);
  }
}

/// Uma conta que se repete todos os meses (a saída em si).
class _LinhaConta extends StatelessWidget {
  final Saida saida;
  final DateTime hoje;
  final VoidCallback aoTocar;
  const _LinhaConta({required this.saida, required this.hoje, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final dias = saida.diasParaFidelizacao(hoje);
    final avisaFidelizacao = dias != null && dias >= 0 && dias <= 30;

    return Cartao(
      aoTocar: aoTocar,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconeCategoria(saida.categoria), color: AppColors.textSecondary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(saida.nome, style: t.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      '${l.saidasTodosOsMeses(saida.diaDoMes)} · ${rotuloMeio(l, saida.meio)}',
                      style: t.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                saida.variavel || saida.valor == null
                    ? l.saidasValorVaria
                    : moeda(saida.valor!),
                style: saida.variavel || saida.valor == null ? t.bodySmall : t.titleMedium,
                textAlign: TextAlign.end,
              ),
            ],
          ),
          if (avisaFidelizacao) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_open_rounded, size: 18, color: AppColors.info),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(l.saidasFidelizacaoAcaba(dias),
                      style: t.bodySmall!.copyWith(color: AppColors.info)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ---- rótulos e ícones (só apresentação; os valores vivem em models/saida.dart) ----

String rotuloCategoria(AppLocalizations l, String categoria) => switch (categoria) {
      'renda' => l.saidasCatRenda,
      'luz' => l.saidasCatLuz,
      'agua' => l.saidasCatAgua,
      'gas' => l.saidasCatGas,
      'telemovel' => l.saidasCatTelemovel,
      'internet' => l.saidasCatInternet,
      'tv' => l.saidasCatTv,
      'carro' => l.saidasCatCarro,
      'combustivel' => l.saidasCatCombustivel,
      'seguro' => l.saidasCatSeguro,
      'escola' => l.saidasCatEscola,
      'creche' => l.saidasCatCreche,
      'saude' => l.saidasCatSaude,
      'ginasio' => l.saidasCatGinasio,
      'credito' => l.saidasCatCredito,
      'imposto' => l.saidasCatImposto,
      'assinatura' => l.saidasCatAssinatura,
      'compras' => l.saidasCatCompras,
      _ => l.saidasCatOutro,
    };

IconData iconeCategoria(String categoria) => switch (categoria) {
      'renda' => Icons.home_rounded,
      'luz' => Icons.lightbulb_rounded,
      'agua' => Icons.water_drop_rounded,
      'gas' => Icons.local_fire_department_rounded,
      'telemovel' => Icons.smartphone_rounded,
      'internet' => Icons.wifi_rounded,
      'tv' => Icons.tv_rounded,
      'carro' => Icons.directions_car_rounded,
      'combustivel' => Icons.local_gas_station_rounded,
      'seguro' => Icons.shield_rounded,
      'escola' => Icons.school_rounded,
      'creche' => Icons.child_care_rounded,
      'saude' => Icons.favorite_rounded,
      'ginasio' => Icons.fitness_center_rounded,
      'credito' => Icons.account_balance_rounded,
      'imposto' => Icons.account_balance_wallet_rounded,
      'assinatura' => Icons.subscriptions_rounded,
      'compras' => Icons.shopping_cart_rounded,
      _ => Icons.receipt_long_rounded,
    };

String rotuloGrupo(AppLocalizations l, String grupo) => switch (grupo) {
      'casa' => l.saidasGrupoCasa,
      'comunicacoes' => l.saidasGrupoComunicacoes,
      'carro' => l.saidasGrupoCarro,
      'familia' => l.saidasGrupoFamilia,
      'dinheiro' => l.saidasGrupoDinheiro,
      _ => l.saidasGrupoDiaAdia,
    };

String rotuloMeio(AppLocalizations l, String meio) => switch (meio) {
      'debito_direto' => l.saidasMeioDebitoDireto,
      'referencia_mb' => l.saidasMeioReferenciaMb,
      'mbway' => l.saidasMeioMbway,
      'transferencia' => l.saidasMeioTransferencia,
      'dinheiro' => l.saidasMeioDinheiro,
      _ => l.saidasMeioCartao,
    };

IconData iconeMeio(String meio) => switch (meio) {
      'debito_direto' => Icons.autorenew_rounded,
      'referencia_mb' => Icons.pin_rounded,
      'mbway' => Icons.smartphone_rounded,
      'transferencia' => Icons.swap_horiz_rounded,
      'dinheiro' => Icons.payments_rounded,
      _ => Icons.credit_card_rounded,
    };
