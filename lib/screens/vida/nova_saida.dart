import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/saida.dart';
import '../../services/fala.dart';
import '../../services/leitor_documento.dart';
import '../../stores/perfil_store.dart';
import '../../stores/saidas_store.dart';
import '../../widgets/widgets.dart';
import '../carro/widgets_carro.dart' show CampoData, Interruptor;
import 'saidas_screen.dart' show iconeCategoria, iconeMeio, rotuloCategoria, rotuloGrupo, rotuloMeio;

/// Abre a folha de registo de uma conta. Devolve `true` se ficou guardada.
///
/// Com [saida] preenchida é uma conta que já existe e se está a mudar.
///
/// Com [lido] preenchida, a folha abre-se JÁ com o que a leitura percebeu — é
/// por aqui que entra uma fatura que chegou por e-mail. [aoGuardar] devolve a
/// conta gravada a quem abriu a folha (a caixa de correio precisa do id dela
/// para ligar a fatura à conta).
Future<bool?> mostrarNovaSaida(
  BuildContext context, {
  required String userId,
  required DateTime hoje,
  Saida? saida,
  DocumentoLido? lido,
  ValueChanged<Saida>? aoGuardar,
}) {
  final store = context.read<SaidasStore>();
  // O botão de ouvir precisa da voz e do perfil, e nesta folha eles não vêm
  // de cima (o sheet vive no Navigator de raiz).
  final perfil = context.read<PerfilStore>();
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider<SaidasStore>.value(value: store),
        ChangeNotifierProvider<PerfilStore>.value(value: perfil),
        ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
      ],
      child: NovaSaida(userId: userId, hoje: hoje, saida: saida, lido: lido, aoGuardar: aoGuardar),
    ),
  );
}

/// A folha de registo de uma conta.
///
/// A foto é o atalho que faz esta tela valer a pena: de uma fatura tira-se o
/// valor, o nome de quem a mandou, o dia — e, quando lá está, a **entidade e
/// a referência do Multibanco**. Quem fotografa uma fatura da EDP fica com a
/// conta pronta a pagar sem escrever catorze números à mão.
class NovaSaida extends StatefulWidget {
  final String userId;
  final DateTime hoje;
  final Saida? saida;

  /// O que já foi lido noutro sítio (a fatura que chegou por e-mail).
  final DocumentoLido? lido;

  /// Chamado com a conta gravada, antes de a folha fechar.
  final ValueChanged<Saida>? aoGuardar;

  const NovaSaida({
    super.key,
    required this.userId,
    required this.hoje,
    this.saida,
    this.lido,
    this.aoGuardar,
  });

  @override
  State<NovaSaida> createState() => _NovaSaidaState();
}

class _NovaSaidaState extends State<NovaSaida> {
  final _nome = TextEditingController();
  final _valor = TextEditingController();
  final _entidade = TextEditingController();
  final _referencia = TextEditingController();
  final _fornecedor = TextEditingController();

  String _categoria = 'outro';
  String _meio = 'debito_direto';
  int _dia = 1;

  /// "É sempre o mesmo valor?" — o contrário de `variavel` na base de dados.
  /// Começa em sim porque a maior parte das contas fixas são mesmo fixas.
  bool _mesmoValor = true;

  DateTime? _fimFidelizacao;
  String? _leituraOcrId;
  String? _lida; // a frase que aparece depois de ler uma fatura
  String? _erro;
  bool _aTrabalhar = false;

  bool get _aMudar => widget.saida != null;

  @override
  void initState() {
    super.initState();
    final s = widget.saida;
    if (s != null) {
      _nome.text = s.nome;
      _categoria = s.categoria;
      _meio = s.meio;
      _dia = s.diaDoMes.clamp(1, 31);
      _mesmoValor = !s.variavel;
      if (s.valor != null) _valor.text = s.valor!.toStringAsFixed(2).replaceAll('.', ',');
      _entidade.text = s.entidade ?? '';
      _referencia.text = s.referencia ?? '';
      _fornecedor.text = s.fornecedor ?? '';
      _fimFidelizacao = s.fimFidelizacao;
      _leituraOcrId = s.leituraOcrId;
    } else {
      _dia = widget.hoje.day.clamp(1, 31);
    }
    // A leitura que veio de fora só se aplica depois do primeiro desenho: o
    // _aoLerDocumento precisa do contexto para ir buscar os textos.
    final d = widget.lido;
    if (d != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _aoLerDocumento(d);
      });
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _valor.dispose();
    _entidade.dispose();
    _referencia.dispose();
    _fornecedor.dispose();
    super.dispose();
  }

  /// O que a foto deu. Nada é gravado aqui: preenche-se o formulário e a
  /// pessoa vê, corrige e só depois guarda.
  void _aoLerDocumento(DocumentoLido d) {
    final l = AppLocalizations.of(context);
    setState(() {
      // O nome só se escreve por cima se estiver vazio — quem já escreveu
      // "Luz de casa" não quer ver aparecer "EDP COMERCIAL SA".
      if (_nome.text.trim().isEmpty && (d.entidadeNome?.trim().isNotEmpty ?? false)) {
        _nome.text = d.entidadeNome!.trim();
      }
      if (d.data != null) _dia = d.data!.day.clamp(1, 31);
      // Isto é o que faz a foto valer a pena: com os dois números do
      // Multibanco a conta fica pronta a pagar.
      if (d.temReferenciaMultibanco) {
        _meio = 'referencia_mb';
        _entidade.text = soNumeros(d.entidadePagamento!);
        _referencia.text = soNumeros(d.referenciaPagamento!);
      }
      // O valor: a câmara do CampoValor já o escreve sozinha, mas uma leitura
      // que venha de fora (fatura do e-mail) não passa por lá.
      if (d.valorTotal != null) {
        _valor.text = d.valorTotal!.toStringAsFixed(2).replaceAll('.', ',');
        _mesmoValor = true;
      }
      _leituraOcrId = d.leituraId;
      _lida = d.temReferenciaMultibanco ? l.saidasLidaComReferencia : l.saidasLidaFatura;
    });
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      setState(() => _erro = l.saidasFaltaNome);
      return;
    }
    double? valor;
    if (_mesmoValor) {
      valor = valorEscrito(_valor.text);
      if (valor == null || valor <= 0) {
        setState(() => _erro = l.saidasFaltaValor);
        return;
      }
    }
    final entidade = soNumeros(_entidade.text);
    final referencia = soNumeros(_referencia.text);
    if (_meio == 'referencia_mb') {
      if (!entidadeValida(entidade)) {
        setState(() => _erro = l.saidasEntidadeInvalida);
        return;
      }
      if (!referenciaValida(referencia)) {
        setState(() => _erro = l.saidasReferenciaInvalida);
        return;
      }
    }

    setState(() {
      _erro = null;
      _aTrabalhar = true;
    });
    final fornecedor = _fornecedor.text.trim();
    final store = context.read<SaidasStore>();
    final guardada = await store.guardar(Saida(
      id: widget.saida?.id ?? '',
      userId: widget.userId,
      nome: nome,
      categoria: _categoria,
      valor: valor,
      variavel: !_mesmoValor,
      diaDoMes: _dia,
      meio: _meio,
      entidade: _meio == 'referencia_mb' ? entidade : null,
      referencia: _meio == 'referencia_mb' ? referencia : null,
      fimFidelizacao: _fimFidelizacao,
      fornecedor: fornecedor.isEmpty ? null : fornecedor,
      leituraOcrId: _leituraOcrId,
    ));
    if (!mounted) return;
    if (guardada == null) {
      setState(() {
        _aTrabalhar = false;
        _erro = l.saidasErroGuardar;
      });
      return;
    }
    // A conta deste mês tem de aparecer já. Sem isto a pessoa guardava a luz
    // hoje e só a via na lista no dia 1 do mês seguinte.
    await store.gerarDoMes(widget.userId, mes: widget.hoje);
    widget.aoGuardar?.call(guardada);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _cancelarConta() async {
    final l = AppLocalizations.of(context);
    final msg = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final confirma = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.saidasCancelarPergunta),
        content: Text(l.saidasCancelarExplica),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.cancelar)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l.saidasCancelarConfirmar)),
        ],
      ),
    );
    if (confirma != true || !mounted) return;
    setState(() => _aTrabalhar = true);
    final ok = await context.read<SaidasStore>().desativar(widget.saida!);
    if (!mounted) return;
    setState(() => _aTrabalhar = false);
    if (!ok) {
      setState(() => _erro = l.saidasErroGuardar);
      return;
    }
    // Sai com `false` para o ecrã de trás não dizer "conta guardada": o que
    // aconteceu foi o contrário.
    navegador.pop(false);
    msg.showSnackBar(SnackBar(content: Text(l.saidasContaCancelada)));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_aMudar ? l.saidasEditarTitulo : l.saidasNovaTitulo, style: t.headlineSmall),
          const SizedBox(height: 16),

          TextField(
            controller: _nome,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l.saidasNome, hintText: l.saidasNomeDica),
          ),
          const SizedBox(height: 18),

          Text(l.saidasCategoria, style: t.titleSmall),
          const SizedBox(height: 8),
          // Dezanove botões seguidos são uma parede: vão por grupos, com o
          // nome do grupo em cima.
          for (final grupo in gruposCategorias.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Text(rotuloGrupo(l, grupo.key), style: t.labelSmall),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in grupo.value)
                  ChoiceChip(
                    label: Text(rotuloCategoria(l, c)),
                    avatar: Icon(iconeCategoria(c),
                        size: 18,
                        color: _categoria == c ? AppColors.primaryDark : AppColors.textSecondary),
                    selected: _categoria == c,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                        color: _categoria == c ? AppColors.primaryDark : AppColors.textPrimary),
                    onSelected: (_) => setState(() => _categoria = c),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 18),

          // O valor é o campo principal e escreve-se à mão; a câmara ao lado
          // é o atalho de quem tem a fatura na mesa.
          CampoValor(
            controlador: _valor,
            rotulo: l.saidasValor,
            tipoEsperado: 'fatura',
            aoLerDocumento: _aoLerDocumento,
          ),
          if (_lida != null) ...[
            const SizedBox(height: 10),
            Aviso(_lida!, tom: Semaforo.verde, icone: Icons.auto_awesome_rounded),
          ],

          Interruptor(
            rotulo: l.saidasSempreMesmoValor,
            valor: _mesmoValor,
            aoMudar: (v) => setState(() => _mesmoValor = v),
          ),
          if (!_mesmoValor)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(l.saidasValorVariaAjuda, style: t.bodySmall),
            ),
          const SizedBox(height: 12),

          // A chave force o campo a mostrar o dia novo quando é a leitura da
          // fatura a mudá-lo (o `initialValue` sozinho não voltava atrás).
          DropdownButtonFormField<int>(
            key: ValueKey('saida_dia_$_dia'),
            initialValue: _dia,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.saidasDiaDoMes),
            items: [
              for (var d = 1; d <= 31; d++)
                DropdownMenuItem(value: d, child: Text(l.saidasDia(d))),
            ],
            onChanged: (v) => setState(() => _dia = v ?? _dia),
          ),
          const SizedBox(height: 10),
          Aviso(l.saidasDiaAviso, tom: Semaforo.verde, icone: Icons.event_available_rounded),
          const SizedBox(height: 18),

          Text(l.saidasComoPagas, style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in meiosPagamento)
                ChoiceChip(
                  label: Text(rotuloMeio(l, m)),
                  avatar: Icon(iconeMeio(m),
                      size: 18,
                      color: _meio == m ? AppColors.primaryDark : AppColors.textSecondary),
                  selected: _meio == m,
                  showCheckmark: false,
                  labelStyle:
                      TextStyle(color: _meio == m ? AppColors.primaryDark : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _meio = m),
                ),
            ],
          ),

          // Os dois números do Multibanco só aparecem quando servem para
          // alguma coisa. Um sem o outro não paga nada, por isso pedem-se
          // sempre juntos.
          if (_meio == 'referencia_mb') ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: const Key('saida_entidade'),
                    controller: _entidade,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: InputDecoration(labelText: l.saidasEntidade),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextField(
                    key: const Key('saida_referencia'),
                    controller: _referencia,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: InputDecoration(labelText: l.saidasReferencia),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l.saidasRefAjuda, style: t.bodySmall),
          ],
          const SizedBox(height: 18),

          TextField(
            controller: _fornecedor,
            textCapitalization: TextCapitalization.characters,
            decoration:
                InputDecoration(labelText: l.saidasFornecedor, hintText: l.saidasFornecedorDica),
          ),
          const SizedBox(height: 18),

          Text(l.saidasFidelizacao, style: t.titleSmall),
          const SizedBox(height: 8),
          CampoData(
            rotulo: l.saidasFidelizacao,
            valor: _fimFidelizacao,
            hoje: widget.hoje,
            primeira: widget.hoje,
            aoEscolher: (d) => setState(() => _fimFidelizacao = d),
          ),
          if (_fimFidelizacao != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _fimFidelizacao = null),
                child: Text(l.saidasFidelizacaoLimpar),
              ),
            ),
          const SizedBox(height: 8),
          Text(l.saidasFidelizacaoAjuda, style: t.bodySmall),
          const SizedBox(height: 4),
          // A etiqueta não é texto visível: é o nome por que este botão se
          // reconhece quando há vários a falar no mesmo ecrã.
          BotaoOuvir(etiqueta: 'saidas-fidelizacao', texto: l.saidasFidelizacaoAjuda),

          if (_erro != null) ...[
            const SizedBox(height: 14),
            Aviso(_erro!, tom: Semaforo.vermelho),
          ],
          const SizedBox(height: 20),
          BotaoGrande(
            key: const Key('saida_guardar'),
            texto: l.guardar,
            icone: Icons.check_rounded,
            aTrabalhar: _aTrabalhar,
            aoTocar: _guardar,
          ),
          if (_aMudar) ...[
            const SizedBox(height: 10),
            BotaoGrande(
              texto: l.saidasCancelarConta,
              secundario: true,
              aTrabalhar: _aTrabalhar,
              aoTocar: _cancelarConta,
            ),
          ],
        ],
      ),
    );
  }
}
