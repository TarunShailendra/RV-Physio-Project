-- Per-session exercise log: 8 weeks x 7 days x 5 sessions.
--
-- Written by exercise_notifier.dart:200 (upsert), read by :72 and by
-- dashboard_notifier.dart:29/50/71.
--
-- The upsert passes onConflict: 'user_id,week_number,day_number,session_number'.
-- Postgres can only resolve that against a unique index or constraint on
-- exactly those four columns — without one, every session completion fails
-- with "no unique or exclusion constraint matching the ON CONFLICT
-- specification", which the app swallows into a debugPrint. The unique index
-- below is what makes the existing upsert work.
--
-- It is created as a standalone `create unique index if not exists` rather than
-- an inline table constraint so that it is also added to any database where
-- exercise_logs already exists without it.
--
-- This table supersedes public.exercise_progress from
-- 20260525091500_create_exercise_progress.sql, which no code references. That
-- table is left in place rather than dropped — removing it is a data-bearing
-- decision, not a schema fix.

create table if not exists public.exercise_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,

  week_number integer not null check (week_number between 1 and 8),
  day_number integer not null check (day_number between 1 and 7),
  session_number integer not null check (session_number between 1 and 5),

  exercise_name text,
  reps integer check (reps >= 0),
  hold_seconds integer check (hold_seconds >= 0),
  rest_seconds integer check (rest_seconds >= 0),
  duration_seconds integer check (duration_seconds >= 0),

  completed boolean not null default false,
  completed_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Required by the onConflict target in exercise_notifier.dart:212.
create unique index if not exists exercise_logs_user_week_day_session_key
  on public.exercise_logs (user_id, week_number, day_number, session_number);

-- Supports the "completed logs for this user" queries in loadProgress and
-- loadDashboard, which always filter on user_id + completed.
create index if not exists exercise_logs_user_completed_idx
  on public.exercise_logs (user_id, completed);

alter table public.exercise_logs enable row level security;

drop policy if exists "Users can read their own exercise logs" on public.exercise_logs;
create policy "Users can read their own exercise logs"
  on public.exercise_logs
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own exercise logs" on public.exercise_logs;
create policy "Users can insert their own exercise logs"
  on public.exercise_logs
  for insert
  with check (auth.uid() = user_id);

-- The upsert needs UPDATE as well as INSERT: repeating a session takes the
-- ON CONFLICT DO UPDATE path.
drop policy if exists "Users can update their own exercise logs" on public.exercise_logs;
create policy "Users can update their own exercise logs"
  on public.exercise_logs
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

drop trigger if exists set_exercise_logs_updated_at on public.exercise_logs;

create trigger set_exercise_logs_updated_at
  before update on public.exercise_logs
  for each row
  execute function public.set_updated_at();
