-- IPAQ (short form) responses.
--
-- Written by assessment_summary_notifier.dart:93 (insert), read by :139
-- (select id). No activity_level column is created: that value is computed in
-- IpaqNotifier and explicitly dropped from the insert payload (:106).
--
-- Day counts are bounded 0..7 because the sliders enforce that range
-- (ipaq_screen.dart:299). Hours and minutes are only bounded below, because
-- the hours/minutes inputs are free-text with no validation
-- (ipaq_screen.dart:436) — a tight upper bound would turn a typo into a
-- rejected insert, which the app currently swallows silently.

create table if not exists public.ipaq_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,

  sitting_hours integer not null default 0 check (sitting_hours >= 0),
  sitting_mins integer not null default 0 check (sitting_mins >= 0),

  walk_days integer not null default 0 check (walk_days between 0 and 7),
  walk_hours integer not null default 0 check (walk_hours >= 0),
  walk_mins integer not null default 0 check (walk_mins >= 0),

  moderate_days integer not null default 0 check (moderate_days between 0 and 7),
  moderate_hours integer not null default 0 check (moderate_hours >= 0),
  moderate_mins integer not null default 0 check (moderate_mins >= 0),

  vigorous_days integer not null default 0 check (vigorous_days between 0 and 7),
  vigorous_hours integer not null default 0 check (vigorous_hours >= 0),
  vigorous_mins integer not null default 0 check (vigorous_mins >= 0),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists ipaq_results_user_id_idx
  on public.ipaq_results (user_id, created_at desc);

alter table public.ipaq_results enable row level security;

drop policy if exists "Users can read their own IPAQ results" on public.ipaq_results;
create policy "Users can read their own IPAQ results"
  on public.ipaq_results
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own IPAQ results" on public.ipaq_results;
create policy "Users can insert their own IPAQ results"
  on public.ipaq_results
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own IPAQ results" on public.ipaq_results;
create policy "Users can update their own IPAQ results"
  on public.ipaq_results
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

drop trigger if exists set_ipaq_results_updated_at on public.ipaq_results;

create trigger set_ipaq_results_updated_at
  before update on public.ipaq_results
  for each row
  execute function public.set_updated_at();
