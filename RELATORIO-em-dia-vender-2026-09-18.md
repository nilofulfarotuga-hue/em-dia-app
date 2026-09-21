# Relatório da missão em-dia-vender-2026-09-18

Datas: 18 a 21 de setembro de 2026.

O maestro foi o Claude Code Opus 5; o trabalho pesado acabou feito pelo ChatGPT Plus gpt-5.5 porque o GLM do plano Go ficou sem quota semanal; este relatório foi escrito por mim.

Bloco 0 — estado real na Google Play: FEITO ficou escrito o estado visto pela API e pela consola: Em Dia em rascunho, testes internos, sem produção, sem perfil de pagamentos e sem subscrições. · PROVA provas/em-dia-vender-2026-09-18/b0-estado-real.md · FICOU a consola só se confirma de novo com Chrome e conta aberta.
Bloco 1 — marca: FEITO nada foi feito neste bloco. · PROVA docs/MARCOS.md (secção da missão) não tem fecho do B1 · FICOU precisa do Gemini no Chrome, que esta sessão não tinha.
Bloco 2 — preços no site: FEITO a página /precos está no ar (61 de 61 asserções) a ler os quatro preços da tabela regras_legais, com Google Play, cancelamento, 14 dias e PWA no grátis; os produtos pagos não foram criados. · PROVA provas/em-dia-vender-2026-09-18/b2-precos-site.md · FICOU criar produtos e prova de compra depois do contrato de pagamentos da Google.
Bloco 3 — ficha da consola: FEITO ficaram prontas as respostas para a Play Console, com acesso à app, dados, classificação, público-alvo, finanças, saúde, notas ao revisor e quatro produtos sem preços escritos. · PROVA provas/em-dia-vender-2026-09-18/b3-b8-ficha-kit.md e docs/PLAY-FICHA-RESPOSTAS.md · FICOU colar as respostas nas 6 tarefas da consola com Chrome.
Bloco 4 — papéis legais: FEITO ficaram no site, publicados e verificados (60 de 60 asserções no ar), os termos, reclamações, apagar conta e privacidade; na app ficaram aviso não fiscal, ligações aos papéis e texto de 14 dias no plano. · PROVA provas/em-dia-vender-2026-09-18/b4a-papeis-site.md e provas/em-dia-vender-2026-09-18/b4b-b6-app.md · FICOU nada ficou.
Bloco 5 — fecho mensal: FEITO a migração 0041 foi aplicada, a função fecho-mensal está no ar (versão 1) e o cron do dia 1 está ativo; provado em produção: sem extrato da Google escreve «sem extrato» em vez de inventar números, grava a folha de rosto no bucket e devolve 401 a quem não tem o segredo. · PROVA provas/em-dia-vender-2026-09-18/b5-fecho-mensal.md · FICOU guardar o id do bucket da Play, a conta de serviço no Vault e dar permissão financeira.
Bloco 6 — suporte e reembolsos: FEITO a Ajuda ganhou prazo de 2 dias úteis, e-mail humano, estados simples dos pedidos e caminho de reembolso pela Google Play ou por e-mail nos 14 dias. · PROVA provas/em-dia-vender-2026-09-18/b4b-b6-app.md · FICOU nada ficou.
Bloco 7 — funil e estatísticas: FEITO o painel admin ganhou o funil por semanas e a app ganhou o interruptor de estatísticas desligado por defeito; os 6 eventos só se escrevem com consentimento. · PROVA provas/em-dia-vender-2026-09-18/b7a-funil.md e provas/em-dia-vender-2026-09-18/b7b-consentimento.md · FICOU nada ficou.
Bloco 8 — kit e fecho da loja: FEITO ficaram escritos o kit de divulgação e as respostas finais da consola; nada foi publicado. · PROVA provas/em-dia-vender-2026-09-18/b3-b8-ficha-kit.md e docs/KIT-DIVULGACAO.md · FICOU Data Safety, produtos e prova de compra ficam para a sessão com Chrome depois do contrato.
Bloco 9 — revisão e fecho: FEITO o portão passou: 182 testes de regras, 78 ecrãs no percurso de ponta a ponta, 141 fotos da fábrica, juiz de visão com 7 verdes e 0 vermelhos; depois esta revisão cruzada, o relatório, o digest e o pendente novo. · PROVA provas/em-dia-vender-2026-09-18/b9-revisao-cruzada.md, RELATORIO-em-dia-vender-2026-09-18.md, docs/DIGEST-em-dia-vender-2026-09-18.md e provas/em-dia-vender-2026-09-18/PENDENTE-DANILO-b9.md · FICOU o push final, que dispara CI Android internal e alpha e web, é do Claude Code.

## Para o Danilo

Aceitar o contrato de pagamentos da Google: Play Console → Definições → Perfil de pagamentos; o formulário fica preenchido e para no botão Enviar.

## Para a próxima sessão com o Chrome (não é do Danilo)

Ler o id do bucket dos relatórios financeiros na Play Console e guardá-lo no Vault como play_relatorios_bucket.

Pôr o JSON da conta de serviço no Vault como play_service_account.

Dar à conta de serviço a permissão Ver dados financeiros.

Colar as respostas de docs/PLAY-FICHA-RESPOSTAS.md nas 6 tarefas da consola.

Atualizar Data Safety.

Criar os produtos e fazer a prova de compra depois do contrato.

Fazer o B1 de marca.
