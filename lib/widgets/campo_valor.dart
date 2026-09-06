import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../regras/regras.dart';
import '../services/leitor_documento.dart';
import 'widgets.dart';

/// O campo do valor, com a câmara ao lado.
///
/// O Danilo escreveu: *"Em cada registo de gasto ou de rendimento, o campo de
/// valor é o principal e escrito à mão; ao lado fica um botão de câmara
/// opcional."*
///
/// A ordem importa e está aqui: **escrever é o caminho, a foto é o atalho.**
/// O campo é grande, tem o foco, e chega para gravar. A câmara é um botão ao
/// lado — quem quiser usa, quem não quiser nem repara.
///
/// A leitura NUNCA grava sozinha: devolve o que leu a quem chamou, para o
/// formulário se preencher e a pessoa poder corrigir antes de guardar.
class CampoValor extends StatefulWidget {
  final TextEditingController controlador;
  final String rotulo;

  /// 'fatura', 'combustivel' ou 'talao' — ajuda o modelo a saber o que procura.
  final String? tipoEsperado;

  /// Chamado quando a foto foi lida. O formulário preenche-se com isto.
  /// `null` esconde a câmara (ecrãs onde não faz sentido fotografar nada).
  final ValueChanged<DocumentoLido>? aoLerDocumento;

  final bool autofocus;
  final ValueChanged<String>? aoMudar;

  const CampoValor({
    super.key,
    required this.controlador,
    required this.rotulo,
    this.tipoEsperado,
    this.aoLerDocumento,
    this.autofocus = false,
    this.aoMudar,
  });

  @override
  State<CampoValor> createState() => _CampoValorState();
}

class _CampoValorState extends State<CampoValor> {
  bool _aLer = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: widget.controlador,
            autofocus: widget.autofocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // Vírgula e ponto: quem escreve 12,50 e quem escreve 12.50 têm
            // os dois razão, e o teclado do telemóvel só dá um deles.
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: t.headlineMedium,
            decoration: InputDecoration(
              labelText: widget.rotulo,
              suffixText: l.euros,
              suffixStyle: t.titleMedium!.copyWith(color: AppColors.textSecondary),
            ),
            onChanged: widget.aoMudar,
          ),
        ),
        if (widget.aoLerDocumento != null) ...[
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _aLer
                ? const SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                    ),
                  )
                : Tooltip(
                    message: l.valorFotoAjuda,
                    child: IconButton.filledTonal(
                      key: const Key('campo_valor_camara'),
                      iconSize: 26,
                      padding: const EdgeInsets.all(15),
                      onPressed: _escolherOrigem,
                      icon: const Icon(Icons.photo_camera_outlined),
                    ),
                  ),
          ),
        ],
      ],
    );
  }

  /// Tirar agora ou ir buscar à galeria. Duas linhas, sem menu escondido.
  Future<void> _escolherOrigem() async {
    final l = AppLocalizations.of(context);
    final origem = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.emDia),
              title: Text(l.valorFotoTirar),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.emDia),
              title: Text(l.valorFotoGaleria),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (origem == null || !mounted) return;
    await _ler(origem);
  }

  Future<void> _ler(ImageSource origem) async {
    final l = AppLocalizations.of(context);
    final mensageiro = ScaffoldMessenger.of(context);
    setState(() => _aLer = true);
    final r = await LeitorDocumento.ler(origem: origem, tipoEsperado: widget.tipoEsperado);
    if (!mounted) return;
    setState(() => _aLer = false);

    if (r.correu) {
      final d = r.documento!;
      // O valor entra logo no campo — é para isso que a foto serve.
      if (d.valorTotal != null) {
        widget.controlador.text = d.valorTotal!.toStringAsFixed(2).replaceAll('.', ',');
        widget.aoMudar?.call(widget.controlador.text);
      }
      widget.aoLerDocumento!(d);
      if (d.poucoSeguro) {
        mensageiro.showSnackBar(SnackBar(content: Text(l.valorFotoConfere)));
      }
      return;
    }
    if (r.erro == ErroLeitura.semFoto) return; // desistiu, não é erro
    mensageiro.showSnackBar(SnackBar(
      content: Text(switch (r.erro!) {
        ErroLeitura.cadeado => l.valorFotoCadeado,
        ErroLeitura.semServico => l.valorFotoIndisponivel,
        ErroLeitura.fotoGrande => l.valorFotoGrande,
        ErroLeitura.rede => l.erroRede,
        _ => l.valorFotoNaoLi,
      }),
    ));
  }
}

/// Lê o que a pessoa escreveu no campo do valor. Aceita vírgula e ponto.
double? valorEscrito(String texto) => lerNumero(texto);

/// A caixa da referência Multibanco, em letras grandes, com botão de copiar.
///
/// Quem paga no multibanco copia nove números de uma folha para o telemóvel, e
/// engana-se. Aqui os números estão em letras grandes, agrupados de três em
/// três, e copiam-se com um toque.
class CaixaReferencia extends StatelessWidget {
  final String entidade;
  final String referencia;
  final double? valor;
  const CaixaReferencia({
    super.key,
    required this.entidade,
    required this.referencia,
    this.valor,
  });

  static String agrupa(String numeros) {
    final b = StringBuffer();
    for (var i = 0; i < numeros.length; i++) {
      if (i > 0 && i % 3 == 0) b.write(' ');
      b.write(numeros[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      cor: AppColors.infoClaro,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.refTitulo, style: t.labelLarge!.copyWith(color: AppColors.info)),
          const SizedBox(height: 10),
          _Linha(rotulo: l.refEntidade, valor: entidade),
          const SizedBox(height: 6),
          _Linha(rotulo: l.refReferencia, valor: agrupa(referencia)),
          if (valor != null) ...[
            const SizedBox(height: 6),
            _Linha(rotulo: l.refValor, valor: moeda(valor!)),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BotaoGrande(
                  key: const Key('ref_copiar'),
                  texto: l.refCopiar,
                  icone: Icons.copy_rounded,
                  secundario: true,
                  aoTocar: () async {
                    await Clipboard.setData(ClipboardData(
                      text: '${l.refEntidade} $entidade\n${l.refReferencia} $referencia'
                          '${valor == null ? '' : '\n${l.refValor} ${moeda(valor!)}'}',
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(l.refCopiado)));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          BotaoOuvir(
            etiqueta: 'referencia-$referencia',
            texto: '${l.refEntidade} ${entidade.split('').join(' ')}. '
                '${l.refReferencia} ${referencia.split('').join(' ')}.'
                '${valor == null ? '' : ' ${l.refValor} ${moeda(valor!)}.'}',
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String rotulo;
  final String valor;
  const _Linha({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 106,
          child: Text(rotulo, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor, style: t.headlineSmall!.copyWith(letterSpacing: 1.5)),
          ),
        ),
      ],
    );
  }
}
