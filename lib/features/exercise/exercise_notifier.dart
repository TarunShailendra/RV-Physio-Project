import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models/exercise_model.dart';

class ExerciseNotifier extends ChangeNotifier {
  final Map<int, WeeklyPlan> _plans = {};
  final Set<int> _completedWeeks = {};

  WeeklyPlan? currentPlan;
  int currentSessionIndex = 0;
  bool isTimerRunning = false;
  int timerSecondsRemaining = 0;
  Timer? _timer;

  int get highestUnlockedWeek {
    for (var week = 1; week < 8; week++) {
      if (!_completedWeeks.contains(week)) return week;
    }
    return 8;
  }

  bool canAccessWeek(int week) => week >= 1 && week <= highestUnlockedWeek;
  bool get isWeekOneComplete => _completedWeeks.contains(1);

  void loadWeek(int week) {
    if (!canAccessWeek(week)) return;
    currentPlan = _plans[week] ??= WeeklyPlan.getWeekPlan(week);
    currentSessionIndex = _firstIncompleteSession(currentPlan!);
    timerSecondsRemaining = _secondsForCurrentSession();
    isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void loadRecommendedWeek(int _) => loadWeek(1);

  void startTimer() {
    if (isTimerRunning || currentPlan == null) return;
    if (timerSecondsRemaining <= 0) timerSecondsRemaining = _secondsForCurrentSession();
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

  void completeSession(int index) {
    final plan = currentPlan;
    if (plan == null || index < 0 || index >= plan.sessions.length) return;
    final sessions = [...plan.sessions];
    final session = sessions[index];
    sessions[index] = ExerciseSession(
      week: session.week,
      day: session.day,
      exerciseName: session.exerciseName,
      reps: session.reps,
      holdSeconds: session.holdSeconds,
      restSeconds: session.restSeconds,
      isCompleted: true,
    );
    currentPlan = WeeklyPlan(
      weekNumber: plan.weekNumber,
      sessions: sessions,
      difficultyLabel: plan.difficultyLabel,
    );
    _plans[plan.weekNumber] = currentPlan!;
    if (sessions.every((item) => item.isCompleted)) _completedWeeks.add(plan.weekNumber);
    currentSessionIndex = _firstIncompleteSession(currentPlan!);
    _resetTimer();
    notifyListeners();
  }

  int _firstIncompleteSession(WeeklyPlan plan) {
    final index = plan.sessions.indexWhere((session) => !session.isCompleted);
    return index == -1 ? plan.sessions.length - 1 : index;
  }

  int _secondsForCurrentSession() {
    final plan = currentPlan;
    if (plan == null || currentSessionIndex >= plan.sessions.length) return 0;
    final session = plan.sessions[currentSessionIndex];
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
    currentPlan = null;
    currentSessionIndex = 0;
    isTimerRunning = false;
    timerSecondsRemaining = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}