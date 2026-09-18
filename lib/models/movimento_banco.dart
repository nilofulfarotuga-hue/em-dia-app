/// Um movimento importado do extrato do banco (tabela `movimentos_banco`) e
/// uma linha de «como cancelar» (tabela `operadores_cancelar`).
///
/// Puro: sem Flutter, sem Supabase. A leitura do ficheiro está em
/// `lib/regras/extrato_banco.dart`; a store em `lib/stores/banco_store.dart`.
library;

import '../regras/extrato_banco.dart';

class MovimentoBanco {
  final String id;
  final String userId;
  final DateTime data;
  final String descricao;

  /// Positivo entrou, negativo saiu.
  final double valor;
  final double? saldo;
  final String? banco;
  final String categoria;
  final String? fornecedor;
  final bool recorrente;
  final String? entradaId;
  final String? saidaId;
  final String? importacaoId;
  final String chave;

  const MovimentoBanco({
    required this.id,
    required this.userId,
    required this.data,
    required this.descricao,
    required this.valor,
    this.saldo,
    this.banco,
    this.categoria = 'outro',
    this.fornecedor,
    this.recorrente = false,
    this.entradaId,
    this.saidaId,
    this.importacaoId,
    required this.chave,
  });

  bool get entra => valor > 0;

  /// O movimento tal como o leitor o devolve (para juntar o que se repete).
  MovimentoLido get lido => MovimentoLido(data: data, descricao: descricao, valor: valor, saldo: saldo);

  factory MovimentoBanco.fromMap(Map<String, dynamic> m) => MovimentoBanco(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        data: DateTime.parse(m['data'] as String),
        descricao: (m['descricao'] as String?) ?? '',
        valor: double.tryParse(m['valor'].toString()) ?? 0,
        saldo: m['saldo'] == null ? null : double.tryParse(m['saldo'].toString()),
        banco: m['banco'] as String?,
        categoria: (m['categoria'] as String?) ?? 'outro',
        fornecedor: m['fornecedor'] as String?,
        recorrente: m['recorrente'] == true,
        entradaId: m['entrada_id'] as String?,
        saidaId: m['saida_id'] as String?,
        importacaoId: m['importacao_id'] as String?,
        chave: (m['chave'] as String?) ?? '',
      );

  /// A linha para gravar, a partir de um movimento lido do ficheiro.
  static Map<String, dynamic> paraGravar({
    required String userId,
    required MovimentoLido m,
    required String categoria,
    String? fornecedor,
    required bool recorrente,
    String? banco,
    String? importacaoId,
  }) =>
      {
        'user_id': userId,
        'data': _iso(m.data),
        'descricao': m.descricao,
        'valor': m.valor,
        'saldo': m.saldo,
        'banco': banco,
        'categoria': categoria,
        'fornecedor': fornecedor,
        'recorrente': recorrente,
        'importacao_id': importacaoId,
        'chave': m.chave,
      };

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

/// «Como cancelar» de um operador (tabela `operadores_cancelar`).
class OperadorCancelar {
  final String chave;
  final String nome;
  final String categoria;
  final String comoCancelar;
  final String? url;
  final String? telefone;
  final String? fonteUrl;

  const OperadorCancelar({
    required this.chave,
    required this.nome,
    required this.categoria,
    required this.comoCancelar,
    this.url,
    this.telefone,
    this.fonteUrl,
  });

  factory OperadorCancelar.fromMap(Map<String, dynamic> m) => OperadorCancelar(
        chave: m['chave'] as String,
        nome: (m['nome'] as String?) ?? '',
        categoria: (m['categoria'] as String?) ?? 'outro',
        comoCancelar: (m['como_cancelar'] as String?) ?? '',
        url: m['url'] as String?,
        telefone: m['telefone'] as String?,
        fonteUrl: m['fonte_url'] as String?,
      );

  /// Encontra o operador de um fornecedor/descrição («MEO» → meo; «Netflix» → netflix).
  static OperadorCancelar? para(List<OperadorCancelar> lista, {String? fornecedor, String? descricao}) {
    final alvo = normalizarDescricao('${fornecedor ?? ''} ${descricao ?? ''}');
    for (final o in lista) {
      if (o.chave == 'generico') continue;
      final nome = normalizarDescricao(o.nome);
      if (alvo.contains(nome) || alvo.contains(o.chave.replaceAll('_', ' '))) return o;
    }
    return null;
  }

  static OperadorCancelar? generico(List<OperadorCancelar> lista) {
    for (final o in lista) {
      if (o.chave == 'generico') return o;
    }
    return null;
  }
}
