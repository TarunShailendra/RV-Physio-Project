-- Store the values the app computes and then discarded.
--
-- saveIqol dropped iqol_score and saveIpaq dropped activity_level, each with a
-- "removed:" comment. Both are derivable from the stored answers, so nothing
-- was lost permanently — but anyone querying these tables for outcomes had to
-- reimplement the scoring, and the IPAQ classification in particular is a
-- twenty-line rule that would be easy to reimplement differently.

alter table public.iqol_results
  add column if not exists iqol_score numeric
    check (iqol_score is null or (iqol_score >= 0 and iqol_score <= 100));

alter table public.ipaq_results
  add column if not exists activity_level text
    check (activity_level is null or activity_level in ('low', 'moderate', 'high'));
