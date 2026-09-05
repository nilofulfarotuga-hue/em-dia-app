import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appNome.
  ///
  /// In pt, this message translates to:
  /// **'Em Dia'**
  String get appNome;

  /// No description provided for @boasVindas.
  ///
  /// In pt, this message translates to:
  /// **'Olá! Eu sou o Em Dia. A partir de agora não te esqueces de nada: Segurança Social, IVA, IRS, carro. Vamos começar com 4 perguntas rápidas.'**
  String get boasVindas;

  /// No description provided for @fimOnboardingUma.
  ///
  /// In pt, this message translates to:
  /// **'Pronto. Este mês só tens uma coisa: {obrigacao}, {valor}, até dia {dia}. Eu aviso-te no dia {diaAviso}.'**
  String fimOnboardingUma(
    String obrigacao,
    String valor,
    String dia,
    String diaAviso,
  );

  /// No description provided for @fimOnboardingVarias.
  ///
  /// In pt, this message translates to:
  /// **'Pronto. Este mês tens {n} coisas: {lista}. Eu aviso-te. Nos próximos 30 dias tens tudo aberto, sem cartão.'**
  String fimOnboardingVarias(int n, String lista);

  /// No description provided for @fimOnboardingNada.
  ///
  /// In pt, this message translates to:
  /// **'Pronto. Este mês não tens nada a pagar. Eu aviso-te quando houver. Nos próximos 30 dias tens tudo aberto, sem cartão.'**
  String get fimOnboardingNada;

  /// No description provided for @push5Dias.
  ///
  /// In pt, this message translates to:
  /// **'Faltam 5 dias para {obrigacao} ({valor}). Toca aqui para ver como pagar.'**
  String push5Dias(String obrigacao, String valor);

  /// No description provided for @pushDia.
  ///
  /// In pt, this message translates to:
  /// **'É hoje. {obrigacao}, {valor}, até à meia-noite. Já pagaste? Toca em Já paguei.'**
  String pushDia(String obrigacao, String valor);

  /// No description provided for @pushPassado.
  ///
  /// In pt, this message translates to:
  /// **'Passou o dia {dia} e não marcaste como pago. Não é o fim do mundo: paga hoje, os juros são pequenos. Se já pagaste, toca aqui.'**
  String pushPassado(String dia);

  /// No description provided for @pushVigiaIva.
  ///
  /// In pt, this message translates to:
  /// **'Atenção: já vais em {valor} este ano. Se passares os 15.000 €, no próximo ano tens de cobrar IVA. Queres perceber o que muda?'**
  String pushVigiaIva(String valor);

  /// No description provided for @pushFimIsencao.
  ///
  /// In pt, this message translates to:
  /// **'Daqui a 30 dias acaba a tua isenção de Segurança Social. A partir de {mes} vais pagar cerca de {valor}/mês. Já estás avisado, sem sustos.'**
  String pushFimIsencao(String mes, String valor);

  /// No description provided for @pushCarro.
  ///
  /// In pt, this message translates to:
  /// **'A inspeção do teu carro ({matricula}) é até {data}. Marca já — os centros enchem no fim do mês.'**
  String pushCarro(String matricula, String data);

  /// No description provided for @pushReforma.
  ///
  /// In pt, this message translates to:
  /// **'Este trimestre descontaste {valor}. São mais 3 meses a contar para a tua reforma. Continua.'**
  String pushReforma(String valor);

  /// No description provided for @pushTrial25.
  ///
  /// In pt, this message translates to:
  /// **'Faltam 5 dias para o teu mês grátis acabar. Depois disso o Em Dia continua a avisar-te, mas com limites. Por 3,49 €/mês (ou 29,90 €/ano) fica tudo como está.'**
  String get pushTrial25;

  /// No description provided for @pushTrial31.
  ///
  /// In pt, this message translates to:
  /// **'Hoje evitaste multas durante um mês. Para continuar assim é 3,49 € por mês — menos que uma multa. Toca para ativar.'**
  String get pushTrial31;

  /// No description provided for @pushReativacao.
  ///
  /// In pt, this message translates to:
  /// **'Está tudo em dia do teu lado. Não precisas de fazer nada. Eu avisarei.'**
  String get pushReativacao;

  /// No description provided for @semaforoVerde.
  ///
  /// In pt, this message translates to:
  /// **'Está tudo em dia'**
  String get semaforoVerde;

  /// No description provided for @semaforoAmareloUma.
  ///
  /// In pt, this message translates to:
  /// **'Tens 1 coisa a vencer em {dias} dias'**
  String semaforoAmareloUma(int dias);

  /// No description provided for @semaforoAmareloVarias.
  ///
  /// In pt, this message translates to:
  /// **'Tens {n} coisas a vencer em {dias} dias'**
  String semaforoAmareloVarias(int n, int dias);

  /// No description provided for @semaforoVermelhoUma.
  ///
  /// In pt, this message translates to:
  /// **'Tens 1 prazo passado — resolve agora'**
  String get semaforoVermelhoUma;

  /// No description provided for @semaforoVermelhoVarias.
  ///
  /// In pt, this message translates to:
  /// **'Tens {n} prazos passados — resolve agora'**
  String semaforoVermelhoVarias(int n);

  /// No description provided for @cartaoEsteMesPagas.
  ///
  /// In pt, this message translates to:
  /// **'Este mês pagas'**
  String get cartaoEsteMesPagas;

  /// No description provided for @cartaoGuardarIrs.
  ///
  /// In pt, this message translates to:
  /// **'Guardar para o IRS'**
  String get cartaoGuardarIrs;

  /// No description provided for @cartaoProximoPrazo.
  ///
  /// In pt, this message translates to:
  /// **'Próximo prazo'**
  String get cartaoProximoPrazo;

  /// No description provided for @jaPaguei.
  ///
  /// In pt, this message translates to:
  /// **'Já paguei'**
  String get jaPaguei;

  /// No description provided for @faltamDias.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {dias} dias'**
  String faltamDias(int dias);

  /// No description provided for @eHoje.
  ///
  /// In pt, this message translates to:
  /// **'É hoje'**
  String get eHoje;

  /// No description provided for @passouHaDias.
  ///
  /// In pt, this message translates to:
  /// **'Passou há {dias} dias'**
  String passouHaDias(int dias);

  /// No description provided for @nadaAPagarEsteMes.
  ///
  /// In pt, this message translates to:
  /// **'Nada a pagar este mês. Respira.'**
  String get nadaAPagarEsteMes;

  /// No description provided for @fraseHumanaVerde.
  ///
  /// In pt, this message translates to:
  /// **'Hoje não tens de fazer nada. Eu estou de olho.'**
  String get fraseHumanaVerde;

  /// No description provided for @fraseHumanaAmarelo.
  ///
  /// In pt, this message translates to:
  /// **'Um passo de cada vez. Vê o que vence primeiro.'**
  String get fraseHumanaAmarelo;

  /// No description provided for @fraseHumanaVermelho.
  ///
  /// In pt, this message translates to:
  /// **'Não é o fim do mundo. Paga hoje e fica arrumado.'**
  String get fraseHumanaVermelho;

  /// No description provided for @juntarComprovativo.
  ///
  /// In pt, this message translates to:
  /// **'Juntar foto do comprovativo'**
  String get juntarComprovativo;

  /// No description provided for @comoPagar.
  ///
  /// In pt, this message translates to:
  /// **'Como pagar'**
  String get comoPagar;

  /// No description provided for @verComoPagar.
  ///
  /// In pt, this message translates to:
  /// **'Ver como pagar'**
  String get verComoPagar;

  /// No description provided for @navPainel.
  ///
  /// In pt, this message translates to:
  /// **'Painel'**
  String get navPainel;

  /// No description provided for @navRecibos.
  ///
  /// In pt, this message translates to:
  /// **'Recibos'**
  String get navRecibos;

  /// No description provided for @navCalendario.
  ///
  /// In pt, this message translates to:
  /// **'Calendário'**
  String get navCalendario;

  /// No description provided for @navCarro.
  ///
  /// In pt, this message translates to:
  /// **'Carro'**
  String get navCarro;

  /// No description provided for @navMais.
  ///
  /// In pt, this message translates to:
  /// **'Mais'**
  String get navMais;

  /// No description provided for @onbOQueFazes.
  ///
  /// In pt, this message translates to:
  /// **'O que fazes?'**
  String get onbOQueFazes;

  /// No description provided for @onbTvde.
  ///
  /// In pt, this message translates to:
  /// **'Motorista TVDE'**
  String get onbTvde;

  /// No description provided for @onbEstafeta.
  ///
  /// In pt, this message translates to:
  /// **'Estafeta'**
  String get onbEstafeta;

  /// No description provided for @onbServicos.
  ///
  /// In pt, this message translates to:
  /// **'Serviços (cabelo, obras, limpeza…)'**
  String get onbServicos;

  /// No description provided for @onbFreelancer.
  ///
  /// In pt, this message translates to:
  /// **'Freelancer'**
  String get onbFreelancer;

  /// No description provided for @onbSemAtividade.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não abri atividade'**
  String get onbSemAtividade;

  /// No description provided for @onbSoCarro.
  ///
  /// In pt, this message translates to:
  /// **'Só quero o carro'**
  String get onbSoCarro;

  /// No description provided for @onbQuandoAbriste.
  ///
  /// In pt, this message translates to:
  /// **'Quando abriste atividade?'**
  String get onbQuandoAbriste;

  /// No description provided for @onbQuandoAbristeAjuda.
  ///
  /// In pt, this message translates to:
  /// **'A data que está no Portal das Finanças. Se não tens a certeza, mete o mês aproximado — dá para mudar depois.'**
  String get onbQuandoAbristeAjuda;

  /// No description provided for @onbFaturouMais15k.
  ///
  /// In pt, this message translates to:
  /// **'No ano passado faturaste mais de 15.000 €?'**
  String get onbFaturouMais15k;

  /// No description provided for @onbFaturouMais15kAjuda.
  ///
  /// In pt, this message translates to:
  /// **'É isto que decide se cobras IVA (o imposto que vai na fatura).'**
  String get onbFaturouMais15kAjuda;

  /// No description provided for @onbSim.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get onbSim;

  /// No description provided for @onbNao.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get onbNao;

  /// No description provided for @onbTensCarro.
  ///
  /// In pt, this message translates to:
  /// **'Tens carro?'**
  String get onbTensCarro;

  /// No description provided for @onbMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Matrícula'**
  String get onbMatricula;

  /// No description provided for @onbMatriculaAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Pela matrícula eu descubro o mês do IUC (o imposto do carro) e quando é a inspeção.'**
  String get onbMatriculaAjuda;

  /// No description provided for @onbDataMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Mês e ano da matrícula'**
  String get onbDataMatricula;

  /// No description provided for @onbSeguroMes.
  ///
  /// In pt, this message translates to:
  /// **'Em que mês renova o seguro?'**
  String get onbSeguroMes;

  /// No description provided for @onbUltimaIpo.
  ///
  /// In pt, this message translates to:
  /// **'Quando foi a última inspeção?'**
  String get onbUltimaIpo;

  /// No description provided for @onbProprioOuFrota.
  ///
  /// In pt, this message translates to:
  /// **'O carro é teu ou alugado à frota?'**
  String get onbProprioOuFrota;

  /// No description provided for @onbProprio.
  ///
  /// In pt, this message translates to:
  /// **'É meu'**
  String get onbProprio;

  /// No description provided for @onbAlugadoFrota.
  ///
  /// In pt, this message translates to:
  /// **'Alugado à frota'**
  String get onbAlugadoFrota;

  /// No description provided for @onbQuantoGanhas.
  ///
  /// In pt, this message translates to:
  /// **'Quanto ganhas por mês, mais ou menos?'**
  String get onbQuantoGanhas;

  /// No description provided for @onbQuantoGanhasAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Só para fazer a primeira simulação. Pode ser aproximado.'**
  String get onbQuantoGanhasAjuda;

  /// No description provided for @onbPorMes.
  ///
  /// In pt, this message translates to:
  /// **'por mês'**
  String get onbPorMes;

  /// No description provided for @onbContinuar.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get onbContinuar;

  /// No description provided for @onbVoltar.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get onbVoltar;

  /// No description provided for @onbSaltar.
  ///
  /// In pt, this message translates to:
  /// **'Saltar'**
  String get onbSaltar;

  /// No description provided for @onbComecar.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get onbComecar;

  /// No description provided for @onbEntrarNaApp.
  ///
  /// In pt, this message translates to:
  /// **'Entrar na app'**
  String get onbEntrarNaApp;

  /// No description provided for @loginTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Entra com o teu e-mail'**
  String get loginTitulo;

  /// No description provided for @loginAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Mando-te um código de 6 números. Sem palavra-passe, sem complicações.'**
  String get loginAjuda;

  /// No description provided for @loginEmail.
  ///
  /// In pt, this message translates to:
  /// **'O teu e-mail'**
  String get loginEmail;

  /// No description provided for @loginEnviarCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Enviar código'**
  String get loginEnviarCodigo;

  /// No description provided for @loginCodigoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Escreve o código que chegou ao e-mail'**
  String get loginCodigoTitulo;

  /// No description provided for @loginCodigo.
  ///
  /// In pt, this message translates to:
  /// **'Código de 6 números'**
  String get loginCodigo;

  /// No description provided for @loginConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get loginConfirmar;

  /// No description provided for @loginGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get loginGoogle;

  /// No description provided for @loginOu.
  ///
  /// In pt, this message translates to:
  /// **'ou'**
  String get loginOu;

  /// No description provided for @loginErro.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui entrar. Vê se o e-mail está certo e tenta outra vez.'**
  String get loginErro;

  /// No description provided for @loginCodigoErrado.
  ///
  /// In pt, this message translates to:
  /// **'Esse código não bate certo. Tenta outra vez ou pede um novo.'**
  String get loginCodigoErrado;

  /// No description provided for @sair.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get sair;

  /// No description provided for @calcTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Calculadora de recibo'**
  String get calcTitulo;

  /// No description provided for @calcValorRecibo.
  ///
  /// In pt, this message translates to:
  /// **'Valor do recibo (sem IVA)'**
  String get calcValorRecibo;

  /// No description provided for @calcRetencao.
  ///
  /// In pt, this message translates to:
  /// **'Retenção na fonte (o que o cliente guarda para as Finanças)'**
  String get calcRetencao;

  /// No description provided for @calcRetencaoPadrao.
  ///
  /// In pt, this message translates to:
  /// **'23% (padrão)'**
  String get calcRetencaoPadrao;

  /// No description provided for @calcRetencao25.
  ///
  /// In pt, this message translates to:
  /// **'25% (por opção)'**
  String get calcRetencao25;

  /// No description provided for @calcRetencaoDispensa.
  ///
  /// In pt, this message translates to:
  /// **'Dispensa (faturei menos de 15.000 € no ano passado)'**
  String get calcRetencaoDispensa;

  /// No description provided for @calcIva.
  ///
  /// In pt, this message translates to:
  /// **'IVA'**
  String get calcIva;

  /// No description provided for @calcIvaIsento.
  ///
  /// In pt, this message translates to:
  /// **'Isento (art. 53.º) — até 15.000 €/ano'**
  String get calcIvaIsento;

  /// No description provided for @calcIvaNormal.
  ///
  /// In pt, this message translates to:
  /// **'23%'**
  String get calcIvaNormal;

  /// No description provided for @calcBruto.
  ///
  /// In pt, this message translates to:
  /// **'Bruto'**
  String get calcBruto;

  /// No description provided for @calcRetencaoValor.
  ///
  /// In pt, this message translates to:
  /// **'Retenção'**
  String get calcRetencaoValor;

  /// No description provided for @calcIvaValor.
  ///
  /// In pt, this message translates to:
  /// **'IVA a cobrar'**
  String get calcIvaValor;

  /// No description provided for @calcLiquido.
  ///
  /// In pt, this message translates to:
  /// **'O que recebes mesmo'**
  String get calcLiquido;

  /// No description provided for @calcMencaoIsencao.
  ///
  /// In pt, this message translates to:
  /// **'Frase para pôr no recibo'**
  String get calcMencaoIsencao;

  /// No description provided for @calcCopiar.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get calcCopiar;

  /// No description provided for @calcCopiado.
  ///
  /// In pt, this message translates to:
  /// **'Copiado'**
  String get calcCopiado;

  /// No description provided for @vigiaIvaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Vigia do IVA'**
  String get vigiaIvaTitulo;

  /// No description provided for @vigiaIvaBarra.
  ///
  /// In pt, this message translates to:
  /// **'Estás em {atual} de {limite}'**
  String vigiaIvaBarra(String atual, String limite);

  /// No description provided for @vigiaIvaOk.
  ///
  /// In pt, this message translates to:
  /// **'Estás longe do limite. Continua a registar.'**
  String get vigiaIvaOk;

  /// No description provided for @vigiaIvaAviso.
  ///
  /// In pt, this message translates to:
  /// **'Atenção: já passaste os 12.000 €. Se chegares aos 15.000 € este ano, no próximo ano cobras IVA.'**
  String get vigiaIvaAviso;

  /// No description provided for @vigiaIvaAlarme.
  ///
  /// In pt, this message translates to:
  /// **'Passaste os 15.000 €. No próximo ano tens de cobrar IVA (23%). Fala com o contabilista.'**
  String get vigiaIvaAlarme;

  /// No description provided for @vigiaIvaCritico.
  ///
  /// In pt, this message translates to:
  /// **'Passaste os 18.750 €: perdes a isenção JÁ. A próxima fatura leva IVA e tens 15 dias úteis para avisar as Finanças.'**
  String get vigiaIvaCritico;

  /// No description provided for @ssTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Segurança Social'**
  String get ssTitulo;

  /// No description provided for @ssIsencaoAte.
  ///
  /// In pt, this message translates to:
  /// **'Estás isento até {data}'**
  String ssIsencaoAte(String data);

  /// No description provided for @ssIsencaoFaltam.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {meses} meses de isenção'**
  String ssIsencaoFaltam(int meses);

  /// No description provided for @ssDeclararEm.
  ///
  /// In pt, this message translates to:
  /// **'Declaras em {mes} o que ganhaste nos últimos 3 meses'**
  String ssDeclararEm(String mes);

  /// No description provided for @ssPagaPorMes.
  ///
  /// In pt, this message translates to:
  /// **'Depois pagas cerca de {valor} por mês, do dia 10 ao dia 20'**
  String ssPagaPorMes(String valor);

  /// No description provided for @ssAjustar.
  ///
  /// In pt, this message translates to:
  /// **'Quero pagar 25% a menos / a mais'**
  String get ssAjustar;

  /// No description provided for @ssAjustarAjuda.
  ///
  /// In pt, this message translates to:
  /// **'A lei deixa ajustar até 25% para cima ou para baixo. Menos agora = menos reforma depois.'**
  String get ssAjustarAjuda;

  /// No description provided for @irsTitulo.
  ///
  /// In pt, this message translates to:
  /// **'IRS'**
  String get irsTitulo;

  /// No description provided for @irsGuardarEsteMes.
  ///
  /// In pt, this message translates to:
  /// **'Guarda {valor} este mês para o IRS'**
  String irsGuardarEsteMes(String valor);

  /// No description provided for @irsEstimativaAno.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa para o ano: {valor}'**
  String irsEstimativaAno(String valor);

  /// No description provided for @irsMinimoExistencia.
  ///
  /// In pt, this message translates to:
  /// **'Abaixo de {valor} por ano não pagas IRS (mínimo de existência).'**
  String irsMinimoExistencia(String valor);

  /// No description provided for @irsAvisoDespesas.
  ///
  /// In pt, this message translates to:
  /// **'Acima de {valor} por ano tens de justificar 15% com faturas com NIF. Verifica com um contabilista.'**
  String irsAvisoDespesas(String valor);

  /// No description provided for @irsPagamentosConta.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos por conta: 20 jul · 20 set · 20 dez'**
  String get irsPagamentosConta;

  /// No description provided for @rendTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Rendimentos'**
  String get rendTitulo;

  /// No description provided for @rendAdicionar.
  ///
  /// In pt, this message translates to:
  /// **'Registar rendimento'**
  String get rendAdicionar;

  /// No description provided for @rendValor.
  ///
  /// In pt, this message translates to:
  /// **'Quanto ganhaste (bruto)'**
  String get rendValor;

  /// No description provided for @rendMes.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get rendMes;

  /// No description provided for @rendFoto.
  ///
  /// In pt, this message translates to:
  /// **'Ler extrato por foto (Uber, Bolt, Glovo)'**
  String get rendFoto;

  /// No description provided for @rendGuardar.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get rendGuardar;

  /// No description provided for @rendSemDados.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não registaste nada. Começa pelo mês passado.'**
  String get rendSemDados;

  /// No description provided for @calTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Calendário'**
  String get calTitulo;

  /// No description provided for @calSemObrigacoes.
  ///
  /// In pt, this message translates to:
  /// **'Nada marcado. Quando houver, aparece aqui.'**
  String get calSemObrigacoes;

  /// No description provided for @calValorEstimado.
  ///
  /// In pt, this message translates to:
  /// **'Valor estimado'**
  String get calValorEstimado;

  /// No description provided for @calAte.
  ///
  /// In pt, this message translates to:
  /// **'Até {data}'**
  String calAte(String data);

  /// No description provided for @carroTitulo.
  ///
  /// In pt, this message translates to:
  /// **'O carro'**
  String get carroTitulo;

  /// No description provided for @carroAdicionar.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar carro'**
  String get carroAdicionar;

  /// No description provided for @carroIuc.
  ///
  /// In pt, this message translates to:
  /// **'IUC (imposto do carro)'**
  String get carroIuc;

  /// No description provided for @carroIpo.
  ///
  /// In pt, this message translates to:
  /// **'Inspeção'**
  String get carroIpo;

  /// No description provided for @carroSeguro.
  ///
  /// In pt, this message translates to:
  /// **'Seguro'**
  String get carroSeguro;

  /// No description provided for @carroCarta.
  ///
  /// In pt, this message translates to:
  /// **'Carta de condução'**
  String get carroCarta;

  /// No description provided for @carroRevisao.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get carroRevisao;

  /// No description provided for @carroAbastecimentos.
  ///
  /// In pt, this message translates to:
  /// **'Abastecimentos'**
  String get carroAbastecimentos;

  /// No description provided for @carroCustoKm.
  ///
  /// In pt, this message translates to:
  /// **'Custo por km'**
  String get carroCustoKm;

  /// No description provided for @carroDespesas.
  ///
  /// In pt, this message translates to:
  /// **'Despesas com NIF'**
  String get carroDespesas;

  /// No description provided for @carroMultas.
  ///
  /// In pt, this message translates to:
  /// **'Portagens e multas'**
  String get carroMultas;

  /// No description provided for @carroSemCarro.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tens carro registado.'**
  String get carroSemCarro;

  /// No description provided for @carroSeguroAviso.
  ///
  /// In pt, this message translates to:
  /// **'O seguro renova em {dias} dias. É agora que comparas.'**
  String carroSeguroAviso(int dias);

  /// No description provided for @reformaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Reforma e direitos'**
  String get reformaTitulo;

  /// No description provided for @reformaDescontas.
  ///
  /// In pt, this message translates to:
  /// **'Descontas {mensal}/mês — vale cerca de {reforma} de reforma'**
  String reformaDescontas(String mensal, String reforma);

  /// No description provided for @reformaIdade.
  ///
  /// In pt, this message translates to:
  /// **'Idade da reforma em 2026: 66 anos e 9 meses. Mínimo: 15 anos de descontos.'**
  String get reformaIdade;

  /// No description provided for @reformaDireitos.
  ///
  /// In pt, this message translates to:
  /// **'O que ganhas por pagar'**
  String get reformaDireitos;

  /// No description provided for @reformaPerdes.
  ///
  /// In pt, this message translates to:
  /// **'O que perdes se não pagares'**
  String get reformaPerdes;

  /// No description provided for @reformaAcordoBrasil.
  ///
  /// In pt, this message translates to:
  /// **'Acordo Portugal–Brasil: o tempo dos dois países conta.'**
  String get reformaAcordoBrasil;

  /// No description provided for @guiasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Guias de 1 minuto'**
  String get guiasTitulo;

  /// No description provided for @guiasOuvir.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir'**
  String get guiasOuvir;

  /// No description provided for @guiasParar.
  ///
  /// In pt, this message translates to:
  /// **'Parar'**
  String get guiasParar;

  /// No description provided for @guiasFonte.
  ///
  /// In pt, this message translates to:
  /// **'Fonte oficial: {fonte} · verificado em {data}'**
  String guiasFonte(String fonte, String data);

  /// No description provided for @iaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta o que quiseres'**
  String get iaTitulo;

  /// No description provided for @iaEscreve.
  ///
  /// In pt, this message translates to:
  /// **'Escreve a tua pergunta…'**
  String get iaEscreve;

  /// No description provided for @iaRodape.
  ///
  /// In pt, this message translates to:
  /// **'Informação geral, não substitui contabilista.'**
  String get iaRodape;

  /// No description provided for @iaLimiteFree.
  ///
  /// In pt, this message translates to:
  /// **'No plano grátis tens {n} perguntas por mês. Usaste {usadas}.'**
  String iaLimiteFree(int n, int usadas);

  /// No description provided for @iaSemRegra.
  ///
  /// In pt, this message translates to:
  /// **'Não tenho essa regra confirmada. Vou pedir um guia novo sobre isto.'**
  String get iaSemRegra;

  /// No description provided for @suporteTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get suporteTitulo;

  /// No description provided for @suporteDuvida.
  ///
  /// In pt, this message translates to:
  /// **'Tenho uma dúvida'**
  String get suporteDuvida;

  /// No description provided for @suporteBug.
  ///
  /// In pt, this message translates to:
  /// **'Algo não funciona'**
  String get suporteBug;

  /// No description provided for @suporteReembolso.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso ou cancelar'**
  String get suporteReembolso;

  /// No description provided for @suporteDescreve.
  ///
  /// In pt, this message translates to:
  /// **'Conta-me o que aconteceu'**
  String get suporteDescreve;

  /// No description provided for @suporteEnviar.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get suporteEnviar;

  /// No description provided for @suporteEnviado.
  ///
  /// In pt, this message translates to:
  /// **'Recebi. Respondo em breve.'**
  String get suporteEnviado;

  /// No description provided for @planoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'O teu plano'**
  String get planoTitulo;

  /// No description provided for @planoTrial.
  ///
  /// In pt, this message translates to:
  /// **'Mês grátis — tudo aberto até {data}'**
  String planoTrial(String data);

  /// No description provided for @planoFree.
  ///
  /// In pt, this message translates to:
  /// **'Plano grátis'**
  String get planoFree;

  /// No description provided for @planoPro.
  ///
  /// In pt, this message translates to:
  /// **'Pro'**
  String get planoPro;

  /// No description provided for @planoFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Família / Frota'**
  String get planoFamilia;

  /// No description provided for @planoProPreco.
  ///
  /// In pt, this message translates to:
  /// **'3,49 €/mês ou 29,90 €/ano'**
  String get planoProPreco;

  /// No description provided for @planoFamiliaPreco.
  ///
  /// In pt, this message translates to:
  /// **'5,99 €/mês ou 49,90 €/ano — até 5 pessoas ou carros'**
  String get planoFamiliaPreco;

  /// No description provided for @planoAtivar.
  ///
  /// In pt, this message translates to:
  /// **'Ativar'**
  String get planoAtivar;

  /// No description provided for @planoCadeado.
  ///
  /// In pt, this message translates to:
  /// **'Isto é do plano Pro'**
  String get planoCadeado;

  /// No description provided for @planoCadeadoLinha.
  ///
  /// In pt, this message translates to:
  /// **'Ativa o Pro para ter avisos sem limite, IA sem limite e mais carros.'**
  String get planoCadeadoLinha;

  /// No description provided for @planoWeb.
  ///
  /// In pt, this message translates to:
  /// **'Para assinar, usa a app no telemóvel Android por agora.'**
  String get planoWeb;

  /// No description provided for @planoGerir.
  ///
  /// In pt, this message translates to:
  /// **'Gerir na Google Play'**
  String get planoGerir;

  /// No description provided for @adminTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Painel Em Dia'**
  String get adminTitulo;

  /// No description provided for @erroRede.
  ///
  /// In pt, this message translates to:
  /// **'Sem ligação. Tenta outra vez daqui a bocado.'**
  String get erroRede;

  /// No description provided for @aCarregar.
  ///
  /// In pt, this message translates to:
  /// **'A carregar…'**
  String get aCarregar;

  /// No description provided for @guardar.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @cancelar.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @apagar.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get apagar;

  /// No description provided for @ok.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @sim.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get sim;

  /// No description provided for @nao.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get nao;

  /// No description provided for @hoje.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get hoje;

  /// No description provided for @amanha.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get amanha;

  /// No description provided for @euros.
  ///
  /// In pt, this message translates to:
  /// **'€'**
  String get euros;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
