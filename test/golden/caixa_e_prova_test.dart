import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/models/entrada.dart';
import 'package:em_dia/models/fatura_recebida.dart';
import 'package:em_dia/screens/prova/prova_rendimento_screen.dart';
import 'package:em_dia/screens/vida/caixa_faturas.dart';
import 'package:em_dia/widgets/widgets.dart';

import '_apoio.dart';
import 'fabrica_de_fotos.dart';

/// Fábrica de fotos de duas telas do Bloco 4:
///   - a caixa de correio das faturas (`CaixaFaturasScreen`);
///   - a prova de rendimento (`ProvaRendimentoScreen`).
///
/// "Hoje" FIXO: segunda, 14 de setembro de 2026. Sem isto, a prova de
/// rendimento mudava de período todos os meses e as fotos nunca eram iguais
/// duas vezes.
final DateTime hojeFoto = DateTime(2026, 9, 14);

// ───────────────────────── A caixa das faturas ─────────────────────────

/// O endereço que o servidor daria a esta pessoa. As oito letras ao acaso são
/// de propósito: é o pedaço mais comprido e é onde o cartão parte, se partir.
const String enderecoDaCaixa = 'joao-a1b2c3d4@contas.em-dia.pt';

/// A frase que o servidor escreveu quando não conseguiu tratar o e-mail. Vem
/// da coluna `erro` — é dado, não é tradução, por isso é igual em PT e em BR.
const String erroDaFalhada =
    'Este e-mail veio sem nada agarrado: só texto, sem PDF nem foto da fatura.';

/// Três faturas, uma por cada estado que a pessoa vai mesmo ver:
///  - `nova` com anexo → tem os dois botões (ver o documento, fazer conta);
///  - `ligada` → já virou conta, o botão de fazer conta desaparece;
///  - `falhou` sem anexo → não tem botão nenhum de abrir e mostra o erro.
List<FaturaRecebida> tresFaturas() => [
      FaturaRecebida(
        id: 'f-nova',
        remetente: 'faturas@edp.pt',
        assunto: 'A tua fatura de eletricidade de agosto já está disponível',
        recebidoEm: DateTime(2026, 9, 13, 8, 42),
        anexoCaminho: '$userIdTeste/2026/09/edp-agosto.pdf',
        anexoNome: 'edp-agosto.pdf',
        anexoBytes: 84213,
        estado: 'nova',
      ),
      FaturaRecebida(
        id: 'f-ligada',
        remetente: 'noreply@vodafone.pt',
        assunto: 'Fatura Vodafone 09/2026',
        recebidoEm: DateTime(2026, 9, 11, 19, 5),
        anexoCaminho: '$userIdTeste/2026/09/vodafone-setembro.pdf',
        anexoNome: 'vodafone-setembro.pdf',
        anexoBytes: 51044,
        estado: 'ligada',
        saidaId: 's-vodafone-09',
      ),
      FaturaRecebida(
        id: 'f-falhou',
        remetente: 'geral@aguasdaguarda.pt',
        assunto: 'Aviso de pagamento da água',
        recebidoEm: DateTime(2026, 9, 9, 7, 30),
        estado: 'falhou',
        erro: erroDaFalhada,
      ),
    ];

/// Hoje (setembro de 2026) o domínio ainda não está comprado: a caixa está
/// DESLIGADA para toda a gente. É este o estado que a app mostra a sério, e é
/// por isso que é a primeira foto.
Widget _caixaDesligada() => embrulhaStores(
      tela: CaixaFaturasScreen(hoje: hojeFoto),
      perfil: perfilTeste(nome: 'João Pereira'),
      plano: 'trial',
    );

/// Caixa ligada, com endereço e com as três faturas.
Widget _caixaLigada() => embrulhaStores(
      tela: CaixaFaturasScreen(hoje: hojeFoto),
      perfil: perfilTeste(nome: 'João Pereira'),
      plano: 'trial',
      caixaLigada: true,
      caixaEndereco: enderecoDaCaixa,
      faturas: tresFaturas(),
    );

/// Ligada mas ainda sem nada lá dentro: é o que a pessoa vê no dia a seguir a
/// pôr o reencaminhamento no e-mail. Tem de dizer o que fazer, não ficar em
/// branco.
Widget _caixaVazia() => embrulhaStores(
      tela: CaixaFaturasScreen(hoje: hojeFoto),
      perfil: perfilTeste(nome: 'João Pereira'),
      plano: 'trial',
      caixaLigada: true,
      caixaEndereco: enderecoDaCaixa,
    );

// ───────────────────────── A prova de rendimento ─────────────────────────

Entrada _entrada({
  required String id,
  required DateTime data,
  required double valor,
  String tipo = 'plataforma',
  String? plataforma = 'uber',
  String? descricao,
}) =>
    Entrada(
      id: id,
      userId: userIdTeste,
      data: data,
      valor: valor,
      tipo: tipo,
      plataforma: tipo == 'plataforma' ? plataforma : null,
      descricao: descricao,
      periodo: 'mes',
    );

/// Doze meses seguidos de dinheiro escrito (setembro de 2025 a agosto de 2026).
///
/// O período por omissão do ecrã são 6 meses JÁ FECHADOS — com "hoje" a 14 de
/// setembro de 2026, isso é março a agosto de 2026: 1200 + 1300 + 1400 + 1250
/// + 1350 + 1600 = 8100 €, ou seja **1.350,00 €** de média por mês. É esse o
/// número grande da foto, e é ele que o teste confere.
List<Entrada> dozeMesesDeEntradas() {
  const valores = <double>[
    980, 1050, 1120, 1400, // set, out, nov, dez de 2025
    900, 1080, // jan, fev de 2026
    1200, 1300, 1400, 1250, 1350, 1600, // mar a ago de 2026 — o período de 6 meses
  ];
  return [
    for (var i = 0; i < valores.length; i++)
      _entrada(
        id: 'e-$i',
        // setembro de 2025 + i meses, sempre no dia 5 (dia fixo = foto igual).
        data: DateTime(2025, 9 + i, 5),
        valor: valores[i],
        // Alterna app de trabalho e recibo verde: é assim que ganha quem anda
        // a recibos verdes, e obriga a folha a juntar duas origens.
        tipo: i.isEven ? 'plataforma' : 'recibo_verde',
        plataforma: 'uber',
      ),
  ];
}

/// Só dois meses escritos (julho e agosto de 2026). Faltam 4 dos 6 meses do
/// período — o ecrã tem de o DIZER, e não fabricar uma folha meia vazia que
/// depois o senhorio recusa.
List<Entrada> doisMesesDeEntradas() => [
      _entrada(id: 'e-jul', data: DateTime(2026, 7, 8), valor: 1180),
      _entrada(id: 'e-ago', data: DateTime(2026, 8, 6), valor: 1320, tipo: 'recibo_verde'),
    ];

Widget _provaComDados({String plano = 'trial'}) => embrulhaStores(
      tela: ProvaRendimentoScreen(hoje: hojeFoto),
      perfil: perfilTeste(nome: 'João Pereira'),
      plano: plano,
      entradas: dozeMesesDeEntradas(),
    );

Widget _provaSemDadosSuficientes() => embrulhaStores(
      tela: ProvaRendimentoScreen(hoje: hojeFoto),
      perfil: perfilTeste(nome: 'João Pereira'),
      plano: 'trial',
      entradas: doisMesesDeEntradas(),
    );

Widget _provaVazia() => embrulhaStores(
      tela: ProvaRendimentoScreen(hoje: hojeFoto),
      perfil: perfilTeste(nome: 'João Pereira'),
      plano: 'trial',
    );

void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  // ─────────────────────────── caixa de faturas ───────────────────────────

  testWidgets('caixa desligada: diz "ainda não está pronta" e NÃO inventa endereço', (tester) async {
    await fotografaSuite(tester, nome: 'caixa_desligada', tela: _caixaDesligada);
    // O que não pode aparecer: um endereço que ainda não recebe nada.
    expect(find.byKey(const Key('caixa_endereco')), findsNothing);
    expect(find.byKey(const Key('caixa_copiar')), findsNothing);
    // "Ainda não está pronta" escreve-se igual em PT-PT e em PT-BR — dá para
    // conferir depois da última foto, que é a brasileira.
    expect(find.text('Ainda não está pronta'), findsOneWidget);
    // Sem faturas, o estado vazio também aparece.
    expect(find.byType(Vazio), findsOneWidget);
  });

  testWidgets('caixa ligada: o endereço da pessoa em cima, para copiar', (tester) async {
    await fotografaSuite(tester, nome: 'caixa_ligada', tela: _caixaLigada);
    final endereco = tester.widget<SelectableText>(find.byKey(const Key('caixa_endereco')));
    expect(endereco.data, enderecoDaCaixa);
    expect(find.byKey(const Key('caixa_copiar')), findsOneWidget);
    // Uma só por ver (a `nova`); as outras duas já foram tratadas.
    expect(find.byType(Vazio), findsNothing);
  });

  testWidgets('caixa ligada: as três faturas (nova, já é conta, não deu)', (tester) async {
    // Rola até à fatura que falhou: numa ListView o que está abaixo da dobra
    // nem chega a ser construído, e nos tamanhos pequenos o terceiro cartão
    // fica lá em baixo.
    Future<void> rolarAteAoFim(WidgetTester t) async {
      await t.dragUntilVisible(
        find.text(erroDaFalhada),
        find.byType(ListView).first,
        const Offset(0, -220),
      );
      await t.pumpAndSettle();
    }

    await fotografaSuite(
      tester,
      nome: 'caixa_faturas',
      tela: _caixaLigada,
      antes: rolarAteAoFim,
    );

    // A nova tem anexo e ainda não é conta: dá para fazer a conta com ela.
    expect(find.byKey(const Key('caixa_fazer_conta_f-nova')), findsOneWidget);
    // A que já é conta perde o botão de fazer conta (senão fazia-se duas vezes).
    expect(find.byKey(const Key('caixa_fazer_conta_f-ligada')), findsNothing);
    // A que falhou não tem anexo: não há nada para abrir nem para ler.
    expect(find.byKey(const Key('caixa_fazer_conta_f-falhou')), findsNothing);
    // E diz, por palavras, porque é que não deu.
    expect(find.text(erroDaFalhada), findsOneWidget);
    // Só as duas com anexo mostram "Ver o documento".
    expect(find.byIcon(Icons.open_in_new_rounded), findsNWidgets(2));
  });

  testWidgets('caixa ligada mas vazia: explica o que fazer em vez de ficar em branco', (tester) async {
    await fotografaSuite(tester, nome: 'caixa_vazia', tela: _caixaVazia);
    expect(find.byType(Vazio), findsOneWidget);
    expect(find.byKey(const Key('caixa_endereco')), findsOneWidget);
  });

  // ─────────────────────────── prova de rendimento ───────────────────────────

  testWidgets('prova com 12 meses escritos: a média mensal em grande', (tester) async {
    // Tem campos de texto (nome e NIF) — por isso vai também com teclado.
    await fotografaSuite(
      tester,
      nome: 'prova_com_dados',
      tela: _provaComDados,
      comTeclado: true,
    );
    expect(find.byKey(const Key('prova_media')), findsOneWidget);
    // 8100 € em 6 meses fechados (março a agosto de 2026).
    expect(find.text('1.350,00 €'), findsOneWidget);
    expect(find.text('8.100,00 €'), findsOneWidget);
    // Com meses a mais que chegue, o botão de fazer a folha está vivo.
    final botao = tester.widget<BotaoGrande>(find.byKey(const Key('prova_fazer')));
    expect(botao.aoTocar, isNotNull);
    // Nada de cadeado: no trial está tudo aberto.
    expect(find.byIcon(Icons.lock_rounded), findsNothing);
  });

  testWidgets('prova com poucos meses: diz quantos faltam, não gera folha vazia', (tester) async {
    await fotografaSuite(
      tester,
      nome: 'prova_sem_dados',
      tela: _provaSemDadosSuficientes,
      comTeclado: true,
    );
    // Faltam 4 dos 6 meses: aparece o aviso e NÃO aparece o cartão da média —
    // uma média de dois meses fingida de seis era mentira.
    expect(find.byType(Aviso), findsOneWidget);
    expect(find.byKey(const Key('prova_media')), findsNothing);
    // E o botão fica morto: uma folha destas não se entrega a ninguém.
    final botao = tester.widget<BotaoGrande>(find.byKey(const Key('prova_fazer')));
    expect(botao.aoTocar, isNull);
  });

  testWidgets('prova sem nada escrito: manda a pessoa escrever primeiro', (tester) async {
    // Sem teclado: aqui não há nada para escrever nesta tela, o caminho é ir a
    // "A minha vida" primeiro.
    await fotografaSuite(tester, nome: 'prova_vazia', tela: _provaVazia);
    expect(find.byType(Vazio), findsOneWidget);
    expect(find.byKey(const Key('prova_media')), findsNothing);
    expect(find.byType(Aviso), findsNothing);
  });

  testWidgets('prova no plano grátis: o cadeado por cima de tudo', (tester) async {
    // Sem teclado: com o cadeado os campos estão atrás de um IgnorePointer,
    // ninguém consegue lá escrever.
    await fotografaSuite(
      tester,
      nome: 'prova_trancada',
      tela: () => _provaComDados(plano: 'free'),
    );
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    // Os dados continuam lá por baixo, esbatidos — é o que faz querer o Pro.
    expect(find.byKey(const Key('prova_media')), findsOneWidget);
  });
}
