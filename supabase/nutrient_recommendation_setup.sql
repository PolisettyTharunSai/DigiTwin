-- DigiTwin nutrient recommendation setup
-- Run this in Supabase SQL editor.

begin;

-- 1) Canonical nutrient schedule (loaded from your potato_nutrients.csv)
create table if not exists public.nutrient_schedule (
  day integer primary key,
  n_g double precision not null default 0,
  p_g double precision not null default 0,
  k_g double precision not null default 0,
  fertilizer_source text not null default 'None',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint nutrient_schedule_day_range check (day between 1 and 109)
);

create index if not exists idx_nutrient_schedule_day on public.nutrient_schedule(day);

alter table public.nutrient_schedule enable row level security;

drop policy if exists nutrient_schedule_read_authenticated on public.nutrient_schedule;
create policy nutrient_schedule_read_authenticated
  on public.nutrient_schedule
  for select
  to authenticated
  using (true);

-- 2) Computed algorithm state snapshot for each user/day
create table if not exists public.nutrient_daily_state (
  user_id uuid not null references auth.users(id) on delete cascade,
  day_number integer not null,
  recommended_n_g double precision not null default 0,
  recommended_p_g double precision not null default 0,
  recommended_k_g double precision not null default 0,
  carry_n_g double precision not null default 0,
  carry_p_g double precision not null default 0,
  carry_k_g double precision not null default 0,
  fertilizer_source text not null default 'None',
  updated_at timestamptz not null default now(),
  primary key (user_id, day_number),
  constraint nutrient_daily_state_day_range check (day_number between 1 and 109)
);

create index if not exists idx_nutrient_daily_state_user_day
  on public.nutrient_daily_state(user_id, day_number);

alter table public.nutrient_daily_state enable row level security;

drop policy if exists nutrient_daily_state_select_own on public.nutrient_daily_state;
create policy nutrient_daily_state_select_own
  on public.nutrient_daily_state
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists nutrient_daily_state_upsert_own on public.nutrient_daily_state;
create policy nutrient_daily_state_upsert_own
  on public.nutrient_daily_state
  for all
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- 3) Extend existing daily log table with nutrient algorithm fields
alter table public.plant_daily_log
  add column if not exists day_number integer,
  add column if not exists nutrient_n_applied_g double precision not null default 0,
  add column if not exists nutrient_p_applied_g double precision not null default 0,
  add column if not exists nutrient_k_applied_g double precision not null default 0,
  add column if not exists nutrient_rec_n_g double precision,
  add column if not exists nutrient_rec_p_g double precision,
  add column if not exists nutrient_rec_k_g double precision,
  add column if not exists nutrient_carry_n_g double precision,
  add column if not exists nutrient_carry_p_g double precision,
  add column if not exists nutrient_carry_k_g double precision,
  add column if not exists fertilizer_source text;

create index if not exists idx_plant_daily_log_user_day_number
  on public.plant_daily_log(user_id, day_number);

create unique index if not exists ux_plant_daily_log_user_log_date
  on public.plant_daily_log(user_id, log_date);

-- Backfill day_number from profile.planting_date where possible.
update public.plant_daily_log l
set day_number = greatest(
  1,
  least(109, ((l.log_date::date - p.planting_date::date) + 1))
)
from public.profile p
where p.id = l.user_id
  and l.day_number is null
  and p.planting_date is not null;

commit;

-- 4) Import nutrient schedule CSV (potato_nutrients.csv)
-- Use Supabase Dashboard:
--   Table Editor -> nutrient_schedule -> Insert -> Import data from CSV
-- CSV columns should match exactly:
--   day,N_g,P_g,K_g,fertilizer_source
-- and map to table columns:
--   day,n_g,p_g,k_g,fertilizer_source
