import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Two faults that leave no trace at runtime: a timestamp written a whole
/// timezone out, and a widget key that interpolates nothing.
void main() {
  group('timestamps sent to Postgres are UTC', () {
    /// Files that build a row for a `timestamptz` column.
    const dbWriters = [
      'lib/features/bladder_diary/screens/bladder_diary_screen.dart',
      'lib/features/profile/profile_notifier.dart',
      'lib/features/exercise/exercise_notifier.dart',
      'lib/features/assessment/notifiers/assessment_summary_notifier.dart',
    ];

    test('no local DateTime is serialised into a row', () {
      // A local DateTime's ISO-8601 string carries no offset, so Postgres
      // reads the wall-clock reading as UTC: a diary submitted at 00:39 IST
      // was stored as 00:39 UTC, five and a half hours into the future, which
      // is exactly the gap between submitted_at and created_at on every row
      // written before this was fixed.
      for (final path in dbWriters) {
        final lines = File(path).readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Prose about the fault is not the fault.
          if (line.trimLeft().startsWith('//')) continue;
          if (!line.contains('toIso8601String()')) continue;
          // A `date` column takes no time part and no zone, so date-only
          // values are correct as they are.
          if (line.contains(".split('T').first")) continue;
          expect(
            line.contains('.toUtc().toIso8601String()'),
            isTrue,
            reason:
                '$path:${i + 1} serialises a DateTime for the database '
                'without toUtc(): ${line.trim()}',
          );
        }
      }
    });

    test('the diary lets Postgres stamp its own submission time', () {
      final source = File(
        'lib/features/bladder_diary/screens/bladder_diary_screen.dart',
      ).readAsStringSync();

      // The read path orders by it; only the write must not set it.
      expect(
        source,
        isNot(contains("'submitted_at':")),
        reason:
            'submitted_at defaults to now() in the column. The device clock '
            'is not the authority on when the server received a diary.',
      );
    });
  });

  test('the diary text fields are keyed per time slot', () {
    final source = File(
      'lib/features/bladder_diary/screens/bladder_diary_screen.dart',
    ).readAsStringSync();

    // These read `fieldKey: 'fluidType-\$day-\$slot'` — an escaped dollar
    // sign, so the key was the literal text rather than the day and slot, and
    // all 72 slots shared one. The lazy list then had nothing to tell one
    // hour's field from another's.
    expect(
      source,
      isNot(contains(r'-\$day-\$slot')),
      reason: 'the day and slot must be interpolated, not escaped',
    );
    for (final field in ['amountMlCups', 'fluidType', 'mlOrLeak']) {
      expect(source, contains("fieldKey: '$field-\$day-\$slot'"));
    }
  });
}
