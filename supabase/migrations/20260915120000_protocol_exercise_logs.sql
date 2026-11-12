-- Widen exercise_logs for the assessment-driven protocols.
--
-- A day used to be five repeats of one exercise, and session_number was which
-- of those five it was. Under the protocol document a day is a pelvic floor
-- block plus up to thirteen other exercises, so session_number now indexes the
-- item within its day and reaches fifteen in the longest weeks.
--
-- The old check (session_number between 1 and 5) rejected everything past the
-- fifth item. exercise_notifier swallows insert failures into a debugPrint, so
-- that rejection would have been silent: no rows, no error on screen, and a
-- dashboard stuck at week 1 and 0% with nothing to explain why. The ceiling is
-- 30 rather than 15 so that a future protocol with a longer day does not
-- reintroduce the same silent failure.

alter table public.exercise_logs
  drop constraint if exists exercise_logs_session_number_check;

alter table public.exercise_logs
  add constraint exercise_logs_session_number_check
  check (session_number between 1 and 30);

-- Which exercise a row refers to, so a log stays interpretable if the protocol
-- tables are ever edited or the display names change. Nullable, because rows
-- predating this column cannot be back-filled: the exercise identities did not
-- exist when those rows were written.
alter table public.exercise_logs
  add column if not exists exercise_key text;

-- Existing rows were written under the old meaning of session_number and
-- cannot be mapped onto exercise identities that did not exist at the time.
-- Leaving them would make every affected day read as part-finished, which the
-- dashboard would then report as an adherence figure. The project owner
-- confirmed this table holds development test data only.
delete from public.exercise_logs;
