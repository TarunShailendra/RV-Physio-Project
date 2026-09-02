import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/exercise_model.dart';

class ExerciseNotifier extends ChangeNotifier {
  final Map<int, WeeklyPlan> _plans = {};
  final Set<int> _completedWeeks = {};
  DateTime? _protocolStartDate;

  /// Bumped when the shape of the protocol changes — a week completed,
  /// progress reloaded, the start week moved, a reset.
  ///
  /// Separate from the notifier itself so the route guard can listen to
  /// protocol changes without also waking on every tick of the countdown,
  /// which notifies once a second while a session is running.
  final ValueNotifier<int> protocolRevision = ValueNotifier<int>(0);

  WeeklyPlan? currentPlan;
  int currentDayIndex = 0;
  int currentSessionIndex = 0;
  bool isTimerRunning = false;
  int timerSecondsRemaining = 0;
  Timer? _timer;

  /// Week the patient's protocol begins at, from
  /// AssessmentSummaryNotifier.recommendedStartWeek.
  ///
  /// A milder, more active patient is placed past the beginner weeks rather
  /// than made to grind through them. Weeks before this one stay reachable —
  /// they are simply not required to unlock what follows.
  int get recommendedStartWeek => _recommendedStartWeek;
  int _recommendedStartWeek = 1;

  /// Furthest week the patient may open: the first one at or after their start
  /// week that they have not finished.
  int get highestUnlockedWeek {
    for (var week = _recommendedStartWeek; week < 8; week++) {
      if (!_completedWeeks.contains(week)) return week;
    }
    return 8;
  }

  bool canAccessWeek(int week) => week >= 1 && week <= highestUnlockedWeek;
  bool get isWeekOneComplete => _completedWeeks.contains(1);

  /// Days the exercise protocol is meant to run for before reassessment.
  static const int protocolDurationDays = 7;

  /// When the patient's protocol began — their earliest completed session, or
  /// the first time they opened a week.
  DateTime? get protocolStartDate => _protocolStartDate;

  @visibleForTesting
  set protocolStartDate(DateTime? value) => _protocolStartDate = value;

  int get daysSinceProtocolStart {
    final start = _protocolStartDate;
    if (start == null) return 0;
    return DateTime.now().difference(start).inDays;
  }

  /// The I-QOL opens once a full week of the protocol is done *and* a week has
  /// actually elapsed.
  ///
  /// Two separate defects lived here. It used to ask specifically for week 1,
  /// stranding any patient whose protocol starts later. And it counted only
  /// finished sessions, so all 35 of them could be tapped through in a couple
  /// of minutes to unlock a questionnaire the protocol says comes after seven
  /// days of exercises.
  bool get isIqolAvailable =>
      _completedWeeks.isNotEmpty &&
      daysSinceProtocolStart >= protocolDurationDays;

  DayPlan? get currentDay =>
      currentPlan != null && currentDayIndex < currentPlan!.days.length
      ? currentPlan!.days[currentDayIndex]
      : null;

  ExerciseSession? get currentSession =>
      currentDay != null && currentSessionIndex < currentDay!.sessions.length
      ? currentDay!.sessions[currentSessionIndex]
      : null;

  void loadWeek(int week) {
    if (!canAccessWeek(week)) return;
    _protocolStartDate ??= DateTime.now();
    currentPlan = _plans[week] ??= WeeklyPlan.getWeekPlan(week);
    currentDayIndex = _firstIncompleteDay(currentPlan!);
    currentSessionIndex = _firstIncompleteSession();
    timerSecondsRemaining = _secondsForCurrentSession();
    isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  /// Applies the recommendation from the assessments, then opens the week the
  /// patient is currently on within it.
  ///
  /// The argument used to be discarded, so every caller's computed
  /// recommendation was thrown away and everyone started at the first week
  /// they had not finished — which is week 1 for every new patient.
  void loadRecommendedWeek(int week) {
    setRecommendedStartWeek(week);
    loadWeek(highestUnlockedWeek);
  }

  /// Raises the floor of the protocol. Applied before loading a week, because
  /// loadWeek refuses a week that is not yet unlocked.
  void setRecommendedStartWeek(int week) {
    final clamped = week.clamp(1, 8);
    if (_recommendedStartWeek == clamped) return;
    _recommendedStartWeek = clamped;
    notifyListeners();
    protocolRevision.value++;
  }

  void selectDay(int dayIndex) {
    if (currentPlan == null) return;
    currentDayIndex = dayIndex;
    currentSessionIndex = _firstIncompleteSession();
    timerSecondsRemaining = _secondsForCurrentSession();
    isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> loadProgress() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final rows = await Supabase.instance.client
          .from('exercise_logs')
          .select(
            'week_number, day_number, session_number, completed, completed_at',
          )
          .eq('user_id', userId)
          .eq('completed', true);

      _completedWeeks.clear();
      _plans.clear();

      final Map<int, Map<int, Set<int>>> byWeekDaySession = {};
      for (final row in rows) {
        final week = row['week_number'] as int;
        final day = row['day_number'] as int;
        final session = row['session_number'] as int;
        byWeekDaySession
            .putIfAbsent(week, () => {})
            .putIfAbsent(day, () => {})
            .add(session);
      }

      for (final weekEntry in byWeekDaySession.entries) {
        final weekNum = weekEntry.key;
        final daySessionMap = weekEntry.value;
        final basePlan = WeeklyPlan.getWeekPlan(weekNum);

        final days = basePlan.days.map((day) {
          final completedSessions = daySessionMap[day.dayNumber] ?? {};
          final sessions = day.sessions.map((session) {
            return ExerciseSession(
              week: session.week,
              day: session.day,
              sessionNumber: session.sessionNumber,
              exerciseName: session.exerciseName,
              reps: session.reps,
              holdSeconds: session.holdSeconds,
              restSeconds: session.restSeconds,
              isCompleted: completedSessions.contains(session.sessionNumber),
            );
          }).toList();
          return DayPlan(dayNumber: day.dayNumber, sessions: sessions);
        }).toList();

        final plan = WeeklyPlan(
          weekNumber: weekNum,
          days: days,
          difficultyLabel: basePlan.difficultyLabel,
        );

        if (plan.isCompleted) _completedWeeks.add(weekNum);
        _plans[weekNum] = plan;
      }

      protocolRevision.value++;

      // The protocol started when the patient first exercised, not when this
      // device happened to load their progress.
      for (final row in rows) {
        final at = DateTime.tryParse(row['completed_at']?.toString() ?? '');
        if (at == null) continue;
        if (_protocolStartDate == null || at.isBefore(_protocolStartDate!)) {
          _protocolStartDate = at;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('loadProgress failed: $e');
    }
  }

  void startTimer() {
    if (isTimerRunning || currentPlan == null) return;
    if (timerSecondsRemaining <= 0) {
      timerSecondsRemaining = _secondsForCurrentSession();
    }
    isTimerRunning = true;
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSecondsRemaining <= 1) {
        timerSecondsRemaining = 0;
        isTimerRunning = false;
        timer.cancel();
      } else {
        timerSecondsRemaining--;
      }
      notifyListeners();
    });
  }

  void pauseTimer() {
    if (!isTimerRunning) return;
    _timer?.cancel();
    isTimerRunning = false;
    notifyListeners();
  }

  Future<void> completeSession(int dayIndex, int sessionIndex) async {
    final plan = currentPlan;
    if (plan == null) return;
    if (dayIndex < 0 || dayIndex >= plan.days.length) return;
    if (sessionIndex < 0 ||
        sessionIndex >= plan.days[dayIndex].sessions.length) {
      return;
    }

    final day = plan.days[dayIndex];
    final session = day.sessions[sessionIndex];

    final updatedSessions = day.sessions.map((s) {
      if (s.sessionNumber == session.sessionNumber) {
        return ExerciseSession(
          week: s.week,
          day: s.day,
          sessionNumber: s.sessionNumber,
          exerciseName: s.exerciseName,
          reps: s.reps,
          holdSeconds: s.holdSeconds,
          restSeconds: s.restSeconds,
          isCompleted: true,
        );
      }
      return s;
    }).toList();

    final updatedDay = DayPlan(
      dayNumber: day.dayNumber,
      sessions: updatedSessions,
    );
    final updatedDays = plan.days
        .map((d) => d.dayNumber == day.dayNumber ? updatedDay : d)
        .toList();

    currentPlan = WeeklyPlan(
      weekNumber: plan.weekNumber,
      days: updatedDays,
      difficultyLabel: plan.difficultyLabel,
    );
    _plans[plan.weekNumber] = currentPlan!;

    if (currentPlan!.isCompleted) _completedWeeks.add(plan.weekNumber);
    protocolRevision.value++;
    currentSessionIndex = _firstIncompleteSession();
    _resetTimer();

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('exercise_logs').upsert({
          'user_id': userId,
          'week_number': session.week,
          'day_number': session.day,
          'session_number': session.sessionNumber,
          'exercise_name': session.exerciseName,
          'reps': session.reps,
          'hold_seconds': session.holdSeconds,
          'rest_seconds': session.restSeconds,
          'completed': true,
          'duration_seconds':
              session.reps * (session.holdSeconds + session.restSeconds),
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id,week_number,day_number,session_number');
      }
    } catch (e) {
      debugPrint('exercise_logs insert failed: $e');
    }

    notifyListeners();
  }

  int _firstIncompleteDay(WeeklyPlan plan) {
    final index = plan.days.indexWhere((d) => !d.isCompleted);
    return index == -1 ? plan.days.length - 1 : index;
  }

  int _firstIncompleteSession() {
    final day = currentDay;
    if (day == null) return 0;
    final index = day.sessions.indexWhere((s) => !s.isCompleted);
    return index == -1 ? day.sessions.length - 1 : index;
  }

  int _secondsForCurrentSession() {
    final session = currentSession;
    if (session == null) return 0;
    return session.reps * (session.holdSeconds + session.restSeconds);
  }

  void _resetTimer() {
    _timer?.cancel();
    isTimerRunning = false;
    timerSecondsRemaining = _secondsForCurrentSession();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _plans.clear();
    _completedWeeks.clear();
    _recommendedStartWeek = 1;
    _protocolStartDate = null;
    currentPlan = null;
    currentDayIndex = 0;
    currentSessionIndex = 0;
    isTimerRunning = false;
    timerSecondsRemaining = 0;
    protocolRevision.value++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    protocolRevision.dispose();
    super.dispose();
  }
}
