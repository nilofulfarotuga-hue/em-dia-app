// admin-apagar-conta (B7, 2026-09-18): apagar a conta de uma pessoa, a sério.
//
// Só um admin com JWT chama isto. Faz, por esta ordem:
//   1. simula (public.admin_apagar_conta_simular) — quantas linhas e ficheiros
//      vão embora; com { "simular": true } fica-se por aqui e devolve-se isso.
//   2. apaga os ficheiros do Storage da pessoa (buckets comprovativos e faturas,
//      pasta <user_id>/…) pela API do Storage com a service role — apagar as
//      linhas de storage.objects por SQL deixava os ficheiros órfãos no disco.
//   3. apaga em auth.users (auth.admin.deleteUser): as tabelas públicas têm
//      ON DELETE CASCADE (conversas_ia e tickets ficam anónimos: SET NULL).
//   4. regista em admin_audit_log (acao usuario_apagado, com os números).
//
// Travas: nunca apaga um admin, nunca apaga o próprio, nunca apaga sem motivo.
// Porta de QA: o header x-cron-secret só serve para SIMULAR (nunca apaga).
import { json, preflight } from '../_shared/cors.ts'
import { clienteAdmin, clienteUtilizador, lerSegredo } from '../_shared/segredos.ts'

const BUCKETS = ['comprovativos', 'faturas']

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return preflight()
  if (req.method !== 'POST') return json({ erro: 'metodo_nao_permitido' }, 405)

  const admin = clienteAdmin()

  let corpo: { user_id?: string; motivo?: string; simular?: boolean } = {}
  try { corpo = await req.json() } catch { /* sem corpo */ }
  const alvo = (corpo.user_id ?? '').trim()
  const motivo = (corpo.motivo ?? '').trim()
  const simular = corpo.simular === true
  if (!/^[0-9a-f-]{36}$/i.test(alvo)) return json({ erro: 'user_id_invalido' }, 400)

  // ---------- quem chama ----------
  let quem: 'admin' | 'qa' | null = null
  let adminId: string | null = null
  const segredoRecebido = req.headers.get('x-cron-secret')
  if (segredoRecebido) {
    const segredoEsperado = await lerSegredo('cron_secret', admin)
    if (segredoEsperado && segredoRecebido === segredoEsperado) quem = 'qa'
  }
  if (!quem && req.headers.get('Authorization')) {
    const supaUser = clienteUtilizador(req)
    const { data: { user } } = await supaUser.auth.getUser()
    if (user) {
      const { data: ehAdmin } = await supaUser.rpc('is_admin')
      if (ehAdmin === true) {
        quem = 'admin'
        adminId = user.id
      }
    }
  }
  if (!quem) return json({ erro: 'nao_autorizado', mensagem: 'Só um admin pode apagar contas.' }, 401)
  if (quem === 'qa' && !simular) return json({ erro: 'qa_so_simula', mensagem: 'A porta de QA só simula; apagar exige um admin com sessão.' }, 403)

  // ---------- 1. simular ----------
  const { data: sim, error: erroSim } = await admin.rpc('admin_apagar_conta_simular', { p_user_id: alvo })
  if (erroSim) return json({ erro: 'simulacao_falhou', mensagem: erroSim.message }, 500)
  const s = sim as { existe: boolean; eh_admin: boolean; email: string | null; linhas: Record<string, number>; ficheiros_storage: number; ficheiros_por_bucket: Record<string, number> }
  if (!s.existe) return json({ erro: 'nao_existe', simulacao: s }, 404)
  if (s.eh_admin) return json({ erro: 'e_admin', mensagem: 'Um admin não se apaga por aqui: tira-o primeiro de public.admins.', simulacao: s }, 403)
  if (adminId && adminId === alvo) return json({ erro: 'a_propria_conta', mensagem: 'Não apagas a tua própria conta a partir do painel.', simulacao: s }, 403)
  if (simular) return json({ ok: true, simulado: true, simulacao: s })
  if (motivo.length < 3) return json({ erro: 'falta_motivo', mensagem: 'Escreve o motivo (fica na auditoria).', simulacao: s }, 400)

  // ---------- 2. ficheiros ----------
  const ficheirosApagados: Record<string, number> = {}
  for (const bucket of BUCKETS) {
    const { data: lista, error: erroLista } = await admin.storage.from(bucket).list(alvo, { limit: 1000 })
    if (erroLista) {
      // Bucket sem pasta da pessoa dá lista vazia, não erro; erro a sério pára tudo.
      return json({ erro: 'storage_listar_falhou', bucket, mensagem: erroLista.message }, 500)
    }
    const caminhos = (lista ?? []).filter((f) => f.name && f.id).map((f) => `${alvo}/${f.name}`)
    if (caminhos.length > 0) {
      const { error: erroRemover } = await admin.storage.from(bucket).remove(caminhos)
      if (erroRemover) return json({ erro: 'storage_apagar_falhou', bucket, mensagem: erroRemover.message }, 500)
    }
    ficheirosApagados[bucket] = caminhos.length
  }

  // ---------- 3. a conta ----------
  const { error: erroAuth } = await admin.auth.admin.deleteUser(alvo)
  if (erroAuth) return json({ erro: 'auth_apagar_falhou', mensagem: erroAuth.message, ficheiros_apagados: ficheirosApagados }, 500)

  // ---------- 4. auditoria ----------
  const { error: erroAudit } = await admin.from('admin_audit_log').insert({
    admin_id: adminId,
    acao: 'usuario_apagado',
    alvo_tipo: 'auth.users',
    alvo_id: alvo,
    antes: { email: s.email, linhas: s.linhas, ficheiros: s.ficheiros_por_bucket },
    depois: { motivo, ficheiros_apagados: ficheirosApagados },
  })
  if (erroAudit) console.error('auditoria falhou:', erroAudit.message)

  return json({ ok: true, apagado: true, user_id: alvo, email: s.email, linhas: s.linhas, ficheiros_apagados: ficheirosApagados })
})
