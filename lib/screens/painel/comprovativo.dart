import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart' show ImagePickerPlatform;
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;

import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/obrigacao.dart';
import '../../regras/regras.dart';
import '../../services/arranque.dart';
import '../../stores/dados_store.dart';
import '../../stores/regras_store.dart';
import '../../widgets/widgets.dart';
import 'cartoes_painel.dart' show nomeHumano;

/// Bucket privado do Supabase Storage (migration 0007). Caminho do ficheiro:
/// `{userId}/{obrigacaoId}.jpg` — a política RLS só deixa o dono ler/escrever
/// o seu prefixo.
const String bucketComprovativos = 'comprovativos';

bool _photoPickerLigado = false;

/// No Android usa o Photo Picker (sem pedir permissão de galeria inteira).
/// Idempotente; chamar no arranque do ecrã.
void ligarPhotoPickerAndroid() {
  if (_photoPickerLigado || kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  final p = ImagePickerPlatform.instance;
  if (p is ImagePickerAndroid) p.useAndroidPhotoPicker = true;
  _photoPickerLigado = true;
}

/// Depois de "Já paguei": pergunta se quer juntar a foto do comprovativo.
/// Se o plano não deixar (`comprovativos_guardar`), mostra a explicação de
/// uma linha em vez do botão.
Future<void> perguntarComprovativo(BuildContext context, {required ObrigacaoItem obrigacao}) async {
  final l = AppLocalizations.of(context);
  final permitido = context.read<PlanoStore>().permitida('comprovativos_guardar');

  final quer = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final t = Theme.of(ctx).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.painelComprovativoPergunta, style: t.headlineSmall),
              const SizedBox(height: 8),
              Text(l.painelComprovativoAjuda, style: t.bodyMedium!.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              if (permitido) ...[
                BotaoGrande(
                  texto: l.juntarComprovativo,
                  icone: Icons.photo_library_rounded,
                  aoTocar: () => Navigator.of(ctx).pop(true),
                ),
                const SizedBox(height: 8),
                BotaoGrande(texto: l.painelAgoraNao, secundario: true, aoTocar: () => Navigator.of(ctx).pop(false)),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cadeadoClaro,
                    borderRadius: AppTheme.cantosPequenos,
                    border: Border.all(color: AppColors.cadeado.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, color: AppColors.cadeado, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('${l.planoCadeado} · ${l.painelCadeadoComprovativo}',
                            style: const TextStyle(
                                fontFamily: AppTheme.fonte,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cadeado)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                BotaoGrande(texto: l.ok, aoTocar: () => Navigator.of(ctx).pop(false)),
              ],
            ],
          ),
        ),
      );
    },
  );
  if (quer != true || !context.mounted) return;
  await juntarComprovativo(context, obrigacao);
}

/// Escolhe a foto (Photo Picker), envia para o bucket e guarda o caminho na
/// obrigação. Mostra o resultado numa snackbar — nunca falha em silêncio.
Future<void> juntarComprovativo(BuildContext context, ObrigacaoItem obrigacao) async {
  final l = AppLocalizations.of(context);
  final obrig = context.read<ObrigacoesStore>();
  final mensageiro = ScaffoldMessenger.of(context);
  try {
    final foto = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 80);
    if (foto == null) return;
    final bytes = await foto.readAsBytes();
    final caminho = '${obrigacao.userId}/${obrigacao.id}.jpg';
    await sb.storage.from(bucketComprovativos).uploadBinary(
          caminho,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    final ok = await obrig.marcarPaga(obrigacao, comprovativoUrl: caminho);
    mensageiro.showSnackBar(SnackBar(content: Text(ok ? l.painelComprovativoOk : l.painelComprovativoErro)));
  } catch (e) {
    debugPrint('comprovativo: $e');
    mensageiro.showSnackBar(SnackBar(content: Text(l.painelComprovativoErro)));
  }
}

/// Texto "como pagar" quando a obrigação não trouxe o seu.
String comoPagarPorTipo(AppLocalizations l, String tipo) => switch (tipo) {
      'ss_declaracao' || 'ss_pagamento' || 'fim_isencao_ss' => l.painelComoPagarSs,
      'iva_declaracao' || 'iva_pagamento' => l.painelComoPagarIva,
      'irs_entrega' || 'irs_pagamento_conta' => l.painelComoPagarIrs,
      'iuc' => l.painelComoPagarIuc,
      'ipo' => l.painelComoPagarIpo,
      'seguro' => l.painelComoPagarSeguro,
      _ => l.painelComoPagarGenerico,
    };

/// Bottom sheet "Como pagar": o texto da obrigação ou o texto por tipo.
Future<void> mostrarComoPagar(BuildContext context, ObrigacaoItem obrigacao) {
  final l = AppLocalizations.of(context);
  final texto = (obrigacao.comoPagar ?? '').trim().isNotEmpty ? obrigacao.comoPagar!.trim() : comoPagarPorTipo(l, obrigacao.tipo);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final t = Theme.of(ctx).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.comoPagar, style: t.labelSmall!.copyWith(letterSpacing: 0.8)),
              const SizedBox(height: 4),
              Text(nomeHumano(l, obrigacao), style: t.headlineSmall),
              const SizedBox(height: 4),
              Text(
                obrigacao.valorEstimado == null
                    ? l.painelComoPagarAte(dataExtensoPt(obrigacao.dataLimite))
                    : '${l.painelComoPagarAte(dataExtensoPt(obrigacao.dataLimite))} · ${moeda(obrigacao.valorEstimado!)}',
                style: t.bodyMedium!.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Flexible(child: SingleChildScrollView(child: Text(texto, style: t.bodyLarge))),
              const SizedBox(height: 20),
              BotaoGrande(texto: l.ok, aoTocar: () => Navigator.of(ctx).pop()),
            ],
          ),
        ),
      );
    },
  );
}
