import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/features/assessment/notifiers/assessment_summary_notifier.dart';
import 'package:telerehab_app/features/assessment/notifiers/iciq_notifier.dart';
import 'package:telerehab_app/features/assessment/notifiers/ipaq_notifier.dart';
import 'package:telerehab_app/features/assessment/notifiers/iqol_notifier.dart';
import 'package:telerehab_app/features/assessment/screens/iciq_screen.dart';
import 'package:telerehab_app/features/assessment/screens/ipaq_screen.dart';
import 'package:telerehab_app/features/assessment/screens/iqol_screen.dart';
import 'package:telerehab_app/features/dashboard/dashboard_notifier.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';
import 'package:telerehab_app/l10n/app_localizations.dart';

/// The three questionnaires must render without throwing.
///
/// The ICIQ screen wrapped each step in IntrinsicHeight while the first three
/// steps returned an Expanded as their root. Expanded requires a Flex
/// ancestor, so Flutter threw "Incorrect use of ParentDataWidget" — a red
/// error screen on the questionnaire every new patient is sent to first, and
/// invisible to flutter analyze.
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

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => IciqNotifier()),
          ChangeNotifierProvider(create: (_) => IpaqNotifier()),
          ChangeNotifierProvider(create: (_) => IqolNotifier()),
          ChangeNotifierProvider(create: (_) => AssessmentSummaryNotifier()),
          ChangeNotifierProvider(create: (_) => DashboardNotifier()),
          ChangeNotifierProvider(create: (_) => ExerciseNotifier()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the ICIQ screen renders its first step', (tester) async {
    await pumpScreen(tester, const IciqScreen());
    expect(tester.takeException(), isNull);
    expect(find.byType(IciqScreen), findsOneWidget);
  });

  testWidgets('the ICIQ screen renders every step', (tester) async {
    await pumpScreen(tester, const IciqScreen());

    // Answer each step and advance, so the slider steps and the checkbox step
    // are all built. The first three used to be the broken ones.
    final iciq = tester
        .element(find.byType(IciqScreen))
        .read<IciqNotifier>();

    iciq.setLeakFrequency(3);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'leak amount step');

    iciq.setLeakAmount(2);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'interference step');

    iciq.setLifeInterference(7);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'when-leaks step');

    iciq.toggleWhenLeak('x');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'result step');
  });

  testWidgets('the IPAQ screen renders its first step', (tester) async {
    await pumpScreen(tester, const IpaqScreen());
    expect(tester.takeException(), isNull);
    expect(find.byType(IpaqScreen), findsOneWidget);
  });

  testWidgets('the I-QOL screen renders its first page', (tester) async {
    await pumpScreen(tester, const IqolScreen());
    expect(tester.takeException(), isNull);
    expect(find.byType(IqolScreen), findsOneWidget);
  });
}
