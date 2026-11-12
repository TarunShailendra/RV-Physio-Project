import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/content/exercise_content.dart';
import 'package:telerehab_app/features/exercise/protocols/exercise_catalogue.dart';

void main() {
  test('every catalogued exercise has content', () {
    for (final key in exerciseCatalogue.keys) {
      expect(exerciseContent.containsKey(key), isTrue, reason: key);
    }
  });

  test('content is not supplied for exercises nothing prescribes', () {
    for (final key in exerciseContent.keys) {
      expect(exerciseCatalogue.containsKey(key), isTrue, reason: key);
    }
  });

  test('every description is usable', () {
    for (final entry in exerciseContent.entries) {
      final en = entry.value.en;
      expect(en.startingPosition.trim(), isNotEmpty, reason: entry.key);
      expect(en.steps, isNotEmpty, reason: entry.key);
      expect(en.dos, isNotEmpty, reason: entry.key);
      expect(en.donts, isNotEmpty, reason: entry.key);
    }
  });

  test('Kannada falls back to English until it is translated', () {
    final content = exerciseContent['pelvic_bridging']!;
    expect(content.kn, isNull);
    expect(content.forLocale('kn'), same(content.en));
    expect(content.forLocale('en'), same(content.en));
  });

  test('the general safety rules are present', () {
    expect(generalDos.length, greaterThanOrEqualTo(6));
    expect(generalDonts.length, greaterThanOrEqualTo(4));
  });
}
