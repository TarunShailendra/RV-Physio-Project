import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/locale/locale_notifier.dart';
import 'features/assessment/notifiers/assessment_summary_notifier.dart';
import 'features/assessment/notifiers/iciq_notifier.dart';
import 'features/assessment/notifiers/ipaq_notifier.dart';
import 'features/assessment/notifiers/iqol_notifier.dart';
import 'features/auth/auth_notifier.dart';
import 'features/bladder_diary/diary_draft_store.dart';
import 'features/dashboard/dashboard_notifier.dart';
import 'features/exercise/exercise_notifier.dart';
import 'features/profile/profile_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Credentials come from the build, not from source. Copy
  // supabase.env.example.json to supabase.env.json (gitignored) and run:
  //   flutter run --dart-define-from-file=supabase.env.json
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase credentials. Pass --dart-define-from-file=supabase.env.json, '
      'or --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final localeNotifier = LocaleNotifier();
  await localeNotifier.load();

  final profileNotifier = ProfileNotifier();
  final dashboardNotifier = DashboardNotifier();
  final exerciseNotifier = ExerciseNotifier();
  final assessmentSummaryNotifier = AssessmentSummaryNotifier();

  final iciqNotifier = IciqNotifier();
  final ipaqNotifier = IpaqNotifier();
  final iqolNotifier = IqolNotifier();

  final authNotifier = AuthNotifier(
    // Pulled back from Supabase whenever a patient signs in, including the
    // session restored at startup. These used to run once here, before anyone
    // could be signed in, so they returned without loading anything.
    onSignedIn: [
      assessmentSummaryNotifier.checkCompletedAssessments,
      exerciseNotifier.loadProgress,
    ],
    // Everything holding patient data, cleared when the session ends. Any
    // notifier added to the provider list below belongs here too.
    onSessionEnded: [
      assessmentSummaryNotifier.reset,
      exerciseNotifier.reset,
      dashboardNotifier.reset,
      profileNotifier.reset,
      DiaryDraftStore.clear,
      iciqNotifier.reset,
      ipaqNotifier.reset,
      iqolNotifier.reset,
    ],
  );

  // Adopt any session Supabase restored from storage, so a returning patient
  // is signed in before the first frame rather than being told their session
  // expired.
  await authNotifier.initialize();

  runApp(
    AppProviders(
      localeNotifier: localeNotifier,
      authNotifier: authNotifier,
      profileNotifier: profileNotifier,
      dashboardNotifier: dashboardNotifier,
      exerciseNotifier: exerciseNotifier,
      assessmentSummaryNotifier: assessmentSummaryNotifier,
      iciqNotifier: iciqNotifier,
      ipaqNotifier: ipaqNotifier,
      iqolNotifier: iqolNotifier,
      child: const TelerehabApp(),
    ),
  );
}

class AppProviders extends StatelessWidget {
  const AppProviders({
    required this.child,
    this.localeNotifier,
    this.authNotifier,
    this.profileNotifier,
    this.dashboardNotifier,
    this.exerciseNotifier,
    this.assessmentSummaryNotifier,
    this.iciqNotifier,
    this.ipaqNotifier,
    this.iqolNotifier,
    super.key,
  });
  final Widget child;
  final LocaleNotifier? localeNotifier;
  final AuthNotifier? authNotifier;
  final ProfileNotifier? profileNotifier;
  final DashboardNotifier? dashboardNotifier;
  final ExerciseNotifier? exerciseNotifier;
  final AssessmentSummaryNotifier? assessmentSummaryNotifier;
  final IciqNotifier? iciqNotifier;
  final IpaqNotifier? ipaqNotifier;
  final IqolNotifier? iqolNotifier;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => localeNotifier ?? LocaleNotifier(),
        ),
        ChangeNotifierProvider(create: (_) => authNotifier ?? AuthNotifier()),
        ChangeNotifierProvider(
          create: (_) => profileNotifier ?? ProfileNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => dashboardNotifier ?? DashboardNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => exerciseNotifier ?? ExerciseNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              assessmentSummaryNotifier ?? AssessmentSummaryNotifier(),
        ),
        ChangeNotifierProvider(create: (_) => iciqNotifier ?? IciqNotifier()),
        ChangeNotifierProvider(create: (_) => ipaqNotifier ?? IpaqNotifier()),
        ChangeNotifierProvider(create: (_) => iqolNotifier ?? IqolNotifier()),
      ],
      child: child,
    );
  }
}
