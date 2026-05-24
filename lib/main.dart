import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'features/assessment/notifiers/assessment_summary_notifier.dart';
import 'features/assessment/notifiers/iciq_notifier.dart';
import 'features/assessment/notifiers/ipaq_notifier.dart';
import 'features/assessment/notifiers/iqol_notifier.dart';
import 'features/auth/auth_notifier.dart';
import 'features/bladder_diary/bladder_diary_notifier.dart';
import 'features/dashboard/dashboard_notifier.dart';
import 'features/exercise/exercise_notifier.dart';
import 'features/profile/profile_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yfigxvdvohhobmgkqyca.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmaWd4dmR2b2hob2JtZ2txeWNhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNzcyNTksImV4cCI6MjA5Mzc1MzI1OX0.nOjeVT84wlAY4goUUnVotTm-pOUIb2IIKR8eoXAwIkc',
  );

  final profileNotifier = ProfileNotifier();
  final dashboardNotifier = DashboardNotifier();
  final exerciseNotifier = ExerciseNotifier();
  final assessmentSummaryNotifier = AssessmentSummaryNotifier();
  final iciqNotifier = IciqNotifier();
  final ipaqNotifier = IpaqNotifier();
  final iqolNotifier = IqolNotifier();
  final bladderDiaryNotifier = BladderDiaryNotifier();

  final authNotifier = AuthNotifier();

  runApp(AppProviders(
    authNotifier: authNotifier,
    profileNotifier: profileNotifier,
    dashboardNotifier: dashboardNotifier,
    exerciseNotifier: exerciseNotifier,
    assessmentSummaryNotifier: assessmentSummaryNotifier,
    iciqNotifier: iciqNotifier,
    ipaqNotifier: ipaqNotifier,
    iqolNotifier: iqolNotifier,
    bladderDiaryNotifier: bladderDiaryNotifier,
    child: const TelerehabApp(),
  ));
}

class AppProviders extends StatelessWidget {
  const AppProviders({
    required this.child,
    this.authNotifier,
    this.profileNotifier,
    this.dashboardNotifier,
    this.exerciseNotifier,
    this.assessmentSummaryNotifier,
    this.iciqNotifier,
    this.ipaqNotifier,
    this.iqolNotifier,
    this.bladderDiaryNotifier,
    super.key,
  });
  final Widget child;
  final AuthNotifier? authNotifier;
  final ProfileNotifier? profileNotifier;
  final DashboardNotifier? dashboardNotifier;
  final ExerciseNotifier? exerciseNotifier;
  final AssessmentSummaryNotifier? assessmentSummaryNotifier;
  final IciqNotifier? iciqNotifier;
  final IpaqNotifier? ipaqNotifier;
  final IqolNotifier? iqolNotifier;
  final BladderDiaryNotifier? bladderDiaryNotifier;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
        ChangeNotifierProvider(
          create: (_) => bladderDiaryNotifier ?? BladderDiaryNotifier(),
        ),
      ],
      child: child,
    );
  }
}
