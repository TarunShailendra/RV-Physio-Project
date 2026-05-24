import 'dart:async';

import 'package:flutter/foundation.dart';

import 'models/exercise_model.dart';

class ExerciseNotifier extends ChangeNotifier {
  WeeklyPlan? currentPlan;
  int currentSessionIndex = 0;
  bool isTimerRunning = false;
  int timerSecondsRemaining = 0;

  Timer? _timer;

  void loadWeek(int week) {
    currentPlan = WeeklyPlan.getWeekPlan(week);
    currentSessionIndex = 0;
    timerSecondsRemaining = _secondsForCurrentSession();
    isTimerRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void loadRecommendedWeek(int week) {
    final safeWeek = week.clamp(1, 8);
    loadWeek(safeWeek);
  }

  void startTimer() {
    if (isTimerRunning || currentPlan == null) {
      return;
    }

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
    if (!isTimerRunning) {
      return;
    }

    _timer?.cancel();
    isTimerRunning = false;
    notifyListeners();
  }

  void completeSession(int index) {
    final plan = currentPlan;
    if (plan == null || index < 0 || index >= plan.sessions.length) {
      return;
    }

    final updatedSessions = [...plan.sessions];
    final session = updatedSessions[index];
    updatedSessions[index] = ExerciseSession(
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
      sessions: updatedSessions,
      difficultyLabel: plan.difficultyLabel,
    );
    currentSessionIndex = index < updatedSessions.length - 1
        ? index + 1
        : index;
    _resetTimer();
    notifyListeners();
  }

  int _secondsForCurrentSession() {
    final plan = currentPlan;
    if (plan == null || currentSessionIndex >= plan.sessions.length) {
      return 0;
    }

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