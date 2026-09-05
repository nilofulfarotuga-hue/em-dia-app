// Textos dos avisos push (copiados de lib/l10n/app_pt.arb e app_pt_BR.arb).
// A variante escolhe-se por profiles.variante_pt ('pt' | 'br'). Nunca inventar números aqui:
// os que aparecem nos textos são os que estão nos .arb da app.

export type VariantePt = 'pt' | 'br'

export type TipoAviso =
  | '5_dias' | 'dia' | 'passado' | 'vigia_iva' | 'fim_isencao'
  | 'carro' | 'trial_25' | 'trial_31' | 'reativacao'

type Textos = {
  // corpos (do .arb)
  push5Dias: (obrigacao: string, valor: string) => string
  pushDia: (obrigacao: string, valor: string) => string
  pushPassado: (dia: string) => string
  pushVigiaIva: (valor: string) => string
  pushFimIsencao: (mes: string, valor: string) => string
  pushCarro: (matricula: string, data: string) => string
  pushTrial25: string
  pushTrial31: string
  pushReativacao: string
  // títulos curtos por tipo (não existem no .arb — só servem de cabeçalho da notificação)
  titulos: Record<TipoAviso, string>
  // título do push agrupado: "Tens N coisas hoje"
  varias: (n: number) => string
  valorPorConfirmar: string
  meses: string[]
}

const MESES_PT = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro']

export const MENSAGENS: Record<VariantePt, Textos> = {
  pt: {
    push5Dias: (o, v) => `Faltam 5 dias para ${o} (${v}). Toca aqui para ver como pagar.`,
    pushDia: (o, v) => `É hoje. ${o}, ${v}, até à meia-noite. Já pagaste? Toca em Já paguei.`,
    pushPassado: (d) => `Passou o dia ${d} e não marcaste como pago. Não é o fim do mundo: paga hoje, os juros são pequenos. Se já pagaste, toca aqui.`,
    pushVigiaIva: (v) => `Atenção: já vais em ${v} este ano. Se passares os 15.000 €, no próximo ano tens de cobrar IVA. Queres perceber o que muda?`,
    pushFimIsencao: (m, v) => `Daqui a 30 dias acaba a tua isenção de Segurança Social. A partir de ${m} vais pagar cerca de ${v}/mês. Já estás avisado, sem sustos.`,
    pushCarro: (m, d) => `A inspeção do teu carro (${m}) é até ${d}. Marca já — os centros enchem no fim do mês.`,
    pushTrial25: 'Faltam 5 dias para o teu mês grátis acabar. Depois disso o Em Dia continua a avisar-te, mas com limites. Por 3,49 €/mês (ou 29,90 €/ano) fica tudo como está.',
    pushTrial31: 'Hoje evitaste multas durante um mês. Para continuar assim é 3,49 € por mês — menos que uma multa. Toca para ativar.',
    pushReativacao: 'Está tudo em dia do teu lado. Não precisas de fazer nada. Eu avisarei.',
    titulos: {
      '5_dias': 'Faltam 5 dias',
      'dia': 'É hoje',
      'passado': 'Passou o prazo',
      'vigia_iva': 'Vigia do IVA',
      'fim_isencao': 'Fim da isenção',
      'carro': 'Inspeção do carro',
      'trial_25': 'Mês grátis a acabar',
      'trial_31': 'Mês grátis acabou',
      'reativacao': 'Estás em dia',
    },
    varias: (n) => `Tens ${n} coisas hoje`,
    valorPorConfirmar: 'valor por confirmar',
    meses: MESES_PT,
  },
  br: {
    push5Dias: (o, v) => `Faltam 5 dias para ${o} (${v}). Toque aqui para ver como pagar.`,
    pushDia: (o, v) => `É hoje. ${o}, ${v}, até meia-noite. Já pagou? Toque em Já paguei.`,
    pushPassado: (d) => `Passou o dia ${d} e você não marcou como pago. Não é o fim do mundo: pague hoje, os juros são pequenos. Se já pagou, toque aqui.`,
    pushVigiaIva: (v) => `Atenção: você já está em ${v} este ano. Se passar de 15.000 €, no ano que vem tem que cobrar IVA. Quer entender o que muda?`,
    pushFimIsencao: (m, v) => `Daqui a 30 dias acaba a sua isenção da Segurança Social. A partir de ${m} você vai pagar cerca de ${v}/mês. Já está avisado, sem susto.`,
    pushCarro: (m, d) => `A inspeção do seu carro (${m}) é até ${d}. Marque já — os centros lotam no fim do mês.`,
    pushTrial25: 'Faltam 5 dias para o seu mês grátis acabar. Depois disso o Em Dia continua te avisando, mas com limites. Por 3,49 €/mês (ou 29,90 €/ano) fica tudo como está.',
    pushTrial31: 'Hoje você evitou multas durante um mês. Para continuar assim é 3,49 € por mês — menos que uma multa. Toque para ativar.',
    pushReativacao: 'Está tudo em dia do seu lado. Não precisa fazer nada. Eu aviso.',
    titulos: {
      '5_dias': 'Faltam 5 dias',
      'dia': 'É hoje',
      'passado': 'Passou o prazo',
      'vigia_iva': 'Vigia do IVA',
      'fim_isencao': 'Fim da isenção',
      'carro': 'Inspeção do carro',
      'trial_25': 'Mês grátis acabando',
      'trial_31': 'Mês grátis acabou',
      'reativacao': 'Você está em dia',
    },
    varias: (n) => `Você tem ${n} coisas hoje`,
    valorPorConfirmar: 'valor a confirmar',
    meses: MESES_PT,
  },
}

/** "1.234,56 €" — milhares com ponto, decimais com vírgula, espaço antes do €. */
export function formatarMoeda(valor: number | string | null | undefined): string | null {
  if (valor === null || valor === undefined || valor === '') return null
  const n = typeof valor === 'string' ? Number(valor) : valor
  if (!Number.isFinite(n)) return null
  const [inteiro, dec] = Math.abs(n).toFixed(2).split('.')
  const comPontos = inteiro.replace(/\B(?=(\d{3})+(?!\d))/g, '.')
  return `${n < 0 ? '-' : ''}${comPontos},${dec} €`
}

/** 'aaaa-mm-dd' → 'dd/mm/aaaa' */
export function formatarData(iso: string | null | undefined): string {
  if (!iso) return ''
  const [a, m, d] = iso.slice(0, 10).split('-')
  return `${d}/${m}/${a}`
}

/** 'aaaa-mm-dd' → nome do mês em português (minúsculas, como na app) */
export function nomeMes(iso: string, variante: VariantePt): string {
  const m = Number(iso.slice(5, 7))
  return MENSAGENS[variante].meses[m - 1] ?? ''
}
