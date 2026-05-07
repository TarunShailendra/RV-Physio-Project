import 'package:flutter/foundation.dart';

import '../assessment/notifiers/assessment_summary_notifier.dart';
import 'models/dashboard_model.dart';

class DashboardNotifier extends ChangeNotifier {
  DashboardNotifier() {
    loadDashboard();
  }

  DashboardModel? data;

  Future<void> loadDashboard() async {
    data = const DashboardModel(
      currentWeek: 1,
      totalWeeks: 8,
      exercisesCompletedThisWeek: 0,
      exercisesTargetThisWeek: 5,
      adherencePercentage: 0.0,
      iciqScorePre: 0,
      iciqScorePost: 0,
      weeklyAdherence: [0, 0, 0, 0, 0, 0, 0, 0],
    );
    notifyListeners();
  }

  void applyAssessmentSummary(AssessmentSummaryNotifier summary) {
    final current = data;
    if (current == null) return;

    data = current.copyWith(
      currentWeek: summary.recommendedStartWeek,
      iciqScorePre: summary.iciq?.iciqScore ?? current.iciqScorePre,
    );
    notifyListeners();
  }
}
