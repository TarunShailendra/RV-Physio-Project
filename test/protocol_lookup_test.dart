import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

void main() {
  test('every severity and activity pair resolves to a protocol', () {
    for (final band in ['mild', 'moderate', 'severe']) {
      for (final activity in IPAQActivityLevel.values) {
        final p = protocolFor(severityBand: band, activity: activity);
        expect(p.blocks.length, 4, reason: '$band/$activity');
      }
    }
  });

  test('all three severe cells share the one severe protocol', () {
    final ids = IPAQActivityLevel.values
        .map((a) => protocolFor(severityBand: 'severe', activity: a).id)
        .toSet();
    expect(ids, {'severe'});
  });

  test('mild and moderate differ by activity level', () {
    expect(
      protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.high).id,
      'mild_high',
    );
    expect(
      protocolFor(severityBand: 'mild', activity: IPAQActivityLevel.low).id,
      'mild_low',
    );
    expect(
      protocolFor(
        severityBand: 'moderate',
        activity: IPAQActivityLevel.moderate,
      ).id,
      'moderate_moderate',
    );
  });

  test('a missing questionnaire falls back to the gentlest protocol', () {
    expect(
      protocolFor(severityBand: null, activity: IPAQActivityLevel.high).id,
      'severe',
    );
    expect(protocolFor(severityBand: 'mild', activity: null).id, 'severe');
    expect(protocolFor(severityBand: 'nonsense', activity: null).id, 'severe');
    expect(protocolFor().id, 'severe');
  });
}
