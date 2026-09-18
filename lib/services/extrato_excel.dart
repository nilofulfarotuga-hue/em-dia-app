import 'package:excel/excel.dart';

import '../regras/extrato_banco.dart';

/// Lê um `.xlsx` do banco em Dart puro (pacote `excel`) e entrega as células
/// como texto ao leitor genérico (`lerExtratoDeCelulas`). Datas guardadas
/// como número de série do Excel são convertidas para `dd-mm-aaaa`; números
/// ficam com vírgula decimal para o leitor os tratar como os CSV portugueses.
ExtratoLido lerExtratoXlsx(List<int> bytes, {String nomeFicheiro = ''}) {
  final Excel folha;
  try {
    folha = Excel.decodeBytes(bytes);
  } catch (e) {
    throw const ExtratoInvalido('excel_ilegivel');
  }
  // A folha com mais linhas é a dos movimentos (as outras são capas/resumos).
  Sheet? melhor;
  for (final s in folha.tables.values) {
    if (melhor == null || s.maxRows > melhor.maxRows) melhor = s;
  }
  if (melhor == null || melhor.maxRows == 0) throw const ExtratoInvalido('ficheiro_vazio');
  final tabela = <List<String>>[];
  for (final linha in melhor.rows) {
    tabela.add([for (final c in linha) _texto(c)]);
  }
  return lerExtratoDeCelulas(tabela, nomeFicheiro: nomeFicheiro);
}

String _texto(Data? c) {
  final v = c?.value;
  if (v == null) return '';
  if (v is DateCellValue) {
    return '${v.day.toString().padLeft(2, '0')}-${v.month.toString().padLeft(2, '0')}-${v.year}';
  }
  if (v is DateTimeCellValue) {
    return '${v.day.toString().padLeft(2, '0')}-${v.month.toString().padLeft(2, '0')}-${v.year}';
  }
  if (v is IntCellValue) return v.value.toString();
  if (v is DoubleCellValue) {
    // à portuguesa, para o leitor: 1234.5 → "1234,50"
    return v.value.toStringAsFixed(2).replaceAll('.', ',');
  }
  if (v is TextCellValue) return v.value.toString();
  return v.toString();
}
