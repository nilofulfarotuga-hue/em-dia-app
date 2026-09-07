// Frente do Em Dia em boraguarda.com (D46, 2026-09-07).
//
// Porquê um Worker e não um CNAME: os três projetos Pages já têm os domínios
// personalizados registados (emdia., app.emdia., admin.emdia.boraguarda.com),
// mas a Cloudflare só os liga quando existir o CNAME — e nenhum token que
// temos escreve DNS na zona (403). Um Worker com "custom_domain" cria o
// registo DNS e o certificado sozinho, com os direitos de Workers que o token
// tem. O Worker limita-se a ir buscar a página ao projeto Pages certo e a
// devolvê-la tal e qual: cabeçalhos (noindex, X-Robots-Tag), estado, corpo.
// No dia em que houver um token com DNS, troca-se por CNAME e apaga-se isto.
const PARA = {
  'emdia.boraguarda.com': 'em-dia-site.pages.dev',
  'app.emdia.boraguarda.com': 'app-em-dia.pages.dev',
  'admin.emdia.boraguarda.com': 'em-dia-admin.pages.dev',
};

export default {
  async fetch(pedido) {
    const url = new URL(pedido.url);
    const origem = PARA[url.hostname];
    if (!origem) return new Response('Em Dia — endereço desconhecido.', { status: 404 });
    url.hostname = origem;
    const cabecalhos = new Headers(pedido.headers);
    cabecalhos.delete('host');
    const resposta = await fetch(url.toString(), {
      method: pedido.method,
      headers: cabecalhos,
      body: pedido.method === 'GET' || pedido.method === 'HEAD' ? undefined : pedido.body,
      redirect: 'manual',
    });
    // Um redirect da própria Pages (ex.: /privacidade.html → /privacidade) tem
    // de voltar com o nosso nome de anfitrião, senão a pessoa cai no pages.dev.
    const loc = resposta.headers.get('location');
    if (loc && loc.includes(origem)) {
      const novos = new Headers(resposta.headers);
      novos.set('location', loc.replace(origem, pedido.headers.get('host') || url.hostname));
      return new Response(resposta.body, { status: resposta.status, headers: novos });
    }
    return resposta;
  },
};
