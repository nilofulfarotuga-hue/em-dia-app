-- Em Dia — 0034: preços da DGEG LIGADOS (B2e) + «perto de mim» (postos e centros de inspeção) — 2026-09-18
--
-- Ordem do Danilo (17/09): «a DGEG publica os preços em dados abertos … verifica, usa, e regista a fonte».
-- Verificado a 18/09: GET https://precoscombustiveis.dgeg.gov.pt/api/PrecoComb/PesquisarPostos → HTTP 200,
-- JSON com Id, Nome, Marca, Distrito, Municipio, Latitude, Longitude, Combustivel, Preco, DataAtualizacao
-- (2026-09-16), sem chave nem registo. A condição da D40 mantém-se: os preços ficam GRÁTIS e para toda a
-- gente na app, sempre com «Fonte: DGEG» à vista. O pedido formal de «Partilha de Informação» (e-mail
-- 1a0788f8fef674b2, minuta em docs/loja/dgeg/) continua em PENDENTE-DANILO para regularizar.

update public.feature_flags set free = true, pro = true, familia = true,
  descricao = 'Preços de combustível da DGEG (grátis para todos — fonte precoscombustiveis.dgeg.gov.pt)'
  where chave = 'precos_combustivel';

-- Corrida diária às 05:10 UTC (06:10 em Lisboa no verão): a DGEG atualiza ao longo do dia; uma vez por dia chega.
select cron.unschedule(jobid) from cron.job where jobname = 'em-dia-precos-combustivel-dia';
select cron.schedule(
  'em-dia-precos-combustivel-dia',
  '10 5 * * *',
  $$
  select net.http_post(
    url := 'https://tgdmgtmknbwhcqoxtjbs.supabase.co/functions/v1/sync-precos-combustiveis',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRnZG1ndG1rbmJ3aGNxb3h0amJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2MTkyOTIsImV4cCI6MjEwNDE5NTI5Mn0.XFzQgX1jj6sVhAQNDPLtwJze61WxnEWkN56hYwD5wCM',
      'x-cron-secret', coalesce((select decrypted_secret from vault.decrypted_secrets where name = 'cron_secret'), '')
    ),
    body := '{"origem":"pg_cron"}'::jsonb
  );
  $$
);

-- ---------------------------------------------------------------- «Perto de mim»
-- Distância em km entre dois pontos (fórmula do haversine; chega para 10 km, sem PostGIS).
create or replace function public.distancia_km(lat1 double precision, lng1 double precision, lat2 double precision, lng2 double precision)
returns double precision language sql immutable as $$
  select 2 * 6371 * asin(sqrt(
    power(sin(radians(lat2 - lat1) / 2), 2) +
    cos(radians(lat1)) * cos(radians(lat2)) * power(sin(radians(lng2 - lng1) / 2), 2)
  ));
$$;

-- Postos com o preço de um combustível num raio (km), do mais barato para o mais caro.
create or replace function public.postos_perto(p_lat double precision, p_lng double precision, p_combustivel text, p_raio_km double precision default 10, p_max integer default 15)
returns table (posto_id integer, nome text, marca text, morada text, localidade text, municipio text, lat double precision, lng double precision, combustivel text, preco numeric, visto_em timestamptz, distancia_km double precision)
language sql stable security definer set search_path = public as $$
  select p.id, p.nome, p.marca, p.morada, p.localidade, p.municipio, p.lat, p.lng,
         c.combustivel, c.preco, c.visto_em,
         public.distancia_km(p_lat, p_lng, p.lat, p.lng) as distancia_km
    from public.postos_combustivel p
    join public.precos_combustivel c on c.posto_id = p.id
   where p.lat is not null and p.lng is not null
     and c.combustivel = p_combustivel
     and public.distancia_km(p_lat, p_lng, p.lat, p.lng) <= p_raio_km
   order by c.preco asc, distancia_km asc
   limit p_max;
$$;
grant execute on function public.postos_perto(double precision, double precision, text, double precision, integer) to authenticated;

-- Os combustíveis que existem na tabela (para o seletor do ecrã).
create or replace function public.combustiveis_disponiveis()
returns table (combustivel text, n bigint)
language sql stable security definer set search_path = public as $$
  select combustivel, count(*) from public.precos_combustivel group by combustivel order by count(*) desc;
$$;
grant execute on function public.combustiveis_disponiveis() to authenticated;

-- Centros de inspeção mais perto (os N mais próximos, com a distância).
create or replace function public.centros_perto(p_lat double precision, p_lng double precision, p_max integer default 5)
returns table (codigo_citv text, nome text, morada text, codigo_postal text, localidade text, distrito text, telefone text, lat double precision, lng double precision, distancia_km double precision)
language sql stable security definer set search_path = public as $$
  select c.codigo_citv, c.nome, c.morada, c.codigo_postal, c.localidade, c.distrito, c.telefone, c.lat, c.lng,
         public.distancia_km(p_lat, p_lng, c.lat, c.lng) as distancia_km
    from public.centros_inspecao c
   where c.lat is not null and c.lng is not null
   order by distancia_km asc
   limit p_max;
$$;
grant execute on function public.centros_perto(double precision, double precision, integer) to authenticated;

-- Sem localização: a pessoa escreve o concelho e a app usa o centro dos postos desse concelho.
create or replace function public.centro_do_municipio(p_municipio text)
returns table (municipio text, lat double precision, lng double precision, postos bigint)
language sql stable security definer set search_path = public as $$
  select municipio, avg(lat), avg(lng), count(*)
    from public.postos_combustivel
   where lat is not null and lng is not null
     and lower(translate(municipio, 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'))
         = lower(translate(p_municipio, 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ', 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC'))
   group by municipio
   limit 1;
$$;
grant execute on function public.centro_do_municipio(text) to authenticated;
