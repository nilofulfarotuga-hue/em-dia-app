# Segredos do iOS — o que o GitHub do Em Dia tem de ter

> Missão em-dia-ios-2026-09-22, bloco 2. Estado: **bloqueado-precisa-pc** — os ficheiros de assinatura vivem no PC do Danilo; esta lista diz o nome, para que serve e de onde vem. **Nenhum valor está aqui nem no repo.**
>
> Onde se põem: GitHub → `nilofulfarotuga-hue/em-dia-app` → Settings → Secrets and variables → Actions → *New repository secret*. Ficheiros vão em **base64 numa linha só** (`base64 -w0 ficheiro` no Git Bash, ou `[Convert]::ToBase64String([IO.File]::ReadAllBytes("ficheiro"))` no PowerShell).
>
> Os nomes são **os mesmos do repo `bora-app-cloud`** (`.github/workflows/build_ios.yml` de lá), para a mesma receita servir as duas apps.

## Quem usa o quê

- **Job A (simulador + capturas)** — não precisa de nenhum segredo da Apple. Corre só com os da secção «Build».
- **Job B (release)** — confere os 7 obrigatórios logo no primeiro passo e pára com `::error::Faltam segredos: …` se faltar algum.

## Apple — assinatura e envio (job B)

| Nome do segredo | Para que serve | De onde vem | Reaproveita o do Bora? |
|---|---|---|---|
| `IOS_DIST_CERT_P12_B64` | Certificado **Apple Distribution** + chave privada, em `.p12`, base64. Assina o IPA. | Keychain do Mac onde foi criado → exportar `.p12`; ou o `.p12` já guardado no PC (`C:\BoraLocal\_segredos\…`). | **Sim, se a app estiver na mesma conta Apple (Team)** — o certificado é da equipa, não da app. |
| `IOS_DIST_CERT_PASSWORD` | Palavra-passe do `.p12` acima. | A que foi posta ao exportar o `.p12`. | Sim, junto com o `.p12`. |
| `IOS_PROVISIONING_PROFILE_B64` | Perfil **App Store** do bundle `com.boraguarda.emdia`, base64. | developer.apple.com → Certificates, IDs & Profiles → Profiles → **+** → *App Store Connect* → App ID `com.boraguarda.emdia` → certificado de distribuição acima → descarregar `.mobileprovision`. | **Não.** O do Bora é de `pt.boraapp.bora`; o CI recusa-o (`o perfil é de …, não de com.boraguarda.emdia`). O nome do perfil pode ser qualquer um: o CI lê-o de dentro do ficheiro. |
| `ASC_KEY_P8_B64` | Chave da API do App Store Connect (`AuthKey_XXXX.p8`), base64. Usada pelo `altool` (upload) e pelo `ios_publicar.py` (versão, notas, submeter). | App Store Connect → Users and Access → Integrations → App Store Connect API → chave com papel *App Manager* (o `.p8` só se descarrega uma vez; está no PC). | **Sim** (a chave é da equipa e vale para todas as apps dela). |
| `ASC_KEY_ID` | Identificador da chave acima (10 caracteres). | Mesma página, coluna *Key ID*. | Sim. |
| `ASC_ISSUER_ID` | *Issuer ID* da equipa (UUID). | Mesma página, no topo. | Sim. |
| `ASC_TEAM_ID` | Team ID da conta de programador (10 caracteres). Vai para o `ExportOptions.plist` e para a assinatura manual. | developer.apple.com → Membership details → *Team ID*. | Sim, se for a mesma conta. |

Não é segredo e já está no workflow: `ASC_APP_ID = 6814807320`, `BUNDLE_ID = com.boraguarda.emdia`.

## Build (jobs A e B)

| Nome do segredo | Para que serve | De onde vem | Obrigatório? |
|---|---|---|---|
| `DART_DEFINES_FILE_B64` | O ficheiro `.dart_defines` (SUPABASE_URL, SUPABASE_ANON_KEY, TURNSTILE_SITE_KEY, EMAIL_REVISOR, GOOGLE_WEB_CLIENT_ID) em base64. | **Já existe** neste repo (usado pelo Android e pela web). Para o iOS só tem de levar `EMAIL_REVISOR=revisor.apple@boraguarda.com` preenchido (ver `docs/APPLE-FICHA-RESPOSTAS.md`, «Acesso do revisor»). | No job B sim; no A não (as capturas usam o modo exemplo). |
| `GOOGLE_SERVICE_INFO_PLIST_B64` | `GoogleService-Info.plist` do Firebase, base64 — push no iPhone. | Consola Firebase do projeto do Em Dia → adicionar app iOS com bundle `com.boraguarda.emdia` → descarregar o plist. Para as notificações chegarem falta ainda a chave APNs (`.p8`) carregada no Firebase. | Não: sem ele o IPA sai sem push e a app funciona (fica um aviso no log). |

## Nomes antigos que deixaram de ser lidos

O `build_ios.yml` de 22/09 lia `IOS_CERTIFICATE_P12_B64`, `IOS_CERTIFICATE_PASSWORD`, `APPSTORE_ISSUER_ID`, `APPSTORE_KEY_ID`, `APPSTORE_PRIVATE_KEY` e `IOS_EXPORT_OPTIONS_PLIST_B64`. Se algum estiver criado, pode apagar-se: a receita nova usa só os nomes acima (os do Bora) e gera o `ExportOptions.plist` sozinha.

## Depois de postos

1. GitHub → Actions → **build-ios** → *Run workflow* no ramo certo, com `enviar` ligado.
2. O job A tem de ficar verde primeiro (e deixa o artefacto `ios-capturas-N` com as pastas `6.9/` e `6.5/`).
3. O job B envia o IPA, põe a versão com lançamento automático após aprovação e submete (`submeter_revisao`). Para só mandar para o TestFlight, desligar `submeter_revisao`.

## Estado

- [ ] **bloqueado-precisa-pc** — os 7 segredos da Apple (ficheiros `.p12`, `.p8`, `.mobileprovision` no PC; perfil novo para `com.boraguarda.emdia` por criar no portal).
- [ ] **bloqueado-precisa-pc** — `GOOGLE_SERVICE_INFO_PLIST_B64` (app iOS no Firebase do Em Dia) e chave APNs.
- [ ] `DART_DEFINES_FILE_B64` com `EMAIL_REVISOR` preenchido (conta do revisor por criar/confirmar).
