import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../regras/extrato_banco.dart';
import '../../regras/regras.dart';
import '../../stores/banco_store.dart';
import '../../stores/sessao_store.dart';
import '../../widgets/widgets.dart';
import 'recorrentes_screen.dart';

/// Importar o extrato do banco (B2a): a pessoa escolhe o ficheiro CSV ou
/// Excel que o banco exportou, vê o que a app leu (o que entrou, o que saiu,
/// a categoria e o que se repete) e só então carrega em «Guardar». O ficheiro
/// é lido no aparelho; ao servidor vão só as linhas já arrumadas.
///
/// Sem SMS, sem Gmail, sem ligação ao banco por dentro (D23). O PDF não se
/// lê aqui: todos os bancos exportam CSV/Excel, e o PDF obrigava a mandar o
/// extrato inteiro para a inteligência artificial — ver `pdf_nao_suportado`.
class ImportarExtratoScreen extends StatefulWidget {
  /// Ficheiro já lido (para as fotos e os testes, sem seletor de ficheiros).
  final ExtratoLido? exemplo;
  final String? nomeExemplo;
  const ImportarExtratoScreen({super.key, this.exemplo, this.nomeExemplo});

  @override
  State<ImportarExtratoScreen> createState() => _ImportarExtratoScreenState();
}

class _ImportarExtratoScreenState extends State<ImportarExtratoScreen> {
  ExtratoLido? _lido;
  String _nome = '';
  String? _erro;
  bool _aTrabalhar = false;
  ResultadoImportacao? _resultado;

  @override
  void initState() {
    super.initState();
    _lido = widget.exemplo;
    _nome = widget.nomeExemplo ?? '';
  }

  Future<void> _escolher() async {
    final l = AppLocalizations.of(context);
    final banco = context.read<BancoStore>();
    final userId = context.read<SessaoStore>().userId;
    setState(() {
      _erro = null;
      _resultado = null;
    });
    const tipos = XTypeGroup(label: 'Extrato', extensions: ['csv', 'txt', 'xlsx', 'xls', 'pdf']);
    final XFile? escolhido;
    try {
      escolhido = await openFile(acceptedTypeGroups: const [tipos]);
    } catch (e) {
      setState(() => _erro = l.importarErroAbrir);
      return;
    }
    if (escolhido == null) return;
    final f = escolhido;
    final Uint8List bytes = await f.readAsBytes();
    try {
      final lido = banco.ler(bytes, f.name);
      setState(() {
        _lido = lido;
        _nome = f.name;
        if (lido.vazio) _erro = l.importarErroVazio;
      });
    } on ExtratoInvalido catch (e) {
      setState(() {
        _lido = null;
        _nome = f.name;
        _erro = switch (e.motivo) {
          'pdf_nao_suportado' => l.importarErroPdf,
          'sem_cabecalho' => l.importarErroCabecalho,
          'excel_ilegivel' => l.importarErroExcel,
          _ => l.importarErroVazio,
        };
      });
      if (userId != null) await banco.registarFalha(userId, f.name, e.motivo);
    }
  }

  Future<void> _guardar() async {
    final l = AppLocalizations.of(context);
    final banco = context.read<BancoStore>();
    final userId = context.read<SessaoStore>().userId;
    final lido = _lido;
    if (lido == null || userId == null) return;
    setState(() => _aTrabalhar = true);
    final r = await banco.guardar(userId, lido, nomeFicheiro: _nome);
    if (!mounted) return;
    setState(() {
      _aTrabalhar = false;
      _resultado = r;
      _erro = r.erro == null ? null : l.erroRede;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final banco = context.watch<BancoStore>();
    final lido = _lido;
    final recorrentes = lido == null ? const <Recorrente>[] : encontrarRecorrentes(lido.movimentos);
    final entrou = lido == null ? 0.0 : lido.movimentos.where((m) => m.entra).fold(0.0, (s, m) => s + m.valor);
    final saiu = lido == null ? 0.0 : lido.movimentos.where((m) => !m.entra).fold(0.0, (s, m) => s + m.valor.abs());
    final resultado = _resultado;

    return Scaffold(
      appBar: AppBar(title: Text(l.importarTitulo)),
      body: ListView(
        padding: paddingEcra,
        children: [
          Text(l.importarExplica, style: t.bodyLarge),
          const SizedBox(height: 8),
          Text(l.importarComoExportar, style: t.bodySmall!.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          BotaoGrande(
            texto: lido == null ? l.importarEscolher : l.importarEscolherOutro,
            icone: Icons.upload_file_rounded,
            secundario: lido != null,
            aTrabalhar: false,
            aoTocar: _aTrabalhar ? null : _escolher,
          ),
          if (_erro != null) ...[
            const SizedBox(height: 12),
            Aviso(_erro!, tom: Semaforo.vermelho, icone: Icons.error_outline_rounded),
          ],
          if (resultado != null && resultado.erro == null) ...[
            const SizedBox(height: 12),
            Aviso(
              resultado.novas == 0 ? l.importarGuardadoNada(resultado.repetidas) : l.importarGuardado(resultado.novas, resultado.repetidas),
              tom: Semaforo.verde,
              icone: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(height: 12),
            BotaoGrande(
              texto: l.recorrentesVerBotao,
              icone: Icons.repeat_rounded,
              aoTocar: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RecorrentesScreen())),
            ),
          ],
          if (lido != null && resultado == null) ...[
            const SizedBox(height: 20),
            TituloSeccao(l.importarOQueLi(_nome.isEmpty ? l.importarFicheiro : _nome)),
            Cartao(
              child: Column(
                children: [
                  LinhaValor(l.importarLinhasLidas, '${lido.movimentos.length}'),
                  LinhaValor(l.importarEntrou, moeda(entrou)),
                  LinhaValor(l.importarSaiu, moeda(saiu)),
                  if (lido.banco != null) LinhaValor(l.importarBanco, _nomeBanco(lido.banco!)),
                  if (recorrentes.isNotEmpty) LinhaValor(l.importarRepetem(recorrentes.length), moeda(totalMensalRecorrente(recorrentes))),
                  if (lido.linhasIgnoradas.isNotEmpty)
                    LinhaValor(l.importarIgnoradas, '${lido.linhasIgnoradas.length}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: Text(l.importarPrivacidade, style: t.bodySmall!.copyWith(color: AppColors.textSecondary))),
                BotaoOuvir(etiqueta: 'importar-resumo', texto: '${l.importarExplica} ${l.importarEntrou} ${moeda(entrou)}. ${l.importarSaiu} ${moeda(saiu)}.'),
              ],
            ),
            const SizedBox(height: 16),
            BotaoGrande(
              texto: l.importarGuardarBotao(lido.movimentos.length),
              icone: Icons.save_rounded,
              aTrabalhar: _aTrabalhar,
              aoTocar: lido.vazio || _aTrabalhar ? null : _guardar,
            ),
            const SizedBox(height: 20),
            TituloSeccao(l.importarMovimentos),
            for (final m in lido.movimentos.take(60)) _LinhaMovimento(m: m, categoria: banco.categoria(m), recorrente: recorrentes.any((r) => r.chave == normalizarDescricao(m.descricao))),
            if (lido.movimentos.length > 60)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l.importarMaisLinhas(lido.movimentos.length - 60), textAlign: TextAlign.center, style: t.bodySmall),
              ),
          ],
        ],
      ),
    );
  }

  String _nomeBanco(String chave) => switch (chave) {
        'cgd' => 'Caixa Geral de Depósitos',
        'millennium' => 'Millennium bcp',
        'santander' => 'Santander',
        'novobanco' => 'Novobanco',
        'bpi' => 'BPI',
        'activobank' => 'ActivoBank',
        'moey' => 'Moey',
        'revolut' => 'Revolut',
        'montepio' => 'Montepio',
        'bankinter' => 'Bankinter',
        'credito_agricola' => 'Crédito Agrícola',
        _ => chave,
      };
}

/// Uma linha do extrato: dia, descrição, categoria, valor (verde entra,
/// preto sai) e a etiqueta «repete-se».
class _LinhaMovimento extends StatelessWidget {
  final MovimentoLido m;
  final ({String categoria, String? fornecedor}) categoria;
  final bool recorrente;
  const _LinhaMovimento({required this.m, required this.categoria, required this.recorrente});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Cartao(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text('${m.data.day}', style: t.titleMedium),
                Text(nomeMes(m.data.month).substring(0, 3), style: t.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(categoria.fornecedor ?? m.descricao, style: t.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Wrap(
                  spacing: 6,
                  children: [
                    Etiqueta(nomeCategoriaMovimento(l, categoria.categoria), cor: AppColors.surface2, corTexto: AppColors.textSecondary),
                    if (recorrente) Etiqueta(l.importarRepeteSe, cor: AppColors.emDiaClaro, corTexto: AppColors.primaryDark, icone: Icons.repeat_rounded),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            (m.entra ? '+' : '−') + moeda(m.valor.abs()),
            style: t.titleMedium!.copyWith(color: m.entra ? AppColors.primaryDark : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

/// O nome humano da categoria de um movimento do banco (as de `saidas` mais
/// «entrada» e «rendimento»).
String nomeCategoriaMovimento(AppLocalizations l, String c) => switch (c) {
      'rendimento' => l.importarCatRendimento,
      'entrada' => l.importarCatEntrada,
      'renda' => l.saidasCatRenda,
      'luz' => l.saidasCatLuz,
      'agua' => l.saidasCatAgua,
      'gas' => l.saidasCatGas,
      'telemovel' => l.saidasCatTelemovel,
      'internet' => l.saidasCatInternet,
      'tv' => l.saidasCatTv,
      'seguro' => l.saidasCatSeguro,
      'ginasio' => l.saidasCatGinasio,
      'escola' => l.saidasCatEscola,
      'creche' => l.saidasCatCreche,
      'credito' => l.saidasCatCredito,
      'carro' => l.saidasCatCarro,
      'combustivel' => l.saidasCatCombustivel,
      'compras' => l.saidasCatCompras,
      'saude' => l.saidasCatSaude,
      'assinatura' => l.saidasCatAssinatura,
      'imposto' => l.saidasCatImposto,
      _ => l.saidasCatOutro,
    };
