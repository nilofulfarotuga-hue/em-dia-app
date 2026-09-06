/// Um guia de 1 minuto (tabela `guias`). O corpo é texto simples com
/// parágrafos, `#` títulos, `-` listas, `1.` passos e `**negrito**`.
class Guia {
  final String slug;
  final String titulo;
  final String? resumo;
  final String corpoPt;
  final String? corpoBr;
  final String? fonteUrl;
  final String? categoria;
  final int ordem;
  final DateTime? verificadoEm;

  const Guia({
    required this.slug,
    required this.titulo,
    this.resumo,
    required this.corpoPt,
    this.corpoBr,
    this.fonteUrl,
    this.categoria,
    this.ordem = 100,
    this.verificadoEm,
  });

  /// Corpo na variante do utilizador (BR só se existir).
  String corpo(String variante) => variante == 'br' && (corpoBr?.trim().isNotEmpty ?? false) ? corpoBr! : corpoPt;

  factory Guia.fromMap(Map<String, dynamic> m) => Guia(
        slug: m['slug'] as String,
        titulo: m['titulo'] as String,
        resumo: m['resumo'] as String?,
        corpoPt: (m['corpo_pt'] as String?) ?? '',
        corpoBr: m['corpo_br'] as String?,
        fonteUrl: m['fonte_url'] as String?,
        categoria: m['categoria'] as String?,
        ordem: (m['ordem'] as num?)?.toInt() ?? 100,
        verificadoEm: m['verificado_em'] == null ? null : DateTime.tryParse(m['verificado_em'].toString()),
      );
}
