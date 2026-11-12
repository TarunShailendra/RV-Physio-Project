import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';
import 'package:telerehab_app/features/exercise/models/protocol.dart';

/// Covers the movement phases: the patient is shown getting into the hold
/// position and coming back out, and the hold clock only runs in between.
///
/// Week 1's fourth item is pelvic_bridging (10 s hold, no relax).

/// A one-item programme: pelvic rotations, 3 reps x 2 sets, 10 s hold, so an
/// odd rep count shows the sides restarting on A each set.
const _rotations = Protocol(
  id: 'test_rotations',
  severityBand: 'mild',
  activity: IPAQActivityLevel.high,
  intensity: 'low',
  timeRange: '5 mins',
  type: 'test',
  blocks: [
    ProtocolWeekBlock(
      startWeek: 1,
      endWeek: 8,
      daysPerWeek: 5,
      progressionFocus: 'test',
      items: [
        PrescribedItem(
          exerciseKey: 'pelvic_rotations',
          sets: 2,
          reps: 3,
          holdSeconds: 10,
        ),
      ],
    ),
  ],
);

void main() {
  ExerciseNotifier openBridge() => ExerciseNotifier()
    ..loadWeek(1)
    ..selectSession(3);

  testWidgets('selecting an item makes it the one the timer runs', (
    tester,
  ) async {
    final notifier = ExerciseNotifier()..loadWeek(1);
    expect(notifier.currentSession!.exerciseKey, isNot('pelvic_bridging'));

    notifier.selectSession(3);

    expect(notifier.currentSession!.exerciseKey, 'pelvic_bridging');
    expect(notifier.phase, ExercisePhase.ready);
  });

  testWidgets('selecting an out-of-range item is ignored', (tester) async {
    final notifier = ExerciseNotifier()..loadWeek(1);
    notifier.selectSession(99);
    notifier.selectSession(-1);
    expect(notifier.currentSessionIndex, 0);
  });

  testWidgets('selecting an item mid-timer stops the clock', (tester) async {
    final notifier = ExerciseNotifier()..loadWeek(1);
    notifier.startTimer();
    expect(notifier.isTimerRunning, isTrue);

    notifier.selectSession(3);

    expect(notifier.isTimerRunning, isFalse);
    expect(notifier.phase, ExercisePhase.ready);
  });

  testWidgets('Start moves into the hold before the clock counts', (
    tester,
  ) async {
    final notifier = openBridge();
    final hold = notifier.currentSession!.holdSeconds!;
    final into = notifier.currentVideo!.sides.first.intoDuration;

    notifier.startTimer();
    expect(notifier.phase, ExercisePhase.moveIn);
    expect(notifier.secondsRemaining.value, hold);

    await tester.pump(into);
    expect(notifier.phase, ExercisePhase.hold);
    expect(notifier.secondsRemaining.value, hold);

    notifier.pauseTimer();
  });

  testWidgets('the hold is followed by moving out, then waiting', (
    tester,
  ) async {
    final notifier = openBridge();
    final session = notifier.currentSession!;
    expect(session.relaxSeconds, isNull);
    final side = notifier.currentVideo!.sides.first;

    notifier.startTimer();
    await tester.pump(
      side.intoDuration + Duration(seconds: session.holdSeconds!),
    );
    expect(notifier.phase, ExercisePhase.moveOut);
    expect(notifier.secondsRemaining.value, 0);

    await tester.pump(side.outDuration);
    expect(notifier.phase, ExercisePhase.betweenReps);
    expect(notifier.isTimerRunning, isFalse);
  });

  testWidgets('pausing mid-movement replays the movement', (tester) async {
    final notifier = openBridge();
    final hold = notifier.currentSession!.holdSeconds!;
    final into = notifier.currentVideo!.sides.first.intoDuration;
    final half = into ~/ 2;

    notifier.startTimer();
    await tester.pump(half);
    notifier.pauseTimer();
    expect(notifier.phase, ExercisePhase.moveIn);

    await tester.pump(const Duration(seconds: 5));
    expect(notifier.phase, ExercisePhase.moveIn);

    notifier.startTimer();
    await tester.pump(half);
    expect(notifier.phase, ExercisePhase.moveIn, reason: 'replayed from start');
    await tester.pump(into - half);
    expect(notifier.phase, ExercisePhase.hold);
    expect(notifier.secondsRemaining.value, hold);

    notifier.pauseTimer();
  });

  testWidgets('a session with no video times exactly as before', (
    tester,
  ) async {
    final notifier = ExerciseNotifier(videoLookup: (_, _) => null)
      ..loadWeek(1)
      ..selectSession(3);

    notifier.startTimer();

    expect(notifier.phase, ExercisePhase.hold);
    expect(notifier.secondsRemaining.value, 10);
    notifier.pauseTimer();
  });

  testWidgets('alternating sides go A, B, A and restart each set', (
    tester,
  ) async {
    final notifier = ExerciseNotifier()
      ..applyProtocol(_rotations)
      ..loadWeek(1);
    final session = notifier.currentSession!;
    expect(session.exerciseKey, 'pelvic_rotations');
    final video = notifier.currentVideo!;
    expect(video.alternates, isTrue);

    for (var set = 1; set <= session.sets; set++) {
      final sides = <int>[];
      for (var rep = 1; rep <= session.reps!; rep++) {
        notifier.startTimer();
        expect(notifier.currentSet, set);
        expect(notifier.currentRep, rep);
        final side = video.sides[notifier.currentSideIndex];
        await tester.pump(side.intoDuration);
        expect(notifier.phase, ExercisePhase.hold);
        sides.add(notifier.currentSideIndex);
        await tester.pump(Duration(seconds: session.holdSeconds!));
        expect(notifier.phase, ExercisePhase.moveOut);
        await tester.pump(side.outDuration);
      }
      expect(sides, [0, 1, 0], reason: 'set $set');
      expect(notifier.currentSideIndex, 0, reason: 'after set $set');
    }
    expect(notifier.phase, ExercisePhase.finished);
  });
}
