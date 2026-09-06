// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appNome => 'Em Dia';

  @override
  String get boasVindas =>
      'Olá! Eu sou o Em Dia. A partir de agora não te esqueces de nada: Segurança Social, IVA, IRS, carro. Vamos começar com 4 perguntas rápidas.';

  @override
  String fimOnboardingUma(
    String obrigacao,
    String valor,
    String dia,
    String diaAviso,
  ) {
    return 'Pronto. Este mês só tens uma coisa: $obrigacao, $valor, até dia $dia. Eu aviso-te no dia $diaAviso.';
  }

  @override
  String fimOnboardingVarias(int n, String lista) {
    return 'Pronto. Este mês tens $n coisas: $lista. Eu aviso-te. Nos próximos 30 dias tens tudo aberto, sem cartão.';
  }

  @override
  String get fimOnboardingNada =>
      'Pronto. Este mês não tens nada a pagar. Eu aviso-te quando houver. Nos próximos 30 dias tens tudo aberto, sem cartão.';

  @override
  String push5Dias(String obrigacao, String valor) {
    return 'Faltam 5 dias para $obrigacao ($valor). Toca aqui para ver como pagar.';
  }

  @override
  String pushDia(String obrigacao, String valor) {
    return 'É hoje. $obrigacao, $valor, até à meia-noite. Já pagaste? Toca em Já paguei.';
  }

  @override
  String pushPassado(String dia) {
    return 'Passou o dia $dia e não marcaste como pago. Não é o fim do mundo: paga hoje, os juros são pequenos. Se já pagaste, toca aqui.';
  }

  @override
  String pushVigiaIva(String valor) {
    return 'Atenção: já vais em $valor este ano. Se passares os 15.000 €, no próximo ano tens de cobrar IVA. Queres perceber o que muda?';
  }

  @override
  String pushFimIsencao(String mes, String valor) {
    return 'Daqui a 30 dias acaba a tua isenção de Segurança Social. A partir de $mes vais pagar cerca de $valor/mês. Já estás avisado, sem sustos.';
  }

  @override
  String pushCarro(String matricula, String data) {
    return 'A inspeção do teu carro ($matricula) é até $data. Marca já — os centros enchem no fim do mês.';
  }

  @override
  String pushReforma(String valor) {
    return 'Este trimestre descontaste $valor. São mais 3 meses a contar para a tua reforma. Continua.';
  }

  @override
  String get pushTrial25 =>
      'Faltam 5 dias para o teu mês grátis acabar. Depois disso o Em Dia continua a avisar-te, mas com limites. Por 3,49 €/mês (ou 29,90 €/ano) fica tudo como está.';

  @override
  String get pushTrial31 =>
      'Hoje evitaste multas durante um mês. Para continuar assim é 3,49 € por mês — menos que uma multa. Toca para ativar.';

  @override
  String get pushReativacao =>
      'Está tudo em dia do teu lado. Não precisas de fazer nada. Eu avisarei.';

  @override
  String get semaforoVerde => 'Está tudo em dia';

  @override
  String semaforoAmareloUma(int dias) {
    return 'Tens 1 coisa a vencer em $dias dias';
  }

  @override
  String semaforoAmareloVarias(int n, int dias) {
    return 'Tens $n coisas a vencer em $dias dias';
  }

  @override
  String get semaforoVermelhoUma => 'Tens 1 prazo passado — resolve agora';

  @override
  String semaforoVermelhoVarias(int n) {
    return 'Tens $n prazos passados — resolve agora';
  }

  @override
  String get cartaoEsteMesPagas => 'Este mês pagas';

  @override
  String get cartaoGuardarIrs => 'Guardar para o IRS';

  @override
  String get cartaoProximoPrazo => 'Próximo prazo';

  @override
  String get jaPaguei => 'Já paguei';

  @override
  String faltamDias(int dias) {
    return 'Faltam $dias dias';
  }

  @override
  String get eHoje => 'É hoje';

  @override
  String passouHaDias(int dias) {
    return 'Passou há $dias dias';
  }

  @override
  String get nadaAPagarEsteMes => 'Nada a pagar este mês. Respira.';

  @override
  String get fraseHumanaVerde =>
      'Hoje não tens de fazer nada. Eu estou de olho.';

  @override
  String get fraseHumanaAmarelo =>
      'Um passo de cada vez. Vê o que vence primeiro.';

  @override
  String get fraseHumanaVermelho =>
      'Não é o fim do mundo. Paga hoje e fica arrumado.';

  @override
  String get juntarComprovativo => 'Juntar foto do comprovativo';

  @override
  String get comoPagar => 'Como pagar';

  @override
  String get verComoPagar => 'Ver como pagar';

  @override
  String get navPainel => 'Painel';

  @override
  String get navRecibos => 'Recibos';

  @override
  String get navCalendario => 'Calendário';

  @override
  String get navCarro => 'Carro';

  @override
  String get navMais => 'Mais';

  @override
  String get onbOQueFazes => 'O que fazes?';

  @override
  String get onbTvde => 'Motorista TVDE';

  @override
  String get onbEstafeta => 'Estafeta';

  @override
  String get onbServicos => 'Serviços (cabelo, obras, limpeza…)';

  @override
  String get onbFreelancer => 'Freelancer';

  @override
  String get onbSemAtividade => 'Ainda não abri atividade';

  @override
  String get onbSoCarro => 'Só quero o carro';

  @override
  String get onbQuandoAbriste => 'Quando abriste atividade?';

  @override
  String get onbQuandoAbristeAjuda =>
      'A data que está no Portal das Finanças. Se não tens a certeza, mete o mês aproximado — dá para mudar depois.';

  @override
  String get onbFaturouMais15k => 'No ano passado faturaste mais de 15.000 €?';

  @override
  String get onbFaturouMais15kAjuda =>
      'É isto que decide se cobras IVA (o imposto que vai na fatura).';

  @override
  String get onbSim => 'Sim';

  @override
  String get onbNao => 'Não';

  @override
  String get onbTensCarro => 'Tens carro?';

  @override
  String get onbMatricula => 'Matrícula';

  @override
  String get onbMatriculaAjuda =>
      'Pela matrícula eu descubro o mês do IUC (o imposto do carro) e quando é a inspeção.';

  @override
  String get onbDataMatricula => 'Mês e ano da matrícula';

  @override
  String get onbSeguroMes => 'Em que mês renova o seguro?';

  @override
  String get onbUltimaIpo => 'Quando foi a última inspeção?';

  @override
  String get onbProprioOuFrota => 'O carro é teu ou alugado à frota?';

  @override
  String get onbProprio => 'É meu';

  @override
  String get onbAlugadoFrota => 'Alugado à frota';

  @override
  String get onbQuantoGanhas => 'Quanto ganhas por mês, mais ou menos?';

  @override
  String get onbQuantoGanhasAjuda =>
      'Só para fazer a primeira simulação. Pode ser aproximado.';

  @override
  String get onbPorMes => 'por mês';

  @override
  String get onbContinuar => 'Continuar';

  @override
  String get onbVoltar => 'Voltar';

  @override
  String get onbSaltar => 'Saltar';

  @override
  String get onbComecar => 'Começar';

  @override
  String get onbEntrarNaApp => 'Entrar na app';

  @override
  String get loginTitulo => 'Entra com o teu e-mail';

  @override
  String get loginAjuda =>
      'Mando-te um código de 6 números. Sem palavra-passe, sem complicações.';

  @override
  String get loginEmail => 'O teu e-mail';

  @override
  String get loginEnviarCodigo => 'Enviar código';

  @override
  String get loginCodigoTitulo => 'Escreve o código que chegou ao e-mail';

  @override
  String get loginCodigo => 'Código de 6 números';

  @override
  String get loginConfirmar => 'Confirmar';

  @override
  String get loginGoogle => 'Entrar com Google';

  @override
  String get loginOu => 'ou';

  @override
  String get loginErro =>
      'Não consegui entrar. Vê se o e-mail está certo e tenta outra vez.';

  @override
  String get loginCodigoErrado =>
      'Esse código não bate certo. Tenta outra vez ou pede um novo.';

  @override
  String get sair => 'Sair';

  @override
  String get calcTitulo => 'Calculadora de recibo';

  @override
  String get calcValorRecibo => 'Valor do recibo (sem IVA)';

  @override
  String get calcRetencao =>
      'Retenção na fonte (o que o cliente guarda para as Finanças)';

  @override
  String get calcRetencaoPadrao => '23% (padrão)';

  @override
  String get calcRetencao25 => '25% (por opção)';

  @override
  String get calcRetencaoDispensa =>
      'Dispensa (faturei menos de 15.000 € no ano passado)';

  @override
  String get calcIva => 'IVA';

  @override
  String get calcIvaIsento => 'Isento (art. 53.º) — até 15.000 €/ano';

  @override
  String get calcIvaNormal => '23%';

  @override
  String get calcBruto => 'Bruto';

  @override
  String get calcRetencaoValor => 'Retenção';

  @override
  String get calcIvaValor => 'IVA a cobrar';

  @override
  String get calcLiquido => 'O que recebes mesmo';

  @override
  String get calcMencaoIsencao => 'Frase para pôr no recibo';

  @override
  String get calcCopiar => 'Copiar';

  @override
  String get calcCopiado => 'Copiado';

  @override
  String get vigiaIvaTitulo => 'Vigia do IVA';

  @override
  String vigiaIvaBarra(String atual, String limite) {
    return 'Estás em $atual de $limite';
  }

  @override
  String get vigiaIvaOk => 'Estás longe do limite. Continua a registar.';

  @override
  String get vigiaIvaAviso =>
      'Atenção: já passaste os 12.000 €. Se chegares aos 15.000 € este ano, no próximo ano cobras IVA.';

  @override
  String get vigiaIvaAlarme =>
      'Passaste os 15.000 €. No próximo ano tens de cobrar IVA (23%). Fala com o contabilista.';

  @override
  String get vigiaIvaCritico =>
      'Passaste os 18.750 €: perdes a isenção JÁ. A próxima fatura leva IVA e tens 15 dias úteis para avisar as Finanças.';

  @override
  String get ssTitulo => 'Segurança Social';

  @override
  String ssIsencaoAte(String data) {
    return 'Estás isento até $data';
  }

  @override
  String ssIsencaoFaltam(int meses) {
    return 'Faltam $meses meses de isenção';
  }

  @override
  String ssDeclararEm(String mes) {
    return 'Declaras em $mes o que ganhaste nos últimos 3 meses';
  }

  @override
  String ssPagaPorMes(String valor) {
    return 'Depois pagas cerca de $valor por mês, do dia 10 ao dia 20';
  }

  @override
  String get ssAjustar => 'Quero pagar 25% a menos / a mais';

  @override
  String get ssAjustarAjuda =>
      'A lei deixa ajustar até 25% para cima ou para baixo. Menos agora = menos reforma depois.';

  @override
  String get irsTitulo => 'IRS';

  @override
  String irsGuardarEsteMes(String valor) {
    return 'Guarda $valor este mês para o IRS';
  }

  @override
  String irsEstimativaAno(String valor) {
    return 'Estimativa para o ano: $valor';
  }

  @override
  String irsMinimoExistencia(String valor) {
    return 'Abaixo de $valor por ano não pagas IRS (mínimo de existência).';
  }

  @override
  String irsAvisoDespesas(String valor) {
    return 'Acima de $valor por ano tens de justificar 15% com faturas com NIF. Verifica com um contabilista.';
  }

  @override
  String get irsPagamentosConta =>
      'Pagamentos por conta: 20 jul · 20 set · 20 dez';

  @override
  String get rendTitulo => 'Rendimentos';

  @override
  String get rendAdicionar => 'Registar rendimento';

  @override
  String get rendValor => 'Quanto ganhaste (bruto)';

  @override
  String get rendMes => 'Mês';

  @override
  String get rendFoto => 'Ler extrato por foto (Uber, Bolt, Glovo)';

  @override
  String get rendGuardar => 'Guardar';

  @override
  String get rendSemDados =>
      'Ainda não registaste nada. Começa pelo mês passado.';

  @override
  String get calTitulo => 'Calendário';

  @override
  String get calSemObrigacoes => 'Nada marcado. Quando houver, aparece aqui.';

  @override
  String get calValorEstimado => 'Valor estimado';

  @override
  String calAte(String data) {
    return 'Até $data';
  }

  @override
  String get carroTitulo => 'O carro';

  @override
  String get carroAdicionar => 'Adicionar carro';

  @override
  String get carroIuc => 'IUC (imposto do carro)';

  @override
  String get carroIpo => 'Inspeção';

  @override
  String get carroSeguro => 'Seguro';

  @override
  String get carroCarta => 'Carta de condução';

  @override
  String get carroRevisao => 'Revisão';

  @override
  String get carroAbastecimentos => 'Abastecimentos';

  @override
  String get carroCustoKm => 'Custo por km';

  @override
  String get carroDespesas => 'Despesas com NIF';

  @override
  String get carroMultas => 'Portagens e multas';

  @override
  String get carroSemCarro => 'Ainda não tens carro registado.';

  @override
  String carroSeguroAviso(int dias) {
    return 'O seguro renova em $dias dias. É agora que comparas.';
  }

  @override
  String get reformaTitulo => 'Reforma e direitos';

  @override
  String reformaDescontas(String mensal, String reforma) {
    return 'Descontas $mensal/mês — vale cerca de $reforma de reforma';
  }

  @override
  String get reformaIdade =>
      'Idade da reforma em 2026: 66 anos e 9 meses. Mínimo: 15 anos de descontos.';

  @override
  String get reformaDireitos => 'O que ganhas por pagar';

  @override
  String get reformaPerdes => 'O que perdes se não pagares';

  @override
  String get reformaAcordoBrasil =>
      'Acordo Portugal–Brasil: o tempo dos dois países conta.';

  @override
  String get guiasTitulo => 'Guias de 1 minuto';

  @override
  String get guiasOuvir => 'Ouvir';

  @override
  String get guiasParar => 'Parar';

  @override
  String guiasFonte(String fonte, String data) {
    return 'Fonte oficial: $fonte · verificado em $data';
  }

  @override
  String get iaTitulo => 'Pergunta o que quiseres';

  @override
  String get iaEscreve => 'Escreve a tua pergunta…';

  @override
  String get iaRodape => 'Informação geral, não substitui contabilista.';

  @override
  String iaLimiteFree(int n, int usadas) {
    return 'No plano grátis tens $n perguntas por mês. Usaste $usadas.';
  }

  @override
  String get iaSemRegra =>
      'Não tenho essa regra confirmada. Vou pedir um guia novo sobre isto.';

  @override
  String get suporteTitulo => 'Ajuda';

  @override
  String get suporteDuvida => 'Tenho uma dúvida';

  @override
  String get suporteBug => 'Algo não funciona';

  @override
  String get suporteReembolso => 'Reembolso ou cancelar';

  @override
  String get suporteDescreve => 'Conta-me o que aconteceu';

  @override
  String get suporteEnviar => 'Enviar';

  @override
  String get suporteEnviado => 'Recebi. Respondo em breve.';

  @override
  String get planoTitulo => 'O teu plano';

  @override
  String planoTrial(String data) {
    return 'Mês grátis — tudo aberto até $data';
  }

  @override
  String get planoFree => 'Plano grátis';

  @override
  String get planoPro => 'Pro';

  @override
  String get planoFamilia => 'Família / Frota';

  @override
  String get planoProPreco => '3,49 €/mês ou 29,90 €/ano';

  @override
  String get planoFamiliaPreco =>
      '5,99 €/mês ou 49,90 €/ano — até 5 pessoas ou carros';

  @override
  String get planoAtivar => 'Ativar';

  @override
  String get planoCadeado => 'Isto é do plano Pro';

  @override
  String get planoCadeadoLinha =>
      'Ativa o Pro para ter avisos sem limite, IA sem limite e mais carros.';

  @override
  String get planoWeb =>
      'Para assinar, usa a app no telemóvel Android por agora.';

  @override
  String get planoGerir => 'Gerir na Google Play';

  @override
  String get adminTitulo => 'Painel Em Dia';

  @override
  String get erroRede => 'Sem ligação. Tenta outra vez daqui a bocado.';

  @override
  String get aCarregar => 'A carregar…';

  @override
  String get guardar => 'Guardar';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get apagar => 'Apagar';

  @override
  String get ok => 'OK';

  @override
  String get sim => 'Sim';

  @override
  String get nao => 'Não';

  @override
  String get hoje => 'Hoje';

  @override
  String get amanha => 'Amanhã';

  @override
  String get euros => '€';

  @override
  String onbPergunta(int n, int total) {
    return 'Pergunta $n de $total';
  }

  @override
  String get onbMes => 'Mês';

  @override
  String get onbAno => 'Ano';

  @override
  String get onbOpcional => 'opcional';

  @override
  String onbIsentoAte(String data) {
    return 'Estás isento de Segurança Social até $data';
  }

  @override
  String onbDepoisPagas(String mes) {
    return 'Depois pagas a partir de $mes';
  }

  @override
  String onbIsencaoJaAcabou(String data) {
    return 'A tua isenção do 1.º ano acabou em $data. Já pagas Segurança Social todos os meses — eu digo-te quanto e quando.';
  }

  @override
  String onbIvaNormalExplica(String taxa) {
    return 'Cobras IVA de $taxa nas faturas e entregas esse dinheiro às Finanças de 3 em 3 meses. Eu aviso-te das datas.';
  }

  @override
  String get onbIvaIsentoExplica =>
      'Não cobras IVA (ficas isento). Só tens de pôr a frase de isenção no recibo — eu dou-ta pronta a copiar.';

  @override
  String onbIucEm(String mes) {
    return 'IUC (o imposto do carro) é em $mes';
  }

  @override
  String onbProximaIpo(String data) {
    return 'Próxima inspeção: $data';
  }

  @override
  String get onbSimulacaoTitulo => 'A tua primeira simulação';

  @override
  String get onbSimulacaoAjuda =>
      'Valores aproximados. Afinas depois em Recibos.';

  @override
  String onbSsPorMes(String valor) {
    return 'Segurança Social ≈ $valor por mês';
  }

  @override
  String onbSsIsentoAte(String data) {
    return 'Segurança Social: isento até $data';
  }

  @override
  String onbIrsPorMes(String valor) {
    return 'IRS a guardar ≈ $valor por mês';
  }

  @override
  String get onbIrsZero =>
      'IRS: com este valor não pagas nada (ficas abaixo do mínimo que a lei não taxa)';

  @override
  String get onbEsteMes => 'Este mês';

  @override
  String get onbSemValor => 'sem pagamento';

  @override
  String onbItemLista(String nome, String valor, String dia) {
    return '$nome ($valor, dia $dia)';
  }

  @override
  String onbItemListaSemValor(String nome, String dia) {
    return '$nome (dia $dia)';
  }

  @override
  String onbDiaLimite(String dia) {
    return 'até dia $dia';
  }

  @override
  String get onbCalendarioErro =>
      'Guardei o teu perfil, mas o calendário ainda não ficou pronto. Abre o Painel daqui a bocado e ele aparece.';

  @override
  String painelOla(String nome) {
    return 'Olá, $nome';
  }

  @override
  String get painelOlaSemNome => 'Olá!';

  @override
  String get painelPergunta => 'Estás em dia?';

  @override
  String painelEtiquetaTrial(String data) {
    return 'Mês grátis até $data';
  }

  @override
  String get painelEtiquetaFree => 'Plano grátis';

  @override
  String get painelEtiquetaPro => 'Pro';

  @override
  String get painelEtiquetaFamilia => 'Família';

  @override
  String get painelSemaforoVerdeSub => 'Nada a vencer nos próximos 5 dias.';

  @override
  String get painelSemaforoAmareloHojeUma => 'Tens 1 coisa a vencer hoje';

  @override
  String painelSemaforoAmareloHojeVarias(int n) {
    return 'Tens $n coisas a vencer hoje';
  }

  @override
  String get painelSemaforoAmareloAmanhaUma => 'Tens 1 coisa a vencer amanhã';

  @override
  String painelSemaforoAmareloAmanhaVarias(int n) {
    return 'Tens $n coisas a vencer amanhã';
  }

  @override
  String painelHeroiEmDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Em $dias dias',
      one: 'Em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String painelHeroiPassouHa(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Passou há $dias dias',
      one: 'Passou há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get painelHeroiSemPrazo => 'Sem prazos à vista';

  @override
  String get painelHeroiSemPrazoAjuda =>
      'Quando houver, aparece aqui. Eu aviso-te antes.';

  @override
  String get painelNomeIuc => 'IUC (o imposto do carro)';

  @override
  String get painelNomeIva => 'IVA (o imposto da fatura)';

  @override
  String get painelNomeIrsConta => 'Pagamento por conta (adiantamento do IRS)';

  @override
  String painelAteDia(int dia) {
    return 'até dia $dia';
  }

  @override
  String get painelPago => 'Pago';

  @override
  String get painelIrsPorMes => 'por mês';

  @override
  String get painelIrsLinha =>
      'Não é tudo teu: guarda isto todos os meses e o IRS não te apanha de surpresa.';

  @override
  String painelIrsZero(String valor) {
    return 'Com o que ganhas não pagas IRS (ficas abaixo do mínimo de existência, $valor por ano).';
  }

  @override
  String get painelIrsSemRendimento =>
      'Diz-me quanto ganhas por mês (na aba Recibos) e eu digo-te quanto guardar.';

  @override
  String get painelIrsAproximado => 'valor aproximado';

  @override
  String painelVigiaFaltam(String valor) {
    return 'Faltam $valor para o limite. Continua a registar.';
  }

  @override
  String get painelPagoOk => 'Marcado como pago. Boa.';

  @override
  String get painelPagoErro =>
      'Não consegui marcar como pago. Vê a ligação e tenta outra vez.';

  @override
  String get painelComprovativoPergunta =>
      'Queres juntar a foto do comprovativo?';

  @override
  String get painelComprovativoAjuda =>
      'Fica guardada aqui, para quando as Finanças ou a Segurança Social perguntarem.';

  @override
  String get painelAgoraNao => 'Agora não';

  @override
  String get painelComprovativoOk => 'Comprovativo guardado.';

  @override
  String get painelComprovativoErro =>
      'Não consegui guardar a foto. Tenta outra vez.';

  @override
  String get painelCadeadoComprovativo =>
      'Ativa o Pro para guardar as fotos dos comprovativos.';

  @override
  String painelComoPagarAte(String data) {
    return 'Até $data';
  }

  @override
  String get painelComoPagarSs =>
      'Entra na Segurança Social Direta (app ou site), vai a Conta-corrente e depois a Pagamentos, e paga por Multibanco ou MB WAY. Prazo: entre o dia 10 e o dia 20.';

  @override
  String get painelComoPagarIva =>
      'Entra no Portal das Finanças, vai a IVA e depois a Pagamentos, e paga com a referência Multibanco que lá aparece. Prazo: até ao dia 25.';

  @override
  String get painelComoPagarIrs =>
      'Entra no Portal das Finanças, vai a IRS e depois a Pagamentos por conta, e paga com a referência Multibanco. Prazo: até ao dia 20.';

  @override
  String get painelComoPagarIuc =>
      'Entra no Portal das Finanças, vai a IUC (o imposto do carro) e a Emitir documento de pagamento, e paga por Multibanco. Prazo: até ao fim do mês da matrícula.';

  @override
  String get painelComoPagarIpo =>
      'Marca a inspeção num centro perto de ti (por telefone ou no site do centro) e leva o documento único do carro. Vai antes do dia limite.';

  @override
  String get painelComoPagarSeguro =>
      'Compara preços antes de renovar. Paga à seguradora por referência Multibanco ou débito direto até à data de renovação.';

  @override
  String get painelComoPagarGenerico =>
      'Confirma a data no Portal das Finanças ou na Segurança Social Direta e trata disto antes do dia limite. Se tiveres dúvidas, pergunta-me.';

  @override
  String get painelTentarOutraVez => 'Tentar outra vez';

  @override
  String get recibosTitulo => 'Recibos verdes';

  @override
  String get recibosSubtitulo =>
      'Faz as contas, regista o que ganhas e vê o que é mesmo teu.';

  @override
  String get calcAjudaValor => 'Escreve o valor sem IVA. Ex.: 1000';

  @override
  String get calcSemValor => 'Escreve um valor e eu faço as contas.';

  @override
  String get calcRecebesNaConta => 'O que recebes na conta';

  @override
  String get calcFicaTeu => 'O que é mesmo teu';

  @override
  String get calcNaoETudoTeu =>
      'O IVA e a retenção não são teus — vão para o Estado. Guarda só o que é mesmo teu.';

  @override
  String get calcDispensaAjuda =>
      'A dispensa só vale se o cliente tiver contabilidade organizada — pergunta-lhe antes.';

  @override
  String get calcRetencaoDispensaCurta => 'Dispensa (0%)';

  @override
  String get calcIvaIsentoCurto => 'Isento (art. 53.º — não cobras IVA)';

  @override
  String get calcIvaNormalCurto => 'Cobras 23%';

  @override
  String get calcBrutoExplicado => 'Bruto (o valor escrito no recibo)';

  @override
  String get ssIsencaoExplica =>
      'Isenção = no 1.º ano de atividade não pagas nada à Segurança Social.';

  @override
  String get rendUltimos => 'Os teus últimos meses';

  @override
  String rendTotalAno(String valor) {
    return 'Este ano já registaste $valor';
  }

  @override
  String get rendTipo => 'Tipo de rendimento';

  @override
  String get rendTipoServicos => 'Serviços (TVDE, entregas, cabelo, obras…)';

  @override
  String get rendTipoVendas => 'Venda de coisas';

  @override
  String get rendPlataforma => 'De onde veio';

  @override
  String get rendClienteDireto => 'Clientes diretos';

  @override
  String get rendPlataformaOutra => 'Outra';

  @override
  String get rendGuardado =>
      'Guardado. Já contei com isto na Vigia do IVA, na Segurança Social e no IRS.';

  @override
  String get rendValorInvalido => 'Escreve um valor maior que zero.';

  @override
  String rendLidoDaFoto(String confianca) {
    return 'Lido da foto ($confianca de certeza). Confirma antes de guardar.';
  }

  @override
  String get rendFotoALer => 'A ler o extrato… demora uns segundos.';

  @override
  String get rendFotoCadeado =>
      'Ler extratos por foto é do plano Pro. Regista à mão — demora 30 segundos.';

  @override
  String get rendFotoIndisponivel =>
      'A leitura por foto está a descansar. Regista à mão por agora — demora 30 segundos.';

  @override
  String get rendFotoNaoLi =>
      'Não consegui ler o mês ou o valor. Tenta uma foto mais nítida ou regista à mão.';

  @override
  String get rendOrigemFoto => 'lido da foto';

  @override
  String rendApagarPergunta(String mes) {
    return 'Apagar o rendimento de $mes?';
  }

  @override
  String get rendApagado => 'Apagado.';

  @override
  String vigiaIvaFalta(String valor) {
    return 'Ainda podes faturar $valor este ano sem cobrar IVA.';
  }

  @override
  String get vigiaIvaSemDados =>
      'Regista os teus rendimentos e eu vigio o limite por ti.';

  @override
  String ssAvisoAntes(int dias, String valor) {
    return 'Aviso-te $dias dias antes do fim, com o valor que vais passar a pagar: cerca de $valor por mês.';
  }

  @override
  String get ssSemAtividade =>
      'Sem atividade aberta não pagas Segurança Social nem IRS. Quando abrires, eu conto tudo.';

  @override
  String get ssSemDataAbertura =>
      'Diz-me quando abriste atividade (no teu perfil) para eu contar a isenção do 1.º ano.';

  @override
  String get ssSemDados =>
      'Regista os teus rendimentos para eu calcular o valor certo. Sem dados, conto com o mínimo.';

  @override
  String ssBaseTrimestre(String inicio, String fim, String valor) {
    return 'Com base no que ganhaste de $inicio a $fim: $valor.';
  }

  @override
  String ssBaseEstimativa(String valor) {
    return 'Com base na tua estimativa de $valor por mês. Regista os rendimentos para ser mais certo.';
  }

  @override
  String ssMinimo(String valor) {
    return 'É o mínimo: $valor por mês, mesmo que ganhes pouco.';
  }

  @override
  String get ssAjustarTitulo => 'Quanto queres pagar?';

  @override
  String get ssAjusteNormal => 'o valor normal';

  @override
  String ssAjusteMenos(int pct) {
    return '$pct% a menos';
  }

  @override
  String ssAjusteMais(int pct) {
    return '$pct% a mais';
  }

  @override
  String ssAjusteAtual(String ajuste) {
    return 'Ajuste atual: $ajuste';
  }

  @override
  String ssNovoValor(String valor) {
    return 'Passas a pagar cerca de $valor por mês';
  }

  @override
  String get ssAjusteGuardado =>
      'Guardado. Vou contar com este ajuste nos avisos.';

  @override
  String get etiquetaEstimativa => 'estimativa';

  @override
  String irsBase(String valor) {
    return 'Com base numa média de $valor por mês.';
  }

  @override
  String get irsSemDados =>
      'Regista os teus rendimentos (ou diz-me quanto ganhas por mês) e eu digo-te quanto guardar.';

  @override
  String get irsPagamentosContaTitulo =>
      'Adiantamentos do IRS (as Finanças chamam-lhes pagamentos por conta)';

  @override
  String get irsPagamentosContaAjuda =>
      'Só se tiveres imposto a pagar. Eu aviso-te 5 dias antes de cada um.';

  @override
  String irsEscaloesPorConfirmar(int ano) {
    return 'escalões $ano por confirmar';
  }

  @override
  String get irsEstimativaNota =>
      'É uma estimativa para saberes quanto guardar — não é a declaração.';

  @override
  String get emitirTitulo => 'Como emitir o recibo';

  @override
  String get emitirSubtitulo =>
      'Passo a passo no Portal das Finanças, com textos prontos a copiar.';

  @override
  String get emitirAbrirGuia => 'Ver o passo a passo';

  @override
  String get emitirPasso1 =>
      'Entra no Portal das Finanças com o teu NIF e a tua senha.';

  @override
  String get emitirPasso2 =>
      'Procura “Faturas e Recibos Verdes” e toca em “Emitir”.';

  @override
  String get emitirPasso3 =>
      'Escolhe “Recibo” (ou “Fatura-Recibo” se o cliente pedir fatura).';

  @override
  String get emitirPasso4 =>
      'Preenche o NIF do cliente. Se for uma plataforma (Uber, Bolt, Glovo), o NIF está no extrato ou no contrato.';

  @override
  String get emitirPasso5 =>
      'Na descrição escreve o que fizeste. Podes copiar este texto:';

  @override
  String get emitirPasso6 =>
      'Põe o valor sem IVA e escolhe a retenção que usaste na calculadora (23%, 25% ou dispensa).';

  @override
  String get emitirPasso7Isento =>
      'No IVA escolhe o regime de isenção do artigo 53.º e copia esta frase para o motivo:';

  @override
  String get emitirPasso7Normal => 'No IVA escolhe a taxa normal (23%).';

  @override
  String get emitirPasso8 =>
      'Confirma e emite. Guarda o PDF — no fim do mês regista aqui o que ganhaste.';

  @override
  String get emitirCapturaBreve => 'captura em breve';

  @override
  String get emitirAbrirPortal => 'Abrir o Portal das Finanças';

  @override
  String get emitirNaoAbriu =>
      'Não consegui abrir o site. Escreve portaldasfinancas.gov.pt no navegador.';

  @override
  String get emitirDescricaoTvde =>
      'Prestação de serviços de transporte de passageiros em veículo descaracterizado (TVDE)';

  @override
  String get emitirDescricaoEstafeta =>
      'Prestação de serviços de entrega de refeições e encomendas';

  @override
  String get emitirDescricaoServicos => 'Prestação de serviços';

  @override
  String calResumo(int n, String valor) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Este mês pagas $n coisas: $valor',
      one: 'Este mês pagas 1 coisa: $valor',
      zero: 'Este mês não tens nada a pagar.',
    );
    return '$_temp0';
  }

  @override
  String get calDiasSemana => 'seg,ter,qua,qui,sex,sáb,dom';

  @override
  String calDiaSelecionado(String data) {
    return 'Só o dia $data';
  }

  @override
  String get calLimparFiltro => 'Ver tudo';

  @override
  String get calFiltroTudo => 'Tudo';

  @override
  String get calFiltroSS => 'Segurança Social';

  @override
  String get calFiltroFiscal => 'IVA/IRS';

  @override
  String get calFiltroCarro => 'Carro';

  @override
  String get calFiltroOutros => 'Outros';

  @override
  String get calPassou => 'Passou';

  @override
  String get calEstaSemana => 'Esta semana';

  @override
  String get calEsteMes => 'Este mês';

  @override
  String get calMaisTarde => 'Mais tarde';

  @override
  String get calJaPagaste => 'Já pagaste';

  @override
  String calFaltamDias(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'faltam $n dias',
      one: 'falta 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get calEhHoje => 'é hoje';

  @override
  String calPassouHa(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'passou há $n dias',
      one: 'passou há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get calPago => 'Pago';

  @override
  String get calSemValor => 'sem valor';

  @override
  String get calSemNesteFiltro => 'Nada marcado aqui.';

  @override
  String get calRecalcular => 'Refazer o calendário';

  @override
  String get calRecalculado => 'Calendário refeito.';

  @override
  String get calErro =>
      'Não consegui carregar o calendário. Puxa para baixo para tentar outra vez.';

  @override
  String get calSemSessao => 'Entra na app para mexer no calendário.';

  @override
  String get calDataLimite => 'Data limite';

  @override
  String calAvisoEm(String data) {
    return 'Aviso-te a $data';
  }

  @override
  String get calAproximado => 'aproximado';

  @override
  String get calRegra => 'Porque aparece';

  @override
  String get calComoPagar => 'Como pagar';

  @override
  String calAbrirSite(String site) {
    return 'Abrir $site';
  }

  @override
  String get calSiteSS => 'a Segurança Social Direta';

  @override
  String get calSitePF => 'o Portal das Finanças';

  @override
  String get calSiteImt => 'o site do IMT';

  @override
  String get calSiteAima => 'o site da AIMA';

  @override
  String get calErroAbrirSite =>
      'Não consegui abrir o site. Tenta no navegador.';

  @override
  String get calJaPaguei => 'Já paguei';

  @override
  String calPagoEm(String data) {
    return 'Pagaste a $data. Boa!';
  }

  @override
  String get calDesmarcar => 'Afinal não paguei';

  @override
  String get calMarcadaPaga => 'Marcado como pago.';

  @override
  String get calDesmarcada => 'Voltou a ficar por pagar.';

  @override
  String get calErroGuardar => 'Não consegui guardar. Tenta outra vez.';

  @override
  String get calCadeadoComprovativo => 'Ativa o Pro para guardar a foto.';

  @override
  String get calTirarFoto => 'Tirar foto agora';

  @override
  String get calEscolherGaleria => 'Escolher da galeria';

  @override
  String get calComprovativoGuardado =>
      'Comprovativo guardado e marcado como pago.';

  @override
  String get calComoPagarSs =>
      'Segurança Social Direta → Conta-corrente → Pagamentos → gera a referência Multibanco e paga na app do banco.';

  @override
  String get calComoPagarFiscal =>
      'Portal das Finanças → Pagamentos → gera a referência Multibanco e paga na app do banco.';

  @override
  String get calComoPagarIuc =>
      'Portal das Finanças → IUC → Pagar → escolhe a matrícula → emite a referência Multibanco.';

  @override
  String get calComoPagarIpo =>
      'Marca no centro de inspeção mais perto de ti. Leva o DUA (documento do carro) e o seguro.';

  @override
  String get calComoPagarSeguro =>
      'Pede 2 ou 3 simulações, compara e renova a que ficar mais barata.';

  @override
  String get calComoPagarMulta =>
      'Usa a referência que vem na carta da notificação. Se pagares cedo, costuma ficar mais barato.';

  @override
  String get calComoPagarOutro =>
      'Paga onde te disseram e depois marca aqui como pago.';

  @override
  String get calRegraSsDeclaracao => 'Declaração trimestral à Segurança Social';

  @override
  String get calRegraSsPagamento =>
      'Pagamento mensal à Segurança Social (dia 10 a 20)';

  @override
  String get calRegraSsIsencao => 'Fim da isenção de Segurança Social';

  @override
  String get calRegraIvaDeclaracao => 'Declaração trimestral de IVA';

  @override
  String get calRegraIvaPagamento => 'Pagamento trimestral de IVA';

  @override
  String get calRegraIrsEntrega => 'Entrega do IRS (abril a junho)';

  @override
  String get calRegraEfatura => 'Validar faturas no e-fatura';

  @override
  String get calRegraIrsConta => 'Pagamentos por conta de IRS';

  @override
  String get calRegraRecibos => 'Comunicar faturas às Finanças';

  @override
  String get calRegraTvde => 'Certificado de motorista TVDE';

  @override
  String get calRegraResidencia => 'Autorização de residência';

  @override
  String get calRegraIuc => 'IUC: mês da matrícula do carro';

  @override
  String get calRegraIpo => 'Inspeção periódica do carro';

  @override
  String get calRegraSeguro => 'Renovação do seguro';

  @override
  String get calRegraCarta => 'Validade da carta de condução';

  @override
  String get calRegraManual => 'Adicionaste tu';

  @override
  String calRegraOutra(String chave) {
    return 'Regra $chave';
  }

  @override
  String get calAdicionar => 'Adicionar';

  @override
  String get calNovaTitulo => 'Adicionar uma obrigação';

  @override
  String get calNovaTipo => 'O que é?';

  @override
  String get calTipoMulta => 'Multa';

  @override
  String get calTipoPortagem => 'Portagem';

  @override
  String get calTipoOutro => 'Outra coisa';

  @override
  String get calNovaDescricao => 'O que tens de pagar';

  @override
  String get calNovaDescricaoDica => 'Ex.: multa de estacionamento na Guarda';

  @override
  String get calNovaData => 'Até quando?';

  @override
  String get calNovaEscolherData => 'Escolher a data';

  @override
  String get calNovaValor => 'Valor (se souberes)';

  @override
  String get calNovaFaltaDescricao => 'Escreve o que é.';

  @override
  String get calNovaFaltaData => 'Escolhe a data.';

  @override
  String get calNovaGuardada => 'Adicionado ao calendário.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appNome => 'Em Dia';

  @override
  String get boasVindas =>
      'Oi! Eu sou o Em Dia. A partir de agora você não esquece de nada: Segurança Social, IVA, IRS, carro. Vamos começar com 4 perguntas rápidas.';

  @override
  String fimOnboardingUma(
    String obrigacao,
    String valor,
    String dia,
    String diaAviso,
  ) {
    return 'Pronto. Este mês você só tem uma coisa: $obrigacao, $valor, até o dia $dia. Eu te aviso no dia $diaAviso.';
  }

  @override
  String fimOnboardingVarias(int n, String lista) {
    return 'Pronto. Este mês você tem $n coisas: $lista. Eu te aviso. Nos próximos 30 dias você tem tudo aberto, sem cartão.';
  }

  @override
  String get fimOnboardingNada =>
      'Pronto. Este mês você não tem nada para pagar. Eu te aviso quando tiver. Nos próximos 30 dias você tem tudo aberto, sem cartão.';

  @override
  String push5Dias(String obrigacao, String valor) {
    return 'Faltam 5 dias para $obrigacao ($valor). Toque aqui para ver como pagar.';
  }

  @override
  String pushDia(String obrigacao, String valor) {
    return 'É hoje. $obrigacao, $valor, até meia-noite. Já pagou? Toque em Já paguei.';
  }

  @override
  String pushPassado(String dia) {
    return 'Passou o dia $dia e você não marcou como pago. Não é o fim do mundo: pague hoje, os juros são pequenos. Se já pagou, toque aqui.';
  }

  @override
  String pushVigiaIva(String valor) {
    return 'Atenção: você já está em $valor este ano. Se passar de 15.000 €, no ano que vem tem que cobrar IVA. Quer entender o que muda?';
  }

  @override
  String pushFimIsencao(String mes, String valor) {
    return 'Daqui a 30 dias acaba a sua isenção da Segurança Social. A partir de $mes você vai pagar cerca de $valor/mês. Já está avisado, sem susto.';
  }

  @override
  String pushCarro(String matricula, String data) {
    return 'A inspeção do seu carro ($matricula) é até $data. Marque já — os centros lotam no fim do mês.';
  }

  @override
  String pushReforma(String valor) {
    return 'Neste trimestre você contribuiu com $valor. São mais 3 meses contando para a sua aposentadoria. Continue.';
  }

  @override
  String get pushTrial25 =>
      'Faltam 5 dias para o seu mês grátis acabar. Depois disso o Em Dia continua te avisando, mas com limites. Por 3,49 €/mês (ou 29,90 €/ano) fica tudo como está.';

  @override
  String get pushTrial31 =>
      'Hoje você evitou multas durante um mês. Para continuar assim é 3,49 € por mês — menos que uma multa. Toque para ativar.';

  @override
  String get pushReativacao =>
      'Está tudo em dia do seu lado. Não precisa fazer nada. Eu aviso.';

  @override
  String get semaforoVerde => 'Está tudo em dia';

  @override
  String semaforoAmareloUma(int dias) {
    return 'Você tem 1 coisa vencendo em $dias dias';
  }

  @override
  String semaforoAmareloVarias(int n, int dias) {
    return 'Você tem $n coisas vencendo em $dias dias';
  }

  @override
  String get semaforoVermelhoUma => 'Você tem 1 prazo vencido — resolva agora';

  @override
  String semaforoVermelhoVarias(int n) {
    return 'Você tem $n prazos vencidos — resolva agora';
  }

  @override
  String get cartaoEsteMesPagas => 'Este mês você paga';

  @override
  String get cartaoGuardarIrs => 'Guardar para o IRS';

  @override
  String get cartaoProximoPrazo => 'Próximo prazo';

  @override
  String get jaPaguei => 'Já paguei';

  @override
  String faltamDias(int dias) {
    return 'Faltam $dias dias';
  }

  @override
  String get eHoje => 'É hoje';

  @override
  String passouHaDias(int dias) {
    return 'Passou há $dias dias';
  }

  @override
  String get nadaAPagarEsteMes => 'Nada para pagar este mês. Respira.';

  @override
  String get fraseHumanaVerde =>
      'Hoje você não precisa fazer nada. Eu estou de olho.';

  @override
  String get fraseHumanaAmarelo =>
      'Um passo de cada vez. Veja o que vence primeiro.';

  @override
  String get fraseHumanaVermelho =>
      'Não é o fim do mundo. Pague hoje e fica resolvido.';

  @override
  String get juntarComprovativo => 'Anexar foto do comprovante';

  @override
  String get comoPagar => 'Como pagar';

  @override
  String get verComoPagar => 'Ver como pagar';

  @override
  String get navPainel => 'Painel';

  @override
  String get navRecibos => 'Recibos';

  @override
  String get navCalendario => 'Calendário';

  @override
  String get navCarro => 'Carro';

  @override
  String get navMais => 'Mais';

  @override
  String get onbOQueFazes => 'O que você faz?';

  @override
  String get onbTvde => 'Motorista TVDE';

  @override
  String get onbEstafeta => 'Entregador';

  @override
  String get onbServicos => 'Serviços (cabelo, obras, limpeza…)';

  @override
  String get onbFreelancer => 'Freelancer';

  @override
  String get onbSemAtividade => 'Ainda não abri atividade';

  @override
  String get onbSoCarro => 'Só quero o carro';

  @override
  String get onbQuandoAbriste => 'Quando você abriu atividade?';

  @override
  String get onbQuandoAbristeAjuda =>
      'A data que está no Portal das Finanças. Se não tem certeza, coloque o mês aproximado — dá para mudar depois.';

  @override
  String get onbFaturouMais15k =>
      'No ano passado você faturou mais de 15.000 €?';

  @override
  String get onbFaturouMais15kAjuda =>
      'É isso que decide se você cobra IVA (o imposto que vai na fatura).';

  @override
  String get onbSim => 'Sim';

  @override
  String get onbNao => 'Não';

  @override
  String get onbTensCarro => 'Você tem carro?';

  @override
  String get onbMatricula => 'Placa (matrícula)';

  @override
  String get onbMatriculaAjuda =>
      'Pela matrícula eu descubro o mês do IUC (o imposto do carro) e quando é a inspeção.';

  @override
  String get onbDataMatricula => 'Mês e ano da matrícula';

  @override
  String get onbSeguroMes => 'Em que mês renova o seguro?';

  @override
  String get onbUltimaIpo => 'Quando foi a última inspeção?';

  @override
  String get onbProprioOuFrota => 'O carro é seu ou alugado da frota?';

  @override
  String get onbProprio => 'É meu';

  @override
  String get onbAlugadoFrota => 'Alugado da frota';

  @override
  String get onbQuantoGanhas => 'Quanto você ganha por mês, mais ou menos?';

  @override
  String get onbQuantoGanhasAjuda =>
      'Só para fazer a primeira simulação. Pode ser aproximado.';

  @override
  String get onbPorMes => 'por mês';

  @override
  String get onbContinuar => 'Continuar';

  @override
  String get onbVoltar => 'Voltar';

  @override
  String get onbSaltar => 'Pular';

  @override
  String get onbComecar => 'Começar';

  @override
  String get onbEntrarNaApp => 'Entrar no app';

  @override
  String get loginTitulo => 'Entre com o seu e-mail';

  @override
  String get loginAjuda =>
      'Eu mando um código de 6 números. Sem senha, sem complicação.';

  @override
  String get loginEmail => 'Seu e-mail';

  @override
  String get loginEnviarCodigo => 'Enviar código';

  @override
  String get loginCodigoTitulo => 'Digite o código que chegou no e-mail';

  @override
  String get loginCodigo => 'Código de 6 números';

  @override
  String get loginConfirmar => 'Confirmar';

  @override
  String get loginGoogle => 'Entrar com Google';

  @override
  String get loginOu => 'ou';

  @override
  String get loginErro =>
      'Não consegui entrar. Veja se o e-mail está certo e tente de novo.';

  @override
  String get loginCodigoErrado =>
      'Esse código não bate. Tente de novo ou peça um novo.';

  @override
  String get sair => 'Sair';

  @override
  String get calcTitulo => 'Calculadora de recibo';

  @override
  String get calcValorRecibo => 'Valor do recibo (sem IVA)';

  @override
  String get calcRetencao =>
      'Retenção na fonte (o que o cliente guarda para as Finanças)';

  @override
  String get calcRetencaoPadrao => '23% (padrão)';

  @override
  String get calcRetencao25 => '25% (por opção)';

  @override
  String get calcRetencaoDispensa =>
      'Dispensa (faturei menos de 15.000 € no ano passado)';

  @override
  String get calcIva => 'IVA';

  @override
  String get calcIvaIsento => 'Isento (art. 53.º) — até 15.000 €/ano';

  @override
  String get calcIvaNormal => '23%';

  @override
  String get calcBruto => 'Bruto';

  @override
  String get calcRetencaoValor => 'Retenção';

  @override
  String get calcIvaValor => 'IVA a cobrar';

  @override
  String get calcLiquido => 'O que você recebe de verdade';

  @override
  String get calcMencaoIsencao => 'Frase para colocar no recibo';

  @override
  String get calcCopiar => 'Copiar';

  @override
  String get calcCopiado => 'Copiado';

  @override
  String get vigiaIvaTitulo => 'Vigia do IVA';

  @override
  String vigiaIvaBarra(String atual, String limite) {
    return 'Você está em $atual de $limite';
  }

  @override
  String get vigiaIvaOk => 'Você está longe do limite. Continue registrando.';

  @override
  String get vigiaIvaAviso =>
      'Atenção: você já passou de 12.000 €. Se chegar aos 15.000 € este ano, no ano que vem cobra IVA.';

  @override
  String get vigiaIvaAlarme =>
      'Você passou de 15.000 €. No ano que vem tem que cobrar IVA (23%). Fale com o contador.';

  @override
  String get vigiaIvaCritico =>
      'Você passou de 18.750 €: perde a isenção JÁ. A próxima fatura leva IVA e você tem 15 dias úteis para avisar as Finanças.';

  @override
  String get ssTitulo => 'Segurança Social';

  @override
  String ssIsencaoAte(String data) {
    return 'Você está isento até $data';
  }

  @override
  String ssIsencaoFaltam(int meses) {
    return 'Faltam $meses meses de isenção';
  }

  @override
  String ssDeclararEm(String mes) {
    return 'Em $mes você declara o que ganhou nos últimos 3 meses';
  }

  @override
  String ssPagaPorMes(String valor) {
    return 'Depois você paga cerca de $valor por mês, do dia 10 ao dia 20';
  }

  @override
  String get ssAjustar => 'Quero pagar 25% a menos / a mais';

  @override
  String get ssAjustarAjuda =>
      'A lei deixa ajustar até 25% para cima ou para baixo. Menos agora = menos aposentadoria depois.';

  @override
  String get irsTitulo => 'IRS';

  @override
  String irsGuardarEsteMes(String valor) {
    return 'Guarde $valor este mês para o IRS';
  }

  @override
  String irsEstimativaAno(String valor) {
    return 'Estimativa para o ano: $valor';
  }

  @override
  String irsMinimoExistencia(String valor) {
    return 'Abaixo de $valor por ano você não paga IRS (mínimo de existência).';
  }

  @override
  String irsAvisoDespesas(String valor) {
    return 'Acima de $valor por ano você tem que justificar 15% com notas com NIF. Confira com um contador.';
  }

  @override
  String get irsPagamentosConta =>
      'Pagamentos por conta: 20 jul · 20 set · 20 dez';

  @override
  String get rendTitulo => 'Rendimentos';

  @override
  String get rendAdicionar => 'Registrar rendimento';

  @override
  String get rendValor => 'Quanto você ganhou (bruto)';

  @override
  String get rendMes => 'Mês';

  @override
  String get rendFoto => 'Ler extrato por foto (Uber, Bolt, Glovo)';

  @override
  String get rendGuardar => 'Salvar';

  @override
  String get rendSemDados =>
      'Você ainda não registrou nada. Comece pelo mês passado.';

  @override
  String get calTitulo => 'Calendário';

  @override
  String get calSemObrigacoes => 'Nada marcado. Quando tiver, aparece aqui.';

  @override
  String get calValorEstimado => 'Valor estimado';

  @override
  String calAte(String data) {
    return 'Até $data';
  }

  @override
  String get carroTitulo => 'O carro';

  @override
  String get carroAdicionar => 'Adicionar carro';

  @override
  String get carroIuc => 'IUC (imposto do carro)';

  @override
  String get carroIpo => 'Inspeção';

  @override
  String get carroSeguro => 'Seguro';

  @override
  String get carroCarta => 'Carteira de motorista';

  @override
  String get carroRevisao => 'Revisão';

  @override
  String get carroAbastecimentos => 'Abastecimentos';

  @override
  String get carroCustoKm => 'Custo por km';

  @override
  String get carroDespesas => 'Despesas com NIF';

  @override
  String get carroMultas => 'Pedágios e multas';

  @override
  String get carroSemCarro => 'Você ainda não tem carro registrado.';

  @override
  String carroSeguroAviso(int dias) {
    return 'O seguro renova em $dias dias. É agora que você compara.';
  }

  @override
  String get reformaTitulo => 'Aposentadoria e direitos';

  @override
  String reformaDescontas(String mensal, String reforma) {
    return 'Você contribui $mensal/mês — vale cerca de $reforma de aposentadoria';
  }

  @override
  String get reformaIdade =>
      'Idade da aposentadoria em 2026: 66 anos e 9 meses. Mínimo: 15 anos de contribuição.';

  @override
  String get reformaDireitos => 'O que você ganha por pagar';

  @override
  String get reformaPerdes => 'O que você perde se não pagar';

  @override
  String get reformaAcordoBrasil =>
      'Acordo Portugal–Brasil: o tempo dos dois países conta.';

  @override
  String get guiasTitulo => 'Guias de 1 minuto';

  @override
  String get guiasOuvir => 'Ouvir';

  @override
  String get guiasParar => 'Parar';

  @override
  String guiasFonte(String fonte, String data) {
    return 'Fonte oficial: $fonte · verificado em $data';
  }

  @override
  String get iaTitulo => 'Pergunte o que quiser';

  @override
  String get iaEscreve => 'Escreva a sua pergunta…';

  @override
  String get iaRodape => 'Informação geral, não substitui contador.';

  @override
  String iaLimiteFree(int n, int usadas) {
    return 'No plano grátis você tem $n perguntas por mês. Usou $usadas.';
  }

  @override
  String get iaSemRegra =>
      'Não tenho essa regra confirmada. Vou pedir um guia novo sobre isso.';

  @override
  String get suporteTitulo => 'Ajuda';

  @override
  String get suporteDuvida => 'Tenho uma dúvida';

  @override
  String get suporteBug => 'Algo não funciona';

  @override
  String get suporteReembolso => 'Reembolso ou cancelar';

  @override
  String get suporteDescreve => 'Me conte o que aconteceu';

  @override
  String get suporteEnviar => 'Enviar';

  @override
  String get suporteEnviado => 'Recebi. Respondo em breve.';

  @override
  String get planoTitulo => 'O seu plano';

  @override
  String planoTrial(String data) {
    return 'Mês grátis — tudo aberto até $data';
  }

  @override
  String get planoFree => 'Plano grátis';

  @override
  String get planoPro => 'Pro';

  @override
  String get planoFamilia => 'Família / Frota';

  @override
  String get planoProPreco => '3,49 €/mês ou 29,90 €/ano';

  @override
  String get planoFamiliaPreco =>
      '5,99 €/mês ou 49,90 €/ano — até 5 pessoas ou carros';

  @override
  String get planoAtivar => 'Ativar';

  @override
  String get planoCadeado => 'Isso é do plano Pro';

  @override
  String get planoCadeadoLinha =>
      'Ative o Pro para ter avisos sem limite, IA sem limite e mais carros.';

  @override
  String get planoWeb =>
      'Para assinar, use o app no celular Android por enquanto.';

  @override
  String get planoGerir => 'Gerenciar na Google Play';

  @override
  String get adminTitulo => 'Painel Em Dia';

  @override
  String get erroRede => 'Sem conexão. Tente de novo daqui a pouco.';

  @override
  String get aCarregar => 'Carregando…';

  @override
  String get guardar => 'Salvar';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get apagar => 'Apagar';

  @override
  String get ok => 'OK';

  @override
  String get sim => 'Sim';

  @override
  String get nao => 'Não';

  @override
  String get hoje => 'Hoje';

  @override
  String get amanha => 'Amanhã';

  @override
  String get euros => '€';

  @override
  String onbPergunta(int n, int total) {
    return 'Pergunta $n de $total';
  }

  @override
  String get onbMes => 'Mês';

  @override
  String get onbAno => 'Ano';

  @override
  String get onbOpcional => 'opcional';

  @override
  String onbIsentoAte(String data) {
    return 'Você está isento de Segurança Social até $data';
  }

  @override
  String onbDepoisPagas(String mes) {
    return 'Depois você paga a partir de $mes';
  }

  @override
  String onbIsencaoJaAcabou(String data) {
    return 'A sua isenção do 1.º ano acabou em $data. Você já paga Segurança Social todos os meses — eu te digo quanto e quando.';
  }

  @override
  String onbIvaNormalExplica(String taxa) {
    return 'Você cobra IVA de $taxa nas faturas e entrega esse dinheiro para as Finanças de 3 em 3 meses. Eu te aviso das datas.';
  }

  @override
  String get onbIvaIsentoExplica =>
      'Você não cobra IVA (fica isento). Só precisa colocar a frase de isenção no recibo — eu te dou pronta para copiar.';

  @override
  String onbIucEm(String mes) {
    return 'IUC (o imposto do carro) é em $mes';
  }

  @override
  String onbProximaIpo(String data) {
    return 'Próxima inspeção: $data';
  }

  @override
  String get onbSimulacaoTitulo => 'A sua primeira simulação';

  @override
  String get onbSimulacaoAjuda =>
      'Valores aproximados. Você ajusta depois em Recibos.';

  @override
  String onbSsPorMes(String valor) {
    return 'Segurança Social ≈ $valor por mês';
  }

  @override
  String onbSsIsentoAte(String data) {
    return 'Segurança Social: isento até $data';
  }

  @override
  String onbIrsPorMes(String valor) {
    return 'IRS para guardar ≈ $valor por mês';
  }

  @override
  String get onbIrsZero =>
      'IRS: com esse valor você não paga nada (fica abaixo do mínimo que a lei não taxa)';

  @override
  String get onbEsteMes => 'Este mês';

  @override
  String get onbSemValor => 'sem pagamento';

  @override
  String onbItemLista(String nome, String valor, String dia) {
    return '$nome ($valor, dia $dia)';
  }

  @override
  String onbItemListaSemValor(String nome, String dia) {
    return '$nome (dia $dia)';
  }

  @override
  String onbDiaLimite(String dia) {
    return 'até o dia $dia';
  }

  @override
  String get onbCalendarioErro =>
      'Salvei o seu perfil, mas o calendário ainda não ficou pronto. Abra o Painel daqui a pouco e ele aparece.';

  @override
  String painelOla(String nome) {
    return 'Olá, $nome';
  }

  @override
  String get painelOlaSemNome => 'Olá!';

  @override
  String get painelPergunta => 'Você está em dia?';

  @override
  String painelEtiquetaTrial(String data) {
    return 'Mês grátis até $data';
  }

  @override
  String get painelEtiquetaFree => 'Plano grátis';

  @override
  String get painelEtiquetaPro => 'Pro';

  @override
  String get painelEtiquetaFamilia => 'Família';

  @override
  String get painelSemaforoVerdeSub => 'Nada vencendo nos próximos 5 dias.';

  @override
  String get painelSemaforoAmareloHojeUma => 'Você tem 1 coisa vencendo hoje';

  @override
  String painelSemaforoAmareloHojeVarias(int n) {
    return 'Você tem $n coisas vencendo hoje';
  }

  @override
  String get painelSemaforoAmareloAmanhaUma =>
      'Você tem 1 coisa vencendo amanhã';

  @override
  String painelSemaforoAmareloAmanhaVarias(int n) {
    return 'Você tem $n coisas vencendo amanhã';
  }

  @override
  String painelHeroiEmDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Em $dias dias',
      one: 'Em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String painelHeroiPassouHa(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Passou há $dias dias',
      one: 'Passou há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get painelHeroiSemPrazo => 'Sem prazos à vista';

  @override
  String get painelHeroiSemPrazoAjuda =>
      'Quando tiver, aparece aqui. Eu te aviso antes.';

  @override
  String get painelNomeIuc => 'IUC (o imposto do carro)';

  @override
  String get painelNomeIva => 'IVA (o imposto da nota)';

  @override
  String get painelNomeIrsConta => 'Pagamento por conta (adiantamento do IRS)';

  @override
  String painelAteDia(int dia) {
    return 'até o dia $dia';
  }

  @override
  String get painelPago => 'Pago';

  @override
  String get painelIrsPorMes => 'por mês';

  @override
  String get painelIrsLinha =>
      'Não é tudo seu: guarde isso todo mês e o IRS não te pega de surpresa.';

  @override
  String painelIrsZero(String valor) {
    return 'Com o que você ganha não paga IRS (fica abaixo do mínimo de existência, $valor por ano).';
  }

  @override
  String get painelIrsSemRendimento =>
      'Me diga quanto você ganha por mês (na aba Recibos) e eu te digo quanto guardar.';

  @override
  String get painelIrsAproximado => 'valor aproximado';

  @override
  String painelVigiaFaltam(String valor) {
    return 'Faltam $valor para o limite. Continue registrando.';
  }

  @override
  String get painelPagoOk => 'Marcado como pago. Boa.';

  @override
  String get painelPagoErro =>
      'Não consegui marcar como pago. Veja a conexão e tente de novo.';

  @override
  String get painelComprovativoPergunta => 'Quer juntar a foto do comprovante?';

  @override
  String get painelComprovativoAjuda =>
      'Fica guardada aqui, para quando as Finanças ou a Segurança Social perguntarem.';

  @override
  String get painelAgoraNao => 'Agora não';

  @override
  String get painelComprovativoOk => 'Comprovante guardado.';

  @override
  String get painelComprovativoErro =>
      'Não consegui guardar a foto. Tente de novo.';

  @override
  String get painelCadeadoComprovativo =>
      'Ative o Pro para guardar as fotos dos comprovantes.';

  @override
  String painelComoPagarAte(String data) {
    return 'Até $data';
  }

  @override
  String get painelComoPagarSs =>
      'Entre na Segurança Social Direta (app ou site), vá em Conta-corrente e depois em Pagamentos, e pague por Multibanco ou MB WAY. Prazo: entre o dia 10 e o dia 20.';

  @override
  String get painelComoPagarIva =>
      'Entre no Portal das Finanças, vá em IVA e depois em Pagamentos, e pague com a referência Multibanco que aparece lá. Prazo: até o dia 25.';

  @override
  String get painelComoPagarIrs =>
      'Entre no Portal das Finanças, vá em IRS e depois em Pagamentos por conta, e pague com a referência Multibanco. Prazo: até o dia 20.';

  @override
  String get painelComoPagarIuc =>
      'Entre no Portal das Finanças, vá em IUC (o imposto do carro) e em Emitir documento de pagamento, e pague por Multibanco. Prazo: até o fim do mês da matrícula.';

  @override
  String get painelComoPagarIpo =>
      'Marque a inspeção num centro perto de você (por telefone ou no site do centro) e leve o documento único do carro. Vá antes do dia limite.';

  @override
  String get painelComoPagarSeguro =>
      'Compare preços antes de renovar. Pague à seguradora por referência Multibanco ou débito direto até a data de renovação.';

  @override
  String get painelComoPagarGenerico =>
      'Confirme a data no Portal das Finanças ou na Segurança Social Direta e resolva isso antes do dia limite. Se tiver dúvidas, me pergunte.';

  @override
  String get painelTentarOutraVez => 'Tentar de novo';

  @override
  String get recibosTitulo => 'Recibos verdes';

  @override
  String get recibosSubtitulo =>
      'Faça as contas, registre o que você ganha e veja o que é mesmo seu.';

  @override
  String get calcAjudaValor => 'Escreva o valor sem IVA. Ex.: 1000';

  @override
  String get calcSemValor => 'Escreva um valor e eu faço as contas.';

  @override
  String get calcRecebesNaConta => 'O que você recebe na conta';

  @override
  String get calcFicaTeu => 'O que é mesmo seu';

  @override
  String get calcNaoETudoTeu =>
      'O IVA e a retenção não são seus — vão para o Estado. Guarde só o que é mesmo seu.';

  @override
  String get calcDispensaAjuda =>
      'A dispensa só vale se o cliente tiver contabilidade organizada — pergunte a ele antes.';

  @override
  String get calcRetencaoDispensaCurta => 'Dispensa (0%)';

  @override
  String get calcIvaIsentoCurto => 'Isento (art. 53.º — você não cobra IVA)';

  @override
  String get calcIvaNormalCurto => 'Você cobra 23%';

  @override
  String get calcBrutoExplicado => 'Bruto (o valor escrito no recibo)';

  @override
  String get ssIsencaoExplica =>
      'Isenção = no 1.º ano de atividade você não paga nada à Segurança Social.';

  @override
  String get rendUltimos => 'Seus últimos meses';

  @override
  String rendTotalAno(String valor) {
    return 'Este ano você já registrou $valor';
  }

  @override
  String get rendTipo => 'Tipo de rendimento';

  @override
  String get rendTipoServicos => 'Serviços (TVDE, entregas, cabelo, obras…)';

  @override
  String get rendTipoVendas => 'Venda de coisas';

  @override
  String get rendPlataforma => 'De onde veio';

  @override
  String get rendClienteDireto => 'Clientes diretos';

  @override
  String get rendPlataformaOutra => 'Outra';

  @override
  String get rendGuardado =>
      'Salvo. Já contei com isso na Vigia do IVA, na Segurança Social e no IRS.';

  @override
  String get rendValorInvalido => 'Escreva um valor maior que zero.';

  @override
  String rendLidoDaFoto(String confianca) {
    return 'Lido da foto ($confianca de certeza). Confira antes de salvar.';
  }

  @override
  String get rendFotoALer => 'Lendo o extrato… leva uns segundos.';

  @override
  String get rendFotoCadeado =>
      'Ler extratos por foto é do plano Pro. Registre à mão — leva 30 segundos.';

  @override
  String get rendFotoIndisponivel =>
      'A leitura por foto está descansando. Registre à mão por agora — leva 30 segundos.';

  @override
  String get rendFotoNaoLi =>
      'Não consegui ler o mês ou o valor. Tente uma foto mais nítida ou registre à mão.';

  @override
  String get rendOrigemFoto => 'lido da foto';

  @override
  String rendApagarPergunta(String mes) {
    return 'Apagar o rendimento de $mes?';
  }

  @override
  String get rendApagado => 'Apagado.';

  @override
  String vigiaIvaFalta(String valor) {
    return 'Você ainda pode faturar $valor este ano sem cobrar IVA.';
  }

  @override
  String get vigiaIvaSemDados =>
      'Registre seus rendimentos e eu vigio o limite para você.';

  @override
  String ssAvisoAntes(int dias, String valor) {
    return 'Aviso você $dias dias antes do fim, com o valor que vai passar a pagar: cerca de $valor por mês.';
  }

  @override
  String get ssSemAtividade =>
      'Sem atividade aberta você não paga Segurança Social nem IRS. Quando abrir, eu conto tudo.';

  @override
  String get ssSemDataAbertura =>
      'Me diga quando você abriu atividade (no seu perfil) para eu contar a isenção do 1.º ano.';

  @override
  String get ssSemDados =>
      'Registre seus rendimentos para eu calcular o valor certo. Sem dados, conto com o mínimo.';

  @override
  String ssBaseTrimestre(String inicio, String fim, String valor) {
    return 'Com base no que você ganhou de $inicio a $fim: $valor.';
  }

  @override
  String ssBaseEstimativa(String valor) {
    return 'Com base na sua estimativa de $valor por mês. Registre os rendimentos para ficar mais certo.';
  }

  @override
  String ssMinimo(String valor) {
    return 'É o mínimo: $valor por mês, mesmo que você ganhe pouco.';
  }

  @override
  String get ssAjustarTitulo => 'Quanto você quer pagar?';

  @override
  String get ssAjusteNormal => 'o valor normal';

  @override
  String ssAjusteMenos(int pct) {
    return '$pct% a menos';
  }

  @override
  String ssAjusteMais(int pct) {
    return '$pct% a mais';
  }

  @override
  String ssAjusteAtual(String ajuste) {
    return 'Ajuste atual: $ajuste';
  }

  @override
  String ssNovoValor(String valor) {
    return 'Você passa a pagar cerca de $valor por mês';
  }

  @override
  String get ssAjusteGuardado =>
      'Salvo. Vou contar com esse ajuste nos avisos.';

  @override
  String get etiquetaEstimativa => 'estimativa';

  @override
  String irsBase(String valor) {
    return 'Com base numa média de $valor por mês.';
  }

  @override
  String get irsSemDados =>
      'Registre seus rendimentos (ou me diga quanto ganha por mês) e eu digo quanto guardar.';

  @override
  String get irsPagamentosContaTitulo =>
      'Adiantamentos do IRS (as Finanças chamam de pagamentos por conta)';

  @override
  String get irsPagamentosContaAjuda =>
      'Só se você tiver imposto a pagar. Eu aviso 5 dias antes de cada um.';

  @override
  String irsEscaloesPorConfirmar(int ano) {
    return 'faixas $ano por confirmar';
  }

  @override
  String get irsEstimativaNota =>
      'É uma estimativa para você saber quanto guardar — não é a declaração.';

  @override
  String get emitirTitulo => 'Como emitir o recibo';

  @override
  String get emitirSubtitulo =>
      'Passo a passo no Portal das Finanças, com textos prontos para copiar.';

  @override
  String get emitirAbrirGuia => 'Ver o passo a passo';

  @override
  String get emitirPasso1 =>
      'Entre no Portal das Finanças com o seu NIF e a sua senha.';

  @override
  String get emitirPasso2 =>
      'Procure “Faturas e Recibos Verdes” e toque em “Emitir”.';

  @override
  String get emitirPasso3 =>
      'Escolha “Recibo” (ou “Fatura-Recibo” se o cliente pedir fatura).';

  @override
  String get emitirPasso4 =>
      'Preencha o NIF do cliente. Se for uma plataforma (Uber, Bolt, Glovo), o NIF está no extrato ou no contrato.';

  @override
  String get emitirPasso5 =>
      'Na descrição escreva o que você fez. Pode copiar este texto:';

  @override
  String get emitirPasso6 =>
      'Coloque o valor sem IVA e escolha a retenção que usou na calculadora (23%, 25% ou dispensa).';

  @override
  String get emitirPasso7Isento =>
      'No IVA escolha o regime de isenção do artigo 53.º e copie esta frase para o motivo:';

  @override
  String get emitirPasso7Normal => 'No IVA escolha a taxa normal (23%).';

  @override
  String get emitirPasso8 =>
      'Confirme e emita. Guarde o PDF — no fim do mês registre aqui o que ganhou.';

  @override
  String get emitirCapturaBreve => 'captura em breve';

  @override
  String get emitirAbrirPortal => 'Abrir o Portal das Finanças';

  @override
  String get emitirNaoAbriu =>
      'Não consegui abrir o site. Escreva portaldasfinancas.gov.pt no navegador.';

  @override
  String get emitirDescricaoTvde =>
      'Prestação de serviços de transporte de passageiros em veículo descaracterizado (TVDE)';

  @override
  String get emitirDescricaoEstafeta =>
      'Prestação de serviços de entrega de refeições e encomendas';

  @override
  String get emitirDescricaoServicos => 'Prestação de serviços';

  @override
  String calResumo(int n, String valor) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Este mês você paga $n coisas: $valor',
      one: 'Este mês você paga 1 coisa: $valor',
      zero: 'Este mês você não tem nada a pagar.',
    );
    return '$_temp0';
  }

  @override
  String get calDiasSemana => 'seg,ter,qua,qui,sex,sáb,dom';

  @override
  String calDiaSelecionado(String data) {
    return 'Só o dia $data';
  }

  @override
  String get calLimparFiltro => 'Ver tudo';

  @override
  String get calFiltroTudo => 'Tudo';

  @override
  String get calFiltroSS => 'Segurança Social';

  @override
  String get calFiltroFiscal => 'IVA/IRS';

  @override
  String get calFiltroCarro => 'Carro';

  @override
  String get calFiltroOutros => 'Outros';

  @override
  String get calPassou => 'Passou';

  @override
  String get calEstaSemana => 'Esta semana';

  @override
  String get calEsteMes => 'Este mês';

  @override
  String get calMaisTarde => 'Mais tarde';

  @override
  String get calJaPagaste => 'Já pagou';

  @override
  String calFaltamDias(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'faltam $n dias',
      one: 'falta 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get calEhHoje => 'é hoje';

  @override
  String calPassouHa(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'passou há $n dias',
      one: 'passou há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get calPago => 'Pago';

  @override
  String get calSemValor => 'sem valor';

  @override
  String get calSemNesteFiltro => 'Nada marcado aqui.';

  @override
  String get calRecalcular => 'Refazer o calendário';

  @override
  String get calRecalculado => 'Calendário refeito.';

  @override
  String get calErro =>
      'Não consegui carregar o calendário. Puxe para baixo para tentar de novo.';

  @override
  String get calSemSessao => 'Entre no app para mexer no calendário.';

  @override
  String get calDataLimite => 'Data limite';

  @override
  String calAvisoEm(String data) {
    return 'Te aviso em $data';
  }

  @override
  String get calAproximado => 'aproximado';

  @override
  String get calRegra => 'Por que aparece';

  @override
  String get calComoPagar => 'Como pagar';

  @override
  String calAbrirSite(String site) {
    return 'Abrir $site';
  }

  @override
  String get calSiteSS => 'a Segurança Social Direta';

  @override
  String get calSitePF => 'o Portal das Finanças';

  @override
  String get calSiteImt => 'o site do IMT';

  @override
  String get calSiteAima => 'o site da AIMA';

  @override
  String get calErroAbrirSite =>
      'Não consegui abrir o site. Tente no navegador.';

  @override
  String get calJaPaguei => 'Já paguei';

  @override
  String calPagoEm(String data) {
    return 'Pago em $data. Boa!';
  }

  @override
  String get calDesmarcar => 'Afinal não paguei';

  @override
  String get calMarcadaPaga => 'Marcado como pago.';

  @override
  String get calDesmarcada => 'Voltou a ficar pendente.';

  @override
  String get calErroGuardar => 'Não consegui salvar. Tente de novo.';

  @override
  String get calCadeadoComprovativo => 'Ative o Pro para guardar a foto.';

  @override
  String get calTirarFoto => 'Tirar foto agora';

  @override
  String get calEscolherGaleria => 'Escolher da galeria';

  @override
  String get calComprovativoGuardado =>
      'Comprovante salvo e marcado como pago.';

  @override
  String get calComoPagarSs =>
      'Segurança Social Direta → Conta-corrente → Pagamentos → gere a referência Multibanco e pague no app do banco.';

  @override
  String get calComoPagarFiscal =>
      'Portal das Finanças → Pagamentos → gere a referência Multibanco e pague no app do banco.';

  @override
  String get calComoPagarIuc =>
      'Portal das Finanças → IUC → Pagar → escolha a placa → emita a referência Multibanco.';

  @override
  String get calComoPagarIpo =>
      'Marque no centro de inspeção mais perto de você. Leve o DUA (documento do carro) e o seguro.';

  @override
  String get calComoPagarSeguro =>
      'Peça 2 ou 3 simulações, compare e renove a que ficar mais barata.';

  @override
  String get calComoPagarMulta =>
      'Use a referência que vem na carta da notificação. Se pagar cedo, costuma ficar mais barato.';

  @override
  String get calComoPagarOutro =>
      'Pague onde mandaram e depois marque aqui como pago.';

  @override
  String get calRegraSsDeclaracao => 'Declaração trimestral à Segurança Social';

  @override
  String get calRegraSsPagamento =>
      'Pagamento mensal à Segurança Social (dia 10 a 20)';

  @override
  String get calRegraSsIsencao => 'Fim da isenção de Segurança Social';

  @override
  String get calRegraIvaDeclaracao => 'Declaração trimestral de IVA';

  @override
  String get calRegraIvaPagamento => 'Pagamento trimestral de IVA';

  @override
  String get calRegraIrsEntrega => 'Entrega do IRS (abril a junho)';

  @override
  String get calRegraEfatura => 'Validar notas no e-fatura';

  @override
  String get calRegraIrsConta => 'Pagamentos por conta de IRS';

  @override
  String get calRegraRecibos => 'Comunicar notas às Finanças';

  @override
  String get calRegraTvde => 'Certificado de motorista TVDE';

  @override
  String get calRegraResidencia => 'Autorização de residência';

  @override
  String get calRegraIuc => 'IUC: mês da placa do carro';

  @override
  String get calRegraIpo => 'Inspeção periódica do carro';

  @override
  String get calRegraSeguro => 'Renovação do seguro';

  @override
  String get calRegraCarta => 'Validade da carteira de motorista';

  @override
  String get calRegraManual => 'Você adicionou';

  @override
  String calRegraOutra(String chave) {
    return 'Regra $chave';
  }

  @override
  String get calAdicionar => 'Adicionar';

  @override
  String get calNovaTitulo => 'Adicionar uma obrigação';

  @override
  String get calNovaTipo => 'O que é?';

  @override
  String get calTipoMulta => 'Multa';

  @override
  String get calTipoPortagem => 'Pedágio';

  @override
  String get calTipoOutro => 'Outra coisa';

  @override
  String get calNovaDescricao => 'O que você tem de pagar';

  @override
  String get calNovaDescricaoDica => 'Ex.: multa de estacionamento na Guarda';

  @override
  String get calNovaData => 'Até quando?';

  @override
  String get calNovaEscolherData => 'Escolher a data';

  @override
  String get calNovaValor => 'Valor (se souber)';

  @override
  String get calNovaFaltaDescricao => 'Escreva o que é.';

  @override
  String get calNovaFaltaData => 'Escolha a data.';

  @override
  String get calNovaGuardada => 'Adicionado ao calendário.';
}
