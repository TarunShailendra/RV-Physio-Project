-- ICIQ-SF responses.
--
-- Written by assessment_summary_notifier.dart:46 (insert), read by :122
-- (select id). Columns match that payload exactly; no score column is created
-- because the app does not write one.
--
-- Range checks are deliberately loose on leak_amount. The UI currently offers
-- 1..3 (iciq_screen.dart:284) where the validated ICIQ-SF uses 0/2/4/6, so the
-- check accepts 0..6 to avoid having to re-migrate when that is corrected.
--
-- when_leaks is jsonb rather than text[] for consistency with the jsonb
-- collections in the other migrations. Note that the app stores *localised*
-- strings here (iciq_screen.dart:345), so values vary by device language.

create table if not exists public.iciq_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  leak_frequency integer not null check (leak_frequency between 0 and 5),
  leak_amount integer not null check (leak_amount between 0 and 6),
  life_interference integer not null check (life_interference between 0 and 10),
  when_leaks jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists iciq_results_user_id_idx
  on public.iciq_results (user_id, created_at desc);

alter table public.iciq_results enable row level security;

drop policy if exists "Users can read their own ICIQ results" on public.iciq_results;
create policy "Users can read their own ICIQ results"
  on public.iciq_results
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own ICIQ results" on public.iciq_results;
create policy "Users can insert their own ICIQ results"
  on public.iciq_results
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own ICIQ results" on public.iciq_results;
create policy "Users can update their own ICIQ results"
  on public.iciq_results
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_iciq_results_updated_at on public.iciq_results;

create trigger set_iciq_results_updated_at
  before update on public.iciq_results
  for each row
  execute function public.set_updated_at();
