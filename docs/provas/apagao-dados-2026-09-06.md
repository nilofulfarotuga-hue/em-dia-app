# APAGÃO DE DADOS — 2026-09-06, por volta das 13:56

**Todos os dados de utilizador da base de dados desapareceram.** A app e o
servidor estão inteiros; o que se perdeu foram as contas e o que estava dentro
delas. Escrevo isto sem suavizar nada, porque é o que interessa saber de manhã.

## O que havia, e o que há agora

Às 13:50 de hoje o `avisos-cron` processou **7 utilizadores** e eu tinha acabado
de ler, com sessão de administrador, o perfil do `boraappbora@gmail.com` com o
onboarding feito e 17 obrigações. Às 15:10, com a mesma sessão de
administrador:

| Tabela | Antes (provado hoje) | Agora |
|---|---|---|
| `profiles` | 7 | **2** — e ambos recriados às **13:56:27** |
| `obrigacoes` | 17 só do meu passeio | **0** |
| `rendimentos` | tinha | **0** |
| `carros` | tinha | **0** |
| `conversas_ia` | **37** | **0** |
| `tickets_suporte` | tinha (o meu, `18eca49f…`) | **0** |
| `eventos_push` | tinha | **0** |
| `assinaturas` | — | 0 |
| `admin_audit_log` | tinha | **0** |

Os dois perfis que restam são o `boraappbora@gmail.com` e o
`nilofulfarotuga@gmail.com`, **com o onboarding a zero** (`sem_atividade`,
`onboarding_concluido = false`) e ambos com `criado_em = 2026-09-06T13:56:27` —
o mesmo segundo, o que é assinatura de uma inserção em bloco, não de duas
pessoas a entrar.

E as tabelas de conteúdo ficaram **todas de pé**: `regras_legais` 66,
`guias` 11, `feature_flags` 11, `irs_escaloes` 18, `admins` 2.

## O que isto diz

Conteúdo que vem das migrações e dos seeds: intacto.
Dados criados por pessoas a usar a app: apagados.

Isso é o desenho de uma **reposição da base de dados a partir das migrações**
(um `db reset` ou equivalente), não de um `DELETE` avulso. A migração
`20260906_0004_vault_cron_admin.sql` é a que insere os dois administradores
`nilofulfarotuga@` e `boraappbora@` — o que explica os dois perfis, ao mesmo
segundo, com tudo a zero.

## Quem fez, e o que eu não vou dizer

**Não sei, e não invento.** O que sei, e está provado:

- Há **outra sessão a escrever nesta pasta** ao mesmo tempo que eu. O meu
  `git add -A` apanhou, sem eu pedir, ficheiros que não escrevi: primeiro
  `lib/stores/dados_store.dart`, depois `pesq.html` e
  `test/unit/painel_prazos_test.dart`, e a seguir quatro migrações novas
  (`0010` a `0013`).
- Essas migrações **foram aplicadas**: o `is_admin` deixou de estar ao alcance
  de quem não tem sessão (`HTTP 401`), que é exactamente o que a `0011` faz.
- O vigia da noite (`EmDia-Retomar`) lançou retomas às 13:26 e às 14:46. A
  tranca `docs/.sessao-viva` só é renovada quando a sessão se lembra, por isso
  basta uma pausa de 20 minutos entre respostas para o vigia achar que a sessão
  morreu e lançar outra por cima.

Não tenho como provar qual delas correu o quê, e uma acusação sem prova não vale
mais do que nenhuma.

## Quanto custa, a sério

Pouco em dinheiro, muito em confiança:

- **Não havia clientes.** A app está em teste interno; as contas eram as tuas
  duas e as de teste.
- Perdeu-se: o teu onboarding (são 5 perguntas, 1 minuto), 37 conversas com o
  assistente, os tickets de suporte, os eventos de aviso e o registo de
  auditoria. As obrigações **regeneram-se sozinhas** assim que refizeres o
  onboarding (`calcular-obrigacoes`).
- Os utilizadores de teste `teste@emdia.pt` e `teste2@emdia.pt` (os do
  `teste.env`) deixaram de entrar: `HTTP 400 invalid_credentials`. As provas que
  dependiam deles têm de passar a usar outra conta.

## A app está bem — provado depois do apagão

```
calcular-obrigacoes    HTTP 200  {"geradas":0,…}   (0 porque o perfil está a zero)
avisos-cron (forçado)  HTTP 200  {"utilizadores":2,"erros":0}
suporte-auto           HTTP 200  ticket b5b1210e-48f3-499f-abff-d4a40ea71753
site público           57 asserções passaram / 0 falharam
```

## O que eu NÃO fiz, de propósito

**Não tentei repor nada.** Não tenho cópia de segurança destes dados, e inventar
linhas para a base parecer cheia seria pior do que a base vazia. O Supabase
costuma guardar cópias diárias no painel do projeto (Database → Backups); se
quiseres recuperar as 37 conversas e o resto, essa é a via, e a decisão é tua —
repor uma cópia **desfaz também tudo o que se fez hoje depois dela**, incluindo
os arranjos de segurança.

A minha opinião, para o que vale: não repunha. O que se perdeu é dados de teste,
e a cópia traria de volta as duas fugas de segurança que se fecharam hoje.

## O que tem de mudar antes da próxima noite

Duas sessões a mexer na mesma base de dados de produção, sem ninguém a ver, é
como isto acontece. Ou só corre uma, ou o vigia tem de saber que já há uma viva
antes de lançar outra.
