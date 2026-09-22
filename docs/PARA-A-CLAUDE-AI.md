# Para a Claude.ai

Missao: `em-dia-web-iphone-2026-09-22`.

Pedidos que esta sessao OpenCode nao deve fazer diretamente:

- Inserir as linhas do `e2e_log` no Supabase certo quando eu deixar as provas por bloco. RUN_ID: `em-dia-web-iphone-2026-09-22`.
- Qualquer SQL no Supabase do Em Dia (`tgdmgtmknbwhcqoxtjbs`), incluindo ler `regras_legais.planos_a_venda` e `regras_legais.promessa_gratis_texto` se for preciso validar producao.
- Play Console e App Store Connect: colar fichas, criar app iOS na consola, TestFlight, certificados, perfis e capturas submetidas. O OpenCode nao deve tentar essas consolas.
- App Store Connect: usar `docs/APPLE-FICHA-RESPOSTAS.md`; antes de submeter, criar/confirmar `revisor.apple@boraguarda.com`, definir palavra-passe fora do repo, configurar o secret `EMAIL_REVISOR`, confirmar que Google nao aparece no iOS e que notificacoes iOS nao sao pedidas se APNs/Firebase iOS ainda nao estiverem prontos.
- Correr o workflow iOS em macOS/TestFlight e guardar a prova ou erro real em `provas/em-dia-web-iphone-2026-09-22/`. Nesta sessao Windows, `pod install` ficou bloqueado por `pod_missing`.
- Gerar as imagens finais de divulgacao no Gemini/ChatGPT autenticado a partir de `docs/DIVULGACAO-WEB-IPHONE-2026-09-22.md`; o OpenCode deixou prompts, nao imagens finais.
- Copiar `docs/DIGEST-em-dia-web-iphone-2026-09-22.md` para `public.claude_ai_memoria` como digest da missao. O OpenCode deixou o digest em ficheiro porque nao deve fazer SQL no Supabase do Em Dia.
