# BLOCO 2 — as funcionalidades que faltavam (a–g) · 2026-09-18

Cada alínea fecha com saída literal. Linhas no `e2e_log` (projeto `ojykpzwqrtusfeakzrna`, run `em-dia-tudo-2026-09-17`):
2019 (b2a), 2020 (b2c), 2021 (b2d), 2024 (b2e), 2029 (b2f), 2030 (b2g), 2031 (b2b).

## a) Importar o extrato do banco (CSV/XLSX, no telemóvel; nada de SMS/Gmail/banco por dentro)
- Código: `lib/regras/extrato_banco.dart` (reconhece banco, separador, colunas Débito/Crédito, datas PT, categoriza com 57 regras seed), `lib/services/extrato_excel.dart`, `lib/stores/banco_store.dart`, ecrã `lib/screens/vida/importar_extrato_screen.dart`.
- BD: migração `20260918_0032_extrato_banco_e_recorrentes.sql` (tabelas `movimentos_banco` unique `user_id+chave`, `importacoes_extrato`, `categorias_regras`, `operadores_cancelar`; RLS dono + admin).
- Prova: `flutter test test/unit/extrato_banco_test.dart` → `+11: All tests passed!` (E01–E11: BOM/Latin-1, `;` e `,`, "Data valor" não é valor, Débito+Crédito, repetidos ignorados). Golden `vida_banco_test` 3/3.
- Enable Banking (ligação direta ao banco): **não agora**. Verificado a 18/09 em `enablebanking.com/docs/api/reference/#certificate-upload-and-application-registration`: sandbox grátis e automática; **produção só depois de "contractual formalities"** (contacto comercial) e a página de preços não existe (`/pricing` → 404). Zero euros novos e D23 (sem banco por dentro) mantêm-se: ficheiro pela mão da pessoa.

## b) Fatura-recibo certificada (InvoiceXpress) — código pronto, atrás de interruptor
- Edge Function `emitir-recibo` **v2 ACTIVE** (`updated_at 1789722868106`), ficheiro `supabase/functions/emitir-recibo/index.ts` (Deno `check` limpo). API verificada em `invoicexpress.com/api-v2`: `POST invoice_receipts.json`, `PUT …/change-state.json {state: finalized}`, `GET api/pdf/{id}.json` (202 enquanto gera), código de isenção **M10** (regime de isenção, art. 53.º) da tabela oficial do apêndice.
- Migração `20260918_0035_faturacao_certificada.sql` aplicada: flag `faturacao_certificada` **free=false, pro=false, familia=false** (SELECT: `{"chave":"faturacao_certificada","free":false,"pro":false,"familia":false}`), tabela `recibos_emitidos` (RLS: dono e admin leem; escreve só o servidor).
- Prova da função, chamada de dentro da BD por `pg_net` (o segredo do cron nunca saiu do Vault), respostas em `net._http_response`:
  - id 297 `{"modo":"estado"}` → **200** `{"ligada":false,"tem_conta":false}`
  - id 298 `{"modo":"emitir", …}` → **403** `{"erro":"desligada"}`
  - id 299 segredo errado → **401** `{"erro":"sem_sessao"}`
  - sem `Authorization` → **401** `UNAUTHORIZED_NO_AUTH_HEADER` (gateway)
- App: `PlanoStore.ligadaParaAlguem` (três planos a false = desligada para todos, trial incluído); ecrã `EmitirReciboScreen` (nome, NIF com dígito de controlo, o que fizeste, valor, retenção 23 % da regra `retencao_padrao`, nota do IVA pelo perfil); cartão em Recibos só com o interruptor ligado. Golden `recibos_emitir_test` → `+4: All tests passed!` (fotos `recibos_passar_fatura_{pequeno,medio,grande}_{pt,pt_BR}.png`; `recibos_sem_fatura_medio_pt.png` prova que o cartão NÃO aparece desligado).
- Fora o «captura em breve» do ecrã "Como emitir o recibo" (chave `emitirCapturaBreve` apagada).
- **Para o Danilo (sentada única):** criar a conta InvoiceXpress e pôr `invoicexpress_account` e `invoicexpress_api_key` no Vault; depois ligar a flag no admin. Sem isso ninguém vê o botão — não há "em breve" no ecrã.

## c) O que se repete + como cancelar + aviso 1 dia antes
- `encontrarRecorrentes(minimoMeses: 2, toleranciaPct: 15)` em `extrato_banco.dart`; ecrã `recorrentes_screen.dart` («Pagas X por mês em coisas que se repetem»), «Como cancelar» por operador (`operadores_cancelar`: MEO 16200, NOS 16990, Vodafone 16912, EDP, Galp, Netflix, Spotify, Disney+, HBO, Amazon, YouTube, Google, Apple, ginásios, genérico) e «Avisa-me antes» que cria a conta em `saidas` (débito direto, dia do mês) — o aviso da véspera é o das contas (`avisoEm`).
- Prova: golden `vida_recorrentes_*` 3/3; e2e 2020.

## d) Cofre do imposto automático
- `lib/regras/cofre_automatico.dart` (`fatiaParaOCofre`: SS 21,4 % × 70 % fora da isenção + IRS pela taxa efetiva anual); `CofreStore.reservarPorEntrada` (não repete por `entrada_id`, nota `auto`); interruptor `profiles.cofre_automatico` (migração 0033, default true) no ecrã do cofre; frase «já tens X guardado dos Y que vais precisar em [mês]».
- Prova: `test/unit/cofre_automatico_test.dart` A01–A05 verdes; e2e 2021.

## e) Centros de inspeção + combustível DGEG (ligado, fonte à vista)
- API DGEG `PesquisarPostos?qtdPorPagina=99999` → **HTTP 200 sem chave**; sync corrida a sério: `{"ligada":true,"gravou":true,"postos":3133,"precos":14157}`; cron `em-dia-precos-combustivel-dia` `10 5 * * *` ativo.
- Migração 0034: RPCs `postos_perto`, `centros_perto`, `combustiveis_disponiveis`, `centro_do_municipio`. RPC real na Guarda: `PLENERGY Guarda Gare I 2,035 €/L a 2,7 km`; centro `CIMA – GUARDA a 2,0 km`.
- Ecrã «Perto de mim» (separador Carro): localização só ao tocar, em primeiro plano, nunca guardada; alternativa por concelho; toque abre o Google Maps. Permissões Android `ACCESS_COARSE/FINE_LOCATION` (nunca background). Golden 3/3; commit `d052e22`; e2e 2024.
- **Para o Danilo:** a Segurança dos Dados na Play passa a declarar «Localização aproximada, só em primeiro plano, não partilhada»; o pedido formal à DGEG continua por assinar (minuta em `docs/loja/dgeg/`).

## f) Modo exemplo «Vê como fica»
- `lib/exemplo/`: `DadosExemplo` (a Maria, TVDE, 1.200 €/mês, carro AB-12-CD, 6 meses, mês em curso, contas, cofre automático, fidelizações, 3 meses de extrato, perto de mim) — **as obrigações saem do gerador a sério** (`gerarObrigacoes`) e a fatia do cofre da regra real; stores sem servidor (ler não vai à rede; gravar avisa «Num exemplo nada fica guardado» e segue); `ExemploScreen` = `ShellScreen` embrulhada, faixa laranja fixa com «Sair», navegador próprio para os ecrãs de dentro continuarem a ver as stores de exemplo, recuar fecha primeiro os de dentro.
- Entradas: ecrã de login («Ainda não tens a certeza? Espreita a app cheia antes de criar conta») e «Ver um exemplo» em Mais (escondido dentro do exemplo).
- Prova: `flutter test test/golden/exemplo_test.dart` → `+4: All tests passed!` (fotos `exemplo_painel_*`, `exemplo_vida_medio_pt`, `exemplo_carro_medio_pt`); painel da Maria mostra «Paga a Segurança Social 179,76 € — Dia 20 é domingo: tens até segunda, dia 21». Commit `762a89a`; e2e 2029.
- Achado de caminho: as abas «A minha vida» e «Calendário» partiam em duas linhas no telemóvel médio (390 px) e desalinhavam os ícones → «Dinheiro» (título «O meu dinheiro») e «Agenda». Suite golden inteira `+117: All tests passed!`.

## g) PDF da prova de rendimento e «vale a pena esta corrida»
- `test/unit/prova_pdf_test.dart` G01–G04 gera o PDF a sério: 12 meses fechados (set/2025→ago/2026, o mês em curso fica de fora), média 1.175,00 €, `%PDF-`…`%%EOF`, **Inter embebida** (`/BaseFont/Inter-Regular`, `/FontFile2`), ficheiro `provas/em-dia-tudo-2026-09-17/prova-rendimento-12m.pdf`.
- Defeito apanhado pelo teste: com 12 meses saíam **2 páginas**, a segunda só com «De onde vem» (pymupdf: `paginas 2`, `/Count 2`). Espaços 18→14 pt e linhas 8→6 pt → `paginas 1`. Commit `fe0a2cc`.
- «Vale a pena»: VP01–VP12 calculados à mão (10 €/10 km → combustível 1,05, desgaste 0,50, SS 1,50, IRS 2,30, sobra 4,65 €; VP12 prova que a fatia da SS é a mesma da conta trimestral) → verdes; goldens `vale_e_fala` e `caixa_e_prova` verdes. e2e 2030.

## Estado dos testes no fecho do bloco
`flutter analyze --no-fatal-infos` → 1 issue (aviso `anonKey` deprecado, pré-existente) · `flutter test test/unit` → `+134` (+4 G01–G04 = 138) · `flutter test test/golden` → `+117` (+4 exemplo, +4 recibos_emitir).
