-- Patient profile, keyed to the Supabase auth user.
--
-- This migration is dated before 20260802000000_add_profile_fields.sql, which
-- alters this table. Without it, a clean `supabase db push` fails on that
-- ALTER because no migration ever created public.profiles.
--
-- Columns mirror exactly what the app reads and writes:
--   auth_notifier.dart:33      select full_name, city, date_of_birth, phone, email
--   auth_notifier.dart:94      upsert id, full_name, phone, email, date_of_birth
--   profile_notifier.dart:217  select (all columns below)
--   profile_notifier.dart:237  upsert (all columns below)
--
-- The nine columns added by 20260802000000 (marital_status, has_children,
-- delivery_type, children_ages, childbirth_pain_level, height_cm, weight_kg,
-- has_diabetes, has_hypertension) are deliberately left to that migration so
-- the history stays honest. `gender` is created here because no existing
-- migration adds it, even though profile_notifier.dart:217 selects it.

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  phone text,
  date_of_birth date,
  gender text,
  city text,
  occupation text,
  incontinence_type text,
  symptom_duration_months integer check (symptom_duration_months >= 0),
  has_sought_treatment boolean not null default false,
  profile_completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Users can read their own profile" on public.profiles;
create policy "Users can read their own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
  on public.profiles
  for insert
  with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_profiles_updated_at on public.profiles;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row
  execute function public.set_updated_at();
