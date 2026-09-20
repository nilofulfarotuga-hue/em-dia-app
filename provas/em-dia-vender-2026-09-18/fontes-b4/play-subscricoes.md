# Google Play — Crie e faça a gestão de subscrições (ajuda ao programador, pt, lida 2026-09-20)
Fonte: https://support.google.com/googleplay/android-developer/answer/140504?hl=pt

 Crie e faça a gestão de subscrições - Play Console Ajuda Pular para o conteúdo principal 
 Play Console Ajuda 
 Fazer login 
 Ajuda do Google 
 Centro de ajuda
 Ajuda
 Centro de Políticas
 Comunidade
 Play Console 
 Política de privacidade 
 Termos de serviço 
 Enviar comentário
 Enviar comentários sobre…
Este conteúdo e informações de ajuda 
Experiência geral do Centro de Ajuda 
 Fechar Seguinte 
 Centro de ajuda 
 Comunidade 
 Anúncios 
 Play Console 
 Ajuda Introdução Artigos populares Gerir a sua conta de programador Crie, carregue e publique Distribuir a aplicação Testar a aplicação e verificar o desempenho Proteja a sua app Aja em conformidade com as Políticas do Google Play Corrigir um problema Validação de programadores Android Design para vários formatos Central Play Help Center 
 Centro de Políticas Conteúdo restrito Propriedade intelectual Privacidade, logro e abuso de dispositivos Utilização de SDKs em apps Software malicioso Roubo de identidade Software indesejável para dispositivos móveis Rentabilização e anúncios Ficha da loja e promoção Spam, funcionalidade e experiência do utilizador Outros programas Famílias Aplicação Atualizações e outros recursos Como funciona o Google Play para programadores 
 Subscrições 
 Crie e faça a gestão de subscrições 
 Notificação
 You can now request help from the Help page in your Play Console account. If you don't have access to Play Console, ask your account admin for an invite.
 Crie e faça a gestão de subscrições
 Em maio de 2022, introduzimos alterações na forma como os produtos de subscrição são definidos e geridos na Play Console. Se tiver subscrições existentes e quiser saber como estas alterações as afetam, consulte o artigo Alterações recentes às subscrições na Play Console .
 Esta página explica como criar e gerir subscrições na Play Console. Recomendamos que leia este artigo para se familiarizar com os conceitos, os objetos e as funcionalidades das subscrições antes de continuar.
 Quando usar a Play Console, tem de configurar e gerir separadamente as subscrições, os planos base e as ofertas por essa ordem.
 Disponibilidade 
 Se estiver numa localização que suporta o registo de comerciantes , pode usar o sistema de faturação do Google Play.
 Se estiver numa localização suportada e quiser começar a usar as funcionalidades do sistema de faturação do Google Play nas suas apps, configure um perfil de pagamentos e reveja a documentação da API do sistema de faturação do Google Play .
 Crie e faça a gestão de subscrições 
 Clique numa secção abaixo para a expandir ou reduzir.
 Crie uma nova subscrição 
 Antes de criar uma subscrição, certifique-se de que planeia os IDs do produto cuidadosamente. Os IDs do produto têm de ser exclusivos para a sua app e, depois de os criar, não os pode alterar nem voltar a usar.
 Os IDs do produto têm de começar por um número ou uma letra minúscula, podem também incluir sublinhados (_) e pontos finais (.), e podem ter um máximo de 40 carateres.
 Nota : o ID do produto android.test não está disponível para utilização, tal como todos os IDs do produto que começam por android.test .
 Compreenda as suas responsabilidades
 Antes de criar uma subscrição, reveja a nossa Política de Subscrições . É fundamental que compreenda totalmente esta política e que a cumpra. Tem de ser transparente com os utilizadores acerca da sua oferta. Isto inclui explicar detalhadamente os termos da sua oferta, incluindo o custo da subscrição, a frequência do ciclo de faturação e se é obrigatório ter uma subscrição para usar a app. Os utilizadores não devem ter de realizar nenhuma ação adicional para rever as informações. 
 Além disso, as apps com conteúdo ou serviços de subscrição têm de ter uma IU (interface do utilizador)/experiência do utilizador clara para garantir que os utilizadores conseguem encontrar e escolher facilmente uma opção. Por exemplo, se vender subscrições nas suas apps, tem de garantir que estas divulgam claramente a forma como um utilizador pode gerir ou cancelar a respetiva subscrição. Também tem de incluir na sua app o acesso a um método online e fácil de usar para cancelar a subscrição.
 Para criar uma subscrição:
 Abra a Play Console e aceda à página Subscrições ( Rentabilizar com o Play > Produtos > Subscrições ).
 Clique em Criar subscrição .
 Introduza os detalhes da sua subscrição.
 ID do produto : o ID do produto tem de começar por um número ou uma letra minúscula, pode também incluir sublinhados (_) e pontos finais (.), e pode ter até 40 carateres.
 Nome: um diminutivo da sua subscrição até 55 carateres. Os utilizadores irão ver esta informação nos emails e no centro de subscrições.
 Como programador, tem de ser transparente relativamente a quaisquer serviços de subscrição ou conteúdos que ofereça na sua app.
 O nome da subscrição tem de refletir com precisão a sua oferta. Por exemplo, não dê o nome "Avaliação por 0 €" à sua subscrição.
 Clique em Criar .
 Clique em Editar detalhes da subscrição para ver e editar a página "Detalhes da subscrição". Tem a opção de adicionar mais informações aqui.
 Recomendamos vivamente que dedique algum tempo a adicionar vantagens ponderadas e descritivas quando criar a sua subscrição. Isto pode ajudar a atrair utilizadores e reduzir o abandono por parte dos utilizadores. 
 Junto a "Vantagens", clique em + Adicionar vantagem e introduza uma descrição de uma funcionalidade da sua subscrição. Pode adicionar até 4 vantagens (até 40 carateres cada).
 As vantagens devem realçar as funcionalidades para dar aos utilizadores uma melhor ideia do que a sua subscrição oferece, como "Catálogo completo de programas de TV e filmes".
 Uma vez que nem todos os utilizadores vão ser elegíveis para um preço promocional ou uma avaliação por 0 €, a vantagem não deve mencionar a avaliação por 0 €nem o preço. Por exemplo, não é permitido mencionar "Experimente 7 dias por 0 €".
 Junto a "Descrição", introduza uma descrição opcional para a subscrição. Isto destina-se a utilização interna; não é apresentado aos utilizadores no Google Play.
 Junto a "Ícones", adicione um ícone opcional para a sua subscrição. Adicionar um ícone relevante à sua subscrição ajuda com o merchandise do seu produto de subscrição na Play Store e noutras superfícies para consumidores.
 Nota : as políticas de conteúdo do Google Play para subscrições exigem (entre outras coisas) que os metadados dos produtos (nome, descrição, ícone, etc.) sejam exatos, não sejam enganadores e não sejam impróprios.
 Pode ter de facultar informações acerca do produto que está a distribuir para fins fiscais ou de leis de consumo. Se for o caso, desloque a página para a secção "Impostos e conformidade" e clique em Gerir definições. Saiba mais acerca das definições de impostos e conformidade .
 Clique em Guardar alterações .
 Para disponibilizar a subscrição aos utilizadores do Google Play, tem de criar e ativar, pelo menos, um plano base. Tenha em atenção que, depois de criar um plano base, deixa de poder eliminar a subscrição. Em vez disso, tem de arquivar a subscrição quando deixar de a vender.
 Edite uma subscrição existente 
 Abra a Play Console e aceda à página Subscrições ( Rentabilizar com o Play > Produtos > Subscrições ).
 Junto à subscrição que quer editar, clique na seta para a direita para ver os detalhes desta.
 Clique em Editar detalhes da subscrição e faça as alterações.
 Clique em Guardar alterações .
 Crie e faça a gestão de planos base 
 Clique numa secção abaixo para a expandir ou reduzir.
 Crie e ative um plano base 
 Antes de criar um plano base, certifique-se de que planeia cuidadosamente os IDs do mesmo. Os IDs do plano base têm de ser exclusivos numa subscrição da sua app e, após a ativação do plano base, não os pode alterar nem voltar a usar.
 Os IDs do plano base têm de começar por um número ou uma letra minúscula. Pode usar números (0-9), letras minúsculas (a-z) e hífenes.
 Para criar um plano base:
 Abra a Play Console e aceda à página Subscrições ( Rentabilizar com o Play > Produtos > Subscrições ).
 Junto à subscrição na qual quer criar um plano base, clique na seta para a direita para ver os detalhes da subscrição.
 Clique em Adicionar plano base .
 Introduza um ID do plano base. O ID do plano base tem de ser exclusivo numa subscrição e, após a ativação do plano base, não o pode alterar nem voltar a usar.
 Escolha o tipo:
 Renovação automática: é renovado automaticamente, a menos que o utilizador o cancele.
 Pré-pago: os utilizadores vão ter de fazer um pagamento manual para prolongar o respetivo plano.
 Prestações ( disponíveis em determinados países/regiões) : os utilizadores pagam um valor mensal fixo durante um período de fidelização definido para obter uma concessão de subscrição pela duração do período de fidelização. Neste momento, este plano base só está disponível para ser oferecido nos seguintes países: Brasil, Espanha, França e Itália. Os planos de prestações são renovados automaticamente, a menos que o utilizador os cancele.
 (Apenas plano base de renovação automática) Se estiver a criar um plano base de renovação automática, defina o seguinte:
 Período de faturação: selecione a duração da concessão da subscrição. Os períodos de faturação disponíveis são os seguintes:
 Semanalmente
 A cada 4 semanas
 Mensalmente
 A cada 2 meses
 A cada 3 meses
 A cada 4 meses
 A cada 6 meses
 A cada 8 meses
 Anualmente
 Período de tolerância: selecione o período máximo, durante o qual os utilizadores vão manter as concessões de subscrição enquanto um pagamento de renovação recusado permanece por resolver.
 Suspensão de conta: selecione a duração máxima antes de um problema de pagamento de renovação não resolvido resultar na expiração da subscrição. Este período de suspensão de conta começa após o fim de qualquer período de tolerância. Durante a suspensão de conta, os utilizadores não devem ter acesso a concessões de subscrição.
 Por predefinição, todos os planos base de renovação automática e planos de prestações têm a suspensão de conta ativada, e os períodos são calculados automaticamente. O cálculo é de 60 dias menos a duração do período de tolerância. Pode ajustar a duração da suspensão de conta ou desativá-la na Google Play Console. Especificar uma duração inferior ao valor predefinido pode reduzir o número de subscrições recuperadas de pagamentos recusados.
 Plano de faturação e alterações de ofertas: escolha como aplicar os restantes dias pagos quando os utilizadores alteram as ofertas.
 Subscrever novamente: se esta opção estiver ativa, os utilizadores podem voltar a comprar uma subscrição de renovação automática expirada na Play Store.
 (Apenas plano base pré-pago) Se estiver a criar um plano base pré-pago, defina o seguinte:
 Duração: selecione a duração da concessão da subscrição. As opções de duração disponíveis são as seguintes:
 1 dia
 3 dias
 1 semana
 4 semanas
 1 mês
 2 meses
 3 meses
 4 meses
 6 meses
 8 meses
 1 ano
 Permitir prolongamento: se esta opção estiver ativa, os utilizadores podem prolongar a duração de uma subscrição pré-paga ativa na Play Store.
 (Apenas no plano base de prestações) se estiver a criar um plano base de prestações, defina o seguinte:
 Período de fidelização: introduza o período de fidelização em meses (tem de ser entre 3 e 24).
 Tipo de renovação: selecione Renovação automática mensal ou É renovada automaticamente durante a mesma duração .
 Período de tolerância: selecione o período máximo, durante o qual os utilizadores vão manter as concessões de subscrição enquanto um pagamento de renovação recusado permanece por resolver.
 Suspensão de conta: selecione a duração máxima antes de um problema de pagamento de renovação não resolvido resultar na expiração da subscrição. Este período de suspensão de conta começa após o fim de qualquer período de tolerância. Durante a suspensão de conta, os utilizadores não devem ter acesso a concessões de subscrição.
 Plano de faturação e alterações de ofertas: escolha como aplicar os restantes dias pagos quando os utilizadores alteram os planos. Se o estiver a fazer para um plano base de prestações , visite o site para programadores Android para saber mais.
 Subscrever novamente: se esta opção estiver ativa, os utilizadores podem voltar a comprar uma subscrição de renovação automática expirada na Play Store.
 (Opcional) Adicione etiquetas para identificar o plano base ou a oferta na API. As etiquetas podem ser usadas para determinar que oferta é apresentada quando o utilizador é elegível para mais do que uma. Pode adicionar até 20 etiquetas.
 Na parte superior direita da secção "Preço e disponibilidade", clique em Gerir disponibilidade por país/região . Para selecionar as localizações onde o seu plano base vai estar disponível:
 Os utilizadores só podem comprar as suas subscrições em regiões onde o seu plano base está disponível. O país no Google Play do utilizador é usado para determinar que planos base estão disponíveis para o mesmo.
 Se optar por disponibilizar o seu plano base de subscrição em "Novos países/regiões", quando a Google adicionar o suporte de uma nova moeda de comprador num país onde já distribui a sua app, também iremos disponibilizar automaticamente o plano base. Saiba mais acerca da oferta de apps em várias moedas .
 Se escolher um tipo de plano base que só esteja disponível para utilizadores em determinados países/regiões, como um plano base de prestações, apenas esses países/regiões são selecionáveis.
 Depois de fazer as suas seleções, clique em Aplicar .
 Para definir o preço de um plano base em vários países/regiões ao mesmo tempo:
 Clique em Atualizar preços e selecione os países/regiões nos quais quer definir os preços em massa.
 Clique em Definir preço .
 Introduza o preço sem impostos e a moeda que quer usar.
 Este preço é convertido na moeda adequada para cada país/região, é adicionado o imposto para as jurisdições com imposto incluído e, de seguida, o preço é calculado de forma a agir em conformidade com as taxas alfandegárias locais .
 Clique em Atualiz