# PENDENTE-DANILO — só o que precisa mesmo da pessoa

> Cada linha: o quê · onde (página já aberta no ecrã, quando possível) · porquê não pude fazer sozinho.
> Nada aqui trava a noite: anota-se e salta-se para o bloco seguinte.

- [ ] **Cópia de segurança da keystore** `C:\BoraLocal\_segredos\em-dia\em-dia-release.jks` + `keystore.env` para o Drive da equipa. Porquê: perder a keystore = perder a app na Play; a escolha do sítio é tua.
- [ ] **Telemóvel Android por USB** — `adb devices` não mostra nenhum aparelho ligado (2026-09-05 23:20). Liga o cabo de manhã; a instalação pelo track interno e a prova do push ficam para esse momento.
- [ ] **Firebase — aceitar os Termos do Firebase (1 clique + "Continuar")** — página já aberta no Chrome (separador "Criar projeto - Console do Firebase"), com o projeto Google Cloud `em-dia` selecionado. Só falta marcar "Aceito os Termos do Firebase" e clicar Continuar. Porquê: aceitar termos é ato da pessoa (regra A.2 da adenda). Depois disso eu faço o resto (app Android `pt.emdia.app`, google-services.json para o secret, conta de serviço para o FCM). Até lá, os avisos ficam registados na tabela `eventos_push` com resultado `sem_fcm` e a app funciona sem push.
