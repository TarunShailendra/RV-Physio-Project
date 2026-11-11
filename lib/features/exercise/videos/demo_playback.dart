import '../exercise_notifier.dart';
import 'exercise_video.dart';

/// What the demonstration video should be doing. Pure data: the widget turns
/// it into player calls, so the mapping from timer phase to playback can be
/// tested without a player.
sealed class DemoCommand {
  const DemoCommand();
}

/// Loop the whole file: the preview before the timer starts, and the
/// demonstration for exercises that have no hold.
final class LoopWhole extends DemoCommand {
  const LoopWhole();

  @override
  bool operator ==(Object other) => other is LoopWhole;

  @override
  int get hashCode => (LoopWhole).hashCode;
}

/// Play from [start], then stop at [end].
final class PlaySegment extends DemoCommand {
  const PlaySegment(this.start, this.end);

  final Duration start;
  final Duration end;

  @override
  bool operator ==(Object other) =>
      other is PlaySegment && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'PlaySegment($start, $end)';
}

/// Seek to [at] and stay there.
final class ShowFrame extends DemoCommand {
  const ShowFrame(this.at);

  final Duration at;

  @override
  bool operator ==(Object other) => other is ShowFrame && other.at == at;

  @override
  int get hashCode => at.hashCode;

  @override
  String toString() => 'ShowFrame($at)';
}

/// Pause where the video is.
final class Freeze extends DemoCommand {
  const Freeze();

  @override
  bool operator ==(Object other) => other is Freeze;

  @override
  int get hashCode => (Freeze).hashCode;
}

DemoCommand demoCommandFor({
  required ExercisePhase phase,
  required bool isTimerRunning,
  required bool isHeld,
  required VideoSide side,
}) {
  if (!isHeld || phase == ExercisePhase.ready) return const LoopWhole();

  final moving =
      phase == ExercisePhase.moveIn ||
      phase == ExercisePhase.hold ||
      phase == ExercisePhase.moveOut ||
      phase == ExercisePhase.rest;
  if (!isTimerRunning && moving) return const Freeze();

  Duration ms(int v) => Duration(milliseconds: v);
  return switch (phase) {
    ExercisePhase.moveIn => PlaySegment(ms(side.intoStartMs), ms(side.holdMs)),
    ExercisePhase.hold => ShowFrame(ms(side.holdMs)),
    ExercisePhase.moveOut => PlaySegment(
      ms(side.outStartMs),
      ms(side.outEndMs),
    ),
    ExercisePhase.rest ||
    ExercisePhase.betweenReps ||
    ExercisePhase.finished => ShowFrame(ms(side.intoStartMs)),
    ExercisePhase.ready => const LoopWhole(),
  };
}
