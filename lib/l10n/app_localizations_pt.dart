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
  String get onbTvde => 'Motorista TVDE (Uber, Bolt)';

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
  String get loginEmailInvalido =>
      'Esse e-mail não parece certo. Confere as letras e escreve outra vez.';

  @override
  String get loginEmailDeMentira =>
      'Esse e-mail não recebe correio. Escreve o teu a sério, senão o código não chega a lado nenhum.';

  @override
  String get loginCodigoCurto => 'Faltam números. O código tem 6.';

  @override
  String get loginCodigoExpirado =>
      'Esse código já passou da validade. Pede um novo.';

  @override
  String get loginMuitosPedidos =>
      'Pediste códigos a mais. Espera um bocado e tenta outra vez.';

  @override
  String get loginReenviar => 'Não chegou? Enviar outro código';

  @override
  String loginReenviarEm(int segundos) {
    return 'Podes pedir outro código daqui a $segundos segundos';
  }

  @override
  String get loginCodigoNovo => 'Enviei um código novo. Vê o e-mail.';

  @override
  String get loginTrocarEmail => 'Escrevi o e-mail errado';

  @override
  String get loginOndeEsta =>
      'Não vês o e-mail? Procura na pasta do lixo. Às vezes é para lá que ele vai.';

  @override
  String get sair => 'Sair';

  @override
  String get arranqueFalhouTitulo => 'Não consegui abrir a tua conta';

  @override
  String get arranqueFalhouLinha =>
      'Isto costuma ser a internet. Toca em tentar outra vez. Se continuar assim, sai e entra de novo — os teus dados ficam guardados no servidor.';

  @override
  String get tentarOutraVez => 'Tentar outra vez';

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
    return 'Acima de $valor por ano tens de justificar 15% com faturas com NIF (o teu número de contribuinte). Verifica com um contabilista.';
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
      'Entra no Portal das Finanças com o teu NIF (o teu número de contribuinte) e a tua senha.';

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

  @override
  String get carroOTeuCarro => 'O teu carro';

  @override
  String carroMatriculaKm(String matricula, String km) {
    return '$matricula · $km km';
  }

  @override
  String get carroAdicionarAjuda =>
      'Nome, matrícula, seguro, inspeção — em 1 minuto.';

  @override
  String get carroCadeadoLinha =>
      'No plano grátis só cabe 1 carro. Ativa o Pro para mais.';

  @override
  String get carroSemSessao => 'Entra na app para guardar.';

  @override
  String get carroGuardado => 'Guardado.';

  @override
  String get carroErroGuardar => 'Não consegui guardar. Tenta outra vez.';

  @override
  String get carroGuardadoRecalculado =>
      'Carro guardado. Já refiz o teu calendário.';

  @override
  String get carroGuardadoSemCalendario =>
      'Carro guardado. O calendário refaz-se assim que houver rede.';

  @override
  String get carroLembretes => 'Lembretes';

  @override
  String get carroSemLembretes =>
      'Preenche a matrícula e as datas do carro para eu te lembrar do IUC, da inspeção e do seguro.';

  @override
  String carroFaltamKm(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'faltam $nString km',
      one: 'falta 1 km',
    );
    return '$_temp0';
  }

  @override
  String get carroSemData => 'sem data';

  @override
  String get carroIucOnde => 'Imposto do carro. Pagas no Portal das Finanças.';

  @override
  String get carroIucSemEstimativa =>
      'Sem estimativa: falta a cilindrada do carro.';

  @override
  String carroIpoAvisos(int a, int b) {
    return 'Aviso-te $a e $b dias antes.';
  }

  @override
  String get carroIpoTvde =>
      'TVDE: inspeção todos os anos (ainda por confirmar).';

  @override
  String carroSeguradoraLinha(String nome) {
    return 'Seguradora: $nome';
  }

  @override
  String get carroSeguroCompara =>
      'É agora que comparas: pede 2 ou 3 simulações.';

  @override
  String carroCartaRegra(int a, int b, int c) {
    return 'A carta vale $a anos até aos 60, $b até aos 70 e depois $c.';
  }

  @override
  String carroRevisaoAosKm(String km) {
    return 'Revisão aos $km km.';
  }

  @override
  String get carroSoInformacao =>
      'Só informação: esta data não está no calendário porque ainda não foi gerada.';

  @override
  String carroResumoMes(String mes) {
    return 'Resumo de $mes';
  }

  @override
  String get carroResumoGasto => 'gasto';

  @override
  String get carroResumoKm => 'km';

  @override
  String get carroResumoEuroKm => '€/km';

  @override
  String get carroResumoL100 => 'L/100 km';

  @override
  String get carroCompensa =>
      'Para o TVDE: é isto que cada km te custa em combustível — assim sabes se a corrida compensa.';

  @override
  String get carroSemCustoKm =>
      'Regista 2 depósitos cheios com os km e eu calculo o custo por km.';

  @override
  String get carroSemAbastecimentos => 'Ainda não registaste abastecimentos.';

  @override
  String get carroNovoAbastecimento => 'Novo abastecimento';

  @override
  String get carroLitros => 'Litros';

  @override
  String get carroValorTotal => 'Valor total';

  @override
  String get carroKmConta => 'Km no conta-quilómetros';

  @override
  String get carroDepositoCheio => 'Enchi o depósito';

  @override
  String get carroPosto => 'Posto (opcional)';

  @override
  String get carroComNif => 'Pedi fatura com NIF';

  @override
  String get carroNif => 'NIF';

  @override
  String carroLitrosCurto(String litros) {
    return '$litros L';
  }

  @override
  String carroPrecoLitro(String preco) {
    return '$preco €/⁠L';
  }

  @override
  String carroKmCurto(String km) {
    return '$km km';
  }

  @override
  String get carroData => 'Data';

  @override
  String get carroEscolherData => 'Escolher a data';

  @override
  String get carroFaltaValor => 'Escreve o valor.';

  @override
  String get carroFaltaData => 'Escolhe a data.';

  @override
  String get carroAbastecimentoGuardado => 'Abastecimento guardado.';

  @override
  String carroDespesasAnoNif(int ano) {
    return 'Com NIF em $ano';
  }

  @override
  String get carroDespesasIrs =>
      'Guardadas para o IRS: cada fatura com o teu NIF (número de contribuinte) conta como despesa da atividade.';

  @override
  String get carroSemDespesas => 'Ainda não registaste despesas.';

  @override
  String get carroNovaDespesa => 'Nova despesa';

  @override
  String get carroTipoDespesa => 'O que foi?';

  @override
  String get carroTipoIuc => 'IUC';

  @override
  String get carroTipoIpo => 'Inspeção';

  @override
  String get carroTipoSeguro => 'Seguro';

  @override
  String get carroTipoRevisao => 'Revisão';

  @override
  String get carroTipoPneus => 'Pneus';

  @override
  String get carroTipoReparacao => 'Reparação';

  @override
  String get carroTipoPortagem => 'Portagem';

  @override
  String get carroTipoMulta => 'Multa';

  @override
  String get carroTipoEstacionamento => 'Estacionamento';

  @override
  String get carroTipoLavagem => 'Lavagem';

  @override
  String get carroTipoOutro => 'Outra';

  @override
  String get carroValor => 'Valor';

  @override
  String get carroNota => 'Nota (opcional)';

  @override
  String get carroNotaDica => 'Ex.: A23, Guarda → Covilhã';

  @override
  String get carroDataNotificacao => 'Quando recebeste a notificação?';

  @override
  String carroPrazoMulta(String data, int n) {
    return 'Pagar até $data — $n dias úteis. Depois sobe o valor.';
  }

  @override
  String get carroMultaNoCalendario =>
      'Vai também para o calendário, com aviso na véspera.';

  @override
  String get carroDespesaGuardada => 'Despesa guardada.';

  @override
  String carroMultasNota(int n) {
    return 'Portagens e multas pagam-se em $n dias úteis a contar da notificação.';
  }

  @override
  String get carroSemMultas => 'Nada por pagar.';

  @override
  String carroPagarAte(String data) {
    return 'pagar até $data';
  }

  @override
  String get carroEmBreve => 'Em breve';

  @override
  String get carroCentrosInspecao => 'Centros de inspeção perto de ti';

  @override
  String get carroCentrosInspecaoLinha =>
      'Mapa com os centros mais próximos, a partir dos dados abertos do Estado.';

  @override
  String get carroCombustivelBarato =>
      'Combustível mais barato num raio de 10 km';

  @override
  String get carroCombustivelBaratoLinha =>
      'Preços de hoje, a partir dos dados abertos do Estado (DGEG).';

  @override
  String get carroNovoTitulo => 'Adicionar carro';

  @override
  String get carroNome => 'Nome (ex.: o Clio)';

  @override
  String get carroMatricula => 'Matrícula';

  @override
  String get carroMatriculaDica => 'AA-11-BB';

  @override
  String get carroMesMatricula => 'Mês da matrícula';

  @override
  String get carroAnoMatricula => 'Ano';

  @override
  String get carroMatriculaAjuda =>
      'Pelo mês sei quando é o IUC; pelo ano, quando é a inspeção.';

  @override
  String get carroCombustivel => 'Combustível';

  @override
  String get carroCombGasolina => 'Gasolina';

  @override
  String get carroCombGasoleo => 'Gasóleo';

  @override
  String get carroCombEletrico => 'Elétrico';

  @override
  String get carroCombHibrido => 'Híbrido';

  @override
  String get carroCombGpl => 'GPL';

  @override
  String get carroCombOutro => 'Outro';

  @override
  String get carroCilindrada => 'Cilindrada (cc, opcional)';

  @override
  String get carroCo2 => 'CO2 g/km (opcional)';

  @override
  String get carroCilindradaAjuda =>
      'Está no DUA. Com estes dois estimo o IUC.';

  @override
  String get carroSeguradora => 'Seguradora';

  @override
  String get carroSeguroRenova => 'Quando renova o seguro?';

  @override
  String get carroUltimaIpo => 'Última inspeção (se já fez)';

  @override
  String get carroUsoTvde => 'Uso em TVDE';

  @override
  String get carroCartaValidade => 'Validade da carta de condução';

  @override
  String get carroFaltaMatricula => 'Escreve a matrícula.';

  @override
  String get carroFaltaMesMatricula => 'Escolhe o mês da matrícula.';

  @override
  String get carroFaltaAnoMatricula =>
      'Escreve o ano da matrícula (4 dígitos).';

  @override
  String get maisSubtitulo => 'Tudo o resto está aqui.';

  @override
  String get maisReforma => 'Reforma e direitos';

  @override
  String get maisGuias => 'Guias de 1 minuto';

  @override
  String get maisPergunta => 'Pergunta ao Em Dia';

  @override
  String get maisAjuda => 'Ajuda';

  @override
  String get maisPlano => 'O teu plano';

  @override
  String get maisDefinicoes => 'Definições';

  @override
  String get defsTitulo => 'Definições';

  @override
  String get defsIdioma => 'Como falo contigo';

  @override
  String get defsIdiomaAjuda =>
      'Muda só as palavras da app. As regras e os números são sempre os de Portugal.';

  @override
  String get defsPt => 'Português de Portugal';

  @override
  String get defsPtAjuda => 'Tu, reforma, telemóvel';

  @override
  String get defsBr => 'Português do Brasil';

  @override
  String get defsBrAjuda => 'Você, aposentadoria, celular';

  @override
  String get defsGuardado => 'Guardado.';

  @override
  String get defsConta => 'A tua conta';

  @override
  String get defsSairAjuda =>
      'Sais da app neste telemóvel. Os teus dados ficam guardados.';

  @override
  String get defsApagarConta => 'Apagar a minha conta';

  @override
  String get defsApagarTitulo => 'Apagar a conta?';

  @override
  String get defsApagarTexto =>
      'Vou pedir para apagar a tua conta e os teus dados. Demora até 30 dias. Deixas de receber avisos já hoje. Não dá para voltar atrás.';

  @override
  String get defsApagarConfirmar => 'Sim, apagar';

  @override
  String get defsApagarPedido => 'Pedido recebido. A conta vai ser apagada.';

  @override
  String defsVersao(String versao) {
    return 'Versão $versao';
  }

  @override
  String get defsSemPerfil => 'Entra na app para mudar as definições.';

  @override
  String get reformaSubtitulo => 'O que descontas hoje vale dinheiro amanhã.';

  @override
  String reformaDescontasHoje(String valor) {
    return 'Descontas $valor por mês';
  }

  @override
  String get reformaValeCerca => 'vale cerca de';

  @override
  String get reformaPorMesDeReforma => 'por mês de reforma';

  @override
  String reformaAnosDescontos(int anos) {
    return 'Se descontares durante $anos anos';
  }

  @override
  String reformaAnosCurto(int anos) {
    return '$anos anos';
  }

  @override
  String get reformaEstimativaSimples => 'estimativa simples';

  @override
  String get reformaEstimativaNota =>
      'É uma conta simples, só para teres uma ideia. A Segurança Social faz a conta certa com toda a tua carreira.';

  @override
  String get reformaSemDados =>
      'Diz-me quanto ganhas por mês (no teu perfil) e eu faço a conta. Por agora conto com o mínimo.';

  @override
  String get reformaIdadeTitulo => 'Quando te podes reformar';

  @override
  String reformaIdadeRegra(int ano, String idade, int anos) {
    return 'Em $ano: aos $idade. Precisas de $anos anos de descontos, no mínimo.';
  }

  @override
  String reformaAnosEMeses(int anos, int meses) {
    return '$anos anos e $meses meses';
  }

  @override
  String get reformaBaixaTitulo => 'Baixa por doença';

  @override
  String reformaBaixaTexto(int dia, int meses) {
    return 'Se adoeceres, recebes a partir do $dia.º dia de baixa. Precisas de $meses meses de descontos.';
  }

  @override
  String get reformaParentalidadeTitulo => 'Parentalidade';

  @override
  String get reformaParentalidadeTexto =>
      'Se tiveres um filho, recebes subsídio nos dias em que paras para cuidar dele. Vale para o pai e para a mãe.';

  @override
  String get reformaCessacaoTitulo => 'Cessação de atividade';

  @override
  String reformaCessacaoTexto(int dias) {
    return 'É o \"desemprego\" dos independentes: se fechares por falta de trabalho, recebes um apoio. Precisas de $dias dias de descontos.';
  }

  @override
  String get reformaFilhosTitulo => 'Assistência a filhos';

  @override
  String get reformaFilhosTexto =>
      'Se um filho adoecer e tiveres de ficar com ele, recebes subsídio nesses dias.';

  @override
  String get reformaPerdesBaixa => 'Sem baixa: se adoeceres, não recebes nada.';

  @override
  String get reformaPerdesSubsidio => 'Sem apoio se ficares sem trabalho.';

  @override
  String get reformaPerdesTempo =>
      'Os meses sem pagar não contam para a reforma.';

  @override
  String get reformaPerdesDivida => 'A dívida fica lá e cresce com juros.';

  @override
  String get reformaAcordoTitulo => 'Acordo Portugal–Brasil';

  @override
  String get reformaAcordoTexto =>
      'Se descontaste no Brasil (INSS) e em Portugal, o tempo dos dois países soma-se para a reforma. Não perdes o que já pagaste lá.';

  @override
  String get reformaAcordoBotao => 'Ver no site da Segurança Social';

  @override
  String get guiasSubtitulo => 'Um minuto cada. Podes ouvir em vez de ler.';

  @override
  String get guiasUmMinuto => '1 minuto';

  @override
  String get guiasEmBreve =>
      'Este guia está a ser escrito. Em breve fica aqui, com a fonte oficial.';

  @override
  String get guiasVazio => 'Ainda não há guias. Volta daqui a pouco.';

  @override
  String get guiasPorConfirmar => 'por confirmar';

  @override
  String get guiasSemFonte => 'Fonte oficial: por confirmar';

  @override
  String get guiasOuvirErro => 'Não consegui ler em voz alta neste telemóvel.';

  @override
  String get planoSubtitulo => 'Menos que uma multa.';

  @override
  String get planoEstadoTitulo => 'O que tens agora';

  @override
  String get planoTrialDepois =>
      'Depois passas para o plano grátis, com limites. Se ativares o Pro, fica tudo como está.';

  @override
  String planoLimAvisos(int n) {
    return '$n avisos por mês';
  }

  @override
  String planoLimCarros(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n carros',
      one: '1 carro',
    );
    return '$_temp0';
  }

  @override
  String planoLimPerguntas(int n) {
    return '$n perguntas ao Em Dia por mês';
  }

  @override
  String get planoLimResto => 'O resto aparece com cadeado.';

  @override
  String get planoTensPro => 'Tens o Pro. Está tudo aberto.';

  @override
  String planoTensFamilia(int n) {
    return 'Tens o Família / Frota. Está tudo aberto, para até $n pessoas ou carros.';
  }

  @override
  String get planoEscolhe => 'Escolhe como pagar';

  @override
  String get planoPorMes => 'Por mês';

  @override
  String get planoPorAno => 'Por ano';

  @override
  String planoPrecoMes(String valor) {
    return '$valor/mês';
  }

  @override
  String planoPrecoAno(String valor) {
    return '$valor/ano';
  }

  @override
  String planoPoupas(String valor) {
    return 'poupas $valor';
  }

  @override
  String get planoAbreAvisos => 'Avisos sem limite';

  @override
  String get planoAbreIa => 'Perguntas ao Em Dia sem limite';

  @override
  String get planoAbreFoto => 'Ler extratos por foto (Uber, Bolt, Glovo)';

  @override
  String get planoAbreComprovativos => 'Guardar as fotos dos comprovativos';

  @override
  String get planoAbreCarros => 'Vários carros';

  @override
  String get planoAbreExportar =>
      'Exportar para o contabilista (PDF ou folha de cálculo)';

  @override
  String get planoAbreReforma => 'Reforma e direitos completo';

  @override
  String planoFamiliaAbre(int n) {
    return 'Tudo o que o Pro tem, para até $n pessoas ou carros';
  }

  @override
  String get planoAtivarPro => 'Ativar o Pro';

  @override
  String get planoAtivarFamilia => 'Ativar o Família';

  @override
  String get planoATrabalhar => 'A falar com a Google Play…';

  @override
  String get planoCompraOk => 'Pronto. Já tens tudo aberto.';

  @override
  String get planoCompraErro =>
      'Não consegui fazer a compra. Não te cobrei nada. Tenta outra vez daqui a bocado.';

  @override
  String get planoCompraCancelada => 'Cancelaste. Não te cobrei nada.';

  @override
  String get planoLojaIndisponivel =>
      'A Google Play não está disponível neste telemóvel. Vê se tens a Play Store instalada e com sessão iniciada.';

  @override
  String get planoCancelarQuando => 'Cancelas quando quiseres, na Google Play.';

  @override
  String get iaSuporteTitulo => 'Tira a tua dúvida';

  @override
  String get iaVazio =>
      'Pergunta-me sobre recibos, IVA, Segurança Social ou o teu carro. Respondo com as regras de 2026.';

  @override
  String get iaChip1 => 'Abri atividade em março, quando começo a pagar?';

  @override
  String get iaChip2 => 'Passei os 15 mil, e agora?';

  @override
  String get iaChip3 => 'Posso pagar menos à Segurança Social?';

  @override
  String get iaChip4 => 'Quando é a inspeção do meu carro?';

  @override
  String iaContador(int usadas, int n) {
    return 'Usaste $usadas de $n perguntas este mês';
  }

  @override
  String get iaAPensar => 'A pensar…';

  @override
  String get iaDescansar =>
      'O assistente está a descansar. Tenta daqui a um minuto.';

  @override
  String get iaGuiaNovo => 'Pedi um guia novo sobre isto.';

  @override
  String get iaLimiteCta => 'Ativa o Pro para perguntas sem limite.';

  @override
  String get iaVerPlano => 'Ver o plano Pro';

  @override
  String get suporteIntro => 'O que se passa?';

  @override
  String get suporteDuvidaAjuda =>
      'O assistente responde já, com as regras de 2026.';

  @override
  String get suporteBugAjuda =>
      'Conta-me o que falhou. Eu junto os dados técnicos.';

  @override
  String get suporteReembolsoAjuda => 'Faz-se na Google Play, em 2 minutos.';

  @override
  String get suporteAssunto => 'Assunto';

  @override
  String get suporteAssuntoDica => 'Ex.: A app fecha ao abrir o calendário';

  @override
  String get suporteDescricaoDica =>
      'O que fizeste, o que esperavas e o que aconteceu.';

  @override
  String get suporteLogsNota =>
      'Junto sozinho a versão da app, o tipo de telemóvel e o teu plano. Nada de palavras-passe.';

  @override
  String get suporteAssuntoEmFalta => 'Escreve o assunto.';

  @override
  String get suporteErro => 'Não consegui enviar. Tenta outra vez.';

  @override
  String suporteTicket(String id) {
    return 'Pedido n.º $id';
  }

  @override
  String get suporteRespostaTitulo => 'Resposta';

  @override
  String get suporteEscalado =>
      'Passei isto a uma pessoa da equipa. Respondemos aqui.';

  @override
  String get suporteFechar => 'Voltar à ajuda';

  @override
  String get suporteReembolsoLinha1 =>
      'A assinatura do Em Dia é cobrada pela Google Play, não por nós.';

  @override
  String get suporteReembolsoLinha2 =>
      'Para cancelar ou pedir reembolso, vai às subscrições da tua conta Google.';

  @override
  String get suporteReembolsoLinha3 =>
      'Continuas com o plano até ao fim do período já pago.';

  @override
  String get suporteAbrirSubscricoes => 'Abrir as minhas subscrições';

  @override
  String get suporteReembolsoDescricao =>
      'Pedido aberto a partir da app (botão \"Abrir as minhas subscrições\").';

  @override
  String suporteRegistado(String id) {
    return 'Registei o teu pedido n.º $id. Se a Google recusar, responde aqui com esse número.';
  }

  @override
  String get suporteMeusPedidos => 'Os meus pedidos';

  @override
  String get suporteSemPedidos => 'Ainda não tens pedidos.';

  @override
  String get suporteEstadoAberto => 'Aberto';

  @override
  String get suporteEstadoEmCurso => 'Em análise';

  @override
  String get suporteEstadoFechado => 'Resolvido';

  @override
  String get suporteTipoDuvida => 'Dúvida';

  @override
  String get suporteTipoBug => 'Problema';

  @override
  String get suporteTipoReembolso => 'Reembolso';

  @override
  String get suporteTipoGuia => 'Guia novo';

  @override
  String get suporteTipoOutro => 'Outro';

  @override
  String suporteEmailRodape(String email) {
    return 'Ou escreve para $email';
  }

  @override
  String get admNavVisaoGeral => 'Visão geral';

  @override
  String get admNavUsuarios => 'Usuários';

  @override
  String get admNavRegras => 'Regras legais';

  @override
  String get admNavTickets => 'Tickets';

  @override
  String get admNavIa => 'IA';

  @override
  String get admNavAvisos => 'Avisos';

  @override
  String get admNavAuditoria => 'Auditoria';

  @override
  String get admNaoAdmin => 'Esta conta não é administradora.';

  @override
  String admErroLer(String erro) {
    return 'Não consegui ler os dados: $erro';
  }

  @override
  String get admTentarDeNovo => 'Tentar de novo';

  @override
  String get admVazio => 'Nada por aqui ainda.';

  @override
  String get admErroTitulo => 'Deu erro';

  @override
  String get admFechar => 'Fechar';

  @override
  String get admConfirmar => 'Confirmar';

  @override
  String get admCopiar => 'Copiar';

  @override
  String get admCopiado => 'Copiado.';

  @override
  String get admAtualizar => 'Atualizar';

  @override
  String get admSalvar => 'Salvar';

  @override
  String get admSalvo => 'Salvo e registrado na auditoria.';

  @override
  String get admTodos => 'Todos';

  @override
  String get admSim => 'Sim';

  @override
  String get admNao => 'Não';

  @override
  String get admVgTitulo => 'Visão geral';

  @override
  String get admVgSub =>
      'Números de agora, direto das tabelas (RPC admin_resumo). Nada é calculado no navegador.';

  @override
  String get admVgUsuarios => 'Usuários';

  @override
  String admVgAtivos7(int n) {
    return '$n ativos nos últimos 7 dias';
  }

  @override
  String get admVgTrial => 'Em trial';

  @override
  String get admVgFree => 'Free';

  @override
  String get admVgPro => 'Pro';

  @override
  String get admVgFamilia => 'Família';

  @override
  String get admVgReceita => 'Receita estimada / mês';

  @override
  String admVgReceitaSub(int n) {
    return '$n assinaturas ativas × preço em regras_legais';
  }

  @override
  String get admVgTickets => 'Tickets abertos';

  @override
  String admVgTicketsSub(int n) {
    return '$n escalados para humano';
  }

  @override
  String get admVgCustoHoje => 'Custo IA hoje';

  @override
  String admVgCustoSub(String valor) {
    return 'Alarme acima de $valor por dia';
  }

  @override
  String get admVgCusto7 => 'Custo IA — 7 dias';

  @override
  String admVgCusto7Sub(int n) {
    return '$n conversas';
  }

  @override
  String get admVgPassadas => 'Obrigações passadas';

  @override
  String get admVgPassadasSub =>
      'Prazos vencidos sem marcar pago, em todos os usuários';

  @override
  String admVgAlarme(String custo, String limite) {
    return 'ALARME: o custo de IA de hoje ($custo) passou do limite ($limite, regra ia_custo_alarme_dia_eur). Confira o modelo e o limite de perguntas em Regras legais → Cadeados por plano.';
  }

  @override
  String get admVgTabDia => 'Dia';

  @override
  String get admVgTabConversas => 'Conversas';

  @override
  String get admVgTabCusto => 'Custo (€)';

  @override
  String get admVgPushHoje => 'Push de hoje por resultado';

  @override
  String get admVgPushVazio => 'Nenhum push enviado hoje.';

  @override
  String get admVgResultado => 'Resultado';

  @override
  String get admVgQuantidade => 'Quantidade';

  @override
  String get admUsTitulo => 'Usuários';

  @override
  String get admUsSub =>
      'profiles + plano efetivo (view v_admin_usuarios). Clique numa linha para ver o detalhe e agir.';

  @override
  String get admUsPesquisa => 'Buscar por e-mail ou nome (Enter para buscar)';

  @override
  String get admUsExportar => 'Exportar CSV';

  @override
  String admUsCsvTitulo(int n) {
    return 'CSV dos usuários ($n)';
  }

  @override
  String get admUsCsvNota =>
      'Copie e cole num arquivo .csv (separador ;). O download direto pelo navegador fica para uma próxima versão.';

  @override
  String admUsTabela(int n) {
    return '$n usuários';
  }

  @override
  String get admColEmail => 'E-mail';

  @override
  String get admColNome => 'Nome';

  @override
  String get admColAtividade => 'Atividade';

  @override
  String get admColPlano => 'Plano efetivo';

  @override
  String get admColTrialAte => 'Trial até';

  @override
  String get admColUltimoAcesso => 'Último acesso';

  @override
  String get admColEstado => 'Estado';

  @override
  String get admColCriadoEm => 'Criado em';

  @override
  String get admUsBanido => 'banido';

  @override
  String get admUsAtivo => 'ativo';

  @override
  String get admUsDetalhe => 'Usuário';

  @override
  String get admUsAcoes => 'Ações';

  @override
  String admUsPlanoAtual(String plano, String efetivo) {
    return 'Plano manual (profiles.plano): $plano · plano efetivo: $efetivo';
  }

  @override
  String get admUsBanir => 'Banir';

  @override
  String get admUsReativar => 'Reativar';

  @override
  String admUsBanirConfirma(String email) {
    return 'Banir $email? O usuário perde o acesso ao app até você reativar.';
  }

  @override
  String get admUsAlterarPlano => 'Alterar plano manual';

  @override
  String get admUsPlanoManualNota =>
      'profiles.plano vale só quando não há trial ativo nem assinatura ativa na Google Play.';

  @override
  String get admUsEstenderTrial => 'Estender trial';

  @override
  String admUsEstenderDias(int n) {
    return '+$n dias';
  }

  @override
  String get admUsApagar => 'Apagar conta';

  @override
  String get admUsApagarNota =>
      'Apagar do auth de verdade precisa da service role (servidor). Aqui só marca como banido e registra o pedido na auditoria — o servidor apaga depois.';

  @override
  String admUsApagarConfirma(String email) {
    return 'Marcar $email como banido e registrar o pedido de apagar a conta?';
  }

  @override
  String get admUsFeito => 'Feito e registrado na auditoria.';

  @override
  String get admUsPerfil => 'Perfil';

  @override
  String admUsObrigacoes(int n) {
    return 'Obrigações ($n)';
  }

  @override
  String admUsRendimentos(int n) {
    return 'Rendimentos ($n)';
  }

  @override
  String admUsAssinaturas(int n) {
    return 'Assinaturas ($n)';
  }

  @override
  String admUsConversas(int n) {
    return 'Últimas conversas com a IA ($n)';
  }

  @override
  String get admRgTitulo => 'Regras legais';

  @override
  String get admRgSub =>
      'A única fonte de números do app e da IA. Editar aqui muda o app na hora. Confira a fonte oficial antes de salvar.';

  @override
  String get admRgAba1 => 'Regras';

  @override
  String get admRgAba2 => 'Escalões IRS';

  @override
  String get admRgAba3 => 'Cadeados por plano';

  @override
  String get admRgPesquisa => 'Buscar chave ou descrição';

  @override
  String admRgTabela(int n, int total) {
    return '$n de $total regras';
  }

  @override
  String get admRgAvisoIas => 'Aviso em massa: o IAS mudou';

  @override
  String get admRgAvisoIasTitulo => 'O IAS mudou';

  @override
  String admRgAvisoIasCorpo(String valor) {
    return 'O IAS (o valor de referência da Segurança Social) mudou para $valor. Os seus valores foram recalculados. Abra o app para conferir.';
  }

  @override
  String get admRgAvisoTituloCampo => 'Título';

  @override
  String get admRgAvisoCorpoCampo => 'Texto do aviso';

  @override
  String get admRgAvisoCriado =>
      'Aviso em massa criado. O envio é feito pelo avisos-cron (tipo massa) às 09:00 de Lisboa.';

  @override
  String get admRgColChave => 'Chave';

  @override
  String get admRgColDescricao => 'Descrição';

  @override
  String get admRgColValor => 'Valor';

  @override
  String get admRgColUnidade => 'Unidade';

  @override
  String get admRgColAno => 'Ano';

  @override
  String get admRgColConfianca => 'Confiança';

  @override
  String get admRgColVerificado => 'Verificado em';

  @override
  String get admRgColFonte => 'Fonte';

  @override
  String get admRgEditar => 'Editar regra';

  @override
  String get admRgValorNum => 'Valor numérico (valor_num)';

  @override
  String get admRgValorTxt => 'Valor em texto (valor_txt)';

  @override
  String get admRgValorJson => 'Valor JSON (valor_json)';

  @override
  String get admRgJsonInvalido =>
      'O JSON não é válido. Confira as chaves e as vírgulas.';

  @override
  String get admRgFonteUrl => 'Fonte (URL oficial)';

  @override
  String get admRgVerificadoEm => 'Verificado em (aaaa-mm-dd)';

  @override
  String get admRgConfianca => 'Confiança';

  @override
  String get admRgEscOrdem => 'Ordem';

  @override
  String get admRgEscAte => 'Até (€)';

  @override
  String get admRgEscTaxa => 'Taxa';

  @override
  String get admRgEscTaxaAjuda => 'Taxa (0,13 = 13%)';

  @override
  String get admRgEscParcela => 'Parcela a abater (€)';

  @override
  String get admRgEscSemLimite => 'sem limite';

  @override
  String get admRgEscSemLimiteAjuda => 'Vazio = último escalão, sem limite';

  @override
  String get admRgEscEditar => 'Editar escalão';

  @override
  String get admRgFlagChave => 'Chave';

  @override
  String get admRgFlagDescricao => 'Descrição';

  @override
  String get admRgFlagFree => 'Free';

  @override
  String get admRgFlagPro => 'Pro';

  @override
  String get admRgFlagFamilia => 'Família';

  @override
  String get admRgFlagLimFree => 'Limite free';

  @override
  String get admRgFlagLimPro => 'Limite pro';

  @override
  String get admRgFlagLimFamilia => 'Limite família';

  @override
  String get admRgFlagEditar => 'Editar cadeado';

  @override
  String get admRgFlagLimiteAjuda => 'Vazio = sem limite';

  @override
  String get admTkTitulo => 'Tickets de suporte';

  @override
  String get admTkSub =>
      'tickets_suporte. Clique numa linha para ver a descrição, os logs e a resposta da IA.';

  @override
  String admTkTabela(int n) {
    return '$n tickets';
  }

  @override
  String get admTkEstadoAberto => 'Aberto';

  @override
  String get admTkEstadoEmCurso => 'Em andamento';

  @override
  String get admTkEstadoFechado => 'Fechado';

  @override
  String get admTkEscalados => 'Só escalados para humano';

  @override
  String get admTkColQuando => 'Quando';

  @override
  String get admTkColTipo => 'Tipo';

  @override
  String get admTkColAssunto => 'Assunto';

  @override
  String get admTkColEstado => 'Estado';

  @override
  String get admTkColEscalar => 'Humano';

  @override
  String get admTkColUsuario => 'Usuário';

  @override
  String admTkDetalhe(String id) {
    return 'Ticket $id';
  }

  @override
  String get admTkDescricao => 'Descrição';

  @override
  String get admTkLogs => 'Logs';

  @override
  String get admTkRespostaIa => 'Resposta da IA';

  @override
  String get admTkMotivo => 'Motivo da escalada';

  @override
  String get admTkMudarEstado => 'Mudar estado';

  @override
  String get admTkEstadoMudado =>
      'Estado atualizado e registrado na auditoria.';

  @override
  String get admTkParceiro => 'Contato do contador/advogado parceiro';

  @override
  String get admTkParceiroAjuda =>
      'Fica em regras_legais (chave contacto_parceiro_contabilista). É o que o suporte mostra quando um ticket sobe para humano. A linha é criada se não existir.';

  @override
  String get admTkParceiroCampo => 'Nome, telefone, e-mail';

  @override
  String get admTkParceiroSalvo => 'Contato salvo e registrado na auditoria.';

  @override
  String get admIaTitulo => 'IA — perguntas e custo';

  @override
  String get admIaSub =>
      'conversas_ia (RPC admin_ia_top_perguntas) e v_custo_ia_diario.';

  @override
  String get admIaVazio => 'Ainda não há perguntas registradas.';

  @override
  String get admIaTop => 'Perguntas mais feitas (top 30)';

  @override
  String get admIaColPergunta => 'Pergunta';

  @override
  String get admIaColVezes => 'Vezes';

  @override
  String get admIaColFora => 'Fora das regras';

  @override
  String get admIaColBr => 'Em PT-BR';

  @override
  String get admIaColUltima => 'Última vez';

  @override
  String get admIaColVariante => 'Variante';

  @override
  String get admIaColResposta => 'Resposta';

  @override
  String admIaFora(int n) {
    return 'Fora das regras ($n) — candidatas a guia novo';
  }

  @override
  String get admIaForaVazio =>
      'Nenhuma pergunta fora das regras. A IA só citou o que está na tabela.';

  @override
  String get admIaCriarGuia => 'Criar guia';

  @override
  String get admIaGuiaConfirma =>
      'Criar um rascunho de guia (publicado = não) com esta pergunta como corpo? Depois você edita o texto.';

  @override
  String admIaGuiaCriado(String slug) {
    return 'Rascunho de guia criado: $slug (publicado = não).';
  }

  @override
  String get admIaCusto => 'Custo por dia (últimos 30 dias)';

  @override
  String get admIaColDia => 'Dia';

  @override
  String get admIaColConversas => 'Conversas';

  @override
  String get admIaColCusto => 'Custo (€)';

  @override
  String get admAvTitulo => 'Avisos';

  @override
  String get admAvSub =>
      'Push enviados (eventos_push), avisos em massa (avisos_massa) e log dos testes E2E (e2e_log).';

  @override
  String get admAvNovoMassa => 'Novo aviso em massa';

  @override
  String get admAvMassaNota =>
      'O envio real é feito pelo avisos-cron (tipo massa) às 09:00 de Lisboa, no máximo 1 por usuário por dia. Aqui só cria.';

  @override
  String get admAvMassaVazio => 'Preencha o título e o texto do aviso.';

  @override
  String get admAvMassaCriado =>
      'Aviso em massa criado e registrado na auditoria.';

  @override
  String get admAvMassaVazioLista => 'Nenhum aviso em massa criado ainda.';

  @override
  String get admAvFiltroResultado => 'Resultado';

  @override
  String get admAvFiltroTipo => 'Tipo';

  @override
  String admAvPush(int n) {
    return 'Push — últimos $n';
  }

  @override
  String get admAvMassa => 'Avisos em massa';

  @override
  String get admAvE2e => 'E2E log — últimos 100';

  @override
  String get admAvColDia => 'Dia';

  @override
  String get admAvColTipo => 'Tipo';

  @override
  String get admAvColTitulo => 'Título';

  @override
  String get admAvColCorpo => 'Corpo';

  @override
  String get admAvColResultado => 'Resultado';

  @override
  String get admAvColEnviadoEm => 'Enviado em';

  @override
  String get admAvColErro => 'Erro';

  @override
  String get admAvColCriadoEm => 'Criado em';

  @override
  String get admAvColSegmento => 'Segmento';

  @override
  String get admAvColEnviados => 'Enviados';

  @override
  String get admAvNaoEnviado => 'ainda não';

  @override
  String get admAvColFluxo => 'Fluxo';

  @override
  String get admAvColPasso => 'Passo';

  @override
  String get admAvColEstado => 'Estado';

  @override
  String get admAvColDetalhe => 'Detalhe';

  @override
  String get admAvColDevice => 'Dispositivo';

  @override
  String get admAuTitulo => 'Auditoria';

  @override
  String get admAuSub =>
      'admin_audit_log — últimas 300 ações de administrador. Clique para ver o antes e o depois.';

  @override
  String get admAuFiltroAcao =>
      'Buscar ação (ex.: usuario_banir, regra_editar)';

  @override
  String admAuTabela(int n) {
    return '$n ações';
  }

  @override
  String admAuDetalhe(String id) {
    return 'Ação #$id';
  }

  @override
  String get admAuColQuando => 'Quando';

  @override
  String get admAuColAdmin => 'Admin';

  @override
  String get admAuColAcao => 'Ação';

  @override
  String get admAuColAlvo => 'Alvo';

  @override
  String get admAuColAntes => 'Antes';

  @override
  String get admAuColDepois => 'Depois';

  @override
  String get carroFormBasicoAjuda =>
      'Só preciso destas três coisas. Pelo mês fico a saber quando pagas o imposto do carro; pelo ano, quando toca a inspeção.';

  @override
  String get carroFormMatriculaInvalida =>
      'Essa matrícula não me parece certa. Escreve as letras e os números, assim: AA-00-AA.';

  @override
  String get carroFormOpcionalTitulo => 'Queres afinar as contas? (opcional)';

  @override
  String get carroFormOpcionalAjuda =>
      'Podes fechar isto e guardar já. Só com a matrícula e a data eu aviso-te a tempo do imposto do carro, da inspeção e do seguro. Estes extras servem para eu acertar melhor o valor do imposto do carro — sem eles a app avisa na mesma, só não te diz um valor certo.';

  @override
  String get carroFormAbrir => 'Abrir';

  @override
  String get carroFormFechar => 'Fechar';

  @override
  String get carroFormIucPorConfirmar => 'imposto por confirmar';

  @override
  String get carroFormIucContaFeita => 'já consigo contar o imposto';

  @override
  String get carroFormIucPorConfirmarLinha =>
      'Sem a cilindrada não invento nenhum valor: aviso-te na data certa e escrevo «por confirmar» em vez de um número errado.';

  @override
  String get carroFormCilindrada => 'Cilindrada (o tamanho do motor, em cc)';

  @override
  String get carroFormCo2 => 'CO2 (o gás que o carro deita, em g/km)';

  @override
  String get carroFormOndeEstao =>
      'Estes dois números estão no papel do carro (o certificado de matrícula, o antigo livrete).';

  @override
  String get guiaIniSaltar => 'Saltar';

  @override
  String get guiaIniSeguinte => 'Seguinte';

  @override
  String get guiaIniComecar => 'Começar';

  @override
  String guiaIniPasso(int n, int total) {
    return 'Ecrã $n de $total';
  }

  @override
  String get guiaIniAvisoTitulo => 'Eu aviso-te';

  @override
  String get guiaIniAvisoTexto =>
      'Cada coisa que tens de pagar tem um dia certo. Eu aviso-te antes desse dia, com tempo para tratares disso. Assim nunca pagas uma multa só por te teres esquecido.';

  @override
  String get guiaIniGanhosTitulo => 'Escreve o que ganhas';

  @override
  String get guiaIniGanhosTexto =>
      'Sempre que receberes dinheiro, escreve aqui. Leva poucos segundos. Quanto mais escreveres, mais certas ficam as minhas contas e os meus avisos.';

  @override
  String get guiaIniPerguntaTitulo => 'Pergunta-me o que quiseres';

  @override
  String get guiaIniPerguntaTexto =>
      'Tens uma dúvida? Escreve-a como se falasses com um amigo. Eu respondo em português simples, a qualquer hora do dia ou da noite.';

  @override
  String get painelAcaoEtiqueta => 'O que fazer agora';

  @override
  String get painelAcaoPagaSs => 'Paga a Segurança Social';

  @override
  String get painelAcaoEntregaSs => 'Entrega a declaração da Segurança Social';

  @override
  String get painelAcaoPagaIva => 'Paga o IVA (o imposto da fatura)';

  @override
  String get painelAcaoEntregaIva => 'Entrega a declaração do IVA';

  @override
  String get painelAcaoEntregaIrs => 'Entrega o IRS';

  @override
  String get painelAcaoPagaIrsConta => 'Paga o adiantamento do IRS';

  @override
  String get painelAcaoValidaFaturas => 'Valida as tuas faturas no e-fatura';

  @override
  String get painelAcaoComunicaFaturas => 'Comunica as faturas que passaste';

  @override
  String get painelAcaoPagaIuc => 'Paga o IUC (o imposto do carro)';

  @override
  String get painelAcaoInspecao => 'Leva o carro à inspeção';

  @override
  String get painelAcaoRevisao => 'Faz a revisão do carro';

  @override
  String get painelAcaoSeguro => 'Paga o seguro do carro';

  @override
  String get painelAcaoCarta => 'Renova a carta de condução';

  @override
  String get painelAcaoTrocaCarta => 'Troca a carta de condução';

  @override
  String get painelAcaoResidencia => 'Renova a autorização de residência';

  @override
  String get painelAcaoCertificadoTvde =>
      'Renova o certificado de motorista TVDE';

  @override
  String get painelAcaoLicencaTvde => 'Renova a licença TVDE do carro';

  @override
  String get painelAcaoMulta => 'Paga a multa';

  @override
  String get painelAcaoPortagem => 'Paga a portagem';

  @override
  String get painelAcaoFimIsencao =>
      'Prepara-te: acaba a tua isenção da Segurança Social';

  @override
  String painelAcaoGenerica(String nome) {
    return 'Trata disto: $nome';
  }

  @override
  String get painelAcaoValorPorSaber => 'Ainda não sei o valor';

  @override
  String painelAcaoPrazoPassou(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Já passou há $dias dias',
      one: 'Já passou há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get painelAcaoPrazoHoje => 'É mesmo hoje';

  @override
  String get painelAcaoPrazoAmanha => 'É amanhã';

  @override
  String painelAcaoPrazoDiaSemana(String diaSemana, int dia) {
    return 'Até $diaSemana, dia $dia';
  }

  @override
  String painelAcaoPrazoData(String data) {
    return 'Até $data';
  }

  @override
  String get painelAcaoDia1 => 'segunda';

  @override
  String get painelAcaoDia2 => 'terça';

  @override
  String get painelAcaoDia3 => 'quarta';

  @override
  String get painelAcaoDia4 => 'quinta';

  @override
  String get painelAcaoDia5 => 'sexta';

  @override
  String get painelAcaoDia6 => 'sábado';

  @override
  String get painelAcaoDia7 => 'domingo';

  @override
  String get painelAcaoBotaoComoPagar => 'Ver como pagar';

  @override
  String get painelAcaoBotaoOQueFazer => 'Ver o que tenho de fazer';

  @override
  String get painelAcaoTudoTitulo => 'Não tens nada a pagar agora';

  @override
  String get painelAcaoTudoAjuda =>
      'Está tudo tratado. Quando houver um prazo, ponho-o aqui e aviso-te antes.';

  @override
  String get painelAcaoTudoSugestao =>
      'Já agora: escreve quanto ganhaste este mês. Com esse número faço as contas certas por ti.';

  @override
  String get painelAcaoTudoBotao => 'Escrever o que ganhei';

  @override
  String get oficioServicos => 'Serviços (cabelo, unhas, limpeza…)';

  @override
  String get oficioObras => 'Obras e construção';

  @override
  String get oficioOutro => 'Outra coisa';

  @override
  String get oficioComoFunciona => 'Como isto funciona';

  @override
  String get oficioExplicacaoTvde =>
      'Aqui tratas dos teus recibos das viagens. Escreve quanto ganhaste, eu faço as contas e digo-te o que é mesmo teu e o que é do Estado.';

  @override
  String get oficioExplicacaoEstafeta =>
      'Aqui tratas dos teus recibos das entregas. Escreve quanto ganhaste, eu faço as contas e digo-te o que é mesmo teu e o que é do Estado.';

  @override
  String get oficioExplicacaoServicos =>
      'Aqui tratas dos recibos dos teus clientes. Escreve quanto ganhaste, eu faço as contas e digo-te o que é mesmo teu e o que é do Estado.';

  @override
  String get oficioExplicacaoObras =>
      'Aqui tratas dos recibos dos teus trabalhos na obra. Escreve quanto ganhaste, eu faço as contas e digo-te o que é mesmo teu e o que é do Estado.';

  @override
  String get oficioExplicacaoFreelancer =>
      'Aqui tratas dos recibos dos trabalhos que entregas. Escreve quanto ganhaste, eu faço as contas e digo-te o que é mesmo teu e o que é do Estado.';

  @override
  String get oficioExplicacaoOutro =>
      'Aqui tratas dos teus recibos. Escreve quanto ganhaste, eu faço as contas e digo-te o que é mesmo teu e o que é do Estado.';

  @override
  String get oficioExplicacaoGeral =>
      'Aqui tratas dos recibos verdes. Escreve quanto ganhaste, eu faço as contas e digo-te o que é mesmo teu e o que é do Estado.';

  @override
  String get oficioAjudaTvde =>
      'Ao fim do mês vai ao extrato da Uber ou da Bolt, tira o total que te pagaram e escreve-o aqui.';

  @override
  String get oficioAjudaEstafeta =>
      'Ao fim do mês vai ao extrato da Glovo, da Bolt Food ou da Uber Eats, tira o total que te pagaram e escreve-o aqui.';

  @override
  String get oficioAjudaServicos =>
      'Faz um recibo a cada cliente que te paga. Ao fim do mês soma tudo e escreve aqui o total.';

  @override
  String get oficioAjudaObras =>
      'Faz um recibo por cada trabalho que te pagam, seja ao dono da casa seja à empresa. Ao fim do mês soma tudo e escreve aqui o total.';

  @override
  String get oficioAjudaFreelancer =>
      'Faz um recibo por cada trabalho que entregas. Ao fim do mês soma tudo e escreve aqui o total.';

  @override
  String get oficioAjudaOutro =>
      'Faz um recibo sempre que alguém te paga o teu trabalho. Ao fim do mês soma tudo e escreve aqui o total.';

  @override
  String get oficioAjudaGeral =>
      'Faz um recibo sempre que alguém te paga o teu trabalho. Ao fim do mês soma tudo e escreve aqui o total.';

  @override
  String get oficioExemploTvde =>
      'No teu caso o cliente é a plataforma: a Uber ou a Bolt. O número de contribuinte delas está no extrato.';

  @override
  String get oficioExemploEstafeta =>
      'No teu caso o cliente é a plataforma: a Glovo, a Bolt Food ou a Uber Eats. O número de contribuinte delas está no extrato.';

  @override
  String get oficioExemploServicos =>
      'No teu caso o cliente é quem te pagou: a pessoa que atendeste ou o salão. Pede-lhe o número de contribuinte.';

  @override
  String get oficioExemploObras =>
      'No teu caso o cliente é quem te pagou a obra: o dono da casa ou a empresa de construção. Pede-lhe o número de contribuinte.';

  @override
  String get oficioExemploFreelancer =>
      'No teu caso o cliente é a empresa ou a pessoa para quem fizeste o trabalho. Pede-lhe o número de contribuinte.';

  @override
  String get oficioExemploOutro =>
      'No teu caso o cliente é a pessoa ou a empresa que te pagou. Pede-lhe o número de contribuinte.';

  @override
  String get oficioExemploGeral =>
      'O cliente é a pessoa ou a empresa que te paga. Pede-lhe o número de contribuinte.';

  @override
  String get oficioDescricaoTvde =>
      'Serviços de transporte em veículo descaracterizado (TVDE)';

  @override
  String get oficioDescricaoEstafeta => 'Serviços de entrega ao domicílio';

  @override
  String get oficioDescricaoServicos =>
      'Prestação de serviços de cabeleireiro e estética';

  @override
  String get oficioDescricaoObras => 'Serviços de construção civil';

  @override
  String get oficioDescricaoFreelancer => 'Prestação de serviços';

  @override
  String get oficioDescricaoOutro => 'Prestação de serviços';

  @override
  String get oficioDescricaoGeral => 'Prestação de serviços';

  @override
  String get sufixoLitros => 'L';

  @override
  String get sufixoKm => 'km';
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
  String get onbTvde => 'Motorista TVDE (Uber, Bolt)';

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
  String get loginEmailInvalido =>
      'Esse e-mail não parece certo. Confira as letras e escreva de novo.';

  @override
  String get loginEmailDeMentira =>
      'Esse e-mail não recebe correio. Escreva o seu de verdade, senão o código não chega em lugar nenhum.';

  @override
  String get loginCodigoCurto => 'Faltam números. O código tem 6.';

  @override
  String get loginCodigoExpirado => 'Esse código já venceu. Peça um novo.';

  @override
  String get loginMuitosPedidos =>
      'Você pediu códigos demais. Espere um pouco e tente de novo.';

  @override
  String get loginReenviar => 'Não chegou? Enviar outro código';

  @override
  String loginReenviarEm(int segundos) {
    return 'Você pode pedir outro código daqui a $segundos segundos';
  }

  @override
  String get loginCodigoNovo => 'Mandei um código novo. Veja o e-mail.';

  @override
  String get loginTrocarEmail => 'Escrevi o e-mail errado';

  @override
  String get loginOndeEsta =>
      'Não achou o e-mail? Procure na pasta de lixo. Às vezes é para lá que ele vai.';

  @override
  String get sair => 'Sair';

  @override
  String get arranqueFalhouTitulo => 'Não consegui abrir a sua conta';

  @override
  String get arranqueFalhouLinha =>
      'Isso costuma ser a internet. Toque em tentar de novo. Se continuar assim, saia e entre de novo — seus dados ficam guardados no servidor.';

  @override
  String get tentarOutraVez => 'Tentar de novo';

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
    return 'Acima de $valor por ano você tem que justificar 15% com notas com NIF (o número de contribuinte português, como o CPF). Confira com um contador.';
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
      'Entre no Portal das Finanças com o seu NIF (o número de contribuinte português, como o CPF) e a sua senha.';

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

  @override
  String get carroOTeuCarro => 'Seu carro';

  @override
  String carroMatriculaKm(String matricula, String km) {
    return '$matricula · $km km';
  }

  @override
  String get carroAdicionarAjuda =>
      'Nome, placa, seguro, inspeção — em 1 minuto.';

  @override
  String get carroCadeadoLinha =>
      'No plano grátis só cabe 1 carro. Ative o Pro para mais.';

  @override
  String get carroSemSessao => 'Entre no app para salvar.';

  @override
  String get carroGuardado => 'Salvo.';

  @override
  String get carroErroGuardar => 'Não consegui salvar. Tente de novo.';

  @override
  String get carroGuardadoRecalculado =>
      'Carro salvo. Já refiz o seu calendário.';

  @override
  String get carroGuardadoSemCalendario =>
      'Carro salvo. O calendário se refaz assim que tiver internet.';

  @override
  String get carroLembretes => 'Lembretes';

  @override
  String get carroSemLembretes =>
      'Preencha a placa e as datas do carro para eu te lembrar do IUC, da inspeção e do seguro.';

  @override
  String carroFaltamKm(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'faltam $nString km',
      one: 'falta 1 km',
    );
    return '$_temp0';
  }

  @override
  String get carroSemData => 'sem data';

  @override
  String get carroIucOnde =>
      'Imposto do carro. Você paga no Portal das Finanças.';

  @override
  String get carroIucSemEstimativa =>
      'Sem estimativa: falta a cilindrada do carro.';

  @override
  String carroIpoAvisos(int a, int b) {
    return 'Te aviso $a e $b dias antes.';
  }

  @override
  String get carroIpoTvde => 'TVDE: inspeção todo ano (ainda a confirmar).';

  @override
  String carroSeguradoraLinha(String nome) {
    return 'Seguradora: $nome';
  }

  @override
  String get carroSeguroCompara =>
      'É agora que você compara: peça 2 ou 3 simulações.';

  @override
  String carroCartaRegra(int a, int b, int c) {
    return 'A carta vale $a anos até os 60, $b até os 70 e depois $c.';
  }

  @override
  String carroRevisaoAosKm(String km) {
    return 'Revisão aos $km km.';
  }

  @override
  String get carroSoInformacao =>
      'Só informação: esta data não está no calendário porque ainda não foi gerada.';

  @override
  String carroResumoMes(String mes) {
    return 'Resumo de $mes';
  }

  @override
  String get carroResumoGasto => 'gasto';

  @override
  String get carroResumoKm => 'km';

  @override
  String get carroResumoEuroKm => '€/km';

  @override
  String get carroResumoL100 => 'L/100 km';

  @override
  String get carroCompensa =>
      'Para o TVDE: é isso que cada km te custa em combustível — assim você sabe se a corrida compensa.';

  @override
  String get carroSemCustoKm =>
      'Registre 2 tanques cheios com os km e eu calculo o custo por km.';

  @override
  String get carroSemAbastecimentos =>
      'Você ainda não registrou abastecimentos.';

  @override
  String get carroNovoAbastecimento => 'Novo abastecimento';

  @override
  String get carroLitros => 'Litros';

  @override
  String get carroValorTotal => 'Valor total';

  @override
  String get carroKmConta => 'Km no hodômetro';

  @override
  String get carroDepositoCheio => 'Enchi o tanque';

  @override
  String get carroPosto => 'Posto (opcional)';

  @override
  String get carroComNif => 'Pedi nota com NIF';

  @override
  String get carroNif => 'NIF';

  @override
  String carroLitrosCurto(String litros) {
    return '$litros L';
  }

  @override
  String carroPrecoLitro(String preco) {
    return '$preco €/⁠L';
  }

  @override
  String carroKmCurto(String km) {
    return '$km km';
  }

  @override
  String get carroData => 'Data';

  @override
  String get carroEscolherData => 'Escolher a data';

  @override
  String get carroFaltaValor => 'Escreva o valor.';

  @override
  String get carroFaltaData => 'Escolha a data.';

  @override
  String get carroAbastecimentoGuardado => 'Abastecimento salvo.';

  @override
  String carroDespesasAnoNif(int ano) {
    return 'Com NIF em $ano';
  }

  @override
  String get carroDespesasIrs =>
      'Guardadas para o IRS: cada nota com o seu NIF (número de contribuinte) conta como despesa da atividade.';

  @override
  String get carroSemDespesas => 'Você ainda não registrou despesas.';

  @override
  String get carroNovaDespesa => 'Nova despesa';

  @override
  String get carroTipoDespesa => 'O que foi?';

  @override
  String get carroTipoIuc => 'IUC';

  @override
  String get carroTipoIpo => 'Inspeção';

  @override
  String get carroTipoSeguro => 'Seguro';

  @override
  String get carroTipoRevisao => 'Revisão';

  @override
  String get carroTipoPneus => 'Pneus';

  @override
  String get carroTipoReparacao => 'Conserto';

  @override
  String get carroTipoPortagem => 'Pedágio';

  @override
  String get carroTipoMulta => 'Multa';

  @override
  String get carroTipoEstacionamento => 'Estacionamento';

  @override
  String get carroTipoLavagem => 'Lavagem';

  @override
  String get carroTipoOutro => 'Outra';

  @override
  String get carroValor => 'Valor';

  @override
  String get carroNota => 'Nota (opcional)';

  @override
  String get carroNotaDica => 'Ex.: A23, Guarda → Covilhã';

  @override
  String get carroDataNotificacao => 'Quando você recebeu a notificação?';

  @override
  String carroPrazoMulta(String data, int n) {
    return 'Pagar até $data — $n dias úteis. Depois o valor sobe.';
  }

  @override
  String get carroMultaNoCalendario =>
      'Vai também para o calendário, com aviso na véspera.';

  @override
  String get carroDespesaGuardada => 'Despesa salva.';

  @override
  String carroMultasNota(int n) {
    return 'Pedágios e multas se pagam em $n dias úteis a contar da notificação.';
  }

  @override
  String get carroSemMultas => 'Nada a pagar.';

  @override
  String carroPagarAte(String data) {
    return 'pagar até $data';
  }

  @override
  String get carroEmBreve => 'Em breve';

  @override
  String get carroCentrosInspecao => 'Centros de inspeção perto de você';

  @override
  String get carroCentrosInspecaoLinha =>
      'Mapa com os centros mais próximos, a partir dos dados abertos do Estado.';

  @override
  String get carroCombustivelBarato =>
      'Combustível mais barato num raio de 10 km';

  @override
  String get carroCombustivelBaratoLinha =>
      'Preços de hoje, a partir dos dados abertos do Estado (DGEG).';

  @override
  String get carroNovoTitulo => 'Adicionar carro';

  @override
  String get carroNome => 'Nome (ex.: o Clio)';

  @override
  String get carroMatricula => 'Placa (matrícula)';

  @override
  String get carroMatriculaDica => 'AA-11-BB';

  @override
  String get carroMesMatricula => 'Mês da matrícula';

  @override
  String get carroAnoMatricula => 'Ano';

  @override
  String get carroMatriculaAjuda =>
      'Pelo mês eu sei quando é o IUC; pelo ano, quando é a inspeção.';

  @override
  String get carroCombustivel => 'Combustível';

  @override
  String get carroCombGasolina => 'Gasolina';

  @override
  String get carroCombGasoleo => 'Diesel (gasóleo)';

  @override
  String get carroCombEletrico => 'Elétrico';

  @override
  String get carroCombHibrido => 'Híbrido';

  @override
  String get carroCombGpl => 'GPL';

  @override
  String get carroCombOutro => 'Outro';

  @override
  String get carroCilindrada => 'Cilindrada (cc, opcional)';

  @override
  String get carroCo2 => 'CO2 g/km (opcional)';

  @override
  String get carroCilindradaAjuda =>
      'Está no DUA. Com esses dois eu estimo o IUC.';

  @override
  String get carroSeguradora => 'Seguradora';

  @override
  String get carroSeguroRenova => 'Quando renova o seguro?';

  @override
  String get carroUltimaIpo => 'Última inspeção (se já fez)';

  @override
  String get carroUsoTvde => 'Uso em TVDE';

  @override
  String get carroCartaValidade => 'Validade da carteira de motorista';

  @override
  String get carroFaltaMatricula => 'Escreva a placa.';

  @override
  String get carroFaltaMesMatricula => 'Escolha o mês da matrícula.';

  @override
  String get carroFaltaAnoMatricula =>
      'Escreva o ano da matrícula (4 dígitos).';

  @override
  String get maisSubtitulo => 'Todo o resto está aqui.';

  @override
  String get maisReforma => 'Aposentadoria e direitos';

  @override
  String get maisGuias => 'Guias de 1 minuto';

  @override
  String get maisPergunta => 'Pergunte ao Em Dia';

  @override
  String get maisAjuda => 'Ajuda';

  @override
  String get maisPlano => 'O seu plano';

  @override
  String get maisDefinicoes => 'Configurações';

  @override
  String get defsTitulo => 'Configurações';

  @override
  String get defsIdioma => 'Como eu falo com você';

  @override
  String get defsIdiomaAjuda =>
      'Muda só as palavras do app. As regras e os números são sempre os de Portugal.';

  @override
  String get defsPt => 'Português de Portugal';

  @override
  String get defsPtAjuda => 'Tu, reforma, telemóvel';

  @override
  String get defsBr => 'Português do Brasil';

  @override
  String get defsBrAjuda => 'Você, aposentadoria, celular';

  @override
  String get defsGuardado => 'Salvo.';

  @override
  String get defsConta => 'A sua conta';

  @override
  String get defsSairAjuda =>
      'Você sai do app neste celular. Seus dados ficam guardados.';

  @override
  String get defsApagarConta => 'Apagar a minha conta';

  @override
  String get defsApagarTitulo => 'Apagar a conta?';

  @override
  String get defsApagarTexto =>
      'Vou pedir para apagar a sua conta e os seus dados. Demora até 30 dias. Você deixa de receber avisos já hoje. Não dá para voltar atrás.';

  @override
  String get defsApagarConfirmar => 'Sim, apagar';

  @override
  String get defsApagarPedido => 'Pedido recebido. A conta vai ser apagada.';

  @override
  String defsVersao(String versao) {
    return 'Versão $versao';
  }

  @override
  String get defsSemPerfil => 'Entre no app para mudar as configurações.';

  @override
  String get reformaSubtitulo =>
      'O que você contribui hoje vale dinheiro amanhã.';

  @override
  String reformaDescontasHoje(String valor) {
    return 'Você contribui $valor por mês';
  }

  @override
  String get reformaValeCerca => 'vale cerca de';

  @override
  String get reformaPorMesDeReforma => 'por mês de aposentadoria';

  @override
  String reformaAnosDescontos(int anos) {
    return 'Se contribuir durante $anos anos';
  }

  @override
  String reformaAnosCurto(int anos) {
    return '$anos anos';
  }

  @override
  String get reformaEstimativaSimples => 'estimativa simples';

  @override
  String get reformaEstimativaNota =>
      'É uma conta simples, só para você ter uma ideia. A Segurança Social faz a conta certa com toda a sua carreira.';

  @override
  String get reformaSemDados =>
      'Me diga quanto você ganha por mês (no seu perfil) e eu faço a conta. Por enquanto conto com o mínimo.';

  @override
  String get reformaIdadeTitulo => 'Quando você pode se aposentar';

  @override
  String reformaIdadeRegra(int ano, String idade, int anos) {
    return 'Em $ano: aos $idade. Você precisa de $anos anos de contribuição, no mínimo.';
  }

  @override
  String reformaAnosEMeses(int anos, int meses) {
    return '$anos anos e $meses meses';
  }

  @override
  String get reformaBaixaTitulo => 'Auxílio-doença (baixa)';

  @override
  String reformaBaixaTexto(int dia, int meses) {
    return 'Se ficar doente, você recebe a partir do $dia.º dia de baixa. Precisa de $meses meses de contribuição.';
  }

  @override
  String get reformaParentalidadeTitulo => 'Licença parental';

  @override
  String get reformaParentalidadeTexto =>
      'Se tiver um filho, você recebe subsídio nos dias em que para para cuidar dele. Vale para o pai e para a mãe.';

  @override
  String get reformaCessacaoTitulo => 'Cessação de atividade';

  @override
  String reformaCessacaoTexto(int dias) {
    return 'É o \"seguro-desemprego\" dos autônomos: se fechar por falta de trabalho, você recebe um apoio. Precisa de $dias dias de contribuição.';
  }

  @override
  String get reformaFilhosTitulo => 'Assistência a filhos';

  @override
  String get reformaFilhosTexto =>
      'Se um filho ficar doente e você tiver que ficar com ele, recebe subsídio nesses dias.';

  @override
  String get reformaPerdesBaixa =>
      'Sem baixa: se ficar doente, você não recebe nada.';

  @override
  String get reformaPerdesSubsidio => 'Sem apoio se ficar sem trabalho.';

  @override
  String get reformaPerdesTempo =>
      'Os meses sem pagar não contam para a aposentadoria.';

  @override
  String get reformaPerdesDivida => 'A dívida fica lá e cresce com juros.';

  @override
  String get reformaAcordoTitulo => 'Acordo Portugal–Brasil';

  @override
  String get reformaAcordoTexto =>
      'Se você contribuiu no Brasil (INSS) e em Portugal, o tempo dos dois países se soma para a aposentadoria. Você não perde o que já pagou lá.';

  @override
  String get reformaAcordoBotao => 'Ver no site da Segurança Social';

  @override
  String get guiasSubtitulo => 'Um minuto cada. Você pode ouvir em vez de ler.';

  @override
  String get guiasUmMinuto => '1 minuto';

  @override
  String get guiasEmBreve =>
      'Este guia está sendo escrito. Em breve fica aqui, com a fonte oficial.';

  @override
  String get guiasVazio => 'Ainda não há guias. Volte daqui a pouco.';

  @override
  String get guiasPorConfirmar => 'por confirmar';

  @override
  String get guiasSemFonte => 'Fonte oficial: por confirmar';

  @override
  String get guiasOuvirErro => 'Não consegui ler em voz alta neste celular.';

  @override
  String get planoSubtitulo => 'Menos que uma multa.';

  @override
  String get planoEstadoTitulo => 'O que você tem agora';

  @override
  String get planoTrialDepois =>
      'Depois você passa para o plano grátis, com limites. Se ativar o Pro, fica tudo como está.';

  @override
  String planoLimAvisos(int n) {
    return '$n avisos por mês';
  }

  @override
  String planoLimCarros(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n carros',
      one: '1 carro',
    );
    return '$_temp0';
  }

  @override
  String planoLimPerguntas(int n) {
    return '$n perguntas ao Em Dia por mês';
  }

  @override
  String get planoLimResto => 'O resto aparece com cadeado.';

  @override
  String get planoTensPro => 'Você tem o Pro. Está tudo aberto.';

  @override
  String planoTensFamilia(int n) {
    return 'Você tem o Família / Frota. Está tudo aberto, para até $n pessoas ou carros.';
  }

  @override
  String get planoEscolhe => 'Escolha como pagar';

  @override
  String get planoPorMes => 'Por mês';

  @override
  String get planoPorAno => 'Por ano';

  @override
  String planoPrecoMes(String valor) {
    return '$valor/mês';
  }

  @override
  String planoPrecoAno(String valor) {
    return '$valor/ano';
  }

  @override
  String planoPoupas(String valor) {
    return 'você economiza $valor';
  }

  @override
  String get planoAbreAvisos => 'Avisos sem limite';

  @override
  String get planoAbreIa => 'Perguntas ao Em Dia sem limite';

  @override
  String get planoAbreFoto => 'Ler extratos por foto (Uber, Bolt, Glovo)';

  @override
  String get planoAbreComprovativos => 'Guardar as fotos dos comprovantes';

  @override
  String get planoAbreCarros => 'Vários carros';

  @override
  String get planoAbreExportar => 'Exportar para o contador (PDF ou planilha)';

  @override
  String get planoAbreReforma => 'Aposentadoria e direitos completo';

  @override
  String planoFamiliaAbre(int n) {
    return 'Tudo o que o Pro tem, para até $n pessoas ou carros';
  }

  @override
  String get planoAtivarPro => 'Ativar o Pro';

  @override
  String get planoAtivarFamilia => 'Ativar o Família';

  @override
  String get planoATrabalhar => 'Falando com a Google Play…';

  @override
  String get planoCompraOk => 'Pronto. Você já tem tudo aberto.';

  @override
  String get planoCompraErro =>
      'Não consegui fazer a compra. Não cobrei nada. Tente de novo daqui a pouco.';

  @override
  String get planoCompraCancelada => 'Você cancelou. Não cobrei nada.';

  @override
  String get planoLojaIndisponivel =>
      'A Google Play não está disponível neste celular. Veja se tem a Play Store instalada e com a sessão iniciada.';

  @override
  String get planoCancelarQuando =>
      'Você cancela quando quiser, na Google Play.';

  @override
  String get iaSuporteTitulo => 'Tire sua dúvida';

  @override
  String get iaVazio =>
      'Me pergunte sobre recibos, IVA, Segurança Social ou o seu carro. Respondo com as regras de 2026.';

  @override
  String get iaChip1 => 'Abri atividade em março, quando começo a pagar?';

  @override
  String get iaChip2 => 'Passei dos 15 mil, e agora?';

  @override
  String get iaChip3 => 'Posso pagar menos à Segurança Social?';

  @override
  String get iaChip4 => 'Quando é a inspeção do meu carro?';

  @override
  String iaContador(int usadas, int n) {
    return 'Você usou $usadas de $n perguntas este mês';
  }

  @override
  String get iaAPensar => 'Pensando…';

  @override
  String get iaDescansar =>
      'O assistente está descansando. Tente daqui a um minuto.';

  @override
  String get iaGuiaNovo => 'Pedi um guia novo sobre isso.';

  @override
  String get iaLimiteCta => 'Ative o Pro para perguntas sem limite.';

  @override
  String get iaVerPlano => 'Ver o plano Pro';

  @override
  String get suporteIntro => 'O que está acontecendo?';

  @override
  String get suporteDuvidaAjuda =>
      'O assistente responde na hora, com as regras de 2026.';

  @override
  String get suporteBugAjuda =>
      'Me conte o que falhou. Eu junto os dados técnicos.';

  @override
  String get suporteReembolsoAjuda => 'É feito na Google Play, em 2 minutos.';

  @override
  String get suporteAssunto => 'Assunto';

  @override
  String get suporteAssuntoDica => 'Ex.: O app fecha ao abrir o calendário';

  @override
  String get suporteDescricaoDica =>
      'O que você fez, o que esperava e o que aconteceu.';

  @override
  String get suporteLogsNota =>
      'Junto sozinho a versão do app, o tipo de celular e o seu plano. Nada de senhas.';

  @override
  String get suporteAssuntoEmFalta => 'Escreva o assunto.';

  @override
  String get suporteErro => 'Não consegui enviar. Tente de novo.';

  @override
  String suporteTicket(String id) {
    return 'Pedido n.º $id';
  }

  @override
  String get suporteRespostaTitulo => 'Resposta';

  @override
  String get suporteEscalado =>
      'Passei isso para uma pessoa da equipe. Respondemos aqui.';

  @override
  String get suporteFechar => 'Voltar à ajuda';

  @override
  String get suporteReembolsoLinha1 =>
      'A assinatura do Em Dia é cobrada pela Google Play, não por nós.';

  @override
  String get suporteReembolsoLinha2 =>
      'Para cancelar ou pedir reembolso, vá nas assinaturas da sua conta Google.';

  @override
  String get suporteReembolsoLinha3 =>
      'Você continua com o plano até o fim do período já pago.';

  @override
  String get suporteAbrirSubscricoes => 'Abrir minhas assinaturas';

  @override
  String get suporteReembolsoDescricao =>
      'Pedido aberto a partir do app (botão \"Abrir minhas assinaturas\").';

  @override
  String suporteRegistado(String id) {
    return 'Registrei o seu pedido n.º $id. Se a Google recusar, responda aqui com esse número.';
  }

  @override
  String get suporteMeusPedidos => 'Meus pedidos';

  @override
  String get suporteSemPedidos => 'Você ainda não tem pedidos.';

  @override
  String get suporteEstadoAberto => 'Aberto';

  @override
  String get suporteEstadoEmCurso => 'Em análise';

  @override
  String get suporteEstadoFechado => 'Resolvido';

  @override
  String get suporteTipoDuvida => 'Dúvida';

  @override
  String get suporteTipoBug => 'Problema';

  @override
  String get suporteTipoReembolso => 'Reembolso';

  @override
  String get suporteTipoGuia => 'Guia novo';

  @override
  String get suporteTipoOutro => 'Outro';

  @override
  String suporteEmailRodape(String email) {
    return 'Ou escreva para $email';
  }

  @override
  String get admNavVisaoGeral => 'Visão geral';

  @override
  String get admNavUsuarios => 'Usuários';

  @override
  String get admNavRegras => 'Regras legais';

  @override
  String get admNavTickets => 'Tickets';

  @override
  String get admNavIa => 'IA';

  @override
  String get admNavAvisos => 'Avisos';

  @override
  String get admNavAuditoria => 'Auditoria';

  @override
  String get admNaoAdmin => 'Esta conta não é administradora.';

  @override
  String admErroLer(String erro) {
    return 'Não consegui ler os dados: $erro';
  }

  @override
  String get admTentarDeNovo => 'Tentar de novo';

  @override
  String get admVazio => 'Nada por aqui ainda.';

  @override
  String get admErroTitulo => 'Deu erro';

  @override
  String get admFechar => 'Fechar';

  @override
  String get admConfirmar => 'Confirmar';

  @override
  String get admCopiar => 'Copiar';

  @override
  String get admCopiado => 'Copiado.';

  @override
  String get admAtualizar => 'Atualizar';

  @override
  String get admSalvar => 'Salvar';

  @override
  String get admSalvo => 'Salvo e registrado na auditoria.';

  @override
  String get admTodos => 'Todos';

  @override
  String get admSim => 'Sim';

  @override
  String get admNao => 'Não';

  @override
  String get admVgTitulo => 'Visão geral';

  @override
  String get admVgSub =>
      'Números de agora, direto das tabelas (RPC admin_resumo). Nada é calculado no navegador.';

  @override
  String get admVgUsuarios => 'Usuários';

  @override
  String admVgAtivos7(int n) {
    return '$n ativos nos últimos 7 dias';
  }

  @override
  String get admVgTrial => 'Em trial';

  @override
  String get admVgFree => 'Free';

  @override
  String get admVgPro => 'Pro';

  @override
  String get admVgFamilia => 'Família';

  @override
  String get admVgReceita => 'Receita estimada / mês';

  @override
  String admVgReceitaSub(int n) {
    return '$n assinaturas ativas × preço em regras_legais';
  }

  @override
  String get admVgTickets => 'Tickets abertos';

  @override
  String admVgTicketsSub(int n) {
    return '$n escalados para humano';
  }

  @override
  String get admVgCustoHoje => 'Custo IA hoje';

  @override
  String admVgCustoSub(String valor) {
    return 'Alarme acima de $valor por dia';
  }

  @override
  String get admVgCusto7 => 'Custo IA — 7 dias';

  @override
  String admVgCusto7Sub(int n) {
    return '$n conversas';
  }

  @override
  String get admVgPassadas => 'Obrigações passadas';

  @override
  String get admVgPassadasSub =>
      'Prazos vencidos sem marcar pago, em todos os usuários';

  @override
  String admVgAlarme(String custo, String limite) {
    return 'ALARME: o custo de IA de hoje ($custo) passou do limite ($limite, regra ia_custo_alarme_dia_eur). Confira o modelo e o limite de perguntas em Regras legais → Cadeados por plano.';
  }

  @override
  String get admVgTabDia => 'Dia';

  @override
  String get admVgTabConversas => 'Conversas';

  @override
  String get admVgTabCusto => 'Custo (€)';

  @override
  String get admVgPushHoje => 'Push de hoje por resultado';

  @override
  String get admVgPushVazio => 'Nenhum push enviado hoje.';

  @override
  String get admVgResultado => 'Resultado';

  @override
  String get admVgQuantidade => 'Quantidade';

  @override
  String get admUsTitulo => 'Usuários';

  @override
  String get admUsSub =>
      'profiles + plano efetivo (view v_admin_usuarios). Clique numa linha para ver o detalhe e agir.';

  @override
  String get admUsPesquisa => 'Buscar por e-mail ou nome (Enter para buscar)';

  @override
  String get admUsExportar => 'Exportar CSV';

  @override
  String admUsCsvTitulo(int n) {
    return 'CSV dos usuários ($n)';
  }

  @override
  String get admUsCsvNota =>
      'Copie e cole num arquivo .csv (separador ;). O download direto pelo navegador fica para uma próxima versão.';

  @override
  String admUsTabela(int n) {
    return '$n usuários';
  }

  @override
  String get admColEmail => 'E-mail';

  @override
  String get admColNome => 'Nome';

  @override
  String get admColAtividade => 'Atividade';

  @override
  String get admColPlano => 'Plano efetivo';

  @override
  String get admColTrialAte => 'Trial até';

  @override
  String get admColUltimoAcesso => 'Último acesso';

  @override
  String get admColEstado => 'Estado';

  @override
  String get admColCriadoEm => 'Criado em';

  @override
  String get admUsBanido => 'banido';

  @override
  String get admUsAtivo => 'ativo';

  @override
  String get admUsDetalhe => 'Usuário';

  @override
  String get admUsAcoes => 'Ações';

  @override
  String admUsPlanoAtual(String plano, String efetivo) {
    return 'Plano manual (profiles.plano): $plano · plano efetivo: $efetivo';
  }

  @override
  String get admUsBanir => 'Banir';

  @override
  String get admUsReativar => 'Reativar';

  @override
  String admUsBanirConfirma(String email) {
    return 'Banir $email? O usuário perde o acesso ao app até você reativar.';
  }

  @override
  String get admUsAlterarPlano => 'Alterar plano manual';

  @override
  String get admUsPlanoManualNota =>
      'profiles.plano vale só quando não há trial ativo nem assinatura ativa na Google Play.';

  @override
  String get admUsEstenderTrial => 'Estender trial';

  @override
  String admUsEstenderDias(int n) {
    return '+$n dias';
  }

  @override
  String get admUsApagar => 'Apagar conta';

  @override
  String get admUsApagarNota =>
      'Apagar do auth de verdade precisa da service role (servidor). Aqui só marca como banido e registra o pedido na auditoria — o servidor apaga depois.';

  @override
  String admUsApagarConfirma(String email) {
    return 'Marcar $email como banido e registrar o pedido de apagar a conta?';
  }

  @override
  String get admUsFeito => 'Feito e registrado na auditoria.';

  @override
  String get admUsPerfil => 'Perfil';

  @override
  String admUsObrigacoes(int n) {
    return 'Obrigações ($n)';
  }

  @override
  String admUsRendimentos(int n) {
    return 'Rendimentos ($n)';
  }

  @override
  String admUsAssinaturas(int n) {
    return 'Assinaturas ($n)';
  }

  @override
  String admUsConversas(int n) {
    return 'Últimas conversas com a IA ($n)';
  }

  @override
  String get admRgTitulo => 'Regras legais';

  @override
  String get admRgSub =>
      'A única fonte de números do app e da IA. Editar aqui muda o app na hora. Confira a fonte oficial antes de salvar.';

  @override
  String get admRgAba1 => 'Regras';

  @override
  String get admRgAba2 => 'Escalões IRS';

  @override
  String get admRgAba3 => 'Cadeados por plano';

  @override
  String get admRgPesquisa => 'Buscar chave ou descrição';

  @override
  String admRgTabela(int n, int total) {
    return '$n de $total regras';
  }

  @override
  String get admRgAvisoIas => 'Aviso em massa: o IAS mudou';

  @override
  String get admRgAvisoIasTitulo => 'O IAS mudou';

  @override
  String admRgAvisoIasCorpo(String valor) {
    return 'O IAS (o valor de referência da Segurança Social) mudou para $valor. Os seus valores foram recalculados. Abra o app para conferir.';
  }

  @override
  String get admRgAvisoTituloCampo => 'Título';

  @override
  String get admRgAvisoCorpoCampo => 'Texto do aviso';

  @override
  String get admRgAvisoCriado =>
      'Aviso em massa criado. O envio é feito pelo avisos-cron (tipo massa) às 09:00 de Lisboa.';

  @override
  String get admRgColChave => 'Chave';

  @override
  String get admRgColDescricao => 'Descrição';

  @override
  String get admRgColValor => 'Valor';

  @override
  String get admRgColUnidade => 'Unidade';

  @override
  String get admRgColAno => 'Ano';

  @override
  String get admRgColConfianca => 'Confiança';

  @override
  String get admRgColVerificado => 'Verificado em';

  @override
  String get admRgColFonte => 'Fonte';

  @override
  String get admRgEditar => 'Editar regra';

  @override
  String get admRgValorNum => 'Valor numérico (valor_num)';

  @override
  String get admRgValorTxt => 'Valor em texto (valor_txt)';

  @override
  String get admRgValorJson => 'Valor JSON (valor_json)';

  @override
  String get admRgJsonInvalido =>
      'O JSON não é válido. Confira as chaves e as vírgulas.';

  @override
  String get admRgFonteUrl => 'Fonte (URL oficial)';

  @override
  String get admRgVerificadoEm => 'Verificado em (aaaa-mm-dd)';

  @override
  String get admRgConfianca => 'Confiança';

  @override
  String get admRgEscOrdem => 'Ordem';

  @override
  String get admRgEscAte => 'Até (€)';

  @override
  String get admRgEscTaxa => 'Taxa';

  @override
  String get admRgEscTaxaAjuda => 'Taxa (0,13 = 13%)';

  @override
  String get admRgEscParcela => 'Parcela a abater (€)';

  @override
  String get admRgEscSemLimite => 'sem limite';

  @override
  String get admRgEscSemLimiteAjuda => 'Vazio = último escalão, sem limite';

  @override
  String get admRgEscEditar => 'Editar escalão';

  @override
  String get admRgFlagChave => 'Chave';

  @override
  String get admRgFlagDescricao => 'Descrição';

  @override
  String get admRgFlagFree => 'Free';

  @override
  String get admRgFlagPro => 'Pro';

  @override
  String get admRgFlagFamilia => 'Família';

  @override
  String get admRgFlagLimFree => 'Limite free';

  @override
  String get admRgFlagLimPro => 'Limite pro';

  @override
  String get admRgFlagLimFamilia => 'Limite família';

  @override
  String get admRgFlagEditar => 'Editar cadeado';

  @override
  String get admRgFlagLimiteAjuda => 'Vazio = sem limite';

  @override
  String get admTkTitulo => 'Tickets de suporte';

  @override
  String get admTkSub =>
      'tickets_suporte. Clique numa linha para ver a descrição, os logs e a resposta da IA.';

  @override
  String admTkTabela(int n) {
    return '$n tickets';
  }

  @override
  String get admTkEstadoAberto => 'Aberto';

  @override
  String get admTkEstadoEmCurso => 'Em andamento';

  @override
  String get admTkEstadoFechado => 'Fechado';

  @override
  String get admTkEscalados => 'Só escalados para humano';

  @override
  String get admTkColQuando => 'Quando';

  @override
  String get admTkColTipo => 'Tipo';

  @override
  String get admTkColAssunto => 'Assunto';

  @override
  String get admTkColEstado => 'Estado';

  @override
  String get admTkColEscalar => 'Humano';

  @override
  String get admTkColUsuario => 'Usuário';

  @override
  String admTkDetalhe(String id) {
    return 'Ticket $id';
  }

  @override
  String get admTkDescricao => 'Descrição';

  @override
  String get admTkLogs => 'Logs';

  @override
  String get admTkRespostaIa => 'Resposta da IA';

  @override
  String get admTkMotivo => 'Motivo da escalada';

  @override
  String get admTkMudarEstado => 'Mudar estado';

  @override
  String get admTkEstadoMudado =>
      'Estado atualizado e registrado na auditoria.';

  @override
  String get admTkParceiro => 'Contato do contador/advogado parceiro';

  @override
  String get admTkParceiroAjuda =>
      'Fica em regras_legais (chave contacto_parceiro_contabilista). É o que o suporte mostra quando um ticket sobe para humano. A linha é criada se não existir.';

  @override
  String get admTkParceiroCampo => 'Nome, telefone, e-mail';

  @override
  String get admTkParceiroSalvo => 'Contato salvo e registrado na auditoria.';

  @override
  String get admIaTitulo => 'IA — perguntas e custo';

  @override
  String get admIaSub =>
      'conversas_ia (RPC admin_ia_top_perguntas) e v_custo_ia_diario.';

  @override
  String get admIaVazio => 'Ainda não há perguntas registradas.';

  @override
  String get admIaTop => 'Perguntas mais feitas (top 30)';

  @override
  String get admIaColPergunta => 'Pergunta';

  @override
  String get admIaColVezes => 'Vezes';

  @override
  String get admIaColFora => 'Fora das regras';

  @override
  String get admIaColBr => 'Em PT-BR';

  @override
  String get admIaColUltima => 'Última vez';

  @override
  String get admIaColVariante => 'Variante';

  @override
  String get admIaColResposta => 'Resposta';

  @override
  String admIaFora(int n) {
    return 'Fora das regras ($n) — candidatas a guia novo';
  }

  @override
  String get admIaForaVazio =>
      'Nenhuma pergunta fora das regras. A IA só citou o que está na tabela.';

  @override
  String get admIaCriarGuia => 'Criar guia';

  @override
  String get admIaGuiaConfirma =>
      'Criar um rascunho de guia (publicado = não) com esta pergunta como corpo? Depois você edita o texto.';

  @override
  String admIaGuiaCriado(String slug) {
    return 'Rascunho de guia criado: $slug (publicado = não).';
  }

  @override
  String get admIaCusto => 'Custo por dia (últimos 30 dias)';

  @override
  String get admIaColDia => 'Dia';

  @override
  String get admIaColConversas => 'Conversas';

  @override
  String get admIaColCusto => 'Custo (€)';

  @override
  String get admAvTitulo => 'Avisos';

  @override
  String get admAvSub =>
      'Push enviados (eventos_push), avisos em massa (avisos_massa) e log dos testes E2E (e2e_log).';

  @override
  String get admAvNovoMassa => 'Novo aviso em massa';

  @override
  String get admAvMassaNota =>
      'O envio real é feito pelo avisos-cron (tipo massa) às 09:00 de Lisboa, no máximo 1 por usuário por dia. Aqui só cria.';

  @override
  String get admAvMassaVazio => 'Preencha o título e o texto do aviso.';

  @override
  String get admAvMassaCriado =>
      'Aviso em massa criado e registrado na auditoria.';

  @override
  String get admAvMassaVazioLista => 'Nenhum aviso em massa criado ainda.';

  @override
  String get admAvFiltroResultado => 'Resultado';

  @override
  String get admAvFiltroTipo => 'Tipo';

  @override
  String admAvPush(int n) {
    return 'Push — últimos $n';
  }

  @override
  String get admAvMassa => 'Avisos em massa';

  @override
  String get admAvE2e => 'E2E log — últimos 100';

  @override
  String get admAvColDia => 'Dia';

  @override
  String get admAvColTipo => 'Tipo';

  @override
  String get admAvColTitulo => 'Título';

  @override
  String get admAvColCorpo => 'Corpo';

  @override
  String get admAvColResultado => 'Resultado';

  @override
  String get admAvColEnviadoEm => 'Enviado em';

  @override
  String get admAvColErro => 'Erro';

  @override
  String get admAvColCriadoEm => 'Criado em';

  @override
  String get admAvColSegmento => 'Segmento';

  @override
  String get admAvColEnviados => 'Enviados';

  @override
  String get admAvNaoEnviado => 'ainda não';

  @override
  String get admAvColFluxo => 'Fluxo';

  @override
  String get admAvColPasso => 'Passo';

  @override
  String get admAvColEstado => 'Estado';

  @override
  String get admAvColDetalhe => 'Detalhe';

  @override
  String get admAvColDevice => 'Dispositivo';

  @override
  String get admAuTitulo => 'Auditoria';

  @override
  String get admAuSub =>
      'admin_audit_log — últimas 300 ações de administrador. Clique para ver o antes e o depois.';

  @override
  String get admAuFiltroAcao =>
      'Buscar ação (ex.: usuario_banir, regra_editar)';

  @override
  String admAuTabela(int n) {
    return '$n ações';
  }

  @override
  String admAuDetalhe(String id) {
    return 'Ação #$id';
  }

  @override
  String get admAuColQuando => 'Quando';

  @override
  String get admAuColAdmin => 'Admin';

  @override
  String get admAuColAcao => 'Ação';

  @override
  String get admAuColAlvo => 'Alvo';

  @override
  String get admAuColAntes => 'Antes';

  @override
  String get admAuColDepois => 'Depois';

  @override
  String get carroFormBasicoAjuda =>
      'Só preciso destas três coisas. Pelo mês eu fico sabendo quando você paga o imposto do carro; pelo ano, quando é a inspeção.';

  @override
  String get carroFormMatriculaInvalida =>
      'Essa placa não me parece certa. Escreva as letras e os números, assim: AA-00-AA.';

  @override
  String get carroFormOpcionalTitulo => 'Quer ajustar as contas? (opcional)';

  @override
  String get carroFormOpcionalAjuda =>
      'Você pode fechar isto e salvar agora. Só com a placa e a data eu já aviso a tempo do imposto do carro, da inspeção e do seguro. Estes extras servem para eu acertar melhor o valor do imposto do carro — sem eles o app avisa do mesmo jeito, só não diz um valor certo.';

  @override
  String get carroFormAbrir => 'Abrir';

  @override
  String get carroFormFechar => 'Fechar';

  @override
  String get carroFormIucPorConfirmar => 'imposto por confirmar';

  @override
  String get carroFormIucContaFeita => 'já consigo calcular o imposto';

  @override
  String get carroFormIucPorConfirmarLinha =>
      'Sem a cilindrada eu não invento nenhum valor: aviso na data certa e escrevo «por confirmar» no lugar de um número errado.';

  @override
  String get carroFormCilindrada => 'Cilindrada (o tamanho do motor, em cc)';

  @override
  String get carroFormCo2 => 'CO2 (o gás que o carro solta, em g/km)';

  @override
  String get carroFormOndeEstao =>
      'Estes dois números estão no documento do carro (o certificado de matrícula).';

  @override
  String get guiaIniSaltar => 'Pular';

  @override
  String get guiaIniSeguinte => 'Próximo';

  @override
  String get guiaIniComecar => 'Começar';

  @override
  String guiaIniPasso(int n, int total) {
    return 'Tela $n de $total';
  }

  @override
  String get guiaIniAvisoTitulo => 'Eu te aviso';

  @override
  String get guiaIniAvisoTexto =>
      'Cada coisa que você tem que pagar tem um dia certo. Eu te aviso antes desse dia, com tempo para você resolver. Assim você nunca paga multa só por ter esquecido.';

  @override
  String get guiaIniGanhosTitulo => 'Anote o que você ganha';

  @override
  String get guiaIniGanhosTexto =>
      'Toda vez que você receber dinheiro, anote aqui. Leva poucos segundos. Quanto mais você anotar, mais certas ficam as minhas contas e os meus avisos.';

  @override
  String get guiaIniPerguntaTitulo => 'Me pergunte o que quiser';

  @override
  String get guiaIniPerguntaTexto =>
      'Ficou com dúvida? Escreva como se estivesse falando com um amigo. Eu respondo em português simples, a qualquer hora do dia ou da noite.';

  @override
  String get painelAcaoEtiqueta => 'O que fazer agora';

  @override
  String get painelAcaoPagaSs => 'Pague a Segurança Social';

  @override
  String get painelAcaoEntregaSs => 'Entregue a declaração da Segurança Social';

  @override
  String get painelAcaoPagaIva => 'Pague o IVA (o imposto da nota fiscal)';

  @override
  String get painelAcaoEntregaIva => 'Entregue a declaração do IVA';

  @override
  String get painelAcaoEntregaIrs => 'Entregue o IRS';

  @override
  String get painelAcaoPagaIrsConta => 'Pague o adiantamento do IRS';

  @override
  String get painelAcaoValidaFaturas => 'Valide suas faturas no e-fatura';

  @override
  String get painelAcaoComunicaFaturas => 'Informe as faturas que você emitiu';

  @override
  String get painelAcaoPagaIuc => 'Pague o IUC (o imposto do carro)';

  @override
  String get painelAcaoInspecao => 'Leve o carro na inspeção';

  @override
  String get painelAcaoRevisao => 'Faça a revisão do carro';

  @override
  String get painelAcaoSeguro => 'Pague o seguro do carro';

  @override
  String get painelAcaoCarta => 'Renove a carta de condução';

  @override
  String get painelAcaoTrocaCarta => 'Troque a carta de condução';

  @override
  String get painelAcaoResidencia => 'Renove a autorização de residência';

  @override
  String get painelAcaoCertificadoTvde =>
      'Renove o certificado de motorista TVDE';

  @override
  String get painelAcaoLicencaTvde => 'Renove a licença TVDE do carro';

  @override
  String get painelAcaoMulta => 'Pague a multa';

  @override
  String get painelAcaoPortagem => 'Pague o pedágio';

  @override
  String get painelAcaoFimIsencao =>
      'Se prepare: sua isenção da Segurança Social está acabando';

  @override
  String painelAcaoGenerica(String nome) {
    return 'Cuide disto: $nome';
  }

  @override
  String get painelAcaoValorPorSaber => 'Ainda não sei o valor';

  @override
  String painelAcaoPrazoPassou(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Já passou faz $dias dias',
      one: 'Já passou faz 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get painelAcaoPrazoHoje => 'É hoje mesmo';

  @override
  String get painelAcaoPrazoAmanha => 'É amanhã';

  @override
  String painelAcaoPrazoDiaSemana(String diaSemana, int dia) {
    return 'Até $diaSemana, dia $dia';
  }

  @override
  String painelAcaoPrazoData(String data) {
    return 'Até $data';
  }

  @override
  String get painelAcaoDia1 => 'segunda';

  @override
  String get painelAcaoDia2 => 'terça';

  @override
  String get painelAcaoDia3 => 'quarta';

  @override
  String get painelAcaoDia4 => 'quinta';

  @override
  String get painelAcaoDia5 => 'sexta';

  @override
  String get painelAcaoDia6 => 'sábado';

  @override
  String get painelAcaoDia7 => 'domingo';

  @override
  String get painelAcaoBotaoComoPagar => 'Ver como pagar';

  @override
  String get painelAcaoBotaoOQueFazer => 'Ver o que eu tenho de fazer';

  @override
  String get painelAcaoTudoTitulo => 'Você não tem nada para pagar agora';

  @override
  String get painelAcaoTudoAjuda =>
      'Está tudo resolvido. Quando aparecer um prazo, eu coloco aqui e aviso você antes.';

  @override
  String get painelAcaoTudoSugestao =>
      'Já que dá: escreva quanto você ganhou neste mês. Com esse número eu faço as contas certas para você.';

  @override
  String get painelAcaoTudoBotao => 'Escrever o que ganhei';

  @override
  String get oficioServicos => 'Serviços (cabelo, unhas, limpeza…)';

  @override
  String get oficioObras => 'Obras e construção';

  @override
  String get oficioOutro => 'Outra coisa';

  @override
  String get oficioComoFunciona => 'Como isso funciona';

  @override
  String get oficioExplicacaoTvde =>
      'Aqui você cuida dos seus recibos das viagens. Escreva quanto você ganhou, eu faço as contas e digo o que é mesmo seu e o que é do Estado.';

  @override
  String get oficioExplicacaoEstafeta =>
      'Aqui você cuida dos seus recibos das entregas. Escreva quanto você ganhou, eu faço as contas e digo o que é mesmo seu e o que é do Estado.';

  @override
  String get oficioExplicacaoServicos =>
      'Aqui você cuida dos recibos dos seus clientes. Escreva quanto você ganhou, eu faço as contas e digo o que é mesmo seu e o que é do Estado.';

  @override
  String get oficioExplicacaoObras =>
      'Aqui você cuida dos recibos dos seus trabalhos na obra. Escreva quanto você ganhou, eu faço as contas e digo o que é mesmo seu e o que é do Estado.';

  @override
  String get oficioExplicacaoFreelancer =>
      'Aqui você cuida dos recibos dos trabalhos que você entrega. Escreva quanto você ganhou, eu faço as contas e digo o que é mesmo seu e o que é do Estado.';

  @override
  String get oficioExplicacaoOutro =>
      'Aqui você cuida dos seus recibos. Escreva quanto você ganhou, eu faço as contas e digo o que é mesmo seu e o que é do Estado.';

  @override
  String get oficioExplicacaoGeral =>
      'Aqui você cuida dos recibos verdes. Escreva quanto você ganhou, eu faço as contas e digo o que é mesmo seu e o que é do Estado.';

  @override
  String get oficioAjudaTvde =>
      'No fim do mês abra o extrato da Uber ou da Bolt, pegue o total que pagaram a você e escreva aqui.';

  @override
  String get oficioAjudaEstafeta =>
      'No fim do mês abra o extrato da Glovo, da Bolt Food ou da Uber Eats, pegue o total que pagaram a você e escreva aqui.';

  @override
  String get oficioAjudaServicos =>
      'Faça um recibo para cada cliente que paga a você. No fim do mês some tudo e escreva aqui o total.';

  @override
  String get oficioAjudaObras =>
      'Faça um recibo para cada trabalho que pagam a você, seja ao dono da casa seja à empresa. No fim do mês some tudo e escreva aqui o total.';

  @override
  String get oficioAjudaFreelancer =>
      'Faça um recibo para cada trabalho que você entrega. No fim do mês some tudo e escreva aqui o total.';

  @override
  String get oficioAjudaOutro =>
      'Faça um recibo sempre que alguém paga o seu trabalho. No fim do mês some tudo e escreva aqui o total.';

  @override
  String get oficioAjudaGeral =>
      'Faça um recibo sempre que alguém paga o seu trabalho. No fim do mês some tudo e escreva aqui o total.';

  @override
  String get oficioExemploTvde =>
      'No seu caso o cliente é a plataforma: a Uber ou a Bolt. O número de contribuinte delas está no extrato.';

  @override
  String get oficioExemploEstafeta =>
      'No seu caso o cliente é a plataforma: a Glovo, a Bolt Food ou a Uber Eats. O número de contribuinte delas está no extrato.';

  @override
  String get oficioExemploServicos =>
      'No seu caso o cliente é quem pagou: a pessoa que você atendeu ou o salão. Peça a ela o número de contribuinte.';

  @override
  String get oficioExemploObras =>
      'No seu caso o cliente é quem pagou a obra: o dono da casa ou a empresa de construção. Peça a ele o número de contribuinte.';

  @override
  String get oficioExemploFreelancer =>
      'No seu caso o cliente é a empresa ou a pessoa para quem você fez o trabalho. Peça a ela o número de contribuinte.';

  @override
  String get oficioExemploOutro =>
      'No seu caso o cliente é a pessoa ou a empresa que pagou a você. Peça a ela o número de contribuinte.';

  @override
  String get oficioExemploGeral =>
      'O cliente é a pessoa ou a empresa que paga a você. Peça a ela o número de contribuinte.';

  @override
  String get oficioDescricaoTvde =>
      'Serviços de transporte em veículo descaracterizado (TVDE)';

  @override
  String get oficioDescricaoEstafeta => 'Serviços de entrega ao domicílio';

  @override
  String get oficioDescricaoServicos =>
      'Prestação de serviços de cabeleireiro e estética';

  @override
  String get oficioDescricaoObras => 'Serviços de construção civil';

  @override
  String get oficioDescricaoFreelancer => 'Prestação de serviços';

  @override
  String get oficioDescricaoOutro => 'Prestação de serviços';

  @override
  String get oficioDescricaoGeral => 'Prestação de serviços';

  @override
  String get sufixoLitros => 'L';

  @override
  String get sufixoKm => 'km';
}
