/// Descarregar um ficheiro de texto (CSV) pelo browser — só existe na web.
///
/// Na web (`dart.library.js_interop`) cria um Blob e um `<a download>`; no
/// resto (testes na VM) devolve `false` e quem chama mostra o texto para copiar,
/// como dantes (B7, 2026-09-18).
library;

export 'descarregar_stub.dart' if (dart.library.js_interop) 'descarregar_web.dart';
