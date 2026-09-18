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
      'ss_declaracao' || 'ss_pagamento' || 'fim_isencao_ss' || 'ss_empresa' || 'dmr' => GrupoObrigacao.ss,
      'iva_declaracao' ||
      'iva_pagamento' ||
      'irs_entrega' ||
      'irs_pagamento_conta' ||
      'efatura_validar' ||
      'recibos_comunicar' ||
      'saft' ||
      'irc_modelo22' ||
      'irc_pagamento_conta' ||
      'ies' ||
      'faturas_nif' =>
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
      // B3 — contrato e empresa
      'subsidio_natal' => Icons.card_giftcard_rounded,
      'faturas_nif' => Icons.receipt_rounded,
      'dmr' || 'ss_empresa' => Icons.groups_rounded,
      'saft' => Icons.upload_file_rounded,
      'irc_modelo22' || 'irc_pagamento_conta' || 'ies' => Icons.apartment_rounded,
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
      'ss_declaracao' || 'ss_pagamento' || 'fim_isencao_ss' || 'ss_empresa' => (
          url: Uri.parse('https://app.seg-social.pt/sso/login'),
          nome: l.calSiteSS,
        ),
      'iva_declaracao' ||
      'iva_pagamento' ||
      'irs_entrega' ||
      'irs_pagamento_conta' ||
      'recibos_comunicar' ||
      'iuc' ||
      'dmr' ||
      'saft' ||
      'irc_modelo22' ||
      'irc_pagamento_conta' ||
      'ies' =>
        (url: Uri.parse('https://www.portaldasfinancas.gov.pt'), nome: l.calSitePF),
      // A página CERTA das faturas, não a entrada do portal.
      'efatura_validar' || 'faturas_nif' => (url: Uri.parse('https://faturas.portaldasfinancas.gov.pt/'), nome: l.calSitePF),
      // O subsídio de Natal não se pede a lado nenhum: quem manda é o Código do Trabalho (ACT).
      'subsidio_natal' => (url: Uri.parse('https://www.act.gov.pt/'), nome: 'ACT'),
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
    // B3 — as regras novas, com o nome da fonte (docs/REGRAS-PT-2026.md)
    'subsidio_natal_ate' => 'Código do Trabalho, art. 263.º',
    'deducoes_irs' => 'Código do IRS, art. 78.º-A a F',
    'dmr_dia' => 'Agenda fiscal da AT (DMR até dia 10)',
    'saft_dia' => 'Agenda fiscal da AT (faturas até dia 5)',
    'ss_empregador_pagamento_dia_fim' => 'Código Contributivo, art. 43.º (até dia 25)',
    'iva_mensal_declaracao_dia' => 'CIVA art. 41.º (mensal, dia 20)',
    'irc_modelo22_data' => 'CIRC art. 120.º (31 de maio)',
    'ies_data' => 'Agenda fiscal da AT (IES, 15 de julho)',
    'irc_pagamentos_conta_datas' => 'Agenda fiscal da AT (PPC de IRC)',
    _ => l.calRegraOutra(chave.replaceAll('_', ' ')),
  };
}
