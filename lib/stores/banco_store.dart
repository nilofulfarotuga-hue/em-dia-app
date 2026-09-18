import 'package:flutter/foundation.dart';

import '../models/movimento_banco.dart';
import '../regras/extrato_banco.dart';
import '../services/arranque.dart';
import '../services/extrato_excel.dart';

/// O resultado de uma importação, para o ecrã dizer o que aconteceu e para a
/// tabela `importacoes_extrato` (o painel admin conta os erros por aqui).
class ResultadoImportacao {
  final int lidas;
  final int novas;
  final int repetidas;
  final int ignoradas;
  final String? banco;
  final String? erro;
  const ResultadoImportacao({
    required this.lidas,
    required this.novas,
    required this.repetidas,
    required this.ignoradas,
    this.banco,
    this.erro,
  });
}

/// Os movimentos do banco (tabela `movimentos_banco`) e o que se repete.
///
/// Padrão Model → Store → Screen. A leitura do ficheiro é toda no aparelho
/// (`lib/regras/extrato_banco.dart`); aqui só se guarda, se lê de volta e se
/// juntam as coisas que se repetem. Nada de SMS, nada de Gmail, nada de banco
/// por dentro (D23) — o ficheiro vem da mão da pessoa.
class BancoStore extends ChangeNotifier {
  List<MovimentoBanco> _movimentos = [];
  List<OperadorCancelar> _operadores = [];
  List<RegraCategoria> _regras = regrasCategoriaPadrao;
  bool _aCarregar = false;
  String? _erro;
  String? _userCarregado;

  /// Do mais recente para o mais antigo.
  List<MovimentoBanco> get movimentos => _movimentos;
  List<OperadorCancelar> get operadores => _operadores;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;
  bool get temDados => _userCarregado != null;

  BancoStore();

  /// Para testes e fotos (golden): itens já carregados, sem servidor.
  BancoStore.paraTeste(List<MovimentoBanco> movimentos, {List<OperadorCancelar> operadores = const []})
      : _movimentos = List.of(movimentos)..sort((a, b) => b.data.compareTo(a.data)),
        _userCarregado = movimentos.isEmpty ? null : movimentos.first.userId {
    _operadores = operadores;
  }

  /// As coisas que se repetem, a partir do que está guardado (últimos 12 meses).
  List<Recorrente> get recorrentes => encontrarRecorrentes(_movimentos.map((m) => m.lido).toList(), regras: _regras);

  /// «Pagas X por mês em coisas que se repetem.»
  double get totalMensal => totalMensalRecorrente(recorrentes);

  /// O que entrou (créditos) que ainda não foi marcado como rendimento — para
  /// a pessoa dizer «isto é meu, conta para o IRS».
  List<MovimentoBanco> get entradasPorConfirmar =>
      _movimentos.where((m) => m.entra && m.entradaId == null && m.categoria == 'rendimento').toList();

  Future<void> carregar(String userId) async {
    if (!temChaves) return;
    _aCarregar = true;
    _erro = null;
    notifyListeners();
    try {
      final desde = DateTime.now().subtract(const Duration(days: 370));
      final rs = await sb
          .from('movimentos_banco')
          .select()
          .eq('user_id', userId)
          .gte('data', '${desde.year}-${desde.month.toString().padLeft(2, '0')}-01')
          .order('data', ascending: false)
          .limit(2000);
      _movimentos = (rs as List).map((m) => MovimentoBanco.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      _userCarregado = userId;
      if (_operadores.isEmpty) {
        final os = await sb.from('operadores_cancelar').select().order('nome', ascending: true);
        _operadores = (os as List).map((m) => OperadorCancelar.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      }
      try {
        final cs = await sb.from('categorias_regras').select().eq('ativa', true);
        final regras = (cs as List)
            .map((m) => RegraCategoria((m as Map)['padrao'] as String, m['categoria'] as String, m['fornecedor'] as String?))
            .toList();
        if (regras.isNotEmpty) _regras = regras;
      } catch (_) {
        // sem rede para as regras: fica o espelho local
      }
    } catch (e) {
      _erro = e.toString();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  /// Lê o ficheiro (CSV ou Excel) sem gravar nada: é o que o ecrã mostra
  /// antes de a pessoa carregar em «Guardar».
  ExtratoLido ler(List<int> bytes, String nomeFicheiro) {
    final nome = nomeFicheiro.toLowerCase();
    if (nome.endsWith('.xlsx') || nome.endsWith('.xls')) return lerExtratoXlsx(bytes, nomeFicheiro: nomeFicheiro);
    if (nome.endsWith('.pdf')) throw const ExtratoInvalido('pdf_nao_suportado');
    return lerExtratoCsv(bytes, nomeFicheiro: nomeFicheiro);
  }

  /// Categoria e fornecedor de um movimento lido, pelas regras carregadas.
  ({String categoria, String? fornecedor}) categoria(MovimentoLido m) => categorizar(m, regras: _regras);

  /// Grava o que foi lido. Não repete o que já lá está (chave por dia + valor +
  /// descrição), marca o que se repete e regista a importação para o admin.
  Future<ResultadoImportacao> guardar(String userId, ExtratoLido lido, {required String nomeFicheiro}) async {
    final recorrentes = encontrarRecorrentes([...lido.movimentos, ..._movimentos.map((m) => m.lido)], regras: _regras)
        .map((r) => r.chave)
        .toSet();
    String? importacaoId;
    try {
      final imp = await sb
          .from('importacoes_extrato')
          .insert({
            'user_id': userId,
            'ficheiro': nomeFicheiro,
            'formato': lido.formato,
            'banco': lido.banco,
            'linhas_lidas': lido.linhasLidas,
            'linhas_ignoradas': lido.linhasIgnoradas.length,
          })
          .select('id')
          .single();
      importacaoId = imp['id'] as String?;
    } catch (e) {
      debugPrint('importacoes_extrato: não registou ($e)');
    }
    final existentes = _movimentos.map((m) => m.chave).toSet();
    final linhas = <Map<String, dynamic>>[];
    var repetidas = 0;
    final vistas = <String>{};
    for (final m in lido.movimentos) {
      if (existentes.contains(m.chave) || !vistas.add(m.chave)) {
        repetidas++;
        continue;
      }
      final c = categoria(m);
      linhas.add(MovimentoBanco.paraGravar(
        userId: userId,
        m: m,
        categoria: c.categoria,
        fornecedor: c.fornecedor,
        recorrente: recorrentes.contains(normalizarDescricao(m.descricao)),
        banco: lido.banco,
        importacaoId: importacaoId,
      ));
    }
    try {
      if (linhas.isNotEmpty) {
        await sb.from('movimentos_banco').upsert(linhas, onConflict: 'user_id,chave', ignoreDuplicates: true);
      }
      if (importacaoId != null) {
        await sb.from('importacoes_extrato').update({'linhas_novas': linhas.length, 'linhas_repetidas': repetidas}).eq('id', importacaoId);
      }
      await carregar(userId);
      return ResultadoImportacao(
        lidas: lido.linhasLidas,
        novas: linhas.length,
        repetidas: repetidas,
        ignoradas: lido.linhasIgnoradas.length,
        banco: lido.banco,
      );
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      if (importacaoId != null) {
        try {
          await sb.from('importacoes_extrato').update({'erro': e.toString()}).eq('id', importacaoId);
        } catch (_) {}
      }
      return ResultadoImportacao(lidas: lido.linhasLidas, novas: 0, repetidas: repetidas, ignoradas: lido.linhasIgnoradas.length, banco: lido.banco, erro: e.toString());
    }
  }

  /// Regista uma importação que falhou logo a ler o ficheiro (para o admin ver).
  Future<void> registarFalha(String userId, String nomeFicheiro, String erro) async {
    try {
      await sb.from('importacoes_extrato').insert({
        'user_id': userId,
        'ficheiro': nomeFicheiro,
        'formato': nomeFicheiro.toLowerCase().endsWith('.xlsx') ? 'xlsx' : (nomeFicheiro.toLowerCase().endsWith('.pdf') ? 'pdf' : 'csv'),
        'erro': erro,
      });
    } catch (_) {}
  }

  /// Liga um movimento a uma entrada já criada («isto é rendimento meu»).
  Future<bool> ligarEntrada(MovimentoBanco m, String entradaId) async {
    try {
      await sb.from('movimentos_banco').update({'entrada_id': entradaId}).eq('id', m.id);
      await carregar(m.userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Liga os movimentos de uma coisa que se repete à conta (`saidas`) criada a partir dela.
  Future<bool> ligarSaida(String userId, Recorrente r, String saidaId) async {
    try {
      final ids = _movimentos.where((m) => normalizarDescricao(m.descricao) == r.chave).map((m) => m.id).toList();
      if (ids.isNotEmpty) {
        await sb.from('movimentos_banco').update({'saida_id': saidaId}).inFilter('id', ids);
      }
      await carregar(userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Apaga tudo o que foi importado (a pessoa manda; nunca se apaga sozinho).
  Future<bool> apagarTudo(String userId) async {
    try {
      await sb.from('movimentos_banco').delete().eq('user_id', userId);
      await carregar(userId);
      return true;
    } catch (e) {
      _erro = e.toString();
      notifyListeners();
      return false;
    }
  }

  void limpar() {
    _movimentos = [];
    _userCarregado = null;
    notifyListeners();
  }
}
