// As peças do Worker que não precisam de rede nem do runtime da Cloudflare.
// Estão à parte de propósito: assim testam-se com `node teste.mjs`, sem
// instalar o postal-mime nem levantar um Worker.

export const TIPOS_QUE_SERVEM = [
  'application/pdf',
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
];

export const MAX_BYTES = 10 * 1024 * 1024;

/** Uint8Array → base64, aos pedaços (um spread de 10 MB rebenta a pilha). */
export function paraBase64(bytes) {
  let s = '';
  const passo = 0x8000;
  for (let i = 0; i < bytes.length; i += passo) {
    s += String.fromCharCode.apply(null, bytes.subarray(i, i + passo));
  }
  return btoa(s);
}

/**
 * Escolhe UM anexo do e-mail: o primeiro que é PDF ou foto e que cabe.
 *
 * Um por e-mail porque as faturas vêm uma a uma, e guardar tudo enchia o balde
 * de assinaturas e logótipos. Devolve `null` quando nenhum serve — e quem
 * chama escreve na caixa da pessoa a dizer porquê, em vez de deitar fora em
 * silêncio.
 */
export function escolherAnexo(anexos) {
  for (const a of anexos ?? []) {
    const tipo = String(a.mimeType ?? '').toLowerCase();
    if (!TIPOS_QUE_SERVEM.includes(tipo)) continue;
    const bytes = a.content instanceof ArrayBuffer
      ? new Uint8Array(a.content)
      : new Uint8Array(a.content ?? []);
    if (bytes.length === 0 || bytes.length > MAX_BYTES) continue;
    return { nome: a.filename ?? 'fatura', mime: tipo, base64: paraBase64(bytes) };
  }
  return null;
}
