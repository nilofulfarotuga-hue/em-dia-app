# B3 — capturas da App Store geradas no CI (job A)

Corrida: https://github.com/nilofulfarotuga-hue/em-dia-app/actions/runs/35891779298 (build-ios n.º 2, `workflow_dispatch` no ramo `em-dia-ios-2026-09-23`, `enviar=false`). Job A **success** em 33 min; job B **skipped** (nada enviado à Apple). Artefacto `ios-capturas-2` (id 10767121354, 14 ficheiros, 30 dias).

Saída literal do log (excertos):

```
No issues found! (ran in 26.1s)
00:40 +182: All tests passed!
ECRAS_VISTOS=78 … 00:15 +6: All tests passed!
runtime: com.apple.CoreSimulator.SimRuntime.iOS-26-5
[capturas] 6.9" → com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max
artefactos/capturas/6.9/01-painel.png 1320 2868
artefactos/capturas/6.9/02-recibo.png 1320 2868
artefactos/capturas/6.9/03-cofre.png 1320 2868
artefactos/capturas/6.9/04-agenda.png 1320 2868
artefactos/capturas/6.9/05-carro.png 1320 2868
artefactos/capturas/6.9/06-assistente.png 1320 2868
[capturas] 6.5" → com.apple.CoreSimulator.SimDeviceType.iPhone-14-Plus
artefactos/capturas/6.5/01-painel.png 1284 2778
… (os 6 com 1284 2778)
flutter: conversas_ia: 'package:supabase_flutter/src/supabase.dart': Failed assertion: … You must initialize the supabase instance before calling Supabase.instance
```

- Tamanhos exatamente os da tabela da Apple (6,9" = 1320×2868; 6,5" = 1284×2778).
- O erro `NSPOSIXErrorDomain code=1 … Failed to set access` é o `simctl privacy grant notifications` (tem `|| true`, não afeta nada).
- **Conferido no código (24/09):** `lib/stores/ia_store.dart:120` — a falha a ler o histórico só faz `debugPrint` e **não** mexe em `_erro`, por isso o ecrã não mostra aviso nenhum: a `06-assistente` mostra o assistente vazio, pronto a perguntar. Pode usar-se.
- Contexto original: na corrida do 6,5", ao abrir «Pergunta o que quiseres» (`06-assistente`) no modo exemplo, a app tentou ler o histórico de conversas no Supabase (não inicializado no teste). O teste passou e a foto foi tirada; ver se o ecrã mostra algum aviso de erro. Reportado como fora-de-scope (o modo exemplo não devia chamar o Supabase no assistente).
