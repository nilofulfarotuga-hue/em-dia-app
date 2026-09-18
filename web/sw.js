/*
  Service worker do Em Dia (B6 — PWA, 2026-09-18).

  O que faz, por palavras: guarda no telemóvel os ficheiros de que a app
  precisa para abrir (a página, o main.dart.js, o CanvasKit, os tipos de letra,
  os assets) e, quando não há rede, entrega-os do que guardou. Com rede, a
  página e o código vêm sempre frescos da rede — o guardado é só a rede de
  segurança. Os pedidos ao Supabase, ao Turnstile e a outras origens passam
  intactos: não se guardam nem se inventam.

  Como se guarda: não há lista fixa de ficheiros (envelhecia a cada versão do
  Flutter). Depois do primeiro ecrã, a página manda a lista do que ela própria
  foi buscar (mensagem `guardar`), e o worker copia isso para a cache — do HTTP
  cache do browser quando lá está, sem descarregar de novo. Na visita seguinte,
  o que passar por aqui vai sendo atualizado à medida que é pedido.

  Versão: o CI carimba __VERSAO__ com o commit (build_web_deploy.yml). Worker
  novo → cache nova → a antiga é apagada ao ativar.
*/
'use strict';

const VERSAO = '__VERSAO__';
const CACHE = 'em-dia-' + VERSAO;

// O mínimo para a página abrir sem rede; o resto chega pela mensagem `guardar`.
const CONCHA = ['/', 'flutter_bootstrap.js', 'manifest.json', 'favicon.png', 'icons/Icon-192.png', 'icons/Icon-512.png'];

// Ficheiros que mudam a cada versão e NÃO têm o nome carimbado: com rede
// vêm sempre da rede; sem rede, do guardado.
const REDE_PRIMEIRO = /\/(flutter_bootstrap\.js|main\.dart\.js|manifest\.json|version\.json|versao\.json|index\.html)$/;

const CANVASKIT = 'https://www.gstatic.com/flutter-canvaskit/';

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    // Um a um e tolerante: um ficheiro em falta não pode impedir o worker de
    // instalar (foi o que matou o service worker do Bora em 2025).
    await Promise.allSettled(CONCHA.map((u) => cache.add(new Request(u, { cache: 'reload' }))));
    await self.skipWaiting();
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const nomes = await caches.keys();
    await Promise.all(nomes.filter((n) => n.startsWith('em-dia-') && n !== CACHE).map((n) => caches.delete(n)));
    await self.clients.claim();
  })());
});

self.addEventListener('message', (event) => {
  const d = event.data || {};
  if (d.tipo !== 'guardar' || !Array.isArray(d.urls)) return;
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    let guardados = 0;
    for (const url of d.urls) {
      try {
        if (!ehNossa(url)) continue;
        if (await cache.match(url)) continue;
        // `force-cache`: se o browser já o tem no HTTP cache, não volta à rede.
        const resp = await fetch(url, { cache: 'force-cache', mode: url.startsWith(CANVASKIT) ? 'cors' : 'same-origin' });
        if (resp && resp.ok) {
          await cache.put(url, resp);
          guardados++;
        }
      } catch (e) {
        // Sem rede a meio: fica para a próxima vez.
      }
    }
    const janelas = await self.clients.matchAll({ type: 'window' });
    janelas.forEach((c) => c.postMessage({ tipo: 'guardado', quantos: guardados, total: d.urls.length, versao: VERSAO }));
  })());
});

function ehNossa(url) {
  return url.startsWith(self.location.origin + '/') || url.startsWith(CANVASKIT);
}

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = req.url;
  if (!ehNossa(url)) return; // Supabase, Turnstile, Google: passam intactos
  if (url.includes('/sw.js')) return;

  if (req.mode === 'navigate') {
    event.respondWith(redePrimeiro(req, '/'));
    return;
  }
  if (REDE_PRIMEIRO.test(new URL(url).pathname)) {
    event.respondWith(redePrimeiro(req));
    return;
  }
  // CanvasKit (nome carimbado pelo Flutter), assets, tipos de letra, ícones:
  // do guardado se lá estiver, senão da rede — e guarda-se para a próxima.
  event.respondWith(cachePrimeiro(req));
});

async function redePrimeiro(req, alternativa) {
  const cache = await caches.open(CACHE);
  try {
    const resp = await fetch(req);
    if (resp && resp.ok) cache.put(req, resp.clone()).catch(() => {});
    return resp;
  } catch (e) {
    const guardado = (await cache.match(req)) || (alternativa && (await cache.match(alternativa)));
    if (guardado) return guardado;
    throw e;
  }
}

async function cachePrimeiro(req) {
  const cache = await caches.open(CACHE);
  const guardado = await cache.match(req);
  if (guardado) return guardado;
  const resp = await fetch(req);
  if (resp && resp.ok) cache.put(req, resp.clone()).catch(() => {});
  return resp;
}
