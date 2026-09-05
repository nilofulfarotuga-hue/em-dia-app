import 'regras_legais.dart';

/// Nível da vigia do IVA (isenção do art. 53.º).
enum NivelIva { ok, aviso, alarme, critico }

class VigiaIva {
  final double acumuladoAno;
  final double limite; // 15.000
  final double aviso; // 12.000
  final double perdaImediata; // 18.750
  final NivelIva nivel;
  final double fracao; // 0..1 (acumulado / limite, tapado a 1)
  final double faltaParaLimite; // >= 0

  const VigiaIva({
    required this.acumuladoAno,
    required this.limite,
    required this.aviso,
    required this.perdaImediata,
    required this.nivel,
    required this.fracao,
    required this.faltaParaLimite,
  });
}

/// "Estás em X € de 15.000 €": aviso aos 12.000, alarme aos 15.000,
/// crítico aos 18.750 (perde a isenção de imediato).
VigiaIva vigiaIva({required double acumuladoAno, required RegrasLegais r}) {
  final limite = r.n('iva_isencao_limite');
  final aviso = r.n('iva_isencao_aviso');
  final perda = r.n('iva_isencao_perda_imediata');
  final NivelIva nivel;
  if (acumuladoAno > perda) {
    nivel = NivelIva.critico;
  } else if (acumuladoAno > limite) {
    nivel = NivelIva.alarme;
  } else if (acumuladoAno >= aviso) {
    nivel = NivelIva.aviso;
  } else {
    nivel = NivelIva.ok;
  }
  return VigiaIva(
    acumuladoAno: acumuladoAno,
    limite: limite,
    aviso: aviso,
    perdaImediata: perda,
    nivel: nivel,
    fracao: (acumuladoAno / limite).clamp(0.0, 1.0),
    faltaParaLimite: (limite - acumuladoAno).clamp(0.0, double.infinity),
  );
}

/// Regime de IVA do ano seguinte, deduzido do que faturou este ano.
/// (Quem passa os 15.000 € cobra IVA no ano seguinte; quem passa os 18.750 €
/// cobra já — ver [vigiaIva].)
bool cobraIvaNoProximoAno({required double faturacaoEsteAno, required RegrasLegais r}) =>
    faturacaoEsteAno > r.n('iva_isencao_limite');
