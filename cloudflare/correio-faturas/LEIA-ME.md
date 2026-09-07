# A caixa de correio das faturas — o que falta para ligar

O código está todo escrito e provado. **Falta uma coisa só: um domínio.**
Enquanto ele não existir, a app diz "ainda não está pronta" em vez de mostrar um
endereço que não recebe nada — e isso é de propósito.

## O que já está no ar

| Peça | Onde | Estado |
|---|---|---|
| Tabela `faturas_recebidas` + balde privado `faturas` | Supabase `tgdmgtmknbwhcqoxtjbs` | aplicado (migração 0023) |
| `minha_caixa_de_faturas()` — inventa e devolve o endereço | Supabase | aplicado |
| Edge Function `receber-fatura` | Supabase | ACTIVE, versão 1 |
| Segredo partilhado `correio_secret` | Vault do Supabase | criado |
| Worker de e-mail | `cloudflare/correio-faturas/` | escrito, **por publicar** |
| Interruptor `caixa_faturas_dominio` | `regras_legais` | **vazio = desligado** |

## Porque é que não liguei já

O Email Routing da Cloudflare precisa de uma zona (um domínio) e mexe nos
registos MX dessa zona. Na conta há três: `boraguarda.com`, `guardafcsad.com` e
`jaiagarwala.com`. **Nenhum é do Em Dia**, e o primeiro é o que manda os códigos
de entrada da app — pôr-lhe um catch-all era arriscar o login de toda a gente
por causa de uma funcionalidade nova. Não se faz.

Comprar o domínio é um clique do Danilo (é dinheiro e cartão): está em
`docs/PENDENTE-DANILO.md`. a decisão de 7 de setembro (D46) é `faturas.boraguarda.com`, um subdomínio de `boraguarda.com`; precisa do Email Routing da zona.

## Os quatro passos, no dia em que o domínio existir

```bash
# 1. o segredo (o MESMO que está no Vault do Supabase, em correio_secret)
cd cloudflare/correio-faturas && npm install
npx wrangler secret put CORREIO_SECRET

# 2. publicar o Worker
npx wrangler deploy
```

3. No painel da Cloudflare, no domínio novo: **Email → Email Routing → Enable**,
   depois **Catch-all address → Send to a Worker → em-dia-correio-faturas**.
   Uma regra só, não uma por pessoa (é isso que tira o tecto das 200).

4. Ligar o interruptor na base de dados — e a app acende sozinha, sem publicar
   versão nenhuma:

```sql
update regras_legais
   set valor_txt = 'faturas.boraguarda.com', verificado_em = current_date
 where chave = 'caixa_faturas_dominio';
```

## Como se desliga, se correr mal

Pôr `valor_txt` a `null` outra vez. A app volta a dizer "ainda não está pronta"
e nada mais parte: as faturas que já entraram continuam lá.

## Testar as peças sem instalar nada

```bash
node teste.mjs
```

11 casos: escolher o anexo certo de entre os vários de um e-mail, saltar
assinaturas e logótipos, recusar o que é maior do que 10 MB, e converter para
base64 mais de 32 KB de uma vez sem rebentar a pilha.
