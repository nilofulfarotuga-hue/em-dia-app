# FILA-CLOUD — trabalho que a rotina cloud `em-dia-noite` pode fazer sem o PC

> A rotina corre de hora a hora na cloud (sem PC, sem painéis web, sem browser, sem telemóvel).
> Pega no PRIMEIRO item por fazer `- [ ]`, faz só esse, marca `- [x]` com data, faz commit + push,
> e escreve uma linha em `docs/MARCOS.md` com o prefixo `[CLOUD]`.
> A sessão local (PC) NÃO toca nestes ficheiros enquanto estiverem por fazer — evita conflitos.
> Se `docs/MARCOS.md` tiver a linha `MISSAO-CONCLUIDA`, a rotina não faz nada.

## Regras para a rotina
- Antes de tudo: `git pull --rebase origin main`.
- Fontes de verdade: `docs/PROMPT_MISSAO_2026-09-05.md` (secções 2, 4, 5 e 6) e `supabase/migrations/20260905_0003_seed.sql` (regras legais). **Nunca inventar um número legal** — se não estiver nas regras, escrever "POR CONFIRMAR".
- Idioma: PT-PT na app e nos guias (com versão PT-BR onde pedido); linguagem de criança de 5 anos, sem jargão sem explicação entre parênteses.
- Commits pequenos, mensagem em português, prefixo `cloud:`. Push direto para `main`. Se o push for rejeitado, `git pull --rebase` e tentar de novo (até 3 vezes); se continuar a falhar, abrir um branch `cloud/<item>` e fazer push desse branch.
- Não tocar em: `lib/`, `android/`, `web/`, `.github/`, `supabase/functions/`, `pubspec.yaml` (são da sessão local).

## Fila
- [ ] **F1 — `docs/perguntas-teste.md`**: 30 perguntas reais de utilizadores (TVDE, estafeta, cabeleireira, freelancer, imigrante brasileiro, só-carro), metade em PT-PT e metade em PT-BR. Para cada uma: a regra que a resposta tem de citar (chave de `regras_legais`) e o prazo/número esperado. Exemplos obrigatórios: "abri atividade em março, quando começo a pagar?", "passei os 15 mil, e agora?", "posso pagar menos à segurança social?", "quando é a inspeção do meu carro de 2021?", "sou brasileiro, o tempo do INSS conta?".
- [x] **F2 — `docs/casos-teste.md`** (2026-09-06, feito pela SESSÃO LOCAL: os 47 casos vivem em `test/unit/regras_test.dart` com o esperado calculado à mão; o documento é gerado desse ficheiro — a rotina cloud NÃO faz este item).
- [ ] **F3 — guias (11) em `supabase/seed/guias/<slug>.md`**: cada ficheiro com frontmatter (`slug`, `titulo`, `resumo`, `categoria`, `fonte_url`, `verificado_em: POR CONFIRMAR`) e o corpo em PT-PT (≤ 1 minuto de leitura, passos numerados, textos prontos a copiar) seguido de `---BR---` e a versão PT-BR. Slugs: `abrir-atividade`, `simplificado-vs-organizada`, `isencao-art-53`, `retencao-23-25-dispensa`, `seguranca-social-direta`, `irs-independente`, `tvde-o-que-e-preciso`, `estafeta-recibos-vs-contrato`, `encerrar-atividade`, `imigrante-nif-niss-sns-aima`, `carro-iuc-ipo-seguro-carta-multas`.
- [ ] **F4 — `docs/marketing/posts.md`**: 20 posts para grupos de Facebook (TVDE Portugal, estafetas Glovo/Uber Eats, brasileiros em Portugal, cabeleireiras/manicures, mães empreendedoras). Cada post = UMA dor + a indicação do print a usar + link (usar `{LINK}`). Regra do Danilo: nunca vender a app, vender o susto evitado. Mais: `docs/marketing/anuncios.md` (5 anúncios Meta Ads: texto + descrição da arte), `docs/marketing/calendario-30-dias.md` (1 post/dia, rotativo por grupo), `docs/marketing/respostas-comentarios.md` (respostas prontas), `docs/marketing/convite-testadores.md` (texto para convidar os 12 testadores, com `{LINK_TESTE}`).
- [ ] **F5 — `docs/videos/`**: 3 guiões com storyboard plano a plano (duração, texto em ecrã, voz, captura da app a mostrar): `01-tvde-multa-30s.md` (vertical, voz PT-BR, "eu sou motorista TVDE e fiz isto porque levei uma multa"), `02-loja-15s.md` (Play Store), `03-explicativo-60s.md` (site).
- [ ] **F6 — `docs/loja/descricao-play.md`**: descrição da loja em PT-PT (título ≤ 30, descrição curta ≤ 80, descrição longa ≤ 4000 com as palavras que as pessoas procuram: recibos verdes, segurança social, IVA, IRS, IUC, inspeção, TVDE, estafeta) + versão PT-BR + 8 frases para as capturas + notas de lançamento dentro de `<pt-PT>…</pt-PT>` e `<pt-BR>…</pt-BR>`.
- [ ] **F7 — `docs/PRIVACIDADE.md`**: política de privacidade em PT-PT, linguagem simples, coerente com o Data Safety (só Firebase Cloud Messaging + Supabase; sem localização em segundo plano; dados: e-mail, telefone opcional, rendimentos, dados do carro, fotos de comprovativos; direito a apagar a conta dentro da app).
