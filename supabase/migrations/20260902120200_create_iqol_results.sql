-- I-QOL responses: 22 Likert items plus the background questions.
--
-- Written by assessment_summary_notifier.dart:70 (insert), read by :151
-- (select id). The q1..q22 keys are built in the loop at :67. No iqol_score
-- column is created: that value is computed in IQOLModel and explicitly
-- dropped from the insert payload (:79).
--
-- Items are checked 0..5, not 1..5. The instrument only defines 1..5, but the
-- screen currently allows every question to be skipped (a PageView with
-- swiping enabled), which writes 0. Rejecting 0 here would turn that into a
-- failed insert the app silently swallows — losing the whole submission rather
-- than recording a partial one. Tighten to 1..5 once the swipe-past-validation
-- gap in iqol_screen.dart is closed.

create table if not exists public.iqol_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,

  q1  integer not null default 0 check (q1  between 0 and 5),
  q2  integer not null default 0 check (q2  between 0 and 5),
  q3  integer not null default 0 check (q3  between 0 and 5),
  q4  integer not null default 0 check (q4  between 0 and 5),
  q5  integer not null default 0 check (q5  between 0 and 5),
  q6  integer not null default 0 check (q6  between 0 and 5),
  q7  integer not null default 0 check (q7  between 0 and 5),
  q8  integer not null default 0 check (q8  between 0 and 5),
  q9  integer not null default 0 check (q9  between 0 and 5),
  q10 integer not null default 0 check (q10 between 0 and 5),
  q11 integer not null default 0 check (q11 between 0 and 5),
  q12 integer not null default 0 check (q12 between 0 and 5),
  q13 integer not null default 0 check (q13 between 0 and 5),
  q14 integer not null default 0 check (q14 between 0 and 5),
  q15 integer not null default 0 check (q15 between 0 and 5),
  q16 integer not null default 0 check (q16 between 0 and 5),
  q17 integer not null default 0 check (q17 between 0 and 5),
  q18 integer not null default 0 check (q18 between 0 and 5),
  q19 integer not null default 0 check (q19 between 0 and 5),
  q20 integer not null default 0 check (q20 between 0 and 5),
  q21 integer not null default 0 check (q21 between 0 and 5),
  q22 integer not null default 0 check (q22 between 0 and 5),

  duration_years integer not null default 0 check (duration_years >= 0),
  duration_months integer not null default 0 check (duration_months between 0 and 11),
  severity integer not null default 1 check (severity between 0 and 5),
  stress_leak boolean not null default false,
  urge_leak boolean not null default false,
  freq_code integer not null default 0 check (freq_code between 0 and 5),

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists iqol_results_user_id_idx
  on public.iqol_results (user_id, created_at desc);

alter table public.iqol_results enable row level security;

drop policy if exists "Users can read their own IQOL results" on public.iqol_results;
create policy "Users can read their own IQOL results"
  on public.iqol_results
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own IQOL results" on public.iqol_results;
create policy "Users can insert their own IQOL results"
  on public.iqol_results
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own IQOL results" on public.iqol_results;
create policy "Users can update their own IQOL results"
  on public.iqol_results
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

drop trigger if exists set_iqol_results_updated_at on public.iqol_results;

create trigger set_iqol_results_updated_at
  before update on public.iqol_results
  for each row
  execute function public.set_updated_at();
