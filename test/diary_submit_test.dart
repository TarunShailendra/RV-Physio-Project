import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/features/bladder_diary/screens/bladder_diary_screen.dart';
import 'package:telerehab_app/l10n/app_localizations.dart';

/// Covers the bladder diary telling the truth about whether it saved.
///
/// _submitDiary skipped the insert entirely when there was no user id, and
/// caught any failure into a debugPrint — then fell through to the "Diary
/// Submitted" dialog with a green check either way. A patient whose session
/// had lapsed spent three days logging a diary and was told it was saved.
///
/// Every request in this suite fails, so submitting always takes the failure
/// path. That is the case that used to be indistinguishable from success.
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

  Future<void> pumpDiary(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BladderDiaryScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a failed save does not show the success dialog', (tester) async {
    await pumpDiary(tester);

    final submit = find.text('Submit 3-Day Diary');
    expect(submit, findsOneWidget);

    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(
      find.text('Diary Submitted'),
      findsNothing,
      reason: 'the save failed, so success must not be claimed',
    );
    expect(
      find.text('Your 3-day bladder diary has been recorded successfully.'),
      findsNothing,
    );
  });

  testWidgets('a failed save says so, and offers a retry', (tester) async {
    await pumpDiary(tester);

    await tester.tap(find.text('Submit 3-Day Diary'));
    await tester.pumpAndSettle();

    // No session in this suite, so the sign-in message is the expected one.
    expect(
      find.text('Your session has ended. Sign in again to save your diary.'),
      findsOneWidget,
      reason: 'the patient must be told the diary was not saved',
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a failed save keeps the patient on the diary', (tester) async {
    await pumpDiary(tester);

    await tester.tap(find.text('Submit 3-Day Diary'));
    await tester.pumpAndSettle();

    expect(
      find.byType(BladderDiaryScreen),
      findsOneWidget,
      reason: 'entries are held only in memory, so navigating away loses them',
    );
    // The three day tabs are still there to go back to.
    expect(find.byType(TabBar), findsOneWidget);
  });
}
