import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/core/theme/glass_theme.dart';
import 'package:telerehab_app/features/assessment/models/iciq_model.dart';
import 'package:telerehab_app/features/assessment/notifiers/assessment_summary_notifier.dart';
import 'package:telerehab_app/features/assessment/notifiers/ipaq_notifier.dart';
import 'package:telerehab_app/features/dashboard/dashboard_notifier.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';

void main() {
  group('C5 — the ICIQ total matches the ICIQ-SF instrument', () {
    test('the scale now reaches the published maximum of 21', () {
      // Frequency 0-5, amount 0/2/4/6, interference 0-10.
      const worst = ICIQModel(
        leakFrequency: 5,
        leakAmount: 6,
        lifeInterference: 10,
        whenLeaks: ['all the time'],
      );
      expect(worst.iciqScore, 21);
      expect(worst.severityBand, 'severe');
    });

    test('an asymptomatic patient scores zero', () {
      const none = ICIQModel(
        leakFrequency: 0,
        leakAmount: 0,
        lifeInterference: 0,
        whenLeaks: ['never'],
      );
      expect(none.iciqScore, 0);
      expect(none.severityBand, 'mild');
      expect(none.isComplete, isTrue);
    });

    test('the severity bands line up with the 0-21 range', () {
      ICIQModel at(int amount, int interference) => ICIQModel(
        leakFrequency: 1,
        leakAmount: amount,
        lifeInterference: interference,
        whenLeaks: const ['x'],
      );
      expect(at(2, 4).iciqScore, 7);
      expect(at(2, 4).severityBand, 'mild');
      expect(at(2, 5).severityBand, 'moderate');
      expect(at(4, 9).iciqScore, 14);
      expect(at(4, 9).severityBand, 'moderate');
      expect(at(4, 10).severityBand, 'severe');
    });
  });

  group('C4 — a sedentary patient can complete the IPAQ', () {
    test('zero days counts as an answer', () {
      final notifier = IpaqNotifier();
      expect(notifier.isAnswered(IpaqQuestion.vigorous), isFalse);

      notifier.updateVigorous(days: 0);

      expect(
        notifier.isAnswered(IpaqQuestion.vigorous),
        isTrue,
        reason: 'no vigorous activity is a real response, not a missing one',
      );
      expect(notifier.model.vigorousDays, 0);
    });

    test('every question tracks its own answered state', () {
      final notifier = IpaqNotifier();
      notifier.updateSitting(hours: 0, mins: 0);
      notifier.updateWalking(days: 0);

      expect(notifier.isAnswered(IpaqQuestion.sitting), isTrue);
      expect(notifier.isAnswered(IpaqQuestion.walking), isTrue);
      expect(notifier.isAnswered(IpaqQuestion.moderate), isFalse);
      expect(notifier.isAnswered(IpaqQuestion.vigorous), isFalse);
    });

    test('reset clears the answered questions', () {
      final notifier = IpaqNotifier();
      notifier.updateWalking(days: 0);
      notifier.reset();
      expect(notifier.isAnswered(IpaqQuestion.walking), isFalse);
    });
  });

  group('C3 — a valid zero is not treated as unanswered', () {
    Widget slider({required int value, required bool isAnswered}) =>
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: GlassLabeledSlider(
                title: 'How often do you leak urine?',
                value: value,
                min: 0,
                max: 5,
                showError: true,
                isAnswered: isAnswered,
                errorMessage: 'Please answer all questions',
                currentLabel: '0',
                minLabel: 'Never',
                maxLabel: 'All the time',
                onChanged: (_) {},
              ),
            ),
          ),
        );

    testWidgets('selecting "Never" shows no error', (tester) async {
      await tester.pumpWidget(slider(value: 0, isAnswered: true));
      await tester.pumpAndSettle();
      expect(
        find.text('Please answer all questions'),
        findsNothing,
        reason: '0 is the lowest valid answer, not a missing one',
      );
    });

    testWidgets('a genuinely unanswered question still shows the error', (
      tester,
    ) async {
      await tester.pumpWidget(
        slider(value: ICIQModel.unanswered, isAnswered: false),
      );
      await tester.pumpAndSettle();
      expect(find.text('Please answer all questions'), findsOneWidget);
    });
  });

  group('B2/C6 — saving reports what happened', () {
    test('an incomplete ICIQ is refused rather than stored as zeros', () async {
      final notifier = AssessmentSummaryNotifier();

      // Answers used to be clamped with `< 0 ? 0 :` on the way out, storing an
      // unanswered question as the mildest possible response.
      const partial = ICIQModel(leakFrequency: 3);
      expect(partial.isComplete, isFalse);

      expect(await notifier.saveIciq(partial), AssessmentSaveResult.incomplete);
      expect(
        notifier.iciq,
        isNull,
        reason: 'a refused save must not mark the questionnaire as done',
      );
    });
  });

  group('E2 — the I-QOL opens on a completed week', () {
    test('a completed week opens it with no waiting', () async {
      // The gate used to require seven elapsed days as well, on the grounds
      // that 35 sessions tapped through in minutes is not a week of exercise.
      // That was removed deliberately: the questionnaire now follows the work
      // rather than the calendar.
      final notifier = ExerciseNotifier()
        ..loadWeek(1)
        ..protocolStartDate = DateTime.now();

      expect(
        notifier.daysSinceProtocolStart,
        lessThan(ExerciseNotifier.protocolDurationDays),
      );
      expect(notifier.isIqolAvailable, isFalse, reason: 'week 1 is not done');

      final plan = notifier.currentPlan!;
      for (var day = 0; day < plan.days.length; day++) {
        for (var s = 0; s < plan.days[day].sessions.length; s++) {
          await notifier.completeSession(day, s);
        }
      }

      expect(
        notifier.isIqolAvailable,
        isTrue,
        reason: 'finishing the week is the whole condition now',
      );
    });

    test('elapsed time alone still opens nothing', () {
      final notifier = ExerciseNotifier()
        ..loadWeek(1)
        ..protocolStartDate = DateTime.now().subtract(const Duration(days: 30));

      expect(
        notifier.isIqolAvailable,
        isFalse,
        reason: 'a month of doing nothing is not a completed week',
      );
    });
  });

  group('E3 — adherence reports the week the patient is on', () {
    test('a perfect first week reads as 100%, not 13%', () {
      final weekly = <double>[100, 0, 0, 0, 0, 0, 0, 0];
      expect(currentWeekAdherence(weekly, 1), 100.0);
      expect(
        weekly.reduce((a, b) => a + b) / 8,
        12.5,
        reason: 'what the original calculation produced',
      );
    });

    test('a patient started past week 1 is not charged for the weeks before '
        'their start', () {
      // The assessments can recommend beginning at week 2 or 3. Averaging
      // across "weeks reached" counted those untouched weeks as zeroes, so a
      // flawless week 3 showed 33% beside a card reading 7/7.
      final weekly = <double>[0, 0, 100, 0, 0, 0, 0, 0];
      expect(currentWeekAdherence(weekly, 3), 100.0);
      expect(
        weekly.take(3).reduce((a, b) => a + b) / 3,
        closeTo(33.3, 0.1),
        reason: 'what the averaging produced',
      );
    });

    test('earlier weeks do not follow the patient forward', () {
      expect(
        currentWeekAdherence(<double>[100, 50, 0, 0, 0, 0, 0, 0], 2),
        50.0,
      );
      expect(
        currentWeekAdherence(<double>[90, 60, 30, 0, 0, 0, 0, 0], 3),
        30.0,
      );
    });

    test('the last week of a finished protocol is the one reported', () {
      expect(currentWeekAdherence(List<double>.filled(8, 80), 8), 80.0);
    });

    test('degenerate inputs are clamped rather than throwing', () {
      expect(currentWeekAdherence([], 3), 0);
      expect(currentWeekAdherence(<double>[50], 0), 50.0);
      expect(
        currentWeekAdherence(<double>[50, 60], 9),
        60.0,
        reason: 'a week past the end reads as the last one, not a range error',
      );
    });
  });
}
