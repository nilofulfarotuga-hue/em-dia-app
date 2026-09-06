-- Em Dia — seed dos guias de 1 minuto (gerado por tool/guias/carregar.py em 2026-09-06)
-- Fonte: supabase/seed/guias/*.md (11 guias). Não editar à mão: edita o .md e volta a correr o script.
-- verificado_em = null quando o .md diz POR CONFIRMAR.

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'abrir-atividade',
  'Abrir atividade (o CAE certo para TVDE, estafeta, cabeleireiro…)',
  'Como dizer às Finanças que vais trabalhar por conta própria, em 6 passos e sem pagar nada.',
  $g$Abrir atividade é dizer às Finanças: "vou trabalhar por conta própria". É grátis e faz-se online.

1. Entra no Portal das Finanças com o teu NIF e a senha. Procura "Início de atividade".
2. Escolhe a data em que começas a trabalhar.
3. Escolhe o código da tua atividade (o CAE, o número que diz o que fazes):
- TVDE (Uber, Bolt): CAE 49320 — POR CONFIRMAR
- Estafeta (Glovo, Uber Eats): CAE 53200 — POR CONFIRMAR
- Cabeleireiro: CAE 96021 — POR CONFIRMAR
Estes códigos ainda não estão nas regras confirmadas da app. Confirma no portal ou com um contabilista.
4. Regime de IRS: escolhe "simplificado". É o mais fácil para quem começa (vê o guia "Simplificado ou organizada").
5. IVA: se contas faturar menos de 15.000 € por ano (iva_isencao_limite), marca a isenção do artigo 53.º. Assim não cobras IVA.
6. Confirma e guarda o comprovativo (o PDF que o portal te dá).

O que acontece a seguir:
- As Finanças avisam a Segurança Social sozinhas. Nos primeiros 12 meses (ss_isencao_meses) não pagas contribuições.
- Já podes passar recibos verdes no portal.

O que fazer: abre atividade antes do primeiro dia de trabalho. Prazo: antes de passares o primeiro recibo.

Fonte: https://www.portaldasfinancas.gov.pt/ · Verificado em: POR CONFIRMAR
$g$,
  $g$Abrir atividade é dizer para as Finanças (a Receita daqui): "vou trabalhar por conta própria". É de graça e se faz online. É parecido com virar MEI no Brasil.

1. Entre no Portal das Finanças com o seu NIF (o CPF daqui) e a senha. Procure "Início de atividade".
2. Escolha a data em que você começa a trabalhar.
3. Escolha o código da sua atividade (o CAE, o número que diz o que você faz):
- TVDE (Uber, Bolt): CAE 49320 — POR CONFIRMAR
- Entregador (Glovo, Uber Eats): CAE 53200 — POR CONFIRMAR
- Cabeleireiro: CAE 96021 — POR CONFIRMAR
Esses códigos ainda não estão nas regras confirmadas do app. Confirme no portal ou com um contador.
4. Regime de IRS (o imposto de renda): escolha "simplificado". É o mais fácil para quem começa (veja o guia "Simplificado ou organizada").
5. IVA (o imposto em cima do preço): se você acha que vai faturar menos de 15.000 € por ano (iva_isencao_limite), marque a isenção do artigo 53.º. Assim você não cobra IVA.
6. Confirme e salve o comprovante (o PDF que o portal te dá).

O que acontece depois:
- As Finanças avisam a Segurança Social (o INSS daqui) sozinhas. Nos primeiros 12 meses (ss_isencao_meses) você não paga contribuição.
- Você já pode emitir recibos verdes (a nota fiscal do autônomo) no portal.

O que fazer: abra atividade antes do primeiro dia de trabalho. Prazo: antes de emitir o primeiro recibo.

Fonte: https://www.portaldasfinancas.gov.pt/ · Verificado em: POR CONFIRMAR
$g$,
  'atividade',
  10,
  'https://www.portaldasfinancas.gov.pt/',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'simplificado-vs-organizada',
  'Simplificado ou contabilidade organizada?',
  'As duas formas de as Finanças contarem o teu lucro e quando é que precisas mesmo de contabilista.',
  $g$Há duas formas de as Finanças contarem o teu lucro para o IRS.

**Regime simplificado** (o normal para quem começa)
- As Finanças não olham para as tuas despesas uma a uma. Usam uma conta fixa.
- Serviços (TVDE, entregas, cabeleireiro): contam 75% do que faturaste (irs_coef_servicos). Os outros 25% são despesas "presumidas" (as Finanças assumem que as tiveste).
- Venda de bens: contam só 15% (irs_coef_vendas).
- Não precisas de contabilista.
- Exemplo: faturaste 10.000 € em serviços. Pagas IRS sobre 7.500 €.

**Contabilidade organizada**
- Conta-se tudo: cada despesa com fatura entra na conta.
- É obrigatório ter contabilista certificado. Custa dinheiro todos os meses.
- Compensa se as tuas despesas reais forem muito maiores do que 25% do que ganhas (carro, combustível, renda de loja).

Quando precisas de contabilista?
1. Se escolheres contabilidade organizada: sempre.
2. Se faturares acima de um limite anual, a organizada passa a ser obrigatória. O valor não está nas regras confirmadas da app: POR CONFIRMAR.
3. Se tiveres muitas despesas e dúvidas: um contabilista custa menos do que um erro.

O que fazer: escolhes o regime quando abres atividade. Se estás a começar, fica no simplificado. Mudar depois: só em certas datas — POR CONFIRMAR. Prazo: no dia em que abres atividade.

Fonte: https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs31.aspx · Verificado em: POR CONFIRMAR
$g$,
  $g$Existem duas formas de as Finanças (a Receita daqui) contarem o seu lucro para o IRS (o imposto de renda).

**Regime simplificado** (o normal para quem começa)
- As Finanças não olham as suas despesas uma por uma. Usam uma conta fixa.
- Serviços (TVDE, entregas, cabeleireiro): contam 75% do que você faturou (irs_coef_servicos). Os outros 25% são despesas "presumidas" (as Finanças assumem que você teve).
- Venda de produtos: contam só 15% (irs_coef_vendas).
- Você não precisa de contador.
- Exemplo: você faturou 10.000 € em serviços. Paga IRS sobre 7.500 €.

**Contabilidade organizada**
- Conta-se tudo: cada despesa com nota fiscal (fatura) entra na conta.
- É obrigatório ter contador certificado. Custa dinheiro todo mês.
- Compensa se as suas despesas reais forem muito maiores do que 25% do que você ganha (carro, combustível, aluguel de loja).

Quando você precisa de contador?
1. Se escolher contabilidade organizada: sempre.
2. Se faturar acima de um limite anual, a organizada vira obrigatória. O valor não está nas regras confirmadas do app: POR CONFIRMAR.
3. Se tiver muitas despesas e dúvidas: um contador custa menos do que um erro.

O que fazer: você escolhe o regime quando abre atividade. Se está começando, fique no simplificado. Mudar depois: só em certas datas — POR CONFIRMAR. Prazo: no dia em que abrir atividade.

Fonte: https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs31.aspx · Verificado em: POR CONFIRMAR
$g$,
  'impostos',
  20,
  'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs31.aspx',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'isencao-art-53',
  'Isenção de IVA (art. 53.º): até 15.000 € por ano',
  'Não cobras IVA até 15.000 € por ano, o que escrever no recibo e o que fazer quando passas o limite.',
  $g$Isenção do artigo 53.º quer dizer: não cobras IVA (o imposto que vai em cima do preço) aos teus clientes e não entregas IVA às Finanças.

Quem pode:
- Quem faturou menos de 15.000 € no ano (iva_isencao_limite).

O que escrever no recibo verde:
Escolhe a opção M10. Aparece a frase "IVA - regime de isenção [artigo 53.º do CIVA] (M10)" (iva_mencao_isencao). Sem esta frase o recibo está errado.

A app avisa-te quando chegares aos 12.000 € (iva_isencao_aviso). É o sinal amarelo.

O que acontece se passares o limite:
1. Passaste 15.000 €: perdes a isenção. Tens 15 dias úteis (iva_isencao_comunicacao_dias_uteis) para entregar a "declaração de alterações" no Portal das Finanças.
2. Passaste 18.750 € (iva_isencao_perda_imediata): perdes de imediato. A fatura seguinte já leva IVA de 23% (iva_taxa_normal).

E depois, com IVA:
- Entregas a declaração de IVA de 3 em 3 meses, até ao dia 20 (iva_declaracao_trimestral_dia) do 2.º mês depois do trimestre.
- Pagas até ao dia 25 (iva_pagamento_dia) desse mesmo mês.
- Cobras 23% a mais ao cliente e entregas esse dinheiro. Não é teu.

O que fazer: vê na app quanto já faturaste este ano. Se passaste os 15.000 €, entrega a declaração de alterações. Prazo: 15 dias úteis depois de passares.

Fonte: https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva53.aspx · Verificado em: POR CONFIRMAR
$g$,
  $g$Isenção do artigo 53.º quer dizer: você não cobra IVA (o imposto que vai em cima do preço, parecido com o ICMS) dos seus clientes e não entrega IVA para as Finanças (a Receita daqui).

Quem pode:
- Quem faturou menos de 15.000 € no ano (iva_isencao_limite).

O que escrever no recibo verde (a nota fiscal do autônomo):
Escolha a opção M10. Aparece a frase "IVA - regime de isenção [artigo 53.º do CIVA] (M10)" (iva_mencao_isencao). Sem essa frase o recibo está errado.

O app avisa quando você chegar aos 12.000 € (iva_isencao_aviso). É o sinal amarelo.

O que acontece se passar do limite:
1. Passou de 15.000 €: você perde a isenção. Tem 15 dias úteis (iva_isencao_comunicacao_dias_uteis) para entregar a "declaração de alterações" no Portal das Finanças.
2. Passou de 18.750 € (iva_isencao_perda_imediata): perde na hora. A próxima nota já leva IVA de 23% (iva_taxa_normal).

E depois, com IVA:
- Você entrega a declaração de IVA a cada 3 meses, até o dia 20 (iva_declaracao_trimestral_dia) do 2.º mês depois do trimestre.
- Paga até o dia 25 (iva_pagamento_dia) desse mesmo mês.
- Cobra 23% a mais do cliente e entrega esse dinheiro. Ele não é seu.

O que fazer: veja no app quanto você já faturou este ano. Se passou dos 15.000 €, entregue a declaração de alterações. Prazo: 15 dias úteis depois de passar.

Fonte: https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva53.aspx · Verificado em: POR CONFIRMAR
$g$,
  'impostos',
  30,
  'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/civa_rep/Pages/iva53.aspx',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'retencao-23-25-dispensa',
  'Retenção na fonte: 23%, 25% ou dispensa',
  'O que o cliente guarda para as Finanças por ti e qual das três opções escolher no recibo.',
  $g$Retenção na fonte é a parte que o teu cliente guarda e entrega às Finanças por ti. É um adiantamento do teu IRS. Em junho acerta-se.

Quem faz a retenção? Só clientes com contabilidade organizada (empresas). Pessoas particulares não retêm nada.

Três escolhas no recibo verde:

1. **Retenção de 23%** (retencao_padrao) — o normal.
Exemplo: recibo de 1.000 €. Recebes 770 €. Os 230 € vão para as Finanças em teu nome.

2. **Retenção de 25%** (retencao_opcao) — por opção tua.
Guardas mais agora. Em junho pagas menos, ou até recebes de volta.

3. **Dispensa de retenção** — só se no ano passado faturaste menos de 15.000 € (retencao_dispensa_limite).
No recibo escolhes a opção "Dispensa de retenção - art. 101.º-B do CIRS" (texto exato do portal: POR CONFIRMAR). Recebes tudo agora. Mas atenção: em junho pagas o IRS todo de uma vez. Guarda uma parte todos os meses.

Uber, Bolt, Glovo: são empresas estrangeiras. Se a retenção se aplica aos recibos passados a elas: POR CONFIRMAR. Confirma com um contabilista.

O que fazer: em cada recibo, escolhe uma das três opções no campo da retenção. Se tens dúvidas, deixa os 23%: é a escolha mais segura. Prazo: no momento em que passas cada recibo.

Fonte: https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs101.aspx · Verificado em: POR CONFIRMAR
$g$,
  $g$Retenção na fonte é a parte que o seu cliente segura e entrega para as Finanças (a Receita daqui) por você. É um adiantamento do seu IRS (o imposto de renda). Em junho tudo se acerta.

Quem faz a retenção? Só clientes com contabilidade organizada (empresas). Pessoa física não retém nada.

Três escolhas no recibo verde (a nota fiscal do autônomo):

1. **Retenção de 23%** (retencao_padrao) — o normal.
Exemplo: recibo de 1.000 €. Você recebe 770 €. Os 230 € vão para as Finanças no seu nome.

2. **Retenção de 25%** (retencao_opcao) — por opção sua.
Você guarda mais agora. Em junho paga menos, ou até recebe de volta.

3. **Dispensa de retenção** — só se no ano passado você faturou menos de 15.000 € (retencao_dispensa_limite).
No recibo você escolhe a opção "Dispensa de retenção - art. 101.º-B do CIRS" (texto exato do portal: POR CONFIRMAR). Recebe tudo agora. Mas atenção: em junho paga o IRS todo de uma vez. Guarde uma parte todo mês.

Uber, Bolt, Glovo: são empresas estrangeiras. Se a retenção vale para os recibos emitidos para elas: POR CONFIRMAR. Confirme com um contador.

O que fazer: em cada recibo, escolha uma das três opções no campo da retenção. Se tiver dúvida, deixe os 23%: é a escolha mais segura. Prazo: na hora de emitir cada recibo.

Fonte: https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs101.aspx · Verificado em: POR CONFIRMAR
$g$,
  'impostos',
  40,
  'https://info.portaldasfinancas.gov.pt/pt/informacao_fiscal/codigos_tributarios/cirs_rep/Pages/irs101.aspx',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'seguranca-social-direta',
  'Segurança Social Direta passo a passo',
  'Onde declarar o que ganhaste, quanto pagas, e as datas: declaração em janeiro, abril, julho e outubro; pagamento do dia 10 ao 20.',
  $g$A Segurança Social Direta é o site onde declaras o que ganhaste e vês quanto pagas.

Passo a passo:
1. Entra em seg-social.pt/consultas/ssdirecta com o NISS e a palavra-passe.
2. Vai a "Emprego" → "Trabalhadores Independentes" → "Declaração trimestral" (nomes dos menus: POR CONFIRMAR).
3. Escreve o total dos recibos dos últimos 3 meses. Serviços num campo, vendas noutro.
4. Se quiseres, pede para pagar até 25% a menos ou a mais (ss_ajuste_max).
5. Confirma. O site diz-te quanto pagas em cada um dos 3 meses seguintes.

Quando declarar: até ao último dia de janeiro, abril, julho e outubro (ss_declaracao_meses).

Quando pagar: todos os meses, do dia 10 ao dia 20 (ss_pagamento_dia_inicio, ss_pagamento_dia_fim). Usa a referência Multibanco que está no site.

Quanto pagas: 21,4% (ss_taxa) sobre 70% do que faturaste em serviços (ss_base_servicos), a dividir por 3 meses.
Exemplo: 3.000 € no trimestre → base 2.100 € → pagas 149,80 € por mês.
- Mínimo: 20 € por mês (ss_minimo_mensal), mesmo sem faturar.
- Primeiro ano: 12 meses sem pagar (ss_isencao_meses). A app avisa 30 dias antes de acabar (ss_aviso_fim_isencao_dias).

Passou o dia 20? Paga hoje: os juros são pequenos.

O que fazer: declara até ao fim de janeiro, abril, julho e outubro. Paga até ao dia 20 de cada mês.

Fonte: https://www.seg-social.pt/trabalhadores-independentes · Verificado em: POR CONFIRMAR
$g$,
  $g$A Segurança Social Direta é o site do INSS daqui, onde você declara o que ganhou e vê quanto paga.

Passo a passo:
1. Entre em seg-social.pt/consultas/ssdirecta com o NISS (o número do INSS daqui) e a senha.
2. Vá em "Emprego" → "Trabalhadores Independentes" → "Declaração trimestral" (nomes dos menus: POR CONFIRMAR).
3. Escreva o total dos recibos dos últimos 3 meses. Serviços num campo, vendas noutro.
4. Se quiser, peça para pagar até 25% a menos ou a mais (ss_ajuste_max).
5. Confirme. O site diz quanto você paga em cada um dos 3 meses seguintes.

Quando declarar: até o último dia de janeiro, abril, julho e outubro (ss_declaracao_meses).

Quando pagar: todo mês, do dia 10 ao dia 20 (ss_pagamento_dia_inicio, ss_pagamento_dia_fim). Use a referência Multibanco (o boleto daqui) que está no site.

Quanto você paga: 21,4% (ss_taxa) sobre 70% do que faturou em serviços (ss_base_servicos), dividido por 3 meses.
Exemplo: 3.000 € no trimestre → base 2.100 € → você paga 149,80 € por mês.
- Mínimo: 20 € por mês (ss_minimo_mensal), mesmo sem faturar.
- Primeiro ano: 12 meses sem pagar (ss_isencao_meses). O app avisa 30 dias antes de acabar (ss_aviso_fim_isencao_dias).

Passou o dia 20? Pague hoje: os juros são pequenos.

O que fazer: declare até o fim de janeiro, abril, julho e outubro. Pague até o dia 20 de cada mês.

Fonte: https://www.seg-social.pt/trabalhadores-independentes · Verificado em: POR CONFIRMAR
$g$,
  'seguranca_social',
  50,
  'https://www.seg-social.pt/trabalhadores-independentes',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'irs-independente',
  'IRS do independente (anexo B, despesas, mínimo de existência)',
  'As datas do IRS, quanto pagas no simplificado, as despesas que tens de justificar e os pagamentos por conta.',
  $g$O IRS é o imposto sobre o que ganhaste no ano. Entregas uma declaração por ano com o anexo B (a folha dos independentes no regime simplificado).

Datas:
1. Até 25 de fevereiro (efatura_validar_ate): valida as tuas faturas no e-fatura. Sem isto perdes deduções.
2. De 1 de abril a 30 de junho (irs_entrega_inicio, irs_entrega_fim): entrega o IRS no Portal das Finanças. O anexo B já vem quase preenchido com os teus recibos. Confirma os valores.
3. Se houver imposto a pagar, a data de pagamento: POR CONFIRMAR.

Quanto pagas:
- Só 75% dos serviços contam como rendimento (irs_coef_servicos).
- Se o rendimento for pequeno, não pagas nada: mínimo de existência de 12.880 € (irs_minimo_existencia).
- O que os clientes já reteram é abatido (vê o guia "Retenção").

Despesas: acima de 27.360 € brutos por ano (irs_despesas_justificar_limite, valor aproximado), tens de justificar 15% (irs_despesas_justificar_pct) com faturas com o teu NIF. Pede sempre fatura com NIF: combustível, telemóvel, portagens.

Pagamentos por conta: a partir do 2.º ano, se tiveste imposto a pagar, adiantas 65% (irs_pagamentos_conta_pct) em 3 vezes: 20 de julho, 20 de setembro e 20 de dezembro (irs_pagamentos_conta_datas). A app põe as 3 datas no calendário.

O que fazer: valida o e-fatura até 25 de fevereiro; entrega o IRS até 30 de junho.

Fonte: https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/default.aspx · Verificado em: POR CONFIRMAR
$g$,
  $g$O IRS é o imposto de renda daqui: o imposto sobre o que você ganhou no ano. Você entrega uma declaração por ano com o anexo B (a folha dos autônomos no regime simplificado).

Datas:
1. Até 25 de fevereiro (efatura_validar_ate): valide as suas notas no e-fatura (o site das notas fiscais). Sem isso você perde deduções.
2. De 1 de abril a 30 de junho (irs_entrega_inicio, irs_entrega_fim): entregue o IRS no Portal das Finanças. O anexo B já vem quase preenchido com os seus recibos. Confira os valores.
3. Se tiver imposto a pagar, a data de pagamento: POR CONFIRMAR.

Quanto você paga:
- Só 75% dos serviços contam como renda (irs_coef_servicos).
- Se a renda for pequena, você não paga nada: mínimo de existência de 12.880 € (irs_minimo_existencia).
- O que os clientes já retiveram é abatido (veja o guia "Retenção").

Despesas: acima de 27.360 € brutos por ano (irs_despesas_justificar_limite, valor aproximado), você tem que justificar 15% (irs_despesas_justificar_pct) com notas com o seu NIF (o CPF daqui). Peça sempre nota com NIF: combustível, celular, pedágios.

Pagamentos por conta: a partir do 2.º ano, se você teve imposto a pagar, adianta 65% (irs_pagamentos_conta_pct) em 3 vezes: 20 de julho, 20 de setembro e 20 de dezembro (irs_pagamentos_conta_datas). O app coloca as 3 datas no calendário.

O que fazer: valide o e-fatura até 25 de fevereiro; entregue o IRS até 30 de junho.

Fonte: https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/default.aspx · Verificado em: POR CONFIRMAR
$g$,
  'impostos',
  60,
  'https://info.portaldasfinancas.gov.pt/pt/apoio_contribuinte/calendario_fiscal/Pages/default.aspx',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'tvde-o-que-e-preciso',
  'TVDE: o que é preciso',
  'As 4 coisas para andar na Uber ou Bolt: o teu certificado, o carro, a atividade aberta e um operador.',
  $g$Para andar na Uber ou na Bolt precisas de 4 coisas: o teu certificado, o carro, a atividade aberta e um operador.

1. **Certificado de motorista TVDE**
- Curso numa escola aprovada pelo IMT (o instituto dos transportes). Horas e preço: POR CONFIRMAR.
- Carta de condução há um mínimo de anos: POR CONFIRMAR.
- Registo criminal: POR CONFIRMAR.
- Vale 5 anos (tvde_certificado_validade_anos). A app avisa-te antes de acabar.

2. **O carro**
- Licença/dístico do veículo TVDE, pedido ao IMT (tvde_licenca_veiculo — POR CONFIRMAR).
- Idade máxima do carro: POR CONFIRMAR.
- Inspeção anual para carros TVDE (ipo_tvde — POR CONFIRMAR).
- Seguro próprio para TVDE. O seguro normal não chega. Pergunta à seguradora: "quero seguro para TVDE". O tipo exato: POR CONFIRMAR.

3. **Atividade aberta nas Finanças**
- O CAE (o código que diz às Finanças o que fazes) é o 49320 — POR CONFIRMAR. Vê o guia "Abrir atividade".
- Isenção de IVA (o imposto sobre o valor acrescentado, aquele que se soma ao preço) se faturares menos de 15.000 € (iva_isencao_limite).

4. **Operador TVDE**
- Uma empresa licenciada que faz a ligação entre ti e a app. Se é obrigatório ter operador: POR CONFIRMAR. Compara comissões antes de assinar.

O que fazer: tira o certificado primeiro; depois trata do carro e do operador; abre atividade antes do primeiro recibo. Prazo: o certificado renova-se de 5 em 5 anos.

Fonte: https://www.imt-ip.pt/sites/IMTT/Portugues/TVDE/Paginas/default.aspx · Verificado em: POR CONFIRMAR
$g$,
  $g$Para rodar na Uber ou na Bolt você precisa de 4 coisas: o seu certificado, o carro, a atividade aberta e um operador.

1. **Certificado de motorista TVDE** (TVDE é o nome do transporte por aplicativo aqui)
- Curso numa escola aprovada pelo IMT (o Detran daqui). Horas e preço: POR CONFIRMAR.
- Carteira de motorista há um mínimo de anos: POR CONFIRMAR.
- Antecedentes criminais: POR CONFIRMAR.
- Vale 5 anos (tvde_certificado_validade_anos). O app avisa antes de acabar.

2. **O carro**
- Licença/adesivo do veículo TVDE, pedido ao IMT (tvde_licenca_veiculo — POR CONFIRMAR).
- Idade máxima do carro: POR CONFIRMAR.
- Vistoria (inspeção) anual para carros TVDE (ipo_tvde — POR CONFIRMAR).
- Seguro próprio para TVDE. O seguro normal não serve. Pergunte à seguradora: "quero seguro para TVDE". O tipo exato: POR CONFIRMAR.

3. **Atividade aberta nas Finanças** (a Receita daqui)
- O CAE (o código que diz às Finanças o que você faz, como o CNAE) é o 49320 — POR CONFIRMAR. Veja o guia "Abrir atividade".
- Isenção de IVA (o imposto sobre o valor acrescentado, aquele que se soma ao preço) se você faturar menos de 15.000 € (iva_isencao_limite).

4. **Operador TVDE**
- Uma empresa licenciada que faz a ponte entre você e o aplicativo. Se é obrigatório ter operador: POR CONFIRMAR. Compare as comissões antes de assinar.

O que fazer: tire o certificado primeiro; depois cuide do carro e do operador; abra atividade antes do primeiro recibo. Prazo: o certificado se renova a cada 5 anos.

Fonte: https://www.imt-ip.pt/sites/IMTT/Portugues/TVDE/Paginas/default.aspx · Verificado em: POR CONFIRMAR
$g$,
  'tvde',
  70,
  'https://www.imt-ip.pt/sites/IMTT/Portugues/TVDE/Paginas/default.aspx',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'estafeta-recibos-vs-contrato',
  'Estafeta de plataforma: recibos ou contrato?',
  'As duas formas de fazer entregas para a Glovo, Uber Eats ou Bolt Food, e o que é a "presunção de laboralidade", sem susto.',
  $g$Se fazes entregas para a Glovo, Uber Eats ou Bolt Food, há duas formas de trabalhar.

**Recibos verdes (independente)**
- Abres atividade nas Finanças (CAE 53200 — POR CONFIRMAR).
- Passas um recibo por mês a quem te paga.
- Pagas tu a Segurança Social: 21,4% (ss_taxa) sobre 70% (ss_base_servicos) do que faturaste, depois dos 12 meses de isenção (ss_isencao_meses).
- Escolhes as horas. Não tens férias pagas nem subsídios.

**Contrato de trabalho**
- A empresa desconta por ti. Tens férias, subsídio de férias e de Natal.
- Menos liberdade de horário.

**A "presunção de laboralidade"** (a lei assume que és empregado)
- A lei diz: se a plataforma manda no teu trabalho (fixa o preço, o horário, avalia-te, obriga a farda), pode ter de te tratar como empregado. O artigo da lei e as regras exatas: POR CONFIRMAR.
- Não é para teres medo. Se continuares a recibos, nada muda no teu dia a dia. Só muda quem paga os descontos.
- Para pedir contrato, fala com a ACT (a autoridade do trabalho) ou um advogado.

O que fazer hoje: se estás a recibos, passa o recibo todos os meses e declara à Segurança Social em janeiro, abril, julho e outubro (ss_declaracao_meses). Prazo: recibo até ao fim de cada mês.

Fonte: https://www.seg-social.pt/trabalhadores-independentes · Verificado em: POR CONFIRMAR
$g$,
  $g$Se você faz entregas para a Glovo, Uber Eats ou Bolt Food, existem duas formas de trabalhar.

**Recibos verdes (autônomo)**
- Você abre atividade nas Finanças, a Receita daqui (CAE 53200 — POR CONFIRMAR).
- Emite um recibo por mês para quem paga você.
- Você mesmo paga a Segurança Social (o INSS daqui): 21,4% (ss_taxa) sobre 70% (ss_base_servicos) do que faturou, depois dos 12 meses de isenção (ss_isencao_meses).
- Você escolhe as horas. Não tem férias pagas nem 13.º.

**Contrato de trabalho** (a carteira assinada daqui)
- A empresa desconta por você. Tem férias, subsídio de férias e de Natal (o 13.º).
- Menos liberdade de horário.

**A "presunção de laboralidade"** (a lei assume que você é empregado)
- A lei diz: se a plataforma manda no seu trabalho (fixa o preço, o horário, avalia você, obriga a usar uniforme), pode ter que tratar você como empregado. O artigo da lei e as regras exatas: POR CONFIRMAR.
- Não é para ter medo. Se continuar nos recibos, nada muda no seu dia a dia. Só muda quem paga os descontos.
- Para pedir contrato, fale com a ACT (o Ministério do Trabalho daqui) ou um advogado.

O que fazer hoje: se você está nos recibos, emita o recibo todo mês e declare para a Segurança Social em janeiro, abril, julho e outubro (ss_declaracao_meses). Prazo: recibo até o fim de cada mês.

Fonte: https://www.seg-social.pt/trabalhadores-independentes · Verificado em: POR CONFIRMAR
$g$,
  'estafeta',
  80,
  'https://www.seg-social.pt/trabalhadores-independentes',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'encerrar-atividade',
  'Encerrar atividade sem deixar contas para trás',
  'Como fechar a atividade nas Finanças, a última declaração na Segurança Social e o apoio a que podes ter direito.',
  $g$Encerrar é dizer às Finanças: "parei de trabalhar por conta própria". Se não fechares, as obrigações continuam.

Passo a passo:
1. Passa o último recibo.
2. Portal das Finanças → "Cessação de atividade". Escolhe a data em que paraste. O prazo para comunicar: POR CONFIRMAR. Guarda o comprovativo.
3. As Finanças avisam a Segurança Social. Mesmo assim, entra na Segurança Social Direta e confirma que ficou "cessado".
4. Faz a última declaração trimestral na Segurança Social no mês certo: janeiro, abril, julho ou outubro (ss_declaracao_meses). Declara o que faturaste até ao dia em que paraste.
5. Paga a última contribuição do dia 10 ao dia 20 (ss_pagamento_dia_inicio, ss_pagamento_dia_fim).
6. No ano seguinte, entrega o IRS com o anexo B entre 1 de abril e 30 de junho (irs_entrega_inicio, irs_entrega_fim).

Tens direito a apoio?
Há o subsídio por cessação de atividade (o "desemprego" dos independentes). Precisas de 360 dias de descontos nos últimos 24 meses (cessacao_atividade_prazo_garantia_dias). As outras condições: POR CONFIRMAR. Pede na Segurança Social Direta.

Dívidas: se tens contribuições em atraso, pede um plano de pagamento antes de fechar. Fechar não apaga a dívida.

O que fazer: cessa no portal no dia em que paras; última declaração no mês do trimestre seguinte. Prazo: POR CONFIRMAR.

Fonte: https://www.seg-social.pt/subsidio-por-cessacao-de-atividade · Verificado em: POR CONFIRMAR
$g$,
  $g$Encerrar é dizer para as Finanças (a Receita daqui): "parei de trabalhar por conta própria". Se você não fechar, as obrigações continuam.

Passo a passo:
1. Emita o último recibo.
2. Portal das Finanças → "Cessação de atividade". Escolha a data em que você parou. O prazo para comunicar: POR CONFIRMAR. Salve o comprovante.
3. As Finanças avisam a Segurança Social (o INSS daqui). Mesmo assim, entre na Segurança Social Direta e confira se ficou "cessado".
4. Faça a última declaração trimestral na Segurança Social no mês certo: janeiro, abril, julho ou outubro (ss_declaracao_meses). Declare o que faturou até o dia em que parou.
5. Pague a última contribuição do dia 10 ao dia 20 (ss_pagamento_dia_inicio, ss_pagamento_dia_fim).
6. No ano seguinte, entregue o IRS (o imposto de renda) com o anexo B entre 1 de abril e 30 de junho (irs_entrega_inicio, irs_entrega_fim).

Você tem direito a algum apoio?
Existe o subsídio por cessação de atividade (o "seguro-desemprego" dos autônomos). Você precisa de 360 dias de contribuição nos últimos 24 meses (cessacao_atividade_prazo_garantia_dias). As outras condições: POR CONFIRMAR. Peça na Segurança Social Direta.

Dívidas: se você tem contribuições atrasadas, peça um parcelamento antes de fechar. Fechar não apaga a dívida.

O que fazer: encerre no portal no dia em que parar; última declaração no mês do trimestre seguinte. Prazo: POR CONFIRMAR.

Fonte: https://www.seg-social.pt/subsidio-por-cessacao-de-atividade · Verificado em: POR CONFIRMAR
$g$,
  'atividade',
  90,
  'https://www.seg-social.pt/subsidio-por-cessacao-de-atividade',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'imigrante-nif-niss-sns-aima',
  'Imigrante: NIF, NISS, SNS e AIMA',
  'Os 4 números de que precisas para viver e trabalhar em Portugal, por ordem, mais a troca da carta e o acordo com o Brasil.',
  $g$Para viver e trabalhar em Portugal precisas de 4 números e de uma morada certa, por esta ordem.

1. **NIF** (o número das Finanças). Pedes num balcão das Finanças ou numa Loja do Cidadão. Leva o passaporte e um comprovativo de morada. Sem NIF não abres conta nem alugas casa.
2. **NISS** (o número da Segurança Social). Pede-se online na Segurança Social ou num balcão. Precisas do NIF. É com ele que descontas.
3. **Número de utente do SNS** (o número do centro de saúde). Pede no centro de saúde da tua zona com o NIF, o passaporte e o comprovativo de morada.
4. **Morada e título de residência na AIMA** (a agência das migrações, o antigo SEF). Mantém a morada sempre atualizada. Marcações em aima.gov.pt. Prazos e documentos: POR CONFIRMAR.

Carta de condução
- A carta estrangeira serve no início. Tens de a trocar pela portuguesa até 2 anos depois de teres residência (troca_carta_estrangeira_prazo_anos — POR CONFIRMAR). Pede no IMT.

Reforma
- O tempo que descontaste no Brasil (INSS) soma-se ao de Portugal, pelo acordo Portugal–Brasil (acordo_pt_br_url). Guarda o teu extrato do INSS.

O que fazer: NIF hoje; NISS na mesma semana; número de utente logo a seguir; morada na AIMA sempre certa. Prazo da carta: 2 anos — POR CONFIRMAR.

Fonte: https://aima.gov.pt/ · Verificado em: POR CONFIRMAR
$g$,
  $g$Para morar e trabalhar em Portugal você precisa de 4 números e de um endereço certo, nesta ordem.

1. **NIF** (o CPF daqui). Você pede num balcão das Finanças (a Receita) ou numa Loja do Cidadão (o Poupatempo daqui). Leve o passaporte e um comprovante de endereço. Sem NIF você não abre conta nem aluga casa.
2. **NISS** (o número do INSS daqui). Pede-se online na Segurança Social ou num balcão. Você precisa do NIF. É com ele que você contribui.
3. **Número de utente do SNS** (o cartão do SUS daqui). Peça no centro de saúde (o posto) da sua região com o NIF, o passaporte e o comprovante de endereço.
4. **Endereço e título de residência na AIMA** (a agência de imigração, o antigo SEF). Mantenha o endereço sempre atualizado. Agendamentos em aima.gov.pt. Prazos e documentos: POR CONFIRMAR.

Carteira de motorista (aqui chama-se carta de condução)
- A carteira brasileira serve no começo. Você tem que trocar pela portuguesa até 2 anos depois de ter residência (troca_carta_estrangeira_prazo_anos — POR CONFIRMAR). Peça no IMT (o Detran daqui).

Aposentadoria
- O tempo que você contribuiu no Brasil (INSS) soma com o de Portugal, pelo acordo Portugal–Brasil (acordo_pt_br_url). Guarde o seu extrato do INSS (CNIS).

O que fazer: NIF hoje; NISS na mesma semana; número de utente logo depois; endereço na AIMA sempre certo. Prazo da carteira: 2 anos — POR CONFIRMAR.

Fonte: https://aima.gov.pt/ · Verificado em: POR CONFIRMAR
$g$,
  'imigrante',
  100,
  'https://aima.gov.pt/',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;

insert into public.guias (slug, titulo, resumo, corpo_pt, corpo_br, categoria, ordem, fonte_url, publicado, verificado_em) values (
  'carro-iuc-ipo-seguro-carta-multas',
  'Carro: IUC, inspeção, seguro, carta e multas',
  'As 5 datas do carro que não podes falhar e como a app te avisa de cada uma.',
  $g$Cinco coisas do carro têm data. A app avisa-te de todas.

1. **IUC** (o imposto do carro). Paga-se todos os anos até ao fim do mês da matrícula (iuc_regra). Exemplo: matrícula de março → pagas até 31 de março. Portal das Finanças → "IUC" → "Emitir documento de pagamento". Se atrasares, há coima.

2. **IPO** (a inspeção). Ligeiros: aos 4, 6 e 8 anos da matrícula (ipo_ligeiros_anos). Depois dos 8 anos, todos os anos (ipo_apos_8_anos). Carros TVDE: anual — POR CONFIRMAR (ipo_tvde). Marca a inspeção antes da data. A app avisa 30 e 7 dias antes (ipo_avisos_dias).

3. **Seguro**. É obrigatório. Renova-se uma vez por ano. A app avisa 45 dias antes (seguro_aviso_dias): é a altura de pedir preços a 2 ou 3 seguradoras.

4. **Carta de condução**. Vale 15 anos até aos 60; dos 60 aos 70, 5 anos; depois dos 70, 2 anos (carta_validade). Renova no IMT antes de caducar.

5. **Multas**. Tens 15 dias úteis para pagar pelo valor mínimo (multa_pagamento_voluntario_dias_uteis). Depois sobe. Paga no site da ANSR ou com a referência que vem na carta.

O que fazer: mete na app a matrícula, a data da matrícula e a data do seguro. Ela põe tudo no calendário. Prazo mais próximo: o IUC, no mês da matrícula.

Fonte: https://www.imt-ip.pt/sites/IMTT/Portugues/Veiculos/InspecoesTecnicas/Paginas/InspecoesTecnicas.aspx · Verificado em: POR CONFIRMAR
$g$,
  $g$Cinco coisas do carro têm data. O app avisa você de todas.

1. **IUC** (o IPVA daqui). Paga-se todo ano até o fim do mês da placa, que aqui se chama matrícula (iuc_regra). Exemplo: matrícula de março → você paga até 31 de março. Portal das Finanças → "IUC" → "Emitir documento de pagamento". Se atrasar, tem multa.

2. **IPO** (a vistoria). Carros de passeio: aos 4, 6 e 8 anos da matrícula (ipo_ligeiros_anos). Depois dos 8 anos, todo ano (ipo_apos_8_anos). Carros TVDE: anual — POR CONFIRMAR (ipo_tvde). Marque a vistoria antes da data. O app avisa 30 e 7 dias antes (ipo_avisos_dias).

3. **Seguro**. É obrigatório. Renova uma vez por ano. O app avisa 45 dias antes (seguro_aviso_dias): é a hora de pedir preço a 2 ou 3 seguradoras.

4. **Carteira de motorista** (aqui, carta de condução). Vale 15 anos até os 60; dos 60 aos 70, 5 anos; depois dos 70, 2 anos (carta_validade). Renove no IMT (o Detran daqui) antes de vencer.

5. **Multas**. Você tem 15 dias úteis para pagar pelo valor mínimo (multa_pagamento_voluntario_dias_uteis). Depois sobe. Pague no site da ANSR ou com a referência que vem na carta.

O que fazer: coloque no app a matrícula, a data da matrícula e a data do seguro. Ele põe tudo no calendário. Prazo mais próximo: o IUC, no mês da matrícula.

Fonte: https://www.imt-ip.pt/sites/IMTT/Portugues/Veiculos/InspecoesTecnicas/Paginas/InspecoesTecnicas.aspx · Verificado em: POR CONFIRMAR
$g$,
  'carro',
  110,
  'https://www.imt-ip.pt/sites/IMTT/Portugues/Veiculos/InspecoesTecnicas/Paginas/InspecoesTecnicas.aspx',
  true,
  null
)
on conflict (slug) do update set titulo = excluded.titulo, resumo = excluded.resumo, corpo_pt = excluded.corpo_pt,
  corpo_br = excluded.corpo_br, categoria = excluded.categoria, ordem = excluded.ordem, fonte_url = excluded.fonte_url,
  publicado = excluded.publicado, verificado_em = excluded.verificado_em;
