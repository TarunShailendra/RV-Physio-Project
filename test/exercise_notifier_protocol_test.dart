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
    expect(notifier.protocol.id, 'severe');
    notifier.loadWeek(1);
    expect(notifier.currentPlan!.days.first.sessions.length, 6);
  });

  test('adopting a new protocol discards the plan built from the old one', () {
    final notifier = ExerciseNotifier();
    notifier.loadWeek(1);
    expect(notifier.currentPlan!.days.first.sessions.length, 6); // severe
    notifier.applyProtocol(
      protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.high),
    );
    expect(notifier.currentPlan, isNull);
    notifier.loadWeek(1);
    expect(notifier.currentPlan!.days.first.sessions.length, 12);
  });

  test('an exercise with no prescribed hold does not start a countdown', () {
    final notifier = ExerciseNotifier();
    notifier.applyProtocol(
      protocolFor(severityBand: 'severe', activity: IPAQActivityLevel.high),
    );
    notifier.loadWeek(1);
    // Item 2 of the severe week 1 day is the quick squeezes: reps, no hold.
    notifier.currentSessionIndex = 1;
    expect(notifier.currentSession!.holdSeconds, isNull);
    notifier.startTimer();
    expect(notifier.isTimerRunning, isFalse);
  });
}
