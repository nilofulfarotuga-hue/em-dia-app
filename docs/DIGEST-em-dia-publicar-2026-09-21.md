# Digest - em-dia-publicar-2026-09-21

Sessao OpenCode gpt-5.5. Objetivo: preparar e submeter Em Dia na Google Play. Resultado: nao submetido, bloqueado por Play Console sem sessao autenticada e Auth Supabase local com `captcha_failed`.

Feito: B1 assets de marca e capturas; B2 ficha Play ajustada para primeira submissao gratis sem compras dentro da app; D76 registada; B3 prova tecnica local com Flutter 3.47.2, AGP 9.1.0, Gradle 9.3.1, NDK 28.2.13676358, `targetSdkVersion="36"`, AAB local 60.012.220 bytes e `.so` 64 bits alinhados a 16 KB ou mais; unitarios 182 verdes, goldens 141 verdes, analyze so com info `anonKey` deprecated; juiz visual com 1 vermelho em `admin_erro_detalhe_desktop_br.png`. B4 nao submetido. B5 sem dinheiro tocado. B6 kit textual corrigido com `[LINK-DA-LOJA]` e `[CODIGO]`. B7 adicionadas migrations `20260921_0042_cadeados_anon_e_search_path.sql` e `20260921_0043_perto_de_mim_sem_anon.sql`, nao aplicadas.

Bloqueios: Play Console nao autenticada (`google.play/business`, CDP falhou), e2e_log e registo aberto bloqueados por `captcha_failed`, `gh` ausente para confirmar secrets/CI, juiz visual com 1 vermelho. Telegram enviado com `msg_id=8164` para B3-B7.

Provas principais: `docs/provas/em-dia-publicar-2026-09-21/`, `docs/RELATORIO-em-dia-publicar-2026-09-21.md`.
