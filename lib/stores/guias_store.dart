import 'package:flutter/foundation.dart';

import '../models/guia.dart';
import '../services/arranque.dart';

/// Os guias de 1 minuto (tabela `guias`, só os publicados, por ordem).
/// Sem rede ou com erro, mostra a lista local dos 11 títulos com o corpo
/// "em breve" — a app nunca fica vazia.
class GuiasStore extends ChangeNotifier {
  List<Guia> _itens = [];
  bool _aCarregar = false;
  String? _erro;

  List<Guia> get itens => _itens;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;

  GuiasStore();

  /// Para testes e fotos (golden): itens já carregados, sem servidor.
  GuiasStore.paraTeste(List<Guia> itens, {bool aCarregar = false, String? erro})
      : _itens = List.of(itens)..sort((a, b) => a.ordem.compareTo(b.ordem)) {
    _aCarregar = aCarregar;
    _erro = erro;
  }

  Future<void> carregar() async {
    _aCarregar = true;
    notifyListeners();
    try {
      if (!temChaves) throw StateError('sem chaves do servidor');
      final rows = await sb.from('guias').select().eq('publicado', true).order('ordem');
      final lidos = (rows as List).map((m) => Guia.fromMap(Map<String, dynamic>.from(m as Map))).toList();
      _itens = lidos.isEmpty ? guiasLocais() : lidos;
      _erro = null;
    } catch (e) {
      _erro = e.toString();
      if (_itens.isEmpty) _itens = guiasLocais();
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  Guia? porSlug(String slug) {
    for (final g in _itens) {
      if (g.slug == slug) return g;
    }
    return null;
  }

  /// Os 11 guias previstos na missão (secção 2, Tela 6), sem corpo ainda.
  /// O corpo vazio faz o ecrã mostrar "em breve"; o servidor substitui isto
  /// assim que houver rede.
  static List<Guia> guiasLocais() => const [
        Guia(slug: 'abrir-atividade', titulo: 'Abrir atividade (o CAE certo para TVDE, estafeta, cabeleireiro…)', categoria: 'inicio', ordem: 10, corpoPt: ''),
        Guia(slug: 'simplificado-vs-organizada', titulo: 'Simplificado ou contabilidade organizada?', categoria: 'inicio', ordem: 20, corpoPt: ''),
        Guia(slug: 'isencao-art-53', titulo: 'Isenção de IVA (art. 53.º): até 15.000 € por ano', categoria: 'iva', ordem: 30, corpoPt: ''),
        Guia(slug: 'retencao-23-25-dispensa', titulo: 'Retenção na fonte: 23%, 25% ou dispensa', categoria: 'recibos', ordem: 40, corpoPt: ''),
        Guia(slug: 'seguranca-social-direta', titulo: 'Segurança Social Direta passo a passo', categoria: 'ss', ordem: 50, corpoPt: ''),
        Guia(slug: 'irs-independente', titulo: 'IRS do independente (anexo B, despesas, mínimo de existência)', categoria: 'irs', ordem: 60, corpoPt: ''),
        Guia(slug: 'tvde-o-que-e-preciso', titulo: 'TVDE: o que é preciso', categoria: 'tvde', ordem: 70, corpoPt: ''),
        Guia(slug: 'estafeta-recibos-vs-contrato', titulo: 'Estafeta de plataforma: recibos ou contrato?', categoria: 'estafeta', ordem: 80, corpoPt: ''),
        Guia(slug: 'encerrar-atividade', titulo: 'Encerrar atividade sem deixar contas para trás', categoria: 'inicio', ordem: 90, corpoPt: ''),
        Guia(slug: 'imigrante-nif-niss-sns-aima', titulo: 'Imigrante: NIF, NISS, SNS e AIMA', categoria: 'imigrante', ordem: 100, corpoPt: ''),
        Guia(slug: 'carro-iuc-ipo-seguro-carta-multas', titulo: 'Carro: IUC, inspeção, seguro, carta e multas', categoria: 'carro', ordem: 110, corpoPt: ''),
      ];
}
