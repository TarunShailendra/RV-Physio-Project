import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/core/theme/glass_theme.dart';
import 'package:telerehab_app/features/assessment/models/iciq_model.dart';
import 'package:telerehab_app/features/assessment/notifiers/iciq_notifier.dart';

/// Covers the ICIQ "has this been answered?" rule.
///
/// leakAmount used to default to 1 while the other two answers defaulted to
/// -1, and the screen's check was `leakAmount != -1`. Step 2 therefore always
/// passed validation: a patient could tap Next straight through the leak
/// amount question and be recorded as answering "1 - none".
void main() {
  group('unanswered questions are detectable', () {
    test('a fresh questionnaire has no answers at all', () {
      const model = ICIQModel();

      expect(model.hasLeakFrequency, isFalse);
      expect(
        model.hasLeakAmount,
        isFalse,
        reason: 'this is the one that used to default to an answer of 1',
      );
      expect(model.hasLifeInterference, isFalse);
      expect(model.hasWhenLeaks, isFalse);
      expect(model.isComplete, isFalse);
    });

    test('every question uses the same unanswered sentinel', () {
      const model = ICIQModel();
      expect(model.leakFrequency, ICIQModel.unanswered);
      expect(model.leakAmount, ICIQModel.unanswered);
      expect(model.lifeInterference, ICIQModel.unanswered);
    });

    test('the leak amount question can no longer be skipped', () {
      final notifier = IciqNotifier();
      notifier.setLeakFrequency(3);
      notifier.setLifeInterference(7);
      notifier.toggleWhenLeak('cough or sneeze');

      expect(
        notifier.model.hasLeakAmount,
        isFalse,
        reason: 'leak amount is still unanswered, so the step must not pass',
      );
      expect(notifier.model.isComplete, isFalse);

      notifier.setLeakAmount(2);
      expect(notifier.model.hasLeakAmount, isTrue);
      expect(notifier.model.isComplete, isTrue);
    });

    test('the lowest option on each scale counts as an answer', () {
      final notifier = IciqNotifier();
      notifier.setLeakFrequency(0); // "Never"
      notifier.setLeakAmount(1); // "none", the minimum of that scale
      notifier.setLifeInterference(0); // "Not at all"
      notifier.toggleWhenLeak('never');

      expect(notifier.model.hasLeakFrequency, isTrue);
      expect(notifier.model.hasLeakAmount, isTrue);
      expect(notifier.model.hasLifeInterference, isTrue);
      expect(notifier.model.isComplete, isTrue);
    });

    test('deselecting the only leak context makes it incomplete again', () {
      final notifier = IciqNotifier();
      notifier.setLeakFrequency(1);
      notifier.setLeakAmount(1);
      notifier.setLifeInterference(1);
      notifier.toggleWhenLeak('at night');
      expect(notifier.model.isComplete, isTrue);

      notifier.toggleWhenLeak('at night');
      expect(notifier.model.isComplete, isFalse);
    });
  });

  group('the minimum of a scale is selectable', () {
    // A Slider fires onChanged only when the value moves. With an unanswered
    // question the thumb renders at the minimum, so without committing on
    // tap-down the minimum could never be chosen: tapping it does nothing.
    testWidgets('tapping the thumb where it rests records that value', (
      tester,
    ) async {
      final recorded = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 420,
              child: GlassLabeledSlider(
                title: 'How much urine do you usually leak?',
                value: ICIQModel.unanswered,
                min: 1,
                max: 3,
                showError: false,
                isRequired: true,
                isAnswered: false,
                currentLabel: '',
                minLabel: 'none',
                maxLabel: 'a moderate amount',
                onChanged: recorded.add,
              ),
            ),
          ),
        ),
      );

      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);

      final box = tester.renderObject<RenderBox>(slider);
      final origin = box.localToGlobal(Offset.zero);
      // Tap the far left of the track, where an unanswered thumb sits.
      await tester.tapAt(
        Offset(origin.dx + 12, origin.dy + box.size.height / 2),
      );
      await tester.pumpAndSettle();

      expect(
        recorded,
        contains(1),
        reason: 'tapping the resting position must record the minimum',
      );
    });

    testWidgets('dragging still records the value moved to', (tester) async {
      final recorded = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 420,
              child: GlassLabeledSlider(
                title: 'How much urine do you usually leak?',
                value: ICIQModel.unanswered,
                min: 1,
                max: 3,
                showError: false,
                isAnswered: false,
                currentLabel: '',
                minLabel: 'none',
                maxLabel: 'a moderate amount',
                onChanged: recorded.add,
              ),
            ),
          ),
        ),
      );

      await tester.drag(find.byType(Slider), const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(recorded.last, greaterThan(1));
    });
  });
}
