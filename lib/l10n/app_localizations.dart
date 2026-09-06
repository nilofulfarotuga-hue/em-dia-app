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
  /// **'Motorista TVDE (Uber, Bolt)'**
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

  /// No description provided for @onbPergunta.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta {n} de {total}'**
  String onbPergunta(int n, int total);

  /// No description provided for @onbMes.
  ///
  /// In pt, this message translates to:
  /// **'Mês'**
  String get onbMes;

  /// No description provided for @onbAno.
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get onbAno;

  /// No description provided for @onbOpcional.
  ///
  /// In pt, this message translates to:
  /// **'opcional'**
  String get onbOpcional;

  /// No description provided for @onbIsentoAte.
  ///
  /// In pt, this message translates to:
  /// **'Estás isento de Segurança Social até {data}'**
  String onbIsentoAte(String data);

  /// No description provided for @onbDepoisPagas.
  ///
  /// In pt, this message translates to:
  /// **'Depois pagas a partir de {mes}'**
  String onbDepoisPagas(String mes);

  /// No description provided for @onbIsencaoJaAcabou.
  ///
  /// In pt, this message translates to:
  /// **'A tua isenção do 1.º ano acabou em {data}. Já pagas Segurança Social todos os meses — eu digo-te quanto e quando.'**
  String onbIsencaoJaAcabou(String data);

  /// No description provided for @onbIvaNormalExplica.
  ///
  /// In pt, this message translates to:
  /// **'Cobras IVA de {taxa} nas faturas e entregas esse dinheiro às Finanças de 3 em 3 meses. Eu aviso-te das datas.'**
  String onbIvaNormalExplica(String taxa);

  /// No description provided for @onbIvaIsentoExplica.
  ///
  /// In pt, this message translates to:
  /// **'Não cobras IVA (ficas isento). Só tens de pôr a frase de isenção no recibo — eu dou-ta pronta a copiar.'**
  String get onbIvaIsentoExplica;

  /// No description provided for @onbIucEm.
  ///
  /// In pt, this message translates to:
  /// **'IUC (o imposto do carro) é em {mes}'**
  String onbIucEm(String mes);

  /// No description provided for @onbProximaIpo.
  ///
  /// In pt, this message translates to:
  /// **'Próxima inspeção: {data}'**
  String onbProximaIpo(String data);

  /// No description provided for @onbSimulacaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'A tua primeira simulação'**
  String get onbSimulacaoTitulo;

  /// No description provided for @onbSimulacaoAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Valores aproximados. Afinas depois em Recibos.'**
  String get onbSimulacaoAjuda;

  /// No description provided for @onbSsPorMes.
  ///
  /// In pt, this message translates to:
  /// **'Segurança Social ≈ {valor} por mês'**
  String onbSsPorMes(String valor);

  /// No description provided for @onbSsIsentoAte.
  ///
  /// In pt, this message translates to:
  /// **'Segurança Social: isento até {data}'**
  String onbSsIsentoAte(String data);

  /// No description provided for @onbIrsPorMes.
  ///
  /// In pt, this message translates to:
  /// **'IRS a guardar ≈ {valor} por mês'**
  String onbIrsPorMes(String valor);

  /// No description provided for @onbIrsZero.
  ///
  /// In pt, this message translates to:
  /// **'IRS: com este valor não pagas nada (ficas abaixo do mínimo que a lei não taxa)'**
  String get onbIrsZero;

  /// No description provided for @onbEsteMes.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get onbEsteMes;

  /// No description provided for @onbSemValor.
  ///
  /// In pt, this message translates to:
  /// **'sem pagamento'**
  String get onbSemValor;

  /// No description provided for @onbItemLista.
  ///
  /// In pt, this message translates to:
  /// **'{nome} ({valor}, dia {dia})'**
  String onbItemLista(String nome, String valor, String dia);

  /// No description provided for @onbItemListaSemValor.
  ///
  /// In pt, this message translates to:
  /// **'{nome} (dia {dia})'**
  String onbItemListaSemValor(String nome, String dia);

  /// No description provided for @onbDiaLimite.
  ///
  /// In pt, this message translates to:
  /// **'até dia {dia}'**
  String onbDiaLimite(String dia);

  /// No description provided for @onbCalendarioErro.
  ///
  /// In pt, this message translates to:
  /// **'Guardei o teu perfil, mas o calendário ainda não ficou pronto. Abre o Painel daqui a bocado e ele aparece.'**
  String get onbCalendarioErro;

  /// No description provided for @painelOla.
  ///
  /// In pt, this message translates to:
  /// **'Olá, {nome}'**
  String painelOla(String nome);

  /// No description provided for @painelOlaSemNome.
  ///
  /// In pt, this message translates to:
  /// **'Olá!'**
  String get painelOlaSemNome;

  /// No description provided for @painelPergunta.
  ///
  /// In pt, this message translates to:
  /// **'Estás em dia?'**
  String get painelPergunta;

  /// No description provided for @painelEtiquetaTrial.
  ///
  /// In pt, this message translates to:
  /// **'Mês grátis até {data}'**
  String painelEtiquetaTrial(String data);

  /// No description provided for @painelEtiquetaFree.
  ///
  /// In pt, this message translates to:
  /// **'Plano grátis'**
  String get painelEtiquetaFree;

  /// No description provided for @painelEtiquetaPro.
  ///
  /// In pt, this message translates to:
  /// **'Pro'**
  String get painelEtiquetaPro;

  /// No description provided for @painelEtiquetaFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Família'**
  String get painelEtiquetaFamilia;

  /// No description provided for @painelSemaforoVerdeSub.
  ///
  /// In pt, this message translates to:
  /// **'Nada a vencer nos próximos 5 dias.'**
  String get painelSemaforoVerdeSub;

  /// No description provided for @painelSemaforoAmareloHojeUma.
  ///
  /// In pt, this message translates to:
  /// **'Tens 1 coisa a vencer hoje'**
  String get painelSemaforoAmareloHojeUma;

  /// No description provided for @painelSemaforoAmareloHojeVarias.
  ///
  /// In pt, this message translates to:
  /// **'Tens {n} coisas a vencer hoje'**
  String painelSemaforoAmareloHojeVarias(int n);

  /// No description provided for @painelSemaforoAmareloAmanhaUma.
  ///
  /// In pt, this message translates to:
  /// **'Tens 1 coisa a vencer amanhã'**
  String get painelSemaforoAmareloAmanhaUma;

  /// No description provided for @painelSemaforoAmareloAmanhaVarias.
  ///
  /// In pt, this message translates to:
  /// **'Tens {n} coisas a vencer amanhã'**
  String painelSemaforoAmareloAmanhaVarias(int n);

  /// No description provided for @painelHeroiEmDias.
  ///
  /// In pt, this message translates to:
  /// **'{dias, plural, =1{Em 1 dia} other{Em {dias} dias}}'**
  String painelHeroiEmDias(int dias);

  /// No description provided for @painelHeroiPassouHa.
  ///
  /// In pt, this message translates to:
  /// **'{dias, plural, =1{Passou há 1 dia} other{Passou há {dias} dias}}'**
  String painelHeroiPassouHa(int dias);

  /// No description provided for @painelHeroiSemPrazo.
  ///
  /// In pt, this message translates to:
  /// **'Sem prazos à vista'**
  String get painelHeroiSemPrazo;

  /// No description provided for @painelHeroiSemPrazoAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Quando houver, aparece aqui. Eu aviso-te antes.'**
  String get painelHeroiSemPrazoAjuda;

  /// No description provided for @painelNomeIuc.
  ///
  /// In pt, this message translates to:
  /// **'IUC (o imposto do carro)'**
  String get painelNomeIuc;

  /// No description provided for @painelNomeIva.
  ///
  /// In pt, this message translates to:
  /// **'IVA (o imposto da fatura)'**
  String get painelNomeIva;

  /// No description provided for @painelNomeIrsConta.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento por conta (adiantamento do IRS)'**
  String get painelNomeIrsConta;

  /// No description provided for @painelAteDia.
  ///
  /// In pt, this message translates to:
  /// **'até dia {dia}'**
  String painelAteDia(int dia);

  /// No description provided for @painelPago.
  ///
  /// In pt, this message translates to:
  /// **'Pago'**
  String get painelPago;

  /// No description provided for @painelIrsPorMes.
  ///
  /// In pt, this message translates to:
  /// **'por mês'**
  String get painelIrsPorMes;

  /// No description provided for @painelIrsLinha.
  ///
  /// In pt, this message translates to:
  /// **'Não é tudo teu: guarda isto todos os meses e o IRS não te apanha de surpresa.'**
  String get painelIrsLinha;

  /// No description provided for @painelIrsZero.
  ///
  /// In pt, this message translates to:
  /// **'Com o que ganhas não pagas IRS (ficas abaixo do mínimo de existência, {valor} por ano).'**
  String painelIrsZero(String valor);

  /// No description provided for @painelIrsSemRendimento.
  ///
  /// In pt, this message translates to:
  /// **'Diz-me quanto ganhas por mês (na aba Recibos) e eu digo-te quanto guardar.'**
  String get painelIrsSemRendimento;

  /// No description provided for @painelIrsAproximado.
  ///
  /// In pt, this message translates to:
  /// **'valor aproximado'**
  String get painelIrsAproximado;

  /// No description provided for @painelVigiaFaltam.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {valor} para o limite. Continua a registar.'**
  String painelVigiaFaltam(String valor);

  /// No description provided for @painelPagoOk.
  ///
  /// In pt, this message translates to:
  /// **'Marcado como pago. Boa.'**
  String get painelPagoOk;

  /// No description provided for @painelPagoErro.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui marcar como pago. Vê a ligação e tenta outra vez.'**
  String get painelPagoErro;

  /// No description provided for @painelComprovativoPergunta.
  ///
  /// In pt, this message translates to:
  /// **'Queres juntar a foto do comprovativo?'**
  String get painelComprovativoPergunta;

  /// No description provided for @painelComprovativoAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Fica guardada aqui, para quando as Finanças ou a Segurança Social perguntarem.'**
  String get painelComprovativoAjuda;

  /// No description provided for @painelAgoraNao.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get painelAgoraNao;

  /// No description provided for @painelComprovativoOk.
  ///
  /// In pt, this message translates to:
  /// **'Comprovativo guardado.'**
  String get painelComprovativoOk;

  /// No description provided for @painelComprovativoErro.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui guardar a foto. Tenta outra vez.'**
  String get painelComprovativoErro;

  /// No description provided for @painelCadeadoComprovativo.
  ///
  /// In pt, this message translates to:
  /// **'Ativa o Pro para guardar as fotos dos comprovativos.'**
  String get painelCadeadoComprovativo;

  /// No description provided for @painelComoPagarAte.
  ///
  /// In pt, this message translates to:
  /// **'Até {data}'**
  String painelComoPagarAte(String data);

  /// No description provided for @painelComoPagarSs.
  ///
  /// In pt, this message translates to:
  /// **'Entra na Segurança Social Direta (app ou site), vai a Conta-corrente e depois a Pagamentos, e paga por Multibanco ou MB WAY. Prazo: entre o dia 10 e o dia 20.'**
  String get painelComoPagarSs;

  /// No description provided for @painelComoPagarIva.
  ///
  /// In pt, this message translates to:
  /// **'Entra no Portal das Finanças, vai a IVA e depois a Pagamentos, e paga com a referência Multibanco que lá aparece. Prazo: até ao dia 25.'**
  String get painelComoPagarIva;

  /// No description provided for @painelComoPagarIrs.
  ///
  /// In pt, this message translates to:
  /// **'Entra no Portal das Finanças, vai a IRS e depois a Pagamentos por conta, e paga com a referência Multibanco. Prazo: até ao dia 20.'**
  String get painelComoPagarIrs;

  /// No description provided for @painelComoPagarIuc.
  ///
  /// In pt, this message translates to:
  /// **'Entra no Portal das Finanças, vai a IUC (o imposto do carro) e a Emitir documento de pagamento, e paga por Multibanco. Prazo: até ao fim do mês da matrícula.'**
  String get painelComoPagarIuc;

  /// No description provided for @painelComoPagarIpo.
  ///
  /// In pt, this message translates to:
  /// **'Marca a inspeção num centro perto de ti (por telefone ou no site do centro) e leva o documento único do carro. Vai antes do dia limite.'**
  String get painelComoPagarIpo;

  /// No description provided for @painelComoPagarSeguro.
  ///
  /// In pt, this message translates to:
  /// **'Compara preços antes de renovar. Paga à seguradora por referência Multibanco ou débito direto até à data de renovação.'**
  String get painelComoPagarSeguro;

  /// No description provided for @painelComoPagarGenerico.
  ///
  /// In pt, this message translates to:
  /// **'Confirma a data no Portal das Finanças ou na Segurança Social Direta e trata disto antes do dia limite. Se tiveres dúvidas, pergunta-me.'**
  String get painelComoPagarGenerico;

  /// No description provided for @painelTentarOutraVez.
  ///
  /// In pt, this message translates to:
  /// **'Tentar outra vez'**
  String get painelTentarOutraVez;

  /// No description provided for @recibosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Recibos verdes'**
  String get recibosTitulo;

  /// No description provided for @recibosSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Faz as contas, regista o que ganhas e vê o que é mesmo teu.'**
  String get recibosSubtitulo;

  /// No description provided for @calcAjudaValor.
  ///
  /// In pt, this message translates to:
  /// **'Escreve o valor sem IVA. Ex.: 1000'**
  String get calcAjudaValor;

  /// No description provided for @calcSemValor.
  ///
  /// In pt, this message translates to:
  /// **'Escreve um valor e eu faço as contas.'**
  String get calcSemValor;

  /// No description provided for @calcRecebesNaConta.
  ///
  /// In pt, this message translates to:
  /// **'O que recebes na conta'**
  String get calcRecebesNaConta;

  /// No description provided for @calcFicaTeu.
  ///
  /// In pt, this message translates to:
  /// **'O que é mesmo teu'**
  String get calcFicaTeu;

  /// No description provided for @calcNaoETudoTeu.
  ///
  /// In pt, this message translates to:
  /// **'O IVA e a retenção não são teus — vão para o Estado. Guarda só o que é mesmo teu.'**
  String get calcNaoETudoTeu;

  /// No description provided for @calcDispensaAjuda.
  ///
  /// In pt, this message translates to:
  /// **'A dispensa só vale se o cliente tiver contabilidade organizada — pergunta-lhe antes.'**
  String get calcDispensaAjuda;

  /// No description provided for @calcRetencaoDispensaCurta.
  ///
  /// In pt, this message translates to:
  /// **'Dispensa (0%)'**
  String get calcRetencaoDispensaCurta;

  /// No description provided for @calcIvaIsentoCurto.
  ///
  /// In pt, this message translates to:
  /// **'Isento (art. 53.º — não cobras IVA)'**
  String get calcIvaIsentoCurto;

  /// No description provided for @calcIvaNormalCurto.
  ///
  /// In pt, this message translates to:
  /// **'Cobras 23%'**
  String get calcIvaNormalCurto;

  /// No description provided for @calcBrutoExplicado.
  ///
  /// In pt, this message translates to:
  /// **'Bruto (o valor escrito no recibo)'**
  String get calcBrutoExplicado;

  /// No description provided for @ssIsencaoExplica.
  ///
  /// In pt, this message translates to:
  /// **'Isenção = no 1.º ano de atividade não pagas nada à Segurança Social.'**
  String get ssIsencaoExplica;

  /// No description provided for @rendUltimos.
  ///
  /// In pt, this message translates to:
  /// **'Os teus últimos meses'**
  String get rendUltimos;

  /// No description provided for @rendTotalAno.
  ///
  /// In pt, this message translates to:
  /// **'Este ano já registaste {valor}'**
  String rendTotalAno(String valor);

  /// No description provided for @rendTipo.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de rendimento'**
  String get rendTipo;

  /// No description provided for @rendTipoServicos.
  ///
  /// In pt, this message translates to:
  /// **'Serviços (TVDE, entregas, cabelo, obras…)'**
  String get rendTipoServicos;

  /// No description provided for @rendTipoVendas.
  ///
  /// In pt, this message translates to:
  /// **'Venda de coisas'**
  String get rendTipoVendas;

  /// No description provided for @rendPlataforma.
  ///
  /// In pt, this message translates to:
  /// **'De onde veio'**
  String get rendPlataforma;

  /// No description provided for @rendClienteDireto.
  ///
  /// In pt, this message translates to:
  /// **'Clientes diretos'**
  String get rendClienteDireto;

  /// No description provided for @rendPlataformaOutra.
  ///
  /// In pt, this message translates to:
  /// **'Outra'**
  String get rendPlataformaOutra;

  /// No description provided for @rendGuardado.
  ///
  /// In pt, this message translates to:
  /// **'Guardado. Já contei com isto na Vigia do IVA, na Segurança Social e no IRS.'**
  String get rendGuardado;

  /// No description provided for @rendValorInvalido.
  ///
  /// In pt, this message translates to:
  /// **'Escreve um valor maior que zero.'**
  String get rendValorInvalido;

  /// No description provided for @rendLidoDaFoto.
  ///
  /// In pt, this message translates to:
  /// **'Lido da foto ({confianca} de certeza). Confirma antes de guardar.'**
  String rendLidoDaFoto(String confianca);

  /// No description provided for @rendFotoALer.
  ///
  /// In pt, this message translates to:
  /// **'A ler o extrato… demora uns segundos.'**
  String get rendFotoALer;

  /// No description provided for @rendFotoCadeado.
  ///
  /// In pt, this message translates to:
  /// **'Ler extratos por foto é do plano Pro. Regista à mão — demora 30 segundos.'**
  String get rendFotoCadeado;

  /// No description provided for @rendFotoIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'A leitura por foto está a descansar. Regista à mão por agora — demora 30 segundos.'**
  String get rendFotoIndisponivel;

  /// No description provided for @rendFotoNaoLi.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui ler o mês ou o valor. Tenta uma foto mais nítida ou regista à mão.'**
  String get rendFotoNaoLi;

  /// No description provided for @rendOrigemFoto.
  ///
  /// In pt, this message translates to:
  /// **'lido da foto'**
  String get rendOrigemFoto;

  /// No description provided for @rendApagarPergunta.
  ///
  /// In pt, this message translates to:
  /// **'Apagar o rendimento de {mes}?'**
  String rendApagarPergunta(String mes);

  /// No description provided for @rendApagado.
  ///
  /// In pt, this message translates to:
  /// **'Apagado.'**
  String get rendApagado;

  /// No description provided for @vigiaIvaFalta.
  ///
  /// In pt, this message translates to:
  /// **'Ainda podes faturar {valor} este ano sem cobrar IVA.'**
  String vigiaIvaFalta(String valor);

  /// No description provided for @vigiaIvaSemDados.
  ///
  /// In pt, this message translates to:
  /// **'Regista os teus rendimentos e eu vigio o limite por ti.'**
  String get vigiaIvaSemDados;

  /// No description provided for @ssAvisoAntes.
  ///
  /// In pt, this message translates to:
  /// **'Aviso-te {dias} dias antes do fim, com o valor que vais passar a pagar: cerca de {valor} por mês.'**
  String ssAvisoAntes(int dias, String valor);

  /// No description provided for @ssSemAtividade.
  ///
  /// In pt, this message translates to:
  /// **'Sem atividade aberta não pagas Segurança Social nem IRS. Quando abrires, eu conto tudo.'**
  String get ssSemAtividade;

  /// No description provided for @ssSemDataAbertura.
  ///
  /// In pt, this message translates to:
  /// **'Diz-me quando abriste atividade (no teu perfil) para eu contar a isenção do 1.º ano.'**
  String get ssSemDataAbertura;

  /// No description provided for @ssSemDados.
  ///
  /// In pt, this message translates to:
  /// **'Regista os teus rendimentos para eu calcular o valor certo. Sem dados, conto com o mínimo.'**
  String get ssSemDados;

  /// No description provided for @ssBaseTrimestre.
  ///
  /// In pt, this message translates to:
  /// **'Com base no que ganhaste de {inicio} a {fim}: {valor}.'**
  String ssBaseTrimestre(String inicio, String fim, String valor);

  /// No description provided for @ssBaseEstimativa.
  ///
  /// In pt, this message translates to:
  /// **'Com base na tua estimativa de {valor} por mês. Regista os rendimentos para ser mais certo.'**
  String ssBaseEstimativa(String valor);

  /// No description provided for @ssMinimo.
  ///
  /// In pt, this message translates to:
  /// **'É o mínimo: {valor} por mês, mesmo que ganhes pouco.'**
  String ssMinimo(String valor);

  /// No description provided for @ssAjustarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Quanto queres pagar?'**
  String get ssAjustarTitulo;

  /// No description provided for @ssAjusteNormal.
  ///
  /// In pt, this message translates to:
  /// **'o valor normal'**
  String get ssAjusteNormal;

  /// No description provided for @ssAjusteMenos.
  ///
  /// In pt, this message translates to:
  /// **'{pct}% a menos'**
  String ssAjusteMenos(int pct);

  /// No description provided for @ssAjusteMais.
  ///
  /// In pt, this message translates to:
  /// **'{pct}% a mais'**
  String ssAjusteMais(int pct);

  /// No description provided for @ssAjusteAtual.
  ///
  /// In pt, this message translates to:
  /// **'Ajuste atual: {ajuste}'**
  String ssAjusteAtual(String ajuste);

  /// No description provided for @ssNovoValor.
  ///
  /// In pt, this message translates to:
  /// **'Passas a pagar cerca de {valor} por mês'**
  String ssNovoValor(String valor);

  /// No description provided for @ssAjusteGuardado.
  ///
  /// In pt, this message translates to:
  /// **'Guardado. Vou contar com este ajuste nos avisos.'**
  String get ssAjusteGuardado;

  /// No description provided for @etiquetaEstimativa.
  ///
  /// In pt, this message translates to:
  /// **'estimativa'**
  String get etiquetaEstimativa;

  /// No description provided for @irsBase.
  ///
  /// In pt, this message translates to:
  /// **'Com base numa média de {valor} por mês.'**
  String irsBase(String valor);

  /// No description provided for @irsSemDados.
  ///
  /// In pt, this message translates to:
  /// **'Regista os teus rendimentos (ou diz-me quanto ganhas por mês) e eu digo-te quanto guardar.'**
  String get irsSemDados;

  /// No description provided for @irsPagamentosContaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Adiantamentos do IRS (as Finanças chamam-lhes pagamentos por conta)'**
  String get irsPagamentosContaTitulo;

  /// No description provided for @irsPagamentosContaAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Só se tiveres imposto a pagar. Eu aviso-te 5 dias antes de cada um.'**
  String get irsPagamentosContaAjuda;

  /// No description provided for @irsEscaloesPorConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'escalões {ano} por confirmar'**
  String irsEscaloesPorConfirmar(int ano);

  /// No description provided for @irsEstimativaNota.
  ///
  /// In pt, this message translates to:
  /// **'É uma estimativa para saberes quanto guardar — não é a declaração.'**
  String get irsEstimativaNota;

  /// No description provided for @emitirTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Como emitir o recibo'**
  String get emitirTitulo;

  /// No description provided for @emitirSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Passo a passo no Portal das Finanças, com textos prontos a copiar.'**
  String get emitirSubtitulo;

  /// No description provided for @emitirAbrirGuia.
  ///
  /// In pt, this message translates to:
  /// **'Ver o passo a passo'**
  String get emitirAbrirGuia;

  /// No description provided for @emitirPasso1.
  ///
  /// In pt, this message translates to:
  /// **'Entra no Portal das Finanças com o teu NIF e a tua senha.'**
  String get emitirPasso1;

  /// No description provided for @emitirPasso2.
  ///
  /// In pt, this message translates to:
  /// **'Procura “Faturas e Recibos Verdes” e toca em “Emitir”.'**
  String get emitirPasso2;

  /// No description provided for @emitirPasso3.
  ///
  /// In pt, this message translates to:
  /// **'Escolhe “Recibo” (ou “Fatura-Recibo” se o cliente pedir fatura).'**
  String get emitirPasso3;

  /// No description provided for @emitirPasso4.
  ///
  /// In pt, this message translates to:
  /// **'Preenche o NIF do cliente. Se for uma plataforma (Uber, Bolt, Glovo), o NIF está no extrato ou no contrato.'**
  String get emitirPasso4;

  /// No description provided for @emitirPasso5.
  ///
  /// In pt, this message translates to:
  /// **'Na descrição escreve o que fizeste. Podes copiar este texto:'**
  String get emitirPasso5;

  /// No description provided for @emitirPasso6.
  ///
  /// In pt, this message translates to:
  /// **'Põe o valor sem IVA e escolhe a retenção que usaste na calculadora (23%, 25% ou dispensa).'**
  String get emitirPasso6;

  /// No description provided for @emitirPasso7Isento.
  ///
  /// In pt, this message translates to:
  /// **'No IVA escolhe o regime de isenção do artigo 53.º e copia esta frase para o motivo:'**
  String get emitirPasso7Isento;

  /// No description provided for @emitirPasso7Normal.
  ///
  /// In pt, this message translates to:
  /// **'No IVA escolhe a taxa normal (23%).'**
  String get emitirPasso7Normal;

  /// No description provided for @emitirPasso8.
  ///
  /// In pt, this message translates to:
  /// **'Confirma e emite. Guarda o PDF — no fim do mês regista aqui o que ganhaste.'**
  String get emitirPasso8;

  /// No description provided for @emitirCapturaBreve.
  ///
  /// In pt, this message translates to:
  /// **'captura em breve'**
  String get emitirCapturaBreve;

  /// No description provided for @emitirAbrirPortal.
  ///
  /// In pt, this message translates to:
  /// **'Abrir o Portal das Finanças'**
  String get emitirAbrirPortal;

  /// No description provided for @emitirNaoAbriu.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui abrir o site. Escreve portaldasfinancas.gov.pt no navegador.'**
  String get emitirNaoAbriu;

  /// No description provided for @emitirDescricaoTvde.
  ///
  /// In pt, this message translates to:
  /// **'Prestação de serviços de transporte de passageiros em veículo descaracterizado (TVDE)'**
  String get emitirDescricaoTvde;

  /// No description provided for @emitirDescricaoEstafeta.
  ///
  /// In pt, this message translates to:
  /// **'Prestação de serviços de entrega de refeições e encomendas'**
  String get emitirDescricaoEstafeta;

  /// No description provided for @emitirDescricaoServicos.
  ///
  /// In pt, this message translates to:
  /// **'Prestação de serviços'**
  String get emitirDescricaoServicos;

  /// No description provided for @calResumo.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =0{Este mês não tens nada a pagar.} =1{Este mês pagas 1 coisa: {valor}} other{Este mês pagas {n} coisas: {valor}}}'**
  String calResumo(int n, String valor);

  /// No description provided for @calDiasSemana.
  ///
  /// In pt, this message translates to:
  /// **'seg,ter,qua,qui,sex,sáb,dom'**
  String get calDiasSemana;

  /// No description provided for @calDiaSelecionado.
  ///
  /// In pt, this message translates to:
  /// **'Só o dia {data}'**
  String calDiaSelecionado(String data);

  /// No description provided for @calLimparFiltro.
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get calLimparFiltro;

  /// No description provided for @calFiltroTudo.
  ///
  /// In pt, this message translates to:
  /// **'Tudo'**
  String get calFiltroTudo;

  /// No description provided for @calFiltroSS.
  ///
  /// In pt, this message translates to:
  /// **'Segurança Social'**
  String get calFiltroSS;

  /// No description provided for @calFiltroFiscal.
  ///
  /// In pt, this message translates to:
  /// **'IVA/IRS'**
  String get calFiltroFiscal;

  /// No description provided for @calFiltroCarro.
  ///
  /// In pt, this message translates to:
  /// **'Carro'**
  String get calFiltroCarro;

  /// No description provided for @calFiltroOutros.
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get calFiltroOutros;

  /// No description provided for @calPassou.
  ///
  /// In pt, this message translates to:
  /// **'Passou'**
  String get calPassou;

  /// No description provided for @calEstaSemana.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get calEstaSemana;

  /// No description provided for @calEsteMes.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get calEsteMes;

  /// No description provided for @calMaisTarde.
  ///
  /// In pt, this message translates to:
  /// **'Mais tarde'**
  String get calMaisTarde;

  /// No description provided for @calJaPagaste.
  ///
  /// In pt, this message translates to:
  /// **'Já pagaste'**
  String get calJaPagaste;

  /// No description provided for @calFaltamDias.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{falta 1 dia} other{faltam {n} dias}}'**
  String calFaltamDias(int n);

  /// No description provided for @calEhHoje.
  ///
  /// In pt, this message translates to:
  /// **'é hoje'**
  String get calEhHoje;

  /// No description provided for @calPassouHa.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{passou há 1 dia} other{passou há {n} dias}}'**
  String calPassouHa(int n);

  /// No description provided for @calPago.
  ///
  /// In pt, this message translates to:
  /// **'Pago'**
  String get calPago;

  /// No description provided for @calSemValor.
  ///
  /// In pt, this message translates to:
  /// **'sem valor'**
  String get calSemValor;

  /// No description provided for @calSemNesteFiltro.
  ///
  /// In pt, this message translates to:
  /// **'Nada marcado aqui.'**
  String get calSemNesteFiltro;

  /// No description provided for @calRecalcular.
  ///
  /// In pt, this message translates to:
  /// **'Refazer o calendário'**
  String get calRecalcular;

  /// No description provided for @calRecalculado.
  ///
  /// In pt, this message translates to:
  /// **'Calendário refeito.'**
  String get calRecalculado;

  /// No description provided for @calErro.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui carregar o calendário. Puxa para baixo para tentar outra vez.'**
  String get calErro;

  /// No description provided for @calSemSessao.
  ///
  /// In pt, this message translates to:
  /// **'Entra na app para mexer no calendário.'**
  String get calSemSessao;

  /// No description provided for @calDataLimite.
  ///
  /// In pt, this message translates to:
  /// **'Data limite'**
  String get calDataLimite;

  /// No description provided for @calAvisoEm.
  ///
  /// In pt, this message translates to:
  /// **'Aviso-te a {data}'**
  String calAvisoEm(String data);

  /// No description provided for @calAproximado.
  ///
  /// In pt, this message translates to:
  /// **'aproximado'**
  String get calAproximado;

  /// No description provided for @calRegra.
  ///
  /// In pt, this message translates to:
  /// **'Porque aparece'**
  String get calRegra;

  /// No description provided for @calComoPagar.
  ///
  /// In pt, this message translates to:
  /// **'Como pagar'**
  String get calComoPagar;

  /// No description provided for @calAbrirSite.
  ///
  /// In pt, this message translates to:
  /// **'Abrir {site}'**
  String calAbrirSite(String site);

  /// No description provided for @calSiteSS.
  ///
  /// In pt, this message translates to:
  /// **'a Segurança Social Direta'**
  String get calSiteSS;

  /// No description provided for @calSitePF.
  ///
  /// In pt, this message translates to:
  /// **'o Portal das Finanças'**
  String get calSitePF;

  /// No description provided for @calSiteImt.
  ///
  /// In pt, this message translates to:
  /// **'o site do IMT'**
  String get calSiteImt;

  /// No description provided for @calSiteAima.
  ///
  /// In pt, this message translates to:
  /// **'o site da AIMA'**
  String get calSiteAima;

  /// No description provided for @calErroAbrirSite.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui abrir o site. Tenta no navegador.'**
  String get calErroAbrirSite;

  /// No description provided for @calJaPaguei.
  ///
  /// In pt, this message translates to:
  /// **'Já paguei'**
  String get calJaPaguei;

  /// No description provided for @calPagoEm.
  ///
  /// In pt, this message translates to:
  /// **'Pagaste a {data}. Boa!'**
  String calPagoEm(String data);

  /// No description provided for @calDesmarcar.
  ///
  /// In pt, this message translates to:
  /// **'Afinal não paguei'**
  String get calDesmarcar;

  /// No description provided for @calMarcadaPaga.
  ///
  /// In pt, this message translates to:
  /// **'Marcado como pago.'**
  String get calMarcadaPaga;

  /// No description provided for @calDesmarcada.
  ///
  /// In pt, this message translates to:
  /// **'Voltou a ficar por pagar.'**
  String get calDesmarcada;

  /// No description provided for @calErroGuardar.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui guardar. Tenta outra vez.'**
  String get calErroGuardar;

  /// No description provided for @calCadeadoComprovativo.
  ///
  /// In pt, this message translates to:
  /// **'Ativa o Pro para guardar a foto.'**
  String get calCadeadoComprovativo;

  /// No description provided for @calTirarFoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto agora'**
  String get calTirarFoto;

  /// No description provided for @calEscolherGaleria.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get calEscolherGaleria;

  /// No description provided for @calComprovativoGuardado.
  ///
  /// In pt, this message translates to:
  /// **'Comprovativo guardado e marcado como pago.'**
  String get calComprovativoGuardado;

  /// No description provided for @calComoPagarSs.
  ///
  /// In pt, this message translates to:
  /// **'Segurança Social Direta → Conta-corrente → Pagamentos → gera a referência Multibanco e paga na app do banco.'**
  String get calComoPagarSs;

  /// No description provided for @calComoPagarFiscal.
  ///
  /// In pt, this message translates to:
  /// **'Portal das Finanças → Pagamentos → gera a referência Multibanco e paga na app do banco.'**
  String get calComoPagarFiscal;

  /// No description provided for @calComoPagarIuc.
  ///
  /// In pt, this message translates to:
  /// **'Portal das Finanças → IUC → Pagar → escolhe a matrícula → emite a referência Multibanco.'**
  String get calComoPagarIuc;

  /// No description provided for @calComoPagarIpo.
  ///
  /// In pt, this message translates to:
  /// **'Marca no centro de inspeção mais perto de ti. Leva o DUA (documento do carro) e o seguro.'**
  String get calComoPagarIpo;

  /// No description provided for @calComoPagarSeguro.
  ///
  /// In pt, this message translates to:
  /// **'Pede 2 ou 3 simulações, compara e renova a que ficar mais barata.'**
  String get calComoPagarSeguro;

  /// No description provided for @calComoPagarMulta.
  ///
  /// In pt, this message translates to:
  /// **'Usa a referência que vem na carta da notificação. Se pagares cedo, costuma ficar mais barato.'**
  String get calComoPagarMulta;

  /// No description provided for @calComoPagarOutro.
  ///
  /// In pt, this message translates to:
  /// **'Paga onde te disseram e depois marca aqui como pago.'**
  String get calComoPagarOutro;

  /// No description provided for @calRegraSsDeclaracao.
  ///
  /// In pt, this message translates to:
  /// **'Declaração trimestral à Segurança Social'**
  String get calRegraSsDeclaracao;

  /// No description provided for @calRegraSsPagamento.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento mensal à Segurança Social (dia 10 a 20)'**
  String get calRegraSsPagamento;

  /// No description provided for @calRegraSsIsencao.
  ///
  /// In pt, this message translates to:
  /// **'Fim da isenção de Segurança Social'**
  String get calRegraSsIsencao;

  /// No description provided for @calRegraIvaDeclaracao.
  ///
  /// In pt, this message translates to:
  /// **'Declaração trimestral de IVA'**
  String get calRegraIvaDeclaracao;

  /// No description provided for @calRegraIvaPagamento.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento trimestral de IVA'**
  String get calRegraIvaPagamento;

  /// No description provided for @calRegraIrsEntrega.
  ///
  /// In pt, this message translates to:
  /// **'Entrega do IRS (abril a junho)'**
  String get calRegraIrsEntrega;

  /// No description provided for @calRegraEfatura.
  ///
  /// In pt, this message translates to:
  /// **'Validar faturas no e-fatura'**
  String get calRegraEfatura;

  /// No description provided for @calRegraIrsConta.
  ///
  /// In pt, this message translates to:
  /// **'Pagamentos por conta de IRS'**
  String get calRegraIrsConta;

  /// No description provided for @calRegraRecibos.
  ///
  /// In pt, this message translates to:
  /// **'Comunicar faturas às Finanças'**
  String get calRegraRecibos;

  /// No description provided for @calRegraTvde.
  ///
  /// In pt, this message translates to:
  /// **'Certificado de motorista TVDE'**
  String get calRegraTvde;

  /// No description provided for @calRegraResidencia.
  ///
  /// In pt, this message translates to:
  /// **'Autorização de residência'**
  String get calRegraResidencia;

  /// No description provided for @calRegraIuc.
  ///
  /// In pt, this message translates to:
  /// **'IUC: mês da matrícula do carro'**
  String get calRegraIuc;

  /// No description provided for @calRegraIpo.
  ///
  /// In pt, this message translates to:
  /// **'Inspeção periódica do carro'**
  String get calRegraIpo;

  /// No description provided for @calRegraSeguro.
  ///
  /// In pt, this message translates to:
  /// **'Renovação do seguro'**
  String get calRegraSeguro;

  /// No description provided for @calRegraCarta.
  ///
  /// In pt, this message translates to:
  /// **'Validade da carta de condução'**
  String get calRegraCarta;

  /// No description provided for @calRegraManual.
  ///
  /// In pt, this message translates to:
  /// **'Adicionaste tu'**
  String get calRegraManual;

  /// No description provided for @calRegraOutra.
  ///
  /// In pt, this message translates to:
  /// **'Regra {chave}'**
  String calRegraOutra(String chave);

  /// No description provided for @calAdicionar.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get calAdicionar;

  /// No description provided for @calNovaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar uma obrigação'**
  String get calNovaTitulo;

  /// No description provided for @calNovaTipo.
  ///
  /// In pt, this message translates to:
  /// **'O que é?'**
  String get calNovaTipo;

  /// No description provided for @calTipoMulta.
  ///
  /// In pt, this message translates to:
  /// **'Multa'**
  String get calTipoMulta;

  /// No description provided for @calTipoPortagem.
  ///
  /// In pt, this message translates to:
  /// **'Portagem'**
  String get calTipoPortagem;

  /// No description provided for @calTipoOutro.
  ///
  /// In pt, this message translates to:
  /// **'Outra coisa'**
  String get calTipoOutro;

  /// No description provided for @calNovaDescricao.
  ///
  /// In pt, this message translates to:
  /// **'O que tens de pagar'**
  String get calNovaDescricao;

  /// No description provided for @calNovaDescricaoDica.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: multa de estacionamento na Guarda'**
  String get calNovaDescricaoDica;

  /// No description provided for @calNovaData.
  ///
  /// In pt, this message translates to:
  /// **'Até quando?'**
  String get calNovaData;

  /// No description provided for @calNovaEscolherData.
  ///
  /// In pt, this message translates to:
  /// **'Escolher a data'**
  String get calNovaEscolherData;

  /// No description provided for @calNovaValor.
  ///
  /// In pt, this message translates to:
  /// **'Valor (se souberes)'**
  String get calNovaValor;

  /// No description provided for @calNovaFaltaDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Escreve o que é.'**
  String get calNovaFaltaDescricao;

  /// No description provided for @calNovaFaltaData.
  ///
  /// In pt, this message translates to:
  /// **'Escolhe a data.'**
  String get calNovaFaltaData;

  /// No description provided for @calNovaGuardada.
  ///
  /// In pt, this message translates to:
  /// **'Adicionado ao calendário.'**
  String get calNovaGuardada;

  /// No description provided for @carroOTeuCarro.
  ///
  /// In pt, this message translates to:
  /// **'O teu carro'**
  String get carroOTeuCarro;

  /// No description provided for @carroMatriculaKm.
  ///
  /// In pt, this message translates to:
  /// **'{matricula} · {km} km'**
  String carroMatriculaKm(String matricula, String km);

  /// No description provided for @carroAdicionarAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Nome, matrícula, seguro, inspeção — em 1 minuto.'**
  String get carroAdicionarAjuda;

  /// No description provided for @carroCadeadoLinha.
  ///
  /// In pt, this message translates to:
  /// **'No plano grátis só cabe 1 carro. Ativa o Pro para mais.'**
  String get carroCadeadoLinha;

  /// No description provided for @carroSemSessao.
  ///
  /// In pt, this message translates to:
  /// **'Entra na app para guardar.'**
  String get carroSemSessao;

  /// No description provided for @carroGuardado.
  ///
  /// In pt, this message translates to:
  /// **'Guardado.'**
  String get carroGuardado;

  /// No description provided for @carroErroGuardar.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui guardar. Tenta outra vez.'**
  String get carroErroGuardar;

  /// No description provided for @carroGuardadoRecalculado.
  ///
  /// In pt, this message translates to:
  /// **'Carro guardado. Já refiz o teu calendário.'**
  String get carroGuardadoRecalculado;

  /// No description provided for @carroGuardadoSemCalendario.
  ///
  /// In pt, this message translates to:
  /// **'Carro guardado. O calendário refaz-se assim que houver rede.'**
  String get carroGuardadoSemCalendario;

  /// No description provided for @carroLembretes.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes'**
  String get carroLembretes;

  /// No description provided for @carroSemLembretes.
  ///
  /// In pt, this message translates to:
  /// **'Preenche a matrícula e as datas do carro para eu te lembrar do IUC, da inspeção e do seguro.'**
  String get carroSemLembretes;

  /// No description provided for @carroFaltamKm.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{falta 1 km} other{faltam {n} km}}'**
  String carroFaltamKm(int n);

  /// No description provided for @carroSemData.
  ///
  /// In pt, this message translates to:
  /// **'sem data'**
  String get carroSemData;

  /// No description provided for @carroIucOnde.
  ///
  /// In pt, this message translates to:
  /// **'Imposto do carro. Pagas no Portal das Finanças.'**
  String get carroIucOnde;

  /// No description provided for @carroIucSemEstimativa.
  ///
  /// In pt, this message translates to:
  /// **'Sem estimativa: falta a cilindrada do carro.'**
  String get carroIucSemEstimativa;

  /// No description provided for @carroIpoAvisos.
  ///
  /// In pt, this message translates to:
  /// **'Aviso-te {a} e {b} dias antes.'**
  String carroIpoAvisos(int a, int b);

  /// No description provided for @carroIpoTvde.
  ///
  /// In pt, this message translates to:
  /// **'TVDE: inspeção todos os anos (ainda por confirmar).'**
  String get carroIpoTvde;

  /// No description provided for @carroSeguradoraLinha.
  ///
  /// In pt, this message translates to:
  /// **'Seguradora: {nome}'**
  String carroSeguradoraLinha(String nome);

  /// No description provided for @carroSeguroCompara.
  ///
  /// In pt, this message translates to:
  /// **'É agora que comparas: pede 2 ou 3 simulações.'**
  String get carroSeguroCompara;

  /// No description provided for @carroCartaRegra.
  ///
  /// In pt, this message translates to:
  /// **'A carta vale {a} anos até aos 60, {b} até aos 70 e depois {c}.'**
  String carroCartaRegra(int a, int b, int c);

  /// No description provided for @carroRevisaoAosKm.
  ///
  /// In pt, this message translates to:
  /// **'Revisão aos {km} km.'**
  String carroRevisaoAosKm(String km);

  /// No description provided for @carroSoInformacao.
  ///
  /// In pt, this message translates to:
  /// **'Só informação: esta data não está no calendário porque ainda não foi gerada.'**
  String get carroSoInformacao;

  /// No description provided for @carroResumoMes.
  ///
  /// In pt, this message translates to:
  /// **'Resumo de {mes}'**
  String carroResumoMes(String mes);

  /// No description provided for @carroResumoGasto.
  ///
  /// In pt, this message translates to:
  /// **'gasto'**
  String get carroResumoGasto;

  /// No description provided for @carroResumoKm.
  ///
  /// In pt, this message translates to:
  /// **'km'**
  String get carroResumoKm;

  /// No description provided for @carroResumoEuroKm.
  ///
  /// In pt, this message translates to:
  /// **'€/km'**
  String get carroResumoEuroKm;

  /// No description provided for @carroResumoL100.
  ///
  /// In pt, this message translates to:
  /// **'L/100 km'**
  String get carroResumoL100;

  /// No description provided for @carroCompensa.
  ///
  /// In pt, this message translates to:
  /// **'Para o TVDE: é isto que cada km te custa em combustível — assim sabes se a corrida compensa.'**
  String get carroCompensa;

  /// No description provided for @carroSemCustoKm.
  ///
  /// In pt, this message translates to:
  /// **'Regista 2 depósitos cheios com os km e eu calculo o custo por km.'**
  String get carroSemCustoKm;

  /// No description provided for @carroSemAbastecimentos.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não registaste abastecimentos.'**
  String get carroSemAbastecimentos;

  /// No description provided for @carroNovoAbastecimento.
  ///
  /// In pt, this message translates to:
  /// **'Novo abastecimento'**
  String get carroNovoAbastecimento;

  /// No description provided for @carroLitros.
  ///
  /// In pt, this message translates to:
  /// **'Litros'**
  String get carroLitros;

  /// No description provided for @carroValorTotal.
  ///
  /// In pt, this message translates to:
  /// **'Valor total'**
  String get carroValorTotal;

  /// No description provided for @carroKmConta.
  ///
  /// In pt, this message translates to:
  /// **'Km no conta-quilómetros'**
  String get carroKmConta;

  /// No description provided for @carroDepositoCheio.
  ///
  /// In pt, this message translates to:
  /// **'Enchi o depósito'**
  String get carroDepositoCheio;

  /// No description provided for @carroPosto.
  ///
  /// In pt, this message translates to:
  /// **'Posto (opcional)'**
  String get carroPosto;

  /// No description provided for @carroComNif.
  ///
  /// In pt, this message translates to:
  /// **'Pedi fatura com NIF'**
  String get carroComNif;

  /// No description provided for @carroNif.
  ///
  /// In pt, this message translates to:
  /// **'NIF'**
  String get carroNif;

  /// No description provided for @carroLitrosCurto.
  ///
  /// In pt, this message translates to:
  /// **'{litros} L'**
  String carroLitrosCurto(String litros);

  /// No description provided for @carroPrecoLitro.
  ///
  /// In pt, this message translates to:
  /// **'{preco} €/⁠L'**
  String carroPrecoLitro(String preco);

  /// No description provided for @carroKmCurto.
  ///
  /// In pt, this message translates to:
  /// **'{km} km'**
  String carroKmCurto(String km);

  /// No description provided for @carroData.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get carroData;

  /// No description provided for @carroEscolherData.
  ///
  /// In pt, this message translates to:
  /// **'Escolher a data'**
  String get carroEscolherData;

  /// No description provided for @carroFaltaValor.
  ///
  /// In pt, this message translates to:
  /// **'Escreve o valor.'**
  String get carroFaltaValor;

  /// No description provided for @carroFaltaData.
  ///
  /// In pt, this message translates to:
  /// **'Escolhe a data.'**
  String get carroFaltaData;

  /// No description provided for @carroAbastecimentoGuardado.
  ///
  /// In pt, this message translates to:
  /// **'Abastecimento guardado.'**
  String get carroAbastecimentoGuardado;

  /// No description provided for @carroDespesasAnoNif.
  ///
  /// In pt, this message translates to:
  /// **'Com NIF em {ano}'**
  String carroDespesasAnoNif(int ano);

  /// No description provided for @carroDespesasIrs.
  ///
  /// In pt, this message translates to:
  /// **'Guardadas para o IRS: cada fatura com NIF conta como despesa da atividade.'**
  String get carroDespesasIrs;

  /// No description provided for @carroSemDespesas.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não registaste despesas.'**
  String get carroSemDespesas;

  /// No description provided for @carroNovaDespesa.
  ///
  /// In pt, this message translates to:
  /// **'Nova despesa'**
  String get carroNovaDespesa;

  /// No description provided for @carroTipoDespesa.
  ///
  /// In pt, this message translates to:
  /// **'O que foi?'**
  String get carroTipoDespesa;

  /// No description provided for @carroTipoIuc.
  ///
  /// In pt, this message translates to:
  /// **'IUC'**
  String get carroTipoIuc;

  /// No description provided for @carroTipoIpo.
  ///
  /// In pt, this message translates to:
  /// **'Inspeção'**
  String get carroTipoIpo;

  /// No description provided for @carroTipoSeguro.
  ///
  /// In pt, this message translates to:
  /// **'Seguro'**
  String get carroTipoSeguro;

  /// No description provided for @carroTipoRevisao.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get carroTipoRevisao;

  /// No description provided for @carroTipoPneus.
  ///
  /// In pt, this message translates to:
  /// **'Pneus'**
  String get carroTipoPneus;

  /// No description provided for @carroTipoReparacao.
  ///
  /// In pt, this message translates to:
  /// **'Reparação'**
  String get carroTipoReparacao;

  /// No description provided for @carroTipoPortagem.
  ///
  /// In pt, this message translates to:
  /// **'Portagem'**
  String get carroTipoPortagem;

  /// No description provided for @carroTipoMulta.
  ///
  /// In pt, this message translates to:
  /// **'Multa'**
  String get carroTipoMulta;

  /// No description provided for @carroTipoEstacionamento.
  ///
  /// In pt, this message translates to:
  /// **'Estacionamento'**
  String get carroTipoEstacionamento;

  /// No description provided for @carroTipoLavagem.
  ///
  /// In pt, this message translates to:
  /// **'Lavagem'**
  String get carroTipoLavagem;

  /// No description provided for @carroTipoOutro.
  ///
  /// In pt, this message translates to:
  /// **'Outra'**
  String get carroTipoOutro;

  /// No description provided for @carroValor.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get carroValor;

  /// No description provided for @carroNota.
  ///
  /// In pt, this message translates to:
  /// **'Nota (opcional)'**
  String get carroNota;

  /// No description provided for @carroNotaDica.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: A23, Guarda → Covilhã'**
  String get carroNotaDica;

  /// No description provided for @carroDataNotificacao.
  ///
  /// In pt, this message translates to:
  /// **'Quando recebeste a notificação?'**
  String get carroDataNotificacao;

  /// No description provided for @carroPrazoMulta.
  ///
  /// In pt, this message translates to:
  /// **'Pagar até {data} — {n} dias úteis. Depois sobe o valor.'**
  String carroPrazoMulta(String data, int n);

  /// No description provided for @carroMultaNoCalendario.
  ///
  /// In pt, this message translates to:
  /// **'Vai também para o calendário, com aviso na véspera.'**
  String get carroMultaNoCalendario;

  /// No description provided for @carroDespesaGuardada.
  ///
  /// In pt, this message translates to:
  /// **'Despesa guardada.'**
  String get carroDespesaGuardada;

  /// No description provided for @carroMultasNota.
  ///
  /// In pt, this message translates to:
  /// **'Portagens e multas pagam-se em {n} dias úteis a contar da notificação.'**
  String carroMultasNota(int n);

  /// No description provided for @carroSemMultas.
  ///
  /// In pt, this message translates to:
  /// **'Nada por pagar.'**
  String get carroSemMultas;

  /// No description provided for @carroPagarAte.
  ///
  /// In pt, this message translates to:
  /// **'pagar até {data}'**
  String carroPagarAte(String data);

  /// No description provided for @carroEmBreve.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get carroEmBreve;

  /// No description provided for @carroCentrosInspecao.
  ///
  /// In pt, this message translates to:
  /// **'Centros de inspeção perto de ti'**
  String get carroCentrosInspecao;

  /// No description provided for @carroCentrosInspecaoLinha.
  ///
  /// In pt, this message translates to:
  /// **'Mapa com os centros mais próximos, a partir dos dados abertos do Estado.'**
  String get carroCentrosInspecaoLinha;

  /// No description provided for @carroCombustivelBarato.
  ///
  /// In pt, this message translates to:
  /// **'Combustível mais barato num raio de 10 km'**
  String get carroCombustivelBarato;

  /// No description provided for @carroCombustivelBaratoLinha.
  ///
  /// In pt, this message translates to:
  /// **'Preços de hoje, a partir dos dados abertos do Estado (DGEG).'**
  String get carroCombustivelBaratoLinha;

  /// No description provided for @carroNovoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar carro'**
  String get carroNovoTitulo;

  /// No description provided for @carroNome.
  ///
  /// In pt, this message translates to:
  /// **'Nome (ex.: o Clio)'**
  String get carroNome;

  /// No description provided for @carroMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Matrícula'**
  String get carroMatricula;

  /// No description provided for @carroMatriculaDica.
  ///
  /// In pt, this message translates to:
  /// **'AA-11-BB'**
  String get carroMatriculaDica;

  /// No description provided for @carroMesMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Mês da matrícula'**
  String get carroMesMatricula;

  /// No description provided for @carroAnoMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get carroAnoMatricula;

  /// No description provided for @carroMatriculaAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Pelo mês sei quando é o IUC; pelo ano, quando é a inspeção.'**
  String get carroMatriculaAjuda;

  /// No description provided for @carroCombustivel.
  ///
  /// In pt, this message translates to:
  /// **'Combustível'**
  String get carroCombustivel;

  /// No description provided for @carroCombGasolina.
  ///
  /// In pt, this message translates to:
  /// **'Gasolina'**
  String get carroCombGasolina;

  /// No description provided for @carroCombGasoleo.
  ///
  /// In pt, this message translates to:
  /// **'Gasóleo'**
  String get carroCombGasoleo;

  /// No description provided for @carroCombEletrico.
  ///
  /// In pt, this message translates to:
  /// **'Elétrico'**
  String get carroCombEletrico;

  /// No description provided for @carroCombHibrido.
  ///
  /// In pt, this message translates to:
  /// **'Híbrido'**
  String get carroCombHibrido;

  /// No description provided for @carroCombGpl.
  ///
  /// In pt, this message translates to:
  /// **'GPL'**
  String get carroCombGpl;

  /// No description provided for @carroCombOutro.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get carroCombOutro;

  /// No description provided for @carroCilindrada.
  ///
  /// In pt, this message translates to:
  /// **'Cilindrada (cc, opcional)'**
  String get carroCilindrada;

  /// No description provided for @carroCo2.
  ///
  /// In pt, this message translates to:
  /// **'CO2 g/km (opcional)'**
  String get carroCo2;

  /// No description provided for @carroCilindradaAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Está no DUA. Com estes dois estimo o IUC.'**
  String get carroCilindradaAjuda;

  /// No description provided for @carroSeguradora.
  ///
  /// In pt, this message translates to:
  /// **'Seguradora'**
  String get carroSeguradora;

  /// No description provided for @carroSeguroRenova.
  ///
  /// In pt, this message translates to:
  /// **'Quando renova o seguro?'**
  String get carroSeguroRenova;

  /// No description provided for @carroUltimaIpo.
  ///
  /// In pt, this message translates to:
  /// **'Última inspeção (se já fez)'**
  String get carroUltimaIpo;

  /// No description provided for @carroUsoTvde.
  ///
  /// In pt, this message translates to:
  /// **'Uso em TVDE'**
  String get carroUsoTvde;

  /// No description provided for @carroCartaValidade.
  ///
  /// In pt, this message translates to:
  /// **'Validade da carta de condução'**
  String get carroCartaValidade;

  /// No description provided for @carroFaltaMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Escreve a matrícula.'**
  String get carroFaltaMatricula;

  /// No description provided for @carroFaltaMesMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Escolhe o mês da matrícula.'**
  String get carroFaltaMesMatricula;

  /// No description provided for @carroFaltaAnoMatricula.
  ///
  /// In pt, this message translates to:
  /// **'Escreve o ano da matrícula (4 dígitos).'**
  String get carroFaltaAnoMatricula;

  /// No description provided for @maisSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Tudo o resto está aqui.'**
  String get maisSubtitulo;

  /// No description provided for @maisReforma.
  ///
  /// In pt, this message translates to:
  /// **'Reforma e direitos'**
  String get maisReforma;

  /// No description provided for @maisGuias.
  ///
  /// In pt, this message translates to:
  /// **'Guias de 1 minuto'**
  String get maisGuias;

  /// No description provided for @maisPergunta.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta ao Em Dia'**
  String get maisPergunta;

  /// No description provided for @maisAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda'**
  String get maisAjuda;

  /// No description provided for @maisPlano.
  ///
  /// In pt, this message translates to:
  /// **'O teu plano'**
  String get maisPlano;

  /// No description provided for @maisDefinicoes.
  ///
  /// In pt, this message translates to:
  /// **'Definições'**
  String get maisDefinicoes;

  /// No description provided for @defsTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Definições'**
  String get defsTitulo;

  /// No description provided for @defsIdioma.
  ///
  /// In pt, this message translates to:
  /// **'Como falo contigo'**
  String get defsIdioma;

  /// No description provided for @defsIdiomaAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Muda só as palavras da app. As regras e os números são sempre os de Portugal.'**
  String get defsIdiomaAjuda;

  /// No description provided for @defsPt.
  ///
  /// In pt, this message translates to:
  /// **'Português de Portugal'**
  String get defsPt;

  /// No description provided for @defsPtAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Tu, reforma, telemóvel'**
  String get defsPtAjuda;

  /// No description provided for @defsBr.
  ///
  /// In pt, this message translates to:
  /// **'Português do Brasil'**
  String get defsBr;

  /// No description provided for @defsBrAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Você, aposentadoria, celular'**
  String get defsBrAjuda;

  /// No description provided for @defsGuardado.
  ///
  /// In pt, this message translates to:
  /// **'Guardado.'**
  String get defsGuardado;

  /// No description provided for @defsConta.
  ///
  /// In pt, this message translates to:
  /// **'A tua conta'**
  String get defsConta;

  /// No description provided for @defsSairAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Sais da app neste telemóvel. Os teus dados ficam guardados.'**
  String get defsSairAjuda;

  /// No description provided for @defsApagarConta.
  ///
  /// In pt, this message translates to:
  /// **'Apagar a minha conta'**
  String get defsApagarConta;

  /// No description provided for @defsApagarTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Apagar a conta?'**
  String get defsApagarTitulo;

  /// No description provided for @defsApagarTexto.
  ///
  /// In pt, this message translates to:
  /// **'Vou pedir para apagar a tua conta e os teus dados. Demora até 30 dias. Deixas de receber avisos já hoje. Não dá para voltar atrás.'**
  String get defsApagarTexto;

  /// No description provided for @defsApagarConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'Sim, apagar'**
  String get defsApagarConfirmar;

  /// No description provided for @defsApagarPedido.
  ///
  /// In pt, this message translates to:
  /// **'Pedido recebido. A conta vai ser apagada.'**
  String get defsApagarPedido;

  /// No description provided for @defsVersao.
  ///
  /// In pt, this message translates to:
  /// **'Versão {versao}'**
  String defsVersao(String versao);

  /// No description provided for @defsSemPerfil.
  ///
  /// In pt, this message translates to:
  /// **'Entra na app para mudar as definições.'**
  String get defsSemPerfil;

  /// No description provided for @reformaSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'O que descontas hoje vale dinheiro amanhã.'**
  String get reformaSubtitulo;

  /// No description provided for @reformaDescontasHoje.
  ///
  /// In pt, this message translates to:
  /// **'Descontas {valor} por mês'**
  String reformaDescontasHoje(String valor);

  /// No description provided for @reformaValeCerca.
  ///
  /// In pt, this message translates to:
  /// **'vale cerca de'**
  String get reformaValeCerca;

  /// No description provided for @reformaPorMesDeReforma.
  ///
  /// In pt, this message translates to:
  /// **'por mês de reforma'**
  String get reformaPorMesDeReforma;

  /// No description provided for @reformaAnosDescontos.
  ///
  /// In pt, this message translates to:
  /// **'Se descontares durante {anos} anos'**
  String reformaAnosDescontos(int anos);

  /// No description provided for @reformaAnosCurto.
  ///
  /// In pt, this message translates to:
  /// **'{anos} anos'**
  String reformaAnosCurto(int anos);

  /// No description provided for @reformaEstimativaSimples.
  ///
  /// In pt, this message translates to:
  /// **'estimativa simples'**
  String get reformaEstimativaSimples;

  /// No description provided for @reformaEstimativaNota.
  ///
  /// In pt, this message translates to:
  /// **'É uma conta simples, só para teres uma ideia. A Segurança Social faz a conta certa com toda a tua carreira.'**
  String get reformaEstimativaNota;

  /// No description provided for @reformaSemDados.
  ///
  /// In pt, this message translates to:
  /// **'Diz-me quanto ganhas por mês (no teu perfil) e eu faço a conta. Por agora conto com o mínimo.'**
  String get reformaSemDados;

  /// No description provided for @reformaIdadeTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Quando te podes reformar'**
  String get reformaIdadeTitulo;

  /// No description provided for @reformaIdadeRegra.
  ///
  /// In pt, this message translates to:
  /// **'Em {ano}: aos {idade}. Precisas de {anos} anos de descontos, no mínimo.'**
  String reformaIdadeRegra(int ano, String idade, int anos);

  /// No description provided for @reformaAnosEMeses.
  ///
  /// In pt, this message translates to:
  /// **'{anos} anos e {meses} meses'**
  String reformaAnosEMeses(int anos, int meses);

  /// No description provided for @reformaBaixaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Baixa por doença'**
  String get reformaBaixaTitulo;

  /// No description provided for @reformaBaixaTexto.
  ///
  /// In pt, this message translates to:
  /// **'Se adoeceres, recebes a partir do {dia}.º dia de baixa. Precisas de {meses} meses de descontos.'**
  String reformaBaixaTexto(int dia, int meses);

  /// No description provided for @reformaParentalidadeTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Parentalidade'**
  String get reformaParentalidadeTitulo;

  /// No description provided for @reformaParentalidadeTexto.
  ///
  /// In pt, this message translates to:
  /// **'Se tiveres um filho, recebes subsídio nos dias em que paras para cuidar dele. Vale para o pai e para a mãe.'**
  String get reformaParentalidadeTexto;

  /// No description provided for @reformaCessacaoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Cessação de atividade'**
  String get reformaCessacaoTitulo;

  /// No description provided for @reformaCessacaoTexto.
  ///
  /// In pt, this message translates to:
  /// **'É o \"desemprego\" dos independentes: se fechares por falta de trabalho, recebes um apoio. Precisas de {dias} dias de descontos.'**
  String reformaCessacaoTexto(int dias);

  /// No description provided for @reformaFilhosTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Assistência a filhos'**
  String get reformaFilhosTitulo;

  /// No description provided for @reformaFilhosTexto.
  ///
  /// In pt, this message translates to:
  /// **'Se um filho adoecer e tiveres de ficar com ele, recebes subsídio nesses dias.'**
  String get reformaFilhosTexto;

  /// No description provided for @reformaPerdesBaixa.
  ///
  /// In pt, this message translates to:
  /// **'Sem baixa: se adoeceres, não recebes nada.'**
  String get reformaPerdesBaixa;

  /// No description provided for @reformaPerdesSubsidio.
  ///
  /// In pt, this message translates to:
  /// **'Sem apoio se ficares sem trabalho.'**
  String get reformaPerdesSubsidio;

  /// No description provided for @reformaPerdesTempo.
  ///
  /// In pt, this message translates to:
  /// **'Os meses sem pagar não contam para a reforma.'**
  String get reformaPerdesTempo;

  /// No description provided for @reformaPerdesDivida.
  ///
  /// In pt, this message translates to:
  /// **'A dívida fica lá e cresce com juros.'**
  String get reformaPerdesDivida;

  /// No description provided for @reformaAcordoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Acordo Portugal–Brasil'**
  String get reformaAcordoTitulo;

  /// No description provided for @reformaAcordoTexto.
  ///
  /// In pt, this message translates to:
  /// **'Se descontaste no Brasil (INSS) e em Portugal, o tempo dos dois países soma-se para a reforma. Não perdes o que já pagaste lá.'**
  String get reformaAcordoTexto;

  /// No description provided for @reformaAcordoBotao.
  ///
  /// In pt, this message translates to:
  /// **'Ver no site da Segurança Social'**
  String get reformaAcordoBotao;

  /// No description provided for @guiasSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Um minuto cada. Podes ouvir em vez de ler.'**
  String get guiasSubtitulo;

  /// No description provided for @guiasUmMinuto.
  ///
  /// In pt, this message translates to:
  /// **'1 minuto'**
  String get guiasUmMinuto;

  /// No description provided for @guiasEmBreve.
  ///
  /// In pt, this message translates to:
  /// **'Este guia está a ser escrito. Em breve fica aqui, com a fonte oficial.'**
  String get guiasEmBreve;

  /// No description provided for @guiasVazio.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há guias. Volta daqui a pouco.'**
  String get guiasVazio;

  /// No description provided for @guiasPorConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'por confirmar'**
  String get guiasPorConfirmar;

  /// No description provided for @guiasSemFonte.
  ///
  /// In pt, this message translates to:
  /// **'Fonte oficial: por confirmar'**
  String get guiasSemFonte;

  /// No description provided for @guiasOuvirErro.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui ler em voz alta neste telemóvel.'**
  String get guiasOuvirErro;

  /// No description provided for @planoSubtitulo.
  ///
  /// In pt, this message translates to:
  /// **'Menos que uma multa.'**
  String get planoSubtitulo;

  /// No description provided for @planoEstadoTitulo.
  ///
  /// In pt, this message translates to:
  /// **'O que tens agora'**
  String get planoEstadoTitulo;

  /// No description provided for @planoTrialDepois.
  ///
  /// In pt, this message translates to:
  /// **'Depois passas para o plano grátis, com limites. Se ativares o Pro, fica tudo como está.'**
  String get planoTrialDepois;

  /// No description provided for @planoLimAvisos.
  ///
  /// In pt, this message translates to:
  /// **'{n} avisos por mês'**
  String planoLimAvisos(int n);

  /// No description provided for @planoLimCarros.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, =1{1 carro} other{{n} carros}}'**
  String planoLimCarros(int n);

  /// No description provided for @planoLimPerguntas.
  ///
  /// In pt, this message translates to:
  /// **'{n} perguntas ao Em Dia por mês'**
  String planoLimPerguntas(int n);

  /// No description provided for @planoLimResto.
  ///
  /// In pt, this message translates to:
  /// **'O resto aparece com cadeado.'**
  String get planoLimResto;

  /// No description provided for @planoTensPro.
  ///
  /// In pt, this message translates to:
  /// **'Tens o Pro. Está tudo aberto.'**
  String get planoTensPro;

  /// No description provided for @planoTensFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Tens o Família / Frota. Está tudo aberto, para até {n} pessoas ou carros.'**
  String planoTensFamilia(int n);

  /// No description provided for @planoEscolhe.
  ///
  /// In pt, this message translates to:
  /// **'Escolhe como pagar'**
  String get planoEscolhe;

  /// No description provided for @planoPorMes.
  ///
  /// In pt, this message translates to:
  /// **'Por mês'**
  String get planoPorMes;

  /// No description provided for @planoPorAno.
  ///
  /// In pt, this message translates to:
  /// **'Por ano'**
  String get planoPorAno;

  /// No description provided for @planoPrecoMes.
  ///
  /// In pt, this message translates to:
  /// **'{valor}/mês'**
  String planoPrecoMes(String valor);

  /// No description provided for @planoPrecoAno.
  ///
  /// In pt, this message translates to:
  /// **'{valor}/ano'**
  String planoPrecoAno(String valor);

  /// No description provided for @planoPoupas.
  ///
  /// In pt, this message translates to:
  /// **'poupas {valor}'**
  String planoPoupas(String valor);

  /// No description provided for @planoAbreAvisos.
  ///
  /// In pt, this message translates to:
  /// **'Avisos sem limite'**
  String get planoAbreAvisos;

  /// No description provided for @planoAbreIa.
  ///
  /// In pt, this message translates to:
  /// **'Perguntas ao Em Dia sem limite'**
  String get planoAbreIa;

  /// No description provided for @planoAbreFoto.
  ///
  /// In pt, this message translates to:
  /// **'Ler extratos por foto (Uber, Bolt, Glovo)'**
  String get planoAbreFoto;

  /// No description provided for @planoAbreComprovativos.
  ///
  /// In pt, this message translates to:
  /// **'Guardar as fotos dos comprovativos'**
  String get planoAbreComprovativos;

  /// No description provided for @planoAbreCarros.
  ///
  /// In pt, this message translates to:
  /// **'Vários carros'**
  String get planoAbreCarros;

  /// No description provided for @planoAbreExportar.
  ///
  /// In pt, this message translates to:
  /// **'Exportar para o contabilista (PDF ou folha de cálculo)'**
  String get planoAbreExportar;

  /// No description provided for @planoAbreReforma.
  ///
  /// In pt, this message translates to:
  /// **'Reforma e direitos completo'**
  String get planoAbreReforma;

  /// No description provided for @planoFamiliaAbre.
  ///
  /// In pt, this message translates to:
  /// **'Tudo o que o Pro tem, para até {n} pessoas ou carros'**
  String planoFamiliaAbre(int n);

  /// No description provided for @planoAtivarPro.
  ///
  /// In pt, this message translates to:
  /// **'Ativar o Pro'**
  String get planoAtivarPro;

  /// No description provided for @planoAtivarFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Ativar o Família'**
  String get planoAtivarFamilia;

  /// No description provided for @planoATrabalhar.
  ///
  /// In pt, this message translates to:
  /// **'A falar com a Google Play…'**
  String get planoATrabalhar;

  /// No description provided for @planoCompraOk.
  ///
  /// In pt, this message translates to:
  /// **'Pronto. Já tens tudo aberto.'**
  String get planoCompraOk;

  /// No description provided for @planoCompraErro.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui fazer a compra. Não te cobrei nada. Tenta outra vez daqui a bocado.'**
  String get planoCompraErro;

  /// No description provided for @planoCompraCancelada.
  ///
  /// In pt, this message translates to:
  /// **'Cancelaste. Não te cobrei nada.'**
  String get planoCompraCancelada;

  /// No description provided for @planoLojaIndisponivel.
  ///
  /// In pt, this message translates to:
  /// **'A Google Play não está disponível neste telemóvel. Vê se tens a Play Store instalada e com sessão iniciada.'**
  String get planoLojaIndisponivel;

  /// No description provided for @planoCancelarQuando.
  ///
  /// In pt, this message translates to:
  /// **'Cancelas quando quiseres, na Google Play.'**
  String get planoCancelarQuando;

  /// No description provided for @iaSuporteTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Tira a tua dúvida'**
  String get iaSuporteTitulo;

  /// No description provided for @iaVazio.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta-me sobre recibos, IVA, Segurança Social ou o teu carro. Respondo com as regras de 2026.'**
  String get iaVazio;

  /// No description provided for @iaChip1.
  ///
  /// In pt, this message translates to:
  /// **'Abri atividade em março, quando começo a pagar?'**
  String get iaChip1;

  /// No description provided for @iaChip2.
  ///
  /// In pt, this message translates to:
  /// **'Passei os 15 mil, e agora?'**
  String get iaChip2;

  /// No description provided for @iaChip3.
  ///
  /// In pt, this message translates to:
  /// **'Posso pagar menos à Segurança Social?'**
  String get iaChip3;

  /// No description provided for @iaChip4.
  ///
  /// In pt, this message translates to:
  /// **'Quando é a inspeção do meu carro?'**
  String get iaChip4;

  /// No description provided for @iaContador.
  ///
  /// In pt, this message translates to:
  /// **'Usaste {usadas} de {n} perguntas este mês'**
  String iaContador(int usadas, int n);

  /// No description provided for @iaAPensar.
  ///
  /// In pt, this message translates to:
  /// **'A pensar…'**
  String get iaAPensar;

  /// No description provided for @iaDescansar.
  ///
  /// In pt, this message translates to:
  /// **'O assistente está a descansar. Tenta daqui a um minuto.'**
  String get iaDescansar;

  /// No description provided for @iaGuiaNovo.
  ///
  /// In pt, this message translates to:
  /// **'Pedi um guia novo sobre isto.'**
  String get iaGuiaNovo;

  /// No description provided for @iaLimiteCta.
  ///
  /// In pt, this message translates to:
  /// **'Ativa o Pro para perguntas sem limite.'**
  String get iaLimiteCta;

  /// No description provided for @iaVerPlano.
  ///
  /// In pt, this message translates to:
  /// **'Ver o plano Pro'**
  String get iaVerPlano;

  /// No description provided for @suporteIntro.
  ///
  /// In pt, this message translates to:
  /// **'O que se passa?'**
  String get suporteIntro;

  /// No description provided for @suporteDuvidaAjuda.
  ///
  /// In pt, this message translates to:
  /// **'O assistente responde já, com as regras de 2026.'**
  String get suporteDuvidaAjuda;

  /// No description provided for @suporteBugAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Conta-me o que falhou. Eu junto os dados técnicos.'**
  String get suporteBugAjuda;

  /// No description provided for @suporteReembolsoAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Faz-se na Google Play, em 2 minutos.'**
  String get suporteReembolsoAjuda;

  /// No description provided for @suporteAssunto.
  ///
  /// In pt, this message translates to:
  /// **'Assunto'**
  String get suporteAssunto;

  /// No description provided for @suporteAssuntoDica.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: A app fecha ao abrir o calendário'**
  String get suporteAssuntoDica;

  /// No description provided for @suporteDescricaoDica.
  ///
  /// In pt, this message translates to:
  /// **'O que fizeste, o que esperavas e o que aconteceu.'**
  String get suporteDescricaoDica;

  /// No description provided for @suporteLogsNota.
  ///
  /// In pt, this message translates to:
  /// **'Junto sozinho a versão da app, o tipo de telemóvel e o teu plano. Nada de palavras-passe.'**
  String get suporteLogsNota;

  /// No description provided for @suporteAssuntoEmFalta.
  ///
  /// In pt, this message translates to:
  /// **'Escreve o assunto.'**
  String get suporteAssuntoEmFalta;

  /// No description provided for @suporteErro.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui enviar. Tenta outra vez.'**
  String get suporteErro;

  /// No description provided for @suporteTicket.
  ///
  /// In pt, this message translates to:
  /// **'Pedido n.º {id}'**
  String suporteTicket(String id);

  /// No description provided for @suporteRespostaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Resposta'**
  String get suporteRespostaTitulo;

  /// No description provided for @suporteEscalado.
  ///
  /// In pt, this message translates to:
  /// **'Passei isto a uma pessoa da equipa. Respondemos aqui.'**
  String get suporteEscalado;

  /// No description provided for @suporteFechar.
  ///
  /// In pt, this message translates to:
  /// **'Voltar à ajuda'**
  String get suporteFechar;

  /// No description provided for @suporteReembolsoLinha1.
  ///
  /// In pt, this message translates to:
  /// **'A assinatura do Em Dia é cobrada pela Google Play, não por nós.'**
  String get suporteReembolsoLinha1;

  /// No description provided for @suporteReembolsoLinha2.
  ///
  /// In pt, this message translates to:
  /// **'Para cancelar ou pedir reembolso, vai às subscrições da tua conta Google.'**
  String get suporteReembolsoLinha2;

  /// No description provided for @suporteReembolsoLinha3.
  ///
  /// In pt, this message translates to:
  /// **'Continuas com o plano até ao fim do período já pago.'**
  String get suporteReembolsoLinha3;

  /// No description provided for @suporteAbrirSubscricoes.
  ///
  /// In pt, this message translates to:
  /// **'Abrir as minhas subscrições'**
  String get suporteAbrirSubscricoes;

  /// No description provided for @suporteReembolsoDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Pedido aberto a partir da app (botão \"Abrir as minhas subscrições\").'**
  String get suporteReembolsoDescricao;

  /// No description provided for @suporteRegistado.
  ///
  /// In pt, this message translates to:
  /// **'Registei o teu pedido n.º {id}. Se a Google recusar, responde aqui com esse número.'**
  String suporteRegistado(String id);

  /// No description provided for @suporteMeusPedidos.
  ///
  /// In pt, this message translates to:
  /// **'Os meus pedidos'**
  String get suporteMeusPedidos;

  /// No description provided for @suporteSemPedidos.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tens pedidos.'**
  String get suporteSemPedidos;

  /// No description provided for @suporteEstadoAberto.
  ///
  /// In pt, this message translates to:
  /// **'Aberto'**
  String get suporteEstadoAberto;

  /// No description provided for @suporteEstadoEmCurso.
  ///
  /// In pt, this message translates to:
  /// **'Em análise'**
  String get suporteEstadoEmCurso;

  /// No description provided for @suporteEstadoFechado.
  ///
  /// In pt, this message translates to:
  /// **'Resolvido'**
  String get suporteEstadoFechado;

  /// No description provided for @suporteTipoDuvida.
  ///
  /// In pt, this message translates to:
  /// **'Dúvida'**
  String get suporteTipoDuvida;

  /// No description provided for @suporteTipoBug.
  ///
  /// In pt, this message translates to:
  /// **'Problema'**
  String get suporteTipoBug;

  /// No description provided for @suporteTipoReembolso.
  ///
  /// In pt, this message translates to:
  /// **'Reembolso'**
  String get suporteTipoReembolso;

  /// No description provided for @suporteTipoGuia.
  ///
  /// In pt, this message translates to:
  /// **'Guia novo'**
  String get suporteTipoGuia;

  /// No description provided for @suporteTipoOutro.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get suporteTipoOutro;

  /// No description provided for @suporteEmailRodape.
  ///
  /// In pt, this message translates to:
  /// **'Ou escreve para {email}'**
  String suporteEmailRodape(String email);

  /// No description provided for @admNavVisaoGeral.
  ///
  /// In pt, this message translates to:
  /// **'Visão geral'**
  String get admNavVisaoGeral;

  /// No description provided for @admNavUsuarios.
  ///
  /// In pt, this message translates to:
  /// **'Usuários'**
  String get admNavUsuarios;

  /// No description provided for @admNavRegras.
  ///
  /// In pt, this message translates to:
  /// **'Regras legais'**
  String get admNavRegras;

  /// No description provided for @admNavTickets.
  ///
  /// In pt, this message translates to:
  /// **'Tickets'**
  String get admNavTickets;

  /// No description provided for @admNavIa.
  ///
  /// In pt, this message translates to:
  /// **'IA'**
  String get admNavIa;

  /// No description provided for @admNavAvisos.
  ///
  /// In pt, this message translates to:
  /// **'Avisos'**
  String get admNavAvisos;

  /// No description provided for @admNavAuditoria.
  ///
  /// In pt, this message translates to:
  /// **'Auditoria'**
  String get admNavAuditoria;

  /// No description provided for @admNaoAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Esta conta não é administradora.'**
  String get admNaoAdmin;

  /// No description provided for @admErroLer.
  ///
  /// In pt, this message translates to:
  /// **'Não consegui ler os dados: {erro}'**
  String admErroLer(String erro);

  /// No description provided for @admTentarDeNovo.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get admTentarDeNovo;

  /// No description provided for @admVazio.
  ///
  /// In pt, this message translates to:
  /// **'Nada por aqui ainda.'**
  String get admVazio;

  /// No description provided for @admErroTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Deu erro'**
  String get admErroTitulo;

  /// No description provided for @admFechar.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get admFechar;

  /// No description provided for @admConfirmar.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get admConfirmar;

  /// No description provided for @admCopiar.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get admCopiar;

  /// No description provided for @admCopiado.
  ///
  /// In pt, this message translates to:
  /// **'Copiado.'**
  String get admCopiado;

  /// No description provided for @admAtualizar.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get admAtualizar;

  /// No description provided for @admSalvar.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get admSalvar;

  /// No description provided for @admSalvo.
  ///
  /// In pt, this message translates to:
  /// **'Salvo e registrado na auditoria.'**
  String get admSalvo;

  /// No description provided for @admTodos.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get admTodos;

  /// No description provided for @admSim.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get admSim;

  /// No description provided for @admNao.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get admNao;

  /// No description provided for @admVgTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Visão geral'**
  String get admVgTitulo;

  /// No description provided for @admVgSub.
  ///
  /// In pt, this message translates to:
  /// **'Números de agora, direto das tabelas (RPC admin_resumo). Nada é calculado no navegador.'**
  String get admVgSub;

  /// No description provided for @admVgUsuarios.
  ///
  /// In pt, this message translates to:
  /// **'Usuários'**
  String get admVgUsuarios;

  /// No description provided for @admVgAtivos7.
  ///
  /// In pt, this message translates to:
  /// **'{n} ativos nos últimos 7 dias'**
  String admVgAtivos7(int n);

  /// No description provided for @admVgTrial.
  ///
  /// In pt, this message translates to:
  /// **'Em trial'**
  String get admVgTrial;

  /// No description provided for @admVgFree.
  ///
  /// In pt, this message translates to:
  /// **'Free'**
  String get admVgFree;

  /// No description provided for @admVgPro.
  ///
  /// In pt, this message translates to:
  /// **'Pro'**
  String get admVgPro;

  /// No description provided for @admVgFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Família'**
  String get admVgFamilia;

  /// No description provided for @admVgReceita.
  ///
  /// In pt, this message translates to:
  /// **'Receita estimada / mês'**
  String get admVgReceita;

  /// No description provided for @admVgReceitaSub.
  ///
  /// In pt, this message translates to:
  /// **'{n} assinaturas ativas × preço em regras_legais'**
  String admVgReceitaSub(int n);

  /// No description provided for @admVgTickets.
  ///
  /// In pt, this message translates to:
  /// **'Tickets abertos'**
  String get admVgTickets;

  /// No description provided for @admVgTicketsSub.
  ///
  /// In pt, this message translates to:
  /// **'{n} escalados para humano'**
  String admVgTicketsSub(int n);

  /// No description provided for @admVgCustoHoje.
  ///
  /// In pt, this message translates to:
  /// **'Custo IA hoje'**
  String get admVgCustoHoje;

  /// No description provided for @admVgCustoSub.
  ///
  /// In pt, this message translates to:
  /// **'Alarme acima de {valor} por dia'**
  String admVgCustoSub(String valor);

  /// No description provided for @admVgCusto7.
  ///
  /// In pt, this message translates to:
  /// **'Custo IA — 7 dias'**
  String get admVgCusto7;

  /// No description provided for @admVgCusto7Sub.
  ///
  /// In pt, this message translates to:
  /// **'{n} conversas'**
  String admVgCusto7Sub(int n);

  /// No description provided for @admVgPassadas.
  ///
  /// In pt, this message translates to:
  /// **'Obrigações passadas'**
  String get admVgPassadas;

  /// No description provided for @admVgPassadasSub.
  ///
  /// In pt, this message translates to:
  /// **'Prazos vencidos sem marcar pago, em todos os usuários'**
  String get admVgPassadasSub;

  /// No description provided for @admVgAlarme.
  ///
  /// In pt, this message translates to:
  /// **'ALARME: o custo de IA de hoje ({custo}) passou do limite ({limite}, regra ia_custo_alarme_dia_eur). Confira o modelo e o limite de perguntas em Regras legais → Cadeados por plano.'**
  String admVgAlarme(String custo, String limite);

  /// No description provided for @admVgTabDia.
  ///
  /// In pt, this message translates to:
  /// **'Dia'**
  String get admVgTabDia;

  /// No description provided for @admVgTabConversas.
  ///
  /// In pt, this message translates to:
  /// **'Conversas'**
  String get admVgTabConversas;

  /// No description provided for @admVgTabCusto.
  ///
  /// In pt, this message translates to:
  /// **'Custo (€)'**
  String get admVgTabCusto;

  /// No description provided for @admVgPushHoje.
  ///
  /// In pt, this message translates to:
  /// **'Push de hoje por resultado'**
  String get admVgPushHoje;

  /// No description provided for @admVgPushVazio.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum push enviado hoje.'**
  String get admVgPushVazio;

  /// No description provided for @admVgResultado.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get admVgResultado;

  /// No description provided for @admVgQuantidade.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get admVgQuantidade;

  /// No description provided for @admUsTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Usuários'**
  String get admUsTitulo;

  /// No description provided for @admUsSub.
  ///
  /// In pt, this message translates to:
  /// **'profiles + plano efetivo (view v_admin_usuarios). Clique numa linha para ver o detalhe e agir.'**
  String get admUsSub;

  /// No description provided for @admUsPesquisa.
  ///
  /// In pt, this message translates to:
  /// **'Buscar por e-mail ou nome (Enter para buscar)'**
  String get admUsPesquisa;

  /// No description provided for @admUsExportar.
  ///
  /// In pt, this message translates to:
  /// **'Exportar CSV'**
  String get admUsExportar;

  /// No description provided for @admUsCsvTitulo.
  ///
  /// In pt, this message translates to:
  /// **'CSV dos usuários ({n})'**
  String admUsCsvTitulo(int n);

  /// No description provided for @admUsCsvNota.
  ///
  /// In pt, this message translates to:
  /// **'Copie e cole num arquivo .csv (separador ;). O download direto pelo navegador fica para uma próxima versão.'**
  String get admUsCsvNota;

  /// No description provided for @admUsTabela.
  ///
  /// In pt, this message translates to:
  /// **'{n} usuários'**
  String admUsTabela(int n);

  /// No description provided for @admColEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get admColEmail;

  /// No description provided for @admColNome.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get admColNome;

  /// No description provided for @admColAtividade.
  ///
  /// In pt, this message translates to:
  /// **'Atividade'**
  String get admColAtividade;

  /// No description provided for @admColPlano.
  ///
  /// In pt, this message translates to:
  /// **'Plano efetivo'**
  String get admColPlano;

  /// No description provided for @admColTrialAte.
  ///
  /// In pt, this message translates to:
  /// **'Trial até'**
  String get admColTrialAte;

  /// No description provided for @admColUltimoAcesso.
  ///
  /// In pt, this message translates to:
  /// **'Último acesso'**
  String get admColUltimoAcesso;

  /// No description provided for @admColEstado.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get admColEstado;

  /// No description provided for @admColCriadoEm.
  ///
  /// In pt, this message translates to:
  /// **'Criado em'**
  String get admColCriadoEm;

  /// No description provided for @admUsBanido.
  ///
  /// In pt, this message translates to:
  /// **'banido'**
  String get admUsBanido;

  /// No description provided for @admUsAtivo.
  ///
  /// In pt, this message translates to:
  /// **'ativo'**
  String get admUsAtivo;

  /// No description provided for @admUsDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get admUsDetalhe;

  /// No description provided for @admUsAcoes.
  ///
  /// In pt, this message translates to:
  /// **'Ações'**
  String get admUsAcoes;

  /// No description provided for @admUsPlanoAtual.
  ///
  /// In pt, this message translates to:
  /// **'Plano manual (profiles.plano): {plano} · plano efetivo: {efetivo}'**
  String admUsPlanoAtual(String plano, String efetivo);

  /// No description provided for @admUsBanir.
  ///
  /// In pt, this message translates to:
  /// **'Banir'**
  String get admUsBanir;

  /// No description provided for @admUsReativar.
  ///
  /// In pt, this message translates to:
  /// **'Reativar'**
  String get admUsReativar;

  /// No description provided for @admUsBanirConfirma.
  ///
  /// In pt, this message translates to:
  /// **'Banir {email}? O usuário perde o acesso ao app até você reativar.'**
  String admUsBanirConfirma(String email);

  /// No description provided for @admUsAlterarPlano.
  ///
  /// In pt, this message translates to:
  /// **'Alterar plano manual'**
  String get admUsAlterarPlano;

  /// No description provided for @admUsPlanoManualNota.
  ///
  /// In pt, this message translates to:
  /// **'profiles.plano vale só quando não há trial ativo nem assinatura ativa na Google Play.'**
  String get admUsPlanoManualNota;

  /// No description provided for @admUsEstenderTrial.
  ///
  /// In pt, this message translates to:
  /// **'Estender trial'**
  String get admUsEstenderTrial;

  /// No description provided for @admUsEstenderDias.
  ///
  /// In pt, this message translates to:
  /// **'+{n} dias'**
  String admUsEstenderDias(int n);

  /// No description provided for @admUsApagar.
  ///
  /// In pt, this message translates to:
  /// **'Apagar conta'**
  String get admUsApagar;

  /// No description provided for @admUsApagarNota.
  ///
  /// In pt, this message translates to:
  /// **'Apagar do auth de verdade precisa da service role (servidor). Aqui só marca como banido e registra o pedido na auditoria — o servidor apaga depois.'**
  String get admUsApagarNota;

  /// No description provided for @admUsApagarConfirma.
  ///
  /// In pt, this message translates to:
  /// **'Marcar {email} como banido e registrar o pedido de apagar a conta?'**
  String admUsApagarConfirma(String email);

  /// No description provided for @admUsFeito.
  ///
  /// In pt, this message translates to:
  /// **'Feito e registrado na auditoria.'**
  String get admUsFeito;

  /// No description provided for @admUsPerfil.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get admUsPerfil;

  /// No description provided for @admUsObrigacoes.
  ///
  /// In pt, this message translates to:
  /// **'Obrigações ({n})'**
  String admUsObrigacoes(int n);

  /// No description provided for @admUsRendimentos.
  ///
  /// In pt, this message translates to:
  /// **'Rendimentos ({n})'**
  String admUsRendimentos(int n);

  /// No description provided for @admUsAssinaturas.
  ///
  /// In pt, this message translates to:
  /// **'Assinaturas ({n})'**
  String admUsAssinaturas(int n);

  /// No description provided for @admUsConversas.
  ///
  /// In pt, this message translates to:
  /// **'Últimas conversas com a IA ({n})'**
  String admUsConversas(int n);

  /// No description provided for @admRgTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Regras legais'**
  String get admRgTitulo;

  /// No description provided for @admRgSub.
  ///
  /// In pt, this message translates to:
  /// **'A única fonte de números do app e da IA. Editar aqui muda o app na hora. Confira a fonte oficial antes de salvar.'**
  String get admRgSub;

  /// No description provided for @admRgAba1.
  ///
  /// In pt, this message translates to:
  /// **'Regras'**
  String get admRgAba1;

  /// No description provided for @admRgAba2.
  ///
  /// In pt, this message translates to:
  /// **'Escalões IRS'**
  String get admRgAba2;

  /// No description provided for @admRgAba3.
  ///
  /// In pt, this message translates to:
  /// **'Cadeados por plano'**
  String get admRgAba3;

  /// No description provided for @admRgPesquisa.
  ///
  /// In pt, this message translates to:
  /// **'Buscar chave ou descrição'**
  String get admRgPesquisa;

  /// No description provided for @admRgTabela.
  ///
  /// In pt, this message translates to:
  /// **'{n} de {total} regras'**
  String admRgTabela(int n, int total);

  /// No description provided for @admRgAvisoIas.
  ///
  /// In pt, this message translates to:
  /// **'Aviso em massa: o IAS mudou'**
  String get admRgAvisoIas;

  /// No description provided for @admRgAvisoIasTitulo.
  ///
  /// In pt, this message translates to:
  /// **'O IAS mudou'**
  String get admRgAvisoIasTitulo;

  /// No description provided for @admRgAvisoIasCorpo.
  ///
  /// In pt, this message translates to:
  /// **'O IAS (o valor de referência da Segurança Social) mudou para {valor}. Os seus valores foram recalculados. Abra o app para conferir.'**
  String admRgAvisoIasCorpo(String valor);

  /// No description provided for @admRgAvisoTituloCampo.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get admRgAvisoTituloCampo;

  /// No description provided for @admRgAvisoCorpoCampo.
  ///
  /// In pt, this message translates to:
  /// **'Texto do aviso'**
  String get admRgAvisoCorpoCampo;

  /// No description provided for @admRgAvisoCriado.
  ///
  /// In pt, this message translates to:
  /// **'Aviso em massa criado. O envio é feito pelo avisos-cron (tipo massa) às 09:00 de Lisboa.'**
  String get admRgAvisoCriado;

  /// No description provided for @admRgColChave.
  ///
  /// In pt, this message translates to:
  /// **'Chave'**
  String get admRgColChave;

  /// No description provided for @admRgColDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get admRgColDescricao;

  /// No description provided for @admRgColValor.
  ///
  /// In pt, this message translates to:
  /// **'Valor'**
  String get admRgColValor;

  /// No description provided for @admRgColUnidade.
  ///
  /// In pt, this message translates to:
  /// **'Unidade'**
  String get admRgColUnidade;

  /// No description provided for @admRgColAno.
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get admRgColAno;

  /// No description provided for @admRgColConfianca.
  ///
  /// In pt, this message translates to:
  /// **'Confiança'**
  String get admRgColConfianca;

  /// No description provided for @admRgColVerificado.
  ///
  /// In pt, this message translates to:
  /// **'Verificado em'**
  String get admRgColVerificado;

  /// No description provided for @admRgColFonte.
  ///
  /// In pt, this message translates to:
  /// **'Fonte'**
  String get admRgColFonte;

  /// No description provided for @admRgEditar.
  ///
  /// In pt, this message translates to:
  /// **'Editar regra'**
  String get admRgEditar;

  /// No description provided for @admRgValorNum.
  ///
  /// In pt, this message translates to:
  /// **'Valor numérico (valor_num)'**
  String get admRgValorNum;

  /// No description provided for @admRgValorTxt.
  ///
  /// In pt, this message translates to:
  /// **'Valor em texto (valor_txt)'**
  String get admRgValorTxt;

  /// No description provided for @admRgValorJson.
  ///
  /// In pt, this message translates to:
  /// **'Valor JSON (valor_json)'**
  String get admRgValorJson;

  /// No description provided for @admRgJsonInvalido.
  ///
  /// In pt, this message translates to:
  /// **'O JSON não é válido. Confira as chaves e as vírgulas.'**
  String get admRgJsonInvalido;

  /// No description provided for @admRgFonteUrl.
  ///
  /// In pt, this message translates to:
  /// **'Fonte (URL oficial)'**
  String get admRgFonteUrl;

  /// No description provided for @admRgVerificadoEm.
  ///
  /// In pt, this message translates to:
  /// **'Verificado em (aaaa-mm-dd)'**
  String get admRgVerificadoEm;

  /// No description provided for @admRgConfianca.
  ///
  /// In pt, this message translates to:
  /// **'Confiança'**
  String get admRgConfianca;

  /// No description provided for @admRgEscOrdem.
  ///
  /// In pt, this message translates to:
  /// **'Ordem'**
  String get admRgEscOrdem;

  /// No description provided for @admRgEscAte.
  ///
  /// In pt, this message translates to:
  /// **'Até (€)'**
  String get admRgEscAte;

  /// No description provided for @admRgEscTaxa.
  ///
  /// In pt, this message translates to:
  /// **'Taxa'**
  String get admRgEscTaxa;

  /// No description provided for @admRgEscTaxaAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Taxa (0,13 = 13%)'**
  String get admRgEscTaxaAjuda;

  /// No description provided for @admRgEscParcela.
  ///
  /// In pt, this message translates to:
  /// **'Parcela a abater (€)'**
  String get admRgEscParcela;

  /// No description provided for @admRgEscSemLimite.
  ///
  /// In pt, this message translates to:
  /// **'sem limite'**
  String get admRgEscSemLimite;

  /// No description provided for @admRgEscSemLimiteAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Vazio = último escalão, sem limite'**
  String get admRgEscSemLimiteAjuda;

  /// No description provided for @admRgEscEditar.
  ///
  /// In pt, this message translates to:
  /// **'Editar escalão'**
  String get admRgEscEditar;

  /// No description provided for @admRgFlagChave.
  ///
  /// In pt, this message translates to:
  /// **'Chave'**
  String get admRgFlagChave;

  /// No description provided for @admRgFlagDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get admRgFlagDescricao;

  /// No description provided for @admRgFlagFree.
  ///
  /// In pt, this message translates to:
  /// **'Free'**
  String get admRgFlagFree;

  /// No description provided for @admRgFlagPro.
  ///
  /// In pt, this message translates to:
  /// **'Pro'**
  String get admRgFlagPro;

  /// No description provided for @admRgFlagFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Família'**
  String get admRgFlagFamilia;

  /// No description provided for @admRgFlagLimFree.
  ///
  /// In pt, this message translates to:
  /// **'Limite free'**
  String get admRgFlagLimFree;

  /// No description provided for @admRgFlagLimPro.
  ///
  /// In pt, this message translates to:
  /// **'Limite pro'**
  String get admRgFlagLimPro;

  /// No description provided for @admRgFlagLimFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Limite família'**
  String get admRgFlagLimFamilia;

  /// No description provided for @admRgFlagEditar.
  ///
  /// In pt, this message translates to:
  /// **'Editar cadeado'**
  String get admRgFlagEditar;

  /// No description provided for @admRgFlagLimiteAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Vazio = sem limite'**
  String get admRgFlagLimiteAjuda;

  /// No description provided for @admTkTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Tickets de suporte'**
  String get admTkTitulo;

  /// No description provided for @admTkSub.
  ///
  /// In pt, this message translates to:
  /// **'tickets_suporte. Clique numa linha para ver a descrição, os logs e a resposta da IA.'**
  String get admTkSub;

  /// No description provided for @admTkTabela.
  ///
  /// In pt, this message translates to:
  /// **'{n} tickets'**
  String admTkTabela(int n);

  /// No description provided for @admTkEstadoAberto.
  ///
  /// In pt, this message translates to:
  /// **'Aberto'**
  String get admTkEstadoAberto;

  /// No description provided for @admTkEstadoEmCurso.
  ///
  /// In pt, this message translates to:
  /// **'Em andamento'**
  String get admTkEstadoEmCurso;

  /// No description provided for @admTkEstadoFechado.
  ///
  /// In pt, this message translates to:
  /// **'Fechado'**
  String get admTkEstadoFechado;

  /// No description provided for @admTkEscalados.
  ///
  /// In pt, this message translates to:
  /// **'Só escalados para humano'**
  String get admTkEscalados;

  /// No description provided for @admTkColQuando.
  ///
  /// In pt, this message translates to:
  /// **'Quando'**
  String get admTkColQuando;

  /// No description provided for @admTkColTipo.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get admTkColTipo;

  /// No description provided for @admTkColAssunto.
  ///
  /// In pt, this message translates to:
  /// **'Assunto'**
  String get admTkColAssunto;

  /// No description provided for @admTkColEstado.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get admTkColEstado;

  /// No description provided for @admTkColEscalar.
  ///
  /// In pt, this message translates to:
  /// **'Humano'**
  String get admTkColEscalar;

  /// No description provided for @admTkColUsuario.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get admTkColUsuario;

  /// No description provided for @admTkDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'Ticket {id}'**
  String admTkDetalhe(String id);

  /// No description provided for @admTkDescricao.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get admTkDescricao;

  /// No description provided for @admTkLogs.
  ///
  /// In pt, this message translates to:
  /// **'Logs'**
  String get admTkLogs;

  /// No description provided for @admTkRespostaIa.
  ///
  /// In pt, this message translates to:
  /// **'Resposta da IA'**
  String get admTkRespostaIa;

  /// No description provided for @admTkMotivo.
  ///
  /// In pt, this message translates to:
  /// **'Motivo da escalada'**
  String get admTkMotivo;

  /// No description provided for @admTkMudarEstado.
  ///
  /// In pt, this message translates to:
  /// **'Mudar estado'**
  String get admTkMudarEstado;

  /// No description provided for @admTkEstadoMudado.
  ///
  /// In pt, this message translates to:
  /// **'Estado atualizado e registrado na auditoria.'**
  String get admTkEstadoMudado;

  /// No description provided for @admTkParceiro.
  ///
  /// In pt, this message translates to:
  /// **'Contato do contador/advogado parceiro'**
  String get admTkParceiro;

  /// No description provided for @admTkParceiroAjuda.
  ///
  /// In pt, this message translates to:
  /// **'Fica em regras_legais (chave contacto_parceiro_contabilista). É o que o suporte mostra quando um ticket sobe para humano. A linha é criada se não existir.'**
  String get admTkParceiroAjuda;

  /// No description provided for @admTkParceiroCampo.
  ///
  /// In pt, this message translates to:
  /// **'Nome, telefone, e-mail'**
  String get admTkParceiroCampo;

  /// No description provided for @admTkParceiroSalvo.
  ///
  /// In pt, this message translates to:
  /// **'Contato salvo e registrado na auditoria.'**
  String get admTkParceiroSalvo;

  /// No description provided for @admIaTitulo.
  ///
  /// In pt, this message translates to:
  /// **'IA — perguntas e custo'**
  String get admIaTitulo;

  /// No description provided for @admIaSub.
  ///
  /// In pt, this message translates to:
  /// **'conversas_ia (RPC admin_ia_top_perguntas) e v_custo_ia_diario.'**
  String get admIaSub;

  /// No description provided for @admIaVazio.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há perguntas registradas.'**
  String get admIaVazio;

  /// No description provided for @admIaTop.
  ///
  /// In pt, this message translates to:
  /// **'Perguntas mais feitas (top 30)'**
  String get admIaTop;

  /// No description provided for @admIaColPergunta.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta'**
  String get admIaColPergunta;

  /// No description provided for @admIaColVezes.
  ///
  /// In pt, this message translates to:
  /// **'Vezes'**
  String get admIaColVezes;

  /// No description provided for @admIaColFora.
  ///
  /// In pt, this message translates to:
  /// **'Fora das regras'**
  String get admIaColFora;

  /// No description provided for @admIaColBr.
  ///
  /// In pt, this message translates to:
  /// **'Em PT-BR'**
  String get admIaColBr;

  /// No description provided for @admIaColUltima.
  ///
  /// In pt, this message translates to:
  /// **'Última vez'**
  String get admIaColUltima;

  /// No description provided for @admIaColVariante.
  ///
  /// In pt, this message translates to:
  /// **'Variante'**
  String get admIaColVariante;

  /// No description provided for @admIaColResposta.
  ///
  /// In pt, this message translates to:
  /// **'Resposta'**
  String get admIaColResposta;

  /// No description provided for @admIaFora.
  ///
  /// In pt, this message translates to:
  /// **'Fora das regras ({n}) — candidatas a guia novo'**
  String admIaFora(int n);

  /// No description provided for @admIaForaVazio.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma pergunta fora das regras. A IA só citou o que está na tabela.'**
  String get admIaForaVazio;

  /// No description provided for @admIaCriarGuia.
  ///
  /// In pt, this message translates to:
  /// **'Criar guia'**
  String get admIaCriarGuia;

  /// No description provided for @admIaGuiaConfirma.
  ///
  /// In pt, this message translates to:
  /// **'Criar um rascunho de guia (publicado = não) com esta pergunta como corpo? Depois você edita o texto.'**
  String get admIaGuiaConfirma;

  /// No description provided for @admIaGuiaCriado.
  ///
  /// In pt, this message translates to:
  /// **'Rascunho de guia criado: {slug} (publicado = não).'**
  String admIaGuiaCriado(String slug);

  /// No description provided for @admIaCusto.
  ///
  /// In pt, this message translates to:
  /// **'Custo por dia (últimos 30 dias)'**
  String get admIaCusto;

  /// No description provided for @admIaColDia.
  ///
  /// In pt, this message translates to:
  /// **'Dia'**
  String get admIaColDia;

  /// No description provided for @admIaColConversas.
  ///
  /// In pt, this message translates to:
  /// **'Conversas'**
  String get admIaColConversas;

  /// No description provided for @admIaColCusto.
  ///
  /// In pt, this message translates to:
  /// **'Custo (€)'**
  String get admIaColCusto;

  /// No description provided for @admAvTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Avisos'**
  String get admAvTitulo;

  /// No description provided for @admAvSub.
  ///
  /// In pt, this message translates to:
  /// **'Push enviados (eventos_push), avisos em massa (avisos_massa) e log dos testes E2E (e2e_log).'**
  String get admAvSub;

  /// No description provided for @admAvNovoMassa.
  ///
  /// In pt, this message translates to:
  /// **'Novo aviso em massa'**
  String get admAvNovoMassa;

  /// No description provided for @admAvMassaNota.
  ///
  /// In pt, this message translates to:
  /// **'O envio real é feito pelo avisos-cron (tipo massa) às 09:00 de Lisboa, no máximo 1 por usuário por dia. Aqui só cria.'**
  String get admAvMassaNota;

  /// No description provided for @admAvMassaVazio.
  ///
  /// In pt, this message translates to:
  /// **'Preencha o título e o texto do aviso.'**
  String get admAvMassaVazio;

  /// No description provided for @admAvMassaCriado.
  ///
  /// In pt, this message translates to:
  /// **'Aviso em massa criado e registrado na auditoria.'**
  String get admAvMassaCriado;

  /// No description provided for @admAvMassaVazioLista.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum aviso em massa criado ainda.'**
  String get admAvMassaVazioLista;

  /// No description provided for @admAvFiltroResultado.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get admAvFiltroResultado;

  /// No description provided for @admAvFiltroTipo.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get admAvFiltroTipo;

  /// No description provided for @admAvPush.
  ///
  /// In pt, this message translates to:
  /// **'Push — últimos {n}'**
  String admAvPush(int n);

  /// No description provided for @admAvMassa.
  ///
  /// In pt, this message translates to:
  /// **'Avisos em massa'**
  String get admAvMassa;

  /// No description provided for @admAvE2e.
  ///
  /// In pt, this message translates to:
  /// **'E2E log — últimos 100'**
  String get admAvE2e;

  /// No description provided for @admAvColDia.
  ///
  /// In pt, this message translates to:
  /// **'Dia'**
  String get admAvColDia;

  /// No description provided for @admAvColTipo.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get admAvColTipo;

  /// No description provided for @admAvColTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get admAvColTitulo;

  /// No description provided for @admAvColCorpo.
  ///
  /// In pt, this message translates to:
  /// **'Corpo'**
  String get admAvColCorpo;

  /// No description provided for @admAvColResultado.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get admAvColResultado;

  /// No description provided for @admAvColEnviadoEm.
  ///
  /// In pt, this message translates to:
  /// **'Enviado em'**
  String get admAvColEnviadoEm;

  /// No description provided for @admAvColErro.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get admAvColErro;

  /// No description provided for @admAvColCriadoEm.
  ///
  /// In pt, this message translates to:
  /// **'Criado em'**
  String get admAvColCriadoEm;

  /// No description provided for @admAvColSegmento.
  ///
  /// In pt, this message translates to:
  /// **'Segmento'**
  String get admAvColSegmento;

  /// No description provided for @admAvColEnviados.
  ///
  /// In pt, this message translates to:
  /// **'Enviados'**
  String get admAvColEnviados;

  /// No description provided for @admAvNaoEnviado.
  ///
  /// In pt, this message translates to:
  /// **'ainda não'**
  String get admAvNaoEnviado;

  /// No description provided for @admAvColFluxo.
  ///
  /// In pt, this message translates to:
  /// **'Fluxo'**
  String get admAvColFluxo;

  /// No description provided for @admAvColPasso.
  ///
  /// In pt, this message translates to:
  /// **'Passo'**
  String get admAvColPasso;

  /// No description provided for @admAvColEstado.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get admAvColEstado;

  /// No description provided for @admAvColDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'Detalhe'**
  String get admAvColDetalhe;

  /// No description provided for @admAvColDevice.
  ///
  /// In pt, this message translates to:
  /// **'Dispositivo'**
  String get admAvColDevice;

  /// No description provided for @admAuTitulo.
  ///
  /// In pt, this message translates to:
  /// **'Auditoria'**
  String get admAuTitulo;

  /// No description provided for @admAuSub.
  ///
  /// In pt, this message translates to:
  /// **'admin_audit_log — últimas 300 ações de administrador. Clique para ver o antes e o depois.'**
  String get admAuSub;

  /// No description provided for @admAuFiltroAcao.
  ///
  /// In pt, this message translates to:
  /// **'Buscar ação (ex.: usuario_banir, regra_editar)'**
  String get admAuFiltroAcao;

  /// No description provided for @admAuTabela.
  ///
  /// In pt, this message translates to:
  /// **'{n} ações'**
  String admAuTabela(int n);

  /// No description provided for @admAuDetalhe.
  ///
  /// In pt, this message translates to:
  /// **'Ação #{id}'**
  String admAuDetalhe(String id);

  /// No description provided for @admAuColQuando.
  ///
  /// In pt, this message translates to:
  /// **'Quando'**
  String get admAuColQuando;

  /// No description provided for @admAuColAdmin.
  ///
  /// In pt, this message translates to:
  /// **'Admin'**
  String get admAuColAdmin;

  /// No description provided for @admAuColAcao.
  ///
  /// In pt, this message translates to:
  /// **'Ação'**
  String get admAuColAcao;

  /// No description provided for @admAuColAlvo.
  ///
  /// In pt, this message translates to:
  /// **'Alvo'**
  String get admAuColAlvo;

  /// No description provided for @admAuColAntes.
  ///
  /// In pt, this message translates to:
  /// **'Antes'**
  String get admAuColAntes;

  /// No description provided for @admAuColDepois.
  ///
  /// In pt, this message translates to:
  /// **'Depois'**
  String get admAuColDepois;
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
