-- Let a patient keep more than one bladder diary.
--
-- 20260525090000_create_bladder_diaries.sql declared unique (user_id) while
-- the app inserts, so a second submission was rejected. That failure used to
-- be swallowed behind a success dialog; now that the diary reports what
-- actually happened, the patient would simply be told it did not save.
--
-- The app reads the newest row by submitted_at, which is only meaningful if
-- several can exist — so the constraint is what is wrong, not the insert.

alter table public.bladder_diaries
  drop constraint if exists bladder_diaries_user_unique;

-- The read path orders by submitted_at within a user.
create index if not exists bladder_diaries_user_submitted_idx
  on public.bladder_diaries (user_id, submitted_at desc);
