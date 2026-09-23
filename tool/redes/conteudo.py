"""Conteúdo dos 30 dias (28/09/2026 a 27/10/2026) — redes do Em Dia.

Regras (docs/marketing/redes-em-dia/LIVRO-DE-REGRAS-REDES.md):
- cada número legal vem de docs/REGRAS-PT-2026.md, com a fonte escrita na peça;
- nada de números inventados nem testemunhos; os ecrãs são da Maria (exemplo);
- promessa e «grátis, sem cartão» em todas as legendas; assina Em Dia;
- PT-PT por omissão; as peças marcadas `br` falam com «você».
"""
from motor import LINK, PROMESSA, PROMESSA_BR

# ------------------------------------------------------------------ fontes
F_SS_TAXA = 'Fonte: Código Contributivo (Lei 110/2009), art. 162.º e 168.º — seg-social.pt'
F_SS_DECL = 'Fonte: Código Contributivo, art. 151.º-A n.º 3 — seg-social.pt'
F_SS_PAG = 'Fonte: Código Contributivo, art. 155.º n.º 2 — seg-social.pt'
F_SS_ISENCAO = 'Fonte: Código Contributivo, art. 145.º — seg-social.pt'
F_IVA53 = 'Fonte: Código do IVA, art. 53.º e 58.º (DL 35/2025) — portaldasfinancas.gov.pt'
F_IVA_TRI = 'Fonte: Código do IVA, art. 27.º e 41.º; agenda fiscal AT 2026'
F_RET = 'Fonte: Código do IRS, art. 101.º — portaldasfinancas.gov.pt'
F_AGENDA = 'Fonte: AT, agenda fiscal 2026; Código Contributivo, art. 151.º-A e 155.º'
F_DED = 'Fonte: Código do IRS, art. 78.º-A a 78.º-F — portaldasfinancas.gov.pt'
F_JOVEM = 'Fonte: Código do IRS, art. 12.º-B (Lei 45-A/2024); FAQ da AT'
F_CT = 'Fonte: Código do Trabalho, art. 238.º, 263.º, 264.º e 268.º; ISS, «Taxas contributivas»'
F_IUC = 'Fonte: Portal das Finanças (IUC); IMT (inspeções)'
F_ENI = 'Fonte: Código do IRC; Código Contributivo (MOE 34,75 %). Explicação geral.'
NAO_SUBSTITUI = 'Não substitui um contabilista.'

H_RV = '#recibosverdes #trabalhadorindependente #segurancasocial #financaspessoais #portugal'
H_TVDE = '#tvde #motoristastvde #recibosverdes #carro #portugal'
H_EST = '#estafetas #entregas #recibosverdes #trabalhadorindependente #portugal'
H_BR = '#brasileirosemportugal #brasileirosemlisboa #morarememportugal #recibosverdes #portugal'
H_CO = '#irs #salario #direitosdotrabalhador #financaspessoais #portugal'
H_EMP = '#pequenasempresas #empreendedorismo #empresarios #contabilidade #portugal'
H_IVA = '#iva #recibosverdes #freelancerportugal #trabalhadorindependente #portugal'
H_IRS = '#irs #deducoes #efatura #financaspessoais #portugal'


def legenda(corpo: str, br=False, fonte=None, contabilista=False) -> str:
    """Legenda final: corpo + fonte + CTA + promessa (obrigatória)."""
    partes = [corpo.strip()]
    if fonte:
        partes.append(fonte.replace('Fonte:', '📚 Fonte:'))
    if contabilista:
        partes.append('Informação geral. ' + NAO_SUBSTITUI)
    if br:
        partes.append(f'👉 Experimente grátis, sem cartão: {LINK} (link na bio)')
        partes.append(PROMESSA_BR)
    else:
        partes.append(f'👉 Experimenta grátis, sem cartão: {LINK} (link na bio)')
        partes.append(PROMESSA)
    return '\n\n'.join(partes)


CTA = {'tipo': 'cta', 'fundo': 'verde'}
CTA_BR = {'tipo': 'cta', 'fundo': 'verde', 'titulo': 'Veja se você está **em dia**.',
          'pontos': ['Diz quanto guardar', 'Avisa antes de cada prazo', 'Explica em português simples'],
          'dica': 'Link na bio · abre no celular ou no computador'}

# ------------------------------------------------------------------ carrosséis
CARROSSEIS = [
    {
        'id': 'C01', 'data': '2026-09-29', 'hora': '13:30', 'publico': 'Recibos verdes',
        'gancho': 'Recibos verdes explicados como se tivesses 5 anos',
        'hashtags': H_RV,
        'corpo': ('Recibos verdes explicados como se tivesses 5 anos 👇\n\n'
                  'Passas um recibo. Nem tudo é teu: parte vai para a Segurança Social, parte para o IRS '
                  'e, às vezes, parte para o IVA.\n\n'
                  'Guarda este post para quando tiveres dúvidas. E manda a quem acabou de abrir atividade.'),
        'fonte': 'Fonte: Código Contributivo (art. 155.º, 162.º, 168.º); Código do IRS (art. 101.º); Código do IVA (art. 53.º).',
        'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'verde', 'etiqueta': 'RECIBOS VERDES · 101',
             'titulo': 'Recibos verdes explicados **como se tivesses 5 anos**',
             'sub': '3 caixinhas, 2 prazos, 1 regra de ouro.', 'ecra': 'painel', 'corte': (0.085, 0.6)},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'Passas um recibo. **Nem tudo é teu.**',
             'corpo': 'Imagina três caixinhas. Uma parte do dinheiro que recebes vai para cada uma delas. O resto é que é teu.',
             'caixa': 'Regra de ouro: separa a parte do Estado no dia em que recebes.', 'cor_caixa': 'verde'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Caixinha 1: **Segurança Social**',
             'corpo': 'Se prestas serviços, pagas 21,4 % sobre 70 % do que ganhas por mês (média do trimestre). O mínimo é 20 € por mês.',
             'caixa': 'Paga-se entre o dia 10 e o dia 20 de cada mês.', 'cor_caixa': 'branco',
             'fonte': F_SS_TAXA + '; art. 155.º'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Caixinha 2: **IRS**',
             'corpo': 'Se o teu cliente é uma empresa, pode ficar com 23 % do recibo e entregá-lo às Finanças por ti. Não é dinheiro perdido: conta no acerto do IRS.',
             'caixa': 'Até 15.000 € por ano podes ficar dispensado desta retenção.', 'cor_caixa': 'branco',
             'fonte': F_RET},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': 'Caixinha 3: **IVA** (às vezes)',
             'corpo': 'Até 15.000 € por ano podes ficar isento de IVA (artigo 53.º). Passando esse valor, tens de cobrar IVA e entregá-lo ao Estado.',
             'caixa': 'Se passares os 15.000 €, tens 15 dias úteis para avisar as Finanças.', 'cor_caixa': 'laranja',
             'fonte': F_IVA53},
            {'tipo': 'lista', 'fundo': 'creme', 'titulo': 'Os **2 prazos** da Segurança Social',
             'itens': [('10 a 20', 'Todos os meses: pagar a contribuição', True),
                       ('Trimestral', 'Até ao fim de janeiro, abril, julho e outubro: declarar o que ganhaste')],
             'fonte': F_SS_PAG + '; art. 151.º-A n.º 3'},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'O Em Dia faz as contas e **avisa-te antes**.',
             'corpo': 'Diz-te quanto pagar, até quando e como.', 'ecra': 'painel', 'corte': (0.085, 0.72),
             'nota': 'Ecrã real · modo exemplo (a Maria)'},
            CTA,
        ],
    },
    {
        'id': 'C02', 'data': '2026-10-01', 'hora': '14:00', 'publico': 'Recibos verdes + pequenos empresários',
        'gancho': 'Outubro: os prazos que não podes falhar',
        'hashtags': H_RV,
        'corpo': ('Outubro começou. Estes são os prazos do mês 📅\n\n'
                  '• 6/10 — comunicação das faturas de setembro (quem usa programa de faturação)\n'
                  '• 12/10 — DMR, para quem tem trabalhadores\n'
                  '• 10 a 20/10 — pagar a Segurança Social\n'
                  '• 31/10 — declaração trimestral da Segurança Social (calha a um sábado: trata até sexta, 30)\n\n'
                  'Guarda para não te esqueceres.'),
        'fonte': F_AGENDA, 'contabilista': False,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'escuro', 'etiqueta': 'CALENDÁRIO · OUTUBRO 2026',
             'titulo': 'Outubro: os prazos que **não podes falhar**', 'sub': 'Guarda este post. Tem tudo o que vence este mês.'},
            {'tipo': 'lista', 'fundo': 'creme', 'titulo': 'Outubro, **dia a dia**',
             'itens': [('6/10', 'Comunicar as faturas de setembro (dia 5 é feriado, passa para dia 6)'),
                       ('12/10', 'DMR — só para quem tem trabalhadores'),
                       ('10 a 20', 'Pagar a Segurança Social (recibos verdes)', True),
                       ('31/10', 'Declaração trimestral da Segurança Social')],
             'fonte': F_AGENDA},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'Segurança Social: **paga entre 10 e 20**',
             'corpo': 'O valor sai do que declaraste no trimestre anterior. Paga-se na Segurança Social Direta ou por referência multibanco.',
             'caixa': 'Em 2026, o dia 20 de outubro é uma terça-feira.', 'cor_caixa': 'verde', 'fonte': F_SS_PAG},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Declaração trimestral: **até 31 de outubro**',
             'corpo': 'Declaras o que ganhaste em julho, agosto e setembro. É com esse valor que a Segurança Social calcula o que pagas nos próximos meses.',
             'caixa': 'Este ano, 31 de outubro é sábado. Não arrisques: trata até sexta, 30.', 'cor_caixa': 'laranja',
             'fonte': F_SS_DECL},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'E já a pensar em **novembro**',
             'corpo': 'Se tens IVA trimestral: a declaração do 3.º trimestre (julho a setembro) é até 20 de novembro e o pagamento até 25 de novembro.',
             'fonte': F_IVA_TRI},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'Todos os teus prazos **num calendário**',
             'corpo': 'Com aviso antes do dia. Se o prazo calha ao fim de semana, avisa na véspera útil.',
             'ecra': 'agenda', 'corte': (0.03, 0.62), 'nota': 'Ecrã real · modo exemplo (a Maria)'},
            CTA,
        ],
    },
    {
        'id': 'C03', 'data': '2026-10-02', 'hora': '16:00', 'publico': 'Brasileiros em Portugal', 'br': True,
        'gancho': 'Abriu atividade em Portugal? 7 palavras que você precisa conhecer',
        'hashtags': H_BR,
        'corpo': ('Chegou em Portugal, abriu atividade e ficou perdido com tanta sigla? 🇧🇷🇵🇹\n\n'
                  'Estas são as 7 palavras que você vai ouvir o tempo todo: NIF, NISS, recibo verde, Portal das Finanças, '
                  'Segurança Social Direta, IRS e IVA.\n\n'
                  'Salve este post e mande para quem acabou de chegar.'),
        'fonte': None, 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'verde', 'etiqueta': 'PARA QUEM CHEGOU DO BRASIL',
             'titulo': 'Abriu atividade em Portugal? **7 palavras** que você precisa conhecer',
             'sub': 'Sem sigla sem explicação.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': '**NIF** — o seu CPF daqui',
             'corpo': 'Número de Identificação Fiscal. É das Finanças e você usa em tudo: contrato, faturas, banco e recibos.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': '**NISS** — o número da Segurança Social',
             'corpo': 'Número de Identificação da Segurança Social. É com ele que você paga a contribuição e ganha direitos (doença, parentalidade, reforma).'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': '**Recibo verde** — a sua nota de serviço',
             'corpo': 'É o documento que você emite no Portal das Finanças quando recebe por um trabalho. É parecido com a nota fiscal do MEI.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': '**Portal das Finanças** e **Segurança Social Direta**',
             'corpo': 'Os dois sites onde tudo acontece. No primeiro: recibos, IRS e IVA. No segundo: declaração trimestral e pagamento da contribuição.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 5, 'titulo': '**IRS** e **IVA**',
             'corpo': 'IRS é o imposto sobre o que você ganha (parecido com o Imposto de Renda). IVA é o imposto sobre o consumo, que vai no preço. Até 15.000 € por ano você pode ficar isento de IVA.',
             'fonte': F_IVA53},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'O Em Dia explica tudo **em português simples**',
             'corpo': 'E também fala do jeito brasileiro, com "você".', 'ecra': 'painel-br', 'corte': (0.085, 0.72),
             'nota': 'Tela real · modo exemplo (a Maria)'},
            CTA_BR,
        ],
    },
    {
        'id': 'C04', 'data': '2026-10-03', 'hora': '11:00', 'publico': 'Freelancers e recibos verdes',
        'gancho': 'Recibo de 1.000 €: quanto chega à tua conta?',
        'hashtags': H_RV,
        'corpo': ('Passas um recibo de 1.000 € a uma empresa. Quanto chega à tua conta? 🤔\n\n'
                  'Se o cliente fizer retenção na fonte de 23 %, recebes 770 €. Os outros 230 € vão para as Finanças '
                  'em teu nome e contam no acerto do IRS.\n\n'
                  'Desliza para ver a conta toda (com a Segurança Social incluída).'),
        'fonte': F_RET + '; ' + F_SS_TAXA.replace('Fonte: ', ''), 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'escuro', 'etiqueta': 'FAZ A CONTA ANTES DE PASSAR',
             'titulo': 'Recibo de **1.000 €**: quanto chega à tua conta?', 'sub': 'Exemplo: serviços, isento de IVA, cliente empresa.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'O cliente pode ficar com **23 %**',
             'corpo': 'Chama-se retenção na fonte. A empresa entrega esse dinheiro às Finanças em teu nome.',
             'caixa': '1.000 € − 230 € = 770 € na tua conta', 'cor_caixa': 'verde', 'fonte': F_RET},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Os 230 € **não se perdem**',
             'corpo': 'São um adiantamento do teu IRS. No acerto do ano seguinte, contam a teu favor: se pagaste a mais, recebes de volta.',
             'fonte': F_RET},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Mas ainda há a **Segurança Social**',
             'corpo': 'Nos serviços, a base é 70 % do que ganhas. A taxa é 21,4 %.',
             'caixa': '1.000 € × 70 % × 21,4 % = 149,80 € por mês (se ganhares 1.000 € todos os meses)', 'cor_caixa': 'laranja',
             'fonte': F_SS_TAXA},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': 'Dispensa de retenção: **até 15.000 €**',
             'corpo': 'Se não ultrapassas 15.000 € por ano, podes pedir para não te reterem os 23 %. Aí recebes os 1.000 € — mas tens de guardar tu a parte do IRS.',
             'fonte': F_RET},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'A calculadora de recibo do Em Dia faz isto **num segundo**',
             'ecra': 'recibos', 'corte': (0.03, 0.72), 'nota': 'Ecrã real · modo exemplo (a Maria)'},
            CTA,
        ],
    },
    {
        'id': 'C05', 'data': '2026-10-06', 'hora': '13:30', 'publico': 'Quem abriu atividade há pouco',
        'gancho': '1.º ano a recibos verdes: o que muda no 13.º mês',
        'hashtags': H_RV,
        'corpo': ('Abriste atividade há menos de um ano? Lê isto antes do 13.º mês 👇\n\n'
                  'Nos primeiros 12 meses estás isento de pagar Segurança Social. Quando a isenção acaba, começam os '
                  'dois prazos: pagar todos os meses e declarar de 3 em 3 meses.\n\n'
                  'Marca na agenda o dia em que abriste atividade.'),
        'fonte': F_SS_ISENCAO, 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'verde', 'etiqueta': 'PRIMEIRO ANO',
             'titulo': 'O 1.º ano é **sem Segurança Social**. E depois?', 'sub': 'O que muda quando fazes 12 meses de atividade.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': '12 meses de **isenção**',
             'corpo': 'Quando abres atividade pela primeira vez, ficas isento de pagar contribuições nos primeiros 12 meses.',
             'fonte': F_SS_ISENCAO},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'No 13.º mês **começa a contar**',
             'corpo': 'Passas a pagar todos os meses (entre o dia 10 e o dia 20) e a declarar o que ganhaste de 3 em 3 meses.',
             'caixa': 'O erro mais comum: esquecer que a isenção acabou.', 'cor_caixa': 'laranja',
             'fonte': F_SS_PAG + '; art. 151.º-A'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Quanto vais pagar?',
             'corpo': 'Serviços: 21,4 % sobre 70 % do que ganhas por mês, em média. Vendas: sobre 20 %. Nunca menos de 20 € por mês.',
             'caixa': 'Quem ganha 1.200 € por mês em serviços paga 179,76 € por mês.', 'cor_caixa': 'verde',
             'fonte': F_SS_TAXA},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': 'Começa **já** a guardar',
             'corpo': 'Mesmo isento, separa um bocadinho de cada recibo. Quando a isenção acabar, não há sustos.'},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'O cofre do imposto: **guarda a fatia** de cada ganho',
             'corpo': 'É um caderno: não mexe no teu dinheiro.', 'ecra': 'cofre', 'corte': (0.03, 0.66),
             'nota': 'Ecrã real · modo exemplo (a Maria)'},
            CTA,
        ],
    },
    {
        'id': 'C06', 'data': '2026-10-08', 'hora': '14:00', 'publico': 'Recibos verdes',
        'gancho': 'Segurança Social: como se faz a conta (com exemplo)',
        'hashtags': H_RV,
        'corpo': ('Quanto pagas à Segurança Social a recibos verdes? A conta em 3 passos 🧮\n\n'
                  '1. Média do que ganhaste por mês no trimestre\n'
                  '2. × 70 % (serviços) ou × 20 % (vendas)\n'
                  '3. × 21,4 %\n\n'
                  'Exemplo: 1.200 € por mês → 179,76 €. Paga-se entre o dia 10 e o dia 20.'),
        'fonte': F_SS_TAXA + '; art. 155.º', 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'escuro', 'etiqueta': 'SEGURANÇA SOCIAL',
             'titulo': 'Quanto pagas à Segurança Social? **A conta em 3 passos.**', 'sub': 'Com um exemplo de 1.200 € por mês.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'A média do **trimestre**',
             'corpo': 'Soma o que ganhaste nos 3 meses e divide por 3. É isto que declaras na declaração trimestral.',
             'caixa': 'Exemplo: 3.600 € em 3 meses → 1.200 € por mês', 'cor_caixa': 'verde', 'fonte': F_SS_DECL},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Só conta **uma parte**',
             'corpo': 'Nos serviços conta 70 %. Nas vendas (produtos) conta 20 %.',
             'caixa': '1.200 € × 70 % = 840 €', 'cor_caixa': 'verde', 'fonte': F_SS_TAXA},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'A taxa é **21,4 %**',
             'corpo': 'É a taxa dos trabalhadores independentes. O mínimo a pagar é 20 € por mês.',
             'caixa': '840 € × 21,4 % = 179,76 € por mês', 'cor_caixa': 'laranja', 'fonte': F_SS_TAXA},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': 'Podes **ajustar** ±25 %',
             'corpo': 'Na Segurança Social Direta podes subir ou baixar a base até 25 %. Paga-se entre o dia 10 e o dia 20 do mês.',
             'fonte': F_SS_TAXA + '; art. 155.º'},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'No Em Dia: o valor, o prazo e **«Ver como pagar»**',
             'ecra': 'painel', 'corte': (0.085, 0.62), 'nota': 'Ecrã real · modo exemplo (a Maria)'},
            CTA,
        ],
    },
    {
        'id': 'C07', 'data': '2026-10-10', 'hora': '11:00', 'publico': 'Trabalhadores por conta de outrem',
        'gancho': 'O teu recibo de vencimento, linha a linha',
        'hashtags': H_CO,
        'corpo': ('Trabalhas por conta de outrem? O teu recibo de vencimento explicado, linha a linha 🧾\n\n'
                  '• 11 % do teu salário vai para a Segurança Social (a empresa paga mais 23,75 %)\n'
                  '• O IRS retido depende das tabelas de retenção da AT\n'
                  '• Subsídio de Natal: até 15 de dezembro\n'
                  '• Horas extra: +25 % na 1.ª hora, +37,5 % nas seguintes (até 100 h por ano)\n\n'
                  'Guarda e confere o teu próximo recibo.'),
        'fonte': F_CT, 'contabilista': False,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'verde', 'etiqueta': 'CONTA DE OUTREM',
             'titulo': 'O teu recibo de vencimento, **linha a linha**', 'sub': 'Para confirmares se está tudo certo.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'Segurança Social: **11 %**',
             'corpo': 'Sai do teu salário bruto. A empresa paga, por cima, mais 23,75 % (não aparece como desconto teu).',
             'fonte': 'Fonte: ISS, «Taxas contributivas» (Código Contributivo, art. 53.º)'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Retenção de **IRS**',
             'corpo': 'É um adiantamento do IRS do ano. A percentagem vem das tabelas de retenção da AT e depende do salário e da tua família.',
             'caixa': 'No acerto do IRS, se reteve a mais, recebes de volta.', 'cor_caixa': 'verde',
             'fonte': 'Fonte: AT, tabelas de retenção na fonte 2026'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Subsídio de Natal: **até 15 de dezembro**',
             'corpo': 'Vale um mês de salário. No ano em que entras ou sais, é proporcional ao tempo que trabalhaste.',
             'fonte': 'Fonte: Código do Trabalho, art. 263.º'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': 'Horas extra: **+25 %** e **+37,5 %**',
             'corpo': 'Até 100 horas por ano: +25 % na 1.ª hora e +37,5 % nas seguintes. Em dia de descanso ou feriado: +50 %.',
             'fonte': 'Fonte: Código do Trabalho, art. 268.º (Lei 13/2023)'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 5, 'titulo': 'Férias: **22 dias úteis**',
             'corpo': 'É o mínimo por ano. O subsídio de férias paga-se antes das férias, salvo acordo escrito.',
             'fonte': 'Fonte: Código do Trabalho, art. 238.º e 264.º'},
            CTA,
        ],
    },
    {
        'id': 'C08', 'data': '2026-10-13', 'hora': '13:30', 'publico': 'Recibos verdes (IVA)',
        'gancho': 'Isenção de IVA: o limite dos 15.000 €',
        'hashtags': H_IVA,
        'corpo': ('Estás isento de IVA? Então este número é para ti: 15.000 € 👀\n\n'
                  'É o limite anual da isenção do artigo 53.º. Se passares, tens 15 dias úteis para avisar as Finanças. '
                  'Se passares 18.750 € (mais 25 %), perdes a isenção logo nesse recibo.\n\n'
                  'Sabes quanto já faturaste este ano?'),
        'fonte': F_IVA53, 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'escuro', 'etiqueta': 'IVA · ARTIGO 53.º', 'etiqueta_laranja': True,
             'titulo': 'Estás isento de IVA? **Não passes os 15.000 €** sem saber.', 'sub': 'O que acontece quando chegas ao limite.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'O limite é **15.000 €** por ano',
             'corpo': 'Enquanto não passares este valor de faturação anual, podes ficar isento de IVA pelo artigo 53.º.',
             'fonte': F_IVA53},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Passaste? **15 dias úteis**',
             'corpo': 'É o prazo para comunicares às Finanças que deixaste de estar isento.',
             'caixa': 'A partir daí, os teus recibos passam a levar IVA.', 'cor_caixa': 'laranja', 'fonte': F_IVA53},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Acima de **18.750 €**: perdes logo',
             'corpo': 'Se ultrapassares o limite em mais de 25 %, a isenção acaba no próprio recibo que te fez passar.',
             'fonte': F_IVA53},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'A **Vigia do IVA** mostra onde estás',
             'corpo': 'E avisa-te aos 12.000 €, antes de chegares ao limite.', 'ecra': 'painel-baixo', 'corte': (0.61, 0.80),
             'cartao': True, 'nota': 'Ecrã real · modo exemplo (a Maria)'},
            CTA,
        ],
    },
    {
        'id': 'C09', 'data': '2026-10-15', 'hora': '14:00', 'publico': 'TVDE e estafetas com carro',
        'gancho': 'O carro também tem prazos',
        'hashtags': H_TVDE,
        'corpo': ('Quem trabalha com o carro tem mais prazos do que pensa 🚗\n\n'
                  '• IUC: paga-se até ao fim do mês da matrícula\n'
                  '• Inspeção: nos ligeiros, aos 4, 6 e 8 anos e depois todos os anos\n'
                  '• Seguro: compara antes de renovar\n\n'
                  'O Em Dia junta os lembretes do carro aos prazos dos recibos verdes.'),
        'fonte': F_IUC, 'contabilista': False,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'verde', 'etiqueta': 'TVDE · ESTAFETAS · CARRO',
             'titulo': 'O carro **também tem prazos**', 'sub': 'IUC, inspeção e seguro: os 3 que custam multas.', 'ecra': 'carro', 'corte': (0.03, 0.6)},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'IUC: **no mês da matrícula**',
             'corpo': 'O Imposto Único de Circulação paga-se até ao fim do mês em que o carro foi matriculado. Todos os anos.',
             'fonte': 'Fonte: Portal das Finanças → IUC'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Inspeção: **4, 6, 8 anos**',
             'corpo': 'Nos carros ligeiros, a inspeção periódica é aos 4, 6 e 8 anos e depois todos os anos.',
             'caixa': 'No TVDE há regras próprias para o carro. Confirma no IMT.', 'cor_caixa': 'laranja',
             'fonte': 'Fonte: IMT, tipos de inspeção'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Seguro: **compara antes**',
             'corpo': 'O Em Dia lembra-te do seguro dias antes da renovação, a tempo de pedires 2 ou 3 simulações.'},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'Quanto te custa **cada quilómetro**?',
             'corpo': 'Regista os abastecimentos e vê o custo por km.', 'ecra': 'carro-baixo', 'corte': (0.44, 0.63),
             'cartao': True, 'nota': 'Ecrã real · modo exemplo (a Maria)'},
            CTA,
        ],
    },
    {
        'id': 'C10', 'data': '2026-10-16', 'hora': '16:00', 'publico': 'Pequenos empresários',
        'gancho': 'ENI ou sociedade? A diferença em 5 lâminas',
        'hashtags': H_EMP,
        'corpo': ('Vais crescer e perguntas-te: continuo em nome individual ou abro uma sociedade? 🏢\n\n'
                  'ENI é a própria pessoa: paga IRS e responde com o seu património. A sociedade é uma pessoa coletiva: '
                  'paga IRC, o gerente desconta 34,75 % para a Segurança Social e é obrigatório ter contabilista certificado.\n\n'
                  'A escolha certa depende de muitos números: fala com um contabilista.'),
        'fonte': F_ENI, 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'escuro', 'etiqueta': 'PEQUENOS EMPRESÁRIOS',
             'titulo': 'ENI ou sociedade? **A diferença** sem palavrões.', 'sub': 'O essencial antes de falares com o contabilista.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'ENI = **tu próprio**',
             'corpo': 'Empresário em nome individual. Pagas IRS e respondes pelas dívidas com o teu património.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Sociedade = **outra pessoa**',
             'corpo': 'É uma pessoa coletiva, separada de ti. Paga IRC. O gerente desconta 34,75 % para a Segurança Social.',
             'fonte': F_ENI},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Na sociedade, **contabilista obrigatório**',
             'corpo': 'Tens de ter um contabilista certificado. E há mais prazos: IRC (Modelo 22), IES, pagamentos por conta.',
             'caixa': 'IRC: pagamentos por conta a 31/07, 30/09 e 15/12 (2026).', 'cor_caixa': 'branco',
             'fonte': 'Fonte: AT, resumo anual das obrigações de pagamento 2026'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': 'Prazos **todos os meses**',
             'corpo': 'Com trabalhadores: DMR até dia 10 e contribuições entre dia 1 e 25. Comunicação das faturas até dia 5.',
             'fonte': 'Fonte: AT, agenda fiscal 2026; Código Contributivo, art. 43.º'},
            {'tipo': 'cta', 'fundo': 'verde', 'titulo': 'Os prazos da empresa **num calendário**.',
             'pontos': ['IVA, SAF-T, DMR e IRC', 'Aviso antes de cada prazo', 'Não substitui o teu contabilista']},
        ],
    },
    {
        'id': 'C11', 'data': '2026-10-17', 'hora': '11:00', 'publico': 'Recibos verdes',
        'gancho': '5 erros que custam dinheiro a quem está a recibos verdes',
        'hashtags': H_RV,
        'corpo': ('5 erros que custam dinheiro a quem está a recibos verdes ❌\n\n'
                  '1. Gastar tudo o que entra\n2. Esquecer a declaração trimestral\n3. Passar os 15.000 € sem avisar\n'
                  '4. Não pedir fatura com NIF\n5. Não saber se estás dispensado de retenção\n\n'
                  'Qual destes já te aconteceu? Conta nos comentários.'),
        'fonte': 'Fonte: Código Contributivo, art. 151.º-A e 155.º; Código do IVA, art. 53.º; Código do IRS, art. 78.º-A a 78.º-F e 101.º.',
        'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'laranja', 'etiqueta': 'LÊ ANTES DO PRÓXIMO RECIBO',
             'titulo': '5 erros que **custam dinheiro** a quem está a recibos verdes', 'acento': (17, 24, 39)},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'Gastar **tudo** o que entra',
             'corpo': 'Parte é da Segurança Social e do IRS. Separa-a no dia em que recebes.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Esquecer a **declaração trimestral**',
             'corpo': 'É até ao fim de janeiro, abril, julho e outubro. Sem ela, a conta da Segurança Social fica errada.',
             'fonte': F_SS_DECL},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Passar os **15.000 €** sem avisar',
             'corpo': 'Quem está isento de IVA tem 15 dias úteis para comunicar que passou o limite.', 'fonte': F_IVA53},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': 'Não pedir fatura **com NIF**',
             'corpo': 'Saúde, educação, renda, restaurantes, oficina, cabeleireiro: tudo isto pode baixar o teu IRS.',
             'fonte': F_DED},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 5, 'titulo': 'Não saber da **dispensa de retenção**',
             'corpo': 'Até 15.000 € por ano podes pedir que não te retenham os 23 %. Mas aí és tu que guardas.',
             'fonte': F_RET},
            CTA,
        ],
    },
    {
        'id': 'C12', 'data': '2026-10-20', 'hora': '13:30', 'publico': 'Toda a gente (IRS)',
        'gancho': 'IRS: as faturas que te baixam o imposto',
        'hashtags': H_IRS,
        'corpo': ('Ainda faltam meses para o IRS, mas as faturas contam desde janeiro 🧾\n\n'
                  '• Saúde: 15 %, até 1.000 €\n• Educação: 30 %, até 800 €\n• Renda da casa: 15 %, até 800 €\n'
                  '• IVA de restaurantes, oficinas, cabeleireiros, ginásios e veterinários: 15 %, até 250 €\n'
                  '• Despesas gerais familiares: 35 %, até 250 €\n\n'
                  'Pede sempre fatura com NIF. E valida-as no e-Fatura até 25 de fevereiro.'),
        'fonte': F_DED, 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'verde', 'etiqueta': 'IRS · DEDUÇÕES',
             'titulo': 'As faturas que **te baixam o IRS**', 'sub': 'Pede sempre com NIF. Isto conta desde janeiro.'},
            {'tipo': 'lista', 'fundo': 'creme', 'titulo': 'Quanto **desconta** cada uma',
             'itens': [('15 %', 'Saúde, até 1.000 €'), ('30 %', 'Educação, até 800 €'), ('15 %', 'Renda da casa, até 800 €'),
                       ('35 %', 'Despesas gerais familiares, até 250 €')],
             'fonte': F_DED},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'O **IVA** de algumas faturas',
             'corpo': 'Restaurantes, oficinas, cabeleireiros, ginásios e veterinários: 15 % do IVA que pagaste conta como dedução, até 250 €.',
             'fonte': F_DED},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': '**600 €** por dependente',
             'corpo': 'Cada dependente dá uma dedução fixa de 600 €.', 'fonte': F_DED},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Valida no **e-Fatura**',
             'corpo': 'Tens até 25 de fevereiro para confirmar as faturas do ano anterior no e-Fatura (Portal das Finanças).',
             'caixa': 'Faturas pendentes que não confirmas podem não contar.', 'cor_caixa': 'laranja',
             'fonte': 'Fonte: AT, agenda declarativa 2026'},
            CTA,
        ],
    },
    {
        'id': 'C13', 'data': '2026-10-22', 'hora': '14:00', 'publico': 'Recibos verdes',
        'gancho': 'Declaração trimestral: faltam 9 dias',
        'hashtags': H_RV,
        'corpo': ('Faltam 9 dias para a declaração trimestral da Segurança Social ⏳\n\n'
                  'Declaras o que ganhaste em julho, agosto e setembro, na Segurança Social Direta. '
                  'O prazo é 31 de outubro — que este ano é um sábado. Trata até sexta, 30.\n\n'
                  'Marca alguém que precisa de ler isto.'),
        'fonte': F_SS_DECL, 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'laranja', 'etiqueta': 'ATÉ 31 DE OUTUBRO',
             'titulo': 'Declaração trimestral: **o que é e como não falhar**', 'acento': (17, 24, 39),
             'sub': 'Para quem está a recibos verdes.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'O que **declaras**',
             'corpo': 'O que ganhaste nos 3 meses anteriores: julho, agosto e setembro. Os valores dos recibos verdes, sem IVA.',
             'fonte': F_SS_DECL},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Para que **serve**',
             'corpo': 'É com este valor que a Segurança Social calcula quanto pagas em novembro, dezembro e janeiro.',
             'fonte': F_SS_TAXA},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 3, 'titulo': 'Onde se **faz**',
             'corpo': 'Na Segurança Social Direta, com o NISS e a palavra-passe. Confirma os valores antes de submeter.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 4, 'titulo': 'Até **31 de outubro**',
             'corpo': 'Em 2026, o dia 31 é sábado.', 'caixa': 'Não arrisques: trata até sexta-feira, 30 de outubro.',
             'cor_caixa': 'laranja', 'fonte': F_SS_DECL},
            {'tipo': 'ecra', 'fundo': 'branco', 'titulo': 'O Em Dia **avisa-te antes**',
             'ecra': 'agenda-baixo', 'corte': (0.1, 0.44), 'cartao': True, 'nota': 'Ecrã real · modo exemplo (a Maria)'},
            CTA,
        ],
    },
    {
        'id': 'C14', 'data': '2026-10-24', 'hora': '11:00', 'publico': 'Jovens até 35 anos',
        'gancho': 'IRS Jovem: tens até 35 anos?',
        'hashtags': '#irsjovem #irs #jovens #financaspessoais #portugal',
        'corpo': ('Tens até 35 anos? O IRS Jovem pode tirar-te imposto dos primeiros 10 anos de rendimentos 🎓\n\n'
                  '• 1.º ano: 100 % isento\n• 2.º ao 4.º: 75 %\n• 5.º ao 7.º: 50 %\n• 8.º ao 10.º: 25 %\n\n'
                  'Com um limite de 29.542,15 € por ano. Serve para quem trabalha por conta de outrem e para recibos verdes. '
                  'Escolhe-se na declaração de IRS.'),
        'fonte': F_JOVEM, 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'verde', 'etiqueta': 'IRS JOVEM 2026',
             'titulo': 'Tens até 35 anos? **O IRS Jovem** é para ti.', 'sub': 'Contrato ou recibos verdes: os dois contam.'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'Quem **pode**',
             'corpo': 'Até 35 anos, que não seja dependente de ninguém no IRS. Vale nos primeiros 10 anos em que tens rendimentos do trabalho.',
             'fonte': F_JOVEM},
            {'tipo': 'lista', 'fundo': 'creme', 'titulo': 'Quanto fica **isento**',
             'itens': [('1.º ano', '100 % do rendimento'), ('2.º a 4.º', '75 %'), ('5.º a 7.º', '50 %'), ('8.º a 10.º', '25 %')],
             'fonte': F_JOVEM},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Há um **limite**',
             'corpo': 'A isenção vai até 55 vezes o IAS por ano: 29.542,15 € em 2026.',
             'caixa': 'Escolhe-se na declaração de IRS: não te esqueças de marcar.', 'cor_caixa': 'verde', 'fonte': F_JOVEM},
            CTA,
        ],
    },
    {
        'id': 'C15', 'data': '2026-10-27', 'hora': '13:30', 'publico': 'Recibos verdes (IVA) + conta de outrem',
        'gancho': 'Novembro está aí: o que vence',
        'hashtags': H_IVA,
        'corpo': ('Novembro está quase aí. O que vence 📅\n\n'
                  '• 20/11 — declaração do IVA do 3.º trimestre (julho a setembro)\n'
                  '• 25/11 — pagamento desse IVA\n'
                  '• 10 a 20/11 — Segurança Social do mês\n\n'
                  'E para quem tem contrato: o subsídio de Natal tem de ser pago até 15 de dezembro.'),
        'fonte': F_IVA_TRI + '; Código Contributivo, art. 155.º; Código do Trabalho, art. 263.º', 'contabilista': True,
        'laminas': [
            {'tipo': 'capa', 'fundo': 'escuro', 'etiqueta': 'CALENDÁRIO · NOVEMBRO 2026',
             'titulo': 'Novembro está aí. **O que vence.**', 'sub': 'IVA trimestral, Segurança Social e o subsídio de Natal.'},
            {'tipo': 'lista', 'fundo': 'creme', 'titulo': 'Novembro, **dia a dia**',
             'itens': [('10 a 20', 'Pagar a Segurança Social'), ('20/11', 'Declaração do IVA do 3.º trimestre', True),
                       ('25/11', 'Pagar o IVA do 3.º trimestre')],
             'fonte': F_IVA_TRI + '; Código Contributivo, art. 155.º'},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 1, 'titulo': 'IVA trimestral: **só se não estás isento**',
             'corpo': 'Se estás isento pelo artigo 53.º, não entregas esta declaração. Se cobras IVA, declaras julho, agosto e setembro.',
             'fonte': F_IVA_TRI},
            {'tipo': 'texto', 'fundo': 'creme', 'n': 2, 'titulo': 'Contrato? **Subsídio de Natal**',
             'corpo': 'Um mês de salário, pago até 15 de dezembro. Proporcional se entraste este ano.',
             'fonte': 'Fonte: Código do Trabalho, art. 263.º'},
            CTA,
        ],
    },
]

# ------------------------------------------------------------------ reels
FIM = {'tipo': 'fim', 'dur': 3.6}

REELS = [
    {'id': 'R01', 'data': '2026-09-28', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': H_RV,
     'gancho': 'Trabalhas a recibos verdes? Estás em dia?',
     'corpo': 'Trabalhas a recibos verdes e nunca sabes se estás em dia? O Em Dia diz-te o que fazer agora, quanto guardar e que prazo vem a seguir. Em português simples.',
     'planos': [
         {'tipo': 'gancho', 'texto': 'Trabalhas a recibos verdes. **Estás em dia?**', 'etiqueta': 'EM DIA', 'dur': 2.6},
         {'tipo': 'ecra', 'legenda': 'Diz-te **o que fazer agora**', 'ecra': 'painel', 'pan': (0.0, 0.0), 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         {'tipo': 'ecra', 'legenda': 'Todos os prazos **num calendário**', 'ecra': 'agenda', 'pan': (0.0, 0.25), 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R02', 'data': '2026-09-30', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': H_RV,
     'gancho': 'Ganhas 1.200 € por mês a recibos verdes?',
     'corpo': 'Ganhas 1.200 € por mês a recibos verdes (serviços)? A Segurança Social é 21,4 % sobre 70 % do que ganhas: 179,76 € por mês. Paga-se entre o dia 10 e o dia 20.',
     'fonte': F_SS_TAXA,
     'planos': [
         {'tipo': 'gancho', 'texto': 'Ganhas **1.200 €** por mês a recibos verdes?', 'sub': 'Vê quanto vai para a Segurança Social.', 'dur': 2.8,
          'etiqueta': 'SEGURANÇA SOCIAL'},
         {'tipo': 'numero', 'antes': 'Por mês, pagas', 'numero': '179,76 €', 'legenda': '21,4 % sobre 70 % do que ganhas (serviços).',
          'fonte': F_SS_TAXA, 'dur': 3.8, 'fundo': 'escuro'},
         {'tipo': 'ecra', 'legenda': 'O Em Dia faz a conta e diz **até quando pagar**', 'ecra': 'painel', 'dur': 3.6, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R03', 'data': '2026-10-01', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': H_RV,
     'gancho': 'Outubro tem 2 prazos da Segurança Social',
     'corpo': 'Outubro tem 2 prazos da Segurança Social para quem está a recibos verdes: pagar entre 10 e 20 e declarar o trimestre até 31 (sábado — trata até sexta, 30).',
     'fonte': F_AGENDA,
     'planos': [
         {'tipo': 'gancho', 'texto': 'Outubro tem **2 prazos** que não podes falhar.', 'etiqueta': 'RECIBOS VERDES', 'dur': 2.6},
         {'tipo': 'lista', 'titulo': 'Outubro', 'itens': [('10 a 20', 'Pagar a Segurança Social', True), ('31/10', 'Declaração trimestral (31 é sábado: trata até dia 30)')],
          'fonte': F_AGENDA, 'dur': 3.8, 'fundo': 'creme'},
         {'tipo': 'ecra', 'legenda': 'O Em Dia **avisa-te antes**', 'ecra': 'agenda', 'pan': (0.0, 0.3), 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R04', 'data': '2026-10-02', 'hora': '20:30', 'publico': 'TVDE', 'hashtags': H_TVDE,
     'gancho': 'Fim do turno. Quanto fica mesmo para ti?',
     'corpo': 'Fim do turno. Entrou dinheiro, mas quanto fica mesmo para ti? No Em Dia escreves o que ganhaste e ele aponta a fatia do imposto no cofre. É um caderno: não mexe no teu dinheiro.',
     'planos': [
         {'tipo': 'gancho', 'texto': 'Fim do turno. **Quanto fica mesmo para ti?**', 'etiqueta': 'TVDE', 'dur': 2.6, 'fundo': 'escuro'},
         {'tipo': 'ecra', 'legenda': 'Escreves **o que ganhaste**', 'ecra': 'dinheiro', 'pan': (0.0, 0.2), 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         {'tipo': 'ecra', 'legenda': 'E ele aponta **a parte do imposto**', 'ecra': 'cofre', 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R05', 'data': '2026-10-04', 'hora': '20:30', 'publico': 'Brasileiros em Portugal', 'br': True, 'hashtags': H_BR,
     'gancho': 'Chegou em Portugal e virou recibo verde?',
     'corpo': 'Chegou em Portugal e virou recibo verde? Segurança Social, IRS, IVA... O Em Dia explica tudo em português simples, fala do jeito brasileiro e avisa antes de cada prazo.',
     'planos': [
         {'tipo': 'gancho', 'texto': 'Chegou em Portugal e **virou recibo verde?**', 'etiqueta': 'PARA QUEM VEIO DO BRASIL', 'dur': 2.8},
         {'tipo': 'ecra', 'legenda': 'O Em Dia diz **o que fazer agora**', 'ecra': 'painel-br', 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Tela real · modo exemplo'},
         {'tipo': 'ecra', 'legenda': 'E explica **do jeito brasileiro**', 'ecra': 'recibos-br', 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Tela real · modo exemplo'},
         FIM]},
    {'id': 'R06', 'data': '2026-10-05', 'hora': '20:30', 'publico': 'Recibos verdes + empresários', 'hashtags': H_RV,
     'gancho': 'Hoje é feriado. E os prazos?',
     'corpo': 'Hoje é feriado (5 de Outubro). Quando um prazo do Estado calha num feriado ou fim de semana, passa para o dia útil seguinte: este mês, a comunicação das faturas de setembro vai até dia 6. O Em Dia avisa-te na véspera útil.',
     'fonte': 'Fonte: AT, agenda fiscal 2026 (nota a); Código do Trabalho, art. 234.º',
     'planos': [
         {'tipo': 'gancho', 'texto': 'Hoje é feriado. **E os prazos?**', 'etiqueta': '5 DE OUTUBRO', 'dur': 2.4},
         {'tipo': 'gancho', 'texto': 'Um prazo que calha num feriado **passa para o dia útil seguinte**.', 'sub': 'Ex.: comunicar as faturas de setembro — até dia 6.',
          'dur': 3.8, 'fundo': 'escuro', 'logo': False},
         {'tipo': 'ecra', 'legenda': 'O Em Dia avisa-te **na véspera útil**', 'ecra': 'agenda-baixo', 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R07', 'data': '2026-10-07', 'hora': '20:30', 'publico': 'TVDE', 'hashtags': H_TVDE,
     'gancho': 'Vale a pena esta corrida?',
     'corpo': 'Vale a pena esta corrida? Escreve quanto te pagam e quantos quilómetros são. O Em Dia diz-te o que fica mesmo para ti, com o gasto do teu carro.',
     'planos': [
         {'tipo': 'gancho', 'texto': '**Vale a pena** esta corrida?', 'etiqueta': 'TVDE', 'dur': 2.2, 'fundo': 'escuro'},
         {'tipo': 'ecra', 'legenda': 'Escreves o preço e os **quilómetros**', 'ecra': 'vale-a-pena', 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         {'tipo': 'ecra', 'legenda': 'Ele conta com **o gasto do teu carro**', 'ecra': 'vale-a-pena', 'pan': (0.2, 0.55), 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R08', 'data': '2026-10-08', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': H_RV,
     'gancho': 'A Segurança Social paga-se entre o dia 10 e o dia 20',
     'corpo': 'Lembrete: a contribuição da Segurança Social paga-se entre o dia 10 e o dia 20 de cada mês. Em outubro, o último dia é terça, 20. No Em Dia tens o valor e o botão «Ver como pagar».',
     'fonte': F_SS_PAG,
     'planos': [
         {'tipo': 'gancho', 'texto': 'A Segurança Social paga-se **entre o dia 10 e o dia 20**.', 'etiqueta': 'LEMBRETE', 'dur': 3.0},
         {'tipo': 'numero', 'antes': 'Em outubro, o último dia é', 'numero': '20/10', 'legenda': 'terça-feira', 'fonte': F_SS_PAG, 'dur': 3.0,
          'fundo': 'escuro'},
         {'tipo': 'ecra', 'legenda': 'No Em Dia: **«Ver como pagar»**', 'ecra': 'painel', 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R09', 'data': '2026-10-09', 'hora': '20:30', 'publico': 'Trabalhadores por conta de outrem', 'hashtags': H_CO,
     'gancho': 'Tens contrato? 11 % do teu salário vai para a Segurança Social',
     'corpo': 'Tens contrato de trabalho? 11 % do teu salário bruto vai para a Segurança Social. E a empresa paga, por cima, mais 23,75 %. É isto que te dá direito a subsídio de desemprego, baixa e reforma.',
     'fonte': 'Fonte: ISS, «Taxas contributivas» (Código Contributivo, art. 53.º)',
     'planos': [
         {'tipo': 'gancho', 'texto': 'Tens contrato? **Olha para o teu recibo.**', 'etiqueta': 'CONTA DE OUTREM', 'dur': 2.4},
         {'tipo': 'numero', 'antes': 'Do teu salário bruto sai', 'numero': '11 %', 'legenda': 'para a Segurança Social.', 'dur': 3.0, 'fundo': 'escuro',
          'fonte': 'Fonte: ISS, «Taxas contributivas»'},
         {'tipo': 'numero', 'antes': 'E a empresa paga, por cima,', 'numero': '23,75 %', 'legenda': 'É isto que te dá direito a baixa, desemprego e reforma.',
          'dur': 3.6, 'fundo': 'verde', 'fonte': 'Fonte: ISS, «Taxas contributivas»'},
         FIM]},
    {'id': 'R10', 'data': '2026-10-11', 'hora': '20:30', 'publico': 'Toda a gente', 'hashtags': '#poupar #financaspessoais #fidelizacao #contas #portugal',
     'gancho': 'O teu contrato da internet está a acabar?',
     'corpo': 'Quando a fidelização acaba, a operadora renova sozinha e o preço pode subir. O Em Dia avisa-te umas semanas antes, a tempo de pedires um preço melhor ou mudares sem multa.',
     'planos': [
         {'tipo': 'gancho', 'texto': 'O teu contrato da internet **está a acabar?**', 'etiqueta': 'FIM DA FIDELIZAÇÃO', 'dur': 2.6},
         {'tipo': 'ecra', 'legenda': 'O Em Dia **avisa-te antes**', 'ecra': 'radar', 'dur': 3.6, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         {'tipo': 'gancho', 'texto': 'A tempo de pedires **um preço melhor**.', 'dur': 2.6, 'fundo': 'escuro', 'logo': False},
         FIM]},
    {'id': 'R11', 'data': '2026-10-12', 'hora': '20:30', 'publico': 'Recibos verdes + imigrantes', 'hashtags': H_RV,
     'gancho': 'O senhorio pediu prova de rendimento?',
     'corpo': 'O senhorio ou o banco pediu prova de quanto ganhas? No Em Dia fazes uma folha com os últimos 3, 6 ou 12 meses, a partir do que registaste. Não substitui a declaração de IRS nem uma certidão das Finanças.',
     'planos': [
         {'tipo': 'gancho', 'texto': 'O senhorio pediu **prova de rendimento?**', 'etiqueta': 'CASA · BANCO', 'dur': 2.6},
         {'tipo': 'ecra', 'legenda': 'Escolhes **3, 6 ou 12 meses**', 'ecra': 'prova', 'dur': 3.4, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         {'tipo': 'gancho', 'texto': 'E sai **uma folha em PDF** com o que registaste.', 'sub': 'Não substitui a declaração de IRS nem uma certidão das Finanças.',
          'dur': 3.4, 'fundo': 'escuro', 'logo': False},
         FIM]},
    {'id': 'R12', 'data': '2026-10-14', 'hora': '20:30', 'publico': 'Recibos verdes (IVA)', 'hashtags': H_IVA,
     'gancho': 'Isento de IVA? Sabes quanto falta para os 15.000 €?',
     'corpo': 'Estás isento de IVA pelo artigo 53.º? O limite é 15.000 € por ano. A Vigia do IVA do Em Dia mostra quanto já faturaste e avisa-te antes de chegares lá.',
     'fonte': F_IVA53,
     'planos': [
         {'tipo': 'gancho', 'texto': 'Isento de IVA? **Sabes quanto falta?**', 'etiqueta': 'IVA · ARTIGO 53.º', 'dur': 2.6},
         {'tipo': 'numero', 'antes': 'O limite anual é', 'numero': '15.000 €', 'legenda': 'Se passares, tens 15 dias úteis para avisar as Finanças.',
          'fonte': F_IVA53, 'dur': 3.6, 'fundo': 'escuro'},
         {'tipo': 'ecra', 'legenda': 'A **Vigia do IVA** mostra onde estás', 'ecra': 'painel-baixo', 'pan': (0.0, 1.0), 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R13', 'data': '2026-10-15', 'hora': '20:30', 'publico': 'TVDE e estafetas', 'hashtags': H_TVDE,
     'gancho': 'IUC: paga-se no mês da matrícula',
     'corpo': 'O IUC paga-se até ao fim do mês da matrícula do carro. O Em Dia junta o IUC, a inspeção e o seguro aos prazos dos recibos verdes, com aviso antes.',
     'fonte': 'Fonte: Portal das Finanças → IUC',
     'planos': [
         {'tipo': 'gancho', 'texto': 'O teu carro **também tem prazos**.', 'etiqueta': 'CARRO', 'dur': 2.4, 'fundo': 'escuro'},
         {'tipo': 'gancho', 'texto': 'O IUC paga-se **até ao fim do mês da matrícula**.', 'dur': 3.0, 'logo': False, 'fonte': ''},
         {'tipo': 'ecra', 'legenda': 'Seguro, inspeção, IUC: **num sítio só**', 'ecra': 'carro', 'pan': (0.0, 0.3), 'dur': 3.6, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R14', 'data': '2026-10-16', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': H_RV,
     'gancho': 'Faltam 4 dias para pagar a Segurança Social',
     'corpo': 'Faltam 4 dias: a contribuição da Segurança Social de outubro paga-se até terça, 20. Já trataste?',
     'fonte': F_SS_PAG,
     'planos': [
         {'tipo': 'numero', 'antes': 'Faltam', 'numero': '4 dias', 'legenda': 'para pagar a Segurança Social de outubro.', 'fonte': F_SS_PAG, 'dur': 3.2,
          'fundo': 'laranja', 'cor_numero': (255, 255, 255)},
         {'tipo': 'ecra', 'legenda': 'O valor e o prazo, **no painel**', 'ecra': 'painel', 'dur': 3.4, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         {'tipo': 'gancho', 'texto': 'Já pagaste? Carrega em **«Já paguei»** e fica verde.', 'dur': 2.8, 'logo': False},
         FIM]},
    {'id': 'R15', 'data': '2026-10-18', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': '#reforma #segurancasocial #recibosverdes #financaspessoais #portugal',
     'gancho': 'O que descontas hoje vale dinheiro amanhã',
     'corpo': 'O que descontas hoje para a Segurança Social vale reforma amanhã — e também baixa por doença e parentalidade. O Em Dia faz uma estimativa simples. A conta certa, com toda a tua carreira, é a da Segurança Social.',
     'planos': [
         {'tipo': 'gancho', 'texto': 'O que descontas hoje **vale dinheiro amanhã**.', 'etiqueta': 'REFORMA E DIREITOS', 'dur': 2.8},
         {'tipo': 'ecra', 'legenda': 'Uma **estimativa simples** da reforma', 'ecra': 'reforma', 'dur': 3.4, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         {'tipo': 'ecra', 'legenda': 'E o que ganhas **por pagar**', 'ecra': 'reforma', 'pan': (0.35, 0.6), 'dur': 3.4, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R16', 'data': '2026-10-19', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': H_RV,
     'gancho': 'Amanhã é o último dia',
     'corpo': 'Amanhã, terça 20, é o último dia para pagar a contribuição da Segurança Social deste mês. Se já pagaste, marca «Já paguei» no Em Dia.',
     'fonte': F_SS_PAG,
     'planos': [
         {'tipo': 'gancho', 'texto': '**Amanhã** é o último dia.', 'etiqueta': 'SEGURANÇA SOCIAL', 'dur': 2.2, 'fundo': 'laranja', 'acento_escuro': True},
         {'tipo': 'numero', 'antes': 'Pagar a Segurança Social até', 'numero': '20/10', 'legenda': 'terça-feira', 'fonte': F_SS_PAG, 'dur': 3.0, 'fundo': 'escuro'},
         {'tipo': 'ecra', 'legenda': 'Vê o valor **e como pagar**', 'ecra': 'painel', 'dur': 3.2, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R17', 'data': '2026-10-21', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': H_RV,
     'gancho': 'Declaração trimestral: faltam 10 dias',
     'corpo': 'Faltam 10 dias para a declaração trimestral da Segurança Social: declaras o que ganhaste em julho, agosto e setembro. O prazo é 31 de outubro, um sábado — trata até sexta, 30.',
     'fonte': F_SS_DECL,
     'planos': [
         {'tipo': 'numero', 'antes': 'Declaração trimestral: faltam', 'numero': '10 dias', 'legenda': 'Declaras julho, agosto e setembro.', 'fonte': F_SS_DECL,
          'dur': 3.4, 'fundo': 'escuro'},
         {'tipo': 'gancho', 'texto': '31 de outubro é **sábado**. Trata até sexta, 30.', 'dur': 3.0, 'fundo': 'laranja', 'logo': False},
         {'tipo': 'ecra', 'legenda': 'Está **na tua agenda**', 'ecra': 'agenda', 'dur': 3.2, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R18', 'data': '2026-10-22', 'hora': '20:30', 'publico': 'Estafetas', 'hashtags': H_EST,
     'gancho': 'Estafeta: cada entrega conta',
     'corpo': 'Fazes entregas e o que ganhas muda todas as semanas? Escreve cada dia no Em Dia: ele soma o mês e aponta a fatia do imposto no cofre. No fim do mês não há sustos.',
     'planos': [
         {'tipo': 'gancho', 'texto': 'Fazes entregas? **Cada dia conta.**', 'etiqueta': 'ESTAFETAS', 'dur': 2.4, 'fundo': 'escuro'},
         {'tipo': 'ecra', 'legenda': 'Escreves o que ganhaste **em cada dia**', 'ecra': 'dinheiro-baixo', 'dur': 3.4, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         {'tipo': 'ecra', 'legenda': 'E vês **quanto já entrou** este mês', 'ecra': 'dinheiro', 'dur': 3.2, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R19', 'data': '2026-10-23', 'hora': '20:30', 'publico': 'Freelancers', 'hashtags': H_RV,
     'gancho': 'Recibo de 1.000 €? Faz a conta antes de o passar',
     'corpo': 'Vais passar um recibo de 1.000 € a uma empresa? Com retenção de 23 %, recebes 770 €. A calculadora de recibo do Em Dia mostra-te o que recebes e o que é mesmo teu, antes de o emitires.',
     'fonte': F_RET,
     'planos': [
         {'tipo': 'gancho', 'texto': 'Recibo de **1.000 €**?', 'sub': 'Faz a conta antes de o passar.', 'etiqueta': 'FREELANCERS', 'dur': 2.4},
         {'tipo': 'numero', 'antes': 'Com retenção de 23 %, recebes', 'numero': '770 €', 'legenda': 'Os 230 € vão para as Finanças em teu nome.',
          'fonte': F_RET, 'dur': 3.4, 'fundo': 'escuro'},
         {'tipo': 'ecra', 'legenda': 'A **calculadora de recibo** faz isto por ti', 'ecra': 'recibos', 'pan': (0.0, 0.35), 'dur': 3.6, 'fundo': 'creme',
          'nota': 'Ecrã real · modo exemplo'},
         FIM]},
    {'id': 'R20', 'data': '2026-10-25', 'hora': '20:30', 'publico': 'Brasileiros em Portugal', 'br': True, 'hashtags': H_BR,
     'gancho': 'Você sabia? Em Portugal o cliente pode reter 23 % do recibo',
     'corpo': 'Você sabia? Em Portugal, quando você passa um recibo verde para uma empresa, ela pode reter 23 % para o IRS. Não é dinheiro perdido: conta no acerto do ano. O Em Dia faz a conta antes de você emitir.',
     'fonte': F_RET,
     'planos': [
         {'tipo': 'gancho', 'texto': 'Você sabia? O cliente pode **ficar com 23 %** do seu recibo.', 'etiqueta': 'PARA QUEM VEIO DO BRASIL', 'dur': 3.2},
         {'tipo': 'gancho', 'texto': 'Não é dinheiro perdido: **conta no acerto do IRS**.', 'dur': 3.0, 'fundo': 'escuro', 'logo': False},
         {'tipo': 'ecra', 'legenda': 'O Em Dia faz a conta **antes de você emitir**', 'ecra': 'recibos-br', 'pan': (0.0, 0.35), 'dur': 3.6, 'fundo': 'creme',
          'nota': 'Tela real · modo exemplo'},
         FIM]},
    {'id': 'R21', 'data': '2026-10-26', 'hora': '20:30', 'publico': 'Recibos verdes', 'hashtags': H_RV,
     'gancho': 'Faltam 5 dias: declaração trimestral',
     'corpo': 'Faltam 5 dias para a declaração trimestral da Segurança Social. O dia 31 é sábado: não deixes para o fim. Declaras o que ganhaste em julho, agosto e setembro, na Segurança Social Direta.',
     'fonte': F_SS_DECL,
     'planos': [
         {'tipo': 'numero', 'antes': 'Declaração trimestral: faltam', 'numero': '5 dias', 'legenda': 'O dia 31 é sábado: não deixes para o fim.', 'fonte': F_SS_DECL,
          'dur': 3.4, 'fundo': 'laranja', 'cor_numero': (255, 255, 255)},
         {'tipo': 'lista', 'titulo': 'O que declaras', 'itens': [('JUL', 'O que ganhaste em julho'), ('AGO', 'O que ganhaste em agosto'), ('SET', 'O que ganhaste em setembro')],
          'dur': 3.4, 'fundo': 'creme'},
         {'tipo': 'ecra', 'legenda': 'O Em Dia **não te deixa esquecer**', 'ecra': 'agenda', 'dur': 3.0, 'fundo': 'creme', 'nota': 'Ecrã real · modo exemplo'},
         FIM]},
]

# ------------------------------------------------------------------ stories
STORIES = [
    {'id': 'S01', 'data': '2026-09-28', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'verde', 'etiqueta': 'OLÁ!',
     'titulo': 'Somos o **Em Dia**.', 'corpo': 'A app que te diz quanto guardar e avisa antes de cada prazo.', 'ecra': 'painel', 'corte': (0.085, 0.5)},
    {'id': 'S02', 'data': '2026-09-29', 'hora': '09:00', 'tipo': 'sondagem', 'fundo': 'escuro', 'etiqueta': 'PERGUNTA RÁPIDA',
     'titulo': 'Sabes quanto guardar para a **Segurança Social?**', 'sticker': 'Sondagem: «Sei» / «Nem ideia»'},
    {'id': 'S03', 'data': '2026-09-30', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'creme', 'etiqueta': 'SABIAS QUE…',
     'titulo': 'Se o teu cliente é uma empresa, **pode reter 23 %** do recibo.', 'corpo': 'Não é dinheiro perdido: conta no acerto do IRS.', 'fonte': F_RET},
    {'id': 'S04', 'data': '2026-10-01', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'escuro', 'etiqueta': 'OUTUBRO',
     'titulo': 'Outubro: **2 prazos** da Segurança Social.', 'corpo': 'Pagar entre 10 e 20.\nDeclarar o trimestre até 31 (é sábado: trata até 30).', 'fonte': F_AGENDA},
    {'id': 'S05', 'data': '2026-10-02', 'hora': '09:00', 'tipo': 'sondagem', 'fundo': 'verde', 'etiqueta': 'PARA QUEM VEIO DO BRASIL', 'br': True,
     'titulo': 'Você abriu atividade em Portugal **há menos de 1 ano?**', 'sticker': 'Sondagem: «Sim» / «Não»'},
    {'id': 'S06', 'data': '2026-10-03', 'hora': '10:00', 'tipo': 'titulo', 'fundo': 'creme', 'etiqueta': 'COMO FUNCIONA',
     'titulo': 'Escreves o que ganhaste. **O Em Dia faz as contas.**', 'ecra': 'dinheiro', 'corte': (0.03, 0.5)},
    {'id': 'S07', 'data': '2026-10-04', 'hora': '10:00', 'tipo': 'caixa_perguntas', 'fundo': 'verde', 'etiqueta': 'PERGUNTA-NOS',
     'titulo': 'Tens uma dúvida sobre **recibos verdes?**', 'corpo': 'Respondemos nos stories desta semana.', 'sticker': 'Caixa de perguntas'},
    {'id': 'S08', 'data': '2026-10-05', 'hora': '10:00', 'tipo': 'titulo', 'fundo': 'escuro', 'etiqueta': 'FERIADO · 5 DE OUTUBRO',
     'titulo': 'Prazo a calhar num feriado? **Passa para o dia útil seguinte.**', 'corpo': 'Comunicar as faturas de setembro: até amanhã, dia 6.',
     'fonte': 'Fonte: AT, agenda fiscal 2026 (nota a)'},
    {'id': 'S09', 'data': '2026-10-06', 'hora': '09:00', 'tipo': 'contagem', 'fundo': 'escuro', 'etiqueta': 'SEGURANÇA SOCIAL',
     'numero': 14, 'titulo': 'para o fim do prazo de pagamento de outubro.', 'corpo': 'Paga-se entre o dia 10 e o dia 20.', 'fonte': F_SS_PAG},
    {'id': 'S10', 'data': '2026-10-07', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'creme', 'etiqueta': 'TVDE',
     'titulo': '**Vale a pena** esta corrida?', 'corpo': 'Escreve o preço e os quilómetros.', 'ecra': 'vale-a-pena', 'corte': (0.03, 0.5)},
    {'id': 'S11', 'data': '2026-10-08', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'verde', 'etiqueta': 'LEMBRETE',
     'titulo': 'A partir de sábado, **dia 10**, já podes pagar a Segurança Social de outubro.', 'fonte': F_SS_PAG},
    {'id': 'S12', 'data': '2026-10-09', 'hora': '09:00', 'tipo': 'sondagem', 'fundo': 'escuro', 'etiqueta': 'PERGUNTA RÁPIDA',
     'titulo': 'Trabalhas por **conta de outrem** ou a **recibos verdes?**', 'sticker': 'Sondagem: «Contrato» / «Recibos verdes»'},
    {'id': 'S13', 'data': '2026-10-10', 'hora': '10:00', 'tipo': 'titulo', 'fundo': 'verde', 'etiqueta': 'ABRE HOJE',
     'titulo': 'Segurança Social: **paga entre hoje e dia 20.**', 'ecra': 'painel', 'corte': (0.085, 0.4), 'fonte': F_SS_PAG},
    {'id': 'S14', 'data': '2026-10-11', 'hora': '10:00', 'tipo': 'titulo', 'fundo': 'creme', 'etiqueta': 'CONTAS DA CASA',
     'titulo': 'Contrato da internet a acabar? **O Em Dia avisa.**', 'ecra': 'radar', 'corte': (0.03, 0.5)},
    {'id': 'S15', 'data': '2026-10-12', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'escuro', 'etiqueta': 'EMPRESAS',
     'titulo': 'Tens trabalhadores? **A DMR de setembro é até hoje.**', 'fonte': 'Fonte: AT, agenda declarativa 2026'},
    {'id': 'S16', 'data': '2026-10-13', 'hora': '09:00', 'tipo': 'contagem', 'fundo': 'escuro', 'etiqueta': 'SEGURANÇA SOCIAL',
     'numero': 7, 'titulo': 'para pagar a Segurança Social de outubro.', 'corpo': 'Último dia: terça, 20.', 'fonte': F_SS_PAG},
    {'id': 'S17', 'data': '2026-10-14', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'creme', 'etiqueta': 'IVA',
     'titulo': 'Isento de IVA? **O limite é 15.000 €.**', 'ecra': 'painel-baixo', 'corte': (0.61, 0.80), 'largura': 820, 'fonte': F_IVA53},
    {'id': 'S18', 'data': '2026-10-15', 'hora': '09:00', 'tipo': 'sondagem', 'fundo': 'verde', 'etiqueta': 'PERGUNTA RÁPIDA',
     'titulo': 'Já pagaste a Segurança Social **deste mês?**', 'sticker': 'Sondagem: «Já» / «Ainda não»'},
    {'id': 'S19', 'data': '2026-10-16', 'hora': '09:00', 'tipo': 'contagem', 'fundo': 'laranja', 'etiqueta': 'SEGURANÇA SOCIAL',
     'numero': 4, 'titulo': 'para pagar a Segurança Social.', 'corpo': 'Até terça, 20 de outubro.', 'fonte': F_SS_PAG},
    {'id': 'S20', 'data': '2026-10-17', 'hora': '10:00', 'tipo': 'titulo', 'fundo': 'creme', 'etiqueta': 'CARRO',
     'titulo': 'Seguro, IUC, inspeção: **o carro também tem prazos.**', 'ecra': 'carro', 'corte': (0.03, 0.5)},
    {'id': 'S21', 'data': '2026-10-18', 'hora': '10:00', 'tipo': 'caixa_perguntas', 'fundo': 'verde', 'etiqueta': 'PERGUNTA-NOS',
     'titulo': 'Qual é a tua maior dúvida sobre **IRS?**', 'sticker': 'Caixa de perguntas'},
    {'id': 'S22', 'data': '2026-10-19', 'hora': '09:00', 'tipo': 'contagem', 'fundo': 'laranja', 'etiqueta': 'SEGURANÇA SOCIAL',
     'numero': 1, 'unidade': 'dia', 'titulo': 'Amanhã é o último dia para pagar.', 'fonte': F_SS_PAG},
    {'id': 'S23', 'data': '2026-10-20', 'hora': '08:30', 'tipo': 'titulo', 'fundo': 'laranja', 'etiqueta': 'HOJE',
     'titulo': 'Último dia para pagar a **Segurança Social** de outubro.', 'fonte': F_SS_PAG},
    {'id': 'S24', 'data': '2026-10-21', 'hora': '09:00', 'tipo': 'contagem', 'fundo': 'escuro', 'etiqueta': 'DECLARAÇÃO TRIMESTRAL',
     'numero': 10, 'titulo': 'para declarar julho, agosto e setembro.', 'corpo': 'Na Segurança Social Direta.', 'fonte': F_SS_DECL},
    {'id': 'S25', 'data': '2026-10-22', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'creme', 'etiqueta': 'AGENDA',
     'titulo': 'Todos os teus prazos **num calendário.**', 'ecra': 'agenda', 'corte': (0.03, 0.5)},
    {'id': 'S26', 'data': '2026-10-23', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'verde', 'etiqueta': 'SABIAS QUE…',
     'titulo': 'Na declaração trimestral declaras **o que ganhaste** nos 3 meses anteriores.', 'corpo': 'Desta vez: julho, agosto e setembro.', 'fonte': F_SS_DECL},
    {'id': 'S27', 'data': '2026-10-24', 'hora': '10:00', 'tipo': 'sondagem', 'fundo': 'escuro', 'etiqueta': 'PERGUNTA RÁPIDA',
     'titulo': 'Já fizeste a **declaração trimestral?**', 'sticker': 'Sondagem: «Já» / «Ainda não»'},
    {'id': 'S28', 'data': '2026-10-25', 'hora': '10:00', 'tipo': 'titulo', 'fundo': 'creme', 'etiqueta': 'MUDOU A HORA',
     'titulo': 'Esta madrugada os relógios **atrasaram uma hora.**', 'corpo': 'Os prazos não mudam: a declaração trimestral continua a ser até dia 31.'},
    {'id': 'S29', 'data': '2026-10-26', 'hora': '09:00', 'tipo': 'contagem', 'fundo': 'laranja', 'etiqueta': 'DECLARAÇÃO TRIMESTRAL',
     'numero': 5, 'titulo': 'O dia 31 é sábado: trata até sexta, 30.', 'fonte': F_SS_DECL},
    {'id': 'S30', 'data': '2026-10-27', 'hora': '09:00', 'tipo': 'titulo', 'fundo': 'escuro', 'etiqueta': 'JÁ A SEGUIR',
     'titulo': 'Novembro: IVA trimestral **até 20/11**, pagamento até 25/11.', 'corpo': 'Só para quem não está isento de IVA.', 'fonte': F_IVA_TRI},
]
