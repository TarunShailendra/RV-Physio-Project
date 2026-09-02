import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../assessment/notifiers/assessment_summary_notifier.dart';
import 'models/dashboard_model.dart';

/// Mean adherence across the weeks the patient has actually reached.
///
/// This used to divide by all eight weeks regardless of progress, so a patient
/// in week 1 with perfect adherence was shown 13% — the most demotivating
/// number the app could put in front of them.
double averageAdherence(List<double> weekly, int currentWeek) {
  if (weekly.isEmpty) return 0;
  final weeksReached = currentWeek.clamp(1, weekly.length);
  final reached = weekly.take(weeksReached);
  return reached.reduce((a, b) => a + b) / weeksReached;
}

class DashboardNotifier extends ChangeNotifier {
  DashboardNotifier();

  DashboardModel? data;
  bool isLoading = false;

  /// True when the last load failed, as opposed to finding nothing to show.
  /// The screen needs to tell those apart: one is worth retrying.
  bool loadFailed = false;

  /// Sessions in a day, and days in a week, of the protocol.
  static const int sessionsPerDay = 5;
  static const int daysPerWeek = 7;

  int? _recommendedStartWeek;

  Future<void> loadDashboard({
    int? recommendedStartWeek,
    int? iciqScorePre,
  }) async {
    if (recommendedStartWeek != null) {
      _recommendedStartWeek = recommendedStartWeek;
    }

    isLoading = true;
    loadFailed = false;
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        data = null;
        isLoading = false;
        notifyListeners();
        return;
      }

      // One query. This used to fetch the same column again per active week,
      // plus once more for the current week — up to ten round trips for data
      // already in hand.
      final rows = await client
          .from('exercise_logs')
          .select('week_number, day_number, session_number')
          .eq('user_id', userId)
          .eq('completed', true);

      // week -> day -> completed session numbers
      final byWeek = <int, Map<int, Set<int>>>{};
      for (final row in rows) {
        final week = row['week_number'] as int?;
        final day = row['day_number'] as int?;
        final session = row['session_number'] as int?;
        if (week == null || day == null || session == null) continue;
        if (week < 1 || week > 8) continue;
        byWeek
            .putIfAbsent(week, () => <int, Set<int>>{})
            .putIfAbsent(day, () => <int>{})
            .add(session);
      }

      /// Days where every session is done. Counting a day as complete on a
      /// single session overstated adherence by up to five times.
      int fullyCompletedDays(int week) =>
          (byWeek[week] ?? const <int, Set<int>>{}).values
              .where((sessions) => sessions.length >= sessionsPerDay)
              .length;

      final weeklyAdherence = <double>[
        for (var week = 1; week <= 8; week++)
          ((fullyCompletedDays(week) / daysPerWeek) * 100).clamp(0.0, 100.0),
      ];

      // The week with activity, or the one the assessments recommended for a
      // patient who has not started yet.
      final active = byWeek.keys.toList()..sort();
      final currentWeek = active.isNotEmpty
          ? active.last
          : (_recommendedStartWeek ?? 1);

      data = DashboardModel(
        currentWeek: currentWeek,
        totalWeeks: 8,
        exercisesCompletedThisWeek: fullyCompletedDays(currentWeek),
        exercisesTargetThisWeek: daysPerWeek,
        adherencePercentage: averageAdherence(weeklyAdherence, currentWeek),
        iciqScorePre: iciqScorePre ?? data?.iciqScorePre ?? 0,
        iciqScorePost: data?.iciqScorePost ?? 0,
        weeklyAdherence: weeklyAdherence,
      );
    } catch (e) {
      debugPrint('[loadDashboard] error: $e');
      loadFailed = true;
      data = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void applyAssessmentSummary(AssessmentSummaryNotifier summary) {
    // Held even when there is no dashboard yet. Every assessment screen calls
    // this before loadDashboard has ever run, so the recommendation used to be
    // dropped on the floor and then overwritten by "highest week with activity".
    _recommendedStartWeek = summary.recommendedStartWeek;

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
    loadFailed = false;
    _recommendedStartWeek = null;
    notifyListeners();
  }
}
