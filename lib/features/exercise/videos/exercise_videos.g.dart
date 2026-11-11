// GENERATED FILE - DO NOT EDIT BY HAND.
// Written by tool/exercise_videos/render.py from the video specs.

import '../models/protocol.dart';
import 'exercise_video.dart';

const Map<String, ExerciseVideo> exerciseVideos = {
  'pelvic_bridging': ExerciseVideo(
    id: 'pelvic_bridging',
    exerciseKey: 'pelvic_bridging',
    position: ExercisePosition.supine,
    asset: 'assets/videos/pelvic_bridging.mp4',
    durationMs: 4400,
    sides: [
      VideoSide(
        intoStartMs: 400,
        holdMs: 1700,
        outStartMs: 2500,
        outEndMs: 4000,
      ),
    ],
  ),
};
