import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart'
    show ImagePickerPlatform;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'arranque.dart';

/// O que a inteligência artificial leu num documento.
///
/// Todos os campos podem vir a nulo — de propósito. Uma leitura que inventa é
/// pior do que uma leitura que falta: a pessoa vê o que foi lido, corrige o que
/// estiver mal, e só depois é que grava.
class DocumentoLido {
  final String leituraId;
  final String tipo; // fatura | combustivel | talao | extrato | outro
  final String? entidadeNome;
  final String? nif;
  final DateTime? data;
  final double? valorTotal;

  /// Os números do Multibanco. Só valem juntos: um sem o outro não paga nada.
  final String? entidadePagamento;
  final String? referenciaPagamento;

  final double? litros;
  final double? precoLitro;

  /// O documento traz o número de contribuinte de quem comprou — é isso que
  /// faz a despesa contar para o IRS.
  final bool contaParaIrs;
  final double confianca;
  final String notas;

  /// Quantas leituras ainda faltam este mês no plano grátis. `null` = sem limite.
  final int? restamEsteMes;

  const DocumentoLido({
    required this.leituraId,
    required this.tipo,
    this.entidadeNome,
    this.nif,
    this.data,
    this.valorTotal,
    this.entidadePagamento,
    this.referenciaPagamento,
    this.litros,
    this.precoLitro,
    this.contaParaIrs = false,
    this.confianca = 0,
    this.notas = '',
    this.restamEsteMes,
  });

  bool get temReferenciaMultibanco =>
      entidadePagamento != null && referenciaPagamento != null;

  /// Abaixo disto vale a pena a app dizer "confere isto, não tenho a certeza".
  bool get poucoSeguro => confianca < 0.75;

  static DocumentoLido daResposta(Map<String, dynamic> d) {
    DateTime? data;
    final bruta = d['data_documento'];
    if (bruta is String && bruta.length == 10) data = DateTime.tryParse(bruta);
    double? numero(Object? v) => v == null ? null : (v as num).toDouble();
    return DocumentoLido(
      leituraId: d['leitura_id'] as String,
      tipo: (d['tipo'] as String?) ?? 'outro',
      entidadeNome: d['entidade_nome'] as String?,
      nif: d['nif'] as String?,
      data: data,
      valorTotal: numero(d['valor_total']),
      entidadePagamento: d['entidade_pagamento'] as String?,
      referenciaPagamento: d['referencia_pagamento'] as String?,
      litros: numero(d['litros']),
      precoLitro: numero(d['preco_litro']),
      contaParaIrs: d['conta_para_irs'] == true,
      confianca: numero(d['confianca']) ?? 0,
      notas: (d['notas'] as String?) ?? '',
      restamEsteMes: (d['restam_este_mes'] as num?)?.toInt(),
    );
  }
}

/// Porque é que não deu para ler. Cada uma tem a sua frase na app.
enum ErroLeitura {
  semFoto, // a pessoa desistiu de escolher
  cadeado, // acabaram as leituras do mês no plano grátis
  semServico, // a chave da IA não está posta
  fotoGrande,
  naoLi, // tremida, cortada, ou o modelo não percebeu
  rede,
}

class ResultadoLeitura {
  final DocumentoLido? documento;
  final ErroLeitura? erro;
  const ResultadoLeitura.ok(this.documento) : erro = null;
  const ResultadoLeitura.falhou(this.erro) : documento = null;
  bool get correu => documento != null;
}

/// Tira a foto (ou escolhe da galeria) e manda-a ler pelo servidor.
///
/// Regra da casa, e da Play: fotos pelo **Photo Picker** do Android, nunca pelo
/// seletor antigo. Assim a app não precisa de pedir permissão para ver as fotos
/// todas — a pessoa escolhe uma e é só essa que a app vê.
class LeitorDocumento {
  /// [tipoEsperado] ajuda o modelo: 'fatura', 'combustivel' ou 'talao'.
  static Future<ResultadoLeitura> ler({
    required ImageSource origem,
    String? tipoEsperado,
  }) async {
    final p = ImagePickerPlatform.instance;
    if (p is ImagePickerAndroid) p.useAndroidPhotoPicker = true;

    final XFile? foto;
    try {
      foto = await ImagePicker().pickImage(
        source: origem,
        maxWidth: 1800,
        imageQuality: 85,
      );
    } catch (e) {
      debugPrint('LeitorDocumento: não deu para escolher a foto — $e');
      return const ResultadoLeitura.falhou(ErroLeitura.naoLi);
    }
    if (foto == null) return const ResultadoLeitura.falhou(ErroLeitura.semFoto);

    try {
      final bytes = await foto.readAsBytes();
      // ~6 MB de imagem viram ~8 MB em base64, que é o tecto do servidor.
      if (bytes.length > 5_800_000) {
        return const ResultadoLeitura.falhou(ErroLeitura.fotoGrande);
      }
      final res = await sb.functions.invoke('ler-documento', body: {
        'imagem_base64': base64Encode(bytes),
        'mime': _mime(foto),
        if (tipoEsperado != null) 'tipo_esperado': tipoEsperado,
      });
      return ResultadoLeitura.ok(
        DocumentoLido.daResposta(Map<String, dynamic>.from(res.data as Map)),
      );
    } on FunctionException catch (e) {
      return ResultadoLeitura.falhou(switch (e.status) {
        402 => ErroLeitura.cadeado,
        413 => ErroLeitura.fotoGrande,
        503 => ErroLeitura.semServico,
        _ => ErroLeitura.naoLi,
      });
    } catch (e) {
      debugPrint('LeitorDocumento: $e');
      return const ResultadoLeitura.falhou(ErroLeitura.rede);
    }
  }

  static String _mime(XFile f) {
    final nome = f.name.toLowerCase();
    if (nome.endsWith('.png')) return 'image/png';
    if (nome.endsWith('.webp')) return 'image/webp';
    if (nome.endsWith('.heic')) return 'image/heic';
    if (nome.endsWith('.pdf')) return 'application/pdf';
    return 'image/jpeg';
  }
}
