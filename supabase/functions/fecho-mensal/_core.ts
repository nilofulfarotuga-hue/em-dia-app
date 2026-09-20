export type EstadoFecho = 'ok' | 'sem_extrato' | 'por_rever' | 'erro'

export interface ResultadoGooglePlay {
  moeda: string | null
  bruto: number | null
  comissao: number | null
  iva: number | null
  reembolsos: number | null
  liquido: number | null
  transacoes: number
  estado: EstadoFecho
  motivo: string | null
}

export interface ResumoFecho extends ResultadoGooglePlay {
  app: string
  mes: string
  assinaturas_ativas: number
  ficheiros: string[]
  regras_calculo: string[]
}

export function parseCsv(texto: string): string[][] {
  const linhas: string[][] = []
  let linha: string[] = []
  let campo = ''
  let emAspas = false

  for (let i = 0; i < texto.length; i++) {
    const c = texto[i]
    const prox = texto[i + 1]
    if (emAspas) {
      if (c === '"' && prox === '"') {
        campo += '"'
        i++
      } else if (c === '"') {
        emAspas = false
      } else {
        campo += c
      }
      continue
    }
    if (c === '"') {
      emAspas = true
    } else if (c === ',') {
      linha.push(campo)
      campo = ''
    } else if (c === '\n') {
      linha.push(campo)
      linhas.push(linha)
      linha = []
      campo = ''
    } else if (c !== '\r') {
      campo += c
    }
  }
  if (campo !== '' || linha.length > 0) {
    linha.push(campo)
    linhas.push(linha)
  }
  return linhas
}

function normalizar(nome: string): string {
  return nome.trim().toLowerCase().replace(/\s+/g, ' ')
}

function procurarColuna(cabecalho: string[], nomes: string[]): number {
  const alvo = nomes.map(normalizar)
  return cabecalho.findIndex((c) => alvo.includes(normalizar(c)))
}

function numero(valor: string | undefined): number | null {
  if (valor === undefined) return null
  const limpo = valor.trim().replace(/\s/g, '')
  if (!limpo) return null
  const n = Number(limpo.replace(',', '.'))
  return Number.isFinite(n) ? n : null
}

function arredondar2(n: number): number {
  return Math.round((n + Number.EPSILON) * 100) / 100
}

export function calcularGooglePlay(csv: string): ResultadoGooglePlay {
  const linhas = parseCsv(csv).filter((l) => l.some((c) => c.trim() !== ''))
  if (linhas.length < 2) {
    return { moeda: null, bruto: null, comissao: null, iva: null, reembolsos: null, liquido: null, transacoes: 0, estado: 'por_rever', motivo: 'CSV vazio ou sem linhas de dados.' }
  }

  const cabecalho = linhas[0]
  const idxTipo = procurarColuna(cabecalho, ['Transaction Type', 'Tipo de transação', 'Tipo de transacao'])
  const idxValor = procurarColuna(cabecalho, ['Amount (Merchant Currency)', 'Merchant Amount', 'Valor na moeda do comerciante'])
  const idxMoeda = procurarColuna(cabecalho, ['Merchant Currency', 'Moeda do comerciante'])
  if (idxTipo < 0 || idxValor < 0) {
    return { moeda: null, bruto: null, comissao: null, iva: null, reembolsos: null, liquido: null, transacoes: 0, estado: 'por_rever', motivo: 'Cabeçalho do CSV não reconhecido: faltam Transaction Type ou Amount (Merchant Currency).' }
  }

  let bruto = 0
  let comissao = 0
  let iva = 0
  let reembolsos = 0
  let transacoes = 0
  let moeda: string | null = null
  let valoresIlegiveis = 0

  for (const linha of linhas.slice(1)) {
    const tipo = (linha[idxTipo] ?? '').trim()
    const valor = numero(linha[idxValor])
    if (!tipo) continue
    if (normalizar(tipo) === normalizar(cabecalho[idxTipo])) continue
    if (idxMoeda >= 0 && !moeda && linha[idxMoeda]?.trim()) moeda = linha[idxMoeda].trim()
    if (valor === null) {
      valoresIlegiveis++
      continue
    }
    if (tipo === 'Charge') {
      bruto += valor
      transacoes++
    } else if (tipo === 'Google fee') {
      comissao += valor
    } else if (tipo === 'Tax') {
      iva += valor
    } else if (['Charge refund', 'Google fee refund', 'Tax refund'].includes(tipo)) {
      reembolsos += valor
    }
  }

  // Regras de cálculo: bruto = Charge; comissão = Google fee; IVA = Tax;
  // reembolsos = Charge refund + Google fee refund + Tax refund; líquido = bruto + comissão + reembolsos.
  // O IVA não entra no líquido porque, na UE, a Google cobra e entrega o IVA.
  const liquido = bruto + comissao + reembolsos
  const motivo = valoresIlegiveis > 0 ? `${valoresIlegiveis} linha(s) com valor ilegível.` : null
  return {
    moeda,
    bruto: arredondar2(bruto),
    comissao: arredondar2(comissao),
    iva: arredondar2(iva),
    reembolsos: arredondar2(reembolsos),
    liquido: arredondar2(liquido),
    transacoes,
    estado: valoresIlegiveis > 0 ? 'por_rever' : 'ok',
    motivo,
  }
}

export function formatarMoedaPt(valor: number | null, moeda = 'EUR'): string {
  if (valor === null || !Number.isFinite(valor)) return 'sem dados'
  const sinal = valor < 0 ? '-' : ''
  const [inteiro, decimal] = Math.abs(valor).toFixed(2).split('.')
  const milhares = inteiro.replace(/\B(?=(\d{3})+(?!\d))/g, '.')
  const simbolo = moeda === 'EUR' ? '€' : moeda
  return `${sinal}${milhares},${decimal} ${simbolo}`
}

export function folhaDeRosto(resumo: ResumoFecho): string {
  const moeda = resumo.moeda ?? 'EUR'
  const linhas = [
    `# Fecho mensal — ${resumo.app} — ${resumo.mes}`,
    '',
    `Estado: ${resumo.estado}`,
    resumo.motivo ? `Nota: ${resumo.motivo}` : null,
    '',
    `Bruto: ${formatarMoedaPt(resumo.bruto, moeda)}`,
    `Comissão Google: ${formatarMoedaPt(resumo.comissao, moeda)}`,
    `IVA: ${formatarMoedaPt(resumo.iva, moeda)}`,
    `Reembolsos: ${formatarMoedaPt(resumo.reembolsos, moeda)}`,
    `Líquido: ${formatarMoedaPt(resumo.liquido, moeda)}`,
    '',
    `Transações cobradas: ${resumo.transacoes}`,
    `Assinaturas ativas no fim do mês: ${resumo.assinaturas_ativas}`,
    '',
    'De onde vieram os números:',
    resumo.ficheiros.length ? resumo.ficheiros.map((f) => `- ${f}`).join('\n') : '- Sem extrato da Google.',
    '',
    'Regras de cálculo:',
    ...resumo.regras_calculo.map((r) => `- ${r}`),
    '',
    'Nota sobre o IVA: na União Europeia, a Google cobra e entrega o IVA. Por isso o IVA fica registado à parte e não entra no líquido pago ao programador.',
    '',
  ].filter((x): x is string => x !== null)
  return linhas.join('\n')
}

export function mesAnteriorLisboa(agora = new Date()): string {
  const partes = new Intl.DateTimeFormat('en-GB', { timeZone: 'Europe/Lisbon', year: 'numeric', month: '2-digit' }).formatToParts(agora)
  const ano = Number(partes.find((p) => p.type === 'year')?.value ?? agora.getUTCFullYear())
  const mes = Number(partes.find((p) => p.type === 'month')?.value ?? agora.getUTCMonth() + 1)
  const d = new Date(Date.UTC(ano, mes - 2, 1))
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}`
}

export function inicioMes(mes: string): string {
  return `${mes}-01`
}

export function fimMesIso(mes: string): string {
  const [ano, m] = mes.split('-').map(Number)
  return new Date(Date.UTC(ano, m, 0, 23, 59, 59, 999)).toISOString()
}

export const REGRAS_CALCULO = [
  'bruto = soma de Amount (Merchant Currency) das linhas Transaction Type = Charge.',
  'comissão = soma negativa das linhas Transaction Type = Google fee.',
  'IVA = soma das linhas Transaction Type = Tax.',
  'reembolsos = soma das linhas Charge refund, Google fee refund e Tax refund.',
  'líquido = bruto + comissão + reembolsos; o IVA não entra porque a Google o entrega ela própria.',
]
