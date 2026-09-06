// Verificador do site público Em Dia — Node ≥ 18, sem dependências.
// Uso: node site/testes/verifica.mjs [URL base]   (por omissão https://em-dia-site.pages.dev)
// Imprime cada asserção e no fim "N asserções passaram / M falharam". Sai com código 1 se alguma falhar.
import vm from 'node:vm';

const BASE = (process.argv[2] || 'https://em-dia-site.pages.dev').replace(/\/$/, '');
const UA = { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0 Safari/537.36' };

let passaram = 0, falharam = 0;
function ok(cond, nome, extra) {
  if (cond) { passaram++; console.log(`  PASSA  ${nome}${extra ? ' — ' + extra : ''}`); }
  else { falharam++; console.log(`  FALHA  ${nome}${extra ? ' — ' + extra : ''}`); }
}
async function get(caminho) {
  const r = await fetch(BASE + caminho, { headers: UA, redirect: 'manual' });
  const buf = Buffer.from(await r.arrayBuffer());
  return { status: r.status, tipo: r.headers.get('content-type') || '', bytes: buf.length, texto: buf.toString('utf8') };
}

console.log(`Verificação de ${BASE} — ${new Date().toISOString()}`);

// 1. Página principal
const pag = await get('/');
ok(pag.status === 200, 'GET / devolve 200', `status ${pag.status}`);
const html = pag.texto;
ok(/<html lang="pt-PT">/.test(html), 'lang="pt-PT"');
const titulo = (html.match(/<title>([^<]+)<\/title>/) || [])[1] || '';
ok(/recibo verde/i.test(titulo) && /Em Dia/.test(titulo), '<title> fala de recibo verde e Em Dia', titulo);
ok(/<h1[^>]*>[\s\S]*?Nunca mais levas multa[\s\S]*?<\/h1>/.test(html), 'H1 «Nunca mais levas multa…»');
ok(pag.bytes < 300 * 1024, 'HTML < 300 KB (sem o vídeo)', `${(pag.bytes / 1024).toFixed(1)} KB`);
ok(/<meta name="description" content="[^"]{80,}"/.test(html), 'meta description com ≥ 80 caracteres');
ok(/<link rel="canonical" href="https:\/\/em-dia-site\.pages\.dev\/">/.test(html), 'canonical');
ok(/property="og:image" content="https:\/\/[^"]+og\.jpg"/.test(html), 'og:image');
ok(/rel="icon"/.test(html) && /apple-touch-icon/.test(html), 'favicon + apple-touch-icon');
ok(!/fonts\.googleapis\.com|fonts\.gstatic\.com|cdn\.jsdelivr|unpkg\.com|cdnjs/.test(html), 'sem Google Fonts nem CDN externa');
ok(/@font-face\{font-family:Inter;src:url\(\/assets\/fonts\/Inter\.woff2\)/.test(html) && /font-display:swap/.test(html), 'Inter local com font-display: swap');

// 2. Dois botões com o MESMO texto/peso
const play = html.match(/<a class="([^"]+)" href="https:\/\/play\.google\.com\/store\/apps\/details\?id=pt\.emdia\.app"[^>]*>[\s\S]*?Descarregar na Play Store[\s\S]*?<\/a>/g) || [];
const web = html.match(/<a class="([^"]+)" href="https:\/\/app-em-dia\.pages\.dev"[^>]*>[\s\S]*?Usar no iPhone\/computador[\s\S]*?<\/a>/g) || [];
ok(play.length >= 1 && web.length >= 1, 'botões «Descarregar na Play Store» e «Usar no iPhone/computador» existem', `${play.length} + ${web.length}`);
const classePlay = (play[0] || '').match(/class="([^"]+)"/)?.[1];
const classeWeb = (web[0] || '').match(/class="([^"]+)"/)?.[1];
ok(classePlay && classePlay === classeWeb, 'os dois botões têm exatamente a mesma classe (mesmo peso)', `${classePlay} = ${classeWeb}`);
ok(play.length === web.length, 'aparecem o mesmo número de vezes (herói + bloco final)', `${play.length} = ${web.length}`);

// 3. Vídeo de herói
const video = (html.match(/<video[^>]*>/) || [])[0] || '';
ok(video !== '', 'existe <video> no herói');
for (const attr of ['muted', 'autoplay', 'playsinline', 'loop']) ok(new RegExp(`\\s${attr}(\\s|>)`).test(video), `video tem ${attr}`);
ok(/poster="\/assets\/video\/heroi-poster\.jpg"/.test(video), 'video tem poster real');
ok(/preload="metadata"/.test(video), 'video preload="metadata"');
ok(/@media\(prefers-reduced-motion:reduce\)\{[^}]*\}[\s\S]*?\.heroi__media video\{display:none\}/.test(html), 'CSS: prefers-reduced-motion pára/esconde o vídeo');
ok(/min-height:100vh;min-height:100svh/.test(html), 'herói com 100vh ANTES de 100svh (webviews)');
const mp4 = await get('/assets/video/heroi.mp4');
ok(mp4.status === 200 && mp4.bytes > 50_000 && mp4.bytes <= 2 * 1024 * 1024, 'heroi.mp4 no ar e ≤ 2 MB', `${(mp4.bytes / 1024).toFixed(0)} KB`);
const poster = await get('/assets/video/heroi-poster.jpg');
ok(poster.status === 200 && poster.tipo.includes('image'), 'poster no ar', `${(poster.bytes / 1024).toFixed(0)} KB`);

// 4. Calculadora presente e função pura correta (C01–C04 de docs/casos-teste.md)
ok(/id="calculadora"/.test(html) && /id="form-recibo"/.test(html) && /id="form-guardar"/.test(html), 'secção da calculadora com os 2 formulários');
ok(/id="r-conta"/.test(html) && /id="r-teu"/.test(html), 'resultados «o que recebes na conta» e «o que é teu»');
// O ano dos escalões é montado em runtime (ano corrente), não cravado — por isso
// a asserção aceita `ano=eq.` seguido do ano ou da interpolação, mas exige o filtro.
ok(/rest\/v1\/regras_legais\?select=chave,valor_num,valor_txt,valor_json/.test(html) && /irs_escaloes\?select=\*&ano=eq\./.test(html), 'lê regras_legais e irs_escaloes em runtime');
const js = await get('/assets/js/calc.js');
ok(js.status === 200, 'calc.js no ar');
let C = null;
try {
  const ctx = { module: { exports: {} }, globalThis: {} };
  ctx.window = undefined;
  vm.runInNewContext(js.texto, ctx);
  C = ctx.module.exports;
} catch (e) { console.log('  (erro a avaliar calc.js: ' + e.message + ')'); }
ok(C && typeof C.calcularRecibo === 'function', 'calc.js expõe calcularRecibo');
if (C) {
  const c1 = C.calcularRecibo(1000, 'padrao', true);
  ok(c1.iva === 0 && c1.retencao === 230 && c1.recebesNaConta === 770 && c1.ficaTeu === 770 && /artigo 53/.test(c1.mencaoIsencao), 'C01 1000 € · 23% · isento → 770 na conta, M10', `${c1.recebesNaConta}`);
  const c2 = C.calcularRecibo(1000, 'vinteCinco', false);
  ok(c2.iva === 230 && c2.totalFatura === 1230 && c2.retencao === 250 && c2.recebesNaConta === 980 && c2.ficaTeu === 750 && c2.mencaoIsencao === null, 'C02 1000 € · 25% · IVA 23% → 980 na conta, 750 teu', `${c2.recebesNaConta} / ${c2.ficaTeu}`);
  const c3 = C.calcularRecibo(500, 'dispensa', true);
  ok(c3.retencao === 0 && c3.recebesNaConta === 500, 'C03 500 € · dispensa → 500', `${c3.recebesNaConta}`);
  const c4 = C.calcularRecibo(1234.56, 'padrao', false);
  ok(c4.iva === 283.95 && c4.retencao === 283.95 && c4.recebesNaConta === 1234.56 && c4.ficaTeu === 950.61, 'C04 1234,56 € → 1234,56 na conta e 950,61 teu', `${c4.recebesNaConta} / ${c4.ficaTeu}`);
  ok(C.moeda(1234.56) === '1.234,56 €' && C.moeda(950.61) === '950,61 €', 'formato 1.234,56 €', C.moeda(1234.56));
  const ss = C.estimarSSMensal(1000, 'servicos');
  ok(ss.contribuicaoMensal === 149.8 && ss.contribuicaoTrimestre === 449.4, 'C10 SS 1.000 €/mês serviços → 149,80 €', `${ss.contribuicaoMensal}`);
  ok(C.estimarSSMensal(100, 'servicos').contribuicaoMensal === 20, 'C13 SS mínimo 20 €');
  ok(C.estimarSSMensal(20000, 'servicos').contribuicaoMensal === 1379.35, 'C15 SS teto 12×IAS → 1.379,35 €');
  const irs = C.calcularIrs(24000, 'servicos', 2026);
  ok(irs.impostoEstimado === 2861.42 && irs.escaloesConfirmados === false, 'C25 IRS 24.000 € 2026 → 2.861,42 € (por confirmar)', `${irs.impostoEstimado}`);
}

// 5. JSON-LD válido
const lds = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)].map(m => { try { return JSON.parse(m[1]); } catch { return null; } });
ok(lds.length === 2 && lds.every(Boolean), 'dois blocos JSON-LD que fazem parse', `${lds.length}`);
ok(lds.some(l => l && l['@type'] === 'SoftwareApplication' && l.name === 'Em Dia' && Array.isArray(l.offers)), 'JSON-LD SoftwareApplication com ofertas');
const faq = lds.find(l => l && l['@type'] === 'FAQPage');
ok(faq && Array.isArray(faq.mainEntity) && faq.mainEntity.length === 6 && faq.mainEntity.every(q => q['@type'] === 'Question' && q.acceptedAnswer?.text), 'JSON-LD FAQPage com 6 perguntas', `${faq?.mainEntity?.length}`);
ok((html.match(/<details>/g) || []).length === 6, '6 <details> na FAQ visível');

// 6. Ficheiros de apoio
const sm = await get('/sitemap.xml');
ok(sm.status === 200 && /<urlset/.test(sm.texto) && /em-dia-site\.pages\.dev\//.test(sm.texto), '/sitemap.xml 200 com urlset', `status ${sm.status}`);
const rb = await get('/robots.txt');
ok(rb.status === 200 && /Sitemap:/.test(rb.texto), '/robots.txt 200 com Sitemap', `status ${rb.status}`);
const nf = await get('/pagina-que-nao-existe-' + Date.now());
ok(nf.status === 404 && /Esta página não existe/.test(nf.texto), 'página inexistente → 404 com a nossa 404.html', `status ${nf.status}`);
// O Cloudflare Pages serve o URL canónico sem .html e redireciona o .html com 308.
// Exigimos as DUAS coisas: o redirect existe e o canónico responde com a página.
// (É o URL canónico que vai na ficha da Play Console.)
const pvh = await get('/privacidade.html');
ok(pvh.status === 308, '/privacidade.html redireciona 308 para o canónico', `status ${pvh.status}`);
const pv = await get('/privacidade');
ok(pv.status === 200 && /Política de privacidade/.test(pv.texto), '/privacidade 200 com a política', `status ${pv.status}`);
const og = await get('/assets/img/og.jpg');
ok(og.status === 200 && og.tipo.includes('image'), 'og.jpg no ar');
const fonte = await get('/assets/fonts/Inter.woff2');
ok(fonte.status === 200 && fonte.bytes < 400 * 1024, 'Inter.woff2 no ar e < 400 KB', `${(fonte.bytes / 1024).toFixed(0)} KB`);
const webps = (html.match(/\/assets\/img\/[a-z_]+\.webp/g) || []);
ok(webps.length >= 6 && /loading="lazy"/.test(html), 'capturas em WebP com lazy loading', `${webps.length}`);

// 7. Acessibilidade e tamanhos
ok(/body\{[^}]*font-size:18px/.test(html), 'corpo ≥ 18 px');
ok(/\.btn\{[^}]*min-height:56px/.test(html), 'botões ≥ 56 px');
ok(/:focus-visible\{outline:3px solid/.test(html), 'foco visível');
ok(/aria-live="polite"/.test(html) && /role="tablist"/.test(html), 'aria-live nos resultados e tablist nos separadores');
ok(/Informação geral\. Não substitui o teu contabilista\./.test(html) && /não substitui contabilista/.test(html), 'aviso «não substitui contabilista»');

// 8. Regras em runtime (a mesma chamada que o browser faz)
try {
  const r = await fetch('https://tgdmgtmknbwhcqoxtjbs.supabase.co/rest/v1/regras_legais?select=chave,valor_num&chave=in.(retencao_padrao,iva_taxa_normal,ss_taxa,preco_pro_mensal)', {
    headers: { apikey: (html.match(/SUPABASE_ANON = '([^']+)'/) || [])[1] || '' }
  });
  const j = r.ok ? await r.json() : [];
  const m = Object.fromEntries(j.map(x => [x.chave, Number(x.valor_num)]));
  ok(r.status === 200 && m.retencao_padrao === 23 && m.iva_taxa_normal === 23 && m.ss_taxa === 21.4 && m.preco_pro_mensal === 3.49, 'REST anónimo a regras_legais devolve 23/23/21,4/3,49', `HTTP ${r.status} ${JSON.stringify(m)}`);
} catch (e) { ok(false, 'REST anónimo a regras_legais', e.message); }

console.log(`\n${passaram} asserções passaram / ${falharam} falharam`);
process.exit(falharam ? 1 : 0);
