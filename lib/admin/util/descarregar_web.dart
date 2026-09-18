import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web: um Blob com BOM (para o Excel abrir o CSV em UTF-8) + `<a download>`.
Future<bool> descarregarTexto({required String nome, required String conteudo, String tipo = 'text/csv;charset=utf-8'}) async {
  try {
    final partes = ['﻿$conteudo'.toJS].toJS;
    final blob = web.Blob(partes, web.BlobPropertyBag(type: tipo));
    final url = web.URL.createObjectURL(blob);
    final a = web.HTMLAnchorElement()
      ..href = url
      ..download = nome
      ..style.display = 'none';
    web.document.body!.append(a);
    a.click();
    a.remove();
    web.URL.revokeObjectURL(url);
    return true;
  } catch (_) {
    return false;
  }
}
