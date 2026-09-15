# Assessment-driven exercise protocols

**Date:** 2026-09-15
**Source of truth:** `App protocols with description.docx`, in the repository root.
**Status:** design approved in chat; awaiting spec review.

## Problem

The exercise section prescribes the same thing to everyone. `WeeklyPlan.getWeekPlan`
switches on the week number and returns one exercise name with one rep count, one
hold and one rest, and the notifier repeats it five times a day for seven days
across eight weeks. The patient's ICIQ and IPAQ answers influence exactly one
number — `recommendedStartWeek`, which only decides which week they begin at.

The protocol document replaces that with nine prescriptions selected from two axes,
where the exercises themselves, their reps, their hold times, the number of sets and
the number of days trained per week all differ. Nothing in the current model can
express that.

## Decisions taken before design

Four questions were settled with the project owner and are not open for
re-litigation during implementation:

1. **The two missing protocols.** The document defines seven of the nine matrix
   cells; Severe+Moderate and Severe+Low have no table. All three Severe cells use
   the single Severe protocol exactly as written, including its five days per week.
   It is already the most conservative plan in the document, so applying it to less
   active patients does not over-prescribe.
2. **ICIQ banding is unchanged.** `ICIQModel.severityBand` keeps its current
   cut-offs — 0–7 mild, 8–14 moderate, 15–21 severe. These differ from the published
   ICIQ-SF bands, which was raised and accepted deliberately. No patient is re-banded
   by this work.
3. **A day is a checklist, not a guided sequence.** The patient sees the day's items
   with their reps and holds, opens one to read its instructions and run a timer, and
   ticks it off. A day runs 20–30 minutes, so it must be resumable and re-orderable.
4. **Existing `exercise_logs` rows are deleted** by the migration. They were written
   under the old "five repeats of one exercise" meaning and cannot be mapped onto
   exercise identities that did not exist when they were recorded. The project owner
   confirmed this is development test data.

## What the document actually specifies

Two axes, nine cells, seven tables:

| UI severity ↓ / IPAQ → | High | Moderate | Low |
|---|---|---|---|
| Mild | Mild+High | Mild+Moderate | Mild+Low |
| Moderate | Moderate+High | Moderate+Moderate | Moderate+Low |
| Severe | Severe (as written) | Severe (reused) | Severe (reused) |

Each protocol carries an intensity phrase, a session time range, a type description,
and four week-blocks covering weeks 1–2, 3–4, 5–6 and 7–8. A block specifies how many
days per week are trained, a set count applied to all its general exercises, a
progression-focus label, and an ordered list of prescribed items.

**Days per week**, which the current model fixes at seven:

| Protocol | W1–2 | W3–4 | W5–6 | W7–8 |
|---|---|---|---|---|
| Mild+High, Moderate+High, all Severe | 5 | 5 | 5 | 5 |
| Mild+Moderate, Moderate+Moderate | 4 | 4 | 5 | 5 |
| Mild+Low, Moderate+Low | 3 | 4 | 4 | 5 |

**Items per day**, which the current model fixes at five:

| Protocol | W1–2 | W3–4 | W5–6 | W7–8 |
|---|---|---|---|---|
| Mild and Moderate, all activity levels | 12 | 14 | 15 | 15 |
| Severe | 6 | 11 | 12 | 13 |

The maximum is fifteen. A prescribed item is either a PFMT block — a body position,
a hold time, a relax time, reps and sets — or a general exercise with reps, an
optional hold, and the block's set count. Some general exercises have no hold at all
("Clamshells: 10 reps", "Straight leg raise: 8 reps no hold"), which the current
model cannot represent because `holdSeconds` is non-nullable.

Sixteen exercises are described in full, each with a starting position, four to six
how-to steps, and two to three DO/DON'T pairs. A set of general safety rules applies
across all of them.

## Approach

Protocol data is encoded as `const` Dart tables. Two alternatives were considered and
rejected: a bundled JSON asset, and protocol rows served from Supabase. The dataset is
seven protocols by four blocks by up to fifteen items, and every value in it is a hold
time or a rep count for a patient. In Dart the analyzer catches a missing or misnamed
field at compile time and tests can assert the tables against the document; in JSON the
same mistake surfaces at runtime, or silently as a wrong number. Neither alternative
removes the need for a rebuild and a release to change a prescription, so neither buys
anything the project needs today.

## Design

### Units and their boundaries

    lib/features/exercise/
      models/
        protocol.dart              Protocol, ProtocolWeekBlock, PrescribedItem, ExercisePosition
        exercise_model.dart        ExerciseSession, DayPlan, WeeklyPlan  (modified)
      protocols/
        exercise_catalogue.dart    the 16 exercises: id, display name, whether it holds
        protocol_tables.dart       the 7 const protocol definitions
        protocol_lookup.dart       protocolFor(severityBand, activityLevel)
      content/
        exercise_content.dart      per-exercise instructional prose, en now, kn later
      screens/
        exercise_screen.dart       day checklist  (rewritten)
        exercise_detail_sheet.dart one exercise: instructions, DO/DON'T, timer  (new)
      exercise_notifier.dart       plan state and progress  (modified)

Each unit has one job and a stated dependency direction. `protocol_tables` depends on
`exercise_catalogue` for ids and on `protocol.dart` for types, and on nothing else —
in particular not on Supabase, Flutter widgets, or localisation, so the whole protocol
dataset is testable as plain Dart. `exercise_content` is leaf data with no dependencies.
`protocol_lookup` is a pure function of two enums. Only the notifier and the screens
reach outward to Supabase and the widget tree.

### Types

`PrescribedItem` covers both kinds of item in one shape rather than a sealed hierarchy,
because the checklist renders them identically and only the detail sheet cares which is
which:

    class PrescribedItem {
      final String exerciseKey;        // 'pelvic_bridging', 'pfmt_slow', 'pfmt_quick'
      final ExercisePosition? position; // supine/sitting/standing; PFMT only, else null
      final int reps;
      final int? holdSeconds;          // null means the exercise has no hold
      final int? relaxSeconds;         // PFMT only
      final int sets;
    }

`ProtocolWeekBlock` holds `startWeek`, `endWeek`, `daysPerWeek`, `progressionFocus` and
`List<PrescribedItem> items`. `Protocol` holds an id, the two axis values, the intensity,
time-range and type phrases, four blocks, and `blockForWeek(int week)`.

### Selecting the protocol

`protocolFor` maps `(ICIQModel.severityBand, IPAQModel.activityLevel)` to a `Protocol`.
Both inputs already exist and are already computed; neither calculation changes. All
three severe cells resolve to the same protocol object. The function is total: every
one of the nine pairs returns a protocol, and a test asserts that.

When either questionnaire is missing, the patient has not finished onboarding and the
route guard already sends them to it. The lookup nonetheless falls back to the most
conservative plan — Severe — rather than throwing, so a data gap cannot produce a
harder prescription than the patient should receive.

### Building the plan

`WeeklyPlan.getWeekPlan(week)` is replaced by `WeeklyPlan.forProtocol(protocol, week)`.
It reads the block covering that week, generates `block.daysPerWeek` days rather than
seven, and gives each day one `ExerciseSession` per prescribed item rather than five
identical ones. `ExerciseSession` gains `exerciseKey`, `sets` and `position`, and its
`holdSeconds` becomes nullable.

Days within a block are identical to one another. The document varies prescriptions by
week-block, never by day, and inventing per-day variation would be inventing clinical
content.

**One item is one session, sets included.** A prescribed item of "12 reps × 2 sets"
produces a single `ExerciseSession` carrying `reps: 12, sets: 2`, and a single log row
when it is finished — not two rows. The detail sheet walks the patient through both
sets; the checklist ticks the item once. This keeps `session_number` equal to the item's
position in the day, which is what makes the day-complete check a simple count.

### Retiring the start-week skip

`recommendedStartWeek` currently starts milder, more active patients at week 2 or 3.
Once the protocol is itself selected from those same two scores, that jump would skip
the patient past their own protocol's "Baseline activation" block, which is where the
document places the foundational work. The personalisation moves from *which week you
start* to *which protocol you get*: every patient now begins their assigned protocol at
week 1.

`ExerciseNotifier.highestUnlockedWeek` loses its `_recommendedStartWeek` floor and
simply returns the first unfinished week. `resolveCurrentWeek` in the dashboard loses
its `recommendedStartWeek` parameter.

`AssessmentSummaryNotifier.recommendedStartWeek` is not merely deleted — a
`Protocol get protocol` replaces it and inherits its plumbing. The value currently
flows from the three assessment screens into two notifiers, and the protocol follows
exactly the same three call sites:

| Today | After |
|---|---|
| `summary.recommendedStartWeek` | `summary.protocol` |
| `ExerciseNotifier.loadRecommendedWeek(int)` | `ExerciseNotifier.applyProtocol(Protocol)` |
| `applyAssessmentSummary` raises `currentWeek` | `applyAssessmentSummary` stores the protocol |

`applyAssessmentSummary` keeps its other job — carrying `iciqScorePre` onto the
dashboard — and loses only the week-raising. The three assessment screens
(`iciq_screen.dart:73`, `ipaq_screen.dart`, `iqol_screen.dart`) change one argument
each.

### Persistence

`exercise_logs` keeps its `(user_id, week_number, day_number, session_number)` identity.
`session_number` becomes the one-based index of the item within its day, and its check
constraint widens from `between 1 and 5` to `between 1 and 30` — the real maximum is
fifteen, and the headroom costs nothing. `day_number`'s existing `between 1 and 7` still
covers the new range of three to five and is left alone.

A nullable `exercise_key text` column records which exercise a row refers to, so a log
row remains interpretable if the protocol tables are ever edited. `duration_seconds`
continues to be written as before.

The migration deletes existing rows, per the decision above, and is written so that
re-running it is harmless.

One risk is being watched here rather than assumed away: the existing insert path
swallows failures into a `debugPrint`, so a rejected constraint produces zero logs and a
dashboard reading week 1 at 0% with no error shown. The migration must therefore be
applied before the app ships, and the implementation plan includes verifying a real
write end to end rather than trusting the tests alone.

### Adherence

`DashboardNotifier`'s `sessionsPerDay = 5` and `daysPerWeek = 7` constants are the last
places that assume a fixed shape. Both become per-week lookups against the patient's
protocol: a day is complete when all of that block's items are logged, and a week's
adherence is completed days over `block.daysPerWeek`. `totalWeeks` stays at eight, which
every protocol shares.

`DashboardNotifier` therefore needs the protocol, which it obtains the same way the
exercise notifier does rather than recomputing it.

### Screens

The day view lists the day's items with reps and hold, a tick against each completed
one, and a progress count. Tapping an item opens a detail sheet carrying its starting
position, numbered steps, DO and DON'T columns, and a rep timer for items that have a
hold. Completing an item returns to the list. Partial days persist, because each item
is logged as it finishes.

The existing timer logic is reused for holds; items without a hold are counted rather
than timed. The general safety rules are reachable once from the day view rather than
repeated on every sheet.

### Content and translation

`exercise_content.dart` holds an `ExerciseContent` per exercise id with an `en` block
filled in and a `kn` block left null, falling back to English. Instructional prose is
content rather than UI labelling, so it stays out of the `.arb` files, which keeps those
readable and lets a translator later fill one clearly marked block without touching app
code. Buttons, headings and counts remain localised normally, and both `.arb` files keep
their existing parity.

This is a deliberate, visible gap: Kannada-speaking patients read English exercise
instructions until the translations are supplied.

## Testing

Written test-first, per the project's normal workflow.

- `protocolFor` returns a protocol for all nine severity/activity pairs, and the three
  severe pairs return the same one.
- Each protocol's four blocks cover weeks 1–8 with no gap or overlap, and
  `blockForWeek` agrees with them at every week from 1 to 8.
- Days per week and items per day match the two tables above, for all seven protocols —
  this is the test that pins the transcription to the document.
- Every `exerciseKey` in every protocol table exists in the catalogue, and every
  catalogue entry has content.
- `WeeklyPlan.forProtocol` produces the right number of days and the right number of
  sessions per day for a sample from each severity.
- Adherence is correct for a three-day week and a five-day week, including the
  regression that a part-finished new week does not report the previous week's figures.
- A day is complete only when every item is logged, not when five are.

Existing tests that encode the retired behaviour — `recommended_week_test.dart` and the
`recommendedStartWeek` cases in `redirect_policy_test.dart` — are updated to the new
rule rather than deleted, so the change in behaviour is recorded rather than lost.

## Out of scope

Kannada translations of the exercise descriptions. Editing protocols without an app
release. Per-day variation within a week-block. Any change to how ICIQ, IPAQ or I-QOL
are scored or banded. The unrelated open items on the project's list — rotating the
Supabase anon key, and the `duration_seconds` generated-column check.
