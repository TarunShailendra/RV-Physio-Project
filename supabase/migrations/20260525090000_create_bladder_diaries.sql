create table if not exists public.bladder_diaries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  diary jsonb not null default '{}'::jsonb,
  submitted_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bladder_diaries_user_unique unique (user_id)
);

alter table public.bladder_diaries enable row level security;

drop policy if exists "Users can read their own bladder diaries" on public.bladder_diaries;
create policy "Users can read their own bladder diaries"
  on public.bladder_diaries
  for select
  using (auth.uid() = user_id);

drop policy if exists "Users can insert their own bladder diaries" on public.bladder_diaries;
create policy "Users can insert their own bladder diaries"
  on public.bladder_diaries
  for insert
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own bladder diaries" on public.bladder_diaries;
create policy "Users can update their own bladder diaries"
  on public.bladder_diaries
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

drop trigger if exists set_bladder_diaries_updated_at on public.bladder_diaries;

create trigger set_bladder_diaries_updated_at
  before update on public.bladder_diaries
  for each row
  execute function public.set_updated_at();
