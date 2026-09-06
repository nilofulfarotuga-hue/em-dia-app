// Widgets partilhados do painel admin (desktop, PT-BR). Compõem os widgets da
// app (Cartao, Aviso, Vazio, Etiqueta) num layout de largura máxima 1100.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/app_colors.dart';
import '../config/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../regras/regras.dart';
import '../widgets/widgets.dart';

const double larguraMaxAdmin = 1100;

/// Página de secção: título, subtítulo, ações à direita e o conteúdo em lista.
class PaginaAdmin extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final List<Widget> acoes;
  final List<Widget> children;
  const PaginaAdmin({super.key, required this.titulo, this.subtitulo, this.acoes = const [], required this.children});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: larguraMaxAdmin),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: t.headlineMedium),
                      if (subtitulo != null) ...[const SizedBox(height: 4), Text(subtitulo!, style: t.bodySmall)],
                    ],
                  ),
                ),
                for (final a in acoes) Padding(padding: const EdgeInsets.only(left: 8), child: a),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Botão compacto (o tema tem botões de 56 px para o telemóvel; aqui são de 40).
class BotaoPequeno extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final VoidCallback? aoTocar;
  final bool secundario;
  final bool perigo;
  const BotaoPequeno(this.texto, {super.key, this.icone, required this.aoTocar, this.secundario = false, this.perigo = false});

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(fontFamily: AppTheme.fonte, fontSize: 14, fontWeight: FontWeight.w600);
    final filho = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icone != null) ...[Icon(icone, size: 18), const SizedBox(width: 6)],
        Text(texto),
      ],
    );
    if (secundario) {
      return OutlinedButton(
        onPressed: aoTocar,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 40),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          textStyle: estilo,
          foregroundColor: perigo ? AppColors.passou : AppColors.primaryDark,
          side: BorderSide(color: perigo ? AppColors.passou : AppColors.primary, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: AppTheme.cantosPequenos),
        ),
        child: filho,
      );
    }
    return FilledButton(
      onPressed: aoTocar,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: estilo,
        backgroundColor: perigo ? AppColors.passou : AppColors.primary,
        shape: const RoundedRectangleBorder(borderRadius: AppTheme.cantosPequenos),
      ),
      child: filho,
    );
  }
}

/// Cartão com um número grande (visão geral).
class CartaoNumero extends StatelessWidget {
  final String rotulo;
  final String valor;
  final String? sub;
  final IconData icone;
  final Color cor;
  final bool alarme;
  const CartaoNumero({
    super.key,
    required this.rotulo,
    required this.valor,
    this.sub,
    required this.icone,
    this.cor = AppColors.primary,
    this.alarme = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Cartao(
      cor: alarme ? AppColors.passouClaro : null,
      bordo: alarme ? AppColors.passou : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 20, color: alarme ? AppColors.passou : cor),
              const SizedBox(width: 8),
              Expanded(child: Text(rotulo, style: t.labelSmall!.copyWith(letterSpacing: 0.6), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 10),
          Text(valor, style: t.displayMedium!.copyWith(color: alarme ? AppColors.passou : AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}

/// Esqueleto cinzento (a carregar).
class Esqueleto extends StatelessWidget {
  final int linhas;
  final double altura;
  const Esqueleto({super.key, this.linhas = 6, this.altura = 18});

  @override
  Widget build(BuildContext context) {
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < linhas; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: FractionallySizedBox(
                widthFactor: i.isEven ? 0.9 : 0.6,
                child: Container(
                  height: altura,
                  decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Estados de uma leitura: a carregar (esqueleto) · erro (Aviso vermelho +
/// tentar de novo) · vazio (Vazio) · dados (builder).
class Leitura<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final bool Function(T)? vazio;
  final String? textoVazio;
  final VoidCallback? aoTentarDeNovo;
  final int linhasEsqueleto;
  const Leitura({
    super.key,
    required this.future,
    required this.builder,
    this.vazio,
    this.textoVazio,
    this.aoTentarDeNovo,
    this.linhasEsqueleto = 6,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Aviso(l.admErroLer(snap.error.toString()), tom: Semaforo.vermelho),
              if (aoTentarDeNovo != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: BotaoPequeno(l.admTentarDeNovo, icone: Icons.refresh_rounded, aoTocar: aoTentarDeNovo, secundario: true),
                ),
              ],
            ],
          );
        }
        if (!snap.hasData) return Esqueleto(linhas: linhasEsqueleto);
        final d = snap.data as T;
        if (vazio != null && vazio!(d)) {
          return Cartao(child: Vazio(icone: Icons.inbox_outlined, texto: textoVazio ?? l.admVazio));
        }
        return builder(context, d);
      },
    );
  }
}

/// Tabela em cartão com scroll horizontal (as colunas nunca partem o layout).
class TabelaAdmin extends StatelessWidget {
  final List<String> colunas;
  final List<DataRow> linhas;
  final String? titulo;
  const TabelaAdmin({super.key, required this.colunas, required this.linhas, this.titulo});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Cartao(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != null) Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 4), child: Text(titulo!, style: t.titleMedium)),
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                headingTextStyle: t.labelSmall!.copyWith(letterSpacing: 0.4),
                dataTextStyle: t.bodyMedium!.copyWith(fontSize: 14),
                columnSpacing: 20,
                horizontalMargin: 12,
                headingRowHeight: 40,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 56,
                columns: [for (final c in colunas) DataColumn(label: Text(c))],
                rows: linhas,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Célula de texto cortada a [max] caracteres (as tabelas não quebram linha).
DataCell celula(String? texto, {int max = 48, TextStyle? estilo}) {
  final s = (texto ?? '').replaceAll('\n', ' ');
  return DataCell(Text(s.length > max ? '${s.substring(0, max)}…' : s, style: estilo, overflow: TextOverflow.ellipsis));
}

/// Cor de uma pílula de estado (tickets, planos, push, confiança…).
Color corEstado(String estado) => switch (estado) {
      'aberto' || 'trial' || 'pendente' => AppColors.info,
      'em_curso' || 'aproximado' => AppColors.aVencer,
      'fechado' || 'ok' || 'pago' || 'ativa' || 'oficial' || 'enviado' => AppColors.emDia,
      'erro' || 'passado' || 'por_confirmar' || 'banido' || 'expirada' || 'cancelada' => AppColors.passou,
      'pro' => AppColors.cadeado,
      'familia' => AppColors.primaryDeep,
      _ => AppColors.textSecondary,
    };

/// Pílula de estado com a cor do [corEstado].
class Pilula extends StatelessWidget {
  final String estado;
  final String? texto;
  const Pilula(this.estado, {super.key, this.texto});

  @override
  Widget build(BuildContext context) => Etiqueta(texto ?? estado, cor: corEstado(estado));
}

/// Filtro de chips (uma opção ativa; `null` = todos).
class ChipsFiltro<T> extends StatelessWidget {
  final List<(T?, String)> opcoes;
  final T? valor;
  final ValueChanged<T?> aoMudar;
  const ChipsFiltro({super.key, required this.opcoes, required this.valor, required this.aoMudar});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (v, rotulo) in opcoes)
          ChoiceChip(
            label: Text(rotulo),
            selected: v == valor,
            onSelected: (_) => aoMudar(v),
            showCheckmark: false,
          ),
      ],
    );
  }
}

/// Campo de texto compacto para as folhas de edição.
class CampoAdmin extends StatelessWidget {
  final TextEditingController controlador;
  final String rotulo;
  final String? ajuda;
  final int linhas;
  final TextInputType? tipo;
  final bool somenteLeitura;
  const CampoAdmin({
    super.key,
    required this.controlador,
    required this.rotulo,
    this.ajuda,
    this.linhas = 1,
    this.tipo,
    this.somenteLeitura = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controlador,
        readOnly: somenteLeitura,
        maxLines: linhas,
        keyboardType: tipo,
        style: const TextStyle(fontFamily: AppTheme.fonte, fontSize: 15),
        decoration: InputDecoration(
          labelText: rotulo,
          helperText: ajuda,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          fillColor: somenteLeitura ? AppColors.surface2 : null,
        ),
      ),
    );
  }
}

/// Folha lateral à direita (edição/detalhe), 520 px, altura toda.
Future<T?> folhaLateral<T>(BuildContext context, {required String titulo, required WidgetBuilder builder, double largura = 560}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'fechar',
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 180),
    transitionBuilder: (context, anim, _, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
      child: child,
    ),
    pageBuilder: (context, _, __) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: AppColors.surface,
        child: SizedBox(
          width: largura,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(child: Text(titulo, style: Theme.of(context).textTheme.headlineSmall, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
              ),
              const Divider(),
              Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(24, 12, 24, 24), child: builder(context))),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Erro de uma ação: nunca se engole — abre um diálogo com o Aviso vermelho.
Future<void> mostrarErro(BuildContext context, Object erro) {
  final l = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.admErroTitulo),
      content: SizedBox(width: 480, child: Aviso(erro.toString(), tom: Semaforo.vermelho)),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.admFechar))],
    ),
  );
}

/// Confirmação simples (sim/não).
Future<bool> confirmar(BuildContext context, {required String titulo, required String texto, bool perigo = false}) async {
  final l = AppLocalizations.of(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: SizedBox(width: 480, child: Text(texto)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.cancelar)),
        BotaoPequeno(l.admConfirmar, aoTocar: () => Navigator.of(context).pop(true), perigo: perigo),
      ],
    ),
  );
  return r == true;
}

/// Aviso rápido de sucesso.
void avisar(BuildContext context, String texto) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(texto)));
}

/// Texto copiável num diálogo (CSV, JSON).
Future<void> mostrarTextoCopiavel(BuildContext context, {required String titulo, required String texto, String? nota}) {
  final l = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: SizedBox(
        width: 720,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nota != null) ...[Text(nota, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 8)],
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface2, borderRadius: AppTheme.cantosPequenos),
                child: SingleChildScrollView(
                  child: SelectableText(texto, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.admFechar)),
        BotaoPequeno(l.admCopiar, icone: Icons.copy_rounded, aoTocar: () async {
          await Clipboard.setData(ClipboardData(text: texto));
          if (context.mounted) avisar(context, l.admCopiado);
        }),
      ],
    ),
  );
}

/// Linha "rótulo: valor" para as folhas de detalhe.
class LinhaDetalhe extends StatelessWidget {
  final String rotulo;
  final String valor;
  const LinhaDetalhe(this.rotulo, this.valor, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 180, child: Text(rotulo, style: t.bodySmall)),
          Expanded(child: SelectableText(valor.isEmpty ? '—' : valor, style: t.bodyMedium)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- formatos
String dataHoraPt(DateTime? d) {
  if (d == null) return '—';
  final l = d.toLocal();
  return '${dataPt(l)} ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
}

String dataOuTraco(DateTime? d) => d == null ? '—' : dataPt(d.toLocal());

DateTime? lerData(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());

String texto(dynamic v) => v == null ? '' : v.toString();

num? numero(dynamic v) => v == null ? null : (v is num ? v : num.tryParse(v.toString()));

/// `1.234,56 €` ou `—`.
String moedaOuTraco(dynamic v) {
  final n = numero(v);
  return n == null ? '—' : moeda(n);
}
