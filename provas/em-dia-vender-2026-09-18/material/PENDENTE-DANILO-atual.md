# PENDENTE-DANILO — só o que precisa mesmo da pessoa

## 🔴 Missão em-dia-vender (18–21/09/2026) — UMA coisa só é tua
1. **Aceitar o contrato de pagamentos da Google** (Play Console → Definições → Perfil de pagamentos → «Criar perfil de
   pagamentos»; eu deixo o formulário preenchido — nome e morada como no CC/Finanças, código postal 6300-610 — e paro no
   botão «Enviar»; se pedirem identidade, é o teu documento). Sem isto não há produtos de assinatura nem produção. Tudo o
   resto (produtos, papéis, ficha, fecho de mês) já está feito ou fica pronto sem ti.

### Não é teu — é da próxima sessão com o Chrome (fica aqui só para ninguém perguntar)
- Ler o id do bucket dos relatórios financeiros na Play Console e guardá-lo no Vault (`play_relatorios_bucket`); pôr o
  JSON da conta de serviço no Vault (`play_service_account`); dar-lhe «Ver dados financeiros». Sem isto o fecho de mês
  escreve «sem extrato» — e está certo escrever isso.
- Colar as respostas de `docs/PLAY-FICHA-RESPOSTAS.md` nas 6 tarefas da consola (classificação, público-alvo, etc.).


## 🔴 Missão em-dia-tudo (18/09/2026) — uma sentada só, no fim; cada linha é UM clique teu

Tudo o resto desta missão foi decidido e feito sem ti (docs/DECISOES.md, D47 a D73).
Estas ficam porque a regra diz que criar contas, assinar e declarar são actos teus.
Nenhuma trava a app: sem elas, o botão correspondente não aparece.

- **Conta de teste na web (uma vez só):** corre `python tool/provas/web_percorrer.py --entrar` — abre um Chromium visível já na app; escreve o e-mail `boraappbora+teste@gmail.com`, marca a caixa «Confirme que é humano», envia, escreve o código (chega ao boraappbora) e faz o onboarding como tu (TVDE, janeiro de 2024, isento, sem carro, 1.200 €). A sessão fica em `C:\BoraLocal\_segredos\em-dia\sessao-teste.json` (fora do repo) e as corridas seguintes entram com a conta sem caixa. A tua conta real fica intocada.
- **InvoiceXpress (fatura-recibo de dentro da app):** cria a conta em `https://web.invoicexpress.com/signup` (grátis para começar), vai a Conta → API e copia o **nome da conta** e a **chave API**. Depois, no SQL do Supabase (projeto em-dia):
  `select vault.create_secret('<NOME-DA-CONTA>', 'invoicexpress_account'); select vault.create_secret('<CHAVE>', 'invoicexpress_api_key');`
  e liga o interruptor: `update feature_flags set pro = true, familia = true where chave = 'faturacao_certificada';` (ou no painel admin). Antes de ligar para clientes reais: uma fatura de 1 € a ti próprio, para ver o PDF.
