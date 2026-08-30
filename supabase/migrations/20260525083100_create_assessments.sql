create table if not exists public.assessments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  assessment_type text not null,
  responses jsonb not null default '{}'::jsonb,
  score numeric not null default 0,
  completed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint assessments_assessment_type_check
    check (assessment_type in ('iciq', 'ipaq', 'iqol')),
  constraint assessments_user_type_unique unique (user_id, assessment_type)
);

alter table public.assessments enable row level security;

create policy "Users can read their own assessments"
  on public.assessments
  for select
  using (auth.uid() = user_id);

create policy "Users can insert their own assessments"
  on public.assessments
  for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own assessments"
  on public.assessments
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

drop trigger if exists set_assessments_updated_at on public.assessments;

create trigger set_assessments_updated_at
  before update on public.assessments
  for each row
  execute function public.set_updated_at();
