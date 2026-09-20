import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/perfil.dart';
import 'arranque.dart';

/// Estatísticas de utilização (B7b). Só escreve se a pessoa ligou o
/// interruptor nas Definições (profiles.consentiu_estatisticas); sem
/// consentimento não há pedido nenhum ao servidor. Nunca lança: um erro
/// de rede ou de RLS fica em silêncio (é estatística, não é dado da conta).
enum EventoUso { abriuApp, concluiuOnboarding, viuPlano, iniciouCompra, comprou, cancelou }

class Uso {
  static String tipoDb(EventoUso e) => switch (e) {
        EventoUso.abriuApp => 'abriu_app',
        EventoUso.concluiuOnboarding => 'concluiu_onboarding',
        EventoUso.viuPlano => 'viu_plano',
        EventoUso.iniciouCompra => 'iniciou_compra',
        EventoUso.comprou => 'comprou',
        EventoUso.cancelou => 'cancelou',
      };

  static Future<void> registar(EventoUso e, {required Perfil? perfil, SupabaseClient? cliente}) async {
    if (perfil == null || !perfil.consentiuEstatisticas) return;
    try {
      await (cliente ?? sb).from('eventos_uso').insert({
        'user_id': perfil.userId,
        'tipo': tipoDb(e),
      });
    } catch (erro) {
      debugPrint('uso: não registou ${tipoDb(e)} ($erro)');
    }
  }
}
