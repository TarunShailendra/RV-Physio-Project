alter table public.profiles
  add column if not exists marital_status text,
  add column if not exists has_children boolean,
  add column if not exists delivery_type text,
  add column if not exists children_ages text,
  add column if not exists childbirth_pain_level integer check (childbirth_pain_level between 0 and 10),
  add column if not exists height_cm numeric,
  add column if not exists weight_kg numeric,
  add column if not exists has_diabetes boolean not null default false,
  add column if not exists has_hypertension boolean not null default false;