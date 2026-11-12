import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/models/protocol.dart';

Protocol _sample() => const Protocol(
  id: 'sample',
  severityBand: 'mild',
  activity: IPAQActivityLevel.high,
  intensity: 'moderate to high',
  timeRange: '20-30 mins',
  type: 'PFMT + core',
  blocks: [
    ProtocolWeekBlock(
      startWeek: 1,
      endWeek: 2,
      daysPerWeek: 5,
      progressionFocus: 'Baseline activation',
      items: [],
    ),
    ProtocolWeekBlock(
      startWeek: 3,
      endWeek: 4,
      daysPerWeek: 5,
      progressionFocus: 'Strength + stability',
      items: [],
    ),
    ProtocolWeekBlock(
      startWeek: 5,
      endWeek: 6,
      daysPerWeek: 5,
      progressionFocus: 'Functional + dynamic strength',
      items: [],
    ),
    ProtocolWeekBlock(
      startWeek: 7,
      endWeek: 8,
      daysPerWeek: 5,
      progressionFocus: 'High-level performance + endurance',
      items: [],
    ),
  ],
);

void main() {
  test('blockForWeek returns the block covering each week from 1 to 8', () {
    final p = _sample();
    for (var week = 1; week <= 8; week++) {
      final block = p.blockForWeek(week);
      expect(week, greaterThanOrEqualTo(block.startWeek));
      expect(week, lessThanOrEqualTo(block.endWeek));
    }
  });

  test('blockForWeek rejects weeks outside the protocol', () {
    expect(() => _sample().blockForWeek(0), throwsArgumentError);
    expect(() => _sample().blockForWeek(9), throwsArgumentError);
  });

  test('a prescribed item may have no reps and no hold', () {
    const item = PrescribedItem(exerciseKey: 'diaphragmatic_breathing', sets: 1);
    expect(item.reps, isNull);
    expect(item.holdSeconds, isNull);
    expect(item.position, isNull);
  });
}
