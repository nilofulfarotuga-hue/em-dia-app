/// Uma fatura que chegou por e-mail à caixa da pessoa.
///
/// Quem a põe aqui é o servidor (`receber-fatura`), nunca a app: o telemóvel
/// só lê, marca e apaga. Ver a decisão D24 em `docs/DECISOES.md`.
class FaturaRecebida {
  final String id;
  final String remetente;
  final String? assunto;
  final DateTime recebidoEm;

  /// Caminho no balde privado `faturas`. Nulo quando o e-mail veio sem anexo
  /// que servisse — e aí [erro] diz porquê, em português.
  final String? anexoCaminho;
  final String? anexoNome;
  final int? anexoBytes;

  /// `nova` · `ligada` (já virou conta) · `ignorada` · `falhou`
  final String estado;
  final String? saidaId;
  final String? erro;

  const FaturaRecebida({
    required this.id,
    required this.remetente,
    required this.recebidoEm,
    required this.estado,
    this.assunto,
    this.anexoCaminho,
    this.anexoNome,
    this.anexoBytes,
    this.saidaId,
    this.erro,
  });

  bool get temAnexo => anexoCaminho != null;
  bool get porVer => estado == 'nova';

  /// Quem mandou, em curto: `faturas@edp.pt` → `edp.pt`. É o que a pessoa
  /// reconhece de relance; o endereço todo cabe no detalhe.
  String get deQuem {
    final arroba = remetente.indexOf('@');
    return arroba > 0 ? remetente.substring(arroba + 1) : remetente;
  }

  static FaturaRecebida daLinha(Map<String, dynamic> m) => FaturaRecebida(
        id: m['id'] as String,
        remetente: (m['remetente'] as String?) ?? '',
        assunto: m['assunto'] as String?,
        recebidoEm: DateTime.parse(m['recebido_em'] as String).toLocal(),
        anexoCaminho: m['anexo_caminho'] as String?,
        anexoNome: m['anexo_nome'] as String?,
        anexoBytes: (m['anexo_bytes'] as num?)?.toInt(),
        estado: (m['estado'] as String?) ?? 'nova',
        saidaId: m['saida_id'] as String?,
        erro: m['erro'] as String?,
      );
}
