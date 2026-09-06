# Política de Privacidade — Em Dia

**Data de entrada em vigor:** 6 de setembro de 2026
**Responsável pelo tratamento dos dados:** Danilo (nome completo **POR CONFIRMAR**), Guarda, Portugal
**Contacto:** suporte@emdia.pt (domínio **POR CONFIRMAR** — ver `docs/PENDENTE-DANILO.md`)

Esta política aplica-se à app **Em Dia** (Android, web e painel administrativo) e cumpre o **RGPD**
(Regulamento Geral de Proteção de Dados). Está escrita em português simples, para seres tu a perceber
sem precisares de um advogado.

## 1. O que é o Em Dia

O Em Dia é um assistente para trabalhadores independentes em Portugal (recibos verdes) e para quem
tem carro — lembra-te de prazos como Segurança Social, IVA, IRS, IUC e inspeção, e responde às tuas
perguntas com um assistente de Inteligência Artificial.

## 2. Que dados recolhemos e para quê

| Dado | Para quê | Obrigatório? |
|---|---|---|
| **E-mail** | Entrar na app (login por código) | Sim |
| **Telefone** | Contacto opcional, nunca usado para login | Não |
| **Nome** | Personalizar a saudação e os avisos | Não |
| **Dados de atividade** (tipo de atividade, data de abertura, regime de IVA) | Calcular o teu calendário de obrigações e os valores certos | Sim, para usar o calendário |
| **Rendimentos** (valores que registas) | Calcular a Segurança Social, o IVA e o que guardar para o IRS | Sim, para usar a calculadora |
| **Obrigações** (o que já pagaste, o que falta) | Mostrar o teu semáforo "Estás em dia?" | Sim, para usar o painel |
| **Dados do carro** (matrícula, datas de seguro/inspeção/matrícula) | Calcular o IUC, a inspeção e avisar-te a tempo | Não (só se usares o módulo do carro) |
| **Fotos de comprovativos** (recibos, faturas, extratos) | Guardar prova de que pagaste ou de quanto ganhaste | Não (funcionalidade opcional) |
| **Perguntas que fazes ao assistente de IA** | Gerar a resposta e melhorar os guias da app | Não (só se usares o chat) |
| **Token de notificações** (Firebase Cloud Messaging) | Enviar-te o aviso de um prazo | Não (podes desligar as notificações) |

### O que NÃO recolhemos

- **Sem localização** (nem em primeiro plano nem em segundo plano).
- **Sem contactos** do teu telemóvel.
- **Sem publicidade** e sem identificadores de publicidade.
- **Sem venda de dados** a ninguém, nunca.

## 3. Onde ficam guardados os teus dados

Todos os dados ficam em servidores do **Supabase** na **União Europeia** (região de **Paris, França**).
As fotos de comprovativos ficam num balde (pasta) **privado** — só tu (e, se precisares de ajuda, a
equipa de suporte, com o teu pedido) conseguem aceder.

## 4. As tuas perguntas ao assistente de IA

Quando escreves uma pergunta ao assistente, o texto é enviado ao **Gemini**, o motor de Inteligência
Artificial da **Google**, só para gerar a resposta — a Google não usa a tua pergunta para outros fins
que não sejam responder-te. Guardamos a pergunta e a resposta para melhorar os guias e as respostas
futuras (por exemplo, criar um guia novo sobre um tema muito perguntado).

## 5. Com quem partilhamos dados

- **Google (Gemini):** as tuas perguntas ao assistente, para gerar a resposta.
- **Google (Firebase Cloud Messaging):** um identificador técnico do teu telemóvel, só para te
  entregar as notificações.
- **Google Play:** o recibo da tua compra (se tiveres um plano pago), para validar a assinatura.

Não partilhamos dados com mais ninguém. Não vendemos dados. Não fazemos publicidade.

## 6. Os teus direitos (RGPD)

Tens direito a:

- **Ver** os teus dados — dentro da app, em Definições → Os meus dados.
- **Corrigir** os teus dados — edita-os diretamente na app.
- **Apagar** a tua conta e todos os teus dados — em **Definições → Apagar conta**, dentro da app.
  Esta ação apaga tudo: perfil, rendimentos, obrigações, carros, fotos de comprovativos e histórico
  de conversas com o assistente. É definitivo e não tem "desfazer".
- **Pedir uma cópia** dos teus dados (portabilidade) — escreve para suporte@emdia.pt.
- **Reclamar** junto da **CNPD** (Comissão Nacional de Proteção de Dados), se achares que não
  cumprimos esta política: www.cnpd.pt.

## 7. Quanto tempo guardamos os dados

Enquanto a tua conta existir. Se apagares a conta, os dados são removidos de imediato dos sistemas
em produção (podem existir cópias de segurança técnicas por um período curto, só para recuperação
de falhas, nunca para uso comercial).

## 8. Contas de teste e menores

O Em Dia destina-se a adultos que trabalham em Portugal. Não pedimos nem tratamos intencionalmente
dados de menores de 18 anos.

## 9. Alterações a esta política

Se mudarmos esta política, avisamos dentro da app antes de a alteração entrar em vigor. A data no
topo desta página diz sempre a versão em vigor.

## 10. Contacto

Dúvidas sobre privacidade: **suporte@emdia.pt** (domínio **POR CONFIRMAR**).
Responsável: **Danilo** (apelido **POR CONFIRMAR**), Guarda, Portugal.

---

## Para o Data Safety da Play

> Lista exata de tipos de dados e finalidades, para copiar diretamente para o formulário
> "Segurança dos dados" da Google Play Console.

### Dados recolhidos e partilhados

| Categoria (Data Safety) | Tipo de dado | Recolhido | Partilhado | Finalidade | Opcional |
|---|---|---|---|---|---|
| Informação pessoal | E-mail | Sim | Não | Funcionalidade da app (autenticação) | Não |
| Informação pessoal | Nome | Sim | Não | Personalização da app | Sim |
| Informação pessoal | Número de telefone | Sim | Não | Comunicações com o utilizador | Sim |
| Informação financeira | Outra informação financeira (rendimentos, obrigações fiscais, dados do carro) | Sim | Não | Funcionalidade da app | Não* |
| Fotos e vídeos | Fotos | Sim | Não | Funcionalidade da app (comprovativos) | Sim |
| Mensagens | Outras mensagens no aplicativo (perguntas ao assistente de IA) | Sim | Sim (Google/Gemini, só para gerar a resposta) | Funcionalidade da app, análise | Sim |
| Identificadores do dispositivo ou outros | ID de instalação do Firebase / token FCM | Sim | Sim (Google/Firebase, só para entregar a notificação) | Funcionalidade da app (notificações) | Sim |

\* Obrigatório apenas para usar o calendário de obrigações e a calculadora; a app funciona em modo
limitado sem estes dados.

### O que declarar como "NÃO recolhido"

- Localização (aproximada e precisa).
- Contactos.
- Histórico de navegação ou de pesquisa fora da app.
- Identificadores de publicidade.
- Dados de saúde ou fitness.

### Práticas de segurança a declarar

- Os dados são **encriptados em trânsito** (HTTPS/TLS).
- O utilizador pode **pedir a eliminação dos dados** dentro da app (Definições → Apagar conta).
- Os dados são revistos por práticas de segurança próprias antes de publicação (RLS do Supabase:
  cada utilizador só vê os seus dados).

### SDKs de terceiros presentes na app (para a secção de bibliotecas do Data Safety)

- `firebase_core` + `firebase_messaging` (Google) — notificações push.
- Cliente Supabase (`supabase_flutter`) — base de dados e autenticação.

Nenhum outro SDK de publicidade, analytics de terceiros ou rastreio está presente.
