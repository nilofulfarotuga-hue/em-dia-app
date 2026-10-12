/* Conta de onde veio quem abriu o site (?de=<origem>) — 12/10/2026, missão em-dia-medir-cliques.
   Só a origem entra na base (RPC registar_origem); nada que identifique a pessoa.
   A chave é a "publishable" do Em Dia: pública por desenho (a RPC só deixa inserir a origem). */
(function () {
  try {
    var de = (new URLSearchParams(location.search).get('de') || '').trim().toLowerCase();
    if (!/^[a-z0-9_-]{2,24}$/.test(de)) return;

    // Links para a app levam a origem de quem chegou (senão ficam com o fixo da página).
    var cta = function () {
      var as = document.querySelectorAll('a[href^="https://app.emdia.boraguarda.com/"]');
      for (var i = 0; i < as.length; i++) {
        try {
          var u = new URL(as[i].href);
          u.searchParams.set('de', de);
          as[i].href = u.toString();
        } catch (e) {}
      }
    };
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', cta);
    else cta();

    // Robôs e pré-visualizações não contam.
    var ua = navigator.userAgent || '';
    if (navigator.webdriver || /bot|crawler|spider|facebookexternalhit|Facebot|preview/i.test(ua)) return;

    // Uma vez por visita, para cada origem.
    var chave = 'emdia.origem.' + de;
    try {
      if (sessionStorage.getItem(chave)) return;
      sessionStorage.setItem(chave, '1');
    } catch (e) {}

    fetch('https://tgdmgtmknbwhcqoxtjbs.supabase.co/rest/v1/rpc/registar_origem', {
      method: 'POST',
      keepalive: true,
      headers: { apikey: 'sb_publishable_xosxjre3zsX-S90KcMsDuw_TxyCV53V', 'Content-Type': 'application/json' },
      body: JSON.stringify({ p_de: de })
    }).catch(function () {});
  } catch (e) {}
})();
