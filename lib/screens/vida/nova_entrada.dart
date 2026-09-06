import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/entrada.dart';
import '../../regras/regras.dart';
import '../../services/fala.dart';
import '../../services/leitor_documento.dart';
import '../../stores/entradas_store.dart';
import '../../stores/perfil_store.dart';
import '../../widgets/widgets.dart';
import '../carro/widgets_carro.dart' show CampoData, Interruptor;
import '../recibos/recibos_widgets.dart' show ChipEscolha, NotaInfo;

/// Abre a folha de registo do dinheiro que entrou. Devolve `true` se ficou
/// guardado.
///
/// As stores voltam a ser dadas à folha de propósito: assim a folha pode ser
/// aberta sozinha num teste, sem montar a app inteira à volta dela.
Future<bool?> mostrarNovaEntrada(
  BuildContext context, {
  required String userId,
  required DateTime hoje,
}) {
  final entradas = context.read<EntradasStore>();
  final perfil = context.read<PerfilStore>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider<EntradasStore>.value(value: entradas),
        ChangeNotifierProvider<PerfilStore>.value(value: perfil),
        // A voz é uma só em toda a app (o botão de ouvir a explicação do IRS).
        ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
      ],
      child: NovaEntrada(userId: userId, hoje: hoje),
    ),
  );
}

/// A folha de registo, pela ordem por que a pessoa pensa:
/// **quanto** → de onde veio → quando → de quanto tempo é → km → o que foi →
/// conta para o IRS → guardar.
///
/// O valor vem primeiro porque é o único campo obrigatório: quem só quiser
/// escrever o número e carregar em guardar, consegue.
class NovaEntrada extends StatefulWidget {
  final String userId;
  final DateTime hoje;
  const NovaEntrada({super.key, required this.userId, required this.hoje});

  @override
  State<NovaEntrada> createState() => _NovaEntradaState();
}

class _NovaEntradaState extends State<NovaEntrada> {
  final _valor = TextEditingController();
  final _descricao = TextEditingController();
  final _km = TextEditingController();

  String _tipo = 'recibo_verde';
  String? _plataforma;
  late DateTime _data = soDia(widget.hoje);
  String _periodo = 'dia';
  bool _contaParaIrs = true;

  bool _lidoDaFoto = false;
  String? _leituraId;
  String? _erro;
  bool _aGuardar = false;

  @override
  void dispose() {
    _valor.dispose();
    _descricao.dispose();
    _km.dispose();
    super.dispose();
  }

  /// Os km só aparecem a quem anda na estrada: motorista, estafeta, ou
  /// qualquer pessoa que esteja a escrever dinheiro vindo de uma app. Pedir
  /// km a uma cabeleireira era um campo a mais por nada.
  bool get _mostraKm {
    if (_tipo == 'plataforma') return true;
    final tipo = context.read<PerfilStore>().perfil?.tipoAtividade;
    return tipo == TipoAtividade.tvde || tipo == TipoAtividade.estafeta;
  }

  /// A foto do extrato preenche o valor (isso é do [CampoValor]) e a data, se
  /// a souber ler. Nunca grava sozinha: a pessoa vê e corrige antes.
  void _aoLerDocumento(DocumentoLido d) {
    setState(() {
      _lidoDaFoto = true;
      _leituraId = d.leituraId;
      final lida = d.data;
      if (lida != null && !lida.isAfter(widget.hoje)) _data = soDia(lida);
    });
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final valor = valorEscrito(_valor.text);
    if (valor == null || valor <= 0) {
      setState(() => _erro = l.vidaFaltaValor);
      return;
    }
    setState(() {
      _erro = null;
      _aGuardar = true;
    });
    final descricao = _descricao.text.trim();
    final km = int.tryParse(_km.text.trim().replaceAll(' ', ''));
    final ok = await context.read<EntradasStore>().guardar(Entrada(
          id: '',
          userId: widget.userId,
          data: _data,
          valor: centimos(valor),
          tipo: _tipo,
          plataforma: _plataforma,
          descricao: descricao.isEmpty ? null : descricao,
          periodo: _periodo,
          km: _mostraKm ? km : null,
          contaParaIrs: _contaParaIrs,
          leituraOcrId: _leituraId,
        ));
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _aGuardar = false;
        _erro = l.vidaErroGuardar;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.vidaBotaoNovo, style: t.headlineSmall),
          const SizedBox(height: 16),

          // 1. Quanto. O campo principal, com a câmara ao lado (um extrato
          // não é fatura nem talão — por isso `tipoEsperado: null`).
          CampoValor(
            key: const Key('nova_entrada_valor'),
            controlador: _valor,
            rotulo: l.vidaQuanto,
            tipoEsperado: null,
            aoLerDocumento: _aoLerDocumento,
            aoMudar: (_) {
              if (_erro != null) setState(() => _erro = null);
            },
          ),
          if (_lidoDaFoto) ...[
            const SizedBox(height: 10),
            NotaInfo(l.vidaLiDaFoto),
          ],

          // 2. De onde veio.
          const SizedBox(height: 20),
          Text(l.vidaDeOndeVeio, style: t.titleMedium),
          const SizedBox(height: 10),
          for (final tipo in tiposEntrada) ...[
            BotaoEscolha(
              key: Key('tipo_$tipo'),
              texto: rotuloTipoEntrada(l, tipo),
              ajuda: ajudaTipoEntrada(l, tipo),
              icone: iconeTipoEntrada(tipo),
              selecionado: _tipo == tipo,
              aoTocar: () => setState(() {
                _tipo = tipo;
                // Sair de "app de trabalho" apaga a app escolhida: senão
                // ficava um "bolt" agarrado a um salário.
                if (tipo != 'plataforma') _plataforma = null;
              }),
            ),
            const SizedBox(height: 8),
          ],

          // 2b. Qual app (só quando veio de uma app de trabalho).
          if (_tipo == 'plataforma') ...[
            const SizedBox(height: 8),
            Text(l.vidaQualPlataforma, style: t.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in plataformasEntrada)
                  ChipEscolha(
                    texto: nomePlataformaEntrada(l, p),
                    selecionado: _plataforma == p,
                    aoTocar: () => setState(() => _plataforma = p),
                  ),
              ],
            ),
          ],

          // 3. Quando (abre no dia de hoje).
          const SizedBox(height: 20),
          CampoData(
            rotulo: l.vidaQuando,
            valor: _data,
            hoje: widget.hoje,
            ultima: widget.hoje,
            aoEscolher: (d) => setState(() => _data = d),
          ),

          // 4. De quanto tempo é este dinheiro.
          const SizedBox(height: 20),
          Text(l.vidaPorQuePeriodo, style: t.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final p in periodosEntrada) ...[
                Expanded(
                  child: _BotaoPeriodo(
                    texto: rotuloPeriodoEntrada(l, p),
                    selecionado: _periodo == p,
                    aoTocar: () => setState(() => _periodo = p),
                  ),
                ),
                if (p != periodosEntrada.last) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(l.vidaPeriodoExplica, style: t.bodySmall),

          // 5. Km (só a quem anda na estrada).
          if (_mostraKm) ...[
            const SizedBox(height: 20),
            TextField(
              controller: _km,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l.vidaKm,
                helperText: l.vidaKmAjuda,
                helperMaxLines: 3,
                suffixText: l.vidaKmUnidade,
              ),
            ),
          ],

          // 6. O que foi (opcional).
          const SizedBox(height: 20),
          TextField(
            controller: _descricao,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.vidaDescricao, hintText: l.vidaDescricaoDica),
          ),

          // 7. Conta para o IRS — ligado por omissão, com a explicação por baixo.
          const SizedBox(height: 8),
          Interruptor(
            rotulo: l.vidaContaIrs,
            valor: _contaParaIrs,
            aoMudar: (v) => setState(() => _contaParaIrs = v),
          ),
          Text(l.vidaContaIrsExplica, style: t.bodySmall),
          const SizedBox(height: 4),
          BotaoOuvir(etiqueta: 'entrada-irs', texto: l.vidaContaIrsExplica),

          if (_erro != null) ...[
            const SizedBox(height: 12),
            Aviso(_erro!, tom: Semaforo.vermelho),
          ],

          // 8. Guardar.
          const SizedBox(height: 20),
          BotaoGrande(
            key: const Key('nova_entrada_guardar'),
            texto: l.guardar,
            icone: Icons.check_rounded,
            aTrabalhar: _aGuardar,
            aoTocar: _guardar,
          ),
        ],
      ),
    );
  }
}

/// Um dos três botões do período. Lado a lado, todos do mesmo tamanho, para
/// se ver de uma vez que são três escolhas e não uma lista.
class _BotaoPeriodo extends StatelessWidget {
  final String texto;
  final bool selecionado;
  final VoidCallback aoTocar;
  const _BotaoPeriodo({required this.texto, required this.selecionado, required this.aoTocar});

  @override
  Widget build(BuildContext context) {
    return Cartao(
      aoTocar: aoTocar,
      cor: selecionado ? AppColors.primaryLight : AppColors.surface,
      bordo: selecionado ? AppColors.primary : AppColors.divider,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Center(
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: selecionado ? AppColors.primaryDeep : AppColors.textPrimary,
              ),
        ),
      ),
    );
  }
}

// ---- as palavras de uma entrada (usadas pela folha e pela lista) ----

String rotuloTipoEntrada(AppLocalizations l, String tipo) => switch (tipo) {
      'recibo_verde' => l.vidaTipoReciboVerde,
      'plataforma' => l.vidaTipoPlataforma,
      'salario' => l.vidaTipoSalario,
      'dinheiro_mao' => l.vidaTipoDinheiroMao,
      'arrendamento' => l.vidaTipoArrendamento,
      'subsidio' => l.vidaTipoSubsidio,
      'pensao' => l.vidaTipoPensao,
      _ => l.vidaTipoOutro,
    };

String ajudaTipoEntrada(AppLocalizations l, String tipo) => switch (tipo) {
      'recibo_verde' => l.vidaTipoReciboVerdeAjuda,
      'plataforma' => l.vidaTipoPlataformaAjuda,
      'salario' => l.vidaTipoSalarioAjuda,
      'dinheiro_mao' => l.vidaTipoDinheiroMaoAjuda,
      'arrendamento' => l.vidaTipoArrendamentoAjuda,
      'subsidio' => l.vidaTipoSubsidioAjuda,
      'pensao' => l.vidaTipoPensaoAjuda,
      _ => l.vidaTipoOutroAjuda,
    };

IconData iconeTipoEntrada(String tipo) => switch (tipo) {
      'recibo_verde' => Icons.receipt_long_rounded,
      'plataforma' => Icons.phone_iphone_rounded,
      'salario' => Icons.badge_rounded,
      'dinheiro_mao' => Icons.payments_rounded,
      'arrendamento' => Icons.house_rounded,
      'subsidio' => Icons.volunteer_activism_rounded,
      'pensao' => Icons.elderly_rounded,
      _ => Icons.savings_rounded,
    };

/// Os nomes das apps são marcas: escrevem-se na mesma nas duas línguas. Só
/// "outra" é que é palavra e vai à tradução.
String nomePlataformaEntrada(AppLocalizations l, String? p) => switch (p) {
      'uber' => 'Uber',
      'bolt' => 'Bolt',
      'glovo' => 'Glovo',
      'uber_eats' => 'Uber Eats',
      'outro' => l.vidaPlataformaOutra,
      _ => l.vidaPlataformaOutra,
    };

String rotuloPeriodoEntrada(AppLocalizations l, String periodo) => switch (periodo) {
      'semana' => l.vidaPeriodoSemana,
      'mes' => l.vidaPeriodoMes,
      _ => l.vidaPeriodoDia,
    };
