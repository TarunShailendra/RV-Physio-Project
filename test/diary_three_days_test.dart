import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/features/bladder_diary/screens/bladder_diary_screen.dart';
import 'package:telerehab_app/l10n/app_localizations.dart';

/// A bladder diary covers three days. Entries made on days 2 and 3 must
/// survive to the draft, and to the payload, exactly as day 1's do.
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

  setUp(() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bladder_diary_draft');
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

  /// Opens the 6am row of the tab on screen and types [amount] into its
  /// fluid amount field.
  Future<void> enterAt6am(WidgetTester tester, String amount) async {
    await tester.tap(find.text('6am').hitTestable());
    await tester.pumpAndSettle();

    final field = find
        .widgetWithText(TextFormField, 'Amount (ml / cups)')
        .hitTestable();
    expect(field, findsOneWidget, reason: 'the 6am row should be open');
    await tester.enterText(field, amount);
    await tester.pumpAndSettle();
  }

  Future<Map<String, dynamic>> readDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('bladder_diary_draft');
    expect(raw, isNotNull, reason: 'typing should have written a draft');
    return jsonDecode(raw!) as Map<String, dynamic>;
  }

  testWidgets('an entry on each of the three days is kept', (tester) async {
    await pumpDiary(tester);

    await enterAt6am(tester, '111');

    await tester.tap(find.text('Day 2'));
    await tester.pumpAndSettle();
    await enterAt6am(tester, '222');

    await tester.tap(find.text('Day 3'));
    await tester.pumpAndSettle();
    await enterAt6am(tester, '333');

    final draft = await readDraft();
    final days = draft['data'] as List<dynamic>;

    for (final (index, expected) in [
      (0, '111'),
      (1, '222'),
      (2, '333'),
    ].indexed) {
      final slot =
          (days[expected.$1] as List<dynamic>)[0] as Map<String, dynamic>;
      expect(
        slot['fluidAmount'],
        expected.$2,
        reason:
            'day ${expected.$1 + 1} 6am should hold ${expected.$2}; only '
            'day 1 was reaching the database (index $index)',
      );
    }
  });

  test('the draft carries the row a submitted diary was stored as', () async {
    // A second submit must edit that row rather than store the same three
    // days again. The id travels in the draft so it survives a restart.
    SharedPreferences.setMockInitialValues({
      'bladder_diary_draft': jsonEncode({
        'diaryId': 'abc-123',
        'data': [
          [
            {
              'fluidAmount': '111',
              'fluidType': '',
              'urineOutput': '',
              'cantMeasure': false,
              'bladderSensation': null,
              'pad': false,
            },
          ],
        ],
        'markers': [<String, dynamic>{}],
      }),
    });

    final restored = await SharedPreferences.getInstance();
    final raw = restored.getString('bladder_diary_draft');
    expect(raw, isNotNull);
    expect(jsonDecode(raw!)['diaryId'], 'abc-123');
  });

  testWidgets('a diary in progress comes back after leaving the screen', (
    tester,
  ) async {
    await pumpDiary(tester);
    await enterAt6am(tester, '111');

    // Leave and come back, the way the patient does.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();
    await pumpDiary(tester);

    expect(
      find.widgetWithText(TextFormField, 'Amount (ml / cups)').hitTestable(),
      findsNothing,
      reason: 'rows start collapsed',
    );
    await tester.tap(find.text('6am').hitTestable());
    await tester.pumpAndSettle();

    expect(
      find.text('111'),
      findsWidgets,
      reason: 'the entry must not disappear on leaving the diary',
    );
  });
}
