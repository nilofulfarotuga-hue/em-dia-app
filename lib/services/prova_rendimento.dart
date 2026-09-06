/// A prova de rendimento em PDF (invenção 2 de 5).
///
/// Quem anda a recibos verdes não tem recibo de vencimento. Sem esse papel
/// ouve "não" no senhorio, no banco e na financeira — não por ganhar pouco,
/// mas por não ter como MOSTRAR o que ganha. Esta folha é isso: o que a pessoa
/// escreveu na app, arrumado, somado e assumido como nosso.
///
/// O ficheiro está partido em duas metades de propósito:
///  - [ProvaRendimento.contar] é puro (sem Flutter, sem PDF): dá-se a testar
///    sozinho e é onde vivem as decisões de contagem;
///  - [ProvaRendimento.folha] só desenha, e recebe TODOS os textos já
///    traduzidos em [TextosProva]. É por isso que não há uma única frase em
///    português dentro deste Dart — a regra da casa é que os textos vivem nos
///    `.arb`, e um PDF não é exceção.
///
/// NADA aqui se parece com um documento oficial: sem brasão, sem logótipo das
/// Finanças, sem selo. É uma folha nossa e o rodapé diz que é nossa.
library;

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/entrada.dart';
import '../regras/regras.dart';

/// Uma linha do mapa: um mês do período e o dinheiro que entrou nele.
class MesDaProva {
  final int ano;
  final int mes;
  final double total;

  /// Quantas vezes entrou dinheiro nesse mês. Não vai para o papel, mas serve
  /// para o ecrã dizer se o mês está mesmo vazio ou só é pequeno.
  final int quantas;

  const MesDaProva({
    required this.ano,
    required this.mes,
    required this.total,
    required this.quantas,
  });

  /// "março de 2026". Os nomes dos meses escrevem-se igual em PT-PT e PT-BR,
  /// por isso saem da biblioteca das regras (como o `moeda`) e não da tradução.
  String get rotulo => '${nomeMes(mes)} de $ano';
}

/// Quem assina a folha. Vem do perfil e do que a pessoa escreve no ecrã — o
/// NIF ainda não tem coluna em `profiles`, por isso é escrito à mão.
class PessoaProva {
  final String nome;
  final String? nif;
  const PessoaProva({required this.nome, this.nif});

  /// Sem NIF a folha sai na mesma; só perde uma linha. Um senhorio aceita,
  /// um banco costuma pedir — por isso o ecrã pede, mas não obriga.
  bool get temNif => (nif ?? '').trim().isNotEmpty;
}

/// O período já contado. Puro: só números e códigos, zero texto para ler.
class DadosProva {
  /// Primeiro dia do primeiro mês do período.
  final DateTime inicio;

  /// Último dia do último mês do período.
  final DateTime fim;

  /// Um item por mês do período, do mais antigo para o mais recente. Um mês
  /// sem nada aparece com 0,00 € — some-lo do mapa era esconder um buraco.
  final List<MesDaProva> meses;

  /// De onde veio o dinheiro, em códigos: `recibo_verde`, `plataforma`,
  /// `plataforma:uber`… Quem traduz isto é o ecrã.
  final List<String> origens;

  /// Quantos meses de história ainda faltam para esta folha fazer sentido.
  final int mesesEmFalta;

  final DateTime feitaEm;

  const DadosProva({
    required this.inicio,
    required this.fim,
    required this.meses,
    required this.origens,
    required this.mesesEmFalta,
    required this.feitaEm,
  });

  double get total => meses.fold(0.0, (s, m) => s + m.total);

  /// A média divide pelo NÚMERO DE MESES DO PERÍODO, não pelos meses em que
  /// entrou alguma coisa. Dividir só pelos meses "bons" dava um número maior e
  /// falso: quem lê a folha quer saber com quanto é que pode contar por mês.
  double get mediaMensal => meses.isEmpty ? 0 : total / meses.length;

  /// Quantos meses do período têm mesmo dinheiro escrito.
  int get mesesComDinheiro => meses.where((m) => m.total > 0).length;

  /// Uma folha a zeros não prova nada e queima a confiança de quem a recebe.
  bool get podeFazer => mesesEmFalta == 0 && total > 0;
}

/// Todas as frases que vão para o papel, já na língua de quem está a ver.
/// Quem preenche isto é o ecrã, a partir do `AppLocalizations`.
class TextosProva {
  final String titulo;
  final String app;
  final String rotuloNome;
  final String rotuloNif;
  final String rotuloPeriodo;

  /// Já formatado ("1 de março de 2026 a 31 de agosto de 2026").
  final String periodo;

  final String rotuloMedia;
  final String ajudaMedia;
  final String colunaMes;
  final String colunaValor;
  final String rotuloTotal;
  final String rotuloOrigem;

  /// Já junto numa linha ("Recibo verde, App de trabalho (Uber, Bolt)").
  final String origem;

  /// Já formatado ("Folha feita a 06/09/2026.").
  final String feitaEm;

  /// A frase honesta do rodapé. É obrigatória: é ela que impede esta folha de
  /// se fazer passar por um documento das Finanças.
  final String honesto;

  const TextosProva({
    required this.titulo,
    required this.app,
    required this.rotuloNome,
    required this.rotuloNif,
    required this.rotuloPeriodo,
    required this.periodo,
    required this.rotuloMedia,
    required this.ajudaMedia,
    required this.colunaMes,
    required this.colunaValor,
    required this.rotuloTotal,
    required this.rotuloOrigem,
    required this.origem,
    required this.feitaEm,
    required this.honesto,
  });
}

/// Cores do papel. São as mesmas do `docs/DESIGN-SYSTEM.md`, repetidas aqui
/// porque o pacote `pdf` tem a sua própria classe de cor e não fala com o
/// `AppColors` (que é de Material). Se a paleta mudar, muda-se nos dois sítios.
const PdfColor _verde = PdfColor.fromInt(0xFF16A34A);
const PdfColor _verdeFundo = PdfColor.fromInt(0xFFF0FDF4);
const PdfColor _verdeEscuro = PdfColor.fromInt(0xFF065F46);
const PdfColor _texto = PdfColor.fromInt(0xFF111827);
const PdfColor _cinza = PdfColor.fromInt(0xFF6B7280);
const PdfColor _linha = PdfColor.fromInt(0xFFE5E7EB);
const PdfColor _riscaPar = PdfColor.fromInt(0xFFF6F7F4);

/// O caminho está no `pubspec.yaml` (secção `fonts`). Não se muda um sem o
/// outro — e o `pubspec.yaml` não é nosso para mexer.
const String _caminhoInter = 'assets/fonts/Inter-VariableFont.ttf';

class ProvaRendimento {
  ProvaRendimento._();

  static pw.Font? _fonteEmCache;
  static bool _saiuComAInter = false;

  /// `false` quando a Inter não carregou e a folha saiu com a letra de origem
  /// do PDF. Serve para os testes e para o relatório não dizerem que correu
  /// tudo bem quando não correu.
  static bool get saiuComAInter => _saiuComAInter;

  /// Conta o período. Puro: recebe a lista toda de entradas e devolve o mapa.
  ///
  /// [meses] é 3, 6 ou 12. [hoje] entra à mão para os testes e as fotos não
  /// dependerem do dia em que correm.
  static DadosProva contar({
    required List<Entrada> entradas,
    required int meses,
    required DateTime hoje,
    DateTime? feitaEm,
  }) {
    // O período são os últimos [meses] meses JÁ FECHADOS — o mês a decorrer
    // fica de fora. Meio mês misturado com meses inteiros puxa a média para
    // baixo, e quem recebe a folha não tem como saber disso: seria uma mentira
    // educada, e a folha existe exactamente para não haver dessas.
    final ultimoMes = adicionarMeses(DateTime(hoje.year, hoje.month, 1), -1);
    final fim = DateTime(
      ultimoMes.year,
      ultimoMes.month,
      ultimoDiaDoMes(ultimoMes.year, ultimoMes.month),
    );
    final inicio = adicionarMeses(DateTime(ultimoMes.year, ultimoMes.month, 1), -(meses - 1));

    final linhas = <MesDaProva>[];
    for (var i = 0; i < meses; i++) {
      final m = adicionarMeses(inicio, i);
      final doMes = entradas.where((e) => e.data.year == m.year && e.data.month == m.month).toList();
      linhas.add(MesDaProva(
        ano: m.year,
        mes: m.month,
        total: doMes.fold(0.0, (s, e) => s + e.valor),
        quantas: doMes.length,
      ));
    }

    final noPeriodo = entradas.where((e) {
      final d = soDia(e.data);
      return !d.isBefore(inicio) && !d.isAfter(fim);
    }).toList();

    // A ordem das origens é a dos tipos no formulário, não a da lista de
    // entradas: assim duas folhas da mesma pessoa saem sempre iguais.
    final tipos = <String>{for (final e in noPeriodo) e.tipo};
    final apps = <String>{
      for (final e in noPeriodo)
        if (e.tipo == 'plataforma' && e.plataforma != null) e.plataforma!,
    };
    final origens = <String>[
      for (final t in tiposEntrada)
        if (tipos.contains(t)) t,
      for (final p in plataformasEntrada)
        if (apps.contains(p)) 'plataforma:$p',
    ];

    // Quantos meses de história a pessoa tem mesmo.
    //
    // Não se contam os meses vazios DENTRO do período: quem tirou agosto de
    // férias mostra agosto a zero, e isso é verdade, não é falta de dados. O
    // que se mede é outra coisa — "já uso a app há tempo suficiente para esta
    // folha?" — e por isso conta-se desde a primeira vez que escreveu alguma
    // coisa. Sem isto, um mês de férias trancava a folha para sempre.
    final maisAntiga = entradas.isEmpty
        ? null
        : entradas.map((e) => soDia(e.data)).reduce((a, b) => a.isBefore(b) ? a : b);
    final bruto = maisAntiga == null
        ? 0
        : (fim.year * 12 + fim.month) - (maisAntiga.year * 12 + maisAntiga.month) + 1;
    final comHistorico = bruto < 0 ? 0 : (bruto > meses ? meses : bruto);

    return DadosProva(
      inicio: inicio,
      fim: fim,
      meses: linhas,
      origens: origens,
      mesesEmFalta: meses - comHistorico,
      feitaEm: feitaEm ?? hoje,
    );
  }

  /// Desenha a folha e devolve os bytes do PDF. Quem os guarda ou parte é o
  /// ecrã — este ficheiro não sabe o que é um telemóvel.
  static Future<Uint8List> folha({
    required DadosProva dados,
    required PessoaProva pessoa,
    required TextosProva textos,
  }) async {
    final fonte = await _fonte();
    final doc = pw.Document(
      title: textos.titulo,
      author: textos.app,
      creator: textos.app,
      theme: pw.ThemeData.withFont(base: fonte, bold: fonte),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 46, 42, 40),
        footer: (_) => _rodape(textos),
        build: (_) => [
          _cabecalho(textos),
          pw.SizedBox(height: 18),
          _quemEQuando(textos, pessoa),
          pw.SizedBox(height: 18),
          _destaqueDaMedia(textos, dados),
          pw.SizedBox(height: 18),
          _mapaDosMeses(textos, dados),
          pw.SizedBox(height: 16),
          _deOndeVem(textos),
        ],
      ),
    );

    return doc.save();
  }

  // ---------- as peças do papel ----------

  static pw.Widget _cabecalho(TextosProva t) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                t.titulo,
                style: const pw.TextStyle(fontSize: 24, color: _texto),
              ),
              pw.Text(
                t.app,
                style: const pw.TextStyle(fontSize: 12, color: _verde),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          // A única cor forte da folha. O laranja não entra aqui: no papel não
          // há "a vencer" nenhum, e a regra do laranja é para avisos.
          pw.Container(height: 3, color: _verde),
        ],
      );

  static pw.Widget _quemEQuando(TextosProva t, PessoaProva p) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _linhaDeIdentidade(t.rotuloNome, p.nome),
          if (p.temNif) ...[
            pw.SizedBox(height: 6),
            _linhaDeIdentidade(t.rotuloNif, p.nif!.trim()),
          ],
          pw.SizedBox(height: 6),
          _linhaDeIdentidade(t.rotuloPeriodo, t.periodo),
        ],
      );

  static pw.Widget _linhaDeIdentidade(String rotulo, String valor) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(rotulo, style: const pw.TextStyle(fontSize: 11, color: _cinza)),
          ),
          pw.Expanded(
            child: pw.Text(valor, style: const pw.TextStyle(fontSize: 12, color: _texto)),
          ),
        ],
      );

  /// O número mais importante da folha é o maior — é a regra do fiscal visual,
  /// e aqui é ela que decide o que a pessoa do outro lado da mesa vê primeiro.
  static pw.Widget _destaqueDaMedia(TextosProva t, DadosProva d) => pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: pw.BoxDecoration(
          color: _verdeFundo,
          borderRadius: pw.BorderRadius.circular(12),
          border: pw.Border.all(color: _verde, width: 0.8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(t.rotuloMedia, style: const pw.TextStyle(fontSize: 11, color: _verdeEscuro)),
            pw.SizedBox(height: 4),
            pw.Text(
              moeda(d.mediaMensal),
              style: const pw.TextStyle(fontSize: 34, color: _verdeEscuro),
            ),
            pw.SizedBox(height: 4),
            pw.Text(t.ajudaMedia, style: const pw.TextStyle(fontSize: 10, color: _cinza)),
          ],
        ),
      );

  static pw.Widget _mapaDosMeses(TextosProva t, DadosProva d) {
    final linhas = <pw.TableRow>[
      pw.TableRow(
        children: [
          _celula(t.colunaMes, tamanho: 10, cor: _cinza),
          _celula(t.colunaValor, tamanho: 10, cor: _cinza, direita: true),
        ],
      ),
    ];
    for (var i = 0; i < d.meses.length; i++) {
      final m = d.meses[i];
      linhas.add(
        pw.TableRow(
          // Riscas claras alternadas: com 12 linhas, o olho perde-se a seguir
          // o valor até ao fim da linha.
          decoration: i.isEven ? const pw.BoxDecoration(color: _riscaPar) : null,
          children: [
            _celula(m.rotulo),
            _celula(moeda(m.total), direita: true),
          ],
        ),
      );
    }
    linhas.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _texto, width: 1)),
        ),
        children: [
          _celula(t.rotuloTotal, tamanho: 13),
          _celula(moeda(d.total), tamanho: 13, cor: _verdeEscuro, direita: true),
        ],
      ),
    );

    return pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(color: _linha, width: 0.5),
      ),
      columnWidths: const {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(2)},
      children: linhas,
    );
  }

  static pw.Widget _celula(
    String texto, {
    double tamanho = 12,
    PdfColor cor = _texto,
    bool direita = false,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: pw.Text(
          texto,
          textAlign: direita ? pw.TextAlign.right : pw.TextAlign.left,
          style: pw.TextStyle(fontSize: tamanho, color: cor),
        ),
      );

  static pw.Widget _deOndeVem(TextosProva t) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(t.rotuloOrigem, style: const pw.TextStyle(fontSize: 11, color: _cinza)),
          pw.SizedBox(height: 3),
          pw.Text(t.origem, style: const pw.TextStyle(fontSize: 12, color: _texto)),
        ],
      );

  static pw.Widget _rodape(TextosProva t) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 12),
          pw.Container(height: 0.5, color: _linha),
          pw.SizedBox(height: 8),
          pw.Text(t.feitaEm, style: const pw.TextStyle(fontSize: 9, color: _cinza)),
          pw.SizedBox(height: 2),
          pw.Text(t.honesto, style: const pw.TextStyle(fontSize: 9, color: _cinza)),
        ],
      );

  // ---------- a letra ----------

  static Future<pw.Font> _fonte() async {
    final jaTenho = _fonteEmCache;
    if (jaTenho != null) return jaTenho;
    try {
      final f = pw.Font.ttf(await rootBundle.load(_caminhoInter));
      _fonteEmCache = f;
      _saiuComAInter = true;
      return f;
    } catch (e) {
      // Sem a Inter a folha sai com a letra de origem do PDF: mais feia, mas
      // legível e com os acentos certos. Vale mais uma folha com outra letra
      // do que folha nenhuma na mão de quem está à espera no banco. Fica no
      // log e em [saiuComAInter] para ninguém dizer que correu bem.
      debugPrint('prova_rendimento: não carreguei a Inter ($e)');
      final f = pw.Font.helvetica();
      _fonteEmCache = f;
      _saiuComAInter = false;
      return f;
    }
  }
}
