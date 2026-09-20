# Tarefa B2 (parte sem dinheiro) — página de preços no site, a ler os preços da tabela `regras_legais`

Projeto «Em Dia». Site estático em `site/` (publicado em https://emdia.boraguarda.com). `site/index.html` já tem uma
calculadora que lê `regras_legais` por REST anónimo da Supabase — copia exatamente esse padrão (URL, chave anónima,
cabeçalhos, tratamento de erro) para ler as chaves `preco_pro_mensal`, `preco_pro_anual`, `preco_familia_mensal`,
`preco_familia_anual` (coluna `valor_num`, euros). `site/privacidade.html` é o modelo de estilo. PT-PT, «tu», simples.

## `site/precos.html`
- Título «Preços» + uma frase: «Grátis 30 dias. Depois escolhes.» (o trial de 30 dias vem do servidor —
  `profiles.trial_ate`).
- Três cartões lado a lado (em telemóvel empilham): **Grátis** (o que tem: calculadora, agenda com 3 avisos, 1 carro,
  5 perguntas por mês — confirma os limites em `lib/screens/plano/plano_screen.dart` / l10n `planoLim*`; se não
  bateres certo, escreve o que a app diz), **Pro** (tudo aberto: avisos sem limite, carros sem limite, perguntas à IA,
  fotos de faturas, exportar, prova de rendimento, reforma — confirma em `planoAbre*`), **Família/Frota** (Pro para até
  5 pessoas/carros — confirma na descrição da regra `preco_familia_mensal`).
- Em cada cartão pago: preço mensal e anual **lidos da tabela** (mostra «—» enquanto carrega e «preço na app» se a
  leitura falhar), formato `3,49 €/mês` e `29,90 €/ano` com «(poupas X %)» calculado; frase «1.º mês grátis na Google
  Play»; botão «Assinar na app» que leva a `https://play.google.com/store/apps/details?id=pt.emdia.app`.
- Por baixo: «Como cancelar» (Google Play → Pagamentos e subscrições → Subscrições; ficas até ao fim do período pago),
  «Desistir em 14 dias» (link para `/termos`), «No iPhone ou computador» (usa `app.emdia.boraguarda.com` no grátis; a
  assinatura compra-se num Android — escreve isto claramente, sem prometer iOS), FAQ com 4 perguntas (é seguro? posso
  mudar de plano? o que acontece se não pagar? tenho fatura?).
- Nada de preços escritos à mão no HTML (só o que vier da tabela); nada em inglês; sem emojis.
- Rodapé de `site/index.html`: link «Preços». `site/sitemap.xml`: a página nova. `site/testes/verifica.mjs`: asserções
  para `/precos` (200, título, contém «Google Play» e «14 dias»), seguindo o padrão das outras.
- Se `site/index.html` já tiver uma secção de preços com valores escritos à mão, troca-os pela leitura da tabela (mesmo
  código) — e diz na resposta o que mudaste.

## Critério de feito
`site/precos.html` + rodapé + sitemap + testes; `node --check site/testes/verifica.mjs` passa. Cola a lista de ficheiros
e as linhas do HTML onde os preços são lidos.

## Proibido
Escrever valores de preços à mão; mexer em `lib/`, `supabase/`, git; publicar; prometer iOS.
