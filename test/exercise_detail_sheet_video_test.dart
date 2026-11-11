import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';
import 'package:telerehab_app/features/exercise/screens/exercise_detail_sheet.dart';
import 'package:telerehab_app/features/exercise/videos/demo_video_player.dart';
import 'package:telerehab_app/l10n/app_localizations.dart';

class FakeDemoVideoPlayer implements DemoVideoPlayer {
  FakeDemoVideoPlayer({this.failLoad = false});

  final bool failLoad;
  final calls = <String>[];
  final _changes = ChangeNotifier();
  bool disposed = false;
  Duration _position = Duration.zero;

  @override
  Future<void> load(String asset) async {
    calls.add('load $asset');
    if (failLoad) throw Exception('cannot load');
  }

  @override
  Future<void> play() async => calls.add('play');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> seekTo(Duration at) async {
    calls.add('seekTo ${at.inMilliseconds}');
    _position = at;
  }

  @override
  Future<void> setLooping(bool looping) async => calls.add('loop $looping');

  @override
  Duration get position => _position;

  @override
  Listenable get changes => _changes;

  @override
  bool get isReady => !failLoad;

  @override
  double get aspectRatio => 16 / 9;

  @override
  Widget buildView() => const SizedBox(key: Key('fake-video'));

  @override
  Future<void> dispose() async {
    disposed = true;
    calls.add('dispose');
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:1',
      anonKey: 'test-anon-key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        autoRefreshToken: false,
      ),
    );
  });

  final original = createDemoVideoPlayer;
  late FakeDemoVideoPlayer fake;

  setUp(() => fake = FakeDemoVideoPlayer());
  tearDown(() => createDemoVideoPlayer = original);

  /// Pumps a button that opens the sheet for week 1 item [index].
  Future<ExerciseNotifier> openSheet(
    WidgetTester tester,
    int index, {
    ExerciseNotifier? notifier,
  }) async {
    notifier ??= ExerciseNotifier();
    notifier.loadWeek(1);
    await tester.pumpWidget(
      ChangeNotifierProvider<ExerciseNotifier>.value(
        value: notifier,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showExerciseDetail(
                  context,
                  notifier!.currentPlan!.days[0].sessions[index],
                  0,
                  index,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return notifier;
  }

  Future<void> scrollToStart(WidgetTester tester) => tester.scrollUntilVisible(
    find.byIcon(Icons.play_arrow),
    300,
    scrollable: find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    ),
  );

  testWidgets('the sheet shows the video above the exercise name', (
    tester,
  ) async {
    createDemoVideoPlayer = () => fake;
    await openSheet(tester, 3);

    final video = find.byKey(const Key('fake-video'));
    expect(video, findsOneWidget);
    expect(
      tester.getTopLeft(video).dy,
      lessThan(tester.getTopLeft(find.text('Pelvic bridging')).dy),
    );
    expect(fake.calls.first, 'load assets/videos/pelvic_bridging.mp4');
  });

  testWidgets('the sheet shows no video when none exists', (tester) async {
    createDemoVideoPlayer = () => fake;
    await openSheet(
      tester,
      3,
      notifier: ExerciseNotifier(videoLookup: (_, _) => null),
    );

    expect(find.byKey(const Key('fake-video')), findsNothing);
    expect(fake.calls, isEmpty);
    await tester.scrollUntilVisible(
      find.text('Mark as done'),
      300,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Mark as done'), findsOneWidget);
  });

  testWidgets('a video that fails to load leaves the sheet as before', (
    tester,
  ) async {
    fake = FakeDemoVideoPlayer(failLoad: true);
    createDemoVideoPlayer = () => fake;
    await openSheet(tester, 3);

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('fake-video')), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Mark as done'),
      300,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('Mark as done'), findsOneWidget);
  });

  testWidgets('closing the sheet while the timer runs disposes cleanly', (
    tester,
  ) async {
    createDemoVideoPlayer = () => fake;
    final notifier = await openSheet(tester, 3);

    await scrollToStart(tester);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(const Duration(milliseconds: 100));
    expect(notifier.isTimerRunning, isTrue);

    Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));

    expect(tester.takeException(), isNull);
    expect(fake.disposed, isTrue);
    notifier.pauseTimer();
  });

  testWidgets('starting the timer plays into the hold', (tester) async {
    createDemoVideoPlayer = () => fake;
    final notifier = await openSheet(tester, 3);

    await scrollToStart(tester);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.pump();

    final seek = fake.calls.lastIndexOf('seekTo 400');
    expect(seek, isNonNegative);
    expect(fake.calls.sublist(seek), contains('play'));
    notifier.pauseTimer();
  });

  testWidgets('opening an item selects it for the timer', (tester) async {
    createDemoVideoPlayer = () => fake;
    final notifier = ExerciseNotifier()..loadWeek(1);
    expect(notifier.currentSession!.exerciseKey, isNot('pelvic_bridging'));

    await openSheet(tester, 3, notifier: notifier);

    expect(notifier.currentSession!.exerciseKey, 'pelvic_bridging');
  });

  testWidgets('reopening the same item keeps a running timer', (tester) async {
    createDemoVideoPlayer = () => FakeDemoVideoPlayer();
    final notifier = await openSheet(tester, 3);
    await scrollToStart(tester);
    await tester.pump();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump(const Duration(milliseconds: 100));
    final phase = notifier.phase;
    expect(notifier.isTimerRunning, isTrue);

    Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pump();

    expect(notifier.isTimerRunning, isTrue);
    expect(notifier.phase, phase);
    expect(notifier.currentRep, 1);
    notifier.pauseTimer();
    await tester.pumpAndSettle();
  });

  testWidgets('opening a different item selects and resets', (tester) async {
    createDemoVideoPlayer = () => FakeDemoVideoPlayer();
    final notifier = await openSheet(tester, 3);
    expect(notifier.currentSessionIndex, 3);
    Navigator.of(tester.element(find.byType(Scaffold).first)).pop();
    await tester.pumpAndSettle();

    final context = tester.element(find.text('open'));
    showExerciseDetail(
      context,
      notifier.currentPlan!.days[0].sessions[0],
      0,
      0,
    );
    await tester.pumpAndSettle();

    expect(notifier.currentSessionIndex, 0);
  });

  testWidgets('the video stays mounted while scrolling to the timer', (
    tester,
  ) async {
    createDemoVideoPlayer = () => fake;
    await openSheet(tester, 3);

    await scrollToStart(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('fake-video')), findsOneWidget);
    expect(fake.disposed, isFalse);
    expect(fake.calls.where((c) => c.startsWith('load')).length, 1);
  });

  testWidgets(
    'a sheet with little height does not overflow and keeps the video',
    (tester) async {
      createDemoVideoPlayer = () => fake;
      // A short window leaves the sheet less height than an uncapped 16:9
      // video needs, as dragging the sheet to its minimum does on a phone.
      tester.view.physicalSize = const Size(360, 200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await openSheet(tester, 3);

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('fake-video')), findsOneWidget);
    },
  );

  testWidgets('on a wide surface the video is at most 40% of the sheet', (
    tester,
  ) async {
    createDemoVideoPlayer = () => fake;
    tester.view.physicalSize = const Size(1600, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await openSheet(tester, 3);

    final video = tester.getSize(find.byKey(const Key('fake-video')));
    final body = tester.getSize(find.byType(LayoutBuilder).last);
    expect(video.height, lessThanOrEqualTo(body.height * 0.4));
    expect(video.width / video.height, closeTo(16 / 9, 0.01));
    expect(tester.takeException(), isNull);
  });
}
