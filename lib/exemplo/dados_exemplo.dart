/// O modo exemplo — «vê como fica» (B2f, 2026-09-18).
///
/// Uma pessoa inventada, a Maria, motorista TVDE há pouco mais de um ano, com
/// um carro, contas para pagar e um mês de trabalho já lançado. Tudo o que a
/// app mostra sai daqui; nada vem do servidor e nada fica guardado.
///
/// As obrigações NÃO são inventadas à mão: passam pelo mesmo gerador que
/// serve as contas reais (`gerarObrigacoes`, com as regras da tabela), para o
/// exemplo nunca contar uma história diferente da lei. A fatia do cofre também
/// sai da regra a sério (`fatiaParaOCofre`).
library;

import '../models/carro.dart';
import '../models/cofre_movimento.dart';
import '../models/entrada.dart';
import '../models/fidelizacao.dart';
import '../models/movimento_banco.dart';
import '../models/obrigacao.dart';
import '../models/perfil.dart';
import '../models/rendimento.dart';
import '../models/saida.dart';
import '../regras/carro.dart' show Combustivel;
import '../regras/cofre_automatico.dart';
import '../regras/datas.dart';
import '../regras/extrato_banco.dart' show normalizarDescricao;
import '../regras/obrigacoes.dart';
import '../regras/regras_legais.dart';
import '../regras/seguranca_social.dart';
import '../stores/perto_store.dart';
import '../stores/resumo_store.dart';

const String userIdExemplo = '00000000-0000-4000-8000-00000000e0e0';

/// Tudo o que as stores de exemplo precisam, já calculado para [hoje].
class DadosExemplo {
  final DateTime hoje;
  final Perfil perfil;
  final Carro carro;
  final List<Abastecimento> abastecimentos;
  final List<DespesaCarro> despesasCarro;
  final List<ObrigacaoItem> obrigacoes;
  final List<Rendimento> rendimentos;
  final List<Entrada> entradas;
  final List<Saida> saidas;
  final List<SaidaPagamento> pagamentos;
  final List<CofreMovimento> cofre;
  final List<Fidelizacao> fidelizacoes;
  final List<MovimentoBanco> movimentosBanco;
  final List<OperadorCancelar> operadores;
  final ResumoMes resumoMes;
  final ResumoAno resumoAno;
  final List<PostoPerto> postos;
  final List<CentroPerto> centros;

  const DadosExemplo._({
    required this.hoje,
    required this.perfil,
    required this.carro,
    required this.abastecimentos,
    required this.despesasCarro,
    required this.obrigacoes,
    required this.rendimentos,
    required this.entradas,
    required this.saidas,
    required this.pagamentos,
    required this.cofre,
    required this.fidelizacoes,
    required this.movimentosBanco,
    required this.operadores,
    required this.resumoMes,
    required this.resumoAno,
    required this.postos,
    required this.centros,
  });

  /// Monta o exemplo à volta de [hoje] (por omissão, o dia de hoje em Lisboa),
  /// com as regras [r] (as da tabela, se já vieram; senão as de fábrica).
  factory DadosExemplo.montar({DateTime? hoje, RegrasLegais? regras}) {
    final h = soDia(hoje ?? hojeLisboa());
    final r = regras ?? RegrasLegais.padrao2026();
    final abertura = adicionarMeses(h, -14); // já paga Segurança Social (1.º ano passou)

    final perfil = Perfil(
      userId: userIdExemplo,
      nome: 'Maria',
      tipoAtividade: TipoAtividade.tvde,
      dataAbertura: abertura,
      regimeIva: RegimeIva.isento53,
      tipoRendimento: TipoRendimento.servicos,
      rendimentoMensalEstimado: 1200,
      plano: 'free',
      trialAte: DateTime(h.year, h.month, h.day + 30),
      onboardingConcluido: true,
      viuGuiaInicio: true,
      criadoEm: abertura,
    );

    final carro = Carro(
      id: 'ex-carro',
      userId: userIdExemplo,
      nome: 'O meu carro',
      matricula: 'AB-12-CD',
      dataMatricula: DateTime(h.year - 5, 3, 15),
      usoTvde: true,
      combustivel: Combustivel.gasoleo,
      cilindradaCc: 1461,
      co2: 110,
      seguradora: 'Fidelidade',
      seguroRenovaEm: DateTime(h.year, h.month, h.day + 40),
      // A inspeção é anual (TVDE): a última foi no aniversário da matrícula
      // deste ano (ou do ano passado, se o aniversário ainda não chegou).
      ultimaIpo: DateTime(h.month > 3 || (h.month == 3 && h.day >= 15) ? h.year : h.year - 1, 3, 15),
      kmAtual: 148200,
      cartaValidade: DateTime(h.year + 3, 6, 30),
    );
    final abastecimentos = [
      Abastecimento(id: 'ex-ab1', carroId: carro.id, data: DateTime(h.year, h.month, h.day - 12), litros: 38.2, valorTotal: 62.4, km: 147600, posto: 'Plenergy Guarda', comNif: true),
      Abastecimento(id: 'ex-ab2', carroId: carro.id, data: DateTime(h.year, h.month, h.day - 5), litros: 35.0, valorTotal: 57.1, km: 148200, posto: 'Intermarché', comNif: true),
    ];
    final despesasCarro = [
      DespesaCarro(id: 'ex-dc1', carroId: carro.id, data: DateTime(h.year, h.month, h.day - 20), tipo: 'revisao', valor: 89.9, descricao: 'Mudança de óleo', comNif: true),
    ];

    // As obrigações, pelo gerador a sério (12 meses a contar de hoje).
    final geradas = gerarObrigacoes(perfil: perfil.paraObrigacoes, carros: [carro.paraObrigacoes!], hoje: h, r: r);
    final obrigacoes = <ObrigacaoItem>[];
    for (final (i, o) in geradas.indexed) {
      obrigacoes.add(ObrigacaoItem.fromMap({
        ...o.toMap(userIdExemplo),
        'id': 'ex-o-$i',
        'estado': 'pendente',
      }));
    }

    // Os últimos 6 meses fechados, com o rendimento à volta dos 1.200 €.
    const valores = [1180.0, 1240.0, 1310.0, 1150.0, 1290.0, 1220.0];
    final rendimentos = <Rendimento>[];
    for (var i = 1; i <= 6; i++) {
      final mes = adicionarMeses(DateTime(h.year, h.month, 1), -i);
      rendimentos.add(Rendimento(
        id: 'ex-r-$i',
        userId: userIdExemplo,
        mes: mes,
        valorBruto: valores[i - 1],
        tipo: 'servicos',
        origem: 'manual',
        plataforma: 'uber',
      ));
    }

    // O mês em curso, dia a dia, até hoje.
    final entradas = <Entrada>[];
    const dias = [
      (1, 'uber', 68.4, 62, 6.5),
      (2, 'bolt', 54.2, 48, 5.0),
      (4, 'uber', 91.1, 88, 8.0),
      (5, 'uber', 73.6, 70, 7.0),
      (7, 'bolt', 47.9, 41, 4.5),
      (9, 'uber', 82.3, 79, 7.5),
      (11, 'uber', 66.0, 60, 6.0),
      (13, 'bolt', 58.7, 52, 5.5),
      (15, 'uber', 95.4, 92, 8.5),
      (17, 'uber', 71.2, 66, 6.5),
      (19, 'bolt', 49.8, 44, 4.5),
      (22, 'uber', 88.0, 84, 8.0),
      (24, 'uber', 77.5, 73, 7.0),
      (26, 'bolt', 61.3, 55, 5.5),
      (28, 'uber', 84.9, 80, 7.5),
    ];
    for (final (dia, plat, valor, km, horas) in dias) {
      if (dia > h.day) break;
      entradas.add(Entrada(
        id: 'ex-e-$dia',
        userId: userIdExemplo,
        data: DateTime(h.year, h.month, dia),
        valor: valor,
        tipo: 'plataforma',
        plataforma: plat,
        periodo: 'dia',
        km: km,
        horas: horas,
      ));
    }

    // As contas de todos os meses.
    final saidas = [
      Saida(id: 'ex-s-renda', userId: userIdExemplo, nome: 'Renda da casa', categoria: 'renda', valor: 450, diaDoMes: 1, meio: 'transferencia'),
      Saida(id: 'ex-s-meo', userId: userIdExemplo, nome: 'MEO (net + TV)', categoria: 'internet', valor: 32.99, diaDoMes: 8, meio: 'debito_direto', fornecedor: 'MEO', fimFidelizacao: DateTime(h.year, h.month, h.day + 45)),
      Saida(id: 'ex-s-tlm', userId: userIdExemplo, nome: 'Telemóvel Vodafone', categoria: 'telemovel', valor: 15, diaDoMes: 12, meio: 'debito_direto', fornecedor: 'Vodafone'),
      Saida(id: 'ex-s-seguro', userId: userIdExemplo, nome: 'Seguro do carro', categoria: 'seguro', valor: 38.5, diaDoMes: 15, meio: 'debito_direto', fornecedor: 'Fidelidade'),
      Saida(id: 'ex-s-gym', userId: userIdExemplo, nome: 'Ginásio', categoria: 'ginasio', valor: 29.9, diaDoMes: 10, meio: 'debito_direto', fornecedor: 'Fitness Hut', fimFidelizacao: DateTime(h.year, h.month, h.day + 200)),
      Saida(id: 'ex-s-netflix', userId: userIdExemplo, nome: 'Netflix', categoria: 'assinatura', valor: 7.99, diaDoMes: 20, meio: 'cartao', fornecedor: 'Netflix'),
      Saida(id: 'ex-s-luz', userId: userIdExemplo, nome: 'Luz EDP', categoria: 'luz', valor: 41, variavel: true, diaDoMes: 18, meio: 'debito_direto', fornecedor: 'EDP'),
    ];
    final pagamentos = <SaidaPagamento>[];
    for (final s in saidas) {
      final limite = DateTime(h.year, h.month, s.diaDoMes);
      final passou = limite.isBefore(h);
      pagamentos.add(SaidaPagamento(
        id: 'ex-p-${s.id}',
        userId: userIdExemplo,
        saidaId: s.id,
        mes: DateTime(h.year, h.month, 1),
        dataLimite: limite,
        valor: s.valor,
        estado: passou ? 'pago' : 'pendente',
        pagoEm: passou ? limite : null,
      ));
    }

    // O cofre automático: a fatia de cada dia de trabalho, pela regra a sério.
    final cofre = <CofreMovimento>[];
    for (final e in entradas) {
      final fatia = fatiaParaOCofre(
        valor: e.valor,
        data: e.data,
        tipo: TipoRendimento.servicos,
        rendimentoAnualEstimado: 1200 * 12,
        dataAbertura: abertura,
        regras: r,
      );
      if (fatia.total <= 0) continue;
      cofre.add(CofreMovimento(
        id: 'ex-c-${e.id}',
        userId: userIdExemplo,
        data: e.data,
        valor: fatia.total,
        motivo: 'guardar',
        entradaId: e.id,
        nota: 'auto',
      ));
    }

    final fidelizacoes = [
      for (final s in saidas)
        if (s.fimFidelizacao != null)
          Fidelizacao(
            saidaId: s.id,
            nome: s.nome,
            categoria: s.categoria,
            fimFidelizacao: s.fimFidelizacao!,
            diasParaAcabar: s.fimFidelizacao!.difference(h).inDays,
            fornecedor: s.fornecedor,
            valorMensal: s.valor,
          ),
    ];

    // Três meses de extrato, só com o que se repete (para o ecrã «Pagas X por mês»).
    final movimentos = <MovimentoBanco>[];
    for (var i = 1; i <= 3; i++) {
      final mes = adicionarMeses(DateTime(h.year, h.month, 1), -i);
      void mov(String descricao, double valor, int dia, String categoria, String? fornecedor) {
        final data = DateTime(mes.year, mes.month, dia);
        movimentos.add(MovimentoBanco(
          id: 'ex-m-$i-${movimentos.length}',
          userId: userIdExemplo,
          data: data,
          descricao: descricao,
          valor: valor,
          banco: 'Exemplo',
          categoria: categoria,
          fornecedor: fornecedor,
          recorrente: true,
          chave: '${dataPtIso(data)}|${valor.toStringAsFixed(2)}|${normalizarDescricao(descricao)}',
        ));
      }

      mov('DD MEO SA', -32.99, 8, 'internet', 'MEO');
      mov('DD VODAFONE PORTUGAL', -15.00, 12, 'telemovel', 'Vodafone');
      mov('COMPRA NETFLIX.COM', -7.99, 20, 'assinatura', 'Netflix');
      mov('DD FITNESS HUT', -29.90, 10, 'ginasio', 'Fitness Hut');
      mov('DD FIDELIDADE SEGUROS', -38.50, 15, 'seguro', 'Fidelidade');
    }
    const operadores = [
      OperadorCancelar(chave: 'meo', nome: 'MEO', categoria: 'internet', comoCancelar: 'Na app MEO ou em my.meo.pt → Perfil → Mensagens → Abrir pedido. Por telefone: 16200.', url: 'https://my.meo.pt/perfil/mensagens/abrir-pedido', telefone: '16200'),
      OperadorCancelar(chave: 'vodafone', nome: 'Vodafone', categoria: 'telemovel', comoCancelar: 'Na app My Vodafone ou por telefone: 16912.', url: 'https://ajuda.vodafone.pt/', telefone: '16912'),
      OperadorCancelar(chave: 'netflix', nome: 'Netflix', categoria: 'assinatura', comoCancelar: 'Em netflix.com → Conta → Cancelar subscrição. Fica ativa até ao fim do período pago.', url: 'https://www.netflix.com/cancelplan'),
      OperadorCancelar(chave: 'fitness_hut', nome: 'Fitness Hut', categoria: 'ginasio', comoCancelar: 'Por escrito ao ginásio (e-mail ou na receção), com o pré-aviso do contrato — normalmente 30 dias.'),
    ];

    // As contas do mês e do ano, como o servidor as faria.
    final entrou = entradas.fold<double>(0, (t, e) => t + e.valor);
    final saiu = pagamentos.where((p) => p.estado == 'pago').fold<double>(0, (t, p) => t + (p.valor ?? 0));
    final faltaContas = pagamentos.where((p) => p.estado != 'pago').fold<double>(0, (t, p) => t + (p.valor ?? 0));
    final faltaEstado = obrigacoes
        .where((o) => o.prazoEfetivo.year == h.year && o.prazoEfetivo.month == h.month && o.prazoEfetivo.day >= h.day)
        .fold<double>(0, (t, o) => t + (o.valorEstimado ?? 0));
    final noCofre = cofre.fold<double>(0, (t, c) => t + c.valor);
    final resumoMes = ResumoMes(
      mes: DateTime(h.year, h.month, 1),
      entrou: entrou,
      saiu: saiu,
      faltaPagarContas: faltaContas,
      faltaPagarEstado: faltaEstado,
      comoAcabaOMes: entrou - saiu - faltaContas - faltaEstado,
      noCofre: noCofre,
    );
    final porMes = List<double>.filled(12, 0);
    for (final rd in rendimentos) {
      if (rd.mes.year == h.year) porMes[rd.mes.month - 1] += rd.valorBruto;
    }
    porMes[h.month - 1] += entrou;
    final entrouAno = porMes.fold<double>(0, (t, v) => t + v);
    final resumoAno = ResumoAno(
      ano: h.year,
      entrouTotal: entrouAno,
      entrouParaIrs: entrouAno,
      porTipo: {'plataforma': entrouAno},
      porMes: porMes,
      saiuTotal: saiu + saidas.fold<double>(0, (t, s) => t + (s.valor ?? 0)) * (h.month - 1),
    );

    // «Perto de mim» com os números reais da Guarda a 18/09/2026 (DGEG/IMT).
    const postos = [
      PostoPerto(id: 1, nome: 'PLENERGY Guarda Gare I', marca: 'PLENERGY', localidade: 'Guarda', municipio: 'Guarda', lat: 40.52, lng: -7.27, combustivel: 'Gasóleo simples', preco: 2.035, distanciaKm: 2.7),
      PostoPerto(id: 2, nome: 'PA Arrifana - Guarda', marca: 'PA', localidade: 'Arrifana', municipio: 'Guarda', lat: 40.50, lng: -7.30, combustivel: 'Gasóleo simples', preco: 2.065, distanciaKm: 7.2),
      PostoPerto(id: 3, nome: 'INTERMARCHÉ DA GUARDA', marca: 'INTERMARCHÉ', localidade: 'Guarda', municipio: 'Guarda', lat: 40.54, lng: -7.25, combustivel: 'Gasóleo simples', preco: 2.079, distanciaKm: 1.7),
    ];
    const centros = [
      CentroPerto(codigo: '1', nome: 'CIMA - GUARDA', localidade: 'GUARDA', distrito: 'Guarda', lat: 40.54, lng: -7.26, distanciaKm: 2.0),
      CentroPerto(codigo: '2', nome: 'BETOREL - GUARDA', localidade: 'SÃO MIGUEL DA GUARDA', distrito: 'Guarda', lat: 40.55, lng: -7.28, distanciaKm: 2.5),
    ];

    return DadosExemplo._(
      hoje: h,
      perfil: perfil,
      carro: carro,
      abastecimentos: abastecimentos,
      despesasCarro: despesasCarro,
      obrigacoes: obrigacoes,
      rendimentos: rendimentos,
      entradas: entradas,
      saidas: saidas,
      pagamentos: pagamentos,
      cofre: cofre,
      fidelizacoes: fidelizacoes,
      movimentosBanco: movimentos,
      operadores: operadores,
      resumoMes: resumoMes,
      resumoAno: resumoAno,
      postos: postos,
      centros: centros,
    );
  }
}
