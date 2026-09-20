# B4b + B6 — Na app: aviso «não é aconselhamento fiscal», ligações aos papéis, suporte com prazo e caminho para humano — 2026-09-20

> Missão `em-dia-vender-2026-09-18`. Fecha o Bloco 4 (com o B4a) e o Bloco 6 (suporte/reembolsos).

## Quem fez o quê
- **ChatGPT Plus (gpt-5.5, opencode)**, `delegar.ps1 chatgpt … -Id b4b-b6-app -MaxMin 35` (lançado solto): 22 ficheiros,
  +334/−36. A tentativa 1 escreveu tudo, correu merge + gen-l10n + analyze e ficou presa nos 7 ficheiros de goldens
  (TIMEOUT 35 min); a tentativa 2 foi parada por mim aos 2 min e o diff tirado da cópia isolada.
- **Claude Code (checker)**: reviu o diff; 3 goldens vermelhos → 2 arranjos de teste (a linha dos termos no Plano fica
  abaixo da dobra: `scrollUntilVisible`; o e-mail aparece 2× no ecrã de Ajuda: `findsAtLeastNWidgets(1)`) e 1 arranjo de
  código (`ListTile` dentro de `Cartao` precisa de `Material` transparente — aviso do Flutter que fazia falhar o teste).

## O que ficou
- `lib/widgets/widgets.dart`: `AvisoNaoFiscal` (Key `aviso_nao_fiscal`, com `Semantics`) no fim de recibos, cofre,
  vale a pena, reforma e prova de rendimento. Texto `avisoNaoFiscal` PT/BR.
- `lib/config/ligacoes.dart`: `urlTermos`, `urlPrivacidade`, `urlReclamacoes`, `urlApagarConta`, `emailSuporte`.
- Ajuda (`SuporteScreen`): aviso «Respondemos em 2 dias úteis…» + botão de e-mail (`suporte_email`, mailto com assunto),
  cartão «Os nossos papéis» (termos, privacidade, reclamações → site), «Recebi. Respondo em breve» → «Recebemos.
  Respondemos em 2 dias úteis, aqui em «Os meus pedidos»», estados dos pedidos «Recebido / A tratar / Respondido».
- Reembolso: linha 4 «Assinaste há menos de 14 dias? Devolvemos tudo…» + botão «Escrever-nos» (`suporte_reembolso_email`).
- Plano: «Ao assinares aceitas os termos. Cancelas quando quiseres na Google Play. Tens 14 dias para desistir…» + botão
  «Termos e condições» (`plano_termos`). `compras.dart` não mudou.

## Provas literais (checker, 2026-09-20 21:4x–21:5x)
```
flutter analyze --no-fatal-infos → 1 issue found (anonKey, pré-existente)
flutter test test/golden/suporte_test.dart test/golden/plano_test.dart test/golden/recibos_test.dart
  1.ª: 00:27 +9 -3 (plano_termos fora do ecrã; e-mail 2×; ListTile em DecoratedBox)
  depois dos arranjos: suporte 00:12 +4: All tests passed!  (plano e recibos já tinham passado: +10)
flutter test cofre_e_radar reforma vale_e_fala caixa_e_prova → 00:45 +39: All tests passed!
```
Saída do motor: `b4b-b6-saida-chatgpt.txt`.
