# Exercise demonstration videos

**Date:** 2026-11-11
**Status:** written up after a design conversation with the project owner; awaiting their review.
**Style reference:** `../Videos/pelvic_bridge_side_view.mp4` and the script that made it,
`../Videos/bridge.py` (both in the `Videos` folder beside the repository, outside it).

## Intent

Every exercise in the exercise tab gets an animated demonstration. The patient opens an
exercise from the day's checklist and **follows the animation while they exercise**, rep by
rep. Today the detail sheet gives them written steps, DO/DON'T lists and a countdown, but
nothing that shows the movement; the patient has to translate prose into a body position on
their own, alone, at home. The animation closes that gap.

The project owner supplied one animation — a pelvic bridge, side view — made by a ~250-line
Pillow script. All the other animations are to be made in that same style.

## Goals

- One animation per exercise in `exerciseCatalogue` (16), in the bridge video's style.
- For held exercises, the animation is **driven by the app's own timer** so it always matches
  the patient's prescription — whatever reps, hold, relax and sets their protocol and week give.
- For exercises with no hold, the animation is a looping **demonstration** only.
- The videos ship inside the app.

## Non-goals

- No change to which exercises, reps, holds or sets anyone is prescribed.
- No audio, voice-over or music.
- No new screens; the video lives in the existing detail sheet.
- No rep counting for unheld exercises. They stay "do them, then tap mark as done".

## Anti-goals — failure even if it technically works

- **An animation that contradicts the prescription.** A video showing a 1.5 s hold while the
  timer says 10 s, or "REP 1 / 3" when the patient is on rep 7 of 12, is worse than no video.
  This is why nothing about reps, phases or timing is baked into the videos.
- **An animation that contradicts the written instructions.** Each animation must depict
  exactly what `lib/features/exercise/content/exercise_content.dart` tells the patient to do.
  Where they disagree, the text wins and the animation is fixed.
- **A broken sheet when a video cannot play.** The instructions and the timer must work exactly
  as they do today if a video fails to load.

## Decisions made with the project owner

1. **Follow-along, matched to the prescription** — not a fixed 3-rep demo.
2. **One short single-rep video per exercise, played by the app in step with its timer**
   (option 2), rather than one full-length video per prescription. There are 79 distinct
   prescriptions across the 7 protocols; full-length videos for all of them would run to
   ~200 MB+. Single-rep videos total roughly 5 MB.
3. **No-hold exercises are a looping demonstration only.**
4. **The per-exercise movement and camera list below** was played back and approved as is.
5. **The pelvic bridge is re-rendered** from the owner's script without its baked-in rep
   counter and captions, and as a single rep. Room, figure, colours and proportions unchanged.

## What each animation shows

Shared style, taken from `bridge.py`: the same gym room (wall gradient, window, clock,
exercise ball, dumbbell rack, kettlebells, teal mat, floor), the same flat figure (skin, coral
top, navy leggings, white shoes, dark hair in a bun), 1280×720, 30 fps, 2× supersampled, cosine
easing, soft orange glow over the working muscle, green dashed alignment guide where the
document names a line to hold. **No text in any frame** — captions, title cards, rep counters
and phase labels come from the app, which keeps the videos language-neutral for Kannada.

| Exercise key | Camera | Movement | Video(s) |
|---|---|---|---|
| `pfmt_slow` | side | Still figure; pelvic-floor area glows in on the squeeze, out on the relax | 3: supine, sitting, standing |
| `pfmt_quick` | side | Same still figure; short glow pulse per squeeze | 3: supine, sitting, standing |
| `diaphragmatic_breathing` | side, supine, knees bent | One hand on chest, one on belly; belly rises on the breath in, falls on the breath out; chest still | 1 |
| `pelvic_bridging` | side | Re-render of the owner's bridge | 1 |
| `pelvic_tilt` | side, supine, knees bent | Small backward roll of the pelvis flattening the lower back; hips stay down | 1 |
| `pelvic_rotations` | from the feet, supine | Both knees lower together to one side, hold, return; then the other side | 1, two halves |
| `leg_circles` | side, supine | One leg straight up, the other bent; small circle drawn by the raised foot, in slight perspective | 1 |
| `single_leg_stretch` | side, supine | Both knees to chest; one leg extends low while the other stays in; then switch | 1, two halves |
| `straight_leg_raise` | side, supine | One knee bent; straight leg lifts to the bent knee's height, holds, lowers | 1 |
| `side_leg_raise` | front, side-lying | Bottom leg slightly bent; straight top leg lifts toward the ceiling, holds, lowers | 1 |
| `wall_squat` | side | Back against a wall added to the room; slides down to a comfortable bend, holds, slides up | 1 |
| `quadruped_arm_leg_raise` | side, hands and knees | One arm reaches forward as the opposite leg extends back; hold; return; then the other pair | 1, two halves |
| `clamshells` | front, side-lying | Knees bent and stacked, feet together; top knee opens toward the ceiling and closes | 1 |
| `lunges` | side, standing beside a chair | Step forward, both knees bend, push back up | 1 |
| `squats` | side, standing beside a chair | Hips back and down as if into a chair, stand back up | 1 |
| `leg_scissors` | side, supine | Both legs straight up; one lowers toward the floor and returns; then the other | 1, two halves |

That is 20 video files. Exercises with "two halves" alternate sides: the app plays the first
half on odd reps and the second half on even reps.

## How the app plays them

### Held exercises — synced to the timer

Each held video is one rep cut into named segments, recorded alongside the video:

- **into** — from the start pose to the hold pose,
- **hold frame** — the instant the hold pose is reached, where the video is paused,
- **out of** — from the hold pose back to the start pose.

Alternating exercises have these segments twice, once per side. The PFMT videos use the same
shape, with the glow rising during *into* and fading during *out of*.

The video follows the timer's phases:

| Timer | Video |
|---|---|
| ready (before Start) | loops one whole rep as a preview |
| moving into the hold | plays *into* |
| hold, counting down | paused on the hold frame |
| relax / between reps | plays *out of*, then waits on the start pose |
| paused | paused where it is |
| finished | rests on the start pose |

**Behaviour change, my call:** the timer gains short movement phases either side of each hold,
whose lengths are the video's own *into* and *out of* segments (around 1–1.5 s). Today the hold
countdown starts the instant the patient taps Start, so a 10 s hold would include the time
spent getting into position. With this change the hold countdown starts when the figure
reaches the hold pose. Rep, set and phase labels continue to come from the app's existing
timer display. The duration written to `exercise_logs` stays the prescription
(reps × (hold + relax) × sets), unchanged.

**Existing defect fixed along the way** (found while planning): opening an item's sheet never
told the timer which item it was, so the sheet's timer always ran the day's first unfinished
item. A video synced to the wrong item would make that visible, so opening a sheet now selects
its item for the timer.

### Unheld exercises — demonstration

Clamshells, leg circles, lunges, squats, leg scissors, quick squeezes, diaphragmatic breathing
and any item the protocol prescribes without a hold: the video loops one rep at a natural pace
from the moment the sheet opens. No counting. The "mark as done" button is unchanged.

### Where it sits

At the top of the exercise detail sheet, full width, 16:9, above the exercise name. Muted and
autoplaying (browsers only autoplay muted video, and there is no audio). If the video fails to
load, the space collapses and the rest of the sheet is exactly as it is today.

## Constraints

- **Videos are generated by a committed script**, as the protocol tables are, so they can be
  regenerated and traced. The owner's `bridge.py` is the starting point; it is refactored into a
  shared room/figure/encoder module plus one pose sequence per exercise, and lives under
  `tool/` in the repo.
- **The generator also writes the segment timings** as a Dart file, so the app's segment
  boundaries cannot drift from the rendered videos.
- **Encoding is H.264 MP4** (yuv420p, faststart), which plays in Chrome, Android and iOS.
  `bridge.py` pipes to an `ffmpeg` on the PATH, which this machine does not have; the
  generator will use the binary bundled by the `imageio-ffmpeg` pip package instead.
- **The app keeps working in tests.** Video playback cannot run under `flutter test`, so the
  player sits behind a small seam that tests replace.
- Project norms carry over: test-first, `flutter analyze` clean and `flutter test` green before
  each commit, commit locally on a new branch off `exercise-protocols`, **never push without the
  owner's say-so**.

## Left to the builder

- How the figure is rigged (joint model, inverse kinematics) and how poses are keyframed.
- Exact segment durations, provided they look natural and *into*/*out of* stay roughly 1–1.5 s.
- Which Flutter package plays the video (`video_player` is the obvious choice) and how the seam
  for tests is shaped.
- Where the generated Dart timing file and the assets live, and how pubspec lists them.
- Tests: at minimum, every catalogue key (and each PFMT position) has a video entry whose asset
  exists, segment timings are ordered and inside the video's length, and the timer's new
  movement phases sequence correctly.

## Verification

Tests cover the wiring; only eyes cover the animations. Before handing over:

- a contact sheet of key frames from every video, checked against its row in the table above and
  its text in `exercise_content.dart`;
- the app run in Chrome, with one held exercise (bridge), one alternating exercise and one PFMT
  position followed through a full rep with the timer, and one unheld exercise seen looping.

The owner reviews the contact sheet before anything is committed as final.
