import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/protocols/exercise_catalogue.dart';

void main() {
  test('the catalogue holds the sixteen exercises the document describes', () {
    expect(exerciseCatalogue.length, 16);
  });

  test('every exercise has a non-empty display name', () {
    for (final entry in exerciseCatalogue.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: entry.key);
    }
  });

  test('the two pelvic floor items are recognised as PFMT', () {
    expect(isPfmt('pfmt_slow'), isTrue);
    expect(isPfmt('pfmt_quick'), isTrue);
    expect(isPfmt('clamshells'), isFalse);
  });
}
