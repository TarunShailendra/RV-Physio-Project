import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';

/// Covers the recommended start week actually reaching the exercise plan.
///
/// loadRecommendedWeek(int _) discarded its argument and called
/// loadWeek(highestUnlockedWeek). All four call sites carefully computed
/// AssessmentSummaryNotifier.recommendedStartWeek and passed it in, so the
/// whole heuristic combining ICIQ severity, IPAQ activity level and I-QOL
/// score had no effect: every patient started at the first week they had not
/// finished, which is week 1 for everyone new.
void main() {
  setUpAll(() {
    // completeSession also tries to persist to Supabase, which is not
    // initialised here; the failure is caught and debugPrinted. Silence that
    // so the output stays readable — the local progression is what is under
    // test, and the persistence path is covered by the migration work.
    debugPrint = (String? message, {int? wrapWidth}) {};
  });

  tearDownAll(() => debugPrint = debugPrintThrottled);

  /// Completes every session of [week]: 7 days x 5 sessions.
  ///
  /// No backdating of the protocol start: the I-QOL asks only for a finished
  /// week, so a week completed in the same instant opens it.
  Future<void> completeWeek(ExerciseNotifier notifier, int week) async {
    notifier.loadWeek(week);
    final plan = notifier.currentPlan!;
    expect(plan.weekNumber, week);
    for (var day = 0; day < plan.days.length; day++) {
      for (
        var session = 0;
        session < plan.days[day].sessions.length;
        session++
      ) {
        await notifier.completeSession(day, session);
      }
    }
  }

  group('the recommendation is honoured', () {
    test('a new patient recommended week 3 starts at week 3', () {
      final notifier = ExerciseNotifier();
      notifier.loadRecommendedWeek(3);

      expect(notifier.recommendedStartWeek, 3);
      expect(
        notifier.currentPlan?.weekNumber,
        3,
        reason: 'the argument used to be discarded and this loaded week 1',
      );
    });

    test('each recommendation lands on its own week', () {
      for (final week in [1, 2, 3]) {
        final notifier = ExerciseNotifier();
        notifier.loadRecommendedWeek(week);
        expect(notifier.currentPlan?.weekNumber, week, reason: 'week $week');
      }
    });

    test('a later start week does not leave the screen without a plan', () {
      // loadWeek refuses a week that is not unlocked, so raising the floor has
      // to happen first. Otherwise currentPlan stays null and the exercise
      // screen shows a loading spinner forever.
      final notifier = ExerciseNotifier();
      notifier.loadRecommendedWeek(3);

      expect(notifier.currentPlan, isNotNull);
      expect(notifier.currentDay, isNotNull);
      expect(notifier.currentSession, isNotNull);
    });

    test('the recommendation raises the unlock floor', () {
      final notifier = ExerciseNotifier();
      expect(notifier.highestUnlockedWeek, 1);

      notifier.setRecommendedStartWeek(3);
      expect(notifier.highestUnlockedWeek, 3);
      expect(notifier.canAccessWeek(3), isTrue);
      expect(
        notifier.canAccessWeek(4),
        isFalse,
        reason: 'week 4 still has to be earned',
      );
    });

    test('earlier weeks stay reachable, just not required', () {
      final notifier = ExerciseNotifier();
      notifier.setRecommendedStartWeek(3);

      expect(notifier.canAccessWeek(1), isTrue);
      expect(notifier.canAccessWeek(2), isTrue);

      notifier.loadWeek(1);
      expect(notifier.currentPlan?.weekNumber, 1);
    });

    test('out-of-range recommendations are clamped', () {
      final notifier = ExerciseNotifier();
      notifier.setRecommendedStartWeek(0);
      expect(notifier.recommendedStartWeek, 1);

      notifier.setRecommendedStartWeek(99);
      expect(notifier.recommendedStartWeek, 8);
    });

    test('reset clears the recommendation back to week 1', () {
      final notifier = ExerciseNotifier();
      notifier.loadRecommendedWeek(3);
      expect(notifier.recommendedStartWeek, 3);

      notifier.reset();
      expect(notifier.recommendedStartWeek, 1);
      expect(notifier.highestUnlockedWeek, 1);
    });
  });

  group('progression from a later start week', () {
    test('finishing the start week unlocks the next one', () async {
      final notifier = ExerciseNotifier();
      notifier.loadRecommendedWeek(3);
      expect(notifier.highestUnlockedWeek, 3);

      await completeWeek(notifier, 3);

      expect(notifier.highestUnlockedWeek, 4);
      expect(notifier.canAccessWeek(4), isTrue);
    });

    test(
      'the I-QOL opens after the patient completes their own first week',
      () async {
        // This used to ask for week 1 specifically, so a patient starting at
        // week 3 would finish their first week and still never be offered the
        // questionnaire.
        final notifier = ExerciseNotifier();
        notifier.loadRecommendedWeek(3);
        expect(notifier.isIqolAvailable, isFalse);

        await completeWeek(notifier, 3);

        expect(
          notifier.isIqolAvailable,
          isTrue,
          reason: 'a completed week of the protocol must unlock the I-QOL',
        );
        expect(
          notifier.isWeekOneComplete,
          isFalse,
          reason: 'week 1 was never part of this patient protocol',
        );
      },
    );

    test('a week-1 patient is unaffected', () async {
      final notifier = ExerciseNotifier();
      notifier.loadRecommendedWeek(1);
      expect(notifier.highestUnlockedWeek, 1);
      expect(notifier.isIqolAvailable, isFalse);

      await completeWeek(notifier, 1);

      expect(notifier.highestUnlockedWeek, 2);
      expect(notifier.isIqolAvailable, isTrue);
    });
  });
}
