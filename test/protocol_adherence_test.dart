import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/dashboard/dashboard_notifier.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

void main() {
  final mildLow = protocolFor(
    severityBand: 'mild',
    activity: IPAQActivityLevel.low,
  );
  final mildHigh = protocolFor(
    severityBand: 'mild',
    activity: IPAQActivityLevel.high,
  );

  test('a three-day week is fully adherent after three days', () {
    expect(weekAdherence(completedDays: 3, week: 1, protocol: mildLow), 100.0);
    expect(
      weekAdherence(completedDays: 2, week: 1, protocol: mildLow),
      closeTo(66.67, 0.01),
    );
  });

  test('the same three days on a five-day week is not full adherence', () {
    expect(weekAdherence(completedDays: 3, week: 8, protocol: mildLow), 60.0);
    expect(weekAdherence(completedDays: 3, week: 1, protocol: mildHigh), 60.0);
  });

  test('adherence never exceeds 100 percent', () {
    expect(weekAdherence(completedDays: 9, week: 1, protocol: mildLow), 100.0);
  });

  test('a part-finished new week does not report the previous week', () {
    expect(
      resolveCurrentWeek(
        weeksTouched: {1, 2},
        completedDaysByWeek: {1: 3, 2: 0},
        protocol: mildLow,
      ),
      2,
    );
  });

  test('a week is only finished when its own day count is met', () {
    // Week 1 of mild+low is three days; weeks 3-4 are four.
    expect(
      resolveCurrentWeek(
        weeksTouched: {1},
        completedDaysByWeek: {1: 3},
        protocol: mildLow,
      ),
      2,
    );
    expect(
      resolveCurrentWeek(
        weeksTouched: {3},
        completedDaysByWeek: {3: 3},
        protocol: mildLow,
      ),
      3,
    );
    expect(
      resolveCurrentWeek(
        weeksTouched: {3},
        completedDaysByWeek: {3: 4},
        protocol: mildLow,
      ),
      4,
    );
  });

  test('a patient who has done nothing is on week one', () {
    expect(
      resolveCurrentWeek(
        weeksTouched: const {},
        completedDaysByWeek: const {},
        protocol: mildHigh,
      ),
      1,
    );
  });
}
