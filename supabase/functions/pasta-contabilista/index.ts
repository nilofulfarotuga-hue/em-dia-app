// Edge Function: pasta-contabilista (B3, 2026-09-18)
//
// «Pasta do contabilista»: todo o dia 1 (cron `em-dia-pasta-contabilista-mes`)
// a app junta o MÊS ANTERIOR de cada pessoa que ligou o interruptor
// (`profiles.pasta_contabilista_ativa` + `contabilista_email`) — o que entrou,
// o que saiu, o extrato importado, as faturas recebidas e as faturas-recibo
// emitidas — em CSV (UTF-8 com BOM, separador «;», números com vírgula, para
// o Excel português abrir à primeira) e envia por e-mail (Resend) ao
// contabilista. O Danilo pediu exatamente isto a 06/08 para o Bora: o
// empresário não substitui o contabilista, poupa-lhe as horas de juntar papéis.
//
// Dois modos:
//   · cron (x-cron-secret): todas as pessoas com a pasta ligada, mês anterior;
//   · `{"modo":"agora"}` com o JWT da pessoa: só ela, mês anterior, já.
// Cada envio fica em `pastas_contabilista` (user_id + mês únicos) para nunca
// mandar duas vezes o mesmo mês pelo cron; «agora» reenvia (é a pessoa a pedir).
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador, lerSegredo } from '../_shared/segredos.ts'
import type { SupabaseClient } from 'jsr:@supabase/supabase-js@2'

const REMETENTE = 'Em Dia <emdia@boraguarda.com>'
const MESES = ['janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', 'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro']

function mesAnterior(agora = new Date()): { inicio: string; fim: string; rotulo: string; mesIso: string } {
  const a = agora.getUTCFullYear()
  const m = agora.getUTCMonth() // 0-11 = mês atual
  const ini = new Date(Date.UTC(m === 0 ? a - 1 : a, m === 0 ? 11 : m - 1, 1))
  const fim = new Date(Date.UTC(a, m, 0)) // último dia do mês anterior
  const iso = (d: Date) => d.toISOString().slice(0, 10)
  return { inicio: iso(ini), fim: iso(fim), rotulo: `${MESES[ini.getUTCMonth()]} de ${ini.getUTCFullYear()}`, mesIso: iso(ini) }
}

// CSV à portuguesa: «;», vírgula decimal, aspas quando preciso, BOM para o Excel.
function csv(cabecalho: string[], linhas: unknown[][]): string {
  const cel = (v: unknown): string => {
    if (v === null || v === undefined) return ''
    if (typeof v === 'number') return v.toFixed(2).replace('.', ',')
    const s = String(v)
    return /[;"\n\r]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s
  }
  return '﻿' + [cabecalho, ...linhas].map((l) => l.map(cel).join(';')).join('\r\n') + '\r\n'
}

function b64(s: string): string {
  const bytes = new TextEncoder().encode(s)
  let bin = ''
  for (const b of bytes) bin += String.fromCharCode(b)
  return btoa(bin)
}

const n = (v: unknown): number => (v === null || v === undefined ? 0 : Number(v))

async function montarPasta(admin: SupabaseClient, userId: string, inicio: string, fim: string) {
  const [entradas, pagamentos, movimentos, faturas, recibos] = await Promise.all([
    admin.from('entradas').select('data, valor, tipo, plataforma, descricao, conta_para_irs').eq('user_id', userId).gte('data', inicio).lte('data', fim).order('data', { ascending: true }),
    admin.from('saidas_pagamentos').select('data_limite, valor, estado, pago_em, saidas(nome, categoria, fornecedor)').eq('user_id', userId).gte('data_limite', inicio).lte('data_limite', fim).order('data_limite', { ascending: true }),
    admin.from('movimentos_banco').select('data, descricao, valor, categoria, fornecedor, recorrente').eq('user_id', userId).gte('data', inicio).lte('data', fim).order('data', { ascending: true }),
    admin.from('faturas_recebidas').select('recebido_em, remetente, assunto, estado, anexo_nome').eq('user_id', userId).gte('recebido_em', inicio).lte('recebido_em', fim + 'T23:59:59Z').order('recebido_em', { ascending: true }),
    admin.from('recibos_emitidos').select('data, numero, cliente_nome, cliente_nif, descricao, valor, isento, retencao_pct, estado, pdf_url').eq('user_id', userId).gte('data', inicio).lte('data', fim).order('data', { ascending: true }),
  ])
  const e = (entradas.data ?? []) as Record<string, unknown>[]
  const p = (pagamentos.data ?? []) as Record<string, any>[]
  const m = (movimentos.data ?? []) as Record<string, unknown>[]
  const f = (faturas.data ?? []) as Record<string, unknown>[]
  const rc = (recibos.data ?? []) as Record<string, unknown>[]

  const ficheiros = [
    { filename: 'entrou.csv', content: b64(csv(['data', 'valor', 'tipo', 'plataforma', 'descricao', 'conta_para_irs'], e.map((x) => [x.data, n(x.valor), x.tipo, x.plataforma, x.descricao, x.conta_para_irs ? 'sim' : 'não']))) },
    { filename: 'saiu.csv', content: b64(csv(['data_limite', 'conta', 'categoria', 'fornecedor', 'valor', 'estado', 'pago_em'], p.map((x) => [x.data_limite, x.saidas?.nome, x.saidas?.categoria, x.saidas?.fornecedor, n(x.valor), x.estado, x.pago_em]))) },
    { filename: 'extrato.csv', content: b64(csv(['data', 'descricao', 'valor', 'categoria', 'fornecedor', 'repete'], m.map((x) => [x.data, x.descricao, n(x.valor), x.categoria, x.fornecedor, x.recorrente ? 'sim' : 'não']))) },
    { filename: 'faturas_recebidas.csv', content: b64(csv(['recebido_em', 'remetente', 'assunto', 'estado', 'anexo'], f.map((x) => [x.recebido_em, x.remetente, x.assunto, x.estado, x.anexo_nome]))) },
    { filename: 'faturas_recibo_emitidas.csv', content: b64(csv(['data', 'numero', 'cliente', 'nif', 'descricao', 'valor', 'isento_iva', 'retencao_pct', 'estado', 'pdf'], rc.map((x) => [x.data, x.numero, x.cliente_nome, x.cliente_nif, x.descricao, n(x.valor), x.isento ? 'sim' : 'não', n(x.retencao_pct), x.estado, x.pdf_url]))) },
  ]
  const totalEntrou = e.reduce((t, x) => t + n(x.valor), 0)
  const totalSaiu = p.filter((x) => x.estado === 'pago').reduce((t, x) => t + n(x.valor), 0)
  return {
    ficheiros,
    itens: { entradas: e.length, saidas: p.length, extrato: m.length, faturas: f.length, recibos: rc.length },
    totalEntrou,
    totalSaiu,
  }
}

async function enviar(chave: string, para: string, assunto: string, texto: string, attachments: { filename: string; content: string }[]) {
  const resp = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${chave}` },
    body: JSON.stringify({ from: REMETENTE, to: [para], subject: assunto, text: texto, attachments }),
  })
  return { ok: resp.status >= 200 && resp.status < 300, detalhe: `HTTP ${resp.status}: ${(await resp.text()).slice(0, 300)}` }
}

async function pastaDe(admin: SupabaseClient, chave: string | null, perfil: Record<string, any>, agora: Date, forcar: boolean) {
  const { inicio, fim, rotulo, mesIso } = mesAnterior(agora)
  const para = String(perfil.contabilista_email ?? '').trim()
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]{2,}$/.test(para)) return { ok: false, motivo: 'sem_email' }
  // Já foi? (só o cron respeita; «agora» é a pessoa a pedir de novo)
  if (!forcar) {
    const { data: ja } = await admin.from('pastas_contabilista').select('id, estado').eq('user_id', perfil.user_id).eq('mes', mesIso).maybeSingle()
    if (ja && ja.estado === 'enviada') return { ok: true, motivo: 'ja_enviada', para }
  }
  const pasta = await montarPasta(admin, perfil.user_id, inicio, fim)
  const nome = String(perfil.nome ?? '').trim() || 'cliente Em Dia'
  const assunto = `Pasta de ${rotulo} — ${nome} (Em Dia)`
  const texto = [
    `Olá,`,
    ``,
    `Segue a pasta de ${rotulo} de ${nome}, montada pela app Em Dia.`,
    `Entrou: ${pasta.totalEntrou.toFixed(2).replace('.', ',')} € (${pasta.itens.entradas} linhas) · Saiu (pago): ${pasta.totalSaiu.toFixed(2).replace('.', ',')} € (${pasta.itens.saidas} contas).`,
    `Extrato: ${pasta.itens.extrato} movimentos · Faturas recebidas: ${pasta.itens.faturas} · Faturas-recibo emitidas: ${pasta.itens.recibos}.`,
    ``,
    `Em anexo: entrou.csv, saiu.csv, extrato.csv, faturas_recebidas.csv, faturas_recibo_emitidas.csv (separador «;», Excel português).`,
    ``,
    `Isto é o que a pessoa escreveu ou importou na app; não substitui a contabilidade. Dúvidas: responde a este e-mail.`,
    `— Em Dia · emdia.boraguarda.com`,
  ].join('\n')

  const registo = {
    user_id: perfil.user_id,
    mes: mesIso,
    para_email: para,
    itens: pasta.itens,
    estado: 'a_enviar',
    erro: null as string | null,
    enviado_em: null as string | null,
  }
  if (!chave) {
    await admin.from('pastas_contabilista').upsert({ ...registo, estado: 'erro', erro: 'sem_resend_api_key' }, { onConflict: 'user_id,mes' })
    return { ok: false, motivo: 'sem_resend_api_key', para, itens: pasta.itens }
  }
  const r = await enviar(chave, para, assunto, texto, pasta.ficheiros)
  await admin.from('pastas_contabilista').upsert(
    { ...registo, estado: r.ok ? 'enviada' : 'erro', erro: r.ok ? null : r.detalhe, enviado_em: r.ok ? new Date().toISOString() : null },
    { onConflict: 'user_id,mes' },
  )
  return { ok: r.ok, motivo: r.ok ? 'enviada' : r.detalhe, para, itens: pasta.itens, mes: rotulo }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido' }, 405)

  const admin = clienteAdmin()
  let corpo: Record<string, unknown> = {}
  try {
    corpo = (await req.json()) as Record<string, unknown>
  } catch {
    corpo = {}
  }
  const chave = await lerSegredo('resend_api_key', admin)
  const agora = new Date()

  // Modo cron: todas as pessoas com a pasta ligada.
  const segredo = req.headers.get('x-cron-secret')
  if (segredo) {
    const esperado = await lerSegredo('cron_secret', admin)
    if (!esperado || segredo !== esperado) return json({ erro: 'segredo_errado' }, 401)
    // Porta de QA (como nas outras funções): `user_id` no corpo faz só essa pessoa, com «agora».
    const uid = typeof corpo.user_id === 'string' && /^[0-9a-f-]{36}$/i.test(corpo.user_id) ? corpo.user_id : null
    let q = admin.from('profiles').select('user_id, nome, contabilista_email, pasta_contabilista_ativa')
    q = uid ? q.eq('user_id', uid) : q.eq('pasta_contabilista_ativa', true)
    const { data: perfis, error } = await q
    if (error) return json({ erro: 'perfis', detalhe: error.message }, 500)
    const resultados = []
    for (const p of perfis ?? []) {
      try {
        resultados.push({ user_id: p.user_id, ...(await pastaDe(admin, chave, p, agora, uid !== null)) })
      } catch (e) {
        resultados.push({ user_id: p.user_id, ok: false, motivo: String(e).slice(0, 200) })
      }
    }
    return json({ ok: true, pessoas: resultados.length, enviadas: resultados.filter((r) => r.ok && r.motivo === 'enviada').length, resultados })
  }

  // Modo «agora»: a própria pessoa, com o JWT.
  const supaUser = clienteUtilizador(req)
  const { data: { user } } = await supaUser.auth.getUser()
  if (!user) return json({ erro: 'sem_sessao' }, 401)
  const { data: perfil } = await admin.from('profiles').select('user_id, nome, contabilista_email, pasta_contabilista_ativa').eq('user_id', user.id).maybeSingle()
  if (!perfil) return json({ erro: 'sem_perfil' }, 404)
  const r = await pastaDe(admin, chave, perfil, agora, true)
  if (!r.ok) return json({ erro: r.motivo, para: r.para ?? null, itens: r.itens ?? null }, r.motivo === 'sem_email' ? 400 : 502)
  return json({ ok: true, para: r.para, itens: r.itens, mes: r.mes })
})
