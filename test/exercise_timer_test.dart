import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';

/// Covers the exercise timer.
///
/// It was a single flat countdown of reps x (hold + rest) that did nothing on
/// reaching zero — no cue for when to contract or release, which is the whole
/// point of a pelvic floor protocol. It also called notifyListeners once a
/// second, rebuilding every widget watching the notifier to update one label.
///
/// Driven through testWidgets so Timer.periodic runs on the binding's clock
/// rather than in real time.
void main() {
  ExerciseNotifier openWeekOne() => ExerciseNotifier()..loadWeek(1);

  testWidgets('starts on the first rep, holding', (tester) async {
    final notifier = openWeekOne();
    expect(notifier.phase, ExercisePhase.ready);

    notifier.startTimer();

    expect(notifier.phase, ExercisePhase.hold);
    expect(notifier.currentRep, 1);
    expect(
      notifier.secondsRemaining.value,
      notifier.currentSession!.holdSeconds,
    );
    notifier.pauseTimer();
  });

  testWidgets('hold gives way to rest, then the next rep', (tester) async {
    final notifier = openWeekOne();
    final session = notifier.currentSession!;
    notifier.startTimer();

    await tester.pump(Duration(seconds: session.holdSeconds));
    expect(notifier.phase, ExercisePhase.rest, reason: 'the hold is over');
    expect(notifier.secondsRemaining.value, session.restSeconds);

    await tester.pump(Duration(seconds: session.restSeconds));
    expect(notifier.phase, ExercisePhase.hold, reason: 'on to the next rep');
    expect(notifier.currentRep, 2);

    notifier.pauseTimer();
  });

  testWidgets('the session finishes rather than stopping silently', (
    tester,
  ) async {
    final notifier = openWeekOne();
    final session = notifier.currentSession!;
    notifier.startTimer();

    await tester.pump(
      Duration(seconds: session.reps * (session.holdSeconds + session.restSeconds)),
    );

    expect(notifier.phase, ExercisePhase.finished);
    expect(notifier.currentRep, session.reps);
    expect(notifier.isTimerRunning, isFalse);
  });

  testWidgets('ticking does not go through notifyListeners', (tester) async {
    final notifier = openWeekOne();
    notifier.startTimer();

    var notifications = 0;
    notifier.addListener(() => notifications++);
    final before = notifier.secondsRemaining.value;

    await tester.pump(const Duration(seconds: 3));

    expect(notifier.secondsRemaining.value, before - 3, reason: 'it ticked');
    expect(
      notifications,
      0,
      reason: 'a tick must not rebuild everything watching the notifier',
    );

    notifier.pauseTimer();
  });

  testWidgets('pausing keeps the place', (tester) async {
    final notifier = openWeekOne();
    notifier.startTimer();
    await tester.pump(const Duration(seconds: 2));

    final at = notifier.secondsRemaining.value;
    notifier.pauseTimer();
    await tester.pump(const Duration(seconds: 5));

    expect(notifier.secondsRemaining.value, at, reason: 'paused means paused');
    expect(notifier.isTimerRunning, isFalse);
  });
}
