import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/exercise/models/protocol.dart';
import 'package:telerehab_app/features/exercise/videos/exercise_video.dart';
import 'package:telerehab_app/features/exercise/videos/exercise_videos.g.dart';

void main() {
  test('every video has its asset on disk and listed in pubspec', () {
    for (final v in exerciseVideos.values) {
      expect(File(v.asset).existsSync(), isTrue, reason: v.asset);
    }
    expect(File('pubspec.yaml').readAsStringSync(), contains('assets/videos/'));
  });

  test('segments are ordered and inside the video', () {
    for (final v in exerciseVideos.values) {
      for (var i = 0; i < v.sides.length; i++) {
        final s = v.sides[i];
        expect(s.intoStartMs, greaterThanOrEqualTo(0));
        expect(s.intoStartMs, lessThan(s.holdMs));
        expect(s.holdMs, lessThanOrEqualTo(s.outStartMs));
        expect(s.outStartMs, lessThan(s.outEndMs));
        expect(s.outEndMs, lessThanOrEqualTo(v.durationMs));
        if (i > 0) {
          expect(s.intoStartMs,
              greaterThanOrEqualTo(v.sides[i - 1].outEndMs));
        }
      }
    }
  });

  test('the bridge resolves to its video', () {
    final v = videoFor('pelvic_bridging', null)!;
    expect(v.id, 'pelvic_bridging');
    final s = v.sides.single;
    expect(s.intoStartMs, 400);
    expect(s.holdMs, 1700);
    expect(s.outStartMs, 2500);
    expect(s.outEndMs, 4000);
    expect(v.durationMs, 4400);
    expect(s.intoDuration, const Duration(milliseconds: 1300));
    expect(s.outDuration, const Duration(milliseconds: 1500));
  });

  test('PFMT videos resolve by position', () {
    for (final key in ['pfmt_slow', 'pfmt_quick']) {
      for (final pos in [
        ExercisePosition.supine,
        ExercisePosition.sitting,
        ExercisePosition.standing,
      ]) {
        expect(videoFor(key, pos)!.id, '${key}_${pos.name}');
      }
    }
    expect(videoFor('pfmt_quick', null)!.id, 'pfmt_quick_supine');
    expect(videoFor('diaphragmatic_breathing', null)!.id,
        'diaphragmatic_breathing');
  });

  test('an unknown exercise has no video', () {
    expect(videoFor('no_such_exercise', null), isNull);
  });

  test('alternating videos pick a side by rep', () {
    const a = VideoSide(intoStartMs: 0, holdMs: 10, outStartMs: 20, outEndMs: 30);
    const b = VideoSide(intoStartMs: 40, holdMs: 50, outStartMs: 60, outEndMs: 70);
    const v = ExerciseVideo(
      id: 'x',
      exerciseKey: 'x',
      position: ExercisePosition.supine,
      asset: 'x.mp4',
      durationMs: 80,
      sides: [a, b],
    );
    expect(v.alternates, isTrue);
    expect(v.sideForRep(1), same(v.sides[0]));
    expect(v.sideForRep(2), same(v.sides[1]));
    expect(v.sideForRep(5), same(v.sides[0]));
  });
}
