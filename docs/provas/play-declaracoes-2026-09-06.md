# Prova — declarações da Play (2026-09-06, noite)

O PRÓXIMO em `docs/MARCOS.md` era: **segurança dos dados, classificação de
conteúdo, público-alvo e acesso à app**. Nesta sessão o servidor MCP do Chrome
caiu (`mcp__claude-in-chrome__*` indisponível), por isso não houve browser.
Das quatro, só a **segurança dos dados** tem endpoint próprio na API. Foi por aí.

## O que ficou feito

**A declaração está escrita, e é a Google que valida o ficheiro.** O modelo
oficial (`docs/loja/play/data-safety-modelo.csv`, 763 respostas possíveis,
descarregado de `storage.googleapis.com/support-kms-prod/b5v9It2Egwr…`, o mesmo
ficheiro que o artigo 10787469 serve em 14 idiomas) é preenchido por
`tool/play/data_safety.py` — 46 respostas — e sai em
`docs/loja/play/data-safety-em-dia.csv`.

O endpoint existe e a conta de serviço tem acesso. Prova, com o corpo vazio:

```
POST /androidpublisher/v3/applications/pt.emdia.app/dataSafety
HTTP 400: "Safety label data must be specified."
```

E com o CSV preenchido a Google já o **lê e valida linha a linha** — o erro
deixou de ser de formato.

## O que declaro que a app recolhe (verificado no código, não adivinhado)

| Tipo | Obrigatório? | Porquê |
|---|---|---|
| `PSL_EMAIL` | sim | entrar é por código enviado ao e-mail |
| `PSL_USER_ACCOUNT` | sim | o id do Supabase liga o perfil aos dados |
| `PSL_OTHER` (financeiro) | sim | rendimentos e os valores de SS/IVA/IRS que a app calcula |
| `PSL_OTHER_PERSONAL` | não | matrícula, datas do carro, validade da carta, residência, certificado TVDE |
| `PSL_PURCHASE_HISTORY` | não | `in_app_purchase` está na app e a tabela `assinaturas` guarda o estado |
| `PSL_PHOTOS` | não | comprovativos e extratos, pelo Photo Picker |
| `PSL_USER_GENERATED_CONTENT` | não | perguntas ao assistente e mensagens de suporte |
| `PSL_DEVICE_ID` | não | o identificador do Firebase Messaging, para os avisos |

**Localização: nenhuma.** É a regra 9 do `CLAUDE.md` — foi a política de
localização que travou o Bora. Também fora: nome e telefone (as colunas existem
na tabela mas nenhum ecrã as preenche), registos de falhas e diagnóstico (não há
Crashlytics nem Analytics — só `firebase_core` e `firebase_messaging`),
contactos, calendário, áudio, SMS, e número de cartão ou IBAN (o pagamento é da
Google Play; a app nunca lhes toca).

**Partilha com terceiros: nenhuma.** O Supabase e o Firebase tratam os dados por
conta do Em Dia, e a Google não conta isso como partilha.

Segurança: tudo cifrado em trânsito (`TRUE`) e há forma de pedir para apagar a
conta dentro da app (`TRUE` — `lib/screens/mais/definicoes_screen.dart`,
`_apagarConta`).

## Onde encravou, com o erro literal

```
HTTP 400: Invalid safety labels declaration:
Response missing for PSL_SUPPORTED_ACCOUNT_CREATION_METHODS
```

Essa pergunta **não existe no modelo público** da Google. Procurei o ID de
resposta dela e não há forma honesta de o obter:

- o mesmo modelo é servido em `en, pt-PT, pt-BR, es, de, fr, ja, ko, hi, ru, it, tr, id, zh-Hans` — é o mesmo ficheiro, e nenhum a tem;
- a Google não a documenta em lado nenhum público (procurado na web e no GitHub);
- 20 IDs plausíveis foram testados um a um contra a API e **todos** devolveram
  `Invalid response ID` (`PSL_ACCOUNT_CREATION_USERNAME_PASSWORD`,
  `PSL_ACCOUNT_CREATION_EMAIL`, `PSL_USERNAME_PASSWORD`, `PSL_SOCIAL_LOGIN`,
  `PSL_GOOGLE`, `PSL_OTHER`, `PSL_NONE`, … );
- sem ID nenhum a API responde `Response ID missing`.

Adivinhar mais era perder a noite. **Não inventei nada e não enviei nada.**

## Como se fecha isto em dois minutos

Na Play Console: **Política → Segurança dos dados → Exportar para CSV**. Esse
ficheiro traz as perguntas de hoje, incluindo a que falta. Depois:

```bash
python tool/play/data_safety.py --modelo <exportado.csv> --aplicar
```

O script preenche as perguntas que conhece e deixa as restantes exactamente como
vieram da exportação, dizendo quais são.

## As outras três continuam por fazer

Classificação de conteúdo, público-alvo e acesso à app **não têm endpoint** na
Android Publisher API v3 — só existem no formulário da consola. Precisam de uma
sessão com browser.
