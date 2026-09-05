# MARCOS — missão em-dia-missao-total-2026-09-05

> Qualquer retoma começa por LER este ficheiro e continua do último `PRÓXIMO`.
> Nunca recomeçar do zero. Formato: `[data hora] FEITO: <passo> | PRÓXIMO: <passo> | PROVA: <ficheiro/comando>`
>
> Sessão local (Claude Code app): `c51cb931-0ec0-4bb4-bb6f-e956090318aa`
> Pasta: `C:\BoraLocal\projetosflutter\em_dia` (= `C:\Users\danil\Desktop\projetosflutter\em_dia`)
> Repo: `nilofulfarotuga-hue/em-dia-app` · Supabase: `tgdmgtmknbwhcqoxtjbs` (em-dia, eu-west-3)
> Segredos locais (fora do repo): `C:\BoraLocal\_segredos\em-dia\`
>
> A última linha `MISSAO-CONCLUIDA` desliga o vigia e a rotina cloud.

[2026-09-05 22:20] FEITO: CEO-AI invocado, ctx doctor OK, Córtex consultado (0 registos sobre Em Dia) | PRÓXIMO: portão de RAM | PROVA: saída ctx_doctor no transcript
[2026-09-05 23:25] FEITO: portão de RAM — llama-server (idle, 4,3 GB) parado; 1049 MB → 5979 MB disponíveis | PRÓXIMO: scaffold Flutter | PROVA: Get-CimInstance Win32_PerfFormattedData_PerfOS_Memory AvailableMBytes=5979
[2026-09-05 23:30] FEITO: `flutter create --org pt.emdia --project-name em_dia --platforms android,web` | PRÓXIMO: keystore | PROVA: em_dia/pubspec.yaml existe
[2026-09-05 23:31] FEITO: keystore `em-dia-release.jks` (alias emdia, RSA 2048, válida até 2054) em C:\BoraLocal\_segredos\em-dia\ + keystore.env | PRÓXIMO: vigia da noite (A.4) | PROVA: keytool -list SHA1 69:5F:69:EE:81:1F:76:70:29:5C:3B:C9:9C:02:FA:80:3C:74:C7:10
