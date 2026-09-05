// Em Dia — a app (PT-PT). Painel admin: lib/main_admin.dart.
import 'package:flutter/material.dart';

import 'app.dart';
import 'services/arranque.dart';

Future<void> main() async {
  await arrancar();
  runApp(const EmDiaApp());
}
