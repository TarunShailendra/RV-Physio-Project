import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../assessment/notifiers/assessment_summary_notifier.dart';
import '../exercise/models/protocol.dart';
import '../exercise/protocols/protocol_lookup.dart';
import 'models/dashboard_model.dart';

/// Adherence for the week the patient is on.
///
/// This was a mean across every week up to the current one, which is wrong for
/// anyone whose assessments start them past week 1: the weeks before their
/// start are counted as zeroes they were never asked to fill. A patient
/// recommended to begin at week 3, with all seven days of week 3 done, was
/// shown 33% — sitting next to a card reading 7/7 for the same week.
///
/// Reporting the current week alone also makes the two cards agree by
/// construction, since both come from the same completed-day count. The full
/// history is still on the weekly adherence chart, which is where a trend
/// across weeks belongs.
double currentWeekAdherence(List<double> weekly, int currentWeek) {
  if (weekly.isEmpty) return 0;
  final week = currentWeek.clamp(1, weekly.length);
  return weekly[week - 1];
}

/// The week the patient is on: the first week at or after the furthest one
/// they have touched that they have not yet finished.
///
/// This was simply the highest week holding a completed session, which lags a
/// week behind from the moment a week is finished until the first session of
/// the next one is logged. Through that whole gap — the start of every new
/// week — the dashboard and the profile reported the week just finished,
/// along with its exercise count and its adherence.
///
/// Reading forward to the first incomplete week mirrors
/// ExerciseNotifier.highestUnlockedWeek, so the two agree about where the
/// patient is.
///
/// A week counts as finished when its own prescribed day count is met, which
/// the protocol supplies and which varies from three to five. This used to be
/// a fixed seven for every week of every patient. The recommendedStartWeek
/// parameter is retired along with the rule behind it: every patient now
/// begins their own protocol at week 1.
int resolveCurrentWeek({
  required Set<int> weeksTouched,
  required Map<int, int> completedDaysByWeek,
  required Protocol protocol,
}) {
  final started = weeksTouched.isEmpty
      ? 1
      : weeksTouched.reduce((a, b) => a > b ? a : b);

  for (
    var week = started.clamp(1, DashboardNotifier.totalWeeks);
    week < DashboardNotifier.totalWeeks;
    week++
  ) {
    if ((completedDaysByWeek[week] ?? 0) <
        protocol.blockForWeek(week).daysPerWeek) {
      return week;
    }
  }
  return DashboardNotifier.totalWeeks;
}

/// Share of the week's prescribed days the patient has completed, 0 to 100.
///
/// The denominator is the protocol's own days for that week. It used to be a
/// fixed seven, so a patient prescribed a three-day week could not read above
/// 43 per cent however diligent they were.
@visibleForTesting
double weekAdherence({
  required int completedDays,
  required int week,
  required Protocol protocol,
}) {
  final target = protocol.blockForWeek(week).daysPerWeek;
  if (target <= 0) return 0;
  return ((completedDays / target) * 100).clamp(0.0, 100.0);
}

class DashboardNotifier extends ChangeNotifier {
  DashboardNotifier();

  DashboardModel? data;
  bool isLoading = false;

  /// True when the last load failed, as opposed to finding nothing to show.
  /// The screen needs to tell those apart: one is worth retrying.
  bool loadFailed = false;

  /// Weeks in the protocol. Every protocol the document defines runs eight.
  ///
  /// The sessionsPerDay and daysPerWeek constants that used to sit here are
  /// gone: both now vary by protocol and by week, and are read from the
  /// patient's own plan instead of assumed.
  static const int totalWeeks = 8;

  Protocol _protocol = protocolFor();

  Future<void> loadDashboard({Protocol? protocol, int? iciqScorePre}) async {
    if (protocol != null) _protocol = protocol;

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
        if (week < 1 || week > totalWeeks) continue;
        byWeek
            .putIfAbsent(week, () => <int, Set<int>>{})
            .putIfAbsent(day, () => <int>{})
            .add(session);
      }

      /// Days where every prescribed item is done. Counting a day as
      /// complete on a single session overstated adherence severalfold; the
      /// threshold is the number of items that week actually prescribes,
      /// which runs from six to fifteen.
      int fullyCompletedDays(int week) {
        final required = _protocol.blockForWeek(week).items.length;
        return (byWeek[week] ?? const <int, Set<int>>{}).values
            .where((sessions) => sessions.length >= required)
            .length;
      }

      final weeklyAdherence = <double>[
        for (var week = 1; week <= totalWeeks; week++)
          weekAdherence(
            completedDays: fullyCompletedDays(week),
            week: week,
            protocol: _protocol,
          ),
      ];

      final currentWeek = resolveCurrentWeek(
        weeksTouched: byWeek.keys.toSet(),
        completedDaysByWeek: {
          for (var week = 1; week <= totalWeeks; week++)
            week: fullyCompletedDays(week),
        },
        protocol: _protocol,
      );

      data = DashboardModel(
        currentWeek: currentWeek,
        totalWeeks: totalWeeks,
        exercisesCompletedThisWeek: fullyCompletedDays(currentWeek),
        exercisesTargetThisWeek: _protocol
            .blockForWeek(currentWeek)
            .daysPerWeek,
        adherencePercentage: currentWeekAdherence(weeklyAdherence, currentWeek),
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
    // this before loadDashboard has ever run.
    _protocol = summary.protocol;

    final current = data;
    if (current == null) return;

    // The week-raising that used to live here is gone. It carried a
    // recommended start week onto the dashboard; every patient now begins
    // their own protocol at week 1, so there is nothing to raise towards.
    data = current.copyWith(
      iciqScorePre: summary.iciq?.iciqScore ?? current.iciqScorePre,
    );
    notifyListeners();
  }

  void reset() {
    data = null;
    loadFailed = false;
    _protocol = protocolFor();
    notifyListeners();
  }
}
