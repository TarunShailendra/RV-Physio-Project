import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/iciq_model.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/assessment/notifiers/assessment_summary_notifier.dart';

/// This file used to assert that a milder, more active patient was started at
/// week 2 or 3 rather than week 1. That rule is retired: the same two scores
/// now choose the protocol itself, and skipping forward would drop the patient
/// past their own protocol's baseline activation block.
void main() {
  test('a mild, highly active patient gets the mild+high protocol', () {
    final summary = AssessmentSummaryNotifier()
      ..iciq = const ICIQModel(
        leakFrequency: 1,
        leakAmount: 2,
        lifeInterference: 3,
      )
      ..ipaq = const IPAQModel(activityLevel: IPAQActivityLevel.high);
    expect(summary.iciq!.severityBand, 'mild');
    expect(summary.protocol.id, 'mild_high');
  });

  test('a moderate, moderately active patient gets moderate+moderate', () {
    final summary = AssessmentSummaryNotifier()
      ..iciq = const ICIQModel(
        leakFrequency: 3,
        leakAmount: 4,
        lifeInterference: 5,
      )
      ..ipaq = const IPAQModel(activityLevel: IPAQActivityLevel.moderate);
    expect(summary.iciq!.severityBand, 'moderate');
    expect(summary.protocol.id, 'moderate_moderate');
  });

  test('a severe patient gets the severe protocol at any activity level', () {
    for (final activity in IPAQActivityLevel.values) {
      final summary = AssessmentSummaryNotifier()
        ..iciq = const ICIQModel(
          leakFrequency: 5,
          leakAmount: 6,
          lifeInterference: 8,
        )
        ..ipaq = IPAQModel(activityLevel: activity);
      expect(summary.protocol.id, 'severe', reason: '$activity');
    }
  });

  test('an unfinished onboarding falls back to the gentlest protocol', () {
    expect(AssessmentSummaryNotifier().protocol.id, 'severe');
  });
}
