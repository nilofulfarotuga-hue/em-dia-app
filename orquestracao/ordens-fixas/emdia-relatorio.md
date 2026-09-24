[MODELO: OPUS]

ORDEM FIXA — EM DIA, RELATÓRIO DO DIA (dispara às 22:30, Agendador de Tarefas do Windows)

Lê primeiro `C:\BoraLocal\projetosflutter\em_dia\orquestracao\ordens-fixas\_COMUM-EMDIA.md`.

Esta ordem **não publica nada**. Só conta e avisa.

O QUE TENS DE FAZER:

1. TRÊS NÚMEROS, e mais nada.

   a) **Publicações em grupos hoje** — projeto `ojykpzwqrtusfeakzrna`:

   ```sql
   select count(*)
   from e2e_log
   where created_at >= (now() at time zone 'Europe/Lisbon')::date
     and fluxo = 'redes-emdia-grupos-auto'
     and estado in ('ok','pendente')
     and passo like 'grupo-%';
   ```

   b) **Comentários respondidos hoje** — mesma tabela, `passo like 'comentario-%'`.

   c) **Contas novas no Em Dia hoje** — projeto `tgdmgtmknbwhcqoxtjbs`:

   ```sql
   select count(*) from auth.users
   where created_at >= (now() at time zone 'Europe/Lisbon')::date;
   ```

2. MANDA PELO TELEGRAM, em três linhas curtas, sem jargão:

   ```
   Em Dia, 24/09: 4 publicações em grupos, 11 comentários respondidos, 2 contas novas.
   ```

   Usa:
   `bash C:\BoraLocal\projetosflutter\bora_app\orquestracao\ponte-telegram.sh --so-texto "<texto>"`
   Mensagem em **base64** se tiver acentos — senão partem-se no caminho.
   **Cuidado com o falso positivo:** o `curl` desta ponte já devolveu 0 com HTTP 401,
   dizendo "avisado" sem avisar ninguém. Confirma o corpo da resposta, não o código.

3. SE HOUVE AVISO DO FACEBOOK HOJE (alguma linha `estado='falhou'` com aviso da Meta),
   acrescenta uma quarta linha a dizer isso em voz alta, e que o Em Dia está parado 72 h.

4. FECHO.
   Uma linha no `e2e_log` com `passo='relatorio-dia'` e os três números no `detalhe`.
