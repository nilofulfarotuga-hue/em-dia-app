/// O radar da fidelização: quando é que cada contrato preso te larga.
///
/// Fidelização é o tempo em que a pessoa não pode sair do contrato sem pagar
/// multa — 24 meses no telemóvel, na internet, no ginásio. Quando esse tempo
/// acaba, a empresa costuma renovar em silêncio, já com o preço mais alto.
/// Quem sabe a data tem duas semanas para ligar e negociar; quem não sabe,
/// paga mais um ano.
///
/// As linhas vêm inteiras do servidor (`radar_fidelizacao`), **incluindo os
/// dias que faltam**. É de propósito: quem conta os dias é o Postgres, com a
/// data de Lisboa. Contar aqui dava um número diferente a quem tem o telemóvel
/// noutro fuso ou com a hora trocada — e o número que aparece no ecrã é
/// exactamente o que decide se a pessoa ainda vai a tempo.
library;

import '../regras/regras.dart';

/// Em que ponto está a fidelização deste contrato.
///
/// São cinco e não dois porque as palavras do ecrã são cinco: "acabou há 5
/// dias", "acabou ontem", "acaba hoje", "acaba amanhã", "faltam 12 dias".
/// Um "há 1 dias" ou um "faltam 0 dias" seria a app a falar como máquina.
enum MomentoFidelizacao { acabou, ontem, hoje, amanha, faltam }

/// Uma linha do radar: um contrato preso e a data em que te larga.
class Fidelizacao {
  final String saidaId;
  final String nome;
  final String categoria;

  /// Quem é a empresa. A nulo quando a pessoa não a escreveu — a app diz isso
  /// em vez de inventar um nome.
  final String? fornecedor;

  final DateTime fimFidelizacao;

  /// Quantos dias faltam. **Negativo quer dizer que já acabou** — e essas
  /// linhas continuam a aparecer, porque um contrato que acabou há pouco é
  /// exactamente aquele que ainda dá para renegociar.
  final int diasParaAcabar;

  /// Quanto se paga por mês. A nulo nas contas de valor variável ou quando
  /// ninguém escreveu o valor.
  final double? valorMensal;

  const Fidelizacao({
    required this.saidaId,
    required this.nome,
    required this.categoria,
    required this.fimFidelizacao,
    required this.diasParaAcabar,
    this.fornecedor,
    this.valorMensal,
  });

  bool get jaAcabou => diasParaAcabar < 0;

  /// Quantos dias passaram desde que acabou (sempre positivo). Só faz sentido
  /// quando [jaAcabou].
  int get diasDesdeQueAcabou => diasParaAcabar.abs();

  /// A distância a hoje, para os dois lados. É por este número que se escolhe
  /// a linha em destaque quando já não há nenhuma no futuro.
  int get distanciaAHoje => diasParaAcabar.abs();

  MomentoFidelizacao get momento {
    if (diasParaAcabar < -1) return MomentoFidelizacao.acabou;
    if (diasParaAcabar == -1) return MomentoFidelizacao.ontem;
    if (diasParaAcabar == 0) return MomentoFidelizacao.hoje;
    if (diasParaAcabar == 1) return MomentoFidelizacao.amanha;
    return MomentoFidelizacao.faltam;
  }

  /// Uma linha devolvida por `radar_fidelizacao`.
  ///
  /// O `valor_mensal` é `numeric` no Postgres e chega como texto no cliente do
  /// Supabase — por isso passa pelo [double.tryParse] e não por um cast.
  factory Fidelizacao.daLinha(Map<String, dynamic> m, {DateTime? hoje}) {
    final fim = DateTime.parse(m['fim_fidelizacao'].toString());
    return Fidelizacao(
      saidaId: m['saida_id'].toString(),
      nome: (m['nome'] as String?) ?? '',
      categoria: (m['categoria'] as String?) ?? 'outro',
      fornecedor: _limpo(m['fornecedor'] as String?),
      fimFidelizacao: soDia(fim),
      // Se um dia a coluna deixar de vir, conta-se aqui pela mesma regra (dias
      // inteiros até à data, em Lisboa) em vez de mostrar zero e mentir.
      diasParaAcabar:
          (m['dias_para_acabar'] as num?)?.toInt() ?? diasAte(fim, hoje ?? hojeLisboa()),
      valorMensal:
          m['valor_mensal'] == null ? null : double.tryParse(m['valor_mensal'].toString()),
    );
  }

  /// Um texto vazio ou só com espaços é o mesmo que não ter nada escrito.
  static String? _limpo(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}
