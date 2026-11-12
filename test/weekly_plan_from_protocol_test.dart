import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/models/exercise_model.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

void main() {
  test('a week has as many days as its block prescribes, not seven', () {
    final mildLow = protocolFor(
      severityBand: 'mild',
      activity: IPAQActivityLevel.low,
    );
    expect(WeeklyPlan.forProtocol(mildLow, 1).days.length, 3);
    expect(WeeklyPlan.forProtocol(mildLow, 4).days.length, 4);
    expect(WeeklyPlan.forProtocol(mildLow, 8).days.length, 5);

    final mildHigh = protocolFor(
      severityBand: 'mild',
      activity: IPAQActivityLevel.high,
    );
    expect(WeeklyPlan.forProtocol(mildHigh, 1).days.length, 5);
  });

  test('a day has one session per prescribed item, not five', () {
    final severe = protocolFor(
      severityBand: 'severe',
      activity: IPAQActivityLevel.low,
    );
    expect(WeeklyPlan.forProtocol(severe, 1).days.first.sessions.length, 6);
    expect(WeeklyPlan.forProtocol(severe, 7).days.first.sessions.length, 13);
  });

  test('sessions carry the prescription, including nullable holds', () {
    final severe = protocolFor(
      severityBand: 'severe',
      activity: IPAQActivityLevel.high,
    );
    final day = WeeklyPlan.forProtocol(severe, 3).days.first;

    final slr = day.sessions.firstWhere(
      (s) => s.exerciseKey == 'straight_leg_raise',
    );
    expect(slr.reps, 8);
    expect(slr.holdSeconds, isNull); // the document says "8 reps no hold"

    final bridge = day.sessions.firstWhere(
      (s) => s.exerciseKey == 'pelvic_bridging',
    );
    expect(bridge.reps, 12);
    expect(bridge.holdSeconds, 10);

    final pfmt = day.sessions.firstWhere((s) => s.exerciseKey == 'pfmt_slow');
    expect(pfmt.position, isNotNull);
    expect(pfmt.relaxSeconds, isNotNull);
    expect(pfmt.sets, 2);
  });

  test('sessions carry a display name from the catalogue', () {
    final p = protocolFor(
      severityBand: 'mild',
      activity: IPAQActivityLevel.high,
    );
    final day = WeeklyPlan.forProtocol(p, 1).days.first;
    expect(
      day.sessions.map((s) => s.exerciseName),
      contains('Pelvic bridging'),
    );
  });

  test('session numbers are the one-based index within the day', () {
    final p = protocolFor(
      severityBand: 'mild',
      activity: IPAQActivityLevel.high,
    );
    final day = WeeklyPlan.forProtocol(p, 1).days.first;
    expect(
      day.sessions.map((s) => s.sessionNumber).toList(),
      List.generate(day.sessions.length, (i) => i + 1),
    );
  });

  test('every day in a week is identical, as the document specifies', () {
    final p = protocolFor(
      severityBand: 'moderate',
      activity: IPAQActivityLevel.moderate,
    );
    final week = WeeklyPlan.forProtocol(p, 5);
    final first = week.days.first.sessions.map((s) => s.exerciseKey).toList();
    for (final day in week.days) {
      expect(day.sessions.map((s) => s.exerciseKey).toList(), first);
    }
  });

  test('the week carries its own day count and progression focus', () {
    final mildLow = protocolFor(
      severityBand: 'mild',
      activity: IPAQActivityLevel.low,
    );
    final week1 = WeeklyPlan.forProtocol(mildLow, 1);
    expect(week1.daysPerWeek, 3);
    expect(week1.progressionFocus, 'Baseline activation');
  });
}
