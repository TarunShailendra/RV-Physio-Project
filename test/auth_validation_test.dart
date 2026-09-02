import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/features/auth/auth_notifier.dart';
import 'package:telerehab_app/features/auth/screens/login_screen.dart';
import 'package:telerehab_app/features/auth/screens/signup_screen.dart';
import 'package:telerehab_app/l10n/app_localizations.dart';

/// Covers the auth form validation.
///
/// Both email validators opened with `if (email.isEmpty) return null;`, so a
/// blank address passed. On signup that fell through to a fabricated
/// `<phone>@phone.local`, producing an account with no way to reset a password
/// or confirm an address.
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

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthNotifier(),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('A3 — login rejects a blank email', (tester) async {
    await pump(tester, const LoginScreen());

    await tester.enterText(find.byType(TextFormField).last, 'somepassword');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter your email'),
      findsOneWidget,
      reason: 'a blank email used to pass validation',
    );
  });

  testWidgets('A3 — signup rejects a blank email', (tester) async {
    await pump(tester, const SignupScreen());

    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email'), findsOneWidget);
  });

  testWidgets('A3 — signup still rejects a malformed email', (tester) async {
    await pump(tester, const SignupScreen());

    await tester.enterText(find.byType(TextFormField).at(1), 'asha@example');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign up'));
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a valid email'),
      findsOneWidget,
      reason: 'the signup validator only checked for @, not a domain',
    );
  });

  group('A4 — duplicate registration is distinguished', () {
    test('the flag starts clear', () {
      expect(AuthNotifier().emailAlreadyRegistered, isFalse);
    });

    test('an ordinary failure is not reported as a duplicate', () async {
      // Every request in this suite fails, so this exercises the generic
      // failure path rather than the duplicate one.
      final auth = AuthNotifier();
      await auth.signup(
        'Asha R',
        'asha@example.com',
        'Password!1',
        '9999999999',
        34,
      );

      expect(
        auth.emailAlreadyRegistered,
        isFalse,
        reason: 'only a genuine duplicate should set this',
      );
      expect(auth.errorMessage, isNotNull);
    });
  });
}
