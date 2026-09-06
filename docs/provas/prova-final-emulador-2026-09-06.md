# PROVA FINAL NO ANDROID — instala, pede código, recebe o e-mail, entra, faz o onboarding e vê o painel (6 de setembro de 2026, 22h15)

> A ordem do Danilo: "cria um AVD com imagem que traga a Play Store, 4 GB, instala o
> Em Dia, pede código, lê o código na Resend, escreve-o, faz o onboarding e chega ao
> painel. Grava com `adb -e shell screenrecord`… Essa é a prova final que fecha
> MISSAO-CONCLUIDA." Está feita. Vídeo e 18 fotogramas em
> `docs/provas/entrada-emulador-2026-09-06/`.

## O aparelho

| Peça | Valor |
|---|---|
| PC | Ryzen 7 170, 13,7 GB de RAM, WHPX ligado |
| AVD | `emdia` — Pixel 6, `system-images;android-34;google_apis_playstore;x86_64` (Android 14 com Play Store), `hw.ramSize=4096`, 1080×2400 a 420 dpi (411 dp de largura, o mesmo desenho da web) |
| `adb devices` | `emulator-5554 device` |
| A app | **AAB `em-dia-1.0.0+28.aab` guardado pelo CI como artifact** (run `a6b0064`, o mesmo ficheiro que subiu para os tracks `internal` e `alpha`), convertido em APK universal com `bundletool 1.17.2` e **assinado com a chave de release** do cofre local (`em-dia-release.jks`). `package="pt.emdia.app" versionCode="28" versionName="1.0.0"`. `adb -e install` → `Success`. |

**Porque não pela Play Store do emulador:** entrar na Play Store exige escrever a
palavra-passe da conta Google — uma das coisas que as travas desta sessão não deixam
um agente fazer, com ou sem autorização (D44). O ficheiro é o mesmo, a assinatura é a
mesma, o `versionCode` é o mesmo; só o caminho de download é outro.

## O percurso, gravado dentro do aparelho (`nohup screenrecord … &`)

`entrada-emulador-ate-ao-painel.mp4` — **4 min 29 s**, três segmentos seguidos
(`seg1` instalação → código pedido, `seg2` código → simulação, `seg3` guia → painel).
Conta nova: `boraappbora+emulador3@gmail.com`.

| # | Fotograma | O que se vê |
|---|---|---|
| 01 | `01-instalado.png` | ecrã inicial do Android depois do `adb install` |
| 02 | `02-entrada.png` | "Entra com o teu e-mail" |
| 03 | `03-email.png` | e-mail escrito |
| 04 | `04-turnstile.png` | o invisível não deu token em 20 s → aparece a caixa **"Verify you are human"** e a frase "Não consegui confirmar que não és um robô. Tenta outra vez." (a rede de segurança do commit `2a63b8d` a funcionar no Android) |
| 05 | `05-turnstile-caixa.png` | caixa tocada → **"Success!"** → botão verde |
| 06 | `06-codigo-pedido.png` | seis casinhas do código: o servidor aceitou o pedido **com token** |
| — | Resend | id **`6a8d21bb-b013-4e54-b73d-03711a4d0c38`**, `2026-09-06 21:14:40Z`, para `boraappbora+emulador3@gmail.com`, **`delivered`**; código **177998** lido no texto do e-mail |
| 07 | `07-onboarding-boas-vindas.png` | código aceite → "Olá! Eu sou o Em Dia… 4 perguntas rápidas" |
| 08–13 | `08-q1` … `13-q5` | O que fazes? (Motorista TVDE) · Quando abriste atividade? (março 2026) · IVA (não) · Tens carro? (não) · Quanto ganhas? (1.200 €) |
| 14 | `14-simulacao.png` | "Pronto. Este mês não tens nada a pagar… Nos próximos 30 dias tens tudo aberto, sem cartão." |
| 15–17 | `15-guia-1` … `17-guia-3` | o guia de 3 ecrãs — o terceiro toque já não dá cinzento |
| 18 | `18-painel.png` | **PAINEL**: "Olá! Estás em dia? · Mês grátis até 06/10 · O QUE FAZER AGORA: Valida as tuas faturas no e-fatura, até 25 de fevereiro de 2027 · Está tudo em dia · Este mês pagas: nada · Guardar para o IRS 0,00 €" |

A primeira passagem à mão (conta `boraappbora+emulador`, código 894380, Resend
`9d5c3874…` delivered às 20:57:01Z) chegou ao mesmo painel e está em
`primeira-passagem/` (16 fotografias + o vídeo do fim, `q5-ate-painel.mp4`); as três
gravações lançadas do PC nessa passagem morreram ao fechar o stdin — por isso a
passagem gravada foi refeita de raiz com a gravação dentro do aparelho.

## O que isto prova, e o que não prova

- **Prova:** uma pessoa nova, no Android, com a build da Play interna, entra com
  e-mail + código (com o Turnstile ligado no servidor), faz o onboarding e vê o painel.
  Ferramenta reproduzível: `bash tool/provas/emulador_entrada.sh <apk> <email> <pasta>`.
- **Não prova:** o download pela Play Store (precisa da palavra-passe da conta Google no
  emulador). Quando o Danilo abrir o link do teste interno no telemóvel dele, é a mesma
  build que aqui — `versionCode` 28 ou o que estiver no track nessa altura.
