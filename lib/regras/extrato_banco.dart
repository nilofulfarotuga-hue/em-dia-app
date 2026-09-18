/// Ler um extrato de banco (CSV ou Excel) e transformá-lo em movimentos.
///
/// Todos os bancos portugueses deixam exportar os movimentos em CSV ou Excel
/// (CGD, Santander, Millennium, Novobanco, BPI, ActivoBank, Moey, Revolut). Os
/// ficheiros não são todos iguais: uns usam `;`, outros `,`; uns têm uma coluna
/// «Valor» com sinal, outros duas («Débito» e «Crédito»); as datas vêm
/// `dd-mm-aaaa`, `dd/mm/aaaa` ou `aaaa-mm-dd`; os números vêm `1.234,56` ou
/// `-12.50` (Revolut). Por isso isto não conhece bancos de cor — procura a
/// linha do cabeçalho, reconhece as colunas pelos nomes e lê o resto.
///
/// Tudo em Dart puro (sem Flutter, sem servidor): o extrato nunca sai do
/// aparelho para ser lido. Testado em `test/unit/extrato_banco_test.dart`.
library;

import 'dart:convert';

/// Um movimento lido do extrato. [valor] positivo entrou, negativo saiu.
class MovimentoLido {
  final DateTime data;
  final String descricao;
  final double valor;
  final double? saldo;

  const MovimentoLido({required this.data, required this.descricao, required this.valor, this.saldo});

  bool get entra => valor > 0;

  /// Chave estável para não importar duas vezes o mesmo movimento
  /// (o mesmo dia, o mesmo valor e a mesma descrição, sem acentos nem espaços a mais).
  String get chave => '${_iso(data)}|${valor.toStringAsFixed(2)}|${normalizarDescricao(descricao)}';

  @override
  String toString() => '${_iso(data)} ${valor.toStringAsFixed(2)} $descricao';
}

/// O que a leitura devolveu: os movimentos, o banco (se se reconheceu), e o
/// que não se conseguiu ler — para a pessoa saber, e para o painel admin
/// (`importacoes_extrato`) contar erros.
class ExtratoLido {
  final List<MovimentoLido> movimentos;
  final String? banco;
  final String formato; // csv | xlsx
  final int linhasLidas;
  final List<String> linhasIgnoradas;

  const ExtratoLido({
    required this.movimentos,
    required this.banco,
    required this.formato,
    required this.linhasLidas,
    required this.linhasIgnoradas,
  });

  bool get vazio => movimentos.isEmpty;
}

class ExtratoInvalido implements Exception {
  final String motivo;
  const ExtratoInvalido(this.motivo);
  @override
  String toString() => 'ExtratoInvalido: $motivo';
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Minúsculas, sem acentos, sem números de referência longos, sem espaços a
/// mais. É com isto que se junta «COMPRA 1234 NETFLIX.COM» de meses diferentes.
String normalizarDescricao(String s) {
  var t = s.toLowerCase();
  const de = 'áàãâäéèêëíìîïóòõôöúùûüçñ';
  const para = 'aaaaaeeeeiiiiooooouuuucn';
  for (var i = 0; i < de.length; i++) {
    t = t.replaceAll(de[i], para[i]);
  }
  // datas e números compridos dentro da descrição mudam todos os meses e não
  // dizem nada sobre quem cobrou.
  t = t.replaceAll(RegExp(r'\d{2}[/.-]\d{2}([/.-]\d{2,4})?'), ' ');
  t = t.replaceAll(RegExp(r'\b\d{4,}\b'), ' ');
  t = t.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
  return t.replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Lê um número escrito à portuguesa (`1.234,56`, `-12,50`, `12,50 €`) ou à
/// inglesa (`-12.50`, `1,234.56`). Devolve nulo quando não é um número.
double? lerNumeroExtrato(String? s) {
  if (s == null) return null;
  var t = s.trim().replaceAll('€', '').replaceAll('EUR', '').replaceAll(' ', '').replaceAll(' ', '');
  if (t.isEmpty || t == '-') return null;
  // (12,50) = negativo em alguns exports
  var negativo = false;
  if (t.startsWith('(') && t.endsWith(')')) {
    negativo = true;
    t = t.substring(1, t.length - 1);
  }
  if (t.startsWith('+')) t = t.substring(1);
  if (t.startsWith('-')) {
    negativo = !negativo;
    t = t.substring(1);
  }
  final temVirgula = t.contains(',');
  final temPonto = t.contains('.');
  if (temVirgula && temPonto) {
    // o último separador é o decimal
    if (t.lastIndexOf(',') > t.lastIndexOf('.')) {
      t = t.replaceAll('.', '').replaceAll(',', '.');
    } else {
      t = t.replaceAll(',', '');
    }
  } else if (temVirgula) {
    // «1,234» sem decimais é raro nos bancos; «12,50» é o normal → vírgula decimal
    final partes = t.split(',');
    if (partes.length == 2 && partes[1].length == 3 && partes[0].length <= 3) {
      t = t.replaceAll(',', ''); // 1,234 à inglesa (Revolut nunca manda assim, mas fica)
    } else {
      t = t.replaceAll(',', '.');
    }
  } else if (temPonto) {
    final partes = t.split('.');
    if (partes.length > 2 || (partes.length == 2 && partes[1].length == 3 && partes[0].length <= 3 && !t.contains('.0'))) {
      // 1.234 ou 1.234.567: pontos de milhar à portuguesa
      t = t.replaceAll('.', '');
    }
  }
  if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(t)) return null;
  final v = double.parse(t);
  return negativo ? -v : v;
}

/// Lê uma data `dd-mm-aaaa`, `dd/mm/aaaa`, `dd.mm.aaaa`, `aaaa-mm-dd` (com ou
/// sem hora) ou `dd-mm-aa`. Nulo quando não é uma data.
DateTime? lerDataExtrato(String? s) {
  if (s == null) return null;
  final t = s.trim();
  if (t.isEmpty) return null;
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(t);
  if (iso != null) {
    return _dataValida(int.parse(iso.group(1)!), int.parse(iso.group(2)!), int.parse(iso.group(3)!));
  }
  final pt = RegExp(r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})').firstMatch(t);
  if (pt != null) {
    var ano = int.parse(pt.group(3)!);
    if (ano < 100) ano += 2000;
    return _dataValida(ano, int.parse(pt.group(2)!), int.parse(pt.group(1)!));
  }
  return null;
}

DateTime? _dataValida(int a, int m, int d) {
  if (m < 1 || m > 12 || d < 1 || d > 31 || a < 1990 || a > 2100) return null;
  final x = DateTime(a, m, d);
  return (x.month == m && x.day == d) ? x : null;
}

// ---------------------------------------------------------------------------
// Reconhecer as colunas
// ---------------------------------------------------------------------------

String _limparCabecalho(String s) => normalizarDescricao(s).replaceAll('.', '');

const _nomesData = ['data mov', 'data movimento', 'data lancamento', 'data operacao', 'data', 'date', 'completed date', 'started date', 'data valor'];
const _nomesDescricao = ['descricao', 'descricao do movimento', 'descritivo', 'description', 'movimento', 'historico', 'detalhe', 'designacao'];
const _nomesValor = ['valor', 'montante', 'importancia', 'amount', 'valor eur', 'montante eur'];
const _nomesDebito = ['debito', 'debit', 'valor debito', 'a debito', 'saida', 'saidas'];
const _nomesCredito = ['credito', 'credit', 'valor credito', 'a credito', 'entrada', 'entradas'];
const _nomesSaldo = ['saldo', 'saldo contabilistico', 'saldo disponivel', 'balance', 'saldo apos movimento'];

int _indice(List<String> cabecalho, List<String> nomes, {Set<int> excluir = const {}}) {
  for (final n in nomes) {
    final i = cabecalho.indexWhere((c) => c == n);
    if (i >= 0 && !excluir.contains(i)) return i;
  }
  for (final n in nomes) {
    // «Data valor» não é a coluna do valor: as colunas de data ficam de fora
    // da procura aproximada (cicatriz do teste E07).
    for (var i = 0; i < cabecalho.length; i++) {
      final c = cabecalho[i];
      if (excluir.contains(i) || c.startsWith('data ')) continue;
      if (c.startsWith(n) || c.contains(' $n')) return i;
    }
  }
  return -1;
}

class _Colunas {
  final int data;
  final int descricao;
  final int valor; // -1 quando há débito/crédito
  final int debito;
  final int credito;
  final int saldo;
  const _Colunas(this.data, this.descricao, this.valor, this.debito, this.credito, this.saldo);
  bool get valida => data >= 0 && descricao >= 0 && (valor >= 0 || (debito >= 0 && credito >= 0));
}

_Colunas _reconhecer(List<String> linha) {
  final c = linha.map(_limparCabecalho).toList();
  var data = _indice(c, _nomesData);
  // Revolut: «Started Date» e «Completed Date» — a que conta é a concluída.
  final concluida = c.indexOf('completed date');
  if (concluida >= 0) data = concluida;
  // todas as colunas de data ficam fora das outras procuras
  final datas = <int>{for (var i = 0; i < c.length; i++) if (c[i].startsWith('data') || c[i].endsWith('date')) i};
  final debito = _indice(c, _nomesDebito, excluir: datas);
  final credito = _indice(c, _nomesCredito, excluir: datas);
  // com Débito e Crédito, a coluna «Valor» solta não interessa
  final valor = (debito >= 0 && credito >= 0) ? -1 : _indice(c, _nomesValor, excluir: datas);
  return _Colunas(
    data,
    _indice(c, _nomesDescricao, excluir: datas),
    valor,
    debito,
    credito,
    _indice(c, _nomesSaldo, excluir: datas),
  );
}

/// Adivinha o banco pelas primeiras linhas (o nome do banco costuma vir antes
/// do cabeçalho) e pelo nome do ficheiro. Só para etiquetar a importação — a
/// leitura não depende disto.
String? reconhecerBanco(List<String> cabecalho, String nomeFicheiro) {
  final c = cabecalho.map(_limparCabecalho).join('|');
  final f = nomeFicheiro.toLowerCase();
  if (c.contains('started date') && c.contains('completed date')) return 'revolut';
  for (final (chave, nome) in const [
    ('cgd', 'cgd'), ('caixa', 'cgd'), ('santander', 'santander'), ('millennium', 'millennium'), ('bcp', 'millennium'),
    ('novobanco', 'novobanco'), ('novo banco', 'novobanco'), ('bpi', 'bpi'), ('activobank', 'activobank'),
    ('moey', 'moey'), ('revolut', 'revolut'), ('montepio', 'montepio'), ('bankinter', 'bankinter'), ('credito agricola', 'credito_agricola'),
  ]) {
    if (f.contains(chave) || c.contains(chave)) return nome;
  }
  return null;
}

// ---------------------------------------------------------------------------
// CSV
// ---------------------------------------------------------------------------

/// Descodifica os bytes: UTF-8 quando é válido, senão Latin-1 (os bancos
/// portugueses ainda exportam muito em Windows-1252, com «ç» e «ã» a um byte).
String descodificarTexto(List<int> bytes) {
  try {
    var s = utf8.decode(bytes);
    if (s.startsWith('﻿')) s = s.substring(1);
    return s;
  } on FormatException {
    return latin1.decode(bytes);
  }
}

/// O separador que mais aparece nas primeiras linhas com conteúdo.
String detetarSeparador(List<String> linhas) {
  var melhor = ';';
  var max = -1;
  for (final sep in const [';', ',', '\t', '|']) {
    var total = 0;
    for (final l in linhas.take(20)) {
      total += sep.allMatches(l).length;
    }
    if (total > max) {
      max = total;
      melhor = sep;
    }
  }
  return melhor;
}

/// Divide uma linha CSV respeitando aspas («"1.234,56"», «"COMPRA; LOJA"»).
List<String> dividirLinhaCsv(String linha, String sep) {
  final out = <String>[];
  final sb = StringBuffer();
  var dentro = false;
  for (var i = 0; i < linha.length; i++) {
    final ch = linha[i];
    if (ch == '"') {
      if (dentro && i + 1 < linha.length && linha[i + 1] == '"') {
        sb.write('"');
        i++;
      } else {
        dentro = !dentro;
      }
    } else if (ch == sep && !dentro) {
      out.add(sb.toString());
      sb.clear();
    } else {
      sb.write(ch);
    }
  }
  out.add(sb.toString());
  return out.map((c) => c.trim()).toList();
}

/// Lê um CSV (bytes) e devolve os movimentos.
ExtratoLido lerExtratoCsv(List<int> bytes, {String nomeFicheiro = ''}) {
  final texto = descodificarTexto(bytes);
  final linhas = const LineSplitter().convert(texto).where((l) => l.trim().isNotEmpty).toList();
  if (linhas.isEmpty) throw const ExtratoInvalido('ficheiro_vazio');
  final sep = detetarSeparador(linhas);
  final tabela = linhas.map((l) => dividirLinhaCsv(l, sep)).toList();
  return _lerTabela(tabela, formato: 'csv', nomeFicheiro: nomeFicheiro);
}

/// Lê uma tabela já dividida em células (CSV ou folha de Excel).
ExtratoLido _lerTabela(List<List<String>> tabela, {required String formato, required String nomeFicheiro}) {
  // 1. a linha do cabeçalho: a primeira (nas 30 primeiras) em que se reconhecem as colunas.
  var iCab = -1;
  _Colunas? cols;
  for (var i = 0; i < tabela.length && i < 30; i++) {
    final c = _reconhecer(tabela[i]);
    if (c.valida) {
      iCab = i;
      cols = c;
      break;
    }
  }
  if (cols == null) throw const ExtratoInvalido('sem_cabecalho');
  final banco = reconhecerBanco([for (var i = 0; i <= iCab; i++) ...tabela[i]], nomeFicheiro);
  final movimentos = <MovimentoLido>[];
  final ignoradas = <String>[];
  var lidas = 0;
  for (var i = iCab + 1; i < tabela.length; i++) {
    final l = tabela[i];
    if (l.every((c) => c.trim().isEmpty)) continue;
    lidas++;
    String celula(int k) => (k >= 0 && k < l.length) ? l[k] : '';
    final data = lerDataExtrato(celula(cols.data));
    if (data == null) {
      ignoradas.add(l.join(' | '));
      continue;
    }
    double? valor;
    if (cols.valor >= 0) {
      valor = lerNumeroExtrato(celula(cols.valor));
    } else {
      final d = lerNumeroExtrato(celula(cols.debito));
      final c = lerNumeroExtrato(celula(cols.credito));
      if (d == null && c == null) {
        valor = null;
      } else {
        // o débito às vezes já vem negativo, às vezes não — sai sempre negativo
        valor = (c ?? 0) - (d ?? 0).abs();
      }
    }
    if (valor == null) {
      ignoradas.add(l.join(' | '));
      continue;
    }
    final descricao = celula(cols.descricao).trim();
    movimentos.add(MovimentoLido(
      data: data,
      descricao: descricao.isEmpty ? '(sem descrição)' : descricao,
      valor: valor,
      saldo: cols.saldo >= 0 ? lerNumeroExtrato(celula(cols.saldo)) : null,
    ));
  }
  movimentos.sort((a, b) => b.data.compareTo(a.data));
  return ExtratoLido(movimentos: movimentos, banco: banco, formato: formato, linhasLidas: lidas, linhasIgnoradas: ignoradas);
}

/// Ponto de entrada para folhas de Excel já convertidas em células de texto
/// (quem lê o .xlsx é `lib/services/extrato_excel.dart`, que depende do pacote
/// `excel`; aqui fica-se sem dependências para os testes serem rápidos).
ExtratoLido lerExtratoDeCelulas(List<List<String>> tabela, {String nomeFicheiro = ''}) =>
    _lerTabela(tabela, formato: 'xlsx', nomeFicheiro: nomeFicheiro);

// ---------------------------------------------------------------------------
// Categorias e coisas que se repetem
// ---------------------------------------------------------------------------

/// Uma regra «se a descrição tem X, a categoria é Y». As da tabela
/// `categorias_regras` mandam; estas são o espelho para funcionar sem rede.
class RegraCategoria {
  final String padrao; // já normalizado (minúsculas, sem acentos)
  final String categoria; // uma das categorias de `saidas`, ou 'rendimento'
  final String? fornecedor;
  const RegraCategoria(this.padrao, this.categoria, [this.fornecedor]);
}

const List<RegraCategoria> regrasCategoriaPadrao = [
  RegraCategoria('meo', 'telemovel', 'MEO'),
  RegraCategoria('altice', 'telemovel', 'MEO'),
  RegraCategoria('nos ', 'telemovel', 'NOS'),
  RegraCategoria('nos comunicacoes', 'telemovel', 'NOS'),
  RegraCategoria('vodafone', 'telemovel', 'Vodafone'),
  RegraCategoria('nowo', 'internet', 'NOWO'),
  RegraCategoria('digi', 'telemovel', 'DIGI'),
  RegraCategoria('edp', 'luz', 'EDP'),
  RegraCategoria('endesa', 'luz', 'Endesa'),
  RegraCategoria('iberdrola', 'luz', 'Iberdrola'),
  RegraCategoria('goldenergy', 'luz', 'Goldenergy'),
  RegraCategoria('galp', 'combustivel', 'Galp'),
  RegraCategoria('bp ', 'combustivel', 'BP'),
  RegraCategoria('repsol', 'combustivel', 'Repsol'),
  RegraCategoria('cepsa', 'combustivel', 'Cepsa'),
  RegraCategoria('prio', 'combustivel', 'Prio'),
  RegraCategoria('aguas', 'agua', null),
  RegraCategoria('epal', 'agua', 'EPAL'),
  RegraCategoria('netflix', 'assinatura', 'Netflix'),
  RegraCategoria('spotify', 'assinatura', 'Spotify'),
  RegraCategoria('disney', 'assinatura', 'Disney+'),
  RegraCategoria('hbo', 'assinatura', 'HBO Max'),
  RegraCategoria('amazon prime', 'assinatura', 'Amazon Prime'),
  RegraCategoria('prime video', 'assinatura', 'Amazon Prime'),
  RegraCategoria('youtube', 'assinatura', 'YouTube'),
  RegraCategoria('apple com', 'assinatura', 'Apple'),
  RegraCategoria('google', 'assinatura', 'Google'),
  RegraCategoria('microsoft', 'assinatura', 'Microsoft'),
  RegraCategoria('fitness hut', 'ginasio', 'Fitness Hut'),
  RegraCategoria('solinca', 'ginasio', 'Solinca'),
  RegraCategoria('holmes place', 'ginasio', 'Holmes Place'),
  RegraCategoria('ginasio', 'ginasio', null),
  RegraCategoria('continente', 'compras', 'Continente'),
  RegraCategoria('pingo doce', 'compras', 'Pingo Doce'),
  RegraCategoria('lidl', 'compras', 'Lidl'),
  RegraCategoria('auchan', 'compras', 'Auchan'),
  RegraCategoria('mercadona', 'compras', 'Mercadona'),
  RegraCategoria('intermarche', 'compras', 'Intermarché'),
  RegraCategoria('minipreco', 'compras', 'Minipreço'),
  RegraCategoria('aldi', 'compras', 'Aldi'),
  RegraCategoria('farmacia', 'saude', null),
  RegraCategoria('seguranca social', 'imposto', 'Segurança Social'),
  RegraCategoria('seg social', 'imposto', 'Segurança Social'),
  RegraCategoria('autoridade tributaria', 'imposto', 'AT'),
  RegraCategoria('at pagamento', 'imposto', 'AT'),
  RegraCategoria('iuc', 'imposto', 'AT'),
  RegraCategoria('seguro', 'seguro', null),
  RegraCategoria('fidelidade', 'seguro', 'Fidelidade'),
  RegraCategoria('tranquilidade', 'seguro', 'Tranquilidade'),
  RegraCategoria('allianz', 'seguro', 'Allianz'),
  RegraCategoria('ageas', 'seguro', 'Ageas'),
  RegraCategoria('renda', 'renda', null),
  RegraCategoria('prestacao', 'credito', null),
  RegraCategoria('credito', 'credito', null),
  RegraCategoria('cofidis', 'credito', 'Cofidis'),
  RegraCategoria('cetelem', 'credito', 'Cetelem'),
  RegraCategoria('via verde', 'carro', 'Via Verde'),
  RegraCategoria('brisa', 'carro', 'Brisa'),
  RegraCategoria('uber', 'rendimento', 'Uber'),
  RegraCategoria('bolt', 'rendimento', 'Bolt'),
  RegraCategoria('glovo', 'rendimento', 'Glovo'),
  RegraCategoria('uber eats', 'rendimento', 'Uber Eats'),
];

/// A categoria de um movimento pela descrição. Créditos das apps de trabalho
/// são «rendimento»; o resto sem regra fica «outro».
({String categoria, String? fornecedor}) categorizar(MovimentoLido m, {List<RegraCategoria> regras = regrasCategoriaPadrao}) {
  final d = ' ${normalizarDescricao(m.descricao)} ';
  for (final r in regras) {
    if (d.contains(' ${r.padrao}') || d.contains(r.padrao)) {
      if (r.categoria == 'rendimento' && !m.entra) continue;
      return (categoria: r.categoria, fornecedor: r.fornecedor);
    }
  }
  return (categoria: m.entra ? 'entrada' : 'outro', fornecedor: null);
}

/// Uma coisa que se repete: o mesmo nome, mais ou menos o mesmo valor, em
/// meses diferentes.
class Recorrente {
  final String nome; // a descrição mais recente, tal como o banco a escreve
  final String chave; // descrição normalizada
  final double valorMedio;
  final int diaHabitual;
  final List<DateTime> datas;
  final String categoria;
  final String? fornecedor;

  const Recorrente({
    required this.nome,
    required this.chave,
    required this.valorMedio,
    required this.diaHabitual,
    required this.datas,
    required this.categoria,
    this.fornecedor,
  });

  int get vezes => datas.length;
  DateTime get ultima => datas.first;
}

/// Encontra o que se repete nos débitos: a mesma descrição (normalizada) em
/// pelo menos [minimoMeses] meses diferentes, com valores a menos de
/// [toleranciaPct] do valor médio. É o que o Rocket Money faz por detrás.
List<Recorrente> encontrarRecorrentes(
  List<MovimentoLido> movimentos, {
  int minimoMeses = 2,
  double toleranciaPct = 15,
  List<RegraCategoria> regras = regrasCategoriaPadrao,
}) {
  final grupos = <String, List<MovimentoLido>>{};
  for (final m in movimentos) {
    if (m.entra) continue;
    final k = normalizarDescricao(m.descricao);
    if (k.isEmpty) continue;
    grupos.putIfAbsent(k, () => []).add(m);
  }
  final out = <Recorrente>[];
  for (final e in grupos.entries) {
    final lista = e.value..sort((a, b) => b.data.compareTo(a.data));
    final meses = lista.map((m) => '${m.data.year}-${m.data.month}').toSet();
    if (meses.length < minimoMeses) continue;
    final media = lista.map((m) => m.valor.abs()).reduce((a, b) => a + b) / lista.length;
    final estavel = lista.every((m) => (m.valor.abs() - media).abs() <= media * toleranciaPct / 100);
    if (!estavel) continue;
    final dias = lista.map((m) => m.data.day).toList()..sort();
    final cat = categorizar(lista.first, regras: regras);
    out.add(Recorrente(
      nome: lista.first.descricao,
      chave: e.key,
      valorMedio: (media * 100).round() / 100,
      diaHabitual: dias[dias.length ~/ 2],
      datas: lista.map((m) => m.data).toList(),
      categoria: cat.categoria,
      fornecedor: cat.fornecedor,
    ));
  }
  out.sort((a, b) => b.valorMedio.compareTo(a.valorMedio));
  return out;
}

/// «Pagas X por mês em coisas que se repetem.»
double totalMensalRecorrente(List<Recorrente> r) => r.fold(0.0, (s, x) => s + x.valorMedio);
