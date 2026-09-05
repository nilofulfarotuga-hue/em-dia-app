/// Formatos de Portugal: moeda `1.234,56 €`, datas `dd/mm/aaaa`.
library;

String moeda(num valor, {bool comSimbolo = true, int casas = 2}) {
  final negativo = valor < 0;
  final abs = valor.abs();
  final fixo = abs.toStringAsFixed(casas);
  final partes = fixo.split('.');
  final inteiro = partes[0];
  final decimais = partes.length > 1 ? partes[1] : '';
  final sb = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final resto = inteiro.length - i;
    sb.write(inteiro[i]);
    if (resto > 1 && resto % 3 == 1) sb.write('.');
  }
  final texto = casas > 0 ? '${sb.toString()},$decimais' : sb.toString();
  return '${negativo ? '-' : ''}$texto${comSimbolo ? ' €' : ''}';
}

String dataPt(DateTime d) =>
    '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

String mesAnoPt(DateTime d) => '${_dois(d.month)}/${d.year}';

const List<String> nomesMeses = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

const List<String> nomesMesesCurtos = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

String nomeMes(int mes) => nomesMeses[mes - 1];

String dataExtensoPt(DateTime d) => '${d.day} de ${nomeMes(d.month)} de ${d.year}';

String _dois(int n) => n < 10 ? '0$n' : '$n';

/// Percentagem com vírgula: 21,4%
String pct(num valor, {int casas = 1}) =>
    '${valor.toStringAsFixed(casas).replaceAll('.', ',')}%';

/// Arredonda a cêntimos.
double centimos(num v) => (v * 100).round() / 100;

/// Lê "1.234,56" ou "1234.56" escrito pelo utilizador.
double? lerNumero(String texto) {
  var t = texto.trim().replaceAll('€', '').replaceAll(' ', '');
  if (t.isEmpty) return null;
  if (t.contains(',') && t.contains('.')) {
    t = t.replaceAll('.', '').replaceAll(',', '.');
  } else if (t.contains(',')) {
    t = t.replaceAll(',', '.');
  }
  return double.tryParse(t);
}
