import 'package:flutter/foundation.dart';

import '../assessment/notifiers/assessment_summary_notifier.dart';
import 'models/dashboard_model.dart';

class DashboardNotifier extends ChangeNotifier {
  DashboardNotifier();

  DashboardModel? data;
  bool isLoading = false;

  Future<void> loadDashboard() async {
    try {
      isLoading = true;
      notifyListeners();

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
      isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[loadDashboard] error: $e');
      isLoading = false;
      notifyListeners();
    }
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

  void reset() {
    data = null;
    notifyListeners();
  }
}