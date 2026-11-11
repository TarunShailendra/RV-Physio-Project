import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

/// The little of a video player the demonstration needs. A seam: tests swap
/// in a fake because `video_player` cannot play under `flutter test`.
abstract class DemoVideoPlayer {
  Future<void> load(String asset);
  Future<void> play();
  Future<void> pause();
  Future<void> seekTo(Duration at);
  Future<void> setLooping(bool looping);
  Duration get position;

  /// Notifies as the position moves.
  Listenable get changes;
  bool get isReady;
  double get aspectRatio;
  Widget buildView();
  Future<void> dispose();
}

class VideoPlayerDemo implements DemoVideoPlayer {
  VideoPlayerController? _controller;

  @override
  Future<void> load(String asset) async {
    final controller = VideoPlayerController.asset(asset);
    _controller = controller;
    await controller.initialize();
    await controller.setVolume(0);
  }

  @override
  Future<void> play() async => _controller?.play();

  @override
  Future<void> pause() async => _controller?.pause();

  @override
  Future<void> seekTo(Duration at) async => _controller?.seekTo(at);

  @override
  Future<void> setLooping(bool looping) async =>
      _controller?.setLooping(looping);

  @override
  Duration get position => _controller?.value.position ?? Duration.zero;

  @override
  Listenable get changes => _controller ?? const _Never();

  @override
  bool get isReady => _controller?.value.isInitialized ?? false;

  @override
  double get aspectRatio => _controller?.value.aspectRatio ?? 16 / 9;

  @override
  Widget buildView() => VideoPlayer(_controller!);

  @override
  Future<void> dispose() async => _controller?.dispose();
}

class _Never implements Listenable {
  const _Never();

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

@visibleForTesting
DemoVideoPlayer Function() createDemoVideoPlayer = VideoPlayerDemo.new;

/// What the app calls to get a player; goes through [createDemoVideoPlayer] so
/// tests can substitute one.
DemoVideoPlayer newDemoVideoPlayer() => createDemoVideoPlayer();
