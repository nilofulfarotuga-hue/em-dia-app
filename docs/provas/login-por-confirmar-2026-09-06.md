> **ERRADO — ver `login-provado-2026-09-06.md`.** Os e-mails apareciam na Resend (delivered) e chegaram à caixa; o que falhava era a minha leitura dos registos, não o envio. Fica aqui só como cicatriz.

# POR CONFIRMAR — o pedido de código responde 200 e o e-mail não aparece

> Escrito no fecho da missão, 6 de setembro de 2026, 19h15. **Isto não está
> resolvido.** Fica aqui em vez de ficar por dizer, porque é a porta de entrada
> da app e um "deve estar bom" aqui não vale nada.

## O que fiz

Quis fechar a missão com uma prova ao vivo: entrar na app publicada
(`app-em-dia.pages.dev`), ir ao separador novo "A minha vida" e fotografá-lo a
funcionar com dados a sério. A app abriu, o ecrã de entrada apareceu **sem um
único erro na consola**, escrevi o e-mail e pedi o código.

## O que aconteceu

O servidor respondeu **200** e a app passou para o ecrã das seis casinhas do
código — ou seja, do lado dela correu tudo bem. Mas:

| Pedido | Hora (UTC) | Resposta do GoTrue | Chegou à Resend? | Chegou à caixa? |
|---|---|---|---|---|
| `nilofulfarotuga@gmail.com` | ~17:52 | 200 | **não aparece** | não |
| `boraappbora@gmail.com` | ~17:55 | 200 | **não aparece** | não |
| `boraappbora+provafinal@gmail.com` | 17:58:34 | 200 | **não aparece** | não |
| `joao.silva@gmail.com` (inventado) | 17:58 | 200 | **sim — devolvido** | — |

O último é o que torna isto estranho: **um e-mail do mesmo minuto, para um
endereço inventado, aparece no registo da Resend.** Os três para endereços a
sério, não.

## O que já verifiquei, para não andar a adivinhar

- **Registos de autenticação do Supabase, das 17:00 às 19:00:** os `500` das
  travas novas aparecem todos com a razão escrita, e os `200` também. **Não há
  um único erro de SMTP nem de limite de envios.** O GoTrue diz que correu bem.
- **Não é a trava nova.** Os três endereços são convidados
  (`boraappbora@gmail.com` está em `emails_convidados`, e o `+provafinal` conta
  pela caixa base). Se fossem travados, davam `500` com `registo_fechado`, como
  o `maria.ferreira@gmail.com` deu.
- **O SMTP funciona.** Às 17h58 saiu mesmo um e-mail (o do endereço inventado).

## As duas hipóteses que ficam, e como se distinguem

1. **Limite de envios por hora.** Hoje foram feitos dezenas de pedidos de código
   (por mim e por outra sessão a testar ao mesmo tempo — vê-se um `/verify` às
   17:56:37 que não é meu). Se o tecto foi atingido, o GoTrue pode responder 200
   e não mandar. **Como se confirma:** ver o limite em Authentication → Rate
   Limits na consola do Supabase, e tentar outra vez daqui a uma hora com a
   consola aberta.
2. **Atraso do registo da Resend e da caixa do Gmail.** Menos provável — o
   e-mail do endereço inventado, do mesmo minuto, apareceu logo.

## O que NÃO se pode concluir daqui

**Não se pode dizer que o login está partido.** Ele foi provado a funcionar
ponta a ponta hoje mesmo, às 16h45, com o código a chegar e a conta a entrar
(está em `docs/MARCOS.md`). O que se pode dizer é isto, e só isto: **às 19h de
hoje, três pedidos seguidos responderam 200 e o e-mail não apareceu, e eu não
sei porquê.**

## O primeiro passo de quem pegar nisto

Com a consola do Supabase aberta em Authentication → Rate Limits, fazer **um**
pedido de código para `boraappbora+<hoje>@gmail.com` e ver, ao mesmo tempo, o
registo da Resend. Se o limite estiver a zero, é a hipótese 1 e resolve-se
subindo o tecto (o SMTP é nosso, da Resend, não o do Supabase). Se o e-mail
aparecer, era atraso, e fecha-se esta página.
