# Play Console — instruções do revisor guardadas; perfil de pagamentos preenchido até ao contrato (6 de setembro de 2026, 22h45)

## 1. Detalhes de início de sessão (o antigo "Acesso à app") — GUARDADO

Página: Política e programas → Conteúdo da app → **Detalhes de início de sessão**.

- "Alguma parte da sua app está restrita?" → **Sim**.
- "Adicione detalhes" → caixa "Adicionar detalhes de início de sessão" preenchida:
  - Nome: `Google reviewer account`
  - Nome de utilizador: `revisor.google@boraguarda.com`
  - Palavra-passe: a de `C:\BoraLocal\_segredos\em-dia\revisor.env` (a conta existe no servidor, e-mail confirmado, entra por `POST /token?grant_type=password` — provado com 200)
  - Outras informações (a Google exige inglês): *"This account signs in with a password: type the e-mail on the sign-in screen and a password field appears (only for this e-mail). Every other account signs in with a 6-digit code sent by e-mail. Cloudflare Turnstile runs invisibly; if a checkbox appears, just tap it. No purchase is needed to review: the 30-day free period unlocks every feature."*
  - Caixa "Os detalhes de início de sessão nesta declaração dão acesso total…" marcada.
- "Adicionar" → a tabela mostra a linha **"Google reviewer account — Nome de utilizador/número de telefone, palavra-passe, instruções"**.
- **"Guardar"** → mensagem da consola: **"Alteração guardada. Envie-a para verificação na Vista geral da publicação."** (a caixa "Aceder à Vista geral da publicação?" foi fechada com "Agora não"; o envio para revisão é o passo do lançamento, não deste bloco).

Como se fez: a consola é AngularDart e não aceita valores postos por JavaScript nem
cliques sintéticos. O que funcionou: pôr o separador visível (a janela do Chrome estava
minimizada; `ShowWindow` + pesquisa de separadores Ctrl+Shift+A) e usar cliques e teclado
verdadeiros. As duas tentativas anteriores (JS e `form_input`) deixavam o botão "Guardar"
cinzento — está registado na memória do agente para não se repetir.

## 2. Perfil de pagamentos — preenchido até ao "Enviar"

Página: Definições → **Perfil de pagamentos** → "Criar perfil de pagamentos" → escolha do
perfil existente **"Danilo FULFARO DA SILVA — Perfil do Individual para Play — ID
6137-6414-7724"** (a decisão do Danilo: individual, em nome dele, Portugal).

O que ficou preenchido no formulário (tudo o que não é banco nem fisco):

| Campo | Valor |
|---|---|
| Tipo de conta | Individual (já vinha do perfil) |
| Nome e endereço | Danilo FULFARO DA SILVA, R. do Torreão 14, 6300-610 Guarda, Portugal (já vinha do perfil) |
| Informações públicas da empresa | "Usar o nome, o contacto e o endereço que constam nas informações legais" ✔ |
| Designação comercial | `Em Dia` |
| Website | `https://em-dia-site.pages.dev` |
| O que vende | `Software informático` |
| Email de Apoio ao cliente | `boraappbora@gmail.com` |
| Nome apresentado no extrato do cartão de crédito | `EM DIA` |

**Parou no botão "Enviar"**, de propósito: o texto por cima diz "Ao continuar, afiança e
garante que tem autoridade legal total para vincular o indivíduo ao Contrato de
Distribuição para Programadores do Google Play… aceita os Termos de Utilização do Google
Payments". Aceitar um contrato é assinatura da pessoa. O NIF e o IBAN vêm a seguir a esse
clique. O separador ficou aberto exactamente aí.
