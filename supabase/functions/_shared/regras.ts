// Em Dia — regras legais no servidor (Deno/TypeScript).
//
// ESPELHO EXATO da biblioteca Dart `lib/regras/` (datas.dart, formatos.dart,
// seguranca_social.dart, irs.dart, carro.dart, obrigacoes.dart,
// regras_legais.dart). Os dois lados são testados com os mesmos casos
// (test/unit/regras_test.dart ↔ _shared/regras_test.ts). Se mudares um lado,
// muda o outro e corre os dois oráculos.
//
// Nenhum número legal vive aqui: tudo vem de `regras_legais`, `irs_escaloes` e
// `feriados` (ver RegrasLegais). Um valor em falta é erro, nunca se inventa.

// ---------------------------------------------------------------------------
// Datas — representadas como Date à meia-noite UTC (só ano-mês-dia).
// Nunca se usa a hora local do servidor: os prazos legais contam à
// meia-noite de Lisboa (ver hojeLisboa).
// ---------------------------------------------------------------------------

/** Constrói um dia civil. Aceita mês/dia fora do intervalo como o Dart (13 → janeiro seguinte, 0 → último dia do mês anterior). */
export function dia(ano: number, mes: number, d: number): Date {
  return new Date(Date.UTC(ano, mes - 1, d));
}

/** Só a parte do dia (sem horas), para comparar e usar como chave. */
export function soDia(d: Date): Date {
  return dia(d.getUTCFullYear(), d.getUTCMonth() + 1, d.getUTCDate());
}

export const ano = (d: Date): number => d.getUTCFullYear();
export const mes = (d: Date): number => d.getUTCMonth() + 1;
export const diaDoMes = (d: Date): number => d.getUTCDate();

/** `YYYY-MM-DD` (o formato das colunas `date` do Postgres e das chaves únicas). */
export function dataIso(d: Date): string {
  return `${ano(d)}-${String(mes(d)).padStart(2, '0')}-${String(diaDoMes(d)).padStart(2, '0')}`;
}

/** Lê `YYYY-MM-DD` (ou um ISO completo) para um dia civil. */
export function lerDia(s: string): Date {
  const [a, m, d] = s.slice(0, 10).split('-').map((x) => parseInt(x, 10));
  return dia(a, m, d);
}

export function somarDias(d: Date, n: number): Date {
  return dia(ano(d), mes(d), diaDoMes(d) + n);
}

export const antes = (a: Date, b: Date): boolean => a.getTime() < b.getTime();
export const depois = (a: Date, b: Date): boolean => a.getTime() > b.getTime();
export const igual = (a: Date, b: Date): boolean => a.getTime() === b.getTime();

/** Converte um instante UTC para a hora de Lisboa (WET/WEST): último domingo de
 * março (01:00 UTC) ao último domingo de outubro (01:00 UTC) é verão (+1h). */
export function paraLisboa(utc: Date): Date {
  const inicioVerao = ultimoDomingo(utc.getUTCFullYear(), 3).getTime() + 3600_000;
  const fimVerao = ultimoDomingo(utc.getUTCFullYear(), 10).getTime() + 3600_000;
  const t = utc.getTime();
  const verao = t >= inicioVerao && t < fimVerao;
  return new Date(t + (verao ? 3600_000 : 0));
}

function ultimoDomingo(a: number, m: number): Date {
  const d = dia(a, m, ultimoDiaDoMes(a, m));
  return somarDias(d, -(d.getUTCDay() % 7));
}

/** Hoje em Lisboa (só o dia). */
export function hojeLisboa(agoraUtc?: Date): Date {
  return soDia(paraLisboa(agoraUtc ?? new Date()));
}

export function ultimoDiaDoMes(a: number, m: number): number {
  return dia(a, m + 1, 0).getUTCDate();
}

/** Soma meses prendendo o dia ao último dia do mês (31/01 + 1 mês = 28/02). */
export function adicionarMeses(d: Date, meses: number): Date {
  const total = mes(d) - 1 + meses;
  const a = ano(d) + Math.floor(total / 12);
  const m = ((total % 12) + 12) % 12 + 1;
  const dd = Math.min(Math.max(diaDoMes(d), 1), ultimoDiaDoMes(a, m));
  return dia(a, m, dd);
}

export const adicionarAnos = (d: Date, anos: number): Date => adicionarMeses(d, anos * 12);

export function ehFimDeSemana(d: Date): boolean {
  const w = d.getUTCDay();
  return w === 6 || w === 0;
}

export type Feriados = Set<string>; // `YYYY-MM-DD`

export function ehDiaUtil(d: Date, feriados: Feriados): boolean {
  return !ehFimDeSemana(d) && !feriados.has(dataIso(soDia(d)));
}

/** O próprio dia se for útil; senão o último dia útil ANTES. */
export function diaUtilAnteriorOuIgual(d: Date, feriados: Feriados): Date {
  let x = soDia(d);
  while (!ehDiaUtil(x, feriados)) x = somarDias(x, -1);
  return x;
}

/** Data em que se avisa um prazo: véspera útil se cair a fim-de-semana/feriado. */
export const avisoEm = (prazo: Date, feriados: Feriados): Date => diaUtilAnteriorOuIgual(prazo, feriados);

/** Soma N dias úteis (multas: 15 dias úteis de pagamento voluntário). */
export function somarDiasUteis(d: Date, dias: number, feriados: Feriados): Date {
  let x = soDia(d);
  let restam = dias;
  while (restam > 0) {
    x = somarDias(x, 1);
    if (ehDiaUtil(x, feriados)) restam--;
  }
  return x;
}

/** Dias inteiros entre hoje e o prazo (negativo = já passou). */
export function diasAte(prazo: Date, hoje: Date): number {
  return Math.round((soDia(prazo).getTime() - soDia(hoje).getTime()) / 86_400_000);
}

// ---------------------------------------------------------------------------
// Formatos de Portugal
// ---------------------------------------------------------------------------

/** Arredonda como o Dart `num.round()` (metade afasta-se de zero). */
function arredondar(v: number): number {
  return Math.sign(v) * Math.round(Math.abs(v));
}

/** Arredonda a cêntimos (espelho de `centimos` em formatos.dart). */
export function centimos(v: number): number {
  return arredondar(v * 100) / 100;
}

/** Moeda `1.234,56 €`. */
export function moeda(valor: number, comSimbolo = true, casas = 2): string {
  const negativo = valor < 0;
  const fixo = Math.abs(valor).toFixed(casas);
  const [inteiro, decimais = ''] = fixo.split('.');
  let sb = '';
  for (let i = 0; i < inteiro.length; i++) {
    const resto = inteiro.length - i;
    sb += inteiro[i];
    if (resto > 1 && resto % 3 === 1) sb += '.';
  }
  const texto = casas > 0 ? `${sb},${decimais}` : sb;
  return `${negativo ? '-' : ''}${texto}${comSimbolo ? ' €' : ''}`;
}

export const nomesMeses = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

export const nomeMes = (m: number): string => nomesMeses[m - 1];

export function dataPt(d: Date): string {
  return `${String(diaDoMes(d)).padStart(2, '0')}/${String(mes(d)).padStart(2, '0')}/${ano(d)}`;
}

// ---------------------------------------------------------------------------
// Regras legais (a tabela) — a ÚNICA fonte de números
// ---------------------------------------------------------------------------

export interface RegraLegal {
  chave: string;
  valorNum: number | null;
  valorTxt: string | null;
  // deno-lint-ignore no-explicit-any
  valorJson: any;
  unidade: string | null;
  ano: number;
  descricao: string;
  fonteUrl: string | null;
  confianca: string; // oficial | aproximado | por_confirmar
}

export interface EscalaoIrs {
  ano: number;
  ordem: number;
  ate: number | null; // null = sem limite
  taxa: number; // 0.125 = 12,5%
  parcelaAbater: number;
  confianca: string;
}

// deno-lint-ignore no-explicit-any
export function regraDeLinha(m: Record<string, any>): RegraLegal {
  return {
    chave: String(m.chave),
    valorNum: m.valor_num === null || m.valor_num === undefined ? null : Number(m.valor_num),
    valorTxt: m.valor_txt ?? null,
    valorJson: m.valor_json ?? null,
    unidade: m.unidade ?? null,
    ano: m.ano === null || m.ano === undefined ? 2026 : Number(m.ano),
    descricao: m.descricao ?? '',
    fonteUrl: m.fonte_url ?? null,
    confianca: m.confianca ?? 'oficial',
  };
}

// deno-lint-ignore no-explicit-any
export function escalaoDeLinha(m: Record<string, any>): EscalaoIrs {
  return {
    ano: Number(m.ano),
    ordem: Number(m.ordem),
    ate: m.ate === null || m.ate === undefined ? null : Number(m.ate),
    taxa: Number(m.taxa),
    parcelaAbater: Number(m.parcela_abater),
    confianca: m.confianca ?? 'oficial',
  };
}

export class RegrasLegais {
  private readonly regras: Map<string, RegraLegal>;
  readonly escaloes: EscalaoIrs[];
  readonly feriados: Feriados;

  constructor(regras: Iterable<RegraLegal>, escaloes: EscalaoIrs[], feriados: Iterable<Date | string>) {
    this.regras = new Map();
    for (const r of regras) this.regras.set(r.chave, r);
    this.escaloes = escaloes;
    this.feriados = new Set();
    for (const f of feriados) this.feriados.add(typeof f === 'string' ? f.slice(0, 10) : dataIso(f));
  }

  /** Constrói a partir das linhas cruas das três tabelas do Supabase. */
  static deTabelas(
    // deno-lint-ignore no-explicit-any
    regras: Record<string, any>[],
    // deno-lint-ignore no-explicit-any
    escaloes: Record<string, any>[],
    // deno-lint-ignore no-explicit-any
    feriados: Record<string, any>[],
  ): RegrasLegais {
    return new RegrasLegais(
      regras.map(regraDeLinha),
      escaloes.map(escalaoDeLinha),
      feriados.map((f) => String(f.data)),
    );
  }

  regra(chave: string): RegraLegal | undefined {
    return this.regras.get(chave);
  }

  tem(chave: string): boolean {
    return this.regras.has(chave);
  }

  /** Número da regra. Lança se não existir — nunca se inventa um valor por omissão. */
  n(chave: string): number {
    const r = this.regras.get(chave);
    if (!r || r.valorNum === null) throw new Error(`Regra legal em falta ou sem número: ${chave}`);
    return r.valorNum;
  }

  txt(chave: string): string {
    const r = this.regras.get(chave);
    if (!r || r.valorTxt === null) throw new Error(`Regra legal em falta ou sem texto: ${chave}`);
    return r.valorTxt;
  }

  // deno-lint-ignore no-explicit-any
  json(chave: string): any {
    const r = this.regras.get(chave);
    if (!r || r.valorJson === null || r.valorJson === undefined) {
      throw new Error(`Regra legal em falta ou sem JSON: ${chave}`);
    }
    return r.valorJson;
  }

  escaloesDoAno(a: number): EscalaoIrs[] {
    const doAno = this.escaloes.filter((e) => e.ano === a).sort((x, y) => x.ordem - y.ordem);
    if (doAno.length > 0) return doAno;
    // Sem tabela para o ano pedido: usa o ano mais recente que exista.
    const anos = [...new Set(this.escaloes.map((e) => e.ano))].sort((x, y) => x - y);
    if (anos.length === 0) return [];
    return this.escaloesDoAno(anos[anos.length - 1]);
  }
}

// ---------------------------------------------------------------------------
// Segurança Social
// ---------------------------------------------------------------------------

export type TipoRendimento = 'servicos' | 'vendas';

export interface ContribuicaoSS {
  rendimentoTrimestre: number;
  rendimentoMensalRelevante: number;
  baseIncidencia: number;
  contribuicaoMensal: number;
  contribuicaoTrimestre: number;
  bateuNoMinimo: boolean;
  bateuNoMaximo: boolean;
  ajustePct: number;
}

/** 21,4% sobre 70% (serviços) ou 20% (bens) do rendimento médio mensal do
 * trimestre; ajuste até ±25%; mínimo 20 €/mês; base máxima 12 × IAS. */
export function calcularSS(
  rendimentoTrimestre: number,
  tipo: TipoRendimento,
  ajustePct: number,
  r: RegrasLegais,
): ContribuicaoSS {
  const ajusteMax = Math.trunc(r.n('ss_ajuste_max'));
  const ajuste = Math.min(Math.max(ajustePct, -ajusteMax), ajusteMax);
  const pctBase = tipo === 'servicos' ? r.n('ss_base_servicos') : r.n('ss_base_vendas');
  const mensal = rendimentoTrimestre / 3 * pctBase / 100;
  let base = mensal * (1 + ajuste / 100);
  const teto = r.n('ss_base_maxima_ias') * r.n('ias');
  const bateuMax = base > teto;
  if (bateuMax) base = teto;
  let contribuicao = base * r.n('ss_taxa') / 100;
  const minimo = r.n('ss_minimo_mensal');
  const bateuMin = contribuicao < minimo;
  if (bateuMin) contribuicao = minimo;
  return {
    rendimentoTrimestre,
    rendimentoMensalRelevante: centimos(mensal),
    baseIncidencia: centimos(base),
    contribuicaoMensal: centimos(contribuicao),
    contribuicaoTrimestre: centimos(contribuicao * 3),
    bateuNoMinimo: bateuMin,
    bateuNoMaximo: bateuMax,
    ajustePct: ajuste,
  };
}

/** Estimativa a partir de um rendimento mensal: o trimestre é 3× o mês. */
export function estimarSSMensal(
  rendimentoMensal: number,
  tipo: TipoRendimento,
  ajustePct: number,
  r: RegrasLegais,
): ContribuicaoSS {
  return calcularSS(rendimentoMensal * 3, tipo, ajustePct, r);
}

/** Isenção do 1.º ano: primeiro dia do mês em que se começa a pagar. */
export function fimIsencaoSS(dataAbertura: Date, r: RegrasLegais): Date {
  const inicioMes = dia(ano(dataAbertura), mes(dataAbertura), 1);
  return adicionarMeses(inicioMes, Math.trunc(r.n('ss_isencao_meses')));
}

/** Último dia coberto pela isenção. */
export function ultimoDiaIsencaoSS(dataAbertura: Date, r: RegrasLegais): Date {
  return somarDias(fimIsencaoSS(dataAbertura, r), -1);
}

export function mesesDeIsencaoRestantes(dataAbertura: Date, hoje: Date, r: RegrasLegais): number {
  const fim = fimIsencaoSS(dataAbertura, r);
  const h = dia(ano(hoje), mes(hoje), 1);
  if (!antes(h, fim)) return 0;
  return (ano(fim) - ano(h)) * 12 + (mes(fim) - mes(h));
}

/** Meses da declaração trimestral (ordenados), da tabela. */
export function mesesDeclaracaoSS(r: RegrasLegais): number[] {
  return (r.json('ss_declaracao_meses') as number[]).map((e) => Math.trunc(Number(e))).sort((a, b) => a - b);
}

/** Primeiro mês de declaração trimestral igual ou posterior ao mês em que se
 * começa a pagar (POR CONFIRMAR com a Segurança Social). */
export function primeiraDeclaracaoTrimestral(dataAbertura: Date, r: RegrasLegais): Date {
  const fim = fimIsencaoSS(dataAbertura, r);
  const meses = mesesDeclaracaoSS(r);
  for (const m of meses) {
    if (m >= mes(fim)) return dia(ano(fim), m, 1);
  }
  return dia(ano(fim) + 1, meses[0], 1);
}

/** Prazo (último dia do mês) da declaração trimestral. */
export function prazoDeclaracaoTrimestral(a: number, mesDeclaracao: number): Date {
  return dia(a, mesDeclaracao, ultimoDiaDoMes(a, mesDeclaracao));
}

/** Prazo de pagamento da contribuição de um mês: dia 20 desse mês. */
export function prazoPagamentoSS(a: number, m: number, r: RegrasLegais): Date {
  return dia(a, m, Math.trunc(r.n('ss_pagamento_dia_fim')));
}

// ---------------------------------------------------------------------------
// IRS (regime simplificado)
// ---------------------------------------------------------------------------

export interface ProvisaoIrs {
  rendimentoBrutoAnual: number;
  coeficiente: number;
  rendimentoColetavel: number;
  impostoEstimado: number;
  guardarPorMes: number;
  taxaEfetivaPct: number;
  abaixoMinimoExistencia: boolean;
  justificarDespesas: boolean;
  pagamentoPorContaCada: number;
  anoEscaloes: number;
  escaloesConfirmados: boolean;
}

/** Imposto pelos escalões (taxa × coletável − parcela a abater). */
export function impostoPorEscaloes(coletavel: number, escaloes: EscalaoIrs[]): number {
  if (coletavel <= 0 || escaloes.length === 0) return 0;
  for (const e of escaloes) {
    if (e.ate === null || coletavel <= e.ate) return centimos(coletavel * e.taxa - e.parcelaAbater);
  }
  const ultimo = escaloes[escaloes.length - 1];
  return centimos(coletavel * ultimo.taxa - ultimo.parcelaAbater);
}

export function calcularIrs(
  rendimentoBrutoAnual: number,
  tipo: TipoRendimento,
  a: number,
  r: RegrasLegais,
): ProvisaoIrs {
  const coef = tipo === 'servicos' ? r.n('irs_coef_servicos') : r.n('irs_coef_vendas');
  const coletavel = centimos(rendimentoBrutoAnual * coef);
  const minimo = r.n('irs_minimo_existencia');
  const escaloes = r.escaloesDoAno(a);
  const abaixo = coletavel <= minimo;
  const imposto = abaixo ? 0 : impostoPorEscaloes(coletavel, escaloes);
  const ppcPct = r.n('irs_pagamentos_conta_pct');
  return {
    rendimentoBrutoAnual,
    coeficiente: coef,
    rendimentoColetavel: coletavel,
    impostoEstimado: imposto,
    guardarPorMes: centimos(imposto / 12),
    taxaEfetivaPct: rendimentoBrutoAnual > 0 ? centimos(imposto / rendimentoBrutoAnual * 100) : 0,
    abaixoMinimoExistencia: abaixo,
    justificarDespesas: rendimentoBrutoAnual > r.n('irs_despesas_justificar_limite'),
    pagamentoPorContaCada: centimos(imposto * ppcPct / 100 / 3),
    anoEscaloes: escaloes.length === 0 ? a : escaloes[0].ano,
    escaloesConfirmados: escaloes.every((e) => e.confianca !== 'por_confirmar'),
  };
}

function dataDoAno(a: number, mmdd: string): Date {
  const p = mmdd.split('-');
  return dia(a, parseInt(p[0], 10), parseInt(p[1], 10));
}

/** Datas dos pagamentos por conta num ano (20 jul / 20 set / 20 dez). */
export function datasPagamentosPorConta(a: number, r: RegrasLegais): Date[] {
  return (r.json('irs_pagamentos_conta_datas') as string[]).map((s) => dataDoAno(a, s));
}

export const prazoEntregaIrs = (a: number, r: RegrasLegais): Date => dataDoAno(a, r.txt('irs_entrega_fim'));
export const inicioEntregaIrs = (a: number, r: RegrasLegais): Date => dataDoAno(a, r.txt('irs_entrega_inicio'));
export const prazoValidarEfatura = (a: number, r: RegrasLegais): Date => dataDoAno(a, r.txt('efatura_validar_ate'));

// ---------------------------------------------------------------------------
// Carro
// ---------------------------------------------------------------------------

export type Combustivel = 'gasolina' | 'gasoleo' | 'eletrico' | 'hibrido' | 'gpl' | 'outro';

/** Prazo do IUC num dado ano: último dia do mês da matrícula. */
export function prazoIuc(mesMatricula: number, a: number): Date {
  return dia(a, mesMatricula, ultimoDiaDoMes(a, mesMatricula));
}

/** Próximo prazo do IUC a partir de hoje. */
export function proximoIuc(mesMatricula: number, hoje: Date): Date {
  const esteAno = prazoIuc(mesMatricula, ano(hoje));
  return antes(esteAno, soDia(hoje)) ? prazoIuc(mesMatricula, ano(hoje) + 1) : esteAno;
}

/** Calendário de inspeções: aos 4, 6 e 8 anos, depois anual. TVDE: anual (POR CONFIRMAR). */
export function calendarioIpo(matricula: Date, ate: Date, tvde: boolean, r: RegrasLegais): Date[] {
  const datas: Date[] = [];
  if (tvde) {
    let d = adicionarAnos(matricula, 1);
    while (!depois(d, ate)) {
      datas.push(d);
      d = adicionarAnos(d, 1);
    }
    return datas;
  }
  const marcos = (r.json('ipo_ligeiros_anos') as number[]).map((e) => Math.trunc(Number(e))).sort((a, b) => a - b);
  for (const anos of marcos) {
    const d = adicionarAnos(matricula, anos);
    if (!depois(d, ate)) datas.push(d);
  }
  let anos = marcos[marcos.length - 1] + 1;
  let d = adicionarAnos(matricula, anos);
  while (!depois(d, ate)) {
    datas.push(d);
    anos++;
    d = adicionarAnos(matricula, anos);
  }
  return datas;
}

/** Próxima inspeção: a primeira depois da última feita; senão a primeira ≥ hoje. */
export function proximaIpo(
  matricula: Date,
  ultimaIpo: Date | null,
  hoje: Date,
  tvde: boolean,
  r: RegrasLegais,
): Date | null {
  const cal = calendarioIpo(matricula, adicionarAnos(hoje, 3), tvde, r);
  if (ultimaIpo !== null) {
    for (const d of cal) if (depois(d, soDia(ultimaIpo))) return d;
    return null;
  }
  for (const d of cal) if (!antes(d, soDia(hoje))) return d;
  return null;
}

export function avisosIpo(r: RegrasLegais): number[] {
  return (r.json('ipo_avisos_dias') as number[]).map((e) => Math.trunc(Number(e)));
}

/** Data em que se avisa do seguro: 45 dias antes de renovar. */
export function avisoSeguro(renovaEm: Date, r: RegrasLegais): Date {
  return somarDias(renovaEm, -Math.trunc(r.n('seguro_aviso_dias')));
}

/** Validade da carta (anos) pela idade. */
export function anosValidadeCarta(idade: number, r: RegrasLegais): number {
  const m = r.json('carta_validade') as Record<string, number>;
  if (idade < 60) return Math.trunc(Number(m['ate_60']));
  if (idade < 70) return Math.trunc(Number(m['60_a_70']));
  return Math.trunc(Number(m['mais_70']));
}

/** Prazo de pagamento voluntário de uma multa/portagem: 15 dias úteis. */
export function prazoMulta(notificacao: Date, r: RegrasLegais): Date {
  return somarDiasUteis(notificacao, Math.trunc(r.n('multa_pagamento_voluntario_dias_uteis')), r.feriados);
}

export interface EstimativaIuc {
  valor: number;
  explicacao: string;
  aproximado: boolean;
}

function valorNaTabela(tabela: { ate: number; valor: number }[], chave: number): number {
  for (const linha of tabela) {
    if (chave <= Number(linha.ate)) return Number(linha.valor);
  }
  return Number(tabela[tabela.length - 1].valor);
}

/** Estimativa do IUC pela tabela simplificada de `regras_legais.iuc_tabela`. */
export function estimarIuc(
  matricula: Date,
  combustivel: Combustivel,
  cilindradaCc: number | null,
  co2: number | null,
  r: RegrasLegais,
  co2Wltp = true,
): EstimativaIuc | null {
  const t = r.json('iuc_tabela');
  if (combustivel === 'eletrico') {
    return { valor: 0, explicacao: 'Carro elétrico: isento de IUC.', aproximado: false };
  }
  if (cilindradaCc === null) return null;
  const catB = depois(matricula, dia(2007, 6, 30));
  if (!catB) {
    const tab = combustivel === 'gasoleo' ? t['cat_a_gasoleo'] : t['cat_a_gasolina'];
    const v = valorNaTabela(tab, cilindradaCc);
    return {
      valor: centimos(v),
      explicacao: `Categoria A (antes de julho de 2007): ${cilindradaCc} cc → ${moeda(v)}. Valor aproximado.`,
      aproximado: true,
    };
  }
  const vCil = valorNaTabela(t['cat_b_cilindrada'], cilindradaCc);
  let vCo2 = 0;
  if (co2 !== null) {
    vCo2 = valorNaTabela(co2Wltp ? t['cat_b_co2_wltp'] : t['cat_b_co2_nedc'], co2);
  }
  let coef = 1.0;
  for (const linha of t['cat_b_coef_ano'] as { ano: number; coef: number }[]) {
    if (ano(matricula) >= Number(linha.ano)) coef = Number(linha.coef);
  }
  const total = centimos((vCil + vCo2) * coef);
  return {
    valor: total,
    explicacao: `Categoria B: cilindrada ${moeda(vCil)} + CO2 ${moeda(vCo2)} × ${coef} (ano ${ano(matricula)}). ` +
      `${co2 === null ? 'Sem CO2 conhecido — falta a parcela do CO2. ' : ''}Valor aproximado: confirma no Portal das Finanças.`,
    aproximado: true,
  };
}

// ---------------------------------------------------------------------------
// Gerador de obrigações (espelho de obrigacoes.dart)
// ---------------------------------------------------------------------------

export type TipoAtividade = 'tvde' | 'estafeta' | 'servicos' | 'freelancer' | 'sem_atividade' | 'so_carro';
export type RegimeIva = 'isento_53' | 'normal';

export interface PerfilObrigacoes {
  tipoAtividade: TipoAtividade;
  dataAbertura: Date | null;
  regimeIva: RegimeIva;
  tipoRendimento: TipoRendimento;
  rendimentoMensalEstimado: number | null;
  ajusteSsPct: number;
  usaSoftwareFaturacao: boolean;
  imigrante: boolean;
  residenciaRenovaEm: Date | null;
  tvdeCertificadoValidade: Date | null;
}

export function perfil(p: Partial<PerfilObrigacoes> & { tipoAtividade: TipoAtividade }): PerfilObrigacoes {
  return {
    dataAbertura: null,
    regimeIva: 'isento_53',
    tipoRendimento: 'servicos',
    rendimentoMensalEstimado: null,
    ajusteSsPct: 0,
    usaSoftwareFaturacao: false,
    imigrante: false,
    residenciaRenovaEm: null,
    tvdeCertificadoValidade: null,
    ...p,
  };
}

export function temAtividade(p: PerfilObrigacoes): boolean {
  return p.tipoAtividade !== 'sem_atividade' && p.tipoAtividade !== 'so_carro' && p.dataAbertura !== null;
}

export interface CarroObrigacoes {
  id: string;
  matricula: string;
  dataMatricula: Date; // se só se sabe mês/ano: último dia do mês
  seguroRenovaEm: Date | null;
  ultimaIpo: Date | null;
  cartaValidade: Date | null;
  usoTvde: boolean;
  combustivel: Combustivel;
  cilindradaCc: number | null;
  co2: number | null;
}

export function carro(c: Partial<CarroObrigacoes> & { id: string; matricula: string; dataMatricula: Date }): CarroObrigacoes {
  return {
    seguroRenovaEm: null,
    ultimaIpo: null,
    cartaValidade: null,
    usoTvde: false,
    combustivel: 'gasolina',
    cilindradaCc: null,
    co2: null,
    ...c,
  };
}

export interface Obrigacao {
  tipo: string;
  descricao: string;
  dataLimite: Date;
  avisoEm: Date;
  valorEstimado: number | null;
  origemRegra: string;
  comoPagar: string;
  chaveUnica: string;
  carroId: string | null;
}

/** Linha pronta para `public.obrigacoes`. */
export function obrigacaoParaLinha(o: Obrigacao, userId: string): Record<string, unknown> {
  return {
    user_id: userId,
    carro_id: o.carroId,
    tipo: o.tipo,
    descricao: o.descricao,
    data_limite: dataIso(o.dataLimite),
    aviso_em: dataIso(o.avisoEm),
    valor_estimado: o.valorEstimado,
    origem_regra: o.origemRegra,
    como_pagar: o.comoPagar,
    chave_unica: o.chaveUnica,
  };
}

/** Gera todas as obrigações entre hoje e `ate` (por omissão: 12 meses). */
export function gerarObrigacoes(
  p: PerfilObrigacoes,
  carros: CarroObrigacoes[],
  hoje: Date,
  r: RegrasLegais,
  ate?: Date,
): Obrigacao[] {
  const desde = soDia(hoje);
  const fim = ate ?? adicionarMeses(desde, 12);
  const out: Obrigacao[] = [];
  const feriados = r.feriados;

  const o = (x: {
    tipo: string;
    descricao: string;
    prazo: Date;
    valor?: number | null;
    regra: string;
    comoPagar: string;
    carroId?: string | null;
    sufixo?: string;
  }): Obrigacao => ({
    tipo: x.tipo,
    descricao: x.descricao,
    dataLimite: soDia(x.prazo),
    avisoEm: avisoEm(x.prazo, feriados),
    valorEstimado: x.valor ?? null,
    origemRegra: x.regra,
    comoPagar: x.comoPagar,
    chaveUnica: `${x.tipo}|${dataIso(x.prazo)}${x.carroId ? `|${x.carroId}` : ''}${x.sufixo ?? ''}`,
    carroId: x.carroId ?? null,
  });

  const dentro = (d: Date): boolean => !antes(d, desde) && !depois(d, fim);

  // ---------------- Segurança Social ----------------
  if (temAtividade(p)) {
    const abertura = p.dataAbertura!;
    const fimIsencao = fimIsencaoSS(abertura, r);
    const avisoDias = Math.trunc(r.n('ss_aviso_fim_isencao_dias'));
    const estim = p.rendimentoMensalEstimado === null
      ? null
      : estimarSSMensal(p.rendimentoMensalEstimado, p.tipoRendimento, p.ajusteSsPct, r);

    // Fim da isenção: o aviso sai 30 dias antes (véspera útil), com o valor que vai passar a pagar.
    const avisoFim = somarDias(fimIsencao, -avisoDias);
    if (dentro(fimIsencao)) {
      out.push({
        tipo: 'fim_isencao_ss',
        descricao:
          `Acaba a isenção de Segurança Social. A partir de ${nomeMes(mes(fimIsencao))} pagas cerca de ${estim === null ? '—' : moeda(estim.contribuicaoMensal)}/mês.`,
        dataLimite: fimIsencao,
        avisoEm: avisoEm(antes(avisoFim, desde) ? fimIsencao : avisoFim, feriados),
        valorEstimado: estim === null ? null : estim.contribuicaoMensal,
        origemRegra: 'ss_isencao_meses',
        comoPagar: 'Nada a pagar neste dia — é só para saberes. O primeiro pagamento é entre o dia 10 e 20 do mês seguinte, na Segurança Social Direta.',
        chaveUnica: `fim_isencao_ss|${dataIso(fimIsencao)}`,
        carroId: null,
      });
    }

    // Declarações trimestrais (último dia de jan/abr/jul/out) e pagamentos (dia 20)
    const mesesDecl = mesesDeclaracaoSS(r);
    const primeiraDecl = primeiraDeclaracaoTrimestral(abertura, r);
    let cursor = dia(ano(desde), mes(desde), 1);
    while (!depois(cursor, fim)) {
      // declaração
      if (mesesDecl.includes(mes(cursor)) && !antes(cursor, primeiraDecl)) {
        const prazo = prazoDeclaracaoTrimestral(ano(cursor), mes(cursor));
        if (dentro(prazo)) {
          out.push(o({
            tipo: 'ss_declaracao',
            descricao: 'Declaração trimestral à Segurança Social: o que ganhaste nos últimos 3 meses.',
            prazo,
            regra: 'ss_declaracao_meses',
            comoPagar: 'Segurança Social Direta → Emprego → Trabalhadores Independentes → Regime de rendimentos → Declaração trimestral. Não se paga nada aqui: só se declara.',
          }));
        }
      }
      // pagamento mensal (a partir do mês em que acaba a isenção)
      if (!antes(cursor, fimIsencao)) {
        const prazo = prazoPagamentoSS(ano(cursor), mes(cursor), r);
        if (dentro(prazo)) {
          out.push(o({
            tipo: 'ss_pagamento',
            descricao: `Contribuição de ${nomeMes(mes(cursor))} para a Segurança Social.`,
            prazo,
            valor: estim === null ? null : estim.contribuicaoMensal,
            regra: 'ss_pagamento_dia_fim',
            comoPagar: 'Segurança Social Direta → Conta-corrente → Pagamentos → gera a referência Multibanco e paga na app do banco. Entre o dia 10 e o dia 20.',
          }));
        }
      }
      cursor = adicionarMeses(cursor, 1);
    }

    // ---------------- IVA (regime normal, trimestral) ----------------
    if (p.regimeIva === 'normal') {
      const diaDecl = Math.trunc(r.n('iva_declaracao_trimestral_dia'));
      const diaPag = Math.trunc(r.n('iva_pagamento_dia'));
      // trimestres: T1 (jan–mar) → maio; T2 → agosto; T3 → novembro; T4 → fevereiro
      for (let a = ano(desde) - 1; a <= ano(fim); a++) {
        for (const t of [1, 2, 3, 4]) {
          const mesDecl = t * 3 + 2; // 5, 8, 11, 14→2 do ano seguinte
          const anoDecl = mesDecl > 12 ? a + 1 : a;
          const m = mesDecl > 12 ? mesDecl - 12 : mesDecl;
          const decl = dia(anoDecl, m, diaDecl);
          const pag = dia(anoDecl, m, diaPag);
          if (dentro(decl)) {
            out.push(o({
              tipo: 'iva_declaracao',
              descricao: `Declaração de IVA do ${t}.º trimestre de ${a}.`,
              prazo: decl,
              regra: 'iva_declaracao_trimestral_dia',
              comoPagar: 'Portal das Finanças → IVA → Entregar declaração periódica (ou o contabilista faz).',
            }));
          }
          if (dentro(pag)) {
            out.push(o({
              tipo: 'iva_pagamento',
              descricao: `Pagar o IVA do ${t}.º trimestre de ${a}.`,
              prazo: pag,
              regra: 'iva_pagamento_dia',
              comoPagar: 'Depois de entregar a declaração, o Portal das Finanças dá a referência de pagamento. Paga na app do banco.',
            }));
          }
        }
      }
    }

    // ---------------- IRS ----------------
    for (let a = ano(desde); a <= ano(fim); a++) {
      const entrega = prazoEntregaIrs(a, r);
      if (dentro(entrega)) {
        out.push(o({
          tipo: 'irs_entrega',
          descricao: `Entregar a declaração de IRS do ano ${a - 1} (anexo B).`,
          prazo: entrega,
          regra: 'irs_entrega_fim',
          comoPagar: 'Portal das Finanças → IRS → Entregar declaração. Começa a 1 de abril. Se tiveres dúvidas, um contabilista faz por pouco dinheiro.',
        }));
      }
      const efatura = prazoValidarEfatura(a, r);
      if (dentro(efatura)) {
        out.push(o({
          tipo: 'efatura_validar',
          descricao: `Validar as faturas no e-fatura (as despesas com NIF de ${a - 1}).`,
          prazo: efatura,
          regra: 'efatura_validar_ate',
          comoPagar: 'faturas.portaldasfinancas.gov.pt → Faturas → Consumidor → valida as que estão pendentes.',
        }));
      }
      // pagamentos por conta (só faz sentido com estimativa de imposto)
      if (p.rendimentoMensalEstimado !== null) {
        const prov = calcularIrs(p.rendimentoMensalEstimado * 12, p.tipoRendimento, a, r);
        if (prov.pagamentoPorContaCada > 0) {
          for (const d of datasPagamentosPorConta(a, r)) {
            if (dentro(d)) {
              out.push(o({
                tipo: 'irs_pagamento_conta',
                descricao: `Pagamento por conta de IRS (${nomeMes(mes(d))}).`,
                prazo: d,
                valor: prov.pagamentoPorContaCada,
                regra: 'irs_pagamentos_conta_pct',
                comoPagar: 'Portal das Finanças → Situação fiscal → Pagamentos → referência Multibanco. Só se aplica se tiveste IRS a pagar no ano anterior.',
              }));
            }
          }
        }
      }
    }

    // ---------------- Comunicar recibos (só com software de faturação) ----------------
    if (p.usaSoftwareFaturacao) {
      let c = dia(ano(desde), mes(desde), 1);
      while (!depois(c, fim)) {
        const prazo = dia(ano(c), mes(c), Math.trunc(r.n('recibos_comunicar_dia')));
        if (dentro(prazo)) {
          out.push(o({
            tipo: 'recibos_comunicar',
            descricao: `Comunicar às Finanças as faturas de ${nomeMes(mes(adicionarMeses(c, -1)))}.`,
            prazo,
            regra: 'recibos_comunicar_dia',
            comoPagar: 'O teu programa de faturação envia o ficheiro SAF-T. Se passas recibos no Portal das Finanças, isto não se aplica a ti.',
          }));
        }
        c = adicionarMeses(c, 1);
      }
    }
  }

  // ---------------- TVDE ----------------
  if (p.tipoAtividade === 'tvde' && p.tvdeCertificadoValidade !== null) {
    const v = p.tvdeCertificadoValidade;
    if (dentro(v)) {
      out.push(o({
        tipo: 'tvde_certificado',
        descricao: 'Renovar o certificado de motorista TVDE (vale 5 anos).',
        prazo: v,
        regra: 'tvde_certificado_validade_anos',
        comoPagar: 'IMT online → Motorista TVDE → renovação. Trata com 2 meses de antecedência.',
      }));
    }
  }

  // ---------------- Imigrante ----------------
  if (p.imigrante && p.residenciaRenovaEm !== null && dentro(p.residenciaRenovaEm)) {
    out.push(o({
      tipo: 'residencia',
      descricao: 'Renovar a autorização de residência.',
      prazo: p.residenciaRenovaEm,
      regra: 'troca_carta_estrangeira_prazo_anos',
      comoPagar: 'Portal da AIMA → renovação automática ou marcação. Começa 90 dias antes.',
    }));
  }

  // ---------------- Carro ----------------
  for (const c of carros) {
    // IUC — todos os anos no mês da matrícula
    for (let a = ano(desde); a <= ano(fim); a++) {
      const prazo = prazoIuc(mes(c.dataMatricula), a);
      if (dentro(prazo)) {
        const est = estimarIuc(c.dataMatricula, c.combustivel, c.cilindradaCc, c.co2, r);
        out.push(o({
          tipo: 'iuc',
          descricao: `IUC (imposto do carro) do ${c.matricula}.`,
          prazo,
          valor: est === null ? null : est.valor,
          regra: 'iuc_regra',
          comoPagar: 'Portal das Finanças → IUC → Pagar → escolhe a matrícula → referência Multibanco. Até ao fim do mês da matrícula.',
          carroId: c.id,
        }));
      }
    }
    // IPO
    const ipo = proximaIpo(c.dataMatricula, c.ultimaIpo, desde, c.usoTvde, r);
    if (ipo !== null && dentro(ipo)) {
      out.push(o({
        tipo: 'ipo',
        descricao: `Inspeção periódica do ${c.matricula}.`,
        prazo: ipo,
        regra: c.usoTvde ? 'ipo_tvde' : 'ipo_ligeiros_anos',
        comoPagar: 'Marca num centro de inspeção perto de ti (a app mostra os mais próximos). Leva o DUA e o seguro. Custa cerca de 30–40 €.',
        carroId: c.id,
      }));
    }
    // Seguro
    if (c.seguroRenovaEm !== null) {
      let s = c.seguroRenovaEm;
      while (antes(s, desde)) s = adicionarAnos(s, 1);
      if (dentro(s)) {
        out.push(o({
          tipo: 'seguro',
          descricao: `Renova o seguro do ${c.matricula}. 45 dias antes é a altura de comparar preços.`,
          prazo: s,
          regra: 'seguro_aviso_dias',
          comoPagar: 'Pede 2 ou 3 simulações antes de renovar. Se mudares de seguradora, avisa a antiga por escrito 30 dias antes.',
          carroId: c.id,
        }));
      }
    }
    // Carta
    if (c.cartaValidade !== null && dentro(c.cartaValidade)) {
      out.push(o({
        tipo: 'carta',
        descricao: 'Renovar a carta de condução.',
        prazo: c.cartaValidade,
        regra: 'carta_validade',
        comoPagar: 'IMT online ou Espaço Cidadão. Precisas de atestado médico (o médico de família passa).',
        carroId: c.id,
      }));
    }
  }

  out.sort((a, b) => a.dataLimite.getTime() - b.dataLimite.getTime());
  return out;
}

// ---------------------------------------------------------------------------
// Conversão das linhas do Supabase para o perfil/carros do gerador
// ---------------------------------------------------------------------------

// deno-lint-ignore no-explicit-any
export function perfilDeLinha(p: Record<string, any>): PerfilObrigacoes {
  return perfil({
    tipoAtividade: (p.tipo_atividade ?? 'sem_atividade') as TipoAtividade,
    dataAbertura: p.data_abertura ? lerDia(String(p.data_abertura)) : null,
    regimeIva: (p.regime_iva ?? 'isento_53') as RegimeIva,
    tipoRendimento: (p.tipo_rendimento ?? 'servicos') as TipoRendimento,
    rendimentoMensalEstimado: p.rendimento_mensal_estimado === null || p.rendimento_mensal_estimado === undefined
      ? null
      : Number(p.rendimento_mensal_estimado),
    ajusteSsPct: Number(p.ajuste_ss_pct ?? 0),
    usaSoftwareFaturacao: Boolean(p.usa_software_faturacao ?? false),
    imigrante: Boolean(p.imigrante ?? false),
    residenciaRenovaEm: p.residencia_renova_em ? lerDia(String(p.residencia_renova_em)) : null,
    tvdeCertificadoValidade: p.tvde_certificado_validade ? lerDia(String(p.tvde_certificado_validade)) : null,
  });
}

/** Data de matrícula: `data_matricula` ou, se só há mês/ano, o último dia desse mês. */
// deno-lint-ignore no-explicit-any
export function dataMatriculaDeLinha(c: Record<string, any>): Date | null {
  if (c.data_matricula) return lerDia(String(c.data_matricula));
  if (c.mes_matricula && c.ano_matricula) {
    const m = Number(c.mes_matricula);
    const a = Number(c.ano_matricula);
    return dia(a, m, ultimoDiaDoMes(a, m));
  }
  return null;
}

// deno-lint-ignore no-explicit-any
export function carroDeLinha(c: Record<string, any>): CarroObrigacoes | null {
  const dm = dataMatriculaDeLinha(c);
  if (dm === null) return null; // sem data de matrícula não há IUC nem IPO a calcular
  return carro({
    id: String(c.id),
    matricula: String(c.matricula ?? ''),
    dataMatricula: dm,
    seguroRenovaEm: c.seguro_renova_em ? lerDia(String(c.seguro_renova_em)) : null,
    ultimaIpo: c.ultima_ipo ? lerDia(String(c.ultima_ipo)) : null,
    cartaValidade: c.carta_validade ? lerDia(String(c.carta_validade)) : null,
    usoTvde: Boolean(c.uso_tvde ?? false),
    combustivel: (c.combustivel ?? 'gasolina') as Combustivel,
    cilindradaCc: c.cilindrada_cc === null || c.cilindrada_cc === undefined ? null : Number(c.cilindrada_cc),
    co2: c.co2_g_km === null || c.co2_g_km === undefined ? null : Number(c.co2_g_km),
  });
}
