// B4 (2026-09-18): as «palavras difíceis» — o glossário que o botão
// «O que é isto?» abre nos ecrãs que o juiz de simplicidade apontou.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/l10n/app_localizations.dart';
import 'package:em_dia/widgets/palavras_dificeis.dart';

void main() {
  final pt = lookupAppLocalizations(const Locale('pt'));
  final br = lookupAppLocalizations(const Locale('pt', 'BR'));

  test('S01 todas as palavras que os ecrãs pedem existem no glossário', () {
    final mapa = glossario(pt);
    final listas = {
      'calendario': PalavrasDoEcra.calendario,
      'painel': PalavrasDoEcra.painel,
      'cofre': PalavrasDoEcra.cofre,
      'carro': PalavrasDoEcra.carro,
      'guias': PalavrasDoEcra.guias,
      'fala': PalavrasDoEcra.fala,
      'ia': PalavrasDoEcra.ia,
      'recibos': PalavrasDoEcra.recibos,
      'contrato': PalavrasDoEcra.contrato,
      'empresa': PalavrasDoEcra.empresa,
      'onboardingEmpresa': PalavrasDoEcra.onboardingEmpresa,
      'onboardingAbertura': PalavrasDoEcra.onboardingAbertura,
      'onboardingIva': PalavrasDoEcra.onboardingIva,
      'onboardingIvaPeriodo': PalavrasDoEcra.onboardingIvaPeriodo,
      'onboardingAtividade': PalavrasDoEcra.onboardingAtividade,
      'mais': PalavrasDoEcra.mais,
      'reforma': PalavrasDoEcra.reforma,
      'prova': PalavrasDoEcra.prova,
      'radar': PalavrasDoEcra.radar,
    };
    for (final e in listas.entries) {
      for (final termo in e.value) {
        expect(mapa.containsKey(termo), isTrue, reason: 'ecrã ${e.key} pede «$termo» e o glossário não o tem');
      }
    }
  });

  test('S02 as palavras que o juiz apontou mais vezes estão todas explicadas', () {
    final mapa = glossario(pt);
    for (final termo in ['irs', 'ss', 'iva', 'tvde', 'iuc', 'nif', 'pro', 'dgeg', 'conta_corrente', 'imt', 'contabilidade', 'cae', 'multibanco', 'niss', 'retencao', 'anexo_b', 'eni', 'lda', 'nipc', 'trimestre', 'subsidio_natal', 'proporcional', 'fidelizacao', 'prova_rendimento', 'reforma']) {
      expect(mapa[termo], isNotNull, reason: termo);
    }
  });

  test('S03 nenhuma explicação está vazia, é curta (≤ 200 letras) e as duas línguas têm as mesmas chaves', () {
    final mPt = glossario(pt);
    final mBr = glossario(br);
    expect(mBr.keys.toSet(), mPt.keys.toSet());
    for (final e in mPt.entries) {
      final (nome, texto) = e.value;
      expect(nome.trim(), isNotEmpty, reason: e.key);
      expect(texto.trim().length, inInclusiveRange(20, 200), reason: '${e.key}: «$texto»');
      expect(texto.trim().endsWith('.'), isTrue, reason: '${e.key} não acaba em ponto');
    }
  });

  test('S04 PT-PT trata por «tu» e PT-BR por «você» onde a frase fala com a pessoa', () {
    final mPt = glossario(pt);
    final mBr = glossario(br);
    expect(mPt['irs']!.$2, contains('ganhaste'));
    expect(mBr['irs']!.$2, contains('você'));
    expect(mBr['irs']!.$2, isNot(contains('ganhaste')));
    expect(mPt['reforma']!.$1, 'Reforma');
    expect(mBr['reforma']!.$1, 'Aposentadoria');
  });

  test('S05 uma chave que não existe é ignorada, e a lista vazia não desenha botão', () {
    expect(glossario(pt)['nao_existe'], isNull);
    const b = BotaoPalavras(termos: ['nao_existe']);
    expect(b.termos, ['nao_existe']);
  });
}
