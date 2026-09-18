/// As stores do modo exemplo (B2f): as mesmas classes que a app usa, com os
/// dados da [DadosExemplo] já dentro e SEM servidor — ler não vai à rede e
/// gravar não grava. Quem tenta guardar recebe um aviso («isto é um exemplo,
/// cria a tua conta para guardares») e a app segue como se tivesse corrido
/// bem, para nenhum ecrã ficar preso num erro de rede que não existe.
library;

import '../models/carro.dart';
import '../models/cofre_movimento.dart';
import '../models/entrada.dart';
import '../models/fatura_recebida.dart';
import '../models/fidelizacao.dart';
import '../models/movimento_banco.dart';
import '../models/obrigacao.dart';
import '../models/perfil.dart';
import '../models/rendimento.dart';
import '../models/saida.dart';
import '../regras/extrato_banco.dart';
import '../regras/regras_legais.dart';
import '../regras/seguranca_social.dart';
import '../stores/banco_store.dart';
import '../stores/caixa_store.dart';
import '../stores/cofre_store.dart';
import '../stores/dados_store.dart';
import '../stores/entradas_store.dart';
import '../stores/perfil_store.dart';
import '../stores/perto_store.dart';
import '../stores/radar_store.dart';
import '../stores/regras_store.dart';
import '../stores/resumo_store.dart';
import '../stores/saidas_store.dart';
import '../stores/sessao_store.dart';
import 'dados_exemplo.dart';

/// Chamado sempre que alguém tenta gravar dentro do exemplo.
typedef AoTentarGravar = void Function();

class SessaoExemplo extends SessaoStore {
  SessaoExemplo() : super.semServidor();
  @override
  String? get userId => userIdExemplo;
  @override
  bool get autenticado => true;
}

class PerfilExemplo extends PerfilStore {
  final Perfil _p;
  final AoTentarGravar avisar;
  PerfilExemplo(this._p, this.avisar);
  @override
  Perfil? get perfil => _p;
  @override
  bool get temPerfil => true;
  @override
  Future<void> carregar(String userId) async {}
  @override
  Future<bool> guardar(Perfil novo) async {
    avisar();
    return true;
  }

  @override
  Future<bool> guardarRascunhoOnboarding(Map<String, dynamic>? rascunho) async => true;
}

/// Plano «trial» com tudo aberto: o exemplo mostra a app inteira.
class PlanoExemplo extends PlanoStore {
  @override
  String get planoEfetivo => 'trial';
  @override
  bool get carregado => true;
  @override
  bool get emTrial => true;
  @override
  bool get ehPago => false;
  @override
  bool permitida(String chave) => true;
  @override
  int? limite(String chave) => null;
  @override
  Future<void> carregar(String? userId) async {}
}

class ObrigacoesExemplo extends ObrigacoesStore {
  final AoTentarGravar avisar;
  ObrigacoesExemplo(super.itens, this.avisar) : super.paraTeste();
  @override
  Future<void> carregar(String userId) async {}
  @override
  Future<void> recalcularSeVelho(String userId, {DateTime? agora}) async {}
  @override
  Future<bool> recalcular(String userId) async => true;
  @override
  Future<bool> marcarPaga(ObrigacaoItem o, {String? comprovativoUrl}) async {
    avisar();
    return true;
  }

  @override
  Future<bool> desmarcarPaga(ObrigacaoItem o) async {
    avisar();
    return true;
  }

  @override
  Future<bool> adicionarManual({
    required String userId,
    required String tipo,
    required String descricao,
    required DateTime data,
    double? valor,
    required Set<DateTime> feriados,
  }) async {
    avisar();
    return true;
  }
}

class RendimentosExemplo extends RendimentosStore {
  final AoTentarGravar avisar;
  RendimentosExemplo(super.itens, this.avisar) : super.paraTeste();
  @override
  Future<void> carregar(String userId) async {}
  @override
  Future<bool> guardar(Rendimento r) async {
    avisar();
    return true;
  }

  @override
  Future<bool> apagar(Rendimento r) async {
    avisar();
    return true;
  }
}

class CarrosExemplo extends CarrosStore {
  final AoTentarGravar avisar;
  CarrosExemplo(super.carros, super.abastecimentos, super.despesas, this.avisar) : super.paraTeste();
  @override
  Future<void> carregar(String userId) async {}
  @override
  Future<Carro?> guardarCarro(Carro c) async {
    avisar();
    return c;
  }

  @override
  Future<bool> apagarCarro(Carro c) async {
    avisar();
    return true;
  }

  @override
  Future<bool> guardarAbastecimento(String userId, Map<String, dynamic> dados) async {
    avisar();
    return true;
  }

  @override
  Future<bool> guardarDespesa(String userId, Map<String, dynamic> dados) async {
    avisar();
    return true;
  }
}

class EntradasExemplo extends EntradasStore {
  final AoTentarGravar avisar;
  EntradasExemplo(super.itens, this.avisar) : super.paraTeste();
  @override
  Future<void> carregar(String userId) async {}
  @override
  Future<void> carregarSePreciso(String userId) async {}
  @override
  Future<Entrada?> guardarEDevolver(Entrada e) async {
    avisar();
    return e;
  }

  @override
  Future<bool> apagar(Entrada e) async {
    avisar();
    return true;
  }
}

class SaidasExemplo extends SaidasStore {
  final AoTentarGravar avisar;
  SaidasExemplo(super.saidas, super.pagamentos, this.avisar) : super.paraTeste();
  @override
  Future<void> carregar(String userId, {DateTime? hoje}) async {}
  @override
  Future<bool> gerarDoMes(String userId, {DateTime? mes}) async => true;
  @override
  Future<Saida?> guardar(Saida s) async {
    avisar();
    return s;
  }

  @override
  Future<bool> desativar(Saida s) async {
    avisar();
    return true;
  }

  @override
  Future<bool> marcarPago(SaidaPagamento p, {double? valor}) async {
    avisar();
    return true;
  }

  @override
  Future<bool> desmarcarPago(SaidaPagamento p) async {
    avisar();
    return true;
  }

  @override
  Future<bool> saltar(SaidaPagamento p) async {
    avisar();
    return true;
  }
}

class ResumoExemplo extends ResumoStore {
  ResumoExemplo(ResumoMes mes, ResumoAno ano) : super.paraTeste(mes: mes, ano: ano);
  @override
  Future<void> carregar(String userId, {int? ano}) async {}
  @override
  Future<void> escolherAno(String userId, int ano) async {}
}

class CofreExemplo extends CofreStore {
  final AoTentarGravar avisar;
  CofreExemplo(super.movimentos, double entrouParaIrs, this.avisar) : super.paraTeste(entrouParaIrs: entrouParaIrs);
  @override
  Future<void> carregar(String userId, {int? ano}) async {}
  @override
  Future<void> carregarSePreciso(String userId, {int? ano}) async {}
  @override
  Future<double> reservarPorEntrada({
    required String userId,
    required String entradaId,
    required double valor,
    required DateTime data,
    required TipoRendimento tipo,
    double? rendimentoAnualEstimado,
    DateTime? dataAbertura,
    required RegrasLegais regras,
  }) async =>
      0;
  @override
  Future<bool> apontar(CofreMovimento m) async {
    avisar();
    return true;
  }

  @override
  Future<bool> apagar(CofreMovimento m) async {
    avisar();
    return true;
  }
}

class RadarExemplo extends RadarStore {
  RadarExemplo(List<Fidelizacao> contratos) : super.paraTeste(contratos: contratos);
  @override
  Future<void> carregarSePreciso(String userId) async {}
  @override
  Future<void> carregar(String userId, {int? dias}) async {}
}

class CaixaExemplo extends CaixaStore {
  final AoTentarGravar avisar;
  CaixaExemplo(this.avisar) : super.paraTeste(endereco: 'maria.k7f2@faturas.emdia.pt', ligada: true);
  @override
  Future<void> carregarSePreciso() async {}
  @override
  Future<void> carregar() async {}
  @override
  Future<bool> marcarLigada(FaturaRecebida f, String saidaId) async {
    avisar();
    return true;
  }

  @override
  Future<bool> ignorar(FaturaRecebida f) async {
    avisar();
    return true;
  }

  @override
  Future<bool> apagar(FaturaRecebida f) async {
    avisar();
    return true;
  }

  @override
  Future<String?> enderecoParaAbrir(FaturaRecebida f) async => null;
}

class BancoExemplo extends BancoStore {
  final AoTentarGravar avisar;
  BancoExemplo(super.movimentos, List<OperadorCancelar> operadores, this.avisar) : super.paraTeste(operadores: operadores);
  @override
  Future<void> carregar(String userId) async {}
  @override
  Future<ResultadoImportacao> guardar(String userId, ExtratoLido lido, {required String nomeFicheiro}) async {
    avisar();
    return const ResultadoImportacao(lidas: 0, novas: 0, repetidas: 0, ignoradas: 0);
  }

  @override
  Future<void> registarFalha(String userId, String nomeFicheiro, String erro) async {}
  @override
  Future<bool> ligarEntrada(MovimentoBanco m, String entradaId) async {
    avisar();
    return true;
  }

  @override
  Future<bool> ligarSaida(String userId, Recorrente r, String saidaId) async {
    avisar();
    return true;
  }

  @override
  Future<bool> apagarTudo(String userId) async {
    avisar();
    return true;
  }
}

class PertoExemplo extends PertoStore {
  PertoExemplo(List<PostoPerto> postos, List<CentroPerto> centros)
      : super.paraTeste(lat: 40.537, lng: -7.268, origem: OrigemLocal.concelho, concelho: 'Guarda', postos: postos, centros: centros);
  @override
  Future<void> usarLocalizacao() async {}
  @override
  Future<void> usarConcelho(String concelho) async {}
  @override
  Future<void> escolherCombustivel(String c) async {}
}
