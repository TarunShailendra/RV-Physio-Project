import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../exercise_notifier.dart';
import '../models/exercise_model.dart';
import '../videos/demo_playback.dart';
import '../videos/demo_video_player.dart';

/// The animated demonstration at the top of the detail sheet, played in step
/// with the exercise timer. Collapses to nothing when the exercise has no
/// video or the video fails to load, leaving the sheet as it was.
class ExerciseDemoVideo extends StatefulWidget {
  const ExerciseDemoVideo({super.key, required this.session});

  final ExerciseSession session;

  @override
  State<ExerciseDemoVideo> createState() => _ExerciseDemoVideoState();
}

class _ExerciseDemoVideoState extends State<ExerciseDemoVideo> {
  DemoVideoPlayer? _player;
  bool _loaded = false;
  bool _failed = false;
  bool _disposed = false;

  /// What the timer wants now, and what has been applied to the player.
  DemoCommand? _wanted;
  DemoCommand? _applied;
  bool _frameQueued = false;

  /// Bumped whenever a newer command supersedes the one being applied, so a
  /// slow seek from an old command cannot go on to play over a newer one.
  int _generation = 0;
  VoidCallback? _segmentListener;

  @override
  void initState() {
    super.initState();
    final video = context.read<ExerciseNotifier>().currentVideo;
    if (video == null) return;
    final player = newDemoVideoPlayer();
    _player = player;
    _load(player, video.asset);
  }

  Future<void> _load(DemoVideoPlayer player, String asset) async {
    try {
      await player.load(asset);
    } catch (_) {
      _failed = true;
      if (identical(_player, player)) _player = null;
      _generation++;
      // Collapse first: when the platform throws before a player exists,
      // video_player's dispose waits forever, so awaiting it would leave an
      // empty box above the instructions.
      if (mounted) setState(() {});
      _quietly(player.dispose());
      return;
    }
    if (_disposed) return;
    _loaded = true;
    if (mounted) setState(() {});
    _applyWanted();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _detachSegmentListener();
    final player = _player;
    _player = null;
    if (player != null) _quietly(player.dispose());
    super.dispose();
  }

  /// Runs a player call whose result nothing waits on, so a player error
  /// never surfaces as an uncaught async error.
  void _quietly(Future<void> call) => unawaited(call.catchError((_) {}));

  void _detachSegmentListener() {
    final listener = _segmentListener;
    if (listener != null) _player?.changes.removeListener(listener);
    _segmentListener = null;
  }

  /// Records the command and applies it after the frame, so a phase that is
  /// replaced within the same frame (a zero-length movement) is never started.
  void _want(DemoCommand command) {
    _wanted = command;
    if (_frameQueued) return;
    _frameQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _frameQueued = false;
      if (_disposed) return;
      _applyWanted();
    });
  }

  Future<void> _applyWanted() async {
    final command = _wanted;
    final player = _player;
    if (command == null || player == null || !_loaded || _failed) return;
    if (command == _applied) return;
    _applied = command;
    final generation = ++_generation;
    bool stale() => _disposed || generation != _generation;

    _detachSegmentListener();
    try {
      switch (command) {
        case LoopWhole():
          await player.setLooping(true);
          if (stale()) return;
          await player.play();
        case PlaySegment(:final start, :final end):
          await player.setLooping(false);
          if (stale()) return;
          await player.seekTo(start);
          if (stale()) return;
          void onChange() {
            if (stale()) return;
            if (player.position >= end) {
              _detachSegmentListener();
              _quietly(player.pause());
            }
          }

          _segmentListener = onChange;
          player.changes.addListener(onChange);
          await player.play();
        case ShowFrame(:final at):
          await player.setLooping(false);
          if (stale()) return;
          await player.pause();
          if (stale()) return;
          await player.seekTo(at);
        case Freeze():
          await player.pause();
      }
    } catch (_) {
      // A player error must never reach the patient or the timer.
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ExerciseNotifier>();
    final video = notifier.currentVideo;
    final player = _player;
    if (video == null || _failed || player == null) {
      return const SizedBox.shrink();
    }

    final side =
        video.sides[notifier.currentSideIndex.clamp(0, video.sides.length - 1)];
    _want(
      demoCommandFor(
        phase: notifier.phase,
        isTimerRunning: notifier.isTimerRunning,
        isHeld: widget.session.holdSeconds != null,
        side: side,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: _loaded && player.isReady
              ? player.buildView()
              : ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
        ),
      ),
    );
  }
}
