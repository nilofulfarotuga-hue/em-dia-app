// Testes das peças do Worker, sem rede e sem instalar nada.
//   node teste.mjs
import { escolherAnexo, paraBase64, MAX_BYTES } from './src/pecas.js';

let passou = 0, falhou = 0;
function certo(nome, condicao) {
  if (condicao) { passou++; console.log('  ok   ' + nome); }
  else { falhou++; console.log('  FALHA ' + nome); }
}

const pdf = new Uint8Array([0x25, 0x50, 0x44, 0x46, 0x2d, 0x31, 0x2e, 0x34]);  // "%PDF-1.4"

console.log('escolherAnexo');
certo('escolhe o PDF', escolherAnexo([{ mimeType: 'application/pdf', filename: 'f.pdf', content: pdf.buffer }])?.mime === 'application/pdf');
certo('salta a assinatura e apanha o PDF a seguir',
  escolherAnexo([
    { mimeType: 'image/gif', filename: 'assinatura.gif', content: pdf.buffer },
    { mimeType: 'application/pdf', filename: 'fatura.pdf', content: pdf.buffer },
  ])?.nome === 'fatura.pdf');
certo('só um, mesmo com dois bons',
  escolherAnexo([
    { mimeType: 'application/pdf', filename: 'a.pdf', content: pdf.buffer },
    { mimeType: 'application/pdf', filename: 'b.pdf', content: pdf.buffer },
  ])?.nome === 'a.pdf');
certo('sem anexos devolve null', escolherAnexo([]) === null);
certo('sem lista nenhuma devolve null', escolherAnexo(undefined) === null);
certo('anexo vazio nao serve', escolherAnexo([{ mimeType: 'application/pdf', content: new Uint8Array(0) }]) === null);
certo('maiusculas no mime tambem servem',
  escolherAnexo([{ mimeType: 'IMAGE/JPEG', filename: 'foto.jpg', content: pdf.buffer }])?.mime === 'image/jpeg');
certo('sem nome fica "fatura"',
  escolherAnexo([{ mimeType: 'image/png', content: pdf.buffer }])?.nome === 'fatura');
certo('maior que 10 MB nao passa',
  escolherAnexo([{ mimeType: 'application/pdf', content: new Uint8Array(MAX_BYTES + 1) }]) === null);

console.log('paraBase64');
certo('"%PDF-1.4" da JVBERi0xLjQ=', paraBase64(pdf) === 'JVBERi0xLjQ=');
const grande = new Uint8Array(0x8000 * 2 + 5).fill(65);
certo('aguenta mais de 32k de uma vez (sem rebentar a pilha)',
  paraBase64(grande) === Buffer.from(grande).toString('base64'));

console.log(`\n${passou} passaram, ${falhou} falharam`);
process.exit(falhou === 0 ? 0 : 1);
