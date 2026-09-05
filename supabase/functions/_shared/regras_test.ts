// Testes da biblioteca partilhada — espelho de test/unit/regras_test.dart.
// Os resultados esperados foram calculados À MÃO (docs/casos-teste.md). Se um
// teste falhar, a regra mudou ou o código está errado: nunca se "ajusta" o
// esperado para bater.
//
// Correr: deno test supabase/functions/_shared/regras_test.ts
//     ou: npx -y deno@2 test supabase/functions/_shared/regras_test.ts

import {
  adicionarMeses,
  avisoEm,
  calcularIrs,
  calcularSS,
  calendarioIpo,
  carro,
  dataIso,
  datasPagamentosPorConta,
  dia,
  type EscalaoIrs,
  estimarIuc,
  fimIsencaoSS,
  gerarObrigacoes,
  hojeLisboa,
  inicioEntregaIrs,
  mesesDeIsencaoRestantes,
  moeda,
  paraLisboa,
  perfil,
  prazoDeclaracaoTrimestral,
  prazoEntregaIrs,
  prazoIuc,
  prazoPagamentoSS,
  prazoValidarEfatura,
  primeiraDeclaracaoTrimestral,
  proximaIpo,
  proximoIuc,
  type RegraLegal,
  RegrasLegais,
  somarDiasUteis,
  ultimoDiaIsencaoSS,
} from './regras.ts';

// --- mini-assert (sem dependências de rede) ---
function eq<T>(atual: T, esperado: T, msg = ''): void {
  const a = JSON.stringify(atual);
  const e = JSON.stringify(esperado);
  if (a !== e) throw new Error(`${msg}\n  esperado: ${e}\n  atual:    ${a}`);
}
const iso = (d: Date) => dataIso(d);
const isos = (ds: Date[]) => ds.map(iso);

// --- Fixture: ESPELHO do seed supabase/migrations/20260905_0003_seed.sql (só para testes;
// em produção os valores vêm sempre das tabelas). ---
function regrasDeTeste2026(): RegrasLegais {
  const r = (chave: string, valor: number, confianca = 'oficial'): RegraLegal => ({
    chave, valorNum: valor, valorTxt: null, valorJson: null, unidade: null, ano: 2026, descricao: chave, fonteUrl: null, confianca,
  });
  const t = (chave: string, valor: string, confianca = 'oficial'): RegraLegal => ({
    chave, valorNum: null, valorTxt: valor, valorJson: null, unidade: null, ano: 2026, descricao: chave, fonteUrl: null, confianca,
  });
  // deno-lint-ignore no-explicit-any
  const j = (chave: string, valor: any, confianca = 'oficial'): RegraLegal => ({
    chave, valorNum: null, valorTxt: null, valorJson: valor, unidade: null, ano: 2026, descricao: chave, fonteUrl: null, confianca,
  });
  const iucTabela = {
    cat_b_cilindrada: [{ ate: 1250, valor: 32.36 }, { ate: 1750, valor: 64.92 }, { ate: 2500, valor: 129.77 }, { ate: 99999, valor: 444.51 }],
    cat_b_co2_nedc: [{ ate: 120, valor: 64.58 }, { ate: 180, valor: 96.77 }, { ate: 250, valor: 210.17 }, { ate: 9999, valor: 360.09 }],
    cat_b_co2_wltp: [{ ate: 140, valor: 64.58 }, { ate: 205, valor: 96.77 }, { ate: 260, valor: 210.17 }, { ate: 9999, valor: 360.09 }],
    cat_b_coef_ano: [{ ano: 2007, coef: 1.0 }, { ano: 2008, coef: 1.05 }, { ano: 2009, coef: 1.1 }, { ano: 2010, coef: 1.15 }],
    cat_a_gasolina: [{ ate: 1000, valor: 19.20 }, { ate: 1300, valor: 30.60 }, { ate: 1750, valor: 47.20 }, { ate: 2600, valor: 118.90 }, { ate: 3500, valor: 193.20 }, { ate: 99999, valor: 344.10 }],
    cat_a_gasoleo: [{ ate: 1500, valor: 30.60 }, { ate: 2000, valor: 47.20 }, { ate: 3000, valor: 118.90 }, { ate: 99999, valor: 193.20 }],
    eletrico: 0,
  };
  const regras: RegraLegal[] = [
    r('ias', 537.13),
    r('iva_taxa_normal', 23), r('iva_isencao_limite', 15000), r('iva_isencao_aviso', 12000), r('iva_isencao_perda_imediata', 18750),
    r('iva_isencao_comunicacao_dias_uteis', 15), t('iva_mencao_isencao', 'IVA - regime de isenção [artigo 53.º do CIVA] (M10)'),
    r('iva_declaracao_trimestral_dia', 20), r('iva_pagamento_dia', 25),
    r('retencao_padrao', 23), r('retencao_opcao', 25), r('retencao_dispensa_limite', 15000),
    r('ss_taxa', 21.4), r('ss_base_servicos', 70), r('ss_base_vendas', 20), r('ss_ajuste_max', 25), r('ss_minimo_mensal', 20),
    r('ss_base_maxima_ias', 12), r('ss_isencao_meses', 12), j('ss_declaracao_meses', [1, 4, 7, 10]),
    r('ss_pagamento_dia_inicio', 10), r('ss_pagamento_dia_fim', 20), r('ss_aviso_fim_isencao_dias', 30),
    r('irs_coef_servicos', 0.75), r('irs_coef_vendas', 0.15), r('irs_minimo_existencia', 12880), r('irs_pagamentos_conta_pct', 65),
    j('irs_pagamentos_conta_datas', ['07-20', '09-20', '12-20']), t('irs_entrega_inicio', '04-01'), t('irs_entrega_fim', '06-30'),
    t('efatura_validar_ate', '02-25'), r('irs_despesas_justificar_limite', 27360, 'aproximado'), r('irs_despesas_justificar_pct', 15),
    r('recibos_comunicar_dia', 5),
    t('iuc_regra', 'mes_da_matricula'), j('iuc_tabela', iucTabela, 'aproximado'), j('ipo_ligeiros_anos', [4, 6, 8]),
    t('ipo_apos_8_anos', 'anual'), t('ipo_tvde', 'anual', 'por_confirmar'), j('ipo_avisos_dias', [30, 7]), r('seguro_aviso_dias', 45),
    j('carta_validade', { ate_60: 15, '60_a_70': 5, mais_70: 2 }), r('multa_pagamento_voluntario_dias_uteis', 15),
    r('troca_carta_estrangeira_prazo_anos', 2, 'por_confirmar'), r('tvde_certificado_validade_anos', 5),
  ];
  const e = (ano: number, ordem: number, ate: number | null, taxa: number, parcelaAbater: number, confianca = 'oficial'): EscalaoIrs =>
    ({ ano, ordem, ate, taxa, parcelaAbater, confianca });
  const escaloes: EscalaoIrs[] = [
    e(2025, 1, 8059, 0.125, 0), e(2025, 2, 12160, 0.16, 282.07), e(2025, 3, 17233, 0.215, 950.87), e(2025, 4, 22306, 0.244, 1450.63),
    e(2025, 5, 28400, 0.314, 3012.05), e(2025, 6, 41629, 0.349, 4006.05), e(2025, 7, 44987, 0.431, 7419.63), e(2025, 8, 83696, 0.446, 8094.44),
    e(2025, 9, null, 0.48, 10940.10),
    e(2026, 1, 8342, 0.125, 0, 'por_confirmar'), e(2026, 2, 12588, 0.157, 266.94, 'por_confirmar'), e(2026, 3, 17838, 0.212, 959.28, 'por_confirmar'),
    e(2026, 4, 23088, 0.241, 1476.58, 'por_confirmar'), e(2026, 5, 29397, 0.311, 3092.74, 'por_confirmar'), e(2026, 6, 43090, 0.349, 4209.83, 'por_confirmar'),
    e(2026, 7, 46567, 0.431, 7743.21, 'por_confirmar'), e(2026, 8, 86634, 0.446, 8441.72, 'por_confirmar'), e(2026, 9, null, 0.48, 11387.28, 'por_confirmar'),
  ];
  const feriados = [
    '2026-01-01', '2026-04-03', '2026-04-05', '2026-04-25', '2026-05-01', '2026-06-04', '2026-06-10', '2026-08-15',
    '2026-10-05', '2026-11-01', '2026-12-01', '2026-12-08', '2026-12-25',
    '2027-01-01', '2027-03-26', '2027-03-28', '2027-04-25', '2027-05-01', '2027-05-27', '2027-06-10', '2027-08-15',
    '2027-10-05', '2027-11-01', '2027-12-01', '2027-12-08', '2027-12-25',
  ];
  return new RegrasLegais(regras, escaloes, feriados);
}

const r = regrasDeTeste2026();
const hoje = dia(2026, 9, 6);

// ---------------- Segurança Social ----------------
Deno.test('C10 1.000 €/mês serviços → 149,80 €/mês', () => {
  const c = calcularSS(3000, 'servicos', 0, r);
  eq(c.rendimentoMensalRelevante, 700);
  eq(c.contribuicaoMensal, 149.80);
  eq(c.contribuicaoTrimestre, 449.40);
  eq(c.bateuNoMinimo, false);
  eq(c.bateuNoMaximo, false);
});
Deno.test('C11 ajuste −25% → 112,35 €; +25% → 187,25 €', () => {
  eq(calcularSS(3000, 'servicos', -25, r).contribuicaoMensal, 112.35);
  eq(calcularSS(3000, 'servicos', 25, r).contribuicaoMensal, 187.25);
});
Deno.test('C12 ajuste fora do limite é tapado a ±25%', () => {
  eq(calcularSS(3000, 'servicos', -40, r).ajustePct, -25);
});
Deno.test('C13 100 €/mês → mínimo de 20 €', () => {
  const c = calcularSS(300, 'servicos', 0, r);
  eq(c.contribuicaoMensal, 20);
  eq(c.contribuicaoTrimestre, 60);
  eq(c.bateuNoMinimo, true);
});
Deno.test('C14 vendas 1.000 €/mês → base 20% → 42,80 €', () => {
  const c = calcularSS(3000, 'vendas', 0, r);
  eq(c.baseIncidencia, 200);
  eq(c.contribuicaoMensal, 42.80);
});
Deno.test('C15 20.000 €/mês → teto 12×IAS (6.445,56 €) → 1.379,35 €', () => {
  const c = calcularSS(60000, 'servicos', 0, r);
  eq(c.baseIncidencia, 6445.56);
  eq(c.contribuicaoMensal, 1379.35);
  eq(c.bateuNoMaximo, true);
});
Deno.test('C16 isenção: abriu 15/03/2026 → paga desde 01/03/2027; 1.ª declaração abril 2027', () => {
  const abertura = dia(2026, 3, 15);
  eq(iso(fimIsencaoSS(abertura, r)), '2027-03-01');
  eq(iso(ultimoDiaIsencaoSS(abertura, r)), '2027-02-28');
  eq(iso(primeiraDeclaracaoTrimestral(abertura, r)), '2027-04-01');
  eq(mesesDeIsencaoRestantes(abertura, hoje, r), 6);
});
Deno.test('C17 isenção: abriu 31/12/2026 → paga desde 01/12/2027; 1.ª declaração janeiro 2028', () => {
  const abertura = dia(2026, 12, 31);
  eq(iso(fimIsencaoSS(abertura, r)), '2027-12-01');
  eq(iso(primeiraDeclaracaoTrimestral(abertura, r)), '2028-01-01');
});
Deno.test('C18 isenção: abriu 29/02/2028 (bissexto) → paga desde 01/02/2029', () => {
  const abertura = dia(2028, 2, 29);
  eq(iso(fimIsencaoSS(abertura, r)), '2029-02-01');
  eq(iso(ultimoDiaIsencaoSS(abertura, r)), '2029-01-31');
});
Deno.test('C19 prazos: declaração até ao último dia do mês; pagamento até dia 20', () => {
  eq(iso(prazoDeclaracaoTrimestral(2027, 4)), '2027-04-30');
  eq(iso(prazoDeclaracaoTrimestral(2026, 1)), '2026-01-31');
  eq(iso(prazoPagamentoSS(2027, 3, r)), '2027-03-20');
});

// ---------------- IRS ----------------
Deno.test('C20 12.000 € serviços 2025 → abaixo do mínimo de existência → 0', () => {
  const p = calcularIrs(12000, 'servicos', 2025, r);
  eq(p.rendimentoColetavel, 9000);
  eq(p.abaixoMinimoExistencia, true);
  eq(p.impostoEstimado, 0);
  eq(p.guardarPorMes, 0);
});
Deno.test('C21 24.000 € serviços 2025 → coletável 18.000 → 2.941,37 €; 245,11 €/mês; PPC 637,30 €', () => {
  const p = calcularIrs(24000, 'servicos', 2025, r);
  eq(p.rendimentoColetavel, 18000);
  eq(p.impostoEstimado, 2941.37);
  eq(p.guardarPorMes, 245.11);
  eq(p.pagamentoPorContaCada, 637.30);
  eq(p.taxaEfetivaPct, 12.26);
  eq(p.justificarDespesas, false);
  eq(p.escaloesConfirmados, true);
});
Deno.test('C22 40.000 € serviços 2025 → 6.463,95 €; tem de justificar despesas', () => {
  const p = calcularIrs(40000, 'servicos', 2025, r);
  eq(p.impostoEstimado, 6463.95);
  eq(p.justificarDespesas, true);
});
Deno.test('C23 40.000 € vendas 2025 → coletável 6.000 → 0', () => {
  const p = calcularIrs(40000, 'vendas', 2025, r);
  eq(p.rendimentoColetavel, 6000);
  eq(p.impostoEstimado, 0);
});
Deno.test('C24 100.000 € serviços 2025 → 25.355,56 €', () => {
  eq(calcularIrs(100000, 'servicos', 2025, r).impostoEstimado, 25355.56);
});
Deno.test('C25 2026: escalões POR CONFIRMAR ficam marcados; 24.000 € → 2.861,42 €', () => {
  const p = calcularIrs(24000, 'servicos', 2026, r);
  eq(p.escaloesConfirmados, false);
  eq(p.anoEscaloes, 2026);
  eq(p.impostoEstimado, 2861.42);
});
Deno.test('C26 datas: PPC 20 jul/set/dez; entrega até 30 jun; e-fatura até 25 fev', () => {
  eq(isos(datasPagamentosPorConta(2026, r)), ['2026-07-20', '2026-09-20', '2026-12-20']);
  eq(iso(prazoEntregaIrs(2027, r)), '2027-06-30');
  eq(iso(inicioEntregaIrs(2027, r)), '2027-04-01');
  eq(iso(prazoValidarEfatura(2027, r)), '2027-02-25');
});

// ---------------- Carro ----------------
Deno.test('C27 IUC: matrícula de fevereiro → até 28/02 (29 em bissexto)', () => {
  eq(iso(prazoIuc(2, 2026)), '2026-02-28');
  eq(iso(prazoIuc(2, 2028)), '2028-02-29');
  eq(iso(proximoIuc(2, hoje)), '2027-02-28');
  eq(iso(proximoIuc(10, hoje)), '2026-10-31');
});
Deno.test('C28 IPO ligeiro 2021: 4/6/8 anos e depois anual', () => {
  const m = dia(2021, 2, 15);
  const cal = calendarioIpo(m, dia(2031, 12, 31), false, r);
  eq(isos(cal.slice(0, 5)), ['2025-02-15', '2027-02-15', '2029-02-15', '2030-02-15', '2031-02-15']);
  eq(iso(proximaIpo(m, null, hoje, false, r)!), '2027-02-15');
  eq(iso(proximaIpo(m, dia(2025, 2, 20), hoje, false, r)!), '2027-02-15');
});
Deno.test('C29 IPO carro de 2015 com inspeção feita em junho de 2026 → junho de 2027', () => {
  eq(iso(proximaIpo(dia(2015, 6, 10), dia(2026, 6, 12), hoje, false, r)!), '2027-06-10');
});
Deno.test('C30 IPO TVDE: anual (POR CONFIRMAR)', () => {
  eq(iso(proximaIpo(dia(2024, 2, 15), null, hoje, true, r)!), '2027-02-15');
  eq(r.regra('ipo_tvde')!.confianca, 'por_confirmar');
});
Deno.test('C33 IUC estimado: 1199 cc, 120 g CO2 (WLTP), 2021 → 111,48 €; elétrico → 0', () => {
  const e = estimarIuc(dia(2021, 2, 15), 'gasolina', 1199, 120, r)!;
  eq(e.valor, 111.48);
  eq(e.aproximado, true);
  eq(estimarIuc(dia(2021, 2, 15), 'eletrico', null, null, r)!.valor, 0);
});

// ---------------- Datas e formatos ----------------
Deno.test('C36 véspera útil: domingo, sábado, feriado', () => {
  eq(iso(avisoEm(dia(2026, 9, 20), r.feriados)), '2026-09-18');
  eq(iso(avisoEm(dia(2026, 10, 31), r.feriados)), '2026-10-30');
  eq(iso(avisoEm(dia(2026, 12, 25), r.feriados)), '2026-12-24');
  eq(iso(avisoEm(dia(2026, 6, 10), r.feriados)), '2026-06-09');
  eq(iso(avisoEm(dia(2026, 9, 7), r.feriados)), '2026-09-07');
});
Deno.test('C37 15 dias úteis a partir de 01/12/2026 (feriado + 8/12) → 23/12/2026', () => {
  eq(iso(somarDiasUteis(dia(2026, 12, 1), 15, r.feriados)), '2026-12-23');
});
Deno.test('C38 somar meses prende o dia ao fim do mês', () => {
  eq(iso(adicionarMeses(dia(2027, 1, 31), 1)), '2027-02-28');
  eq(iso(adicionarMeses(dia(2028, 1, 31), 1)), '2028-02-29');
  eq(iso(adicionarMeses(dia(2026, 11, 15), 2)), '2027-01-15');
  eq(iso(adicionarMeses(dia(2026, 3, 1), -1)), '2026-02-01');
});
Deno.test('C39 moeda 1.234,56 €', () => {
  eq(moeda(1234.56), '1.234,56 €');
  eq(moeda(1234567.891), '1.234.567,89 €');
  eq(moeda(0.5), '0,50 €');
  eq(moeda(-20), '-20,00 €');
});
Deno.test('C41 hora de Lisboa: verão +1, inverno +0', () => {
  eq(paraLisboa(new Date(Date.UTC(2026, 6, 1, 8, 0))).getUTCHours(), 9);
  eq(paraLisboa(new Date(Date.UTC(2026, 11, 1, 8, 0))).getUTCHours(), 8);
  eq(iso(hojeLisboa(new Date(Date.UTC(2026, 6, 1, 23, 30)))), '2026-07-02');
});

// ---------------- Gerador de obrigações ----------------
const perfilTvde = perfil({
  tipoAtividade: 'tvde',
  dataAbertura: dia(2026, 3, 15),
  regimeIva: 'isento_53',
  rendimentoMensalEstimado: 1500,
});

Deno.test('C42 TVDE aberto a 15/03/2026, isento: fim da isenção, pagamentos desde março 2027, sem IVA', () => {
  const obs = gerarObrigacoes(perfilTvde, [], hoje, r);
  const fim = obs.filter((o) => o.tipo === 'fim_isencao_ss');
  eq(fim.length, 1);
  eq(iso(fim[0].dataLimite), '2027-03-01');
  eq(fim[0].valorEstimado, 224.70);
  eq(iso(fim[0].avisoEm), '2027-01-29'); // 30 dias antes = 30/01 (sábado) → sexta 29/01
  const pag = obs.filter((o) => o.tipo === 'ss_pagamento');
  eq(iso(pag[0].dataLimite), '2027-03-20');
  eq(iso(pag[0].avisoEm), '2027-03-19'); // 20/03/2027 é sábado
  eq(pag[0].valorEstimado, 224.70);
  eq(pag.length, 6); // mar..ago 2027
  const decl = obs.filter((o) => o.tipo === 'ss_declaracao');
  eq(isos(decl.map((o) => o.dataLimite)), ['2027-04-30', '2027-07-31']);
  eq(obs.filter((o) => o.tipo.startsWith('iva_')).length, 0);
  eq(iso(obs.filter((o) => o.tipo === 'irs_entrega')[0].dataLimite), '2027-06-30');
  eq(iso(obs.filter((o) => o.tipo === 'efatura_validar')[0].dataLimite), '2027-02-25');
  eq(new Set(obs.map((o) => o.chaveUnica)).size, obs.length, 'chaves únicas');
  for (let i = 1; i < obs.length; i++) {
    if (obs[i - 1].dataLimite.getTime() > obs[i].dataLimite.getTime()) throw new Error('não está ordenado');
  }
  eq(fim[0].chaveUnica, 'fim_isencao_ss|2027-03-01');
  eq(pag[0].chaveUnica, 'ss_pagamento|2027-03-20');
});

Deno.test('C43 regime normal de IVA: declaração dia 20 e pagamento dia 25 do 2.º mês após o trimestre', () => {
  const p = perfil({
    tipoAtividade: 'freelancer',
    dataAbertura: dia(2024, 1, 10),
    regimeIva: 'normal',
    rendimentoMensalEstimado: 3000,
  });
  const obs = gerarObrigacoes(p, [], hoje, r);
  eq(isos(obs.filter((o) => o.tipo === 'iva_declaracao').map((o) => o.dataLimite)), ['2026-11-20', '2027-02-20', '2027-05-20', '2027-08-20']);
  eq(isos(obs.filter((o) => o.tipo === 'iva_pagamento').map((o) => o.dataLimite)), ['2026-11-25', '2027-02-25', '2027-05-25', '2027-08-25']);
  eq(obs.filter((o) => o.tipo === 'ss_pagamento').length, 12);
  eq(obs.filter((o) => o.tipo === 'ss_declaracao').length, 4);
  eq(obs.filter((o) => o.tipo === 'fim_isencao_ss').length, 0);
});

Deno.test('C44 carro de fevereiro de 2021 com seguro em maio: IUC 28/02, IPO 28/02/2027, seguro roda para 2027', () => {
  const c = carro({
    id: 'c1',
    matricula: 'AA-11-BB',
    dataMatricula: dia(2021, 2, 28),
    seguroRenovaEm: dia(2026, 5, 15),
    combustivel: 'gasolina',
    cilindradaCc: 1199,
    co2: 120,
  });
  const obs = gerarObrigacoes(perfil({ tipoAtividade: 'so_carro' }), [c], hoje, r);
  eq(obs.filter((o) => o.tipo.startsWith('ss_')).length, 0);
  const iuc = obs.filter((o) => o.tipo === 'iuc');
  eq(iuc.length, 1);
  eq(iso(iuc[0].dataLimite), '2027-02-28');
  eq(iuc[0].valorEstimado, 111.48);
  eq(iso(iuc[0].avisoEm), '2027-02-26'); // 28/02/2027 é domingo
  eq(iso(obs.filter((o) => o.tipo === 'ipo')[0].dataLimite), '2027-02-28');
  eq(iso(obs.filter((o) => o.tipo === 'seguro')[0].dataLimite), '2027-05-15');
  eq(iuc[0].carroId, 'c1');
  eq(iuc[0].chaveUnica, 'iuc|2027-02-28|c1');
});

Deno.test('C45 sem atividade e sem carro → nada', () => {
  eq(gerarObrigacoes(perfil({ tipoAtividade: 'sem_atividade' }), [], hoje, r).length, 0);
});

Deno.test('C46 número em falta é erro, nunca um valor inventado', () => {
  let lancou = false;
  try {
    r.n('regra_que_nao_existe');
  } catch {
    lancou = true;
  }
  eq(lancou, true);
});

Deno.test('C47 escalões: 2027 não existe → usa o ano mais recente (2026)', () => {
  eq(r.escaloesDoAno(2027)[0].ano, 2026);
  eq(r.escaloesDoAno(2025).length, 9);
});
