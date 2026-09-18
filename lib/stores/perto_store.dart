import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../services/arranque.dart';

/// Um posto com o preço de um combustível, perto (RPC `postos_perto`).
class PostoPerto {
  final int id;
  final String nome;
  final String? marca;
  final String? morada;
  final String? localidade;
  final String? municipio;
  final double lat;
  final double lng;
  final String combustivel;
  final double preco;
  final DateTime? vistoEm;
  final double distanciaKm;
  const PostoPerto({
    required this.id,
    required this.nome,
    this.marca,
    this.morada,
    this.localidade,
    this.municipio,
    required this.lat,
    required this.lng,
    required this.combustivel,
    required this.preco,
    this.vistoEm,
    required this.distanciaKm,
  });

  factory PostoPerto.fromMap(Map<String, dynamic> m) => PostoPerto(
        id: (m['posto_id'] as num).toInt(),
        nome: (m['nome'] as String?) ?? '',
        marca: m['marca'] as String?,
        morada: m['morada'] as String?,
        localidade: m['localidade'] as String?,
        municipio: m['municipio'] as String?,
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        combustivel: (m['combustivel'] as String?) ?? '',
        preco: double.tryParse(m['preco'].toString()) ?? 0,
        vistoEm: m['visto_em'] == null ? null : DateTime.tryParse(m['visto_em'].toString())?.toLocal(),
        distanciaKm: (m['distancia_km'] as num).toDouble(),
      );
}

/// Um centro de inspeção perto (RPC `centros_perto`).
class CentroPerto {
  final String codigo;
  final String nome;
  final String? morada;
  final String? codigoPostal;
  final String? localidade;
  final String distrito;
  final String? telefone;
  final double lat;
  final double lng;
  final double distanciaKm;
  const CentroPerto({
    required this.codigo,
    required this.nome,
    this.morada,
    this.codigoPostal,
    this.localidade,
    required this.distrito,
    this.telefone,
    required this.lat,
    required this.lng,
    required this.distanciaKm,
  });

  factory CentroPerto.fromMap(Map<String, dynamic> m) => CentroPerto(
        codigo: (m['codigo_citv'] as String?) ?? '',
        nome: (m['nome'] as String?) ?? '',
        morada: m['morada'] as String?,
        codigoPostal: m['codigo_postal'] as String?,
        localidade: m['localidade'] as String?,
        distrito: (m['distrito'] as String?) ?? '',
        telefone: m['telefone'] as String?,
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        distanciaKm: (m['distancia_km'] as num).toDouble(),
      );
}

/// De onde veio o «onde estou».
enum OrigemLocal { nenhuma, gps, concelho }

/// «Perto de mim» (B2e): o combustível mais barato num raio de 10 km e os
/// centros de inspeção mais próximos.
///
/// Os dados vêm das tabelas `postos_combustivel`/`precos_combustivel` (DGEG,
/// dados abertos — fonte à vista no ecrã, grátis para toda a gente, D40) e
/// `centros_inspecao` (lista do IMT). A localização é pedida só quando a
/// pessoa carrega no botão, em primeiro plano, e não é guardada em lado
/// nenhum; quem não quiser dá-la escreve o concelho.
class PertoStore extends ChangeNotifier {
  double? _lat;
  double? _lng;
  OrigemLocal _origem = OrigemLocal.nenhuma;
  String? _concelho;
  String _combustivel = 'Gasóleo simples';
  List<String> _combustiveis = const ['Gasóleo simples', 'Gasolina simples 95', 'Gasóleo especial', 'Gasolina especial 95', 'Gasolina 98', 'GPL Auto'];
  List<PostoPerto> _postos = [];
  List<CentroPerto> _centros = [];
  bool _aCarregar = false;
  String? _erro; // 'sem_permissao' | 'sem_gps' | 'concelho_desconhecido' | 'rede'

  double? get lat => _lat;
  double? get lng => _lng;
  OrigemLocal get origem => _origem;
  String? get concelho => _concelho;
  String get combustivel => _combustivel;
  List<String> get combustiveis => _combustiveis;
  List<PostoPerto> get postos => _postos;
  List<CentroPerto> get centros => _centros;
  bool get aCarregar => _aCarregar;
  String? get erro => _erro;
  bool get temLocal => _lat != null && _lng != null;

  PertoStore();

  /// Para testes e fotos: tudo à mão, sem GPS nem servidor.
  PertoStore.paraTeste({
    double? lat,
    double? lng,
    OrigemLocal origem = OrigemLocal.nenhuma,
    String? concelho,
    String combustivel = 'Gasóleo simples',
    List<PostoPerto> postos = const [],
    List<CentroPerto> centros = const [],
    String? erro,
  }) {
    _lat = lat;
    _lng = lng;
    _origem = origem;
    _concelho = concelho;
    _combustivel = combustivel;
    _postos = postos;
    _centros = centros;
    _erro = erro;
  }

  /// Pede a localização ao aparelho (uma vez, em primeiro plano) e carrega.
  Future<void> usarLocalizacao() async {
    _erro = null;
    _aCarregar = true;
    notifyListeners();
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        _erro = 'sem_permissao';
        return;
      }
      if (!kIsWeb && !await Geolocator.isLocationServiceEnabled()) {
        _erro = 'sem_gps';
        return;
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 20)),
      );
      _lat = p.latitude;
      _lng = p.longitude;
      _origem = OrigemLocal.gps;
      _concelho = null;
      await _carregar();
    } catch (e) {
      debugPrint('perto: localização falhou ($e)');
      _erro = 'sem_gps';
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  /// Sem GPS: o centro dos postos desse concelho (RPC `centro_do_municipio`).
  Future<void> usarConcelho(String concelho) async {
    final nome = concelho.trim();
    if (nome.isEmpty) return;
    _erro = null;
    _aCarregar = true;
    notifyListeners();
    try {
      final r = await sb.rpc('centro_do_municipio', params: {'p_municipio': nome});
      final lista = r as List;
      if (lista.isEmpty) {
        _erro = 'concelho_desconhecido';
        return;
      }
      final m = Map<String, dynamic>.from(lista.first as Map);
      _lat = (m['lat'] as num).toDouble();
      _lng = (m['lng'] as num).toDouble();
      _origem = OrigemLocal.concelho;
      _concelho = m['municipio'] as String? ?? nome;
      await _carregar();
    } catch (e) {
      _erro = 'rede';
    } finally {
      _aCarregar = false;
      notifyListeners();
    }
  }

  Future<void> escolherCombustivel(String c) async {
    _combustivel = c;
    notifyListeners();
    if (temLocal) {
      _aCarregar = true;
      notifyListeners();
      try {
        await _carregar();
      } finally {
        _aCarregar = false;
        notifyListeners();
      }
    }
  }

  Future<void> _carregar() async {
    final r = await Future.wait<dynamic>([
      sb.rpc('postos_perto', params: {'p_lat': _lat, 'p_lng': _lng, 'p_combustivel': _combustivel, 'p_raio_km': 10, 'p_max': 15}),
      sb.rpc('centros_perto', params: {'p_lat': _lat, 'p_lng': _lng, 'p_max': 5}),
      sb.rpc('combustiveis_disponiveis'),
    ]);
    _postos = (r[0] as List).map((m) => PostoPerto.fromMap(Map<String, dynamic>.from(m as Map))).toList();
    _centros = (r[1] as List).map((m) => CentroPerto.fromMap(Map<String, dynamic>.from(m as Map))).toList();
    final cs = (r[2] as List).map((m) => (m as Map)['combustivel'] as String).where((c) => !c.contains('GN') && !c.contains('aquecimento') && !c.contains('mistura')).toList();
    if (cs.isNotEmpty) _combustiveis = cs;
  }
}
