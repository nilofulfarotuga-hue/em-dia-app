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
}
