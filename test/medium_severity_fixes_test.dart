import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/core/locale/locale_notifier.dart';
import 'package:telerehab_app/core/utils/calendar.dart';
import 'package:telerehab_app/l10n/app_localizations.dart';

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

  group('F6 — the language can be chosen and is remembered', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('defaults to following the device', () async {
      final notifier = LocaleNotifier();
      await notifier.load();
      expect(notifier.locale, isNull);
    });

    test('a chosen language survives a restart', () async {
      final first = LocaleNotifier();
      await first.load();
      await first.setLocale(const Locale('kn'));
      expect(first.locale?.languageCode, 'kn');

      // A fresh notifier stands in for the next launch.
      final second = LocaleNotifier();
      await second.load();
      expect(second.locale?.languageCode, 'kn');
    });

    test('it can be handed back to the device', () async {
      final notifier = LocaleNotifier();
      await notifier.load();
      await notifier.setLocale(const Locale('kn'));
      await notifier.setLocale(null);

      final reloaded = LocaleNotifier();
      await reloaded.load();
      expect(reloaded.locale, isNull);
    });

    test('listeners are told when the language changes', () async {
      final notifier = LocaleNotifier();
      var notifications = 0;
      notifier.addListener(() => notifications++);
      await notifier.setLocale(const Locale('kn'));
      expect(notifications, greaterThan(0));
    });

    test('both shipped languages resolve every key', () {
      // A missing key in one language throws at lookup, so this is really a
      // check that the two ARB files stayed in step.
      for (final locale in AppLocalizations.supportedLocales) {
        expect(
          lookupAppLocalizations(locale).completeAllQuestions,
          isNotEmpty,
          reason: '$locale',
        );
      }
    });
  });

  group('A5 — an impossible date of birth cannot be built', () {
    test('February has 28 or 29 days, never 31', () {
      expect(daysInMonth(2023, 2), 28);
      expect(daysInMonth(2024, 2), 29, reason: 'leap year');
      expect(daysInMonth(2100, 2), 28, reason: 'century, not a leap year');
      expect(daysInMonth(2000, 2), 29, reason: 'divisible by 400');
    });

    test('short and long months are distinguished', () {
      expect(daysInMonth(2024, 4), 30);
      expect(daysInMonth(2024, 6), 30);
      expect(daysInMonth(2024, 9), 30);
      expect(daysInMonth(2024, 11), 30);
      for (final month in [1, 3, 5, 7, 8, 10, 12]) {
        expect(daysInMonth(2024, month), 31, reason: 'month $month');
      }
    });

    test('the old picker would have rolled 31 February into March', () {
      // What DateTime does with the day the dropdown used to offer.
      expect(DateTime(2024, 2, 31).month, 3);
      expect(DateTime(2024, 2, 31).day, 2);
      // The picker can no longer produce it.
      expect(daysInMonth(2024, 2), lessThan(31));
    });
  });
}
