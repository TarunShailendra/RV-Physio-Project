import '../models/protocol.dart';
import '../protocols/exercise_catalogue.dart' show isPfmt;
import 'exercise_videos.g.dart';

/// One repetition's worth of footage inside a video file: the movement into
/// the hold position, a still hold frame, and the movement back out.
class VideoSide {
  const VideoSide({
    required this.intoStartMs,
    required this.holdMs,
    required this.outStartMs,
    required this.outEndMs,
  });

  final int intoStartMs;
  final int holdMs;
  final int outStartMs;
  final int outEndMs;

  Duration get intoDuration => Duration(milliseconds: holdMs - intoStartMs);
  Duration get outDuration => Duration(milliseconds: outEndMs - outStartMs);
}

class ExerciseVideo {
  const ExerciseVideo({
    required this.id,
    required this.exerciseKey,
    required this.position,
    required this.asset,
    required this.durationMs,
    required this.sides,
  });

  final String id;
  final String exerciseKey;
  final ExercisePosition? position;
  final String asset;
  final int durationMs;
  final List<VideoSide> sides;

  bool get alternates => sides.length == 2;

  /// Reps are 1-based. Alternating videos go A, B, A, B...
  VideoSide sideForRep(int rep) =>
      alternates && rep.isEven ? sides[1] : sides[0];
}

/// The video for [exerciseKey] in [position]. A PFMT key with no position
/// resolves to the supine video. Unknown keys return null.
ExerciseVideo? videoFor(String exerciseKey, ExercisePosition? position) {
  final wanted =
      position ?? (isPfmt(exerciseKey) ? ExercisePosition.supine : null);
  for (final v in exerciseVideos.values) {
    if (v.exerciseKey == exerciseKey && v.position == wanted) return v;
  }
  // Non-positional exercises: tolerate a video whose position is set.
  if (wanted == null) {
    for (final v in exerciseVideos.values) {
      if (v.exerciseKey == exerciseKey) return v;
    }
  }
  return null;
}
