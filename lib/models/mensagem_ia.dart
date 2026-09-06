/// Uma mensagem do chat "Pergunta ao Em Dia" (Tela 7).
class MensagemIa {
  /// true = balão do utilizador (direita); false = balão do Em Dia (esquerda).
  final bool doUtilizador;
  final String texto;

  /// O servidor não tinha regra confirmada e pediu um guia novo.
  final bool foraDasRegras;
  final DateTime quando;

  MensagemIa({
    required this.doUtilizador,
    required this.texto,
    this.foraDasRegras = false,
    DateTime? quando,
  }) : quando = quando ?? DateTime.now();

  MensagemIa.utilizador(String texto, {DateTime? quando})
      : this(doUtilizador: true, texto: texto, quando: quando);

  MensagemIa.emDia(String texto, {bool foraDasRegras = false, DateTime? quando})
      : this(doUtilizador: false, texto: texto, foraDasRegras: foraDasRegras, quando: quando);
}
