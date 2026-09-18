/// Fora da web não há «download»: devolve false e quem chama abre a caixa
/// de copiar.
Future<bool> descarregarTexto({required String nome, required String conteudo, String tipo = 'text/csv;charset=utf-8'}) async => false;
