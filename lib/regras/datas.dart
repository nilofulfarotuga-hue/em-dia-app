/// Datas: fuso Europe/Lisbon, véspera útil, meses com dia "preso".
///
/// Regra da missão: um prazo que cai a fim-de-semana ou feriado avisa-se na
/// véspera útil. Toda a app usa ESTAS funções — nunca aritmética de datas à
/// mão num ecrã.
library;

/// Só a parte do dia (sem horas), para comparar e usar como chave.
DateTime soDia(DateTime d) => DateTime(d.year, d.month, d.day);

/// Hoje em Lisboa. O telemóvel pode estar noutro fuso (ou com a hora trocada);
/// os prazos legais contam à meia-noite de Lisboa.
DateTime hojeLisboa({DateTime? agoraUtc}) {
  final utc = (agoraUtc ?? DateTime.now().toUtc());
  return soDia(paraLisboa(utc));
}

/// Converte um instante UTC para a hora de Lisboa (WET/WEST) sem base de dados
/// de fusos: Portugal continental muda no último domingo de março (01:00 UTC)
/// e no último domingo de outubro (01:00 UTC).
DateTime paraLisboa(DateTime utc) {
  final u = utc.toUtc();
  final inicioVerao = _ultimoDomingo(u.year, 3).add(const Duration(hours: 1));
  final fimVerao = _ultimoDomingo(u.year, 10).add(const Duration(hours: 1));
  final verao = !u.isBefore(inicioVerao) && u.isBefore(fimVerao);
  final local = u.add(Duration(hours: verao ? 1 : 0));
  return DateTime(local.year, local.month, local.day, local.hour, local.minute,
      local.second);
}

DateTime _ultimoDomingo(int ano, int mes) {
  final ultimo = ultimoDiaDoMes(ano, mes);
  final d = DateTime.utc(ano, mes, ultimo);
  return d.subtract(Duration(days: d.weekday % 7));
}

int ultimoDiaDoMes(int ano, int mes) => DateTime(ano, mes + 1, 0).day;

/// Soma meses prendendo o dia ao último dia do mês (31/01 + 1 mês = 28/02).
DateTime adicionarMeses(DateTime d, int meses) {
  final total = d.month - 1 + meses;
  final ano = d.year + (total ~/ 12) - (total < 0 && total % 12 != 0 ? 1 : 0);
  final mes = ((total % 12) + 12) % 12 + 1;
  final dia = d.day.clamp(1, ultimoDiaDoMes(ano, mes));
  return DateTime(ano, mes, dia);
}

DateTime adicionarAnos(DateTime d, int anos) => adicionarMeses(d, anos * 12);

bool ehFimDeSemana(DateTime d) =>
    d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

bool ehDiaUtil(DateTime d, Set<DateTime> feriados) =>
    !ehFimDeSemana(d) && !feriados.contains(soDia(d));

/// O próprio dia se for útil; senão o último dia útil ANTES.
DateTime diaUtilAnteriorOuIgual(DateTime d, Set<DateTime> feriados) {
  var x = soDia(d);
  while (!ehDiaUtil(x, feriados)) {
    x = x.subtract(const Duration(days: 1));
  }
  return x;
}

/// Data em que se avisa um prazo: véspera útil se cair a fim-de-semana/feriado.
DateTime avisoEm(DateTime prazo, Set<DateTime> feriados) =>
    diaUtilAnteriorOuIgual(prazo, feriados);

/// Soma N dias úteis (multas: 15 dias úteis de pagamento voluntário).
DateTime somarDiasUteis(DateTime d, int dias, Set<DateTime> feriados) {
  var x = soDia(d);
  var restam = dias;
  while (restam > 0) {
    x = x.add(const Duration(days: 1));
    if (ehDiaUtil(x, feriados)) restam--;
  }
  return x;
}

/// Dias inteiros entre hoje e o prazo (negativo = já passou).
int diasAte(DateTime prazo, DateTime hoje) =>
    soDia(prazo).difference(soDia(hoje)).inDays;
