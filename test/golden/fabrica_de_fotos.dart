// F-OLHO · Camada 1 — a fábrica de fotos (copiada do padrão do Bora).
//
// Fotografa uma tela em 3 tamanhos (pequeno 360×780, médio 390×844, grande
// 430×932), com e sem teclado, em PT-PT e PT-BR. Um overflow (RenderFlex
// overflowed) faz o teste FALHAR — é o CI vermelho da regra "estouro = falha".
// As fotos ficam em test/golden/_fotos/<nome>_<tamanho>[_teclado]_<locale>.png
// e o juiz de visão (tool/juiz/vision_judge.py) lê-as depois.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/config/app_theme.dart';
import 'package:em_dia/l10n/app_localizations.dart';

/// Os três tamanhos da suíte (nome, tamanho lógico).
const List<(String, Size)> tamanhos = [
  ('pequeno', Size(360, 780)),
  ('medio', Size(390, 844)),
  ('grande', Size(430, 932)),
];

const List<Locale> locales = [Locale('pt'), Locale('pt', 'BR')];

String _dirFotos() {
  // O cwd do `flutter test` é a raiz do projeto.
  final d = Directory('test/golden/_fotos');
  if (!d.existsSync()) d.createSync(recursive: true);
  return d.path;
}

/// Carrega a fonte Inter dos assets (senão as fotos saem em Ahem, os quadrados).
Future<void> carregaFonteInter() async {
  final loader = FontLoader('Inter')..addFont(rootBundle.load('assets/fonts/Inter-VariableFont.ttf'));
  await loader.load();
}

/// Carrega os MaterialIcons do SDK (senão os ícones saem como caixas).
Future<void> carregaFontesSdk() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ??
      (Platform.resolvedExecutable.contains('flutter')
          ? Platform.resolvedExecutable.split(RegExp(r'[\\/]bin[\\/]')).first
          : '');
  final candidatos = [
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  for (final c in candidatos) {
    final f = File(c);
    if (f.existsSync()) {
      final bytes = await f.readAsBytes();
      final loader = FontLoader('MaterialIcons')..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
      return;
    }
  }
}

/// Embrulha a tela na app real (tema + traduções) para a foto.
Widget embrulha(Widget tela, Locale locale) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      locale: locale,
      supportedLocales: locales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: tela,
    );

/// Fotografa UMA tela num tamanho. [tela] é construída de novo por chamada
/// (builder) para não partilhar estado entre fotos.
Future<void> fotografaTela(
  WidgetTester tester, {
  required String nome,
  required (String, Size) tamanho,
  required Widget Function() tela,
  Locale locale = const Locale('pt'),
  bool teclado = false,
  Future<void> Function(WidgetTester)? antes,
}) async {
  final (rotulo, size) = tamanho;
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  tester.view.viewInsets = teclado ? const FakeViewPadding(bottom: 300 * 3) : FakeViewPadding.zero;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetViewInsets();
  });

  await tester.pumpWidget(embrulha(tela(), locale));
  await tester.pump(const Duration(milliseconds: 100));
  if (antes != null) await antes(tester);
  await tester.pump(const Duration(milliseconds: 300));

  // A codificação PNG e a escrita em disco são trabalho REAL (fora do relógio
  // falso do flutter_test): sem runAsync o future nunca completa e o teste
  // pendura até ao timeout (cicatriz 2026-09-06: 1 foto em 10 minutos, vazia).
  final sufixoLocale = locale.countryCode == 'BR' ? 'br' : 'pt';
  final caminho = '${_dirFotos()}/${nome}_$rotulo${teclado ? '_teclado' : ''}_$sufixoLocale.png';
  await tester.runAsync(() async {
    final elemento = find.byType(MaterialApp).evaluate().first;
    final ui.Image imagem = await captureImage(elemento);
    final bytes = await imagem.toByteData(format: ui.ImageByteFormat.png);
    await File(caminho).writeAsBytes(bytes!.buffer.asUint8List());
  });
  expect(File(caminho).lengthSync(), greaterThan(1000), reason: 'foto vazia: $caminho');
}

/// A suíte completa de uma tela: 3 tamanhos × (sem/com teclado) × PT/BR.
/// [comTeclado] só faz sentido em telas com campos de texto.
Future<void> fotografaSuite(
  WidgetTester tester, {
  required String nome,
  required Widget Function() tela,
  bool comTeclado = false,
  Future<void> Function(WidgetTester)? antes,
}) async {
  for (final locale in locales) {
    for (final t in tamanhos) {
      await fotografaTela(tester, nome: nome, tamanho: t, tela: tela, locale: locale, antes: antes);
      if (comTeclado) {
        await fotografaTela(tester, nome: nome, tamanho: t, tela: tela, locale: locale, teclado: true, antes: antes);
      }
    }
  }
}
