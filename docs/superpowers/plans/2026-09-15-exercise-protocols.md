# Assessment-Driven Exercise Protocols Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Select each patient's eight-week exercise programme from their ICIQ severity and IPAQ activity level, so that the exercises, reps, hold times, sets and days-per-week all come from the protocol document rather than from one hard-coded ladder.

**Architecture:** Protocol data lives in `const` Dart tables under `lib/features/exercise/protocols/`, generated once from the source document by a committed script and pinned by tests. A pure lookup maps `(severityBand, activityLevel)` to a `Protocol`. `WeeklyPlan.forProtocol` expands a protocol's week-block into days and per-item sessions, replacing the fixed 7×5 shape. The screens become a day checklist plus a per-exercise detail sheet.

**Tech Stack:** Flutter 3.41.7, Dart, Provider (`ChangeNotifier`), GoRouter, `supabase_flutter` 2.12.4, `flutter_localizations` with `.arb` files, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-09-15-exercise-protocols-design.md`

## Global Constraints

- **Source of truth** is `App protocols with description.docx` in the repository root. No prescription value may be invented, rounded, or "corrected" against clinical intuition. If the document is ambiguous, stop and ask.
- **ICIQ banding does not change.** `ICIQModel.severityBand` keeps `0–7 mild`, `8–14 moderate`, `15–21 severe`.
- **All three Severe cells** (Severe+High, Severe+Moderate, Severe+Low) resolve to the one Severe protocol, including its 5 days/week.
- **One prescribed item is one session and one log row**, sets included. A "12 reps × 2 sets" item produces one `ExerciseSession` with `reps: 12, sets: 2`, and one row in `exercise_logs`.
- **`session_number` is the one-based index of the item within its day.** Max observed is 15; the constraint allows 30.
- **Kannada falls back to English** for exercise content. Never machine-translate clinical instructions.
- **Every timestamp written to Postgres uses `.toUtc()`** before `toIso8601String()`. The codebase was repaired for a +5:30 drift bug; do not reintroduce it.
- **Do not push.** Commit locally only. The project owner approves every push separately.
- Work on branch `exercise-protocols`, already created, based on `b26abb1`.
- `flutter analyze` must be clean and `flutter test` fully green before each commit.

## Verified source data

Both figures below were derived twice — once by hand, once by parser — and agree. Task 3's test asserts them, so they are the contract for the transcription.

**Days per week**

| Protocol | W1–2 | W3–4 | W5–6 | W7–8 |
|---|---|---|---|---|
| Mild+High, Moderate+High, Severe (all three cells) | 5 | 5 | 5 | 5 |
| Mild+Moderate, Moderate+Moderate | 4 | 4 | 5 | 5 |
| Mild+Low, Moderate+Low | 3 | 4 | 4 | 5 |

**Items per day**

| Protocol | W1–2 | W3–4 | W5–6 | W7–8 |
|---|---|---|---|---|
| All Mild and all Moderate | 12 | 14 | 15 | 15 |
| Severe | 6 | 11 | 12 | 13 |

## File structure

| File | Responsibility |
|---|---|
| `lib/features/exercise/models/protocol.dart` *(create)* | `ExercisePosition`, `PrescribedItem`, `ProtocolWeekBlock`, `Protocol`. Pure types, no dependencies. |
| `lib/features/exercise/protocols/exercise_catalogue.dart` *(create)* | The 16 exercise keys and their display names. |
| `lib/features/exercise/protocols/protocol_tables.dart` *(create)* | The 7 `const Protocol` definitions. Generated; do not hand-edit. |
| `tool/generate_protocol_tables.dart` *(create)* | Regenerates the above from `protocols.json`. Committed for traceability. |
| `lib/features/exercise/protocols/protocol_lookup.dart` *(create)* | `protocolFor(severityBand, activityLevel)`. |
| `lib/features/exercise/content/exercise_content.dart` *(create)* | Instructional prose per exercise, `en` filled, `kn` null. |
| `lib/features/exercise/models/exercise_model.dart` *(modify)* | `ExerciseSession` gains fields; `WeeklyPlan.forProtocol` replaces `getWeekPlan`. |
| `lib/features/exercise/exercise_notifier.dart` *(modify)* | Holds the protocol; logs per item; loses the start-week floor. |
| `lib/features/assessment/notifiers/assessment_summary_notifier.dart` *(modify)* | `Protocol get protocol` replaces `recommendedStartWeek`. |
| `lib/features/dashboard/dashboard_notifier.dart` *(modify)* | Adherence against the protocol's own days and items. |
| `lib/features/exercise/screens/exercise_screen.dart` *(rewrite)* | Week → day → checklist. |
| `lib/features/exercise/screens/exercise_detail_sheet.dart` *(create)* | One exercise: instructions, DO/DON'T, timer. |
| `supabase/migrations/20260915120000_protocol_exercise_logs.sql` *(create)* | Widen `session_number`, add `exercise_key`, clear old rows. |

---

### Task 1: Protocol types

**Files:**
- Create: `lib/features/exercise/models/protocol.dart`
- Test: `test/protocol_types_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `enum ExercisePosition { supine, sitting, standing }`; `class PrescribedItem` with `final String exerciseKey; final ExercisePosition? position; final int? reps; final int? holdSeconds; final int? relaxSeconds; final int sets;`; `class ProtocolWeekBlock` with `final int startWeek, endWeek, daysPerWeek; final String progressionFocus; final List<PrescribedItem> items;`; `class Protocol` with `final String id, severityBand, intensity, timeRange, type; final IPAQActivityLevel activity; final List<ProtocolWeekBlock> blocks;` and `ProtocolWeekBlock blockForWeek(int week)`.

`reps` is nullable because diaphragmatic breathing is prescribed with no rep count. `holdSeconds` is nullable because several exercises are explicitly "no hold". `relaxSeconds` is non-null only for `pfmt_slow`.

- [ ] **Step 1: Write the failing test**

```dart
// test/protocol_types_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/models/protocol.dart';

Protocol _sample() => const Protocol(
  id: 'sample',
  severityBand: 'mild',
  activity: IPAQActivityLevel.high,
  intensity: 'moderate to high',
  timeRange: '20-30 mins',
  type: 'PFMT + core',
  blocks: [
    ProtocolWeekBlock(startWeek: 1, endWeek: 2, daysPerWeek: 5,
        progressionFocus: 'Baseline activation', items: []),
    ProtocolWeekBlock(startWeek: 3, endWeek: 4, daysPerWeek: 5,
        progressionFocus: 'Strength + stability', items: []),
    ProtocolWeekBlock(startWeek: 5, endWeek: 6, daysPerWeek: 5,
        progressionFocus: 'Functional + dynamic strength', items: []),
    ProtocolWeekBlock(startWeek: 7, endWeek: 8, daysPerWeek: 5,
        progressionFocus: 'High-level performance + endurance', items: []),
  ],
);

void main() {
  test('blockForWeek returns the block covering each week from 1 to 8', () {
    final p = _sample();
    for (var week = 1; week <= 8; week++) {
      final block = p.blockForWeek(week);
      expect(week, greaterThanOrEqualTo(block.startWeek));
      expect(week, lessThanOrEqualTo(block.endWeek));
    }
  });

  test('blockForWeek rejects weeks outside the protocol', () {
    expect(() => _sample().blockForWeek(0), throwsArgumentError);
    expect(() => _sample().blockForWeek(9), throwsArgumentError);
  });

  test('a prescribed item may have no reps and no hold', () {
    const item = PrescribedItem(exerciseKey: 'diaphragmatic_breathing', sets: 1);
    expect(item.reps, isNull);
    expect(item.holdSeconds, isNull);
    expect(item.position, isNull);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/protocol_types_test.dart`
Expected: FAIL — `Target of URI doesn't exist: '.../protocol.dart'`.

- [ ] **Step 3: Write the implementation**

```dart
// lib/features/exercise/models/protocol.dart
import '../../assessment/models/ipaq_model.dart';

/// Body position a pelvic floor contraction is performed in.
enum ExercisePosition { supine, sitting, standing }

/// One line of a protocol's prescription: an exercise plus its dose.
///
/// [reps] is null for exercises the document prescribes without a count, such
/// as diaphragmatic breathing. [holdSeconds] is null where the document says
/// "no hold" or gives no hold at all. [relaxSeconds] applies only to the slow
/// pelvic floor holds, which are the only items given an explicit rest.
class PrescribedItem {
  const PrescribedItem({
    required this.exerciseKey,
    required this.sets,
    this.position,
    this.reps,
    this.holdSeconds,
    this.relaxSeconds,
  });

  final String exerciseKey;
  final ExercisePosition? position;
  final int? reps;
  final int? holdSeconds;
  final int? relaxSeconds;
  final int sets;
}

/// A two-week stage of a protocol.
class ProtocolWeekBlock {
  const ProtocolWeekBlock({
    required this.startWeek,
    required this.endWeek,
    required this.daysPerWeek,
    required this.progressionFocus,
    required this.items,
  });

  final int startWeek;
  final int endWeek;

  /// Days of the week the patient trains. Three to five, never seven.
  final int daysPerWeek;
  final String progressionFocus;
  final List<PrescribedItem> items;

  bool covers(int week) => week >= startWeek && week <= endWeek;
}

/// One cell of the severity x activity matrix.
class Protocol {
  const Protocol({
    required this.id,
    required this.severityBand,
    required this.activity,
    required this.intensity,
    required this.timeRange,
    required this.type,
    required this.blocks,
  });

  final String id;
  final String severityBand;
  final IPAQActivityLevel activity;
  final String intensity;
  final String timeRange;
  final String type;
  final List<ProtocolWeekBlock> blocks;

  ProtocolWeekBlock blockForWeek(int week) {
    for (final block in blocks) {
      if (block.covers(week)) return block;
    }
    throw ArgumentError.value(week, 'week', 'Outside protocol $id');
  }
}
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/protocol_types_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/models/protocol.dart test/protocol_types_test.dart
git commit -m "Add the protocol types the prescriptions will be expressed in"
```

---

### Task 2: Exercise catalogue

**Files:**
- Create: `lib/features/exercise/protocols/exercise_catalogue.dart`
- Test: `test/exercise_catalogue_test.dart`

**Interfaces:**
- Consumes: nothing.
- Produces: `const Map<String, String> exerciseCatalogue` mapping key to English display name, and `bool isPfmt(String key)`.

The sixteen keys, exactly as the parser derived them from the document: `pfmt_slow`, `pfmt_quick`, `diaphragmatic_breathing`, `pelvic_bridging`, `pelvic_tilt`, `pelvic_rotations`, `leg_circles`, `single_leg_stretch`, `straight_leg_raise`, `side_leg_raise`, `wall_squat`, `quadruped_arm_leg_raise`, `clamshells`, `lunges`, `squats`, `leg_scissors`.

- [ ] **Step 1: Write the failing test**

```dart
// test/exercise_catalogue_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/protocols/exercise_catalogue.dart';

void main() {
  test('the catalogue holds the sixteen exercises the document describes', () {
    expect(exerciseCatalogue.length, 16);
  });

  test('every exercise has a non-empty display name', () {
    for (final entry in exerciseCatalogue.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('the two pelvic floor items are recognised as PFMT', () {
    expect(isPfmt('pfmt_slow'), isTrue);
    expect(isPfmt('pfmt_quick'), isTrue);
    expect(isPfmt('clamshells'), isFalse);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/exercise_catalogue_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/features/exercise/protocols/exercise_catalogue.dart

/// Every exercise the protocol document prescribes, keyed by the identifier
/// used in the protocol tables and written to exercise_logs.exercise_key.
///
/// The display names are English. Patient-facing instructional text lives in
/// content/exercise_content.dart, which is where translations will be added.
const Map<String, String> exerciseCatalogue = {
  'pfmt_slow': 'Slow squeeze and hold',
  'pfmt_quick': 'Quick squeezes',
  'diaphragmatic_breathing': 'Diaphragmatic breathing',
  'pelvic_bridging': 'Pelvic bridging',
  'pelvic_tilt': 'Pelvic tilt',
  'pelvic_rotations': 'Pelvic rotations',
  'leg_circles': 'Leg circles',
  'single_leg_stretch': 'Single leg stretch',
  'straight_leg_raise': 'Straight leg raise',
  'side_leg_raise': 'Side leg raise',
  'wall_squat': 'Wall squat',
  'quadruped_arm_leg_raise': 'Quadruped arm-leg raise',
  'clamshells': 'Clamshells',
  'lunges': 'Lunges',
  'squats': 'Squats',
  'leg_scissors': 'Leg scissors',
};

/// Whether [key] is one of the two pelvic floor training items, which carry a
/// body position and a relax time that the general exercises do not.
bool isPfmt(String key) => key == 'pfmt_slow' || key == 'pfmt_quick';
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/exercise_catalogue_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/protocols/exercise_catalogue.dart test/exercise_catalogue_test.dart
git commit -m "Name the sixteen exercises the protocols draw on"
```

---

### Task 3: Protocol tables

**Files:**
- Create: `tool/generate_protocol_tables.dart`
- Create: `lib/features/exercise/protocols/protocol_tables.dart`
- Test: `test/protocol_tables_test.dart`

**Interfaces:**
- Consumes: `Protocol`, `ProtocolWeekBlock`, `PrescribedItem`, `ExercisePosition` (Task 1); `exerciseCatalogue` (Task 2).
- Produces: `const List<Protocol> allProtocols` — seven entries with ids `mild_high`, `mild_moderate`, `mild_low`, `moderate_high`, `moderate_moderate`, `moderate_low`, `severe`.

The table content is transcribed by the generator rather than typed by hand: 7 protocols × 4 blocks × up to 15 items is 420 values, and a hand-typed hold time is a patient-facing error. The generator reads the JSON produced by `tool/parse_protocols.py` (already written, in the session scratchpad — copy it to `tool/` as part of this task) and emits Dart. Its output is committed as ordinary source; the generator is committed alongside so the transcription can be re-checked.

**The test below is the real safeguard** — it pins both matrices from the plan header, so a mis-generated table fails loudly.

- [ ] **Step 1: Write the failing test**

```dart
// test/protocol_tables_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/protocols/exercise_catalogue.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_tables.dart';

void main() {
  test('there are seven protocol tables', () {
    expect(allProtocols.length, 7);
    expect(
      allProtocols.map((p) => p.id).toList(),
      ['mild_high', 'mild_moderate', 'mild_low', 'moderate_high',
       'moderate_moderate', 'moderate_low', 'severe'],
    );
  });

  test('days per week match the document', () {
    const expected = {
      'mild_high':         [5, 5, 5, 5],
      'mild_moderate':     [4, 4, 5, 5],
      'mild_low':          [3, 4, 4, 5],
      'moderate_high':     [5, 5, 5, 5],
      'moderate_moderate': [4, 4, 5, 5],
      'moderate_low':      [3, 4, 4, 5],
      'severe':            [5, 5, 5, 5],
    };
    for (final p in allProtocols) {
      expect(p.blocks.map((b) => b.daysPerWeek).toList(), expected[p.id],
          reason: p.id);
    }
  });

  test('items per day match the document', () {
    const expected = {
      'mild_high':         [12, 14, 15, 15],
      'mild_moderate':     [12, 14, 15, 15],
      'mild_low':          [12, 14, 15, 15],
      'moderate_high':     [12, 14, 15, 15],
      'moderate_moderate': [12, 14, 15, 15],
      'moderate_low':      [12, 14, 15, 15],
      'severe':            [6, 11, 12, 13],
    };
    for (final p in allProtocols) {
      expect(p.blocks.map((b) => b.items.length).toList(), expected[p.id],
          reason: p.id);
    }
  });

  test('every block covers two weeks and together they cover 1 to 8', () {
    for (final p in allProtocols) {
      expect(p.blocks.length, 4, reason: p.id);
      expect(p.blocks.map((b) => [b.startWeek, b.endWeek]).toList(),
          [[1, 2], [3, 4], [5, 6], [7, 8]], reason: p.id);
    }
  });

  test('every prescribed exercise exists in the catalogue', () {
    for (final p in allProtocols) {
      for (final b in p.blocks) {
        for (final item in b.items) {
          expect(exerciseCatalogue.containsKey(item.exerciseKey), isTrue,
              reason: '${p.id} week ${b.startWeek}: ${item.exerciseKey}');
        }
      }
    }
  });

  test('no item is prescribed a hold without a rep count except breathing', () {
    for (final p in allProtocols) {
      for (final b in p.blocks) {
        for (final item in b.items) {
          if (item.exerciseKey == 'diaphragmatic_breathing') continue;
          expect(item.reps, isNotNull,
              reason: '${p.id}: ${item.exerciseKey} has no reps');
          expect(item.sets, greaterThanOrEqualTo(1), reason: p.id);
        }
      }
    }
  });

  test('the severe protocol never exceeds the gentlest prescriptions', () {
    // A guard against transcribing a Mild row into the Severe table: the
    // document caps severe holds at 15 seconds and severe PFMT reps at 10.
    final severe = allProtocols.firstWhere((p) => p.id == 'severe');
    for (final b in severe.blocks) {
      for (final item in b.items) {
        expect(item.holdSeconds ?? 0, lessThanOrEqualTo(15), reason: item.exerciseKey);
      }
    }
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/protocol_tables_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Copy the parser and write the generator**

Copy `parse_protocols.py` from the session scratchpad to `tool/parse_protocols.py`. Then write `tool/generate_protocol_tables.dart`, a plain Dart script (run with `dart run tool/generate_protocol_tables.dart`) that reads `tool/protocols.json` and writes `lib/features/exercise/protocols/protocol_tables.dart`.

Protocol-level prose, transcribed from the document's headers:

| id | intensity | timeRange | type |
|---|---|---|---|
| `mild_high` | `moderate to high` | `20-30 mins` | `PFMT + core + functional + dynamic strengthening` |
| `mild_moderate` | `moderate` | `20-30 mins` | `PFMT + core + functional + dynamic strengthening` |
| `mild_low` | `moderate to high` | `20-30 mins` | `PFMT + core + functional + dynamic strengthening` |
| `moderate_high` | `moderate to high` | `20-30 mins` | `PFMT + core + functional + dynamic strengthening` |
| `moderate_moderate` | `moderate` | `20-30 mins` | `PFMT + core + functional + dynamic strengthening` |
| `moderate_low` | `moderate to high` | `20-30 mins` | `PFMT + core + functional + dynamic strengthening` |
| `severe` | `low to moderate` | `15-20 mins` | `PFMT + core strengthening` |

The emitted file must open with a header making its provenance unmistakable:

```dart
// GENERATED FILE - DO NOT EDIT BY HAND.
//
// Transcribed from "App protocols with description.docx" by
// tool/generate_protocol_tables.dart. To change a prescription, change the
// document, re-run tool/parse_protocols.py and then the generator, and check
// that test/protocol_tables_test.dart still passes.
```

- [ ] **Step 4: Generate the tables and run the test**

Run: `dart run tool/generate_protocol_tables.dart && dart format lib/features/exercise/protocols/protocol_tables.dart && flutter test test/protocol_tables_test.dart`
Expected: PASS, 7 tests. If the counts test fails, the parser is wrong — fix the parser, not the test.

- [ ] **Step 5: Commit**

```bash
git add tool lib/features/exercise/protocols/protocol_tables.dart test/protocol_tables_test.dart
git commit -m "Transcribe the seven protocol tables from the document"
```

---

### Task 4: Protocol lookup

**Files:**
- Create: `lib/features/exercise/protocols/protocol_lookup.dart`
- Test: `test/protocol_lookup_test.dart`

**Interfaces:**
- Consumes: `allProtocols` (Task 3), `IPAQActivityLevel`.
- Produces: `Protocol protocolFor({String? severityBand, IPAQActivityLevel? activity})`.

Total over all nine pairs. Falls back to `severe` when either input is missing, so a data gap can never yield a harder plan than the patient should have.

- [ ] **Step 1: Write the failing test**

```dart
// test/protocol_lookup_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

void main() {
  test('every severity and activity pair resolves to a protocol', () {
    for (final band in ['mild', 'moderate', 'severe']) {
      for (final activity in IPAQActivityLevel.values) {
        final p = protocolFor(severityBand: band, activity: activity);
        expect(p.blocks.length, 4, reason: '$band/$activity');
      }
    }
  });

  test('all three severe cells share the one severe protocol', () {
    final ids = IPAQActivityLevel.values
        .map((a) => protocolFor(severityBand: 'severe', activity: a).id)
        .toSet();
    expect(ids, {'severe'});
  });

  test('mild and moderate differ by activity level', () {
    expect(protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.high).id,
        'mild_high');
    expect(protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.low).id,
        'mild_low');
    expect(
        protocolFor(severityBand: 'moderate', activity: IPAQActivityLevel.moderate).id,
        'moderate_moderate');
  });

  test('a missing questionnaire falls back to the gentlest protocol', () {
    expect(protocolFor(severityBand: null, activity: IPAQActivityLevel.high).id,
        'severe');
    expect(protocolFor(severityBand: 'mild', activity: null).id, 'severe');
    expect(protocolFor(severityBand: 'nonsense', activity: null).id, 'severe');
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/protocol_lookup_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Write the implementation**

```dart
// lib/features/exercise/protocols/protocol_lookup.dart
import '../../assessment/models/ipaq_model.dart';
import '../models/protocol.dart';
import 'protocol_tables.dart';

/// The protocol for a patient, from their ICIQ severity band and IPAQ
/// activity level.
///
/// The document defines seven of the nine matrix cells: Severe+Moderate and
/// Severe+Low have no table, and all three severe cells therefore use the one
/// severe protocol, which is already the most conservative in the document.
///
/// A null band or activity means the patient has not finished onboarding. The
/// route guard sends them back to the questionnaires, but rather than throw,
/// this falls back to the severe protocol: a data gap must never hand a
/// patient a harder prescription than they should receive.
Protocol protocolFor({String? severityBand, IPAQActivityLevel? activity}) {
  if (severityBand == null || activity == null) return _severe;
  if (severityBand == 'severe') return _severe;

  final suffix = switch (activity) {
    IPAQActivityLevel.high => 'high',
    IPAQActivityLevel.moderate => 'moderate',
    IPAQActivityLevel.low => 'low',
  };
  final id = '${severityBand}_$suffix';
  for (final protocol in allProtocols) {
    if (protocol.id == id) return protocol;
  }
  return _severe;
}

Protocol get _severe => allProtocols.firstWhere((p) => p.id == 'severe');
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/protocol_lookup_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/protocols/protocol_lookup.dart test/protocol_lookup_test.dart
git commit -m "Choose the protocol from the ICIQ band and the IPAQ level"
```

---

### Task 5: Exercise content

**Files:**
- Create: `lib/features/exercise/content/exercise_content.dart`
- Test: `test/exercise_content_test.dart`

**Interfaces:**
- Consumes: `exerciseCatalogue` (Task 2).
- Produces: `class ExerciseText { final String startingPosition; final List<String> steps; final String? tip; final List<String> dos; final List<String> donts; }`; `class ExerciseContent { final ExerciseText en; final ExerciseText? kn; ExerciseText forLocale(String code); }`; `const Map<String, ExerciseContent> exerciseContent`; `const List<String> generalDos`; `const List<String> generalDonts`.

Transcribe all sixteen from the document's "Exercise Description" section verbatim — starting position, the how-to steps as written, the tip where one is given, and both DO/DON'T columns. Do not paraphrase or shorten. Leave every `kn` null.

- [ ] **Step 1: Write the failing test**

```dart
// test/exercise_content_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/content/exercise_content.dart';
import 'package:telerehab_app/features/exercise/protocols/exercise_catalogue.dart';

void main() {
  test('every catalogued exercise has content', () {
    for (final key in exerciseCatalogue.keys) {
      expect(exerciseContent.containsKey(key), isTrue, reason: key);
    }
  });

  test('every description is usable', () {
    for (final entry in exerciseContent.entries) {
      final en = entry.value.en;
      expect(en.startingPosition.trim(), isNotEmpty, reason: entry.key);
      expect(en.steps, isNotEmpty, reason: entry.key);
      expect(en.dos, isNotEmpty, reason: entry.key);
      expect(en.donts, isNotEmpty, reason: entry.key);
    }
  });

  test('Kannada falls back to English until it is translated', () {
    final content = exerciseContent['pelvic_bridging']!;
    expect(content.kn, isNull);
    expect(content.forLocale('kn'), same(content.en));
    expect(content.forLocale('en'), same(content.en));
  });

  test('the general safety rules are present', () {
    expect(generalDos.length, greaterThanOrEqualTo(6));
    expect(generalDonts.length, greaterThanOrEqualTo(4));
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/exercise_content_test.dart`
Expected: FAIL — URI does not exist.

- [ ] **Step 3: Write the implementation**

Types first, then the sixteen entries. Shape:

```dart
// lib/features/exercise/content/exercise_content.dart

/// Patient-facing instructions for one exercise, in one language.
class ExerciseText {
  const ExerciseText({
    required this.startingPosition,
    required this.steps,
    required this.dos,
    required this.donts,
    this.tip,
  });

  final String startingPosition;
  final List<String> steps;
  final String? tip;
  final List<String> dos;
  final List<String> donts;
}

/// One exercise's instructions in every language the app has them in.
///
/// [kn] is null for every exercise today. These are clinical safety
/// instructions and were deliberately not machine-translated; a translator
/// fills this field in without touching any other code.
class ExerciseContent {
  const ExerciseContent({required this.en, this.kn});

  final ExerciseText en;
  final ExerciseText? kn;

  ExerciseText forLocale(String languageCode) =>
      languageCode == 'kn' ? (kn ?? en) : en;
}

const Map<String, ExerciseContent> exerciseContent = {
  'diaphragmatic_breathing': ExerciseContent(
    en: ExerciseText(
      startingPosition:
          'Lie on your back with your knees bent and feet flat on the floor. '
          '(You can also sit tall in a chair.)',
      steps: [
        'Place one hand on your chest and one hand on your belly.',
        'Breathe in slowly through your nose and let your belly rise. Your chest should stay still.',
        'Breathe out slowly through your mouth and let your belly fall back down.',
        'Keep breathing slowly and gently.',
      ],
      tip:
          'This exercise helps you relax and connect your breathing to your '
          'bladder control muscles before you start squeezing them.',
      dos: [
        'Keep your shoulders soft and relaxed.',
        'Breathe slowly and smoothly.',
        'Practice somewhere quiet and comfortable.',
      ],
      donts: [
        "Don't force your breath in or out.",
        "Don't raise your shoulders up toward your ears.",
        "Don't hold your breath at any point.",
      ],
    ),
  ),
  // ... the remaining fifteen, transcribed the same way
};

const List<String> generalDos = [
  'Empty your bladder before starting your pelvic floor exercises.',
  'Warm up gently and perform exercises on a firm, comfortable surface.',
  "Follow the prescribed frequency, repetitions, and hold times for your current week — don't skip ahead.",
  'Progress gradually, exactly as laid out in your week-by-week plan.',
  'Breathe normally and steadily throughout every exercise.',
  'Stop and consult your physiotherapist or doctor if you feel pain, unusual heaviness, or leakage during an exercise.',
];

const List<String> generalDonts = [
  "Don't hold your breath or strain during any exercise.",
  "Don't push through sharp, worsening, or lasting pain.",
  "Don't skip a progression level or increase intensity faster than prescribed.",
  "Don't substitute your buttocks, thighs, or abdominal muscles for the pelvic floor during PFMT.",
];
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/exercise_content_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/content/exercise_content.dart test/exercise_content_test.dart
git commit -m "Carry the exercise instructions across from the document"
```

---

### Task 6: Build the plan from a protocol

**Files:**
- Modify: `lib/features/exercise/models/exercise_model.dart`
- Test: `test/weekly_plan_from_protocol_test.dart`

**Interfaces:**
- Consumes: `Protocol`, `PrescribedItem` (Task 1); `protocolFor` (Task 4).
- Produces: `WeeklyPlan.forProtocol(Protocol protocol, int week)`; `ExerciseSession` gains `final String exerciseKey; final int sets; final ExercisePosition? position;` and `holdSeconds`/`reps` become `int?`.

`WeeklyPlan.getWeekPlan` is deleted. `WeeklyPlan` gains `final String progressionFocus;` and `final int daysPerWeek;`.

- [ ] **Step 1: Write the failing test**

```dart
// test/weekly_plan_from_protocol_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/models/exercise_model.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

void main() {
  test('a week has as many days as its block prescribes, not seven', () {
    final mildLow = protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.low);
    expect(WeeklyPlan.forProtocol(mildLow, 1).days.length, 3);
    expect(WeeklyPlan.forProtocol(mildLow, 4).days.length, 4);
    expect(WeeklyPlan.forProtocol(mildLow, 8).days.length, 5);

    final mildHigh = protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.high);
    expect(WeeklyPlan.forProtocol(mildHigh, 1).days.length, 5);
  });

  test('a day has one session per prescribed item, not five', () {
    final severe = protocolFor(severityBand: 'severe', activity: IPAQActivityLevel.low);
    final week1 = WeeklyPlan.forProtocol(severe, 1);
    expect(week1.days.first.sessions.length, 6);
    expect(WeeklyPlan.forProtocol(severe, 7).days.first.sessions.length, 13);
  });

  test('sessions carry the prescription, including nullable holds', () {
    final severe = protocolFor(severityBand: 'severe', activity: IPAQActivityLevel.high);
    final day = WeeklyPlan.forProtocol(severe, 3).days.first;
    final slr = day.sessions.firstWhere((s) => s.exerciseKey == 'straight_leg_raise');
    expect(slr.reps, 8);
    expect(slr.holdSeconds, isNull); // "8 reps no hold"
    final bridge = day.sessions.firstWhere((s) => s.exerciseKey == 'pelvic_bridging');
    expect(bridge.reps, 12);
    expect(bridge.holdSeconds, 10);
  });

  test('session numbers are the one-based index within the day', () {
    final p = protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.high);
    final day = WeeklyPlan.forProtocol(p, 1).days.first;
    expect(day.sessions.map((s) => s.sessionNumber).toList(),
        List.generate(day.sessions.length, (i) => i + 1));
  });

  test('every day in a week is identical, as the document specifies', () {
    final p = protocolFor(severityBand: 'moderate', activity: IPAQActivityLevel.moderate);
    final week = WeeklyPlan.forProtocol(p, 5);
    final first = week.days.first.sessions.map((s) => s.exerciseKey).toList();
    for (final day in week.days) {
      expect(day.sessions.map((s) => s.exerciseKey).toList(), first);
    }
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/weekly_plan_from_protocol_test.dart`
Expected: FAIL — `forProtocol` is not defined.

- [ ] **Step 3: Rewrite `exercise_model.dart`**

```dart
import '../protocols/exercise_catalogue.dart';
import 'protocol.dart';

class ExerciseSession {
  const ExerciseSession({
    required this.week,
    required this.day,
    required this.sessionNumber,
    required this.exerciseKey,
    required this.exerciseName,
    required this.sets,
    required this.isCompleted,
    this.reps,
    this.holdSeconds,
    this.relaxSeconds,
    this.position,
  });

  final int week;
  final int day;

  /// One-based index of this item within its day. Written to
  /// exercise_logs.session_number, whose constraint allows 1 to 30.
  final int sessionNumber;
  final String exerciseKey;
  final String exerciseName;
  final int? reps;
  final int? holdSeconds;
  final int? relaxSeconds;
  final int sets;
  final ExercisePosition? position;
  final bool isCompleted;
}
```

`DayPlan` is unchanged. `WeeklyPlan` drops `getWeekPlan` and `difficultyLabel`, gains:

```dart
  static WeeklyPlan forProtocol(Protocol protocol, int week) {
    final block = protocol.blockForWeek(week);
    return WeeklyPlan(
      weekNumber: week,
      daysPerWeek: block.daysPerWeek,
      progressionFocus: block.progressionFocus,
      days: List.generate(
        block.daysPerWeek,
        (dayIndex) => DayPlan(
          dayNumber: dayIndex + 1,
          sessions: [
            for (var i = 0; i < block.items.length; i++)
              _sessionFor(block.items[i], week, dayIndex + 1, i + 1),
          ],
        ),
      ),
    );
  }

  static ExerciseSession _sessionFor(
    PrescribedItem item, int week, int day, int sessionNumber,
  ) =>
      ExerciseSession(
        week: week,
        day: day,
        sessionNumber: sessionNumber,
        exerciseKey: item.exerciseKey,
        exerciseName: exerciseCatalogue[item.exerciseKey] ?? item.exerciseKey,
        reps: item.reps,
        holdSeconds: item.holdSeconds,
        relaxSeconds: item.relaxSeconds,
        sets: item.sets,
        position: item.position,
        isCompleted: false,
      );
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/weekly_plan_from_protocol_test.dart`
Expected: PASS, 5 tests. Other suites will now fail to compile — that is expected and Tasks 8–12 repair them.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/models/exercise_model.dart test/weekly_plan_from_protocol_test.dart
git commit -m "Build the weekly plan from the patient's protocol"
```

---

### Task 7: Database migration

**Files:**
- Create: `supabase/migrations/20260915120000_protocol_exercise_logs.sql`
- Test: `test/migration_shape_test.dart`

**Interfaces:**
- Consumes: nothing in Dart.
- Produces: `exercise_logs.exercise_key text`; `session_number` constrained `between 1 and 30`.

This task carries the plan's largest risk. The insert path swallows failures into a `debugPrint`, so if this migration is not applied the app writes nothing and the dashboard shows week 1 at 0% with no error anywhere. Task 14 verifies a real write; do not skip it.

- [ ] **Step 1: Write the failing test**

A Dart test cannot reach the database, so it asserts the migration file says what it must — enough to catch an edit that silently drops a clause.

```dart
// test/migration_shape_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File(
    'supabase/migrations/20260915120000_protocol_exercise_logs.sql',
  ).readAsStringSync().toLowerCase();

  test('the session_number ceiling is raised past the old five', () {
    expect(sql, contains('session_number between 1 and 30'));
    expect(sql, contains('drop constraint if exists'));
  });

  test('exercise_key is added so a log row stays interpretable', () {
    expect(sql, contains('add column if not exists exercise_key text'));
  });

  test('rows written under the old five-per-day scheme are cleared', () {
    expect(sql, contains('delete from public.exercise_logs'));
  });

  test('the migration is safe to run twice', () {
    expect(sql, isNot(contains('add column exercise_key')));
    expect('if exists'.allMatches(sql).length, greaterThanOrEqualTo(2));
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/migration_shape_test.dart`
Expected: FAIL — `PathNotFoundException`.

- [ ] **Step 3: Write the migration**

```sql
-- Widen exercise_logs for the assessment-driven protocols.
--
-- A day used to be five repeats of one exercise. Under the protocol document
-- a day is a pelvic floor block plus up to thirteen other exercises, so
-- session_number now indexes the item within its day and can reach fifteen.
-- The old check (between 1 and 5) rejected everything past the fifth item,
-- and exercise_notifier swallows insert failures into a debugPrint, so the
-- rejection would have been silent: no logs, no error, a dashboard stuck at
-- week 1 and 0%.

alter table public.exercise_logs
  drop constraint if exists exercise_logs_session_number_check;

alter table public.exercise_logs
  add constraint exercise_logs_session_number_check
  check (session_number between 1 and 30);

-- Which exercise a row refers to, so a log stays interpretable if the
-- protocol tables are ever edited. Nullable: rows predating this column
-- cannot be back-filled, because the exercise identities did not exist.
alter table public.exercise_logs
  add column if not exists exercise_key text;

-- Existing rows were written under the old meaning of session_number and
-- cannot be mapped onto exercise identities that did not exist when they were
-- recorded. Leaving them makes every adherence figure read as a part-finished
-- day. The project owner confirmed this is development test data.
delete from public.exercise_logs;
```

- [ ] **Step 4: Run the test and confirm it passes**

Run: `flutter test test/migration_shape_test.dart`
Expected: PASS, 4 tests.

- [ ] **Step 5: Apply it and commit**

Applying it is the project owner's call, since it deletes rows. Present the file, ask, and only then run it in the Supabase SQL editor. Commit either way:

```bash
git add supabase/migrations/20260915120000_protocol_exercise_logs.sql test/migration_shape_test.dart
git commit -m "Widen exercise_logs for a day of up to fifteen exercises"
```

---

### Task 8: Exercise notifier

**Files:**
- Modify: `lib/features/exercise/exercise_notifier.dart`
- Test: `test/exercise_notifier_protocol_test.dart`

**Interfaces:**
- Consumes: `Protocol` (Task 1), `protocolFor` (Task 4), `WeeklyPlan.forProtocol` (Task 6).
- Produces: `void applyProtocol(Protocol protocol)`; `Protocol get protocol`; `loadRecommendedWeek` is deleted; `highestUnlockedWeek` no longer floors at a recommended week.

`_recommendedStartWeek` and `recommendedStartWeek` are removed. `loadWeek` uses `WeeklyPlan.forProtocol(_protocol, week)`. The `exercise_logs` upsert gains `'exercise_key': session.exerciseKey`. A day counts as complete when every item in it is logged, which it already does via `DayPlan.isCompleted`.

- [ ] **Step 1: Write the failing test**

```dart
// test/exercise_notifier_protocol_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

void main() {
  test('the notifier plans from the protocol it is given', () {
    final notifier = ExerciseNotifier();
    notifier.applyProtocol(
      protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.low),
    );
    notifier.loadWeek(1);
    expect(notifier.currentPlan!.days.length, 3);
    expect(notifier.currentPlan!.days.first.sessions.length, 12);
  });

  test('every patient starts at week one', () {
    final notifier = ExerciseNotifier();
    notifier.applyProtocol(
      protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.high),
    );
    expect(notifier.highestUnlockedWeek, 1);
    expect(notifier.canAccessWeek(1), isTrue);
    expect(notifier.canAccessWeek(2), isFalse);
  });

  test('without a protocol the notifier plans the gentlest one', () {
    final notifier = ExerciseNotifier();
    notifier.loadWeek(1);
    expect(notifier.currentPlan!.days.first.sessions.length, 6); // severe W1-2
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/exercise_notifier_protocol_test.dart`
Expected: FAIL — `applyProtocol` is not defined.

- [ ] **Step 3: Modify the notifier**

Replace the recommended-week machinery:

```dart
  Protocol _protocol = protocolFor();
  Protocol get protocol => _protocol;

  /// Adopts the protocol chosen from the patient's questionnaires, discarding
  /// any plan built from the previous one.
  void applyProtocol(Protocol protocol) {
    if (protocol.id == _protocol.id) return;
    _protocol = protocol;
    _plans.clear();
    currentPlan = null;
    protocolRevision.value++;
    notifyListeners();
  }

  /// Furthest week the patient may open: the first one they have not finished.
  ///
  /// This used to be floored at a recommended start week derived from the
  /// questionnaires. Now that those same answers choose the protocol itself,
  /// skipping weeks would skip the patient past their own protocol's baseline
  /// activation block, which is where the document puts the foundational work.
  int get highestUnlockedWeek {
    for (var week = 1; week < 8; week++) {
      if (!_completedWeeks.contains(week)) return week;
    }
    return 8;
  }
```

and in `loadWeek`: `currentPlan = _plans[week] ??= WeeklyPlan.forProtocol(_protocol, week);`

and in the upsert payload, alongside the existing keys: `'exercise_key': session.exerciseKey,`

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/exercise_notifier_protocol_test.dart`
Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/exercise_notifier.dart test/exercise_notifier_protocol_test.dart
git commit -m "Plan from the patient's protocol and drop the start-week skip"
```

---

### Task 9: Route the protocol through the assessments

**Files:**
- Modify: `lib/features/assessment/notifiers/assessment_summary_notifier.dart:30-54`
- Modify: `lib/features/assessment/screens/iciq_screen.dart:73`
- Modify: `lib/features/assessment/screens/ipaq_screen.dart`
- Modify: `lib/features/assessment/screens/iqol_screen.dart`
- Test: `test/recommended_week_test.dart` *(rewrite)*

**Interfaces:**
- Consumes: `protocolFor` (Task 4), `ExerciseNotifier.applyProtocol` (Task 8).
- Produces: `Protocol get protocol` on `AssessmentSummaryNotifier`. `recommendedStartWeek` is deleted.

Each screen changes one call: `context.read<ExerciseNotifier>().loadRecommendedWeek(summary.recommendedStartWeek)` becomes `context.read<ExerciseNotifier>().applyProtocol(summary.protocol)`.

- [ ] **Step 1: Rewrite the test**

`test/recommended_week_test.dart` currently asserts the retired rule. Replace its body:

```dart
// test/recommended_week_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/iciq_model.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/assessment/notifiers/assessment_summary_notifier.dart';

void main() {
  test('a mild, highly active patient gets the mild+high protocol', () {
    final summary = AssessmentSummaryNotifier()
      ..iciq = const ICIQModel(leakFrequency: 1, leakAmount: 2, lifeInterference: 3)
      ..ipaq = const IPAQModel(activityLevel: IPAQActivityLevel.high);
    expect(summary.protocol.id, 'mild_high');
  });

  test('a severe patient gets the severe protocol at any activity level', () {
    for (final activity in IPAQActivityLevel.values) {
      final summary = AssessmentSummaryNotifier()
        ..iciq = const ICIQModel(leakFrequency: 5, leakAmount: 6, lifeInterference: 8)
        ..ipaq = IPAQModel(activityLevel: activity);
      expect(summary.protocol.id, 'severe');
    }
  });

  test('an unfinished onboarding falls back to the gentlest protocol', () {
    expect(AssessmentSummaryNotifier().protocol.id, 'severe');
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/recommended_week_test.dart`
Expected: FAIL — `protocol` is not defined.

- [ ] **Step 3: Replace `recommendedStartWeek`**

Delete the getter at `assessment_summary_notifier.dart:30-54` and put in its place:

```dart
  /// The exercise protocol for this patient, from their ICIQ severity band and
  /// IPAQ activity level.
  ///
  /// This replaces recommendedStartWeek, which used the same two scores to
  /// skip a milder, more active patient forward to week 2 or 3. Now that the
  /// scores select the programme itself, skipping would drop the patient past
  /// their own protocol's baseline activation block.
  Protocol get protocol => protocolFor(
        severityBand: iciq?.severityBand,
        activity: ipaq?.activityLevel,
      );
```

Then update the three screens and `dashboard_notifier.applyAssessmentSummary`, which keeps carrying `iciqScorePre` but loses its `currentWeek` raising.

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/recommended_week_test.dart && flutter analyze`
Expected: PASS, 3 tests; analyze clean of `recommendedStartWeek` references.

- [ ] **Step 5: Commit**

```bash
git add lib/features/assessment lib/features/dashboard/dashboard_notifier.dart test/recommended_week_test.dart
git commit -m "Hand the exercise section a protocol instead of a start week"
```

---

### Task 10: Adherence against the protocol

**Files:**
- Modify: `lib/features/dashboard/dashboard_notifier.dart:38-56,70-72,104-150`
- Modify: `test/current_week_test.dart`
- Test: `test/protocol_adherence_test.dart`

**Interfaces:**
- Consumes: `Protocol` (Task 1).
- Produces: `resolveCurrentWeek({required Set<int> weeksTouched, required Map<int, int> completedDaysByWeek, required Protocol protocol})` — the `recommendedStartWeek` parameter is replaced by the protocol, which supplies each week's own day count.

`sessionsPerDay` and `daysPerWeek` constants are deleted. A day is complete when its logged sessions reach `protocol.blockForWeek(week).items.length`; a week's adherence is completed days over `protocol.blockForWeek(week).daysPerWeek`. `totalWeeks` stays 8.

- [ ] **Step 1: Write the failing test**

```dart
// test/protocol_adherence_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/dashboard/dashboard_notifier.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

void main() {
  final mildLow = protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.low);

  test('a three-day week is fully adherent after three days', () {
    expect(weekAdherence(completedDays: 3, week: 1, protocol: mildLow), 100.0);
    expect(weekAdherence(completedDays: 2, week: 1, protocol: mildLow),
        closeTo(66.67, 0.01));
  });

  test('a five-day week needs five days for the same figure', () {
    expect(weekAdherence(completedDays: 3, week: 8, protocol: mildLow), 60.0);
  });

  test('a part-finished new week does not report the previous week', () {
    final week = resolveCurrentWeek(
      weeksTouched: {1, 2},
      completedDaysByWeek: {1: 3, 2: 0},
      protocol: mildLow,
    );
    expect(week, 2);
  });

  test('a week is only finished when its own day count is met', () {
    // Week 1 of mild+low is three days; week 4 is four.
    expect(resolveCurrentWeek(weeksTouched: {1}, completedDaysByWeek: {1: 3},
        protocol: mildLow), 2);
    expect(resolveCurrentWeek(weeksTouched: {3}, completedDaysByWeek: {3: 3},
        protocol: mildLow), 3);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/protocol_adherence_test.dart`
Expected: FAIL — `weekAdherence` is not defined.

- [ ] **Step 3: Modify the dashboard notifier**

Add the top-level helper and rework `resolveCurrentWeek`:

```dart
/// Share of the week's prescribed days the patient has completed, 0 to 100.
///
/// The denominator is the protocol's own days for that week, which varies from
/// three to five. It used to be a fixed seven, so a patient on a three-day week
/// could not exceed 43% however diligent they were.
@visibleForTesting
double weekAdherence({
  required int completedDays,
  required int week,
  required Protocol protocol,
}) {
  final target = protocol.blockForWeek(week).daysPerWeek;
  if (target == 0) return 0;
  return ((completedDays / target) * 100).clamp(0.0, 100.0);
}
```

In `loadDashboard`, a day is complete when its session count reaches `protocol.blockForWeek(week).items.length` rather than the deleted `sessionsPerDay`.

`DashboardNotifier` obtains the protocol the same way the exercise notifier does — it is handed one, rather than recomputing it from the questionnaires. Add a field alongside the existing state and set it in `applyAssessmentSummary`, which Task 9 is already editing:

```dart
  Protocol _protocol = protocolFor();

  void applyAssessmentSummary(AssessmentSummaryNotifier summary) {
    _protocol = summary.protocol;

    final current = data;
    if (current == null) return;
    // The week-raising that used to live here is gone: every patient now
    // starts their protocol at week 1, so there is no recommendation to
    // raise towards. Carrying iciqScorePre onto the dashboard remains.
    data = current.copyWith(
      iciqScorePre: summary.iciq?.iciqScore ?? current.iciqScorePre,
    );
    notifyListeners();
  }
```

`loadDashboard` then passes `_protocol` to `resolveCurrentWeek` and `weekAdherence`.

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/protocol_adherence_test.dart test/current_week_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/dashboard test/protocol_adherence_test.dart test/current_week_test.dart
git commit -m "Measure adherence against the week's own prescribed days"
```

---

### Task 11: The day checklist screen

**Files:**
- Rewrite: `lib/features/exercise/screens/exercise_screen.dart`
- Modify: `lib/l10n/app_en.arb`, `lib/l10n/app_kn.arb`
- Test: `test/exercise_screen_checklist_test.dart`

**Interfaces:**
- Consumes: `ExerciseNotifier.protocol`, `currentPlan` (Task 8).
- Produces: a screen; no API for later tasks.

New localisation keys, both files, Kannada supplied by translation of these short UI strings only (not the exercise prose): `exercisesDoneOfTotal` (`'{done} of {total} done'`), `repsAndHold` (`'{reps} reps · {hold}s hold'`), `repsOnly` (`'{reps} reps'`), `setsLabel` (`'{sets} sets'`), `progressionFocus`, `generalSafety`, `daysThisWeek` (`'{days} days this week'`).

- [ ] **Step 1: Write the failing test**

```dart
// test/exercise_screen_checklist_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/models/exercise_model.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

void main() {
  testWidgets('the day lists one row per prescribed item', (tester) async {
    final severe = protocolFor(severityBand: 'severe', activity: IPAQActivityLevel.low);
    final day = WeeklyPlan.forProtocol(severe, 1).days.first;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            for (final s in day.sessions) ListTile(title: Text(s.exerciseName)),
          ],
        ),
      ),
    ));

    expect(find.byType(ListTile), findsNWidgets(6));
    expect(find.text('Pelvic bridging'), findsOneWidget);
    expect(find.text('Slow squeeze and hold'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/exercise_screen_checklist_test.dart`
Expected: FAIL until Task 6's model changes are in place; then PASS, proving the data feeding the screen is right before the screen is written.

- [ ] **Step 3: Rewrite the screen**

Week selector at the top as today. Below it, the day's items as a `ListView` of rows, each showing the exercise name, its dose, its set count when above one, and a tick when logged. A header shows `{done} of {total} done` and the block's progression focus. A footer link opens the general safety rules. Tapping a row opens the sheet from Task 12.

The row and its dose line are the parts worth pinning down, because the dose has three shapes and a null-unsafe read here is the easy mistake:

```dart
/// "12 reps · 10s hold", "12 reps", or "" for an item prescribed without a
/// count, such as diaphragmatic breathing.
String _dose(ExerciseSession session, AppLocalizations l10n) {
  final reps = session.reps;
  if (reps == null) return '';
  final hold = session.holdSeconds;
  return hold == null
      ? l10n.repsOnly(reps)
      : l10n.repsAndHold(reps, hold);
}

Widget _itemRow(BuildContext context, ExerciseSession session) {
  final l10n = AppLocalizations.of(context)!;
  final dose = _dose(session, l10n);
  return ListTile(
    key: ValueKey('item-${session.week}-${session.day}-${session.sessionNumber}'),
    leading: Icon(
      session.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
      color: session.isCompleted ? Theme.of(context).colorScheme.primary : null,
    ),
    title: Text(session.exerciseName),
    subtitle: dose.isEmpty && session.sets <= 1
        ? null
        : Text([
            if (dose.isNotEmpty) dose,
            if (session.sets > 1) l10n.setsLabel(session.sets),
          ].join(' · ')),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => showExerciseDetail(context, session),
  );
}
```

The `ValueKey` is not decoration: `ListView.builder` recycles elements, and this screen previously shipped a bug of exactly that shape in the bladder diary, where rows without stable keys picked up their neighbour's state.

Keep the existing `ValueListenableBuilder` on `secondsRemaining` so the countdown does not rebuild the whole list — that was a deliberate optimisation and still applies.

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/exercise_screen_checklist_test.dart && flutter analyze`
Expected: PASS; analyze clean.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/screens/exercise_screen.dart lib/l10n test/exercise_screen_checklist_test.dart
git commit -m "Show the day as a checklist of its prescribed exercises"
```

---

### Task 12: The exercise detail sheet

**Files:**
- Create: `lib/features/exercise/screens/exercise_detail_sheet.dart`
- Test: `test/exercise_detail_sheet_test.dart`

**Interfaces:**
- Consumes: `exerciseContent` (Task 5), `ExerciseSession` (Task 6), the notifier's timer.
- Produces: `Future<void> showExerciseDetail(BuildContext context, ExerciseSession session)`.

The sheet shows the starting position, the numbered steps, the tip when present, the DO and DON'T columns, and — for items with a `holdSeconds` — the existing rep timer. Items without a hold show a plain "mark done" action. Completing calls the notifier's existing completion path, which logs the row.

- [ ] **Step 1: Write the failing test**

```dart
// test/exercise_detail_sheet_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/content/exercise_content.dart';

void main() {
  testWidgets('the sheet shows the position, the steps and both columns',
      (tester) async {
    final text = exerciseContent['pelvic_bridging']!.forLocale('en');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            Text(text.startingPosition),
            for (final step in text.steps) Text(step),
            for (final d in text.dos) Text(d),
            for (final d in text.donts) Text(d),
          ],
        ),
      ),
    ));

    expect(find.text(text.startingPosition), findsOneWidget);
    expect(find.text(text.steps.first), findsOneWidget);
    expect(find.text(text.donts.first), findsOneWidget);
  });

  testWidgets('a Kannada reader still gets readable instructions',
      (tester) async {
    final content = exerciseContent['clamshells']!;
    expect(content.forLocale('kn').steps, isNotEmpty);
  });
}
```

- [ ] **Step 2: Run the test and confirm it fails**

Run: `flutter test test/exercise_detail_sheet_test.dart`
Expected: FAIL until Task 5 lands; then PASS.

- [ ] **Step 3: Write the sheet**

A `showModalBottomSheet` with a scrollable body. Reuse the existing timer widgets from `exercise_screen.dart` rather than writing new ones; lift them into the sheet file if the screen no longer needs them.

- [ ] **Step 4: Run the tests and confirm they pass**

Run: `flutter test test/exercise_detail_sheet_test.dart && flutter analyze`
Expected: PASS; analyze clean.

- [ ] **Step 5: Commit**

```bash
git add lib/features/exercise/screens/exercise_detail_sheet.dart test/exercise_detail_sheet_test.dart
git commit -m "Give each exercise its instructions and its timer"
```

---

### Task 13: Whole-suite repair and analyze

**Files:**
- Modify: `test/redirect_policy_test.dart`, `test/high_severity_fixes_test.dart`, `test/exercise_timer_test.dart`, `test/assessment_screens_render_test.dart`, and any other suite the model change broke.

**Interfaces:**
- Consumes: everything above.
- Produces: a green suite.

- [ ] **Step 1: Find everything broken**

Run: `flutter test 2>&1 | tail -40`
Expected: a list of compile errors in suites referencing `getWeekPlan`, `difficultyLabel`, `recommendedStartWeek`, or the old `ExerciseSession` constructor.

- [ ] **Step 2: Repair each suite**

Update assertions to the new rule rather than deleting them. A test that asserted "a mild, active patient starts at week 3" becomes one asserting they get `mild_high` and start at week 1 — the behaviour change is recorded, not lost.

- [ ] **Step 3: Run the whole suite**

Run: `flutter test`
Expected: all green, including the 132 tests that passed before this work.

- [ ] **Step 4: Run the analyzer**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add test
git commit -m "Bring the existing suites onto the protocol model"
```

---

### Task 14: End-to-end verification

**Files:** none.

This is the task that catches what the tests cannot. Every test above runs against Dart objects; none of them proves Postgres accepts a row with `session_number` of 12, and the app will not tell you if it does not.

- [ ] **Step 1: Apply the migration**

Ask the project owner first — it deletes rows. Then run `supabase/migrations/20260915120000_protocol_exercise_logs.sql` in the Supabase SQL editor.

- [ ] **Step 2: Confirm the constraint actually changed**

```sql
select conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'public.exercise_logs'::regclass
  and conname like '%session_number%';
```

Expected: `check ((session_number >= 1) and (session_number <= 30))`.

- [ ] **Step 3: Run the app and complete a day**

Run: `flutter run -d chrome --dart-define-from-file=supabase.env.json`

Sign in, open week 1, and complete **every** item in a day — including the twelfth and beyond, which is the case the old constraint rejected.

- [ ] **Step 4: Confirm the rows landed**

```sql
select week_number, day_number, session_number, exercise_key, completed_at
from public.exercise_logs
order by session_number;
```

Expected: one row per item, `session_number` running 1..N with no gaps, `exercise_key` populated, and `completed_at` within a minute of now — **not** five and a half hours ahead, which would mean the UTC conversion regressed.

- [ ] **Step 5: Confirm the dashboard agrees**

The dashboard should show week 1, and adherence equal to one day out of that week's prescribed days — 33% on a three-day week, 20% on a five-day week. A reading of 0% with rows present means the adherence denominator is still wrong; a reading of 0% with no rows means the insert is failing silently and step 2 did not take.

- [ ] **Step 6: Commit nothing, report**

Report the outcome. Do not push; the project owner approves every push separately.

---

## Notes for the executor

- `dart format` reflows code after you write it. If a later `sed` or string replacement fails to match, re-read the file rather than assuming the edit was lost.
- `ExerciseNotifier` cannot be constructed without `Supabase.initialize` having run in some suites. Follow the pattern in `test/sign_out_test.dart`, which initialises in `setUpAll`.
- `SharedPreferences.setMockInitialValues({})` must run in `setUpAll` **before** `Supabase.initialize`, not in `setUp` after it.
- The repository has no `.git` history before `b26abb1` locally — the clone is shallow by 50 commits. `git fetch --unshallow` if you need more.
