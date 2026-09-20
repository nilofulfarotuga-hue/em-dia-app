import { assertEquals } from 'jsr:@std/assert@1'
import { calcularGooglePlay, formatarMoedaPt, parseCsv } from './_core.ts'

Deno.test('parseCsv respeita aspas e vírgulas dentro de aspas', () => {
  const linhas = parseCsv('Transaction Type,Product Title,Amount (Merchant Currency)\nCharge,"Plano Pro, mensal",10.00\n')
  assertEquals(linhas, [
    ['Transaction Type', 'Product Title', 'Amount (Merchant Currency)'],
    ['Charge', 'Plano Pro, mensal', '10.00'],
  ])
})

Deno.test('calcularGooglePlay soma bruto, comissão, IVA, reembolsos e líquido', () => {
  const csv = [
    'Transaction Type,Product Title,Merchant Currency,Amount (Merchant Currency)',
    'Charge,"Plano Pro, mensal",EUR,10.00',
    'Charge,Plano Família,EUR,20.50',
    'Google fee,"Taxa, Google",EUR,-1.50',
    'Google fee,Taxa Google,EUR,-3.00',
    'Tax,IVA,EUR,2.30',
    'Tax,IVA,EUR,4.70',
    'Charge refund,Reembolso cliente,EUR,-5.00',
    'Google fee refund,Devolução taxa Google,EUR,0.75',
  ].join('\n')

  // À mão: bruto 10.00 + 20.50 = 30.50; comissão -1.50 + -3.00 = -4.50;
  // IVA 2.30 + 4.70 = 7.00; reembolsos -5.00 + 0.75 = -4.25;
  // líquido = 30.50 + -4.50 + -4.25 = 21.75. O IVA não entra no líquido.
  assertEquals(calcularGooglePlay(csv), {
    moeda: 'EUR',
    bruto: 30.5,
    comissao: -4.5,
    iva: 7,
    reembolsos: -4.25,
    liquido: 21.75,
    transacoes: 2,
    estado: 'ok',
    motivo: null,
  })
})

Deno.test('formatarMoedaPt usa formato português com duas casas', () => {
  assertEquals(formatarMoedaPt(1234.56), '1.234,56 €')
  assertEquals(formatarMoedaPt(-4.5), '-4,50 €')
})
