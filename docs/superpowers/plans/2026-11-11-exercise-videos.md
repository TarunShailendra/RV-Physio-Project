# Exercise Demonstration Videos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every exercise an animated demonstration in the style of the owner's pelvic bridge video, which the app plays in step with its own timer for held exercises and loops as a demonstration for the rest.

**Architecture:** A committed Python generator under `tool/exercise_videos/` (grown from the owner's `bridge.py`) renders 20 single-rep, text-free H.264 videos into `assets/videos/` and writes their segment timings as a generated Dart file. The exercise timer gains short movement phases whose lengths come from those timings. A video widget at the top of the exercise detail sheet maps the timer's phase to a playback command through a pure function, behind a player seam that tests replace.

**Tech Stack:** Python 3.10 with Pillow 12, NumPy and `imageio-ffmpeg` (bundled ffmpeg binary); Flutter 3.41.7, Provider, `video_player`, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-11-11-exercise-videos-design.md`

## Global Constraints

- **No text in any video frame.** Title, rep counter, phase label, captions and hold bar from `bridge.py` are all removed.
- **Style is `bridge.py`'s:** 1280×720, 30 fps, 2× supersampling with LANCZOS downscale, its colour constants, room, figure proportions, cosine `ease`, orange `GLOW` sprite on the working muscle, green dashed alignment guide where the instructions name a line.
- **Every animation depicts exactly what `lib/features/exercise/content/exercise_content.dart` says.** Where they disagree, the text wins.
- **Encoding:** H.264, `yuv420p`, `-movflags +faststart`, `-crf 20`, via `imageio_ffmpeg.get_ffmpeg_exe()` — there is no ffmpeg on PATH.
- **The duration logged to `exercise_logs` is unchanged:** reps × (hold + relax) × sets.
- **A video that fails to load collapses to nothing**; the sheet is otherwise exactly as before.
- **Owner's files in `../Videos/` are never modified.** `bridge.py` is copied into the repo unchanged as a reference.
- Work on a new branch `exercise-videos` off `exercise-protocols`. `flutter analyze` clean and `flutter test` green before every commit. **Commit locally; never push** — the owner approves pushes separately.
- Python scripts in `tool/` are run as `python tool/exercise_videos/render.py ...` from the repo root (not `-I`: the script imports its sibling modules).

## Review Focus

1. **Pausing during a movement phase** — the patient taps Pause while the figure is still moving into the hold. Expected: the clock and video both stop; Start replays the movement from its beginning, and the hold still gets its full prescribed seconds. Test added to Task 3.
2. **Closing the sheet mid-hold** — the patient swipes the sheet away while the timer runs. Expected: no exception from a disposed video controller; the timer carries on as it does today. Test added to Task 4.
3. **A session with no video entry** (a future protocol adds an exercise) — expected: movement phases take zero time so the timer behaves exactly as before, and the sheet shows no video. Tests added to Tasks 3 and 4.
4. **Alternating exercises on an odd rep count** (e.g. pelvic rotations, 5 reps) — expected: sides go A, B, A, B, A; the side resets to A at the start of each set. Test added to Task 3.
5. **Kannada locale** — expected: the two new labels appear in Kannada, and the videos carry no English. Covered by the ARB parity in Task 4 and the no-text rule checked in Task 9.

---

### Task 1: Generator foundation and the re-rendered bridge

**Files:**
- Create: `tool/exercise_videos/reference/bridge.py` (verbatim copy of `../Videos/bridge.py`)
- Create: `tool/exercise_videos/studio.py`
- Create: `tool/exercise_videos/spec.py`
- Create: `tool/exercise_videos/exercises/__init__.py`
- Create: `tool/exercise_videos/exercises/pelvic_bridging.py`
- Create: `tool/exercise_videos/render.py`
- Create: `tool/exercise_videos/check_bridge.py`
- Generated: `assets/videos/pelvic_bridging.mp4`, `lib/features/exercise/videos/exercise_videos.g.dart`

**Interfaces:**
- Produces (Python):
  - `studio.py`: `W, H, S, FPS`; the colour constants from `bridge.py`; `sc, circle, poly, unit, capsule, ease`; `make_room(props: frozenset[str] = frozenset()) -> Image` where props may contain `"wall"` (a wall panel to stand against, right of the mat) and `"chair"` (a side-on chair to hold); `paste_sprite(img, sprite, center, k)`; `GLOW`, `SHADOW`; `dashed_line(draw, points, alpha)`; `encode(frames: Iterable[Image.Image], path: Path) -> int` (returns frames written).
  - `spec.py`: `@dataclass(frozen=True) class SideTiming: into_start: float; hold: float; out_start: float; out_end: float` (seconds); `@dataclass(frozen=True) class VideoSpec: id: str; exercise_key: str; position: str | None; duration: float; sides: tuple[SideTiming, ...]; props: frozenset[str]; frame: Callable[[float, Image.Image], Image.Image]` — `frame(t, room)` draws the figure at time `t` on a copy of `room` and returns the full-resolution RGB frame.
  - Each `exercises/<key>.py` exposes `VIDEOS: list[VideoSpec]`; `exercises/__init__.py` exposes `ALL_VIDEOS: list[VideoSpec]` collecting them.
  - `render.py` CLI: `python tool/exercise_videos/render.py [ID ...] [--preview]`. Always rewrites the Dart file from `ALL_VIDEOS`; renders the named ids (all if none) to `assets/videos/<id>.mp4`; with `--preview`, renders only key-frame strips to `build/exercise_videos/<id>.png` (8 frames evenly spaced). After encoding a video it asserts frame count == `round(duration * FPS)` and that the first and last frames differ by mean absolute pixel difference < 2.0 (the loop is seamless).
- Produces (Dart, generated): see Task 2's types; the file lists every `VideoSpec` as `ExerciseVideo(id:, exerciseKey:, position:, asset: 'assets/videos/<id>.mp4', durationMs:, sides: [VideoSide(intoStartMs:, holdMs:, outStartMs:, outEndMs:)])` in a `const Map<String, ExerciseVideo> exerciseVideos` keyed by id. Header: `// GENERATED FILE - DO NOT EDIT BY HAND.` naming `tool/exercise_videos/render.py`.

Timing for the bridge, one rep: rest 0.4 s → lift 1.3 s (`bridge.py`'s `UP`) → hold plateau 0.8 s → lower 1.5 s (`DOWN`) → rest 0.4 s; duration 4.4 s; `SideTiming(0.4, 1.7, 2.5, 4.0)`.

- [ ] **Step 1: Branch and install the encoder**

Run: `git checkout -b exercise-videos exercise-protocols` then `python -m pip install imageio-ffmpeg`, then `python -c "import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())"`
Expected: a path to an `ffmpeg` executable.

- [ ] **Step 2: Write the fidelity check `check_bridge.py`**

It renders the new bridge at hip elevations `e ∈ {0, 0.5, 1}` and compares each against the frame of `../Videos/pelvic_bridge_side_view.mp4` with the same `e` (frames 0, ~45 and ~90 per `bridge.py`'s timeline: t = 0.3 s, ≈ 1.45 s, 2.6 s), **masking out the overlay regions** (`(28,26)-(430,108)`, `(1032,26)-(1252,108)`, `y ≥ 636`, and for `e = 1` the alignment guide's bounding box). Exit non-zero unless every masked mean absolute difference is < 3.0.

- [ ] **Step 3: Run it to confirm it fails**

Run: `python tool/exercise_videos/check_bridge.py`
Expected: FAIL — `exercises.pelvic_bridging` does not exist.

- [ ] **Step 4: Implement `studio.py`, `spec.py`, `exercises/pelvic_bridging.py`, `render.py`**

Lift the room, sprites, primitives and figure drawing out of `bridge.py` into `studio.py` and `pelvic_bridging.py` without changing a coordinate or colour. Delete `overlay()`'s text, panels and hold bar; keep the alignment guide and glow. Replace the 3-rep `state()` with the one-rep timing above. Font loading is no longer needed.

- [ ] **Step 5: Render and check**

Run: `python tool/exercise_videos/render.py pelvic_bridging` then `python tool/exercise_videos/check_bridge.py`
Expected: `frames 132` from the renderer and PASS from the check. Open `build/exercise_videos/pelvic_bridging.png` (run with `--preview`) and confirm by eye: no text anywhere.

- [ ] **Step 6: Commit**

```bash
git add tool/exercise_videos assets/videos/pelvic_bridging.mp4
git commit -m "Re-render the pelvic bridge as one text-free rep from a shared generator"
```
Leave the generated `exercise_videos.g.dart` uncommitted: it needs Task 2's types to compile, and Task 2 commits it.

---

### Task 2: Video catalogue in the app

**Files:**
- Create: `lib/features/exercise/videos/exercise_video.dart`
- Modify: `pubspec.yaml` (add `video_player: ^2.9.0` under dependencies; add `assets: - assets/videos/` under `flutter:`)
- Test: `test/exercise_videos_test.dart`

**Interfaces:**
- Consumes: the generated `exercise_videos.g.dart` from Task 1.
- Produces:
  - `class VideoSide { const VideoSide({required int intoStartMs, required int holdMs, required int outStartMs, required int outEndMs}); Duration get intoDuration; Duration get outDuration; }`
  - `class ExerciseVideo { const ExerciseVideo({required String id, required String exerciseKey, required ExercisePosition? position, required String asset, required int durationMs, required List<VideoSide> sides}); bool get alternates => sides.length == 2; VideoSide sideForRep(int rep); }` — `sideForRep(1)` is `sides[0]`, `sideForRep(2)` is `sides[1]` when alternating, always `sides[0]` otherwise.
  - `ExerciseVideo? videoFor(String exerciseKey, ExercisePosition? position)` — matches on key and position; a PFMT key with a null position resolves to the supine video; unknown keys return null.

- [ ] **Step 1: Write the failing tests**

```dart
test('every video has its asset on disk and listed in pubspec', ...);
  // File(video.asset).existsSync() for every exerciseVideos value;
  // pubspec.yaml contains 'assets/videos/'.
test('segments are ordered and inside the video', ...);
  // for every side: 0 <= intoStartMs < holdMs <= outStartMs < outEndMs <= durationMs;
  // second side starts at or after the first side's outEndMs.
test('the bridge resolves to its video', ...);
  // videoFor('pelvic_bridging', null)!.id == 'pelvic_bridging'
  // sides.single: intoStartMs 400, holdMs 1700, outStartMs 2500, outEndMs 4000; durationMs 4400
test('an unknown exercise has no video', ...);
  // videoFor('no_such_exercise', null) is null
test('alternating videos pick a side by rep', ...);
  // build a const ExerciseVideo with two sides: sideForRep(1)==sides[0],
  // sideForRep(2)==sides[1], sideForRep(5)==sides[0]
```

- [ ] **Step 2: Run to confirm failure**

Run: `flutter test test/exercise_videos_test.dart`
Expected: FAIL — `exercise_video.dart` not found.

- [ ] **Step 3: Implement the types and `videoFor`; add the pubspec entries; `flutter pub get`**

- [ ] **Step 4: Run tests, then the whole suite and the analyzer**

Run: `flutter test` and `flutter analyze`
Expected: all green; `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/exercise/videos test/exercise_videos_test.dart
git commit -m "List the demonstration videos and their segments in the app"
```

---

### Task 3: Movement phases in the timer

**Files:**
- Modify: `lib/features/exercise/exercise_notifier.dart`
- Modify: `test/exercise_timer_test.dart`, `test/exercise_notifier_protocol_test.dart` (only where they assume the hold starts on Start)
- Test: `test/exercise_movement_phase_test.dart`

**Interfaces:**
- Consumes: `videoFor`, `ExerciseVideo.sideForRep`, `VideoSide.intoDuration/outDuration` (Task 2).
- Produces:
  - `enum ExercisePhase { ready, moveIn, hold, moveOut, rest, betweenReps, finished }`
  - `ExerciseNotifier({ExerciseVideo? Function(String exerciseKey, ExercisePosition? position) videoLookup = videoFor})` — the seam that lets tests stand in a session with no video.
  - `ExerciseVideo? get currentVideo` — `videoLookup(currentSession.exerciseKey, currentSession.position)`.
  - `int get currentSideIndex` — index into `currentVideo.sides` for `currentRep` (0 when not alternating or no video).
  - `void selectSession(int sessionIndex)` — makes that item the current session and resets the timer to `ready`; ignores an out-of-range index.

**Existing defect fixed here:** the detail sheet never told the notifier which item it was showing, so the sheet's timer always ran `currentSession` — the day's first unfinished item — whatever the patient had opened. Open the bridge with the slow squeeze still unticked and the timer counted the squeeze's 4 s hold. Synced video makes that visibly wrong, so Task 4's sheet calls `selectSession(sessionIndex)` when it opens.

Sequence per rep: `moveIn` (into duration) → `hold` (prescribed seconds, existing 1 s countdown) → `moveOut` (out duration) → `rest` if `relaxSeconds` is set, else `betweenReps` (clock stops, as today) → next rep's `moveIn`. After the last rep's `moveOut`, the existing end-of-set logic runs (`betweenReps` for another set, else `finished`). Movement phases run on a one-shot `Timer(duration, …)`, not the periodic tick; `secondsRemaining` shows the coming hold's seconds during `moveIn` and 0 during `moveOut`. Pausing during a movement phase cancels it; Start replays that movement from its beginning. A session with no video has zero-length movements and so behaves as today. `currentRep` restarts at 1 on each set, so alternation restarts on side A.

- [ ] **Step 1: Write the failing tests** in `test/exercise_movement_phase_test.dart`. Use a default notifier (severe protocol) with `loadWeek(1)` and `selectSession(3)` — week 1's fourth item is `pelvic_bridging` (10 s hold, no relax), the one video that exists at this point. Read `into`/`out` from `notifier.currentVideo!.sides.first`.

```dart
testWidgets('selecting an item makes it the one the timer runs', ...);
  // loadWeek(1) leaves item 0 (pfmt_slow) current; selectSession(3);
  // currentSession.exerciseKey == 'pelvic_bridging'; phase == ready
testWidgets('selecting an item mid-timer stops the clock', ...);
  // start on item 0, selectSession(3) -> isTimerRunning false, phase ready
testWidgets('Start moves into the hold before the clock counts', ...);
  // startTimer(); phase == moveIn; secondsRemaining == holdSeconds
  // pump(into); phase == hold; secondsRemaining == holdSeconds
testWidgets('the hold is followed by moving out, then waiting', ...);
  // bridge has no relax: after into + hold -> moveOut; after out -> betweenReps, timer stopped
testWidgets('pausing mid-movement replays the movement', ...);
  // start; pump(half of into); pause; phase == moveIn; pump(5 s) nothing changes;
  // start; pump(half of into) -> still moveIn; pump(rest of into) -> hold with full holdSeconds
testWidgets('a session with no video times exactly as before', ...);
  // ExerciseNotifier(videoLookup: (_, _) => null)..loadWeek(1)..selectSession(3);
  // startTimer(); phase == hold immediately, secondsRemaining == 10
```
(The alternation test needs `pelvic_rotations`' video and is written in Task 8.)

- [ ] **Step 2: Run to confirm failure**

Run: `flutter test test/exercise_movement_phase_test.dart`
Expected: FAIL — `ExercisePhase.moveIn` is not defined.

- [ ] **Step 3: Implement the phases in `exercise_notifier.dart`**

- [ ] **Step 4: Update the existing timer tests to the new rule**

In `exercise_timer_test.dart`, pump through `currentVideo?.sideForRep(rep).intoDuration ?? Duration.zero` (and `outDuration`) where the old tests assumed an instant hold. Do not delete any test. In "ticking does not go through notifyListeners", start counting notifications only once the phase is `hold`.

- [ ] **Step 5: Run the whole suite and analyzer**

Run: `flutter test` and `flutter analyze`
Expected: green; `No issues found!`. The exhaustive switch in `exercise_detail_sheet.dart`'s `_phaseLabel` must handle the two new values: add ARB keys `getIntoPosition` ("Get into position" / "ಸ್ಥಾನಕ್ಕೆ ಬನ್ನಿ") and `returnToStart` ("Return to start" / "ಆರಂಭಕ್ಕೆ ಹಿಂತಿರುಗಿ") to both `.arb` files and map `moveIn`/`moveOut` to them.

- [ ] **Step 6: Commit**

```bash
git add lib test
git commit -m "Start the hold clock once the patient is in position"
```

---

### Task 4: The video in the detail sheet

**Files:**
- Create: `lib/features/exercise/videos/demo_video_player.dart`
- Create: `lib/features/exercise/videos/demo_playback.dart`
- Create: `lib/features/exercise/screens/exercise_demo_video.dart`
- Modify: `lib/features/exercise/screens/exercise_detail_sheet.dart`
- Test: `test/demo_playback_test.dart`, `test/exercise_detail_sheet_video_test.dart`

**Interfaces:**
- Consumes: `ExerciseNotifier.phase`, `.isTimerRunning`, `.currentVideo`, `.currentSideIndex` (Task 3); `ExerciseVideo`, `VideoSide` (Task 2).
- Produces:
  - `demo_playback.dart` (pure Dart): `sealed class DemoCommand`; `LoopWhole()`, `PlaySegment(Duration start, Duration end)` (play then stop at `end`), `ShowFrame(Duration at)` (seek and pause), `Freeze()` (pause where it is). `DemoCommand demoCommandFor({required ExercisePhase phase, required bool isTimerRunning, required bool isHeld, required VideoSide side})`. Mapping: not held → `LoopWhole`; `ready` → `LoopWhole`; not running and phase is `moveIn`/`hold`/`moveOut`/`rest` → `Freeze`; `moveIn` → `PlaySegment(intoStart, hold)`; `hold` → `ShowFrame(hold)`; `moveOut` → `PlaySegment(outStart, outEnd)`; `rest`, `betweenReps`, `finished` → `ShowFrame(intoStart)`.
  - `demo_video_player.dart`: `abstract class DemoVideoPlayer { Future<void> load(String asset); Future<void> play(); Future<void> pause(); Future<void> seekTo(Duration at); Future<void> setLooping(bool looping); Duration get position; Listenable get changes; bool get isReady; double get aspectRatio; Widget buildView(); Future<void> dispose(); }`; `class VideoPlayerDemo implements DemoVideoPlayer` over `VideoPlayerController.asset` with volume 0; `@visibleForTesting DemoVideoPlayer Function() createDemoVideoPlayer = VideoPlayerDemo.new;`.
  - `ExerciseDemoVideo({required ExerciseSession session})` — StatefulWidget; reads `ExerciseNotifier` via `context.watch`; plays `notifier.currentVideo` (the sheet has selected this session, so they agree); returns `SizedBox.shrink()` when there is no video or loading fails; applies `demoCommandFor` whenever its inputs change; for `PlaySegment` it listens to `changes` and pauses once `position >= end`.

- [ ] **Step 1: Write the failing tests**

```dart
// test/demo_playback_test.dart — one test per row of the mapping above, e.g.
test('moving in plays the into segment', ...);
  // demoCommandFor(phase: moveIn, isTimerRunning: true, isHeld: true, side: s)
  //   == PlaySegment(Duration(ms: s.intoStartMs), Duration(ms: s.holdMs))
test('an unheld exercise always loops', ...);
test('a paused timer freezes the video', ...);
test('between reps the figure waits on the start pose', ...);

// test/exercise_detail_sheet_video_test.dart, with createDemoVideoPlayer
// overridden by a FakeDemoVideoPlayer recording calls:
testWidgets('the sheet shows the video above the exercise name', ...);
testWidgets('the sheet shows no video when none exists', ...);
testWidgets('a video that fails to load leaves the sheet as before', ...);
  // fake load() throws -> no exception; 'Mark as done' still present
testWidgets('closing the sheet while the timer runs disposes cleanly', ...);
  // start timer, pop the sheet, pump 3 s -> no exception; fake.disposed == true
testWidgets('starting the timer plays into the hold', ...);
  // tap Start -> fake received seekTo(intoStart) and play()
testWidgets('opening an item selects it for the timer', ...);
  // open the sheet for the bridge (index 3) while item 0 is unticked;
  // notifier.currentSession.exerciseKey == 'pelvic_bridging'
```

- [ ] **Step 2: Run to confirm failure**

Run: `flutter test test/demo_playback_test.dart test/exercise_detail_sheet_video_test.dart`
Expected: FAIL — files not found.

- [ ] **Step 3: Implement**

`showExerciseDetail` calls `context.read<ExerciseNotifier>().selectSession(sessionIndex)` before opening the sheet. `ExerciseDemoVideo` sits as the first child of the sheet's `ListView`, wrapped in `ClipRRect(borderRadius: 12)` and `AspectRatio(16 / 9)`, followed by `SizedBox(height: 16)` only when shown. `isHeld` is `session.holdSeconds != null`.

- [ ] **Step 4: Run the suite and analyzer**

Run: `flutter test` and `flutter analyze`
Expected: green; `No issues found!`

- [ ] **Step 5: See it in Chrome**

Run: `flutter run -d chrome --dart-define-from-file=supabase.env.json`
Open the bridge, confirm the preview loops, tap Start and watch one rep: the figure lifts, stays up for the full hold count, lowers, and waits for Next rep.

- [ ] **Step 6: Commit**

```bash
git add lib test
git commit -m "Play each exercise's demonstration in step with its timer"
```

---

### Task 5: A posable side-view figure

**Files:**
- Create: `tool/exercise_videos/figure.py`
- Modify: `tool/exercise_videos/exercises/pelvic_bridging.py` (draw through the rig)

**Interfaces:**
- Produces: `@dataclass class SidePose` holding a root point (pelvis, in 1280×720 coordinates) and angles in degrees for trunk, neck, near/far shoulder, elbow, hip, knee, ankle; `SIDE_SUPINE_KNEES_BENT`, `SIDE_SITTING`, `SIDE_STANDING`, `SIDE_QUADRUPED` reference poses; `lerp_pose(a, b, k) -> SidePose`; `draw_side_figure(img, pose, *, glow_at: str | None = None, glow_k: float = 0, highlight_pelvic_floor: float = 0) -> dict[str, tuple[float, float]]` returning joint positions (for guides). Segment lengths are `bridge.py`'s: torso 190, thigh 170, shin 165; limb radii, torso profile (`UPW`/`DNW`), head, hair, shoes as in `bridge.py`. Planted feet use `bridge.py`'s two-bone IK, exposed as `knee_ik(hip, ankle, *, bend: Literal["up", "down"])`.

- [ ] **Step 1: Re-point the bridge at the rig and re-run its check**

Run: `python tool/exercise_videos/check_bridge.py`
Expected: PASS still — the rig reproduces the original figure.

- [ ] **Step 2: Render the four reference poses**

Add `python tool/exercise_videos/figure.py --poses` writing `build/exercise_videos/poses.png`. Inspect: supine, sitting on a chair, standing, hands-and-knees all read as the same person, with no joint gaps or inverted limbs.

- [ ] **Step 3: Commit**

```bash
git add tool/exercise_videos
git commit -m "Give the video figure a posable side-view rig"
```

---

### Tasks 6–8: The animations

Each exercise is one module in `tool/exercise_videos/exercises/` exposing `VIDEOS`, registered in `ALL_VIDEOS`. For each module, in its task:

1. Write it from its row in the spec's table **and** its text in `exercise_content.dart`.
2. `python tool/exercise_videos/render.py <id> --preview` and inspect the strip against the text — position, what moves, what stays still, where the glow sits.
3. `python tool/exercise_videos/render.py <id>` (the frame-count and seamless-loop asserts must pass).
4. `flutter test test/exercise_videos_test.dart` (assets present, segments ordered).

Timing for every held video: rest 0.4 s, into 1.0–1.5 s, hold plateau 0.8 s, out 1.0–1.5 s, rest 0.4 s, per side. Unheld videos use the same shape with whatever plateau looks natural (≥ 0) so the loop reads as one rep.

Each task ends with `flutter test`, `flutter analyze`, and a commit of its modules, mp4s and the regenerated Dart file.

#### Task 6: Pelvic floor and breathing (7 videos)

`pfmt_slow_supine`, `pfmt_slow_sitting`, `pfmt_slow_standing`, `pfmt_quick_supine`, `pfmt_quick_sitting`, `pfmt_quick_standing`, `diaphragmatic_breathing`.
- PFMT: figure perfectly still in its position (sitting uses the `"chair"` prop); a pelvic-floor glow (soft, smaller than `GLOW`, centred low between the hips) fades in over *into* and out over *out*. Quick: into 0.3 s, plateau 0.2 s, out 0.3 s.
- Breathing: supine knees bent, near hand on chest, far hand on belly; belly profile rises over ~3 s in, falls over ~4 s out; chest outline does not move.
- Add to `test/exercise_videos_test.dart`: `videoFor('pfmt_slow', ExercisePosition.sitting)!.id == 'pfmt_slow_sitting'`, and likewise for all six PFMT ids; `videoFor('pfmt_quick', null)!.id == 'pfmt_quick_supine'`.

#### Task 7: Lying on the back, side view (5 videos)

`pelvic_tilt` (pelvis rolls back a few degrees, lower-back profile flattens to the floor, hips do not lift; glow on lower belly), `straight_leg_raise` (straight leg rises to the bent knee's height and no higher; glow on the thigh; knee never bends), `single_leg_stretch` (two sides: near leg extends low, then far leg), `leg_scissors` (two sides: near leg lowers, returns; far leg lowers, returns; legs stay straight), `leg_circles` (raised near leg's foot traces a small ellipse ~40×16 px; hips still).

#### Task 8: Standing, hands-and-knees, and the other views (7 videos)

- Side view: `wall_squat` (`"wall"` prop; back slides down the wall to roughly 60° knee bend, knees over ankles), `squats` (`"chair"` prop beside; hips back and down, chest up), `lunges` (`"chair"` prop; near foot steps forward, both knees bend, back knee toward floor, return), `quadruped_arm_leg_raise` (two sides: near arm + far leg, then far arm + near leg; green dashed guide along a flat back).
- Front view, side-lying — new rig `tool/exercise_videos/figure_front.py` in the same palette and proportions: `clamshells` (knees bent and stacked, feet together, top knee opens and closes; glow on the hip), `side_leg_raise` (bottom leg slightly bent, straight top leg lifts toward the ceiling, hips stay stacked).
- From the feet, supine — `pelvic_rotations` (two sides: both knees lower together to the viewer's left, return; then right; arms wide, shoulders flat).
- Add `testWidgets('alternating sides go A, B, A and restart each set', ...)` to `test/exercise_movement_phase_test.dart` using a `pelvic_rotations` session: after each rep `currentSideIndex` reads 0, 1, 0; after the set it reads 0.
- Add to `test/exercise_videos_test.dart`: `test('every exercise in the catalogue has a video', ...)` — every `exerciseCatalogue` key has `videoFor(key, null) != null`, and every PFMT key has a video for each `ExercisePosition`; `exerciseVideos.length == 20`.

---

### Task 9: Review and verification

**Files:**
- Create: `tool/exercise_videos/contact_sheet.py`

- [ ] **Step 1: Build the contact sheet**

`python tool/exercise_videos/contact_sheet.py` writes `build/exercise_videos/contact_sheet.png`: one row per video, 6 frames each (start, mid-into, hold, mid-out, end; second side's hold for alternating videos), labelled with the id **outside** the frames.

- [ ] **Step 2: Check every row against the spec table and `exercise_content.dart`, and that no frame contains text.** Fix any module that disagrees and re-render it.

- [ ] **Step 3: Owner review.** Send the owner the contact sheet. Do not continue until they approve; apply their changes through Tasks 6–8's loop.

- [ ] **Step 4: Run the app in Chrome**

Run: `flutter run -d chrome --dart-define-from-file=supabase.env.json`. Follow one rep each of: the bridge, a PFMT slow hold (in the position this week prescribes), `pelvic_rotations` (two reps, confirming the side changes), and watch `clamshells` loop. Switch to Kannada and confirm the two new labels.

- [ ] **Step 5: Full suite, analyzer, size check**

Run: `flutter test`, `flutter analyze`, and `du -ch assets/videos/*.mp4 | tail -1`
Expected: green; `No issues found!`; total under 8 MB.

- [ ] **Step 6: Commit and report**

```bash
git add tool/exercise_videos/contact_sheet.py
git commit -m "Add a contact sheet for reviewing the exercise videos"
```
Report to the owner. Do not push.
