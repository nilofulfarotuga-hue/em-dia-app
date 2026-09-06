import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fidelizacao.dart';
import '../../regras/regras.dart';
import '../../stores/radar_store.dart';
import '../../stores/regras_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import '../plano/plano_screen.dart';

/// O radar da fidelização.
///
/// Uma lista pela data: que contratos te largam, e quando. O trabalho todo do
/// ecrã é dizer **quanto falta em palavras** — "faltam 12 dias", "acaba
/// amanhã", "acabou há 5 dias" — porque "18/09/2026" não faz ninguém pegar no
/// telefone e um número de dias sozinho ainda é conta para fazer de cabeça.
///
/// Regra do laranja (uma cor forte por ecrã): só **uma** linha é colorida — a
/// que exige acção primeiro. Todas as outras ficam em cinzento. Se o ecrã
/// pintasse cinco linhas de laranja, nenhuma delas queria dizer nada.
class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  bool _pedido = false;

  /// Vai buscar os contratos assim que se souber que o plano deixa.
  ///
  /// Isto mora no `build` e não no `initState` de propósito: o cadeado só se
  /// sabe depois de o `PlanoStore` chegar do servidor. Quem pedisse no
  /// arranque perguntava com o plano ainda por saber, e um ecrã que arrancasse
  /// trancado nunca mais ia buscar nada quando destrancasse.
  void _pedirSePreciso({required bool trancado}) {
    if (_pedido || trancado) return;
    final radar = context.read<RadarStore>();
    // Uma store `paraTeste` já vem carregada: nem se lhe pergunta a sessão
    // (nas fotos não há sessão nenhuma).
    if (radar.jaCarregou || radar.aCarregar) return;
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) return;
    _pedido = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RadarStore>().carregarSePreciso(userId);
    });
  }

  Future<void> _atualizar() async {
    final userId = context.read<SessaoStore>().userId;
    if (userId == null) return;
    await context.read<RadarStore>().carregar(userId);
  }

  void _abrirPlano() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const PlanoScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final radar = context.watch<RadarStore>();
    final plano = context.watch<PlanoStore>();
    final regras = context.watch<RegrasStore>().regras;
    final trancado = !plano.permitida('radar_fidelizacao');
    _pedirSePreciso(trancado: trancado);

    // A janela vem da tabela das regras (`aviso_fidelizacao_dias`), nunca de
    // uma constante daqui. Se a regra não tiver chegado, a frase diz o mesmo
    // sem o número — inventar 30 era escrever uma lei que ninguém aprovou.
    final janela = regras.regra('aviso_fidelizacao_dias')?.valorNum?.toInt();
    final janelaTexto = janela == null ? l.radarJanelaSemNumero : l.radarJanela(janela);

    final falado = [
      l.radarExplicacao,
      l.radarOQueFazer,
      if (trancado) l.radarCadeadoOQueGanhas else janelaTexto,
    ].join(' ');

    final destaque = radar.indiceDestaque;

    return Scaffold(
      appBar: AppBar(title: Text(l.radarTitulo)),
      body: RefreshIndicator(
        onRefresh: _atualizar,
        child: ListView(
          padding: paddingEcra,
          children: [
            _Explicacao(janelaTexto: trancado ? null : janelaTexto, falado: falado),
            const SizedBox(height: 18),
            if (trancado)
              Cadeado(
                trancado: true,
                linha: l.radarCadeado,
                aoTocar: _abrirPlano,
                child: Cartao(
                  key: const Key('radar_cadeado'),
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    l.radarCadeadoOQueGanhas,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else if (radar.erro != null && radar.contratos.isEmpty)
              Aviso(l.radarErro, tom: Semaforo.vermelho)
            else if (radar.aCarregar && radar.contratos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (radar.contratos.isEmpty)
              Vazio(icone: Icons.event_available_outlined, texto: l.radarVazio)
            else ...[
              TituloSeccao(l.radarQuantos(radar.contratos.length)),
              const SizedBox(height: 4),
              for (var i = 0; i < radar.contratos.length; i++)
                _LinhaContrato(
                  contrato: radar.contratos[i],
                  destaque: i == destaque,
                  frase: fraseDeFidelizacao(l, radar.contratos[i]),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Quanto falta, em palavras. É a única coisa que a pessoa lê a sério nesta
/// lista, por isso não tem número solto nem abreviatura: ou é "faltam 12
/// dias", ou é "acaba amanhã", ou é "acabou há 5 dias".
String fraseDeFidelizacao(AppLocalizations l, Fidelizacao c) => switch (c.momento) {
      MomentoFidelizacao.acabou => l.radarAcabouHaDias(c.diasDesdeQueAcabou),
      MomentoFidelizacao.ontem => l.radarAcabouOntem,
      MomentoFidelizacao.hoje => l.radarAcabaHoje,
      MomentoFidelizacao.amanha => l.radarAcabaAmanha,
      MomentoFidelizacao.faltam => l.radarFaltamDias(c.diasParaAcabar),
    };

/// O cartão de cima: o que é isto, e o que fazer com isto.
class _Explicacao extends StatelessWidget {
  final String? janelaTexto;
  final String falado;
  const _Explicacao({required this.janelaTexto, required this.falado});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      key: const Key('radar_explicacao'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.link_off_rounded, color: AppColors.info, size: 24),
              const SizedBox(width: 10),
              Expanded(child: Text(l.radarExplicacao, style: t.bodyMedium)),
            ],
          ),
          const SizedBox(height: 12),
          Text(l.radarOQueFazer,
              style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
          if (janelaTexto != null) ...[
            const SizedBox(height: 8),
            Text(janelaTexto!, style: t.bodySmall),
          ],
          BotaoOuvir(etiqueta: 'radar', texto: falado),
        ],
      ),
    );
  }
}

/// Uma linha da lista: nome, empresa, quanto falta e quanto custa por mês.
///
/// A barra lateral de 4 px é a mesma ideia dos lembretes do Drivvo. Aqui só
/// tem cor na linha em [destaque]; nas outras é o cinzento do divisor, para
/// não haver dois laranjas no mesmo ecrã.
class _LinhaContrato extends StatelessWidget {
  final Fidelizacao contrato;
  final bool destaque;
  final String frase;
  const _LinhaContrato({
    required this.contrato,
    required this.destaque,
    required this.frase,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    // Vermelho para o que já acabou, laranja para o que está a acabar — o
    // semáforo da casa. Só a linha em destaque é que ganha cor.
    final forte = contrato.jaAcabou ? AppColors.passou : AppColors.aVencer;
    final corBarra = destaque ? forte : AppColors.divider;
    final data = dataPt(contrato.fimFidelizacao);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Cartao(
        key: Key('radar_linha_${contrato.saidaId}'),
        cor: destaque
            ? (contrato.jaAcabou ? AppColors.passouClaro : AppColors.aVencerClaro)
            : null,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: corBarra,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Icone(categoria: contrato.categoria),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contrato.nome,
                                  style: t.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(contrato.fornecedor ?? l.radarSemFornecedor,
                                  style: t.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // O valor tem tecto de largura para não empurrar o
                        // nome para fora: "1.234,56 € por mês" parte-se em
                        // duas linhas em vez de partir o ecrã.
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 104),
                          child: contrato.valorMensal != null
                              ? Text(l.radarPorMes(moeda(contrato.valorMensal!)),
                                  textAlign: TextAlign.end, style: t.titleMedium)
                              : Text(l.radarSemValor,
                                  textAlign: TextAlign.end, style: t.bodySmall),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Quanto falta, em palavras, com a largura toda para si.
                    // Na linha em destaque é o maior texto do ecrã — é este
                    // número que decide se ainda vale a pena ligar.
                    Text(
                      frase,
                      style: destaque
                          ? t.headlineSmall!.copyWith(color: forte)
                          : t.titleSmall!.copyWith(color: AppColors.textSecondary),
                    ),
                    if (destaque) ...[
                      Text(
                        contrato.jaAcabou ? l.radarAcabouEm(data) : l.radarAcabaEm(data),
                        style: t.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      // O passo concreto, ao pé do prazo — um aviso sem o que
                      // fazer a seguir só serve para assustar.
                      Text(l.radarLigarAgora,
                          style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O círculo com o ícone do tipo de conta. Fica sempre cinzento: a cor do ecrã
/// é a do prazo, não a da categoria.
class _Icone extends StatelessWidget {
  final String categoria;
  const _Icone({required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.surface2, shape: BoxShape.circle),
      child: Icon(_iconeDaCategoria(categoria), color: AppColors.textSecondary, size: 22),
    );
  }
}

IconData _iconeDaCategoria(String categoria) => switch (categoria) {
      'telemovel' => Icons.smartphone_rounded,
      'internet' => Icons.wifi_rounded,
      'tv' => Icons.tv_rounded,
      'ginasio' => Icons.fitness_center_rounded,
      'luz' => Icons.lightbulb_rounded,
      'gas' => Icons.local_fire_department_rounded,
      'agua' => Icons.water_drop_rounded,
      'seguro' => Icons.shield_rounded,
      'carro' => Icons.directions_car_rounded,
      'credito' => Icons.account_balance_rounded,
      'assinatura' => Icons.subscriptions_rounded,
      'saude' => Icons.favorite_rounded,
      'escola' || 'creche' => Icons.school_rounded,
      'renda' => Icons.house_rounded,
      _ => Icons.receipt_long_rounded,
    };
