/// O que cada tipo de obrigação tem de visual e de texto no Calendário:
/// grupo do filtro, ícone, cor do semáforo, "faltam N dias", site onde se
/// paga, "como pagar" por tipo e o nome humano da regra que a gerou.
/// Só leitura — a lógica (datas, valores) vem das regras e do modelo.
library;

import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';

/// Grupo dos chips de filtro.
enum GrupoObrigacao { tudo, ss, fiscal, carro, outros }

GrupoObrigacao grupoDoTipo(String tipo) => switch (tipo) {
      'ss_declaracao' || 'ss_pagamento' || 'fim_isencao_ss' => GrupoObrigacao.ss,
      'iva_declaracao' ||
      'iva_pagamento' ||
      'irs_entrega' ||
      'irs_pagamento_conta' ||
      'efatura_validar' ||
      'recibos_comunicar' =>
        GrupoObrigacao.fiscal,
      'iuc' || 'ipo' || 'seguro' || 'carta' || 'revisao' || 'troca_carta' || 'tvde_licenca' => GrupoObrigacao.carro,
      _ => GrupoObrigacao.outros,
    };

String rotuloDoGrupo(AppLocalizations l, GrupoObrigacao g) => switch (g) {
      GrupoObrigacao.tudo => l.calFiltroTudo,
      GrupoObrigacao.ss => l.calFiltroSS,
      GrupoObrigacao.fiscal => l.calFiltroFiscal,
      GrupoObrigacao.carro => l.calFiltroCarro,
      GrupoObrigacao.outros => l.calFiltroOutros,
    };

/// Ícone redondo por tipo (SS, IVA, IRS, carro, residência, TVDE, multa…).
IconData iconeDoTipo(String tipo) => switch (tipo) {
      'ss_declaracao' || 'ss_pagamento' => Icons.account_balance_rounded,
      'fim_isencao_ss' => Icons.event_available_rounded,
      'iva_declaracao' || 'iva_pagamento' => Icons.receipt_long_rounded,
      'irs_entrega' || 'irs_pagamento_conta' => Icons.description_rounded,
      'efatura_validar' || 'recibos_comunicar' => Icons.fact_check_rounded,
      'iuc' => Icons.directions_car_rounded,
      'ipo' => Icons.car_repair_rounded,
      'seguro' => Icons.shield_rounded,
      'carta' || 'troca_carta' => Icons.badge_rounded,
      'revisao' => Icons.build_rounded,
      'residencia' => Icons.home_rounded,
      'tvde_certificado' || 'tvde_licenca' => Icons.local_taxi_rounded,
      'multa' => Icons.gavel_rounded,
      'portagem' => Icons.toll_rounded,
      _ => Icons.event_note_rounded,
    };

/// Cor do semáforo desta obrigação, vista de [hoje].
Color corDaObrigacao(ObrigacaoItem o, DateTime hoje) {
  if (o.pago) return AppColors.emDia;
  final dias = o.diasParaPrazo(hoje);
  return AppColors.porEstado(dias < 0 ? 'passado' : o.estado, diasParaPrazo: dias);
}

/// "faltam N dias" · "é hoje" · "passou há N dias" · "Pago".
String textoPrazo(AppLocalizations l, ObrigacaoItem o, DateTime hoje) {
  if (o.pago) return l.calPago;
  final d = o.diasParaPrazo(hoje);
  if (d < 0) return l.calPassouHa(-d);
  if (d == 0) return l.calEhHoje;
  return l.calFaltamDias(d);
}

/// O valor é uma estimativa (IUC/IPO/contribuição da SS) — leva a etiqueta "aproximado".
bool valorEhAproximado(ObrigacaoItem o) => const {'iuc', 'ipo', 'ss_pagamento'}.contains(o.tipo);

/// O texto "como pagar": o da obrigação; se vazio, o texto por tipo.
String comoPagarDe(AppLocalizations l, ObrigacaoItem o) {
  final proprio = (o.comoPagar ?? '').trim();
  if (proprio.isNotEmpty) return proprio;
  return switch (o.tipo) {
    'ss_declaracao' || 'ss_pagamento' || 'fim_isencao_ss' => l.calComoPagarSs,
    'iva_declaracao' ||
    'iva_pagamento' ||
    'irs_entrega' ||
    'irs_pagamento_conta' ||
    'efatura_validar' ||
    'recibos_comunicar' =>
      l.calComoPagarFiscal,
    'iuc' => l.calComoPagarIuc,
    'ipo' => l.calComoPagarIpo,
    'seguro' => l.calComoPagarSeguro,
    'multa' => l.calComoPagarMulta,
    _ => l.calComoPagarOutro,
  };
}

/// Site onde se trata (para o botão "Abrir…"); null se não há site certo.
({Uri url, String nome})? siteDoTipo(AppLocalizations l, String tipo) => switch (tipo) {
      'ss_declaracao' || 'ss_pagamento' || 'fim_isencao_ss' => (
          url: Uri.parse('https://app.seg-social.pt/sso/login'),
          nome: l.calSiteSS,
        ),
      'iva_declaracao' ||
      'iva_pagamento' ||
      'irs_entrega' ||
      'irs_pagamento_conta' ||
      'efatura_validar' ||
      'recibos_comunicar' ||
      'iuc' =>
        (url: Uri.parse('https://www.portaldasfinancas.gov.pt'), nome: l.calSitePF),
      'tvde_certificado' || 'tvde_licenca' || 'carta' || 'troca_carta' => (
          url: Uri.parse('https://www.imt-ip.pt'),
          nome: l.calSiteImt,
        ),
      'residencia' => (url: Uri.parse('https://aima.gov.pt'), nome: l.calSiteAima),
      _ => null,
    };

/// Nome legível da regra (`origem_regra`) que gerou a obrigação; null se não há.
String? nomeDaRegra(AppLocalizations l, String? chave) {
  if (chave == null || chave.trim().isEmpty) return null;
  return switch (chave) {
    'ss_declaracao_meses' => l.calRegraSsDeclaracao,
    'ss_pagamento_dia_fim' => l.calRegraSsPagamento,
    'ss_isencao_meses' => l.calRegraSsIsencao,
    'iva_declaracao_trimestral_dia' => l.calRegraIvaDeclaracao,
    'iva_pagamento_dia' => l.calRegraIvaPagamento,
    'irs_entrega_fim' => l.calRegraIrsEntrega,
    'efatura_validar_ate' => l.calRegraEfatura,
    'irs_pagamentos_conta_pct' => l.calRegraIrsConta,
    'recibos_comunicar_dia' => l.calRegraRecibos,
    'tvde_certificado_validade_anos' => l.calRegraTvde,
    'troca_carta_estrangeira_prazo_anos' => l.calRegraResidencia,
    'iuc_regra' => l.calRegraIuc,
    'ipo_tvde' || 'ipo_ligeiros_anos' => l.calRegraIpo,
    'seguro_aviso_dias' => l.calRegraSeguro,
    'carta_validade' => l.calRegraCarta,
    'manual' => l.calRegraManual,
    _ => l.calRegraOutra(chave.replaceAll('_', ' ')),
  };
}
