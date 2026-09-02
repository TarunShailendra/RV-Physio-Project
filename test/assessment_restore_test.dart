import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/core/utils/supabase_row.dart';
import 'package:telerehab_app/features/assessment/models/iciq_model.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/assessment/models/iqol_model.dart';

/// Covers the row -> model mapping that AssessmentSummaryNotifier
/// .checkCompletedAssessments() relies on to restore a patient's answers.
///
/// Before this was fixed, that method selected only `id` and rebuilt each
/// questionnaire from constants, so every restart replaced real answers with
/// placeholders. The tests below pin the real values down.
void main() {
  group('ICIQ restore', () {
    test('restores the stored answers rather than zeros', () {
      final model = ICIQModel.fromSupabaseRow({
        'leak_frequency': 3,
        'leak_amount': 2,
        'life_interference': 7,
        'when_leaks': ['before toilet', 'cough or sneeze'],
      });

      expect(model.leakFrequency, 3);
      expect(model.leakAmount, 2);
      expect(model.lifeInterference, 7);
      expect(model.whenLeaks, ['before toilet', 'cough or sneeze']);
      expect(model.iciqScore, 12);
      expect(model.severityBand, 'moderate');
    });

    test(
      'regression: the old placeholder scored 0 / mild for every patient',
      () {
        const fabricated = ICIQModel(
          leakFrequency: 0,
          leakAmount: 0,
          lifeInterference: 0,
        );
        expect(fabricated.iciqScore, 0);
        expect(fabricated.severityBand, 'mild');

        final restored = ICIQModel.fromSupabaseRow({
          'leak_frequency': 5,
          'leak_amount': 3,
          'life_interference': 9,
          'when_leaks': <String>[],
        });
        expect(restored.iciqScore, 17);
        expect(restored.severityBand, 'severe');
      },
    );

    test('tolerates a null when_leaks column', () {
      final model = ICIQModel.fromSupabaseRow({
        'leak_frequency': 1,
        'leak_amount': 1,
        'life_interference': 1,
        'when_leaks': null,
      });
      expect(model.whenLeaks, isEmpty);
    });
  });

  group('IPAQ restore', () {
    Map<String, dynamic> row({
      int walkDays = 0,
      int walkMins = 0,
      int moderateDays = 0,
      int moderateMins = 0,
      int vigorousDays = 0,
      int vigorousMins = 0,
    }) => {
      'sitting_hours': 6,
      'sitting_mins': 30,
      'walk_days': walkDays,
      'walk_hours': 0,
      'walk_mins': walkMins,
      'moderate_days': moderateDays,
      'moderate_hours': 0,
      'moderate_mins': moderateMins,
      'vigorous_days': vigorousDays,
      'vigorous_hours': 0,
      'vigorous_mins': vigorousMins,
    };

    test('restores the stored answers', () {
      final model = IPAQModel.fromSupabaseRow(
        row(walkDays: 5, walkMins: 40, moderateDays: 3, moderateMins: 30),
      );

      expect(model.sittingHours, 6);
      expect(model.sittingMins, 30);
      expect(model.walkDays, 5);
      expect(model.walkMins, 40);
      expect(model.moderateDays, 3);
      expect(model.totalWalkMins, 40);
    });

    test('recomputes activity_level, which is never persisted', () {
      // Old behaviour restored a bare IPAQModel(): all zeros, always "low".
      expect(const IPAQModel().activityLevel, IPAQActivityLevel.low);

      final moderate = IPAQModel.fromSupabaseRow(
        row(vigorousDays: 3, vigorousMins: 30),
      );
      expect(moderate.activityLevel, IPAQActivityLevel.moderate);

      final high = IPAQModel.fromSupabaseRow(
        row(vigorousDays: 5, vigorousMins: 60),
      );
      expect(high.activityLevel, IPAQActivityLevel.high);

      final low = IPAQModel.fromSupabaseRow(row());
      expect(low.activityLevel, IPAQActivityLevel.low);
    });

    test('classifier matches the original IpaqNotifier rules', () {
      // vigorous >= 3 days and >= 1500 MET-min  -> high
      expect(
        IPAQModel.fromSupabaseRow(
          row(vigorousDays: 3, vigorousMins: 63),
        ).activityLevel,
        IPAQActivityLevel.high,
      );
      // 7+ active days and >= 3000 MET-min      -> high
      expect(
        IPAQModel.fromSupabaseRow(
          row(walkDays: 7, walkMins: 130, moderateDays: 0, vigorousDays: 0),
        ).activityLevel,
        IPAQActivityLevel.high,
      );
      // moderate >= 5 days and >= 30 min        -> moderate
      expect(
        IPAQModel.fromSupabaseRow(
          row(moderateDays: 5, moderateMins: 30),
        ).activityLevel,
        IPAQActivityLevel.moderate,
      );
      // walking >= 5 days and >= 30 min         -> moderate
      expect(
        IPAQModel.fromSupabaseRow(row(walkDays: 5, walkMins: 30)).activityLevel,
        IPAQActivityLevel.moderate,
      );
      // below every threshold                   -> low
      expect(
        IPAQModel.fromSupabaseRow(row(walkDays: 2, walkMins: 10)).activityLevel,
        IPAQActivityLevel.low,
      );
    });
  });

  group('IQOL restore', () {
    Map<String, dynamic> rowWithItems(List<int> items) => {
      for (var i = 0; i < IQOLModel.itemColumns.length; i++)
        IQOLModel.itemColumns[i]: items[i],
      'duration_years': 2,
      'duration_months': 6,
      'severity': 3,
      'stress_leak': true,
      'urge_leak': false,
      'freq_code': 2,
    };

    test('restores all 22 items and the background answers', () {
      final model = IQOLModel.fromSupabaseRow(
        rowWithItems(List<int>.filled(22, 4)),
      );

      expect(model.items.length, 22);
      expect(model.items.every((i) => i == 4), isTrue);
      expect(model.durationYears, 2);
      expect(model.durationMonths, 6);
      expect(model.severity, 3);
      expect(model.stressLeak, isTrue);
      expect(model.urgeLeak, isFalse);
      expect(model.freqCode, 2);
      expect(model.isComplete, isTrue);
      expect(model.score, 75.0);
    });

    test('items are restored in questionnaire order', () {
      final ascending = List<int>.generate(22, (i) => (i % 5) + 1);
      final model = IQOLModel.fromSupabaseRow(rowWithItems(ascending));
      expect(model.items, ascending);
    });

    test('regression: the old placeholder scored 0 for every patient', () {
      // checkCompletedAssessments used to restore 22 ones, which scores 0 and
      // sent recommendedStartWeek down its "low quality of life" branch on
      // every launch.
      final fabricated = IQOLModel(items: List<int>.filled(22, 1));
      expect(fabricated.score, 0.0);

      final restored = IQOLModel.fromSupabaseRow(
        rowWithItems(List<int>.filled(22, 5)),
      );
      expect(restored.score, 100.0);
    });
  });

  group('row coercion', () {
    test('reads ints arriving as num or String', () {
      expect(asInt(3), 3);
      expect(asInt(3.0), 3);
      expect(asInt('3'), 3);
      expect(asInt(null), isNull);
      expect(asInt('abc'), isNull);
    });

    test('reads bools arriving as bool or Postgres text', () {
      expect(asBool(true), isTrue);
      expect(asBool('t'), isTrue);
      expect(asBool('false'), isFalse);
      expect(asBool(null), isFalse);
      expect(asBool(null, orElse: true), isTrue);
    });

    test('reads jsonb arrays, defaulting to empty', () {
      expect(asStringList(['a', 'b']), ['a', 'b']);
      expect(asStringList(null), isEmpty);
      expect(asStringList('not a list'), isEmpty);
    });
  });
}
