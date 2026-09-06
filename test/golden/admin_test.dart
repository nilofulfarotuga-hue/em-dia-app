// Painel admin (Flutter Web, PT-BR) — fotos de desktop 1280×800 das 7 secções,
// com dados de exemplo em memória (AdminDados.paraTeste), sem servidor.
// Um overflow faz o teste FALHAR (regra "estouro = falha").
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:em_dia/admin/admin_dados.dart';
import 'package:em_dia/admin/admin_shell.dart';

import 'fabrica_de_fotos.dart';

const Size tamanhoDesktop = Size(1280, 800);

/// Fotografa uma tela de desktop (1280×800, dpr 2) em PT-BR — o admin é sempre PT-BR.
Future<void> fotografaDesktop(
  WidgetTester tester, {
  required String nome,
  required Widget Function() tela,
  Future<void> Function(WidgetTester)? antes,
}) async {
  tester.view.physicalSize = tamanhoDesktop * 2;
  tester.view.devicePixelRatio = 2;
  tester.view.viewInsets = FakeViewPadding.zero;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.view.resetViewInsets();
  });
  await tester.pumpWidget(embrulha(tela(), const Locale('pt', 'BR')));
  await tester.pump(const Duration(milliseconds: 100));
  if (antes != null) await antes(tester);
  await tester.pump(const Duration(milliseconds: 400));

  final dir = Directory('test/golden/_fotos');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  final caminho = '${dir.path}/${nome}_desktop_br.png';
  await tester.runAsync(() async {
    final elemento = find.byType(MaterialApp).evaluate().first;
    final ui.Image imagem = await captureImage(elemento);
    final bytes = await imagem.toByteData(format: ui.ImageByteFormat.png);
    await File(caminho).writeAsBytes(bytes!.buffer.asUint8List());
  });
  expect(File(caminho).lengthSync(), greaterThan(1000), reason: 'foto vazia: $caminho');
}

const _u1 = '11111111-1111-4111-8111-111111111111';
const _u2 = '22222222-2222-4222-8222-222222222222';
const _u3 = '33333333-3333-4333-8333-333333333333';
const _adm = '00000000-0000-4000-8000-00000000adm1';

DadosTeste dadosExemplo({bool alarme = false}) {
  final hoje = DateTime(2026, 9, 6);
  String dia(int atras) {
    final d = hoje.subtract(Duration(days: atras));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  final custo = [
    {'dia': dia(0), 'conversas': 41, 'custo_eur': alarme ? 0.7312 : 0.1184},
    {'dia': dia(1), 'conversas': 58, 'custo_eur': 0.1621},
    {'dia': dia(2), 'conversas': 33, 'custo_eur': 0.0912},
    {'dia': dia(3), 'conversas': 27, 'custo_eur': 0.0744},
    {'dia': dia(4), 'conversas': 49, 'custo_eur': 0.1388},
    {'dia': dia(5), 'conversas': 12, 'custo_eur': 0.0331},
    {'dia': dia(6), 'conversas': 19, 'custo_eur': 0.0527},
  ];

  final usuarios = [
    UsuarioAdmin(userId: _u1, email: 'joao.tvde@gmail.com', nome: 'João Pereira', tipoAtividade: 'tvde', plano: 'free', planoEfetivo: 'trial', trialAte: DateTime(2026, 9, 28), ultimoAcesso: DateTime(2026, 9, 6, 8, 12), criadoEm: DateTime(2026, 8, 29), variantePt: 'pt', onboardingConcluido: true),
    UsuarioAdmin(userId: _u2, email: 'maria.estafeta@hotmail.com', nome: 'Maria Souza', tipoAtividade: 'estafeta', plano: 'free', planoEfetivo: 'pro', trialAte: DateTime(2026, 8, 20), ultimoAcesso: DateTime(2026, 9, 5, 22, 40), criadoEm: DateTime(2026, 7, 21), variantePt: 'br', onboardingConcluido: true),
    UsuarioAdmin(userId: _u3, email: 'carlos.freela@proton.me', nome: 'Carlos Lima', tipoAtividade: 'freelancer', plano: 'free', planoEfetivo: 'free', trialAte: DateTime(2026, 8, 2), ultimoAcesso: DateTime(2026, 8, 30, 19, 5), criadoEm: DateTime(2026, 7, 3), variantePt: 'br'),
    UsuarioAdmin(userId: '44444444-4444-4444-8444-444444444444', email: 'ana.servicos@gmail.com', nome: 'Ana Ribeiro', tipoAtividade: 'servicos', plano: 'familia', planoEfetivo: 'familia', trialAte: DateTime(2026, 7, 15), ultimoAcesso: DateTime(2026, 9, 4, 10, 0), criadoEm: DateTime(2026, 6, 15), onboardingConcluido: true),
    UsuarioAdmin(userId: '55555555-5555-4555-8555-555555555555', email: 'spam.bot@mail.ru', nome: null, tipoAtividade: 'sem_atividade', plano: 'free', planoEfetivo: 'free', trialAte: DateTime(2026, 8, 1), ultimoAcesso: null, banido: true, criadoEm: DateTime(2026, 7, 2)),
    UsuarioAdmin(userId: '66666666-6666-4666-8666-666666666666', email: 'rui.carro@sapo.pt', nome: 'Rui Martins', tipoAtividade: 'so_carro', plano: 'free', planoEfetivo: 'trial', trialAte: DateTime(2026, 10, 1), ultimoAcesso: DateTime(2026, 9, 6, 7, 30), criadoEm: DateTime(2026, 9, 1), onboardingConcluido: true),
  ];

  return DadosTeste(
    resumo: ResumoAdmin(
      usuariosTotal: 148,
      usuariosAtivos7d: 63,
      planos: const {'trial': 41, 'free': 82, 'pro': 21, 'familia': 4},
      receitaMensalEur: 21 * 3.49 + 4 * 5.99,
      assinaturasAtivas: 25,
      ticketsAbertos: 7,
      ticketsEscalados: 2,
      obrigacoesPassadas: 19,
      alarmeEur: 0.50,
      custoIa: custo,
      pushHoje: const {'ok': 38, 'sem_token': 5, 'erro': 1},
      hoje: hoje,
    ),
    usuarios: usuarios,
    detalhes: {
      _u1: DetalheUsuario(
        perfil: {...usuarios[0].toMap(), 'data_abertura': '2026-03-01', 'regime_iva': 'isento_53', 'retencao_opcao': 'padrao', 'rendimento_mensal_estimado': 1250, 'imigrante': false},
        obrigacoes: [
          {'tipo': 'ss_pagamento', 'estado': 'pendente', 'data_limite': '2026-09-20', 'valor_estimado': 149.80},
          {'tipo': 'iva_declaracao', 'estado': 'passado', 'data_limite': '2026-08-20', 'valor_estimado': null},
        ],
        rendimentos: [
          {'mes': '2026-08-01', 'plataforma': 'uber', 'valor_bruto': 1310.50},
          {'mes': '2026-07-01', 'plataforma': 'bolt', 'valor_bruto': 980.00},
        ],
        assinaturas: const [],
        conversas: [
          {'variante': 'pt', 'criado_em': '2026-09-05T18:10:00Z', 'pergunta': 'Abri atividade em março, quando começo a pagar?', 'fora_das_regras': false},
        ],
      ),
    },
    regras: [
      {'chave': 'ias', 'descricao': 'IAS — Indexante dos Apoios Sociais', 'valor_num': 537.13, 'unidade': 'eur', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': 'https://www.seg-social.pt/ias', 'verificado_em': '2026-09-05'},
      {'chave': 'iva_isencao_limite', 'descricao': 'Limite da isenção de IVA (art. 53.º)', 'valor_num': 15000, 'unidade': 'eur', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': 'https://info.portaldasfinancas.gov.pt', 'verificado_em': '2026-09-05'},
      {'chave': 'ss_taxa_independente', 'descricao': 'Taxa contributiva do trabalhador independente', 'valor_num': 0.214, 'unidade': 'pct', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': 'https://www.seg-social.pt', 'verificado_em': '2026-09-05'},
      {'chave': 'ss_isencao_meses', 'descricao': 'Meses de isenção no início de atividade', 'valor_num': 12, 'unidade': 'meses', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': 'https://www.seg-social.pt', 'verificado_em': '2026-09-05'},
      {'chave': 'irs_retencao_padrao', 'descricao': 'Retenção na fonte padrão (categoria B)', 'valor_num': 0.25, 'unidade': 'pct', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': null, 'verificado_em': '2026-09-05'},
      {'chave': 'iuc_prazo_regra', 'descricao': 'IUC paga-se até ao fim do mês da matrícula', 'valor_txt': 'mes_matricula', 'unidade': 'texto', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': 'https://www.portaldasfinancas.gov.pt', 'verificado_em': '2026-09-05'},
      {'chave': 'ipo_calendario', 'descricao': 'Calendário de inspeções (anos após matrícula)', 'valor_json': {'primeira': 4, 'depois': [2, 2, 1]}, 'unidade': 'tabela', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': 'https://www.imt-ip.pt', 'verificado_em': '2026-09-05'},
      {'chave': 'preco_pro_mensal', 'descricao': 'Preço do plano Pro (mês)', 'valor_num': 3.49, 'unidade': 'eur', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': null, 'verificado_em': '2026-09-05'},
      {'chave': 'ia_custo_alarme_dia_eur', 'descricao': 'Alarme no admin acima deste custo diário de IA', 'valor_num': 0.50, 'unidade': 'eur', 'ano': 2026, 'confianca': 'oficial', 'fonte_url': null, 'verificado_em': '2026-09-05'},
      {'chave': 'tvde_certificado_validade_anos', 'descricao': 'Validade do certificado de motorista TVDE', 'valor_num': 5, 'unidade': 'anos', 'ano': 2026, 'confianca': 'aproximado', 'fonte_url': 'https://www.imt-ip.pt', 'verificado_em': null},
      {'chave': 'residencia_renovacao_aviso_dias', 'descricao': 'Aviso antes de renovar a autorização de residência', 'valor_num': 60, 'unidade': 'dias', 'ano': 2026, 'confianca': 'por_confirmar', 'fonte_url': null, 'verificado_em': null},
    ],
    escaloes: [
      {'id': 1, 'ano': 2026, 'ordem': 1, 'ate': 8059, 'taxa': 0.125, 'parcela_abater': 0},
      {'id': 2, 'ano': 2026, 'ordem': 2, 'ate': 12160, 'taxa': 0.16, 'parcela_abater': 282.07},
      {'id': 3, 'ano': 2026, 'ordem': 3, 'ate': 17233, 'taxa': 0.215, 'parcela_abater': 950.87},
      {'id': 4, 'ano': 2026, 'ordem': 4, 'ate': 22306, 'taxa': 0.245, 'parcela_abater': 1467.86},
      {'id': 5, 'ano': 2026, 'ordem': 5, 'ate': 28400, 'taxa': 0.315, 'parcela_abater': 3029.28},
      {'id': 6, 'ano': 2026, 'ordem': 6, 'ate': 41629, 'taxa': 0.345, 'parcela_abater': 3881.28},
      {'id': 7, 'ano': 2026, 'ordem': 7, 'ate': 44987, 'taxa': 0.435, 'parcela_abater': 7627.89},
      {'id': 8, 'ano': 2026, 'ordem': 8, 'ate': 83696, 'taxa': 0.45, 'parcela_abater': 8302.70},
      {'id': 9, 'ano': 2026, 'ordem': 9, 'ate': null, 'taxa': 0.48, 'parcela_abater': 10813.58},
    ],
    flags: [
      {'chave': 'painel', 'descricao': 'Painel "Estás em dia?"', 'free': true, 'pro': true, 'familia': true, 'limite_free': null, 'limite_pro': null, 'limite_familia': null},
      {'chave': 'calculadora', 'descricao': 'Calculadora de recibo verde', 'free': true, 'pro': true, 'familia': true, 'limite_free': null, 'limite_pro': null, 'limite_familia': null},
      {'chave': 'avisos_push', 'descricao': 'Avisos por notificação (por mês)', 'free': true, 'pro': true, 'familia': true, 'limite_free': 3, 'limite_pro': null, 'limite_familia': null},
      {'chave': 'ia_perguntas', 'descricao': 'Perguntas ao assistente (por mês)', 'free': true, 'pro': true, 'familia': true, 'limite_free': 5, 'limite_pro': null, 'limite_familia': null},
      {'chave': 'ler_extrato_foto', 'descricao': 'Ler extrato Uber/Bolt/Glovo por foto', 'free': false, 'pro': true, 'familia': true, 'limite_free': null, 'limite_pro': null, 'limite_familia': null},
      {'chave': 'carros', 'descricao': 'Carros registados', 'free': true, 'pro': true, 'familia': true, 'limite_free': 1, 'limite_pro': null, 'limite_familia': 5},
      {'chave': 'exportar_contabilista', 'descricao': 'Exportar PDF/CSV para o contabilista', 'free': false, 'pro': true, 'familia': true, 'limite_free': null, 'limite_pro': null, 'limite_familia': null},
      {'chave': 'membros', 'descricao': 'Pessoas na conta (Família/Frota)', 'free': false, 'pro': false, 'familia': true, 'limite_free': null, 'limite_pro': null, 'limite_familia': 5},
    ],
    tickets: [
      {'id': '85f6a3cb-83a6-49e2-a567-701df9223e73', 'user_id': _u1, 'tipo': 'bug', 'assunto': 'A app fecha ao abrir o calendário', 'descricao': 'Toco em Calendário e fecha logo. Pixel 6a, Android 14.', 'logs': 'versao=1.0.0+3 plano=trial device=Pixel 6a', 'estado': 'aberto', 'escalar_humano': true, 'motivo_escala': 'bug com crash', 'resposta_ia': 'Obrigado. Passei isto para uma pessoa da equipa.', 'criado_em': '2026-09-05T18:12:00Z'},
      {'id': '5cfa39f8-81b1-4709-90b2-73260e45552a', 'user_id': _u2, 'tipo': 'reembolso', 'assunto': 'Quero cancelar a assinatura', 'descricao': null, 'logs': null, 'estado': 'fechado', 'escalar_humano': false, 'motivo_escala': null, 'resposta_ia': 'Os reembolsos tratam-se na Google Play.', 'criado_em': '2026-09-02T09:30:00Z'},
      {'id': 'c1d2e3f4-1111-4222-8333-444455556666', 'user_id': _u3, 'tipo': 'duvida', 'assunto': 'Preciso de contabilista para o IRS?', 'descricao': 'Faturei 14 mil este ano.', 'logs': null, 'estado': 'em_curso', 'escalar_humano': true, 'motivo_escala': 'pediu humano', 'resposta_ia': null, 'criado_em': '2026-09-04T11:05:00Z'},
      {'id': 'd4e5f6a7-2222-4333-8444-555566667777', 'user_id': _u1, 'tipo': 'guia_novo', 'assunto': 'Como mudar de regime de IVA', 'descricao': null, 'logs': null, 'estado': 'aberto', 'escalar_humano': false, 'motivo_escala': null, 'resposta_ia': 'Pedi um guia novo sobre isto.', 'criado_em': '2026-09-03T15:45:00Z'},
      {'id': 'e5f6a7b8-3333-4444-8555-666677778888', 'user_id': _u2, 'tipo': 'outro', 'assunto': 'Elogio: o app salvou minha SS', 'descricao': 'Só queria agradecer.', 'logs': null, 'estado': 'fechado', 'escalar_humano': false, 'motivo_escala': null, 'resposta_ia': 'Obrigado!', 'criado_em': '2026-08-30T20:00:00Z'},
    ],
    topPerguntas: [
      {'pergunta': 'abri atividade em março, quando começo a pagar?', 'n': 37, 'ultima': '2026-09-06T07:40:00Z', 'fora_das_regras': 0, 'variante_br': 12},
      {'pergunta': 'passei dos 15 mil, e agora?', 'n': 29, 'ultima': '2026-09-05T21:10:00Z', 'fora_das_regras': 0, 'variante_br': 9},
      {'pergunta': 'posso pagar menos à segurança social?', 'n': 22, 'ultima': '2026-09-05T13:02:00Z', 'fora_das_regras': 0, 'variante_br': 4},
      {'pergunta': 'quando é a inspeção do meu carro?', 'n': 18, 'ultima': '2026-09-04T09:15:00Z', 'fora_das_regras': 0, 'variante_br': 6},
      {'pergunta': 'como pedir o nif para a minha mulher?', 'n': 9, 'ultima': '2026-09-03T17:30:00Z', 'fora_das_regras': 9, 'variante_br': 8},
      {'pergunta': 'posso deduzir o gasóleo no irs?', 'n': 7, 'ultima': '2026-09-02T12:00:00Z', 'fora_das_regras': 7, 'variante_br': 1},
    ],
    foraDasRegras: [
      {'id': 'a1', 'user_id': _u3, 'pergunta': 'Como pedir o NIF para a minha mulher?', 'resposta': 'Não tenho essa regra confirmada. Fala com as Finanças.', 'variante': 'br', 'modo': 'chat', 'criado_em': '2026-09-03T17:30:00Z'},
      {'id': 'a2', 'user_id': _u1, 'pergunta': 'Posso deduzir o gasóleo no IRS?', 'resposta': 'Não tenho essa regra confirmada.', 'variante': 'pt', 'modo': 'chat', 'criado_em': '2026-09-02T12:00:00Z'},
      {'id': 'a3', 'user_id': _u2, 'pergunta': 'O Bolt desconta a SS por mim?', 'resposta': 'Não tenho essa regra confirmada.', 'variante': 'br', 'modo': 'suporte', 'criado_em': '2026-09-01T08:20:00Z'},
    ],
    custoIa: custo,
    eventosPush: [
      {'id': 'p1', 'user_id': _u1, 'tipo': '5_dias', 'dia': dia(0), 'titulo': 'Faltam 5 dias', 'corpo': 'Faltam 5 dias para a Segurança Social (149,80 €).', 'enviado_em': '2026-09-06T08:00:00Z', 'resultado': 'ok', 'erro': null},
      {'id': 'p2', 'user_id': _u2, 'tipo': 'dia', 'dia': dia(0), 'titulo': 'É hoje', 'corpo': 'É hoje. IVA, até meia-noite.', 'enviado_em': '2026-09-06T08:00:00Z', 'resultado': 'ok', 'erro': null},
      {'id': 'p3', 'user_id': _u3, 'tipo': 'passado', 'dia': dia(0), 'titulo': 'Passou o dia 20', 'corpo': 'Passou o dia 20 e não marcaste como pago.', 'enviado_em': '2026-09-06T08:00:00Z', 'resultado': 'sem_token', 'erro': null},
      {'id': 'p4', 'user_id': _u1, 'tipo': 'vigia_iva', 'dia': dia(1), 'titulo': 'Atenção ao IVA', 'corpo': 'Já estás em 12.400 € este ano.', 'enviado_em': '2026-09-05T08:00:00Z', 'resultado': 'ok', 'erro': null},
      {'id': 'p5', 'user_id': _u2, 'tipo': 'carro', 'dia': dia(1), 'titulo': 'Inspeção', 'corpo': 'A inspeção do teu carro (AA-00-BB) é até 30/09/2026.', 'enviado_em': '2026-09-05T08:00:00Z', 'resultado': 'erro', 'erro': 'FCM 404 UNREGISTERED'},
      {'id': 'p6', 'user_id': _u3, 'tipo': 'trial_25', 'dia': dia(2), 'titulo': 'Faltam 5 dias de trial', 'corpo': 'Faltam 5 dias para o teu mês grátis acabar.', 'enviado_em': '2026-09-04T08:00:00Z', 'resultado': 'ok', 'erro': null},
      {'id': 'p7', 'user_id': _u1, 'tipo': 'massa', 'dia': dia(3), 'titulo': 'O IAS mudou', 'corpo': 'O IAS mudou para 537,13 €.', 'enviado_em': null, 'resultado': null, 'erro': null},
    ],
    avisosMassa: [
      {'id': 'm1', 'titulo': 'O IAS mudou', 'corpo': 'O IAS (o valor de referência da Segurança Social) mudou para 537,13 €. Abra o app para conferir.', 'segmento': 'todos', 'enviado_por': _adm, 'enviado_em': '2026-09-03T08:00:00Z', 'total_enviados': 131, 'criado_em': '2026-09-02T22:10:00Z'},
      {'id': 'm2', 'titulo': 'Novo guia: mudar de regime de IVA', 'corpo': 'Publicámos um guia de 1 minuto sobre o regime de IVA.', 'segmento': 'todos', 'enviado_por': _adm, 'enviado_em': null, 'total_enviados': 0, 'criado_em': '2026-09-05T23:00:00Z'},
    ],
    e2eLog: [
      {'id': 1, 'created_at': '2026-09-06T03:10:00Z', 'fluxo': 'onboarding', 'passo': 'criar_conta', 'estado': 'ok', 'detalhe': 'OTP recebido em 4 s', 'device': 'Pixel 6a', 'run_id': 'r-101'},
      {'id': 2, 'created_at': '2026-09-06T03:11:00Z', 'fluxo': 'onboarding', 'passo': 'calcular_obrigacoes', 'estado': 'ok', 'detalhe': '3 obrigações geradas', 'device': 'Pixel 6a', 'run_id': 'r-101'},
      {'id': 3, 'created_at': '2026-09-06T03:12:00Z', 'fluxo': 'recibos', 'passo': 'calculadora', 'estado': 'ok', 'detalhe': '1000 € → 750 € líquido', 'device': 'Pixel 6a', 'run_id': 'r-101'},
      {'id': 4, 'created_at': '2026-09-06T03:13:00Z', 'fluxo': 'ia', 'passo': 'pergunta', 'estado': 'erro', 'detalhe': '503 sem_gemini_api_key', 'device': 'Pixel 6a', 'run_id': 'r-101'},
      {'id': 5, 'created_at': '2026-09-05T03:10:00Z', 'fluxo': 'carro', 'passo': 'abastecimento', 'estado': 'ok', 'detalhe': '45 L · 72,90 €', 'device': 'Galaxy A34', 'run_id': 'r-100'},
    ],
    auditoria: [
      {'id': 61, 'admin_id': _adm, 'acao': 'usuario_banir', 'alvo_tipo': 'profiles', 'alvo_id': '55555555-5555-4555-8555-555555555555', 'antes': {'banido': false}, 'depois': {'banido': true}, 'criado_em': '2026-09-06T04:02:00Z'},
      {'id': 60, 'admin_id': _adm, 'acao': 'regra_editar', 'alvo_tipo': 'regras_legais', 'alvo_id': 'ias', 'antes': {'valor_num': 522.5, 'verificado_em': '2026-01-10'}, 'depois': {'valor_num': 537.13, 'verificado_em': '2026-09-05'}, 'criado_em': '2026-09-05T23:40:00Z'},
      {'id': 59, 'admin_id': _adm, 'acao': 'aviso_massa_criar', 'alvo_tipo': 'avisos_massa', 'alvo_id': 'm2', 'antes': null, 'depois': {'titulo': 'Novo guia: mudar de regime de IVA', 'segmento': 'todos'}, 'criado_em': '2026-09-05T23:00:00Z'},
      {'id': 58, 'admin_id': _adm, 'acao': 'ticket_estado', 'alvo_tipo': 'tickets_suporte', 'alvo_id': 'c1d2e3f4-1111-4222-8333-444455556666', 'antes': {'estado': 'aberto'}, 'depois': {'estado': 'em_curso'}, 'criado_em': '2026-09-04T11:30:00Z'},
      {'id': 57, 'admin_id': _adm, 'acao': 'flag_editar', 'alvo_tipo': 'feature_flags', 'alvo_id': 'ia_perguntas', 'antes': {'limite_free': 3}, 'depois': {'limite_free': 5}, 'criado_em': '2026-09-03T10:00:00Z'},
      {'id': 56, 'admin_id': _adm, 'acao': 'usuario_trial', 'alvo_tipo': 'profiles', 'alvo_id': _u1, 'antes': {'trial_ate': '2026-09-21T00:00:00Z'}, 'depois': {'trial_ate': '2026-09-28T00:00:00Z'}, 'criado_em': '2026-09-02T09:00:00Z'},
    ],
    contactoParceiro: 'Contabilidade Guarda Lda · 271 000 000 · geral@contaguarda.pt',
  );
}

Widget moldura(int seccao, {DadosTeste? dados}) =>
    AdminMoldura(dados: AdminDados.paraTeste(dados ?? dadosExemplo()), seccao: seccao, aoEscolher: (_) {});

void main() {
  setUpAll(() async {
    await carregaFonteInter();
    await carregaFontesSdk();
  });

  testWidgets('admin_visao_geral: cartões e tabelas', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_visao_geral', tela: () => moldura(0));
    expect(find.text('148'), findsOneWidget);
    expect(find.text('Receita estimada / mês'), findsOneWidget);
    expect(find.textContaining('ALARME'), findsNothing);
  });

  testWidgets('admin_visao_geral_alarme: custo IA acima do limite', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_visao_geral_alarme', tela: () => moldura(0, dados: dadosExemplo(alarme: true)));
    expect(find.textContaining('ALARME'), findsOneWidget);
  });

  testWidgets('admin_usuarios: lista com pesquisa', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_usuarios', tela: () => moldura(1));
    expect(find.text('joao.tvde@gmail.com'), findsOneWidget);
    expect(find.text('banido'), findsOneWidget);
  });

  testWidgets('admin_usuario_detalhe: folha lateral com ações', (tester) async {
    await fotografaDesktop(
      tester,
      nome: 'admin_usuario_detalhe',
      tela: () => moldura(1),
      antes: (t) async {
        await t.tap(find.text('joao.tvde@gmail.com'));
        await t.pump(const Duration(milliseconds: 400));
      },
    );
    expect(find.text('Banir'), findsOneWidget);
    expect(find.text('Estender trial'), findsOneWidget);
  });

  testWidgets('admin_regras: tabela editável', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_regras', tela: () => moldura(2));
    expect(find.text('ias'), findsOneWidget);
    expect(find.text('por_confirmar'), findsOneWidget);
  });

  testWidgets('admin_regras_editar: folha lateral de edição', (tester) async {
    await fotografaDesktop(
      tester,
      nome: 'admin_regras_editar',
      tela: () => moldura(2),
      antes: (t) async {
        await t.tap(find.text('ias'));
        await t.pump(const Duration(milliseconds: 400));
      },
    );
    expect(find.text('Salvar'), findsOneWidget);
  });

  testWidgets('admin_regras_flags: cadeados por plano', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_regras_flags', tela: () => moldura(2), antes: (t) async {
      await t.tap(find.text('Cadeados por plano'));
      await t.pump(const Duration(milliseconds: 300));
    });
    expect(find.text('ia_perguntas'), findsOneWidget);
  });

  testWidgets('admin_tickets: filtros, tabela e contato do parceiro', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_tickets', tela: () => moldura(3));
    expect(find.text('A app fecha ao abrir o calendário'), findsOneWidget);
    expect(find.textContaining('contaguarda.pt'), findsOneWidget);
  });

  testWidgets('admin_ia: top perguntas, fora das regras, custo', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_ia', tela: () => moldura(4));
    expect(find.text('Perguntas mais feitas (top 30)'), findsOneWidget);
    expect(find.text('Criar guia'), findsWidgets);
  });

  testWidgets('admin_avisos: push, massa, e2e', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_avisos', tela: () => moldura(5));
    expect(find.text('Avisos em massa'), findsOneWidget);
  });

  testWidgets('admin_auditoria: log com filtros', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_auditoria', tela: () => moldura(6));
    expect(find.text('usuario_banir'), findsOneWidget);
  });

  testWidgets('admin_erro: leitura falhada mostra Aviso vermelho', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_erro', tela: () => moldura(0, dados: DadosTeste(erro: 'PostgrestException: permission denied for function admin_resumo')));
    expect(find.textContaining('Não consegui ler os dados'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('admin_vazio: sem tickets', (tester) async {
    await fotografaDesktop(tester, nome: 'admin_vazio', tela: () => moldura(3, dados: DadosTeste()));
    expect(find.text('Nada por aqui ainda.'), findsOneWidget);
  });
}
