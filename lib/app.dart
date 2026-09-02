import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/locale/locale_notifier.dart';
import 'core/routing/redirect_policy.dart';
import 'features/assessment/notifiers/assessment_summary_notifier.dart';
import 'features/auth/auth_notifier.dart';
import 'features/exercise/exercise_notifier.dart';
import 'features/profile/screens/profile_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/assessment/screens/assessment_screen.dart';
import 'features/assessment/screens/iciq_screen.dart';
import 'features/assessment/screens/ipaq_screen.dart';
import 'features/assessment/screens/iqol_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/bladder_diary/screens/bladder_diary_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/education/screens/education_screen.dart';
import 'features/exercise/screens/exercise_screen.dart';
import 'features/profile/screens/profile_setup_screen.dart';
import 'features/reassessment/screens/reassessment_screen.dart';
import 'l10n/app_localizations.dart'; // ✅ Import localizations

/// Every route in the app, by path.
///
/// Declared as a map so the set of paths is available to tests: the guard in
/// [resolveRedirect] is only trustworthy if every route it could be asked
/// about is actually covered, and that has to keep holding as routes are added.
final Map<String, WidgetBuilder> appRouteBuilders = {
  '/': (context) => const DashboardScreen(),
  '/login': (context) => const LoginScreen(),
  '/signup': (context) => const SignupScreen(),
  '/profile-setup': (context) => const ProfileSetupScreen(),
  '/ipaq': (context) => const IpaqScreen(),
  '/iciq': (context) => const IciqScreen(),
  '/iqol': (context) => const IqolScreen(),
  '/assessment': (context) => const AssessmentScreen(),
  '/assessment/ipaq': (context) => const IpaqScreen(),
  '/assessment/iciq': (context) => const IciqScreen(),
  '/assessment/iqol': (context) => const IqolScreen(),
  '/bladder-diary': (context) => const BladderDiaryScreen(),
  '/exercise': (context) => const ExerciseScreen(),
  '/dashboard': (context) => const DashboardScreen(),
  '/education': (context) => const EducationScreen(),
  '/reassessment': (context) => const ReassessmentScreen(),
  '/profile': (context) => const ProfileScreen(),
};

/// Builds the router.
///
/// Takes [authNotifier] rather than reading it from context so the guard has a
/// dependable source for who is signed in, and so the router can refresh on
/// sign-in and sign-out.
///
/// The guard re-runs on sign-in and sign-out, on assessment completion, and
/// when the protocol changes shape. It listens to [ExerciseNotifier.protocolRevision]
/// rather than the notifier itself, which also notifies once a second while
/// the exercise countdown is running.
GoRouter createAppRouter(
  AuthNotifier authNotifier,
  AssessmentSummaryNotifier summaryNotifier,
  ExerciseNotifier exerciseNotifier,
) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: Listenable.merge([
      authNotifier,
      summaryNotifier,
      exerciseNotifier.protocolRevision,
    ]),
    routes: [
      for (final entry in appRouteBuilders.entries)
        GoRoute(
          path: entry.key,
          builder: (context, state) => entry.value(context),
        ),
    ],
    redirect: (context, state) {
      // state.uri.path rather than toString(), so a query string cannot make
      // a known route fail to match and fall through the guard.
      final path = state.uri.path;

      return resolveRedirect(
        path: path,
        isSignedIn: authNotifier.currentUser != null,
        hasCompletedProfile:
            authNotifier.currentUser?.isProfileComplete ?? false,
        hasIciq: summaryNotifier.iciq != null,
        hasIpaq: summaryNotifier.ipaq != null,
        hasIqol: summaryNotifier.iqol != null,
        isIqolAvailable: exerciseNotifier.isIqolAvailable,
      );
    },
  );
}

class TelerehabApp extends StatefulWidget {
  const TelerehabApp({super.key});

  @override
  State<TelerehabApp> createState() => _TelerehabAppState();
}

class _TelerehabAppState extends State<TelerehabApp> {
  // Built once: a GoRouter recreated on rebuild would reset the navigation
  // stack. Read lazily so the constructor stays const-friendly.
  late final GoRouter _router = createAppRouter(
    context.read<AuthNotifier>(),
    context.read<AssessmentSummaryNotifier>(),
    context.read<ExerciseNotifier>(),
  );

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleNotifier>().locale;

    return MaterialApp.router(
      locale: locale,
      // ✅ Use onGenerateTitle for localized title
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
