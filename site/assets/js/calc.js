/* Em Dia — calculadora de recibo verde e "quanto guardar".
 * Porta EXATA de lib/regras/recibo.dart, seguranca_social.dart, irs.dart e formatos.dart.
 * Funções puras: não tocam no DOM. Servem no browser (window.EmDiaCalc) e em Node (module.exports)
 * para o site/testes/verifica.mjs correr os casos C01–C04 de docs/casos-teste.md.
 *
 * Os números legais vêm da tabela pública `regras_legais` (lidos em runtime em index.html);
 * REGRAS_SEED é o espelho do seed 20260905_0003 e só se usa se a rede falhar.
 */
(function (raiz) {
  'use strict';

  var REGRAS_SEED = {
    ias: 537.13,
    iva_taxa_normal: 23,
    iva_isencao_limite: 15000,
    iva_isencao_aviso: 12000,
    iva_isencao_perda_imediata: 18750,
    iva_mencao_isencao: 'IVA - regime de isenção [artigo 53.º do CIVA] (M10)',
    retencao_padrao: 23,
    retencao_opcao: 25,
    retencao_dispensa_limite: 15000,
    ss_taxa: 21.4,
    ss_base_servicos: 70,
    ss_base_vendas: 20,
    ss_ajuste_max: 25,
    ss_minimo_mensal: 20,
    ss_base_maxima_ias: 12,
    ss_isencao_meses: 12,
    irs_coef_servicos: 0.75,
    irs_coef_vendas: 0.15,
    irs_minimo_existencia: 12880,
    irs_pagamentos_conta_pct: 65,
    irs_despesas_justificar_limite: 27360,
    trial_dias: 30,
    preco_pro_mensal: 3.49,
    preco_pro_anual: 29.90,
    preco_familia_mensal: 5.99,
    preco_familia_anual: 49.90
  };

  // irs_escaloes 2026 (OE 2026, POR CONFIRMAR no seed) — ate null = sem limite.
  var ESCALOES_SEED = [
    { ano: 2026, ordem: 1, ate: 8342.00, taxa: 0.1250, parcela_abater: 0.00, confianca: 'por_confirmar' },
    { ano: 2026, ordem: 2, ate: 12588.00, taxa: 0.1570, parcela_abater: 266.94, confianca: 'por_confirmar' },
    { ano: 2026, ordem: 3, ate: 17838.00, taxa: 0.2120, parcela_abater: 959.28, confianca: 'por_confirmar' },
    { ano: 2026, ordem: 4, ate: 23088.00, taxa: 0.2410, parcela_abater: 1476.58, confianca: 'por_confirmar' },
    { ano: 2026, ordem: 5, ate: 29397.00, taxa: 0.3110, parcela_abater: 3092.74, confianca: 'por_confirmar' },
    { ano: 2026, ordem: 6, ate: 43090.00, taxa: 0.3490, parcela_abater: 4209.83, confianca: 'por_confirmar' },
    { ano: 2026, ordem: 7, ate: 46567.00, taxa: 0.4310, parcela_abater: 7743.21, confianca: 'por_confirmar' },
    { ano: 2026, ordem: 8, ate: 86634.00, taxa: 0.4460, parcela_abater: 8441.72, confianca: 'por_confirmar' },
    { ano: 2026, ordem: 9, ate: null, taxa: 0.4800, parcela_abater: 11387.28, confianca: 'por_confirmar' }
  ];

  // ---------- formatos.dart ----------
  /** Arredonda a cêntimos (Dart: (v*100).round()/100). */
  function centimos(v) { return Math.round(v * 100) / 100; }

  /** `1.234,56 €` */
  function moeda(valor, comSimbolo) {
    if (comSimbolo === undefined) comSimbolo = true;
    var negativo = valor < 0;
    var abs = Math.abs(valor);
    var fixo = abs.toFixed(2);
    var partes = fixo.split('.');
    var inteiro = partes[0].replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    var s = inteiro + ',' + partes[1];
    if (comSimbolo) s += ' €';
    return (negativo ? '-' : '') + s;
  }

  /** Lê "1.234,56", "1234.56" ou "1234,56" escrito pelo utilizador. */
  function lerNumero(texto) {
    var t = String(texto == null ? '' : texto).trim().replace(/€/g, '').replace(/\s/g, '');
    if (!t) return null;
    if (t.indexOf(',') >= 0 && t.indexOf('.') >= 0) {
      t = t.replace(/\./g, '').replace(/,/g, '.');
    } else if (t.indexOf(',') >= 0) {
      t = t.replace(/,/g, '.');
    }
    var n = Number(t);
    return isFinite(n) ? n : null;
  }

  function pct(valor, casas) {
    if (casas === undefined) casas = 1;
    return Number(valor).toFixed(casas).replace('.', ',') + '%';
  }

  // ---------- regras_legais.dart (leitura) ----------
  function n(regras, chave) {
    var v = regras[chave];
    if (v === undefined || v === null) v = REGRAS_SEED[chave];
    return Number(v);
  }
  function txt(regras, chave) {
    var v = regras[chave];
    if (v === undefined || v === null) v = REGRAS_SEED[chave];
    return v == null ? null : String(v);
  }
  /** Escalões do ano; sem tabela para o ano pedido usa o ano mais recente que exista. */
  function escaloesDoAno(escaloes, ano) {
    var doAno = escaloes.filter(function (e) { return e.ano === ano; })
      .sort(function (a, b) { return a.ordem - b.ordem; });
    if (doAno.length) return doAno;
    var anos = [];
    escaloes.forEach(function (e) { if (anos.indexOf(e.ano) < 0) anos.push(e.ano); });
    anos.sort(function (a, b) { return a - b; });
    if (!anos.length) return [];
    return escaloesDoAno(escaloes, anos[anos.length - 1]);
  }

  // ---------- recibo.dart ----------
  /**
   * @param {number} valor  o que está escrito no recibo (sem IVA)
   * @param {'padrao'|'vinteCinco'|'dispensa'} retencao
   * @param {boolean} isentoIva  art. 53.º
   * @param {object} regras  mapa chave → valor (regras_legais); em falta usa REGRAS_SEED
   */
  function calcularRecibo(valor, retencao, isentoIva, regras) {
    regras = regras || {};
    var taxaRet = retencao === 'padrao' ? n(regras, 'retencao_padrao')
      : retencao === 'vinteCinco' ? n(regras, 'retencao_opcao') : 0;
    var taxaIva = isentoIva ? 0 : n(regras, 'iva_taxa_normal');
    var iva = centimos(valor * taxaIva / 100);
    var ret = centimos(valor * taxaRet / 100);
    return {
      valorSemIva: centimos(valor),
      iva: iva,
      totalFatura: centimos(valor + iva),
      retencao: ret,
      recebesNaConta: centimos(valor + iva - ret),
      ficaTeu: centimos(valor - ret),
      taxaRetencaoPct: taxaRet,
      taxaIvaPct: taxaIva,
      isentoIva: !!isentoIva,
      mencaoIsencao: isentoIva ? txt(regras, 'iva_mencao_isencao') : null
    };
  }

  function podeDispensarRetencao(faturacaoAnoAnterior, regras) {
    return faturacaoAnoAnterior < n(regras || {}, 'retencao_dispensa_limite');
  }

  // ---------- seguranca_social.dart ----------
  /** 21,4% sobre 70% (serviços) ou 20% (bens) do rendimento médio mensal do trimestre; ±25%; mín. 20 €; teto 12×IAS. */
  function calcularSS(rendimentoTrimestre, tipo, ajustePct, regras) {
    regras = regras || {};
    ajustePct = ajustePct || 0;
    var ajusteMax = Math.trunc(n(regras, 'ss_ajuste_max'));
    var ajuste = Math.max(-ajusteMax, Math.min(ajusteMax, ajustePct));
    var pctBase = tipo === 'servicos' ? n(regras, 'ss_base_servicos') : n(regras, 'ss_base_vendas');
    var mensal = rendimentoTrimestre / 3 * pctBase / 100;
    var base = mensal * (1 + ajuste / 100);
    var teto = n(regras, 'ss_base_maxima_ias') * n(regras, 'ias');
    var bateuMax = base > teto;
    if (bateuMax) base = teto;
    var contribuicao = base * n(regras, 'ss_taxa') / 100;
    var minimo = n(regras, 'ss_minimo_mensal');
    var bateuMin = contribuicao < minimo;
    if (bateuMin) contribuicao = minimo;
    return {
      rendimentoTrimestre: rendimentoTrimestre,
      rendimentoMensalRelevante: centimos(mensal),
      baseIncidencia: centimos(base),
      contribuicaoMensal: centimos(contribuicao),
      contribuicaoTrimestre: centimos(contribuicao * 3),
      bateuNoMinimo: bateuMin,
      bateuNoMaximo: bateuMax,
      ajustePct: ajuste
    };
  }

  function estimarSSMensal(rendimentoMensal, tipo, ajustePct, regras) {
    return calcularSS(rendimentoMensal * 3, tipo, ajustePct, regras);
  }

  // ---------- irs.dart ----------
  function impostoPorEscaloes(coletavel, escaloes) {
    if (coletavel <= 0 || !escaloes.length) return 0;
    for (var i = 0; i < escaloes.length; i++) {
      var e = escaloes[i];
      if (e.ate == null || coletavel <= e.ate) {
        return centimos(coletavel * e.taxa - e.parcela_abater);
      }
    }
    var ultimo = escaloes[escaloes.length - 1];
    return centimos(coletavel * ultimo.taxa - ultimo.parcela_abater);
  }

  /** Regime simplificado: coletável = bruto × coef; abaixo do mínimo de existência não há imposto. Estimativa. */
  function calcularIrs(rendimentoBrutoAnual, tipo, ano, regras, escaloes) {
    regras = regras || {};
    escaloes = escaloes || ESCALOES_SEED;
    var coef = tipo === 'servicos' ? n(regras, 'irs_coef_servicos') : n(regras, 'irs_coef_vendas');
    var coletavel = centimos(rendimentoBrutoAnual * coef);
    var minimo = n(regras, 'irs_minimo_existencia');
    var esc = escaloesDoAno(escaloes, ano);
    var abaixo = coletavel <= minimo;
    var imposto = abaixo ? 0 : impostoPorEscaloes(coletavel, esc);
    var ppcPct = n(regras, 'irs_pagamentos_conta_pct');
    return {
      rendimentoBrutoAnual: rendimentoBrutoAnual,
      coeficiente: coef,
      rendimentoColetavel: coletavel,
      impostoEstimado: imposto,
      guardarPorMes: centimos(imposto / 12),
      taxaEfetivaPct: rendimentoBrutoAnual > 0 ? centimos(imposto / rendimentoBrutoAnual * 100) : 0,
      abaixoMinimoExistencia: abaixo,
      justificarDespesas: rendimentoBrutoAnual > n(regras, 'irs_despesas_justificar_limite'),
      pagamentoPorContaCada: centimos(imposto * ppcPct / 100 / 3),
      anoEscaloes: esc.length ? esc[0].ano : ano,
      escaloesConfirmados: esc.every(function (e) { return e.confianca !== 'por_confirmar'; })
    };
  }

  /** "Quanto guardar por mês": SS + IRS a partir de um rendimento mensal. */
  function quantoGuardar(rendimentoMensal, tipo, ano, regras, escaloes) {
    var ss = estimarSSMensal(rendimentoMensal, tipo, 0, regras);
    var irs = calcularIrs(rendimentoMensal * 12, tipo, ano, regras, escaloes);
    var total = centimos(ss.contribuicaoMensal + irs.guardarPorMes);
    return {
      ss: ss,
      irs: irs,
      guardarPorMes: total,
      ficaTeuPorMes: centimos(rendimentoMensal - total)
    };
  }

  var api = {
    REGRAS_SEED: REGRAS_SEED,
    ESCALOES_SEED: ESCALOES_SEED,
    centimos: centimos,
    moeda: moeda,
    lerNumero: lerNumero,
    pct: pct,
    escaloesDoAno: escaloesDoAno,
    calcularRecibo: calcularRecibo,
    podeDispensarRetencao: podeDispensarRetencao,
    calcularSS: calcularSS,
    estimarSSMensal: estimarSSMensal,
    impostoPorEscaloes: impostoPorEscaloes,
    calcularIrs: calcularIrs,
    quantoGuardar: quantoGuardar
  };

  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  raiz.EmDiaCalc = api;
})(typeof window !== 'undefined' ? window : globalThis);
