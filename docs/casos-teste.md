# Casos de teste das regras — Em Dia

> Gerado de `test/unit/regras_test.dart` por `tool/casos_teste_md.py`. **47 casos.** O esperado foi calculado à mão a partir das regras de `regras_legais` (seed 0003). Se um caso falhar, mudou a regra ou o código — nunca se ajusta o esperado para bater.

Correr: `flutter test test/unit -r compact` (última corrida verde: ver docs/MARCOS.md).

## Calculadora de recibo

| # | Caso (entrada → esperado) | Asserções |
|---|---|---|
| C01 | 1000 €, retenção 23%, isento de IVA | `c.iva, 0`<br>`c.retencao, 230`<br>`c.recebesNaConta, 770`<br>`c.ficaTeu, 770`<br>`c.mencaoIsencao, contains('artigo 53')` |
| C02 | 1000 €, retenção 25%, IVA 23% | `c.iva, 230`<br>`c.totalFatura, 1230`<br>`c.retencao, 250`<br>`c.recebesNaConta, 980`<br>`c.ficaTeu, 750`<br>`c.mencaoIsencao, isNull` |
| C03 | 500 €, dispensa de retenção, isento | `c.retencao, 0`<br>`c.recebesNaConta, 500` |
| C04 | 1234,56 € com cêntimos (IVA e retenção arredondados) | `c.iva, 283.95`<br>`c.retencao, 283.95`<br>`c.recebesNaConta, 1234.56`<br>`c.ficaTeu, 950.61` |
| C05 | dispensa só abaixo de 15.000 € no ano anterior | `podeDispensarRetencao(faturacaoAnoAnterior: 14999.99, r: r), isTrue`<br>`podeDispensarRetencao(faturacaoAnoAnterior: 15000, r: r), isFalse` |

## Vigia do IVA

| # | Caso (entrada → esperado) | Asserções |
|---|---|---|
| C06 | 8.000 € → ok, falta 7.000 | `v.nivel, NivelIva.ok`<br>`v.faltaParaLimite, 7000`<br>`v.fracao, closeTo(0.5333, 0.001)` |
| C07 | 12.000 € → aviso | `vigiaIva(acumuladoAno: 12000, r: r).nivel, NivelIva.aviso` |
| C08 | 15.000 € é aviso; 15.000,01 € é alarme | `vigiaIva(acumuladoAno: 15000, r: r).nivel, NivelIva.aviso`<br>`vigiaIva(acumuladoAno: 15000.01, r: r).nivel, NivelIva.alarme`<br>`cobraIvaNoProximoAno(faturacaoEsteAno: 15000.01, r: r), isTrue` |
| C09 | 18.750 € é alarme; 18.750,01 € é crítico (perde já) | `vigiaIva(acumuladoAno: 18750, r: r).nivel, NivelIva.alarme`<br>`vigiaIva(acumuladoAno: 18750.01, r: r).nivel, NivelIva.critico` |

## Segurança Social

| # | Caso (entrada → esperado) | Asserções |
|---|---|---|
| C10 | 1.000 €/mês serviços → 149,80 €/mês | `c.rendimentoMensalRelevante, 700`<br>`c.contribuicaoMensal, 149.80`<br>`c.contribuicaoTrimestre, 449.40`<br>`c.bateuNoMinimo, isFalse`<br>`c.bateuNoMaximo, isFalse` |
| C11 | ajuste −25% → 112,35 €; +25% → 187,25 € | `calcularSS(rendimentoTrimestre: 3000, tipo: TipoRendimento.servicos, ajustePct: -25, r: r).contribuicaoMensal, 112.35`<br>`calcularSS(rendimentoTrimestre: 3000, tipo: TipoRendimento.servicos, ajustePct: 25, r: r).contribuicaoMensal, 187.25` |
| C12 | ajuste fora do limite é tapado a ±25% | `calcularSS(rendimentoTrimestre: 3000, tipo: TipoRendimento.servicos, ajustePct: -40, r: r).ajustePct, -25` |
| C13 | 100 €/mês → mínimo de 20 € | `c.contribuicaoMensal, 20`<br>`c.contribuicaoTrimestre, 60`<br>`c.bateuNoMinimo, isTrue` |
| C14 | vendas 1.000 €/mês → base 20% → 42,80 € | `c.baseIncidencia, 200`<br>`c.contribuicaoMensal, 42.80` |
| C15 | 20.000 €/mês → teto 12×IAS (6.445,56 €) → 1.379,35 € | `c.baseIncidencia, 6445.56`<br>`c.contribuicaoMensal, 1379.35`<br>`c.bateuNoMaximo, isTrue` |
| C16 | isenção: abriu 15/03/2026 → paga desde 01/03/2027; 1.ª declaração abril 2027 | `fimIsencaoSS(abertura, r), DateTime(2027, 3, 1)`<br>`ultimoDiaIsencaoSS(abertura, r), DateTime(2027, 2, 28)`<br>`primeiraDeclaracaoTrimestral(abertura, r), DateTime(2027, 4, 1)`<br>`mesesDeIsencaoRestantes(abertura, hoje, r), 6` |
| C17 | isenção: abriu 31/12/2026 → paga desde 01/12/2027; 1.ª declaração janeiro 2028 | `fimIsencaoSS(abertura, r), DateTime(2027, 12, 1)`<br>`primeiraDeclaracaoTrimestral(abertura, r), DateTime(2028, 1, 1)` |
| C18 | isenção: abriu 29/02/2028 (bissexto) → paga desde 01/02/2029 | `fimIsencaoSS(abertura, r), DateTime(2029, 2, 1)`<br>`ultimoDiaIsencaoSS(abertura, r), DateTime(2029, 1, 31)` |
| C19 | prazos: declaração até ao último dia do mês; pagamento até dia 20 | `prazoDeclaracaoTrimestral(2027, 4), DateTime(2027, 4, 30)`<br>`prazoDeclaracaoTrimestral(2026, 1), DateTime(2026, 1, 31)`<br>`prazoPagamentoSS(2027, 3, r), DateTime(2027, 3, 20)` |

## IRS (regime simplificado)

| # | Caso (entrada → esperado) | Asserções |
|---|---|---|
| C20 | 12.000 € serviços 2025 → abaixo do mínimo de existência → 0 | `p.rendimentoColetavel, 9000`<br>`p.abaixoMinimoExistencia, isTrue`<br>`p.impostoEstimado, 0`<br>`p.guardarPorMes, 0` |
| C21 | 24.000 € serviços 2025 → coletável 18.000 → 2.941,37 €; 245,11 €/mês; PPC 637,30 € | `p.rendimentoColetavel, 18000`<br>`p.impostoEstimado, 2941.37`<br>`p.guardarPorMes, 245.11`<br>`p.pagamentoPorContaCada, 637.30`<br>`p.taxaEfetivaPct, 12.26`<br>`p.justificarDespesas, isFalse`<br>`p.escaloesConfirmados, isTrue` |
| C22 | 40.000 € serviços 2025 → 6.463,95 €; tem de justificar despesas | `p.impostoEstimado, 6463.95`<br>`p.justificarDespesas, isTrue` |
| C23 | 40.000 € vendas 2025 → coletável 6.000 → 0 | `p.rendimentoColetavel, 6000`<br>`p.impostoEstimado, 0` |
| C24 | 100.000 € serviços 2025 → 25.355,56 € | `p.impostoEstimado, 25355.56` |
| C25 | 2026: escalões POR CONFIRMAR ficam marcados; 24.000 € → 2.861,42 € | `p.escaloesConfirmados, isFalse`<br>`p.anoEscaloes, 2026`<br>`p.impostoEstimado, 2861.42` |
| C26 | datas: PPC 20 jul/set/dez; entrega até 30 jun; e-fatura até 25 fev | `datasPagamentosPorConta(2026, r), [DateTime(2026, 7, 20), DateTime(2026, 9, 20), DateTime(2026, 12, 20)]`<br>`prazoEntregaIrs(2027, r), DateTime(2027, 6, 30)`<br>`inicioEntregaIrs(2027, r), DateTime(2027, 4, 1)`<br>`prazoValidarEfatura(2027, r), DateTime(2027, 2, 25)` |

## Carro

| # | Caso (entrada → esperado) | Asserções |
|---|---|---|
| C27 | IUC: matrícula de fevereiro → até 28/02 (29 em bissexto) | `prazoIuc(mesMatricula: 2, ano: 2026), DateTime(2026, 2, 28)`<br>`prazoIuc(mesMatricula: 2, ano: 2028), DateTime(2028, 2, 29)`<br>`proximoIuc(mesMatricula: 2, hoje: hoje), DateTime(2027, 2, 28)`<br>`proximoIuc(mesMatricula: 10, hoje: hoje), DateTime(2026, 10, 31)` |
| C28 | IPO ligeiro 2021: 4/6/8 anos e depois anual | `proximaIpo(matricula: m, hoje: hoje, r: r), DateTime(2027, 2, 15)`<br>`proximaIpo(matricula: m, ultimaIpo: DateTime(2025, 2, 20), hoje: hoje, r: r), DateTime(2027, 2, 15)` |
| C29 | IPO carro de 2015 com inspeção feita em junho de 2026 → junho de 2027 | `proximaIpo(matricula: m, ultimaIpo: DateTime(2026, 6, 12), hoje: hoje, r: r), DateTime(2027, 6, 10)` |
| C30 | IPO TVDE: anual (POR CONFIRMAR) | `proximaIpo(matricula: m, hoje: hoje, tvde: true, r: r), DateTime(2027, 2, 15)`<br>`r.regra('ipo_tvde')!.confirmada, isFalse` |
| C31 | carta: 15 anos até aos 60, 5 até aos 70, depois 2 | `anosValidadeCarta(35, r), 15`<br>`anosValidadeCarta(65, r), 5`<br>`anosValidadeCarta(72, r), 2` |
| C32 | multa notificada a 10/09/2026 → 15 dias úteis → 01/10/2026 | `prazoMulta(DateTime(2026, 9, 10), r), DateTime(2026, 10, 1)` |
| C33 | IUC estimado: 1199 cc, 120 g CO2 (WLTP), 2021 → 111,48 €; elétrico → 0 | `e.valor, 111.48`<br>`e.aproximado, isTrue`<br>`estimarIuc(matricula: DateTime(2021, 2, 15), combustivel: Combustivel.eletrico, r: r)!.valor, 0` |
| C34 | custo por km: 500 km com 45 € → 0,09 €/km, 5,4 L/100 | `c.kmPercorridos, 500`<br>`c.custoPorKm, 0.09`<br>`c.litrosPor100Km, 5.4` |
| C35 | seguro: aviso 45 dias antes | `avisoSeguro(DateTime(2027, 5, 15), r), DateTime(2027, 3, 31)` |

## Datas e formatos

| # | Caso (entrada → esperado) | Asserções |
|---|---|---|
| C36 | véspera útil: domingo, sábado, feriado | `avisoEm(DateTime(2026, 9, 20), r.feriados), DateTime(2026, 9, 18)`<br>`avisoEm(DateTime(2026, 10, 31), r.feriados), DateTime(2026, 10, 30)`<br>`avisoEm(DateTime(2026, 12, 25), r.feriados), DateTime(2026, 12, 24)`<br>`avisoEm(DateTime(2026, 6, 10), r.feriados), DateTime(2026, 6, 9)`<br>`avisoEm(DateTime(2026, 9, 7), r.feriados), DateTime(2026, 9, 7)` |
| C37 | 15 dias úteis a partir de 01/12/2026 (feriado + 8/12) → 23/12/2026 | `somarDiasUteis(DateTime(2026, 12, 1), 15, r.feriados), DateTime(2026, 12, 23)` |
| C38 | somar meses prende o dia ao fim do mês | `adicionarMeses(DateTime(2027, 1, 31), 1), DateTime(2027, 2, 28)`<br>`adicionarMeses(DateTime(2028, 1, 31), 1), DateTime(2028, 2, 29)`<br>`adicionarMeses(DateTime(2026, 11, 15), 2), DateTime(2027, 1, 15)`<br>`adicionarMeses(DateTime(2026, 3, 1), -1), DateTime(2026, 2, 1)` |
| C39 | moeda 1.234,56 € e datas dd/mm/aaaa | `moeda(1234.56), '1.234,56 €'`<br>`moeda(1234567.891), '1.234.567,89 €'`<br>`moeda(0.5), '0,50 €'`<br>`moeda(-20), '-20,00 €'`<br>`dataPt(DateTime(2026, 9, 6)), '06/09/2026'`<br>`pct(21.4), '21,4%'` |
| C40 | ler números escritos à portuguesa e à inglesa | `lerNumero('1.234,56'), 1234.56`<br>`lerNumero('1234.56'), 1234.56`<br>`lerNumero('12,5'), 12.5`<br>`lerNumero('1 250 €'), 1250`<br>`lerNumero('abc'), isNull` |
| C41 | hora de Lisboa: verão +1, inverno +0 | `paraLisboa(DateTime.utc(2026, 7, 1, 8, 0)).hour, 9`<br>`paraLisboa(DateTime.utc(2026, 12, 1, 8, 0)).hour, 8`<br>`hojeLisboa(agoraUtc: DateTime.utc(2026, 7, 1, 23, 30)), DateTime(2026, 7, 2)` |

## Gerador de obrigações

| # | Caso (entrada → esperado) | Asserções |
|---|---|---|
| C42 | TVDE aberto a 15/03/2026, isento: fim da isenção, pagamentos desde março 2027, sem IVA | `fim.dataLimite, DateTime(2027, 3, 1)`<br>`fim.valorEstimado, 224.70`<br>`fim.avisoEm, DateTime(2027, 1, 29)`<br>`pag.first.dataLimite, DateTime(2027, 3, 20)`<br>`pag.first.avisoEm, DateTime(2027, 3, 19)`<br>`pag.first.valorEstimado, 224.70`<br>`pag.length, 6`<br>`decl.map((o) => o.dataLimite), [DateTime(2027, 4, 30), DateTime(2027, 7, 31)]`<br>`obs.where((o) => o.tipo.startsWith('iva_')), isEmpty`<br>`obs.singleWhere((o) => o.tipo == 'irs_entrega').dataLimite, DateTime(2027, 6, 30)`<br>`obs.singleWhere((o) => o.tipo == 'efatura_validar').dataLimite, DateTime(2027, 2, 25)`<br>`obs.map((o) => o.chaveUnica).toSet().length, obs.length, reason: 'chaves únicas'`<br>`obs, isSorted<Obrigacao>((a, b) => a.dataLimite.compareTo(b.dataLimite))` |
| C43 | regime normal de IVA: declaração dia 20 e pagamento dia 25 do 2.º mês após o trimestre | `decl, [DateTime(2026, 11, 20), DateTime(2027, 2, 20), DateTime(2027, 5, 20), DateTime(2027, 8, 20)]`<br>`pag, [DateTime(2026, 11, 25), DateTime(2027, 2, 25), DateTime(2027, 5, 25), DateTime(2027, 8, 25)]`<br>`obs.where((o) => o.tipo == 'ss_pagamento').length, 12`<br>`obs.where((o) => o.tipo == 'ss_declaracao').length, 4`<br>`obs.where((o) => o.tipo == 'fim_isencao_ss'), isEmpty` |
| C44 | carro de fevereiro de 2021 com seguro em maio: IUC 28/02, IPO 28/02/2027, seguro roda para 2027 | `obs.where((o) => o.tipo.startsWith('ss_')), isEmpty`<br>`iuc.dataLimite, DateTime(2027, 2, 28)`<br>`iuc.valorEstimado, 111.48`<br>`iuc.avisoEm, DateTime(2027, 2, 26)`<br>`obs.singleWhere((o) => o.tipo == 'ipo').dataLimite, DateTime(2027, 2, 28)`<br>`obs.singleWhere((o) => o.tipo == 'seguro').dataLimite, DateTime(2027, 5, 15)`<br>`iuc.carroId, 'c1'` |
| C45 | sem atividade e sem carro → nada | `obs, isEmpty` |

## Regras legais (a tabela)

| # | Caso (entrada → esperado) | Asserções |
|---|---|---|
| C46 | número em falta é erro, nunca um valor inventado | `() => r.n('regra_que_nao_existe'), throwsStateError`<br>`r.regra('ipo_tvde')!.confirmada, isFalse`<br>`r.regra('ias')!.confirmada, isTrue` |
| C47 | escalões: 2027 não existe → usa o ano mais recente (2026) | `r.escaloesDoAno(2027).first.ano, 2026`<br>`r.escaloesDoAno(2025).length, 9` |

