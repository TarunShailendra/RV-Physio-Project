import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';

/// Covers the exercise timer.
///
/// It was a single flat countdown of reps x (hold + rest) that did nothing on
/// reaching zero — no cue for when to contract or release, which is the whole
/// point of a pelvic floor protocol. It also called notifyListeners once a
/// second, rebuilding every widget watching the notifier to update one label.
///
/// Under the protocols the timer also has to cope with prescriptions that give
/// no rest, and with items given no hold at all. A default notifier follows the
/// severe protocol, whose first item in week 1 is a supine slow hold of 4
/// seconds with a 4 second relax, 6 reps x 2 sets.
///
/// Driven through testWidgets so Timer.periodic runs on the binding's clock
/// rather than in real time.
void main() {
  ExerciseNotifier openWeekOne() => ExerciseNotifier()..loadWeek(1);

  testWidgets('starts on the first rep of the first set, holding', (
    tester,
  ) async {
    final notifier = openWeekOne();
    expect(notifier.phase, ExercisePhase.ready);

    notifier.startTimer();

    expect(notifier.phase, ExercisePhase.hold);
    expect(notifier.currentRep, 1);
    expect(notifier.currentSet, 1);
    expect(
      notifier.secondsRemaining.value,
      notifier.currentSession!.holdSeconds,
    );
    notifier.pauseTimer();
  });

  testWidgets('hold gives way to the prescribed relax, then the next rep', (
    tester,
  ) async {
    final notifier = openWeekOne();
    final session = notifier.currentSession!;
    expect(session.relaxSeconds, isNotNull, reason: 'PFMT prescribes a relax');
    notifier.startTimer();

    await tester.pump(Duration(seconds: session.holdSeconds!));
    expect(notifier.phase, ExercisePhase.rest, reason: 'the hold is over');
    expect(notifier.secondsRemaining.value, session.relaxSeconds);

    await tester.pump(Duration(seconds: session.relaxSeconds!));
    expect(notifier.phase, ExercisePhase.hold, reason: 'on to the next rep');
    expect(notifier.currentRep, 2);

    notifier.pauseTimer();
  });

  testWidgets('a finished set waits for the patient rather than resting', (
    tester,
  ) async {
    final notifier = openWeekOne();
    final session = notifier.currentSession!;
    expect(session.sets, 2);
    notifier.startTimer();

    await tester.pump(
      Duration(
        seconds: session.reps! * (session.holdSeconds! + session.relaxSeconds!),
      ),
    );

    expect(
      notifier.phase,
      ExercisePhase.betweenReps,
      reason: 'one set of two is done and the document gives no rest between '
          'them, so the clock stops instead of inventing one',
    );
    expect(notifier.currentSet, 2);
    expect(notifier.isTimerRunning, isFalse);
  });

  testWidgets('the item finishes once every set is done', (tester) async {
    final notifier = openWeekOne();
    final session = notifier.currentSession!;
    final perSet =
        session.reps! * (session.holdSeconds! + session.relaxSeconds!);

    notifier.startTimer();
    await tester.pump(Duration(seconds: perSet));
    notifier.startTimer(); // the patient begins the second set
    await tester.pump(Duration(seconds: perSet));

    expect(notifier.phase, ExercisePhase.finished);
    expect(notifier.currentRep, session.reps);
    expect(notifier.isTimerRunning, isFalse);
  });

  testWidgets('an item with no prescribed hold is never timed', (tester) async {
    final notifier = openWeekOne();
    // Item 2 of the severe week 1 day is the quick squeezes: reps, no hold.
    notifier.currentSessionIndex = 1;
    expect(notifier.currentSession!.holdSeconds, isNull);

    notifier.startTimer();

    expect(notifier.isTimerRunning, isFalse);
    expect(notifier.phase, ExercisePhase.ready);
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
