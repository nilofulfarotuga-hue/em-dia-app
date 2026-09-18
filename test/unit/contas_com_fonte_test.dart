// BLOCO 5 (2026-09-18) — «Correção das contas, com testes»: as nove contas que
// o Danilo mandou fixar, cada uma com a FONTE OFICIAL escrita no teste. Se uma
// falhar, ou a regra mudou na tabela (e a fonte diz porquê) ou o código está
// errado — nunca se ajusta o esperado para bater certo.
//
// Estes testes correm no CI antes de qualquer build para a Play
// (.github/workflows/build_android.yml → «Testes unitários das regras»):
// nenhuma build vai à Play com um destes vermelho.
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/regras/regras.dart';

void main() {
  final r = RegrasLegais.padrao2026();

  test('F1 Segurança Social = 70 % × 21,4 % → 179,76 € para 1.200 €/mês '
      '(Código Contributivo, Lei 110/2009, art. 162.º base 70 % e art. 168.º taxa 21,4 %; '
      'https://diariodarepublica.pt/dr/legislacao-consolidada/lei/2009-34514575)', () {
    final ss = estimarSSMensal(rendimentoMensal: 1200, tipo: TipoRendimento.servicos, r: r);
    expect(ss.baseIncidencia, 840.00); // 70 % de 1.200
    expect(ss.contribuicaoMensal, 179.76); // 21,4 % de 840
    expect(r.n('ss_taxa'), 21.4);
    expect(r.n('ss_base_servicos'), 70);
  });

  test('F2 IVA isento abaixo do limiar de 15.000 € (CIVA art. 53.º, DL 35/2025; '
      'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva53.aspx)', () {
    expect(r.n('iva_isencao_limite'), 15000);
    expect(vigiaIva(acumuladoAno: 9000, r: r).nivel, NivelIva.ok);
    expect(vigiaIva(acumuladoAno: 12500, r: r).nivel, NivelIva.aviso); // a partir dos 12.000 avisa-se
    expect(vigiaIva(acumuladoAno: 15500, r: r).nivel, NivelIva.alarme); // passou o limiar
    expect(vigiaIva(acumuladoAno: 19000, r: r).nivel, NivelIva.critico); // +25 %: perde a isenção já
    final recibo = calcularRecibo(valor: 500, retencao: Retencao.dispensa, isentoIva: true, r: r);
    expect(recibo.iva, 0);
    expect(recibo.mencaoIsencao, contains('53'));
  });

  test('F3 retenção na fonte de 23 % (CIRS art. 101.º n.º 1; taxa desde 2024; '
      'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs101.aspx)', () {
    expect(r.n('retencao_padrao'), 23);
    final recibo = calcularRecibo(valor: 1000, retencao: Retencao.padrao, isentoIva: true, r: r);
    expect(recibo.retencao, 230.00);
    expect(recibo.recebesNaConta, 770.00);
    expect(calcularRecibo(valor: 1000, retencao: Retencao.vinteCinco, isentoIva: true, r: r).retencao, 250.00);
  });

  test('F4 isenção de Segurança Social no 1.º ano: 12 meses a contar do início '
      '(Código Contributivo art. 145.º; Guia Prático do ISS «Trabalhadores Independentes»)', () {
    expect(r.n('ss_isencao_meses'), 12);
    expect(fimIsencaoSS(DateTime(2026, 3, 15), r), DateTime(2027, 3, 1)); // começa a pagar em março de 2027
    expect(ultimoDiaIsencaoSS(DateTime(2026, 3, 15), r), DateTime(2027, 2, 28));
  });

  test('F5 prazo do Estado a fim-de-semana/feriado passa ao dia útil seguinte '
      '(AT, Resumo anual 2026, nota a) «…pode ser cumprida até ao dia útil seguinte»; '
      'SS, Guia Prático «Pagamento de Contribuições»)', () {
    final f = r.feriados;
    expect(prazoEfetivo(DateTime(2026, 9, 20), f), DateTime(2026, 9, 21)); // domingo → segunda
    expect(prazoEfetivo(DateTime(2026, 12, 25), f), DateTime(2026, 12, 28)); // Natal (sexta) → segunda
    expect(prazoEfetivo(DateTime(2026, 10, 5), f), DateTime(2026, 10, 6)); // 5 de outubro (feriado) → terça
    expect(avisoEm(DateTime(2026, 9, 20), f), DateTime(2026, 9, 18)); // o aviso continua na véspera útil
  });

  test('F6 IUC paga-se até ao fim do mês da matrícula, todos os anos '
      '(Código do IUC art. 17.º; Portal das Finanças → IUC → Pagar)', () {
    expect(r.txt('iuc_regra'), 'mes_da_matricula');
    expect(prazoIuc(mesMatricula: 5, ano: 2027), DateTime(2027, 5, 31));
    expect(prazoIuc(mesMatricula: 2, ano: 2028), DateTime(2028, 2, 29)); // bissexto
    expect(proximoIuc(mesMatricula: 5, hoje: DateTime(2026, 9, 18)), DateTime(2027, 5, 31));
  });

  test('F7 inspeção pela idade: ligeiros aos 4, 6 e 8 anos, depois anual; TVDE anual '
      '(IMT, tipos de inspeção; Lei 45/2018 art. 12.º n.º 5; '
      'https://www.imt-ip.pt/sites/IMTT/Portugues/Veiculos/InspecoesTecnicas)', () {
    final ligeiro = calendarioIpo(matricula: DateTime(2020, 3, 15), ate: DateTime(2031, 12, 31), r: r);
    expect(ligeiro.take(5).toList(), [
      DateTime(2024, 3, 15), DateTime(2026, 3, 15), DateTime(2028, 3, 15), DateTime(2029, 3, 15), DateTime(2030, 3, 15),
    ]);
    final tvde = calendarioIpo(matricula: DateTime(2024, 3, 15), ate: DateTime(2027, 12, 31), tvde: true, r: r);
    expect(tvde, [DateTime(2025, 3, 15), DateTime(2026, 3, 15), DateTime(2027, 3, 15)]);
    expect(r.txt('ipo_tvde'), 'anual');
    expect(r.n('tvde_idade_max_anos'), 7);
  });

  test('F8 IRS Jovem: ≤ 35 anos, 10 anos, 100/75/50/25 %, limite 55 × IAS '
      '(CIRS art. 12.º-B, Lei 45-A/2024; https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs12b.aspx)', () {
    expect(irsJovem(idadeEm31Dez: 26, anoDeRendimentos: 1, r: r).pctIsencao, 100);
    expect(irsJovem(idadeEm31Dez: 30, anoDeRendimentos: 3, r: r).pctIsencao, 75);
    expect(irsJovem(idadeEm31Dez: 33, anoDeRendimentos: 6, r: r).pctIsencao, 50);
    expect(irsJovem(idadeEm31Dez: 35, anoDeRendimentos: 9, r: r).pctIsencao, 25);
    expect(irsJovem(idadeEm31Dez: 36, anoDeRendimentos: 2, r: r).elegivel, isFalse);
    expect(irsJovem(idadeEm31Dez: 26, anoDeRendimentos: 1, r: r).limiteEur, 29542.15); // 55 × 537,13
  });

  test('F9 contrato: a retenção vem do recibo (não de tabelas copiadas), a SS é 11 % e o IRS do ano acerta-se pelos escalões '
      '(ISS «Taxas Contributivas» 11 %/23,75 %; CIRS art. 25.º dedução 8,54 × IAS e art. 68.º escalões 2026; '
      'tabelas de retenção 2026 da AT ficam como fonte, ver docs/REGRAS-PT-2026.md §3)', () {
    final rv = lerReciboVencimento(bruto: 1200, irsRetido: 96.50, r: r);
    expect(rv.ssTrabalhador, 132.00);
    expect(rv.liquido, 971.50);
    final e = estimarIrsContrato(brutoMensal: 1200, irsRetidoMensal: 96.50, ano: 2026, r: r);
    expect(e.deducaoEspecifica, 4587.09);
    expect(e.imposto, 1650.49);
    expect(e.diferenca, -299.49); // retiveram de menos: acerto a pagar
    expect(e.escaloesConfirmados, isTrue);
  });
}
