// Apoio aos golden tests: stores FALSAS (sem rede, sem Supabase) e fábricas
// de dados. Qualquer tela fotografada embrulha-se com [embrulhaStores].
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:em_dia/models/carro.dart';
import 'package:em_dia/models/obrigacao.dart';
import 'package:em_dia/models/perfil.dart';
import 'package:em_dia/models/rendimento.dart';
import 'package:em_dia/regras/regras.dart';
import 'package:em_dia/stores/dados_store.dart';
import 'package:em_dia/services/fala.dart';
import 'package:em_dia/stores/perfil_store.dart';
import 'package:em_dia/stores/regras_store.dart';
import 'package:em_dia/stores/sessao_store.dart';

const String userIdTeste = '00000000-0000-4000-8000-000000000001';

/// Perfil já carregado, sem servidor.
class PerfilStoreFalso extends PerfilStore {
  final Perfil? _p;
  PerfilStoreFalso(this._p);
  @override
  Perfil? get perfil => _p;
  @override
  bool get temPerfil => _p != null;
  @override
  Future<void> carregar(String userId) async {}
}

/// Plano efetivo fixo (trial / free / pro / familia); tudo permitido no trial
/// e nos pagos, nada de flags de servidor.
class PlanoStoreFalso extends PlanoStore {
  final String _plano;
  /// Limites numéricos por chave (ex.: `{'carros': 1}`); vazio = sem limite.
  final Map<String, int> limites;
  PlanoStoreFalso(this._plano, {this.limites = const {}});
  @override
  String get planoEfetivo => _plano;
  @override
  bool get carregado => true;
  @override
  bool get emTrial => _plano == 'trial';
  @override
  bool get ehPago => _plano == 'pro' || _plano == 'familia';
  @override
  bool permitida(String chave) => _plano != 'free';
  @override
  int? limite(String chave) => limites[chave];
  @override
  Future<void> carregar(String? userId) async {}
}

/// Sessão sem Supabase.
class SessaoStoreFalso extends SessaoStore {
  SessaoStoreFalso() : super.semServidor();
}

Perfil perfilTeste({
  String? nome = 'Danilo',
  TipoAtividade tipoAtividade = TipoAtividade.tvde,
  double? rendimentoMensalEstimado = 1200,
  String plano = 'free',
  DateTime? trialAte,
  DateTime? dataAbertura,
}) =>
    Perfil(
      userId: userIdTeste,
      nome: nome,
      email: 'teste@emdia.pt',
      tipoAtividade: tipoAtividade,
      dataAbertura: dataAbertura ?? DateTime(2026, 3, 1),
      rendimentoMensalEstimado: rendimentoMensalEstimado,
      plano: plano,
      trialAte: trialAte ?? DateTime(2026, 9, 30),
      onboardingConcluido: true,
      criadoEm: DateTime(2026, 8, 31),
    );

ObrigacaoItem obrigacaoTeste({
  required String id,
  required String tipo,
  required DateTime dataLimite,
  double? valor,
  String estado = 'pendente',
  String? descricao,
  String? comoPagar,
}) =>
    ObrigacaoItem(
      id: id,
      userId: userIdTeste,
      tipo: tipo,
      descricao: descricao ?? tipo,
      dataLimite: dataLimite,
      avisoEm: dataLimite,
      valorEstimado: valor,
      estado: estado,
      comoPagar: comoPagar,
    );

Rendimento rendimentoTeste({required DateTime mes, required double valor}) => Rendimento(
      id: 'r-${mes.year}-${mes.month}',
      userId: userIdTeste,
      mes: DateTime(mes.year, mes.month, 1),
      valorBruto: valor,
    );

/// Atalho usado pelas telas que não precisam de dados (onboarding, login):
/// todas as stores falsas, perfil vazio, plano em trial.
Widget comStores(Widget tela, {Perfil? perfil, String plano = 'trial'}) => embrulhaStores(
      tela: tela,
      perfil: perfil ??
          perfilTeste(nome: null, rendimentoMensalEstimado: null, tipoAtividade: TipoAtividade.semAtividade),
      plano: plano,
    );

/// Embrulha a tela com todas as stores (falsas ou pré-carregadas).
Widget embrulhaStores({
  required Widget tela,
  Perfil? perfil,
  String plano = 'trial',
  List<ObrigacaoItem> obrigacoes = const [],
  List<Rendimento> rendimentos = const [],
  bool obrigacoesACarregar = false,
  String? obrigacoesErro,
  List<Carro> carros = const [],
  List<Abastecimento> abastecimentos = const [],
  List<DespesaCarro> despesas = const [],
  Map<String, int> limites = const {},
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessaoStore>(create: (_) => SessaoStoreFalso()),
        // A voz: os botões de ouvir precisam dela para saber quem está a falar.
        ChangeNotifierProvider<Fala>.value(value: Fala.instancia),
        ChangeNotifierProvider<RegrasStore>(create: (_) => RegrasStore()),
        ChangeNotifierProvider<PlanoStore>(create: (_) => PlanoStoreFalso(plano, limites: limites)),
        ChangeNotifierProvider<PerfilStore>(create: (_) => PerfilStoreFalso(perfil)),
        ChangeNotifierProvider<ObrigacoesStore>(
          create: (_) => ObrigacoesStore.paraTeste(obrigacoes, aCarregar: obrigacoesACarregar, erro: obrigacoesErro),
        ),
        ChangeNotifierProvider<RendimentosStore>(create: (_) => RendimentosStore.paraTeste(rendimentos)),
        ChangeNotifierProvider<CarrosStore>(create: (_) => CarrosStore.paraTeste(carros, abastecimentos, despesas)),
      ],
      child: tela,
    );
