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

## O que falta ver na consola (só por captura, quando o Chrome estiver livre)

1. Ficha da loja (o que a API não mostra): categoria, etiquetas, e-mail/URL de contacto, política de privacidade.
2. Segurança dos Dados (Data Safety): o que está declarado hoje vs. o que a app passou a recolher (extratos, fotos de faturas, localização aproximada).
3. Classificação etária (questionário IARC) e declaração de anúncios.
4. Perfil de pagamentos: estado (a 06/09 ficou no botão «Enviar» do contrato — o clique é dele), nome/morada.
5. Validação de programador Android: `pt.emdia.app` registado?
6. Produtos: confirmar na consola o que a API já disse (nenhuma subscrição).

## Decisão de trabalho

A parte da consola que precisa de capturas espera pelo Chrome livre; entretanto avançam os blocos que não precisam
de navegador (papéis legais, fecho de mês, funil, ecrã dos planos), com o GLM a escrever e o Claude Code a verificar.
