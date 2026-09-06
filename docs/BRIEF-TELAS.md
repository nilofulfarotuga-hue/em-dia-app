# BRIEF DAS TELAS — o que cada agente de ecrã tem de saber (bloco 2)

> Lido por quem constrói um ecrã. Fontes: `docs/PROMPT_MISSAO_2026-09-05.md` (secção 2 = a tela, secção 6 = as mensagens),
> `docs/DESIGN-SYSTEM.md` (paleta, tipos, componentes, critério do fiscal), `docs/referencias/` (capturas reais).

## O que já existe (usa, não reinventes)
- **Tema**: `lib/config/app_theme.dart` (`AppTheme.claro`; Inter explícito em tudo) e `lib/config/app_colors.dart` (`AppColors.emDia/aVencer/passou`, claros, `cadeado`).
- **Widgets partilhados**: `lib/widgets/widgets.dart` — `SemaforoGrande`, `Cartao`, `TituloSeccao`, `BotaoGrande`, `BotaoEscolha`, `Etiqueta`, `Cadeado`, `LinhaValor`, `Vazio`, `Aviso`, `paddingEcra`, enum `Semaforo`.
- **Regras (puro Dart, testado)**: `lib/regras/regras.dart` exporta tudo: `RegrasLegais` (`r.n('chave')`, `r.txt`, `r.json`, `r.escaloesDoAno`, `r.feriados`), `calcularRecibo`, `vigiaIva`, `calcularSS`/`estimarSSMensal`/`fimIsencaoSS`/`mesesDeIsencaoRestantes`/`primeiraDeclaracaoTrimestral`, `calcularIrs`/`datasPagamentosPorConta`, `prazoIuc`/`proximoIuc`/`proximaIpo`/`calendarioIpo`/`avisoSeguro`/`estimarIuc`/`custoPorKm`/`prazoMulta`, `gerarObrigacoes` (pré-visualização), datas (`hojeLisboa`, `avisoEm`, `adicionarMeses`, `diasAte`) e formatos (`moeda`, `dataPt`, `dataExtensoPt`, `nomeMes`, `pct`, `lerNumero`). NUNCA cravar números legais num ecrã: vêm de `RegrasStore.regras`.
- **Stores (Provider)**: `SessaoStore` (user, sair), `PerfilStore` (perfil, guardar), `RegrasStore` (regras do servidor com espelho local), `PlanoStore` (`planoEfetivo`, `permitida('chave')`, `limite('chave')`, `emTrial`), `ObrigacoesStore` (itens, recalcular, marcarPaga, pendentes/passadas/aVencer/doMes/proxima), `RendimentosStore` (itens, guardar, totalDoAno, totalTrimestre, mediaMensal), `CarrosStore` (carros, guardarCarro, abastecimentos, despesas, custoKm). Ficheiros: `lib/stores/*.dart`. Modelos em `lib/models/*.dart` (`Perfil`, `Carro`, `Abastecimento`, `DespesaCarro`, `ObrigacaoItem`, `Rendimento`).
- **Servidor**: `sb` (cliente Supabase) e `temChaves` em `lib/services/arranque.dart`. Edge Functions: `calcular-obrigacoes` (POST sem corpo), `ia-responder` ({pergunta, modo}), `ler-extrato` ({imagem_base64, mime}), `suporte-auto` ({tipo, assunto, descricao, logs}), `validar-compra-play` ({produto_id, token_compra}). Chamam-se com `sb.functions.invoke('nome', body: {...})`; 402 = limite/cadeado do plano; 503 = serviço sem chave (mostrar mensagem humana, nunca crash).
- **Traduções**: NUNCA texto cravado no widget. Cada ecrã acrescenta as suas chaves em `lib/l10n/partes/<NN>_<tela>_pt.arb` e `_pt_BR.arb` (prefixo da tela nas chaves, ex. `painel...`), corre `python tool/l10n/merge.py` (gera `lib/l10n/app_pt.arb`/`app_pt_BR.arb`) e `flutter gen-l10n`. Usa `AppLocalizations.of(context)` (import `../../l10n/app_localizations.dart`). As chaves comuns já existentes estão em `lib/l10n/partes/00_comum_pt.arb` (nav, onboarding, login, calc, vigia, ss, irs, rend, cal, carro, reforma, guias, ia, suporte, plano, erros).
- **Navegação**: `lib/app.dart` (`RaizNavegador`: login → onboarding → `ShellScreen` com 5 abas em `lib/screens/shell/shell_screen.dart`). Ecrãs secundários abrem com `Navigator.push`. Nada de rotas nomeadas.
- **Fotos (golden)**: `test/golden/fabrica_de_fotos.dart` — `carregaFonteInter()`, `carregaFontesSdk()`, `fotografaSuite(tester, nome:, tela: () => Widget, comTeclado:)` (3 tamanhos × PT/BR × com/sem teclado). Exemplo: `test/golden/login_test.dart`. Os ecrãs têm de ser fotografáveis SEM servidor: aceitar dados por construtor/`Provider` com stores em modo teste (usa `MultiProvider` com stores pré-carregados — cria em `test/golden/_apoio.dart` fábricas de stores falsas se precisares; `SessaoStore.semServidor()` já existe).

## Regras do ecrã (o fiscal reprova se falhar)
1. Uma ideia por ecrã; o número mais importante é o maior do ecrã.
2. Linguagem de criança de 5 anos, tratamento por **tu** (PT-PT); jargão só com explicação entre parênteses.
3. Um laranja por ecrã. Botão principal visível sem scroll. Texto útil ≥ 13 px. Alvos ≥ 48 px.
4. Estados: a carregar (skeleton), vazio (`Vazio`), erro de rede (`Aviso` vermelho com `erroRede`), cadeado (`Cadeado` + `PlanoStore.permitida`).
5. Todo aviso termina com o passo concreto e o prazo.
6. Sem overflow em 360×780 com teclado e em PT-BR (textos maiores).
7. Nada de `print`, nada de `TODO` deixado, `flutter analyze` limpo no teu ficheiro.

## Prova por ecrã (obrigatória)
- `flutter analyze` sem erros; `flutter test test/golden/<tela>_test.dart` verde com as fotos em `test/golden/_fotos/`.
- `python tool/juiz/vision_judge.py --filtro <tela>` sem vermelhos (usa a chave Gemini de `C:\BoraLocal\_segredos\em-dia\gemini.env`; relatório em `docs/provas/telas/`).
- Uma linha em `docs/provas/telas/RESUMO.md`: `| tela | fotos | juiz (verde/amarelo/vermelho) | data |`.
