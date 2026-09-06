// Worker de e-mail: a porta de entrada da caixa de correio das faturas (D24).
//
// A Cloudflare recebe o e-mail no domínio das contas com UMA regra catch-all
// que aponta para este Worker. O Worker abre o e-mail, tira o primeiro anexo
// que serve, e entrega tudo à Edge Function `receber-fatura` do Supabase, que
// é quem sabe de quem é a caixa e onde guardar.
//
// Porquê catch-all e não uma regra por pessoa: o Email Routing da Cloudflare
// aceita 200 regras por domínio. Com catch-all, o endereço de uma pessoa passa
// a existir no momento em que o gravamos na NOSSA base de dados — sem tecto.
//
// O que este Worker NÃO faz: não guarda nada, não lê nada, não decide nada.
// Se a Edge Function disser que a caixa não existe (404), o e-mail é DEVOLVIDO
// a quem o mandou. Aceitar em silêncio um e-mail que ninguém vai ler é mentir
// a quem o enviou.
import PostalMime from 'postal-mime';
import { escolherAnexo } from './pecas.js';

export default {
  async email(message, env, _ctx) {
    let correio;
    try {
      correio = await PostalMime.parse(message.raw);
    } catch {
      // Um e-mail que não se abre não se aceita em silêncio.
      message.setReject('Não consegui abrir este e-mail.');
      return;
    }

    const anexo = escolherAnexo(correio.attachments);

    const resposta = await fetch(`${env.SUPABASE_URL}/functions/v1/receber-fatura`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-correio-secret': env.CORREIO_SECRET,
      },
      body: JSON.stringify({
        para: message.to,
        de: correio.from?.address ?? message.from,
        assunto: correio.subject ?? '',
        recebido_em: new Date().toISOString(),
        anexos: anexo ? [anexo] : [],
      }),
    });

    if (resposta.status === 404) {
      // Caixa que não existe: devolve-se, para quem mandou saber que não chegou.
      message.setReject('Esse endereço não existe.');
      return;
    }
    if (!resposta.ok) {
      // Erro nosso: não se devolve o e-mail (a culpa não é de quem o mandou).
      // Fica no registo do Worker; devolver ensinava o remetente a desistir de
      // um endereço que está bom.
      console.error('receber-fatura respondeu', resposta.status, await resposta.text());
    }
  },
};
