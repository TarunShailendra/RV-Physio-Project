import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/app.dart';
import 'package:telerehab_app/features/auth/screens/login_screen.dart';
import 'package:telerehab_app/main.dart';

/// Checks the guard is actually wired into the running app, not just correct
/// as a function: that createAppRouter is reached, that TelerehabApp can read
/// the AuthNotifier out of the provider tree, and that a signed-out visitor
/// navigating to a protected route is put back on the login screen.
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

  testWidgets('a signed-out visitor cannot navigate to a protected route', (
    tester,
  ) async {
    await tester.pumpWidget(const AppProviders(child: TelerehabApp()));
    await tester.pumpAndSettle();

    expect(
      find.byType(LoginScreen),
      findsOneWidget,
      reason: 'the app should open on the login screen',
    );

    // Try to reach the dashboard directly, the way a deep link would.
    final context = tester.element(find.byType(LoginScreen));
    GoRouter.of(context).go('/dashboard');
    await tester.pumpAndSettle();

    expect(
      find.byType(LoginScreen),
      findsOneWidget,
      reason: 'the guard must put a signed-out visitor back on login',
    );
  });

  testWidgets('the guard holds across several protected routes', (
    tester,
  ) async {
    await tester.pumpWidget(const AppProviders(child: TelerehabApp()));
    await tester.pumpAndSettle();

    for (final path in ['/exercise', '/bladder-diary', '/education', '/']) {
      final context = tester.element(find.byType(LoginScreen));
      GoRouter.of(context).go(path);
      await tester.pumpAndSettle();

      expect(
        find.byType(LoginScreen),
        findsOneWidget,
        reason: '$path must not be reachable signed out',
      );
    }
  });
}
