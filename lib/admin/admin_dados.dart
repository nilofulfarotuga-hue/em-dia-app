// Camada de dados do painel admin. Tudo o que o painel lê e escreve passa
// por aqui: o construtor normal fala com o Supabase (`sb`); `paraTeste` responde
// de listas em memória (fotos golden sem servidor). Cada escrita regista uma
// linha em `admin_audit_log` (admin_id, acao, alvo_tipo, alvo_id, antes, depois).
import 'dart:convert';

import 'package:csv/csv.dart';

import '../services/arranque.dart';

typedef Linha = Map<String, dynamic>;

/// Números da visão geral (vêm da RPC `admin_resumo`, nunca de constantes).
class ResumoAdmin {
  final int usuariosTotal;
  final int usuariosAtivos7d;
  final Map<String, int> planos; // trial | free | pro | familia
  final double receitaMensalEur;
  final int assinaturasAtivas;
  final int ticketsAbertos;
  final int ticketsEscalados;
  final int obrigacoesPassadas;
  final double? alarmeEur; // regras_legais.ia_custo_alarme_dia_eur
  final List<Linha> custoIa; // [{dia, conversas, custo_eur}] últimos 7 dias, mais recente primeiro
  final Map<String, int> pushHoje; // resultado → n
  final DateTime hoje;

  const ResumoAdmin({
    required this.usuariosTotal,
    required this.usuariosAtivos7d,
    required this.planos,
    required this.receitaMensalEur,
    required this.assinaturasAtivas,
    required this.ticketsAbertos,
    required this.ticketsEscalados,
    required this.obrigacoesPassadas,
    required this.alarmeEur,
    required this.custoIa,
    required this.pushHoje,
    required this.hoje,
  });

  double get custoIaHoje {
    final h = _dia(hoje);
    for (final l in custoIa) {
      if ((l['dia'] as String?) == h) return _num(l['custo_eur']).toDouble();
    }
    return 0;
  }

  double get custoIa7d => custoIa.fold(0.0, (s, l) => s + _num(l['custo_eur']));
  int get conversas7d => custoIa.fold(0, (s, l) => s + _num(l['conversas']).toInt());
  bool get alarme => alarmeEur != null && custoIaHoje > alarmeEur!;

  factory ResumoAdmin.fromMap(Linha m) {
    final planos = <String, int>{};
    ((m['planos'] as Map?) ?? {}).forEach((k, v) => planos[k.toString()] = _num(v).toInt());
    final push = <String, int>{};
    for (final e in (m['push_hoje'] as List?) ?? const []) {
      final mm = Map<String, dynamic>.from(e as Map);
      push[(mm['resultado'] ?? 'pendente').toString()] = _num(mm['n']).toInt();
    }
    return ResumoAdmin(
      usuariosTotal: _num(m['usuarios_total']).toInt(),
      usuariosAtivos7d: _num(m['usuarios_ativos_7d']).toInt(),
      planos: planos,
      receitaMensalEur: _num(m['receita_mensal_eur']).toDouble(),
      assinaturasAtivas: _num(m['assinaturas_ativas']).toInt(),
      ticketsAbertos: _num(m['tickets_abertos']).toInt(),
      ticketsEscalados: _num(m['tickets_escalados']).toInt(),
      obrigacoesPassadas: _num(m['obrigacoes_passadas']).toInt(),
      alarmeEur: m['alarme_eur'] == null ? null : _num(m['alarme_eur']).toDouble(),
      custoIa: ((m['custo_ia'] as List?) ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList(),
      pushHoje: push,
      hoje: DateTime.tryParse((m['hoje'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}

/// Uma linha da view `v_admin_usuarios`.
class UsuarioAdmin {
  final String userId;
  final String? email;
  final String? nome;
  final String? telefone;
  final String tipoAtividade;
  final String plano; // profiles.plano (manual)
  final String planoEfetivo; // trial | free | pro | familia
  final DateTime? trialAte;
  final DateTime? ultimoAcesso;
  final bool banido;
  final DateTime? criadoEm;
  final String variantePt;
  final bool onboardingConcluido;

  const UsuarioAdmin({
    required this.userId,
    this.email,
    this.nome,
    this.telefone,
    this.tipoAtividade = 'sem_atividade',
    this.plano = 'free',
    this.planoEfetivo = 'free',
    this.trialAte,
    this.ultimoAcesso,
    this.banido = false,
    this.criadoEm,
    this.variantePt = 'pt',
    this.onboardingConcluido = false,
  });

  factory UsuarioAdmin.fromMap(Linha m) => UsuarioAdmin(
        userId: m['user_id'] as String,
        email: m['email'] as String?,
        nome: m['nome'] as String?,
        telefone: m['telefone'] as String?,
        tipoAtividade: (m['tipo_atividade'] as String?) ?? 'sem_atividade',
        plano: (m['plano'] as String?) ?? 'free',
        planoEfetivo: (m['plano_efetivo'] as String?) ?? 'free',
        trialAte: _data(m['trial_ate']),
        ultimoAcesso: _data(m['ultimo_acesso']),
        banido: m['banido'] == true,
        criadoEm: _data(m['criado_em']),
        variantePt: (m['variante_pt'] as String?) ?? 'pt',
        onboardingConcluido: m['onboarding_concluido'] == true,
      );

  Linha toMap() => {
        'user_id': userId,
        'email': email,
        'nome': nome,
        'telefone': telefone,
        'tipo_atividade': tipoAtividade,
        'plano': plano,
        'plano_efetivo': planoEfetivo,
        'trial_ate': trialAte?.toIso8601String(),
        'ultimo_acesso': ultimoAcesso?.toIso8601String(),
        'banido': banido,
        'criado_em': criadoEm?.toIso8601String(),
        'variante_pt': variantePt,
        'onboarding_concluido': onboardingConcluido,
      };

  UsuarioAdmin copyWith({String? plano, String? planoEfetivo, DateTime? trialAte, bool? banido}) => UsuarioAdmin(
        userId: userId,
        email: email,
        nome: nome,
        telefone: telefone,
        tipoAtividade: tipoAtividade,
        plano: plano ?? this.plano,
        planoEfetivo: planoEfetivo ?? this.planoEfetivo,
        trialAte: trialAte ?? this.trialAte,
        ultimoAcesso: ultimoAcesso,
        banido: banido ?? this.banido,
        criadoEm: criadoEm,
        variantePt: variantePt,
        onboardingConcluido: onboardingConcluido,
      );
}

/// Tudo o que o detalhe de um utilizador mostra.
class DetalheUsuario {
  final Linha perfil;
  final List<Linha> obrigacoes;
  final List<Linha> rendimentos;
  final List<Linha> assinaturas;
  final List<Linha> conversas;
  const DetalheUsuario({
    required this.perfil,
    required this.obrigacoes,
    required this.rendimentos,
    required this.assinaturas,
    required this.conversas,
  });
}

/// Dados de exemplo para as fotos (golden) e para o modo sem servidor.
class DadosTeste {
  final ResumoAdmin? resumo;
  final List<UsuarioAdmin> usuarios;
  final Map<String, DetalheUsuario> detalhes;
  final List<Linha> regras;
  final List<Linha> escaloes;
  final List<Linha> flags;
  final List<Linha> tickets;
  final List<Linha> topPerguntas;
  final List<Linha> foraDasRegras;
  final List<Linha> custoIa;
  final List<Linha> eventosPush;
  final List<Linha> avisosMassa;
  final List<Linha> e2eLog;
  final List<Linha> auditoria;
  final String? contactoParceiro;
  final String? erro;

  DadosTeste({
    this.resumo,
    this.usuarios = const [],
    this.detalhes = const {},
    this.regras = const [],
    this.escaloes = const [],
    this.flags = const [],
    this.tickets = const [],
    this.topPerguntas = const [],
    this.foraDasRegras = const [],
    this.custoIa = const [],
    this.eventosPush = const [],
    this.avisosMassa = const [],
    this.e2eLog = const [],
    this.auditoria = const [],
    this.contactoParceiro,
    this.erro,
  });
}

class AdminDados {
  final DadosTeste? _t;
  // Cópias mutáveis para o modo de teste (as ações escrevem aqui).
  late final List<UsuarioAdmin> _usuarios;
  late final List<Linha> _regras;
  late final List<Linha> _escaloes;
  late final List<Linha> _flags;
  late final List<Linha> _tickets;
  late final List<Linha> _avisosMassa;
  late final List<Linha> _auditoria;
  String? _contactoParceiro;

  /// Modo real: fala com o Supabase.
  AdminDados() : _t = null;

  /// Modo de teste: responde de memória, sem servidor. Se [DadosTeste.erro]
  /// vier preenchido, todas as leituras falham com esse texto (foto do estado de erro).
  AdminDados.paraTeste(DadosTeste t) : _t = t {
    _usuarios = List.of(t.usuarios);
    _regras = t.regras.map((m) => Map<String, dynamic>.from(m)).toList();
    _escaloes = t.escaloes.map((m) => Map<String, dynamic>.from(m)).toList();
    _flags = t.flags.map((m) => Map<String, dynamic>.from(m)).toList();
    _tickets = t.tickets.map((m) => Map<String, dynamic>.from(m)).toList();
    _avisosMassa = t.avisosMassa.map((m) => Map<String, dynamic>.from(m)).toList();
    _auditoria = t.auditoria.map((m) => Map<String, dynamic>.from(m)).toList();
    _contactoParceiro = t.contactoParceiro;
  }

  bool get emTeste => _t != null;

  void _falhaSePedido() {
    final e = _t?.erro;
    if (e != null) throw StateError(e);
  }

  String? get _adminId => emTeste ? '00000000-0000-4000-8000-00000000adm1' : sb.auth.currentUser?.id;

  // ---------------------------------------------------------------- auditoria
  Future<void> _registar(String acao, {String? alvoTipo, String? alvoId, Linha? antes, Linha? depois}) async {
    final linha = <String, dynamic>{
      'admin_id': _adminId,
      'acao': acao,
      'alvo_tipo': alvoTipo,
      'alvo_id': alvoId,
      'antes': antes,
      'depois': depois,
    };
    if (emTeste) {
      _auditoria.insert(0, {...linha, 'id': _auditoria.length + 1, 'criado_em': DateTime.now().toIso8601String()});
      return;
    }
    await sb.from('admin_audit_log').insert(linha);
  }

  Future<List<Linha>> auditoria({String? acao, String? alvoTipo, int limite = 300}) async {
    if (emTeste) {
      _falhaSePedido();
      return _auditoria
          .where((l) => (acao == null || acao.isEmpty || (l['acao'] ?? '').toString().contains(acao)) &&
              (alvoTipo == null || alvoTipo.isEmpty || l['alvo_tipo'] == alvoTipo))
          .take(limite)
          .toList();
    }
    var q = sb.from('admin_audit_log').select();
    if (acao != null && acao.isNotEmpty) q = q.ilike('acao', '%$acao%');
    if (alvoTipo != null && alvoTipo.isNotEmpty) q = q.eq('alvo_tipo', alvoTipo);
    final rows = await q.order('criado_em', ascending: false).limit(limite);
    return _linhas(rows);
  }

  // ---------------------------------------------------------------- visão geral
  Future<ResumoAdmin> resumo() async {
    if (emTeste) {
      _falhaSePedido();
      return _t!.resumo!;
    }
    final r = await sb.rpc('admin_resumo');
    return ResumoAdmin.fromMap(Map<String, dynamic>.from(r as Map));
  }

  // ---------------------------------------------------------------- usuários
  Future<List<UsuarioAdmin>> usuarios({String pesquisa = '', int limite = 500}) async {
    final p = pesquisa.trim().toLowerCase();
    if (emTeste) {
      _falhaSePedido();
      return _usuarios
          .where((u) => p.isEmpty || (u.email ?? '').toLowerCase().contains(p) || (u.nome ?? '').toLowerCase().contains(p))
          .toList();
    }
    var q = sb.from('v_admin_usuarios').select();
    if (p.isNotEmpty) q = q.or('email.ilike.%$p%,nome.ilike.%$p%');
    final rows = await q.order('criado_em', ascending: false).limit(limite);
    return _linhas(rows).map(UsuarioAdmin.fromMap).toList();
  }

  Future<DetalheUsuario> detalheUsuario(String userId) async {
    if (emTeste) {
      _falhaSePedido();
      final u = _usuarios.firstWhere((u) => u.userId == userId);
      return _t!.detalhes[userId] ??
          DetalheUsuario(perfil: u.toMap(), obrigacoes: const [], rendimentos: const [], assinaturas: const [], conversas: const []);
    }
    final perfil = await sb.from('profiles').select().eq('user_id', userId).single();
    final obrigacoes = await sb.from('obrigacoes').select().eq('user_id', userId).order('data_limite', ascending: true).limit(60);
    final rendimentos = await sb.from('rendimentos').select().eq('user_id', userId).order('mes', ascending: false).limit(24);
    final assinaturas = await sb.from('assinaturas').select().eq('user_id', userId).order('criado_em', ascending: false).limit(20);
    final conversas = await sb
        .from('conversas_ia')
        .select('id,pergunta,resposta,variante,modo,fora_das_regras,custo_tokens,criado_em')
        .eq('user_id', userId)
        .order('criado_em', ascending: false)
        .limit(10);
    return DetalheUsuario(
      perfil: Map<String, dynamic>.from(perfil),
      obrigacoes: _linhas(obrigacoes),
      rendimentos: _linhas(rendimentos),
      assinaturas: _linhas(assinaturas),
      conversas: _linhas(conversas),
    );
  }

  Future<void> _atualizarPerfil(UsuarioAdmin u, String acao, Linha campos) async {
    final antes = {for (final k in campos.keys) k: u.toMap()[k]};
    if (emTeste) {
      final i = _usuarios.indexWhere((x) => x.userId == u.userId);
      if (i >= 0) {
        _usuarios[i] = _usuarios[i].copyWith(
          plano: campos['plano'] as String?,
          banido: campos['banido'] as bool?,
          trialAte: campos['trial_ate'] == null ? null : DateTime.parse(campos['trial_ate'] as String),
        );
      }
    } else {
      await sb.from('profiles').update(campos).eq('user_id', u.userId);
    }
    await _registar(acao, alvoTipo: 'profiles', alvoId: u.userId, antes: antes, depois: campos);
  }

  Future<void> banir(UsuarioAdmin u, bool banido) =>
      _atualizarPerfil(u, banido ? 'usuario_banir' : 'usuario_reativar', {'banido': banido});

  Future<void> alterarPlano(UsuarioAdmin u, String plano) => _atualizarPerfil(u, 'usuario_plano', {'plano': plano});

  Future<void> estenderTrial(UsuarioAdmin u, DateTime ate) =>
      _atualizarPerfil(u, 'usuario_trial', {'trial_ate': ate.toUtc().toIso8601String()});

  /// Apagar a conta de verdade (auth.users) precisa da service role — fica
  /// marcado como banido e registado; o servidor apaga depois.
  Future<void> pedirApagarConta(UsuarioAdmin u) =>
      _atualizarPerfil(u, 'usuario_apagar_pedido', {'banido': true});

  String usuariosCsv(List<UsuarioAdmin> lista) {
    final linhas = <List<dynamic>>[
      ['user_id', 'email', 'nome', 'tipo_atividade', 'plano_efetivo', 'plano', 'trial_ate', 'ultimo_acesso', 'banido', 'criado_em'],
      for (final u in lista)
        [
          u.userId,
          u.email ?? '',
          u.nome ?? '',
          u.tipoAtividade,
          u.planoEfetivo,
          u.plano,
          u.trialAte?.toIso8601String() ?? '',
          u.ultimoAcesso?.toIso8601String() ?? '',
          u.banido,
          u.criadoEm?.toIso8601String() ?? '',
        ],
    ];
    return const ListToCsvConverter(fieldDelimiter: ';').convert(linhas);
  }

  // ---------------------------------------------------------------- regras legais
  Future<List<Linha>> regras() async {
    if (emTeste) {
      _falhaSePedido();
      return List.of(_regras);
    }
    return _linhas(await sb.from('regras_legais').select().order('chave', ascending: true));
  }

  Future<void> guardarRegra(Linha antes, Linha depois) async {
    final chave = antes['chave'] as String;
    final campos = {
      'descricao': depois['descricao'],
      'valor_num': depois['valor_num'],
      'valor_txt': depois['valor_txt'],
      'valor_json': depois['valor_json'],
      'unidade': depois['unidade'],
      'ano': depois['ano'],
      'confianca': depois['confianca'],
      'fonte_url': depois['fonte_url'],
      'verificado_em': depois['verificado_em'],
    };
    if (emTeste) {
      final i = _regras.indexWhere((r) => r['chave'] == chave);
      if (i >= 0) _regras[i] = {..._regras[i], ...campos};
    } else {
      await sb.from('regras_legais').update(campos).eq('chave', chave);
    }
    await _registar('regra_editar', alvoTipo: 'regras_legais', alvoId: chave, antes: antes, depois: campos);
  }

  Future<List<Linha>> escaloes() async {
    if (emTeste) {
      _falhaSePedido();
      return List.of(_escaloes);
    }
    return _linhas(await sb.from('irs_escaloes').select().order('ano', ascending: false).order('ordem', ascending: true));
  }

  Future<void> guardarEscalao(Linha antes, Linha depois) async {
    final id = antes['id'];
    final campos = {'ate': depois['ate'], 'taxa': depois['taxa'], 'parcela_abater': depois['parcela_abater']};
    if (emTeste) {
      final i = _escaloes.indexWhere((r) => r['id'] == id);
      if (i >= 0) _escaloes[i] = {..._escaloes[i], ...campos};
    } else {
      await sb.from('irs_escaloes').update(campos).eq('id', id as Object);
    }
    await _registar('irs_escalao_editar', alvoTipo: 'irs_escaloes', alvoId: '$id', antes: antes, depois: campos);
  }

  Future<List<Linha>> flags() async {
    if (emTeste) {
      _falhaSePedido();
      return List.of(_flags);
    }
    return _linhas(await sb.from('feature_flags').select().order('chave', ascending: true));
  }

  Future<void> guardarFlag(Linha antes, Linha depois) async {
    final chave = antes['chave'] as String;
    final campos = {
      'free': depois['free'],
      'pro': depois['pro'],
      'familia': depois['familia'],
      'limite_free': depois['limite_free'],
      'limite_pro': depois['limite_pro'],
      'limite_familia': depois['limite_familia'],
    };
    if (emTeste) {
      final i = _flags.indexWhere((r) => r['chave'] == chave);
      if (i >= 0) _flags[i] = {..._flags[i], ...campos};
    } else {
      await sb.from('feature_flags').update(campos).eq('chave', chave);
    }
    await _registar('flag_editar', alvoTipo: 'feature_flags', alvoId: chave, antes: antes, depois: campos);
  }

  // ---------------------------------------------------------------- avisos em massa
  Future<void> criarAvisoMassa(String titulo, String corpo, {String segmento = 'todos'}) async {
    final linha = {'titulo': titulo.trim(), 'corpo': corpo.trim(), 'segmento': segmento, 'enviado_por': _adminId};
    String? id;
    if (emTeste) {
      id = 'massa-${_avisosMassa.length + 1}';
      _avisosMassa.insert(0, {...linha, 'id': id, 'total_enviados': 0, 'criado_em': DateTime.now().toIso8601String()});
    } else {
      final r = await sb.from('avisos_massa').insert(linha).select('id').single();
      id = r['id'] as String?;
    }
    await _registar('aviso_massa_criar', alvoTipo: 'avisos_massa', alvoId: id, depois: linha);
  }

  Future<List<Linha>> avisosMassa({int limite = 100}) async {
    if (emTeste) {
      _falhaSePedido();
      return List.of(_avisosMassa);
    }
    return _linhas(await sb.from('avisos_massa').select().order('criado_em', ascending: false).limit(limite));
  }

  // ---------------------------------------------------------------- tickets
  Future<List<Linha>> tickets({String? estado, bool? escalar, int limite = 300}) async {
    if (emTeste) {
      _falhaSePedido();
      return _tickets
          .where((t) => (estado == null || t['estado'] == estado) && (escalar == null || (t['escalar_humano'] == true) == escalar))
          .toList();
    }
    var q = sb.from('tickets_suporte').select();
    if (estado != null) q = q.eq('estado', estado);
    if (escalar != null) q = q.eq('escalar_humano', escalar);
    return _linhas(await q.order('criado_em', ascending: false).limit(limite));
  }

  Future<void> mudarEstadoTicket(Linha ticket, String estado) async {
    final id = ticket['id'] as String;
    if (emTeste) {
      final i = _tickets.indexWhere((t) => t['id'] == id);
      if (i >= 0) _tickets[i] = {..._tickets[i], 'estado': estado};
    } else {
      await sb.from('tickets_suporte').update({'estado': estado}).eq('id', id);
    }
    await _registar('ticket_estado',
        alvoTipo: 'tickets_suporte', alvoId: id, antes: {'estado': ticket['estado']}, depois: {'estado': estado});
  }

  static const chaveContactoParceiro = 'contacto_parceiro_contabilista';

  Future<String?> lerContactoParceiro() async {
    if (emTeste) {
      _falhaSePedido();
      return _contactoParceiro;
    }
    final r = await sb.from('regras_legais').select('valor_txt').eq('chave', chaveContactoParceiro).maybeSingle();
    return r?['valor_txt'] as String?;
  }

  /// Cria a linha em `regras_legais` se não existir (upsert pela chave).
  Future<void> guardarContactoParceiro(String texto) async {
    final antes = await lerContactoParceiro();
    if (emTeste) {
      _contactoParceiro = texto;
    } else {
      await sb.from('regras_legais').upsert({
        'chave': chaveContactoParceiro,
        'valor_txt': texto,
        'unidade': 'texto',
        'descricao': 'Contacto do contabilista/advogado parceiro (mostrado ao escalar um ticket para humano)',
        'confianca': 'oficial',
        'verificado_em': _dia(DateTime.now()),
      }, onConflict: 'chave');
    }
    await _registar('contacto_parceiro',
        alvoTipo: 'regras_legais', alvoId: chaveContactoParceiro, antes: {'valor_txt': antes}, depois: {'valor_txt': texto});
  }

  // ---------------------------------------------------------------- IA
  Future<List<Linha>> topPerguntas({int limite = 30}) async {
    if (emTeste) {
      _falhaSePedido();
      return List.of(_t!.topPerguntas);
    }
    return _linhas(await sb.rpc('admin_ia_top_perguntas', params: {'limite': limite}));
  }

  Future<List<Linha>> foraDasRegras({int limite = 100}) async {
    if (emTeste) {
      _falhaSePedido();
      return List.of(_t!.foraDasRegras);
    }
    return _linhas(await sb
        .from('conversas_ia')
        .select('id,user_id,pergunta,resposta,variante,modo,criado_em')
        .eq('fora_das_regras', true)
        .order('criado_em', ascending: false)
        .limit(limite));
  }

  Future<List<Linha>> custoIaPorDia({int dias = 30}) async {
    if (emTeste) {
      _falhaSePedido();
      return List.of(_t!.custoIa);
    }
    return _linhas(await sb.from('v_custo_ia_diario').select().limit(dias));
  }

  /// Rascunho de guia a partir de uma pergunta (publicado=false).
  Future<String> criarGuia(String pergunta) async {
    final p = pergunta.trim();
    var slug = p
        .toLowerCase()
        .replaceAll(RegExp(r'[àáâã]'), 'a')
        .replaceAll(RegExp(r'[éê]'), 'e')
        .replaceAll(RegExp(r'[í]'), 'i')
        .replaceAll(RegExp(r'[óôõ]'), 'o')
        .replaceAll(RegExp(r'[ú]'), 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.length > 60) slug = slug.substring(0, 60);
    if (slug.isEmpty) slug = 'guia';
    slug = '$slug-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final linha = {
      'slug': slug,
      'titulo': p.length > 120 ? p.substring(0, 120) : p,
      'resumo': null,
      'corpo_pt': p,
      'categoria': 'rascunho',
      'publicado': false,
    };
    if (!emTeste) await sb.from('guias').insert(linha);
    await _registar('guia_criar_rascunho', alvoTipo: 'guias', alvoId: slug, depois: linha);
    return slug;
  }

  // ---------------------------------------------------------------- avisos / push / e2e
  Future<List<Linha>> eventosPush({String? tipo, String? resultado, int limite = 200}) async {
    if (emTeste) {
      _falhaSePedido();
      return _t!.eventosPush
          .where((e) => (tipo == null || e['tipo'] == tipo) && (resultado == null || (e['resultado'] ?? 'pendente') == resultado))
          .toList();
    }
    var q = sb.from('eventos_push').select();
    if (tipo != null) q = q.eq('tipo', tipo);
    if (resultado != null) q = resultado == 'pendente' ? q.isFilter('resultado', null) : q.eq('resultado', resultado);
    return _linhas(await q.order('dia', ascending: false).order('enviado_em', ascending: false).limit(limite));
  }

  Future<List<Linha>> e2eLog({int limite = 100}) async {
    if (emTeste) {
      _falhaSePedido();
      return List.of(_t!.e2eLog);
    }
    return _linhas(await sb.from('e2e_log').select().order('created_at', ascending: false).limit(limite));
  }
}

// ---------------------------------------------------------------- utilidades
List<Linha> _linhas(dynamic rows) => ((rows as List?) ?? const []).map((m) => Map<String, dynamic>.from(m as Map)).toList();

num _num(dynamic v) => v == null ? 0 : (v is num ? v : num.tryParse(v.toString()) ?? 0);

DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

String _dia(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// JSON legível para as folhas de detalhe (auditoria, valor_json).
String jsonBonito(dynamic v) {
  if (v == null) return '—';
  try {
    return const JsonEncoder.withIndent('  ').convert(v);
  } catch (_) {
    return v.toString();
  }
}
