import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

void main() {
  runApp(const AppProviders(child: TelerehabApp()));
}

class AppProviders extends StatelessWidget {
  const AppProviders({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => ProfileNotifier()),
        ChangeNotifierProvider(create: (_) => AssessmentSummaryNotifier()),
        ChangeNotifierProvider(create: (_) => IciqNotifier()),
        ChangeNotifierProvider(create: (_) => IqolNotifier()),
        ChangeNotifierProvider(create: (_) => IpaqNotifier()),
        ChangeNotifierProvider(create: (_) => BladderDiaryNotifier()),
        ChangeNotifierProvider(create: (_) => DashboardNotifier()),
        ChangeNotifierProvider(create: (_) => ExerciseNotifier()),
      ],
      child: child,
    );
  }
}
