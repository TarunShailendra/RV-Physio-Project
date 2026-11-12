import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';
import 'package:telerehab_app/features/exercise/videos/demo_playback.dart';
import 'package:telerehab_app/features/exercise/videos/exercise_video.dart';

void main() {
  const side = VideoSide(
    intoStartMs: 400,
    holdMs: 1700,
    outStartMs: 2500,
    outEndMs: 4000,
  );
  Duration ms(int v) => Duration(milliseconds: v);

  DemoCommand command(
    ExercisePhase phase, {
    bool running = true,
    bool held = true,
  }) => demoCommandFor(
    phase: phase,
    isTimerRunning: running,
    isHeld: held,
    side: side,
  );

  test('moving in plays the into segment', () {
    expect(
      command(ExercisePhase.moveIn),
      PlaySegment(ms(400), ms(1700)),
    );
  });

  test('holding shows the hold frame', () {
    expect(command(ExercisePhase.hold), ShowFrame(ms(1700)));
  });

  test('moving out plays the out segment', () {
    expect(
      command(ExercisePhase.moveOut),
      PlaySegment(ms(2500), ms(4000)),
    );
  });

  test('an unheld exercise always loops', () {
    for (final phase in ExercisePhase.values) {
      expect(command(phase, held: false), const LoopWhole());
    }
  });

  test('the preview before starting loops', () {
    expect(command(ExercisePhase.ready, running: false), const LoopWhole());
  });

  test('a paused timer freezes the video', () {
    for (final phase in [
      ExercisePhase.moveIn,
      ExercisePhase.hold,
      ExercisePhase.moveOut,
      ExercisePhase.rest,
    ]) {
      expect(command(phase, running: false), const Freeze());
    }
  });

  test('between reps the figure waits on the start pose', () {
    for (final phase in [
      ExercisePhase.rest,
      ExercisePhase.betweenReps,
      ExercisePhase.finished,
    ]) {
      expect(command(phase), ShowFrame(ms(400)));
    }
    expect(
      command(ExercisePhase.betweenReps, running: false),
      ShowFrame(ms(400)),
    );
  });
}
