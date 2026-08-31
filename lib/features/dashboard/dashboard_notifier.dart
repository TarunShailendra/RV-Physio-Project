import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      // Fetch all completed exercise logs for this user
      final rows = await client
          .from('exercise_logs')
          .select('week_number, day_number, completed')
          .eq('user_id', userId)
          .eq('completed', true);

      // Weekly adherence — 8 weeks, 5 sessions each
      const int daysPerWeek = 7;
      final List<double> weeklyAdherence = List.filled(8, 0.0);
      final Map<int, int> completedByWeek = {};

      for (final row in rows) {
        final week = row['week_number'] as int;
        if (week >= 1 && week <= 8) {
          completedByWeek[week] = (completedByWeek[week] ?? 0) + 1;
        }
      }

      for (final entry in completedByWeek.entries) {
        final weekIndex = entry.key - 1;
        // count distinct completed days for this week
        final completedDays = await client
            .from('exercise_logs')
            .select('day_number')
            .eq('user_id', userId)
            .eq('week_number', entry.key)
            .eq('completed', true);
        final distinctDays = completedDays
            .map((r) => r['day_number'] as int)
            .toSet()
            .length;
        weeklyAdherence[weekIndex] =
            ((distinctDays / daysPerWeek) * 100).clamp(0.0, 100.0);
      }

      // Current week = highest week with any activity, or 1
      int currentWeek = 1;
      if (completedByWeek.isNotEmpty) {
        currentWeek = completedByWeek.keys.reduce((a, b) => a > b ? a : b);
      }

      // This week's completed sessions
      final thisWeekDays = await client
          .from('exercise_logs')
          .select('day_number')
          .eq('user_id', userId)
          .eq('week_number', currentWeek)
          .eq('completed', true);
      final completedThisWeek = thisWeekDays
          .map((r) => r['day_number'] as int)
          .toSet()
          .length;

      // Overall adherence = average across all 8 weeks
      final double adherence =
          weeklyAdherence.reduce((a, b) => a + b) / 8.0; // already 0–100

      data = DashboardModel(
        currentWeek: currentWeek,
        totalWeeks: 8,
        exercisesCompletedThisWeek: completedThisWeek,
        exercisesTargetThisWeek: daysPerWeek,
        adherencePercentage: adherence,
        iciqScorePre: data?.iciqScorePre ?? 0,
        iciqScorePost: data?.iciqScorePost ?? 0,
        weeklyAdherence: weeklyAdherence,
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