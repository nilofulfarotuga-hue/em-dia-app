# B0 — Estado real na Google Play (2026-09-19, 00:00–00:10)

> Missão `em-dia-vender-2026-09-18`. Regra do bloco: «a Play Console é compilada e o texto da página mente —
> confirma por captura, nunca por leitura de texto». Aqui há duas fontes: a **API Android Publisher** (números
> exactos, lidos pela conta de serviço) e a **Play Console pelo Chrome** (perfil Bora, conta boraappbora@gmail.com).

## O que a API diz (tool/play/api.py, conta de serviço, edição aberta e descartada — nada foi alterado)

```
track internal    : release "1.0.0" completed, versionCode 39  ← a build do último push da missão anterior (30ede37)
track alpha       : (sem releases)
track beta        : (sem releases)
track production  : (sem releases)  ← o Em Dia NÃO está em produção
listagens         : pt-PT "Em Dia: Recibos e Impostos" (curta 80 chars, longa 1751 chars)
                    pt-BR "Em Dia: Impostos em Portugal" (longa 1757 chars)
imagens pt-PT     : ícone 1, gráfico de destaque 1, capturas de telemóvel 8
subscrições       : NENHUMA  ← os 4 produtos (Pro 3,49/29,90; Família 5,99/49,90) ainda não existem na Play
```

## O que a Play Console mostrou pelo Chrome (perfil Bora, conta confirmada no ecrã: boraappbora@gmail.com → «Bora App Guarda»)

- Conta de programador **Bora App Guarda**, id `5372142912736686834`, «Conta pessoal», **2 aplicações** (Bora App e Em Dia).
- Captura da escolha de conta e da página inicial: feita às 00:02 (a primeira captura funcionou; depois o separador
  ficou numa janela em segundo plano — o Danilo estava a usar o Chrome, janelas «App Store Connect» e «A Minha
  Área» — e a Play Console (AngularDart) deixa de desenhar: `Cannot take screenshot with 0 width`, a armadilha já
  registada na skill contas-e-navegadores). As capturas dos ecrãs seguintes ficam para quando o Chrome estiver livre.
- **Aviso na caixa de notificações (8/09), lido do painel:** «Certifique-se de que as suas apps estão registadas para
  a **validação de programador do Android até 30 de setembro de 2026**. As apps do Play não registadas vão ser
  removidas do Play globalmente.» → há uma página «Validação de programadores Android» no menu; tem de se confirmar
  que `pt.emdia.app` está registado (entra no B3/B8 como portão).
- Notificação (18/09): «Atualização da app publicada» é do **Bora App** (produção), não do Em Dia.

## O que a Play Console mostrou pelo Chrome, 00:12–00:20 (separador trazido à frente por pesquisa de separadores, com o Danilo parado há mais de 6 min; devolvido ao «App Store Connect» no fim)

Visto no ecrã (capturas feitas pela extensão; o `save_to_disk` não devolveu caminho, por isso o que fica é o que li nas capturas):

- **Página inicial**: Bora App (`pt.boraapp.bora`) → Produção, 49 utilizadores; **Em Dia: Recibos e Impostos (`pt.emdia.app`) → «Rascunho · Testes internos», 0 utilizadores**.
- **Painel de controlo do Em Dia** (app id `4973228433822861554`): «App de rascunho», nome temporário «pt.emdia.app (unreviewed)», **Produção: Inativo**. Checklist «Conclua a configuração da app»: **5 de 11 concluídas** — feitas: Política de Privacidade, Detalhes de início de sessão, Anúncios, Segurança dos dados, Ficha da loja; **por fazer: Classificação de conteúdo, Público-alvo, Apps governamentais, Funcionalidades financeiras, Saúde, Categoria + detalhes de contacto.**
- **Segurança dos dados**: preenchida (✓ no painel); o formulário tem 5 passos e só se lê passo a passo — a atualização (extratos, fotos de faturas, localização aproximada) fica para o B3.
- **Validação de programadores Android**: `pt.boraapp.bora` **Registada** (1 chave, 20/05/2026) e `pt.emdia.app` **Registada** (3 chaves, 6/09/2026) → o aviso de 30/09 está cumprido. Identidade: «Danilo FULFARO DA SILVA, R. do Torreão 14, Guarda - 6300-610, Portugal».
- **Conta de programador**: pessoal, id 5372142912736686834, nome «Bora App Guarda», proprietário boraappbora@gmail.com; nome legal e morada como acima (a morada **não tem andar** — é o ponto que a Apple chumbou; confirmar com o cartão de cidadão é do Danilo).
- **Definições → Perfil de pagamentos: «Crie um perfil de pagamentos para começar» — NÃO HÁ perfil de pagamentos ligado à conta.** Ao carregar em «Criar perfil de pagamentos» aparece o seletor com o perfil individual já existente «Danilo FULFARO DA SILVA — Perfil do Individual para Play — ID 6137-6414-7724» e a opção de criar outro. O passo de 06/09 (formulário + «Enviar» = aceitar o contrato) **não ficou gravado**. Sem este perfil não se criam subscrições (B2) — é o clique legal do Danilo, e o único que a missão lhe deixa.
- Definições tem também «Taxas de imposto» (por país) e «Teste da licença» (contas de teste para compras) — entram no B2.

## Conclusões do B0 para os blocos seguintes

1. Ordem obrigatória do B8 confirmada: perfil de pagamentos (clique dele) → produtos (B2) → papéis (B4) → produção.
2. B3 tem 6 tarefas por fazer na consola, todas declarações (classificação etária, público-alvo, governamental, financeiras, saúde, categoria/contactos).
3. Não há subscrições nem perfil de pagamentos: os preços da app (3,49/29,90/5,99/49,90) só existem em `regras_legais`.
4. A extensão só desenha a consola quando o separador está à frente; as capturas fazem-se com o Danilo parado (pesquisa de separadores) e devolve-se o separador dele no fim.

## O que ainda falta ver por captura (fica para o B3, na mesma sessão do Chrome)

1. Ficha da loja (o que a API não mostra): categoria, etiquetas, e-mail/URL de contacto, política de privacidade.
2. Segurança dos Dados (Data Safety): o que está declarado hoje vs. o que a app passou a recolher (extratos, fotos de faturas, localização aproximada).
3. Classificação etária (questionário IARC) e declaração de anúncios.
4. Perfil de pagamentos: estado (a 06/09 ficou no botão «Enviar» do contrato — o clique é dele), nome/morada.
5. Validação de programador Android: `pt.emdia.app` registado?
6. Produtos: confirmar na consola o que a API já disse (nenhuma subscrição).

## Decisão de trabalho

A parte da consola que precisa de capturas espera pelo Chrome livre; entretanto avançam os blocos que não precisam
de navegador (papéis legais, fecho de mês, funil, ecrã dos planos), com o GLM a escrever e o Claude Code a verificar.
