create table if not exists public.exercise_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  week_number integer not null check (week_number between 1 and 8),
  completed_sessions jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint exercise_progress_user_week_unique unique (user_id, week_number)
);

alter table public.exercise_progress enable row level security;

drop policy if exists "Users can read their own exercise progress" on public.exercise_progress;
create policy "Users can read their own exercise progress"
  on public.exercise_progress
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own exercise progress" on public.exercise_progress;
create policy "Users can insert their own exercise progress"
  on public.exercise_progress
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own exercise progress" on public.exercise_progress;
create policy "Users can update their own exercise progress"
  on public.exercise_progress
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

drop trigger if exists set_exercise_progress_updated_at on public.exercise_progress;

create trigger set_exercise_progress_updated_at
  before update on public.exercise_progress
  for each row
  execute function public.set_updated_at();
