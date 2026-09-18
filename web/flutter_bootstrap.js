/*
  Arranque da app na web (B6 — PWA, 2026-09-18).

  Isto é o MODELO do flutter_bootstrap.js: o `flutter build web` substitui os
  dois marcadores em baixo pelo carregador do Flutter e pela configuração da
  build, e serve o resultado como flutter_bootstrap.js. Ter o modelo à mão
  serve para uma coisa: chamar o carregador SEM `serviceWorkerSettings`.

  Porquê: o service worker que o Flutter 3.47 gera (flutter_service_worker.js)
  é um resto deprecado que se desregista a si próprio ao ativar e manda a página
  recarregar (flutter/flutter#156910). Com ele registado, a app nunca abre sem
  rede — foi o que o Bloco 0 mediu («sem service worker»). O nosso é o sw.js,
  registado aqui em baixo depois do primeiro ecrã, para não roubar rede ao
  arranque.
*/
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({});

(function () {
  if (!('serviceWorker' in navigator)) return;
  // Só em https (ou localhost): noutro sítio o registo é recusado e suja a consola.
  if (location.protocol !== 'https:' && location.hostname !== 'localhost') return;

  // O motor do Flutter dispara `flutter-first-frame` na janela quando desenha
  // o primeiro ecrã. Só depois disso é que se manda guardar ficheiros — o
  // arranque tem prioridade.
  var primeiroFrame = new Promise(function (resolve) {
    if (window.__emDiaPrimeiroFrame) return resolve();
    window.addEventListener('flutter-first-frame', function () {
      window.__emDiaPrimeiroFrame = Date.now();
      resolve();
    }, { once: true });
    // Rede de segurança: se o evento nunca vier (motor antigo), 15 s.
    setTimeout(resolve, 15000);
  });
  window.addEventListener('flutter-first-frame', function () {
    window.__emDiaPrimeiroFrame = window.__emDiaPrimeiroFrame || Date.now();
  }, { once: true });

  function urlsCarregadas() {
    // Tudo o que esta página foi buscar: main.dart.js, CanvasKit (gstatic),
    // tipos de letra, assets. É esta lista que o sw.js guarda para a próxima
    // vez sem rede — sem lista fixa que envelhece a cada versão do Flutter.
    var propria = location.origin + '/';
    return performance.getEntriesByType('resource')
      .map(function (e) { return e.name; })
      .filter(function (u) {
        return (u.indexOf(propria) === 0 && u.indexOf('/sw.js') < 0)
          || u.indexOf('https://www.gstatic.com/flutter-canvaskit/') === 0;
      });
  }

  // O worker responde `guardado` com quantos ficheiros copiou — fica na janela
  // para a prova (tool/provas/pwa_prova.py) e para quem depurar na consola.
  navigator.serviceWorker.addEventListener('message', function (e) {
    if (e.data && e.data.tipo === 'guardado') window.__emDiaSwGuardou = e.data;
  });

  window.addEventListener('load', function () {
    navigator.serviceWorker.register('sw.js', { scope: '/' }).then(function () {
      return Promise.all([navigator.serviceWorker.ready, primeiroFrame]);
    }).then(function (r) {
      var reg = r[0];
      // 1,5 s depois do primeiro ecrã: dá tempo aos tipos de letra e aos
      // últimos assets de chegarem, e depois guarda-se tudo de uma vez.
      setTimeout(function () {
        var alvo = reg.active || navigator.serviceWorker.controller;
        if (!alvo) return;
        alvo.postMessage({ tipo: 'guardar', urls: urlsCarregadas() });
        window.__emDiaSwPediuGuardar = Date.now();
      }, 1500);
    }).catch(function (e) {
      console.warn('Em Dia: service worker não registado —', e);
    });
  });
})();
