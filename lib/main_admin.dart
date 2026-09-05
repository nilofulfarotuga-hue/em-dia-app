// Painel admin (Flutter Web, PT-BR). Ponto de entrada separado — mesmo pacote,
// mesmo tema, mesmo cliente Supabase; build com `-t lib/main_admin.dart`.
// Os ecrãs vivem em lib/admin/ (bloco 2).
import 'package:flutter/material.dart';

import 'admin/admin_app.dart';
import 'services/arranque.dart';

Future<void> main() async {
  await arrancar();
  runApp(const AdminApp());
}
