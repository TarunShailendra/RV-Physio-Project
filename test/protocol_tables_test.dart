import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/protocols/exercise_catalogue.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_tables.dart';

void main() {
  test('there are seven protocol tables', () {
    expect(allProtocols.length, 7);
    expect(allProtocols.map((p) => p.id).toList(), [
      'mild_high',
      'mild_moderate',
      'mild_low',
      'moderate_high',
      'moderate_moderate',
      'moderate_low',
      'severe',
    ]);
  });

  test('days per week match the document', () {
    const expected = {
      'mild_high': [5, 5, 5, 5],
      'mild_moderate': [4, 4, 5, 5],
      'mild_low': [3, 4, 4, 5],
      'moderate_high': [5, 5, 5, 5],
      'moderate_moderate': [4, 4, 5, 5],
      'moderate_low': [3, 4, 4, 5],
      'severe': [5, 5, 5, 5],
    };
    for (final p in allProtocols) {
      expect(
        p.blocks.map((b) => b.daysPerWeek).toList(),
        expected[p.id],
        reason: p.id,
      );
    }
  });

  test('items per day match the document', () {
    const expected = {
      'mild_high': [12, 14, 15, 15],
      'mild_moderate': [12, 14, 15, 15],
      'mild_low': [12, 14, 15, 15],
      'moderate_high': [12, 14, 15, 15],
      'moderate_moderate': [12, 14, 15, 15],
      'moderate_low': [12, 14, 15, 15],
      'severe': [6, 11, 12, 13],
    };
    for (final p in allProtocols) {
      expect(
        p.blocks.map((b) => b.items.length).toList(),
        expected[p.id],
        reason: p.id,
      );
    }
  });

  test('every block covers two weeks and together they cover 1 to 8', () {
    for (final p in allProtocols) {
      expect(p.blocks.length, 4, reason: p.id);
      expect(
        p.blocks.map((b) => [b.startWeek, b.endWeek]).toList(),
        [
          [1, 2],
          [3, 4],
          [5, 6],
          [7, 8],
        ],
        reason: p.id,
      );
    }
  });

  test('every prescribed exercise exists in the catalogue', () {
    for (final p in allProtocols) {
      for (final b in p.blocks) {
        for (final item in b.items) {
          expect(
            exerciseCatalogue.containsKey(item.exerciseKey),
            isTrue,
            reason: '${p.id} week ${b.startWeek}: ${item.exerciseKey}',
          );
        }
      }
    }
  });

  test('every item but breathing carries a rep count and at least one set', () {
    for (final p in allProtocols) {
      for (final b in p.blocks) {
        for (final item in b.items) {
          if (item.exerciseKey == 'diaphragmatic_breathing') continue;
          expect(
            item.reps,
            isNotNull,
            reason: '${p.id}: ${item.exerciseKey} has no reps',
          );
          expect(item.sets, greaterThanOrEqualTo(1), reason: p.id);
        }
      }
    }
  });

  test('the severe protocol never exceeds the gentlest prescriptions', () {
    // A guard against transcribing a Mild row into the Severe table: the
    // document caps severe holds at 15 seconds.
    final severe = allProtocols.firstWhere((p) => p.id == 'severe');
    for (final b in severe.blocks) {
      for (final item in b.items) {
        expect(
          item.holdSeconds ?? 0,
          lessThanOrEqualTo(15),
          reason: item.exerciseKey,
        );
      }
    }
  });

  test('every pelvic floor slow hold names a position and a relax time', () {
    for (final p in allProtocols) {
      for (final b in p.blocks) {
        for (final item in b.items.where((i) => i.exerciseKey == 'pfmt_slow')) {
          expect(item.position, isNotNull, reason: p.id);
          expect(item.relaxSeconds, isNotNull, reason: p.id);
          expect(item.holdSeconds, isNotNull, reason: p.id);
        }
      }
    }
  });
}
