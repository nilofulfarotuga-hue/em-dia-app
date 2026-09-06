/// Um movimento do cofre do imposto (tabela `cofre_movimentos`).
///
/// O cofre NÃO é uma conta bancária e não mexe em dinheiro nenhum: é o caderno
/// onde a pessoa aponta o que já pôs de lado para o Estado. Cada linha é uma
/// anotação — nunca uma transferência.
///
/// O sinal do [valor] diz tudo: **positivo pôs de lado, negativo tirou de lá**
/// (é assim que a coluna está definida na migração 0015, e é assim que o
/// `resumo_do_mes` soma o `no_cofre`).
///
/// Puro: sem Flutter, sem Supabase. Só dados e as duas conversões.
library;

import '../regras/regras.dart';

/// Os quatro valores que a coluna `motivo` aceita (há um `check` na tabela —
/// escrever outra coisa dá erro no servidor, não na app).
///
/// A app só escreve três deles: `guardar`, `pagar_imposto` e `tirar`. O
/// `acerto` existe para correções feitas do lado do servidor; a lista e o ecrã
/// têm de o saber mostrar na mesma, senão uma linha que não veio da app
/// aparecia sem nome.
const List<String> motivosCofre = ['guardar', 'pagar_imposto', 'tirar', 'acerto'];

/// A razão em palavras, do lado de cá.
///
/// **Porque não é isto a coluna `motivo`:** a pessoa quer distinguir "paguei a
/// Segurança Social" de "paguei o IRS", e a tabela tem um só valor para os
/// dois (`pagar_imposto`). Como as migrações não são desta tarefa, a diferença
/// vai na coluna livre `nota`, com um código curto e estável (`ss` / `irs`) em
/// vez de uma frase — uma frase ficava presa à língua em que foi escrita e
/// deixava de ser legível quando a pessoa trocasse de PT-PT para PT-BR.
///
/// Se um dia o `check` da tabela ganhar valores próprios, muda-se o [motivo]
/// de cada razão aqui e a `nota` deixa de ser precisa.
class RazaoCofre {
  /// Chave estável desta razão (é ela que o ecrã usa para escolher o texto).
  final String chave;

  /// O que vai para a coluna `motivo`.
  final String motivo;

  /// O que vai para a coluna `nota` (só quando é preciso separar duas razões
  /// que partilham o mesmo `motivo`).
  final String? nota;

  /// `true` põe dinheiro no cofre (valor positivo); `false` tira.
  final bool poe;

  const RazaoCofre({
    required this.chave,
    required this.motivo,
    this.nota,
    required this.poe,
  });
}

/// As quatro razões que a app oferece, pela ordem em que aparecem na folha.
///
/// A primeira é a única que põe dinheiro no cofre — as outras três tiram. É
/// por isso que a folha não tem um interruptor de "mais ou menos": o sinal sai
/// sempre da razão escolhida, e assim não há maneira de gravar um "guardei"
/// negativo por engano.
const List<RazaoCofre> razoesCofre = [
  RazaoCofre(chave: 'guardei', motivo: 'guardar', poe: true),
  RazaoCofre(chave: 'paguei_ss', motivo: 'pagar_imposto', nota: 'ss', poe: false),
  RazaoCofre(chave: 'paguei_irs', motivo: 'pagar_imposto', nota: 'irs', poe: false),
  RazaoCofre(chave: 'precisei', motivo: 'tirar', poe: false),
];

/// As razões que põem dinheiro no cofre / as que tiram, para a folha mostrar
/// só as que fazem sentido no botão por onde foi aberta.
List<RazaoCofre> razoesQuePoem() => razoesCofre.where((r) => r.poe).toList();
List<RazaoCofre> razoesQueTiram() => razoesCofre.where((r) => !r.poe).toList();

class CofreMovimento {
  final String id;
  final String userId;

  /// O dia em que a pessoa pôs (ou tirou) o dinheiro. Só a data, sem horas.
  final DateTime data;

  /// Positivo põe de lado, negativo tira de lá.
  final double valor;

  /// guardar | pagar_imposto | tirar | acerto
  final String motivo;

  /// Ligações opcionais a uma entrada ou a uma obrigação. A app ainda não as
  /// escreve — ficam aqui porque a tabela as tem e um dia o "guardar 23% deste
  /// recibo" vai querer dizer de onde veio o dinheiro.
  final String? entradaId;
  final String? obrigacaoId;

  /// Texto livre. Ver [RazaoCofre]: quando o motivo é `pagar_imposto`, guarda
  /// o código `ss` ou `irs`.
  final String? nota;

  const CofreMovimento({
    required this.id,
    required this.userId,
    required this.data,
    required this.valor,
    this.motivo = 'guardar',
    this.entradaId,
    this.obrigacaoId,
    this.nota,
  });

  /// Pôs de lado (em vez de ter tirado).
  bool get poe => valor >= 0;

  /// O valor sem sinal — é este que se mostra, com um "+" ou um "−" à frente.
  /// Mostrar "-50,00 €" numa linha que já diz "Paguei o IRS" era dizer a mesma
  /// coisa duas vezes com um sinal que ninguém lê.
  double get quantia => valor.abs();

  /// A razão desta linha, do lado de cá. A nulo quando o movimento não veio da
  /// app (um `acerto`, por exemplo) — o ecrã trata esse caso pelo [motivo].
  RazaoCofre? get razao {
    for (final r in razoesCofre) {
      if (r.motivo != motivo) continue;
      if (r.poe != poe) continue;
      // Duas razões partilham o motivo `pagar_imposto` e só a nota as separa.
      // Quando a linha NÃO tem nota nenhuma (veio de fora da app, ou de uma
      // versão anterior a esta), fica a primeira — a Segurança Social, que é a
      // mais comum. Exigir a nota aqui deixava essas linhas sem nome nenhum.
      if (r.nota != null && nota != null && r.nota != nota) continue;
      return r;
    }
    return null;
  }

  factory CofreMovimento.fromMap(Map<String, dynamic> m) => CofreMovimento(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        data: DateTime.parse(m['data'] as String),
        // `numeric` chega como texto no cliente do Supabase — daí o parse.
        valor: double.tryParse(m['valor'].toString()) ?? 0,
        motivo: (m['motivo'] as String?) ?? 'guardar',
        entradaId: m['entrada_id'] as String?,
        obrigacaoId: m['obrigacao_id'] as String?,
        nota: m['nota'] as String?,
      );

  Map<String, dynamic> toMap() => {
        // Sem id, o servidor gera um novo.
        if (id.isNotEmpty) 'id': id,
        'user_id': userId,
        'data': dataPtIso(data),
        'valor': valor,
        'motivo': motivo,
        'entrada_id': entradaId,
        'obrigacao_id': obrigacaoId,
        'nota': nota,
      };

  /// Constrói o movimento a partir do que a folha recolheu: a razão dá o
  /// motivo, a nota e o sinal; a pessoa só escreve o número, sempre positivo.
  factory CofreMovimento.doQueAPessoaEscreveu({
    required String userId,
    required DateTime data,
    required double quantia,
    required RazaoCofre razao,
  }) =>
      CofreMovimento(
        id: '',
        userId: userId,
        data: soDia(data),
        valor: centimos(razao.poe ? quantia.abs() : -quantia.abs()),
        motivo: razao.motivo,
        nota: razao.nota,
      );
}
