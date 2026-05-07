import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(path: '/ipaq', builder: (context, state) => const IpaqScreen()),
    GoRoute(path: '/iciq', builder: (context, state) => const IciqScreen()),
    GoRoute(path: '/iqol', builder: (context, state) => const IqolScreen()),
    GoRoute(
      path: '/assessment',
      builder: (context, state) => const AssessmentScreen(),
    ),
    GoRoute(
      path: '/assessment/ipaq',
      builder: (context, state) => const IpaqScreen(),
    ),
    GoRoute(
      path: '/assessment/iciq',
      builder: (context, state) => const IciqScreen(),
    ),
    GoRoute(
      path: '/assessment/iqol',
      builder: (context, state) => const IqolScreen(),
    ),
    GoRoute(
      path: '/bladder-diary',
      builder: (context, state) => const BladderDiaryScreen(),
    ),
    GoRoute(
      path: '/exercise',
      builder: (context, state) => const ExerciseScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/education',
      builder: (context, state) => const EducationScreen(),
    ),
    GoRoute(
      path: '/reassessment',
      builder: (context, state) => const ReassessmentScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

class TelerehabApp extends StatelessWidget {
  const TelerehabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // ✅ Use onGenerateTitle for localized title
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
