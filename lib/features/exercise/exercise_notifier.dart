import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/exercise_model.dart';
import 'models/protocol.dart';
import 'protocols/protocol_lookup.dart';

/// What the patient should be doing right now.
///
/// [betweenReps] is where an exercise rests when the document gives it no
/// relax time. Only the slow pelvic floor holds are prescribed an explicit
/// rest; for a bridge or a leg raise the lowering of the limb is the rest, and
/// putting a number on it would be inventing clinical content. The patient
/// starts the next rep when they are ready.
enum ExercisePhase { ready, hold, rest, betweenReps, finished }

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

  /// Seconds left in the current phase.
  ///
  /// Exposed as a ValueNotifier so the countdown does not go through
  /// notifyListeners: it ticks once a second, and every widget watching this
  /// notifier — both chip rows and all four cards — used to rebuild each time
  /// to update one line of text.
  final ValueNotifier<int> secondsRemaining = ValueNotifier<int>(0);

  int get timerSecondsRemaining => secondsRemaining.value;

  /// Which part of the rep the patient is in.
  ExercisePhase phase = ExercisePhase.ready;

  /// 1-based rep the patient is on, out of the session's reps.
  int currentRep = 0;

  Timer? _timer;

  /// The programme this patient is following, chosen from their ICIQ severity
  /// band and IPAQ activity level.
  ///
  /// Defaults to the severe protocol, which is the most conservative the
  /// document defines. A patient whose questionnaires have not loaded yet must
  /// never be shown a harder plan than they should have.
  Protocol get protocol => _protocol;
  Protocol _protocol = protocolFor();

  /// Adopts the protocol chosen from the patient's questionnaires, discarding
  /// any plan built from the previous one.
  ///
  /// Replaces loadRecommendedWeek, which took a start week derived from the
  /// same two scores and skipped the patient forward to it. Now that those
  /// scores choose the programme itself, skipping would drop the patient past
  /// their own protocol's baseline activation block.
  void applyProtocol(Protocol protocol) {
    if (protocol.id == _protocol.id) return;
    _protocol = protocol;
    _plans.clear();
    currentPlan = null;
    currentDayIndex = 0;
    currentSessionIndex = 0;
    _resetTimer();
    protocolRevision.value++;
    notifyListeners();
  }

  /// Furthest week the patient may open: the first one they have not finished.
  ///
  /// This used to be floored at a recommended start week. Every patient now
  /// begins their own protocol at week 1.
  int get highestUnlockedWeek {
    for (var week = 1; week < 8; week++) {
      if (!_completedWeeks.contains(week)) return week;
    }
    return 8;
  }

  bool canAccessWeek(int week) => week >= 1 && week <= highestUnlockedWeek;
  bool get isWeekOneComplete => _completedWeeks.contains(1);

  /// Days the exercise protocol is meant to run for before reassessment.
  /// Descriptive only: it no longer gates [isIqolAvailable].
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

  /// The I-QOL opens once a full week of the protocol is done.
  ///
  /// "A full week" means any week the patient has finished, not week 1
  /// specifically: asking for week 1 stranded anyone whose assessments start
  /// them at week 2 or 3, since they would finish their own first week and
  /// never be offered the questionnaire.
  ///
  /// Completing a week no longer also requires that a week has elapsed. The
  /// protocol places the I-QOL after seven days of exercises, and all 35
  /// sessions can be tapped through in a couple of minutes, so with the app
  /// alone the questionnaire can now be reached the same day the protocol
  /// starts. [daysSinceProtocolStart] still records how long it actually
  /// took, which is the figure that matters when reading the results back.
  bool get isIqolAvailable => _completedWeeks.isNotEmpty;

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
    currentPlan = _plans[week] ??= WeeklyPlan.forProtocol(_protocol, week);
    currentDayIndex = _firstIncompleteDay(currentPlan!);
    currentSessionIndex = _firstIncompleteSession();
    _resetTimer();
    notifyListeners();
  }

  void selectDay(int dayIndex) {
    if (currentPlan == null) return;
    currentDayIndex = dayIndex;
    currentSessionIndex = _firstIncompleteSession();
    _resetTimer();
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
        if (weekNum < 1 || weekNum > 8) continue;
        final basePlan = WeeklyPlan.forProtocol(_protocol, weekNum);

        final days = basePlan.days.map((day) {
          final completedSessions = daySessionMap[day.dayNumber] ?? {};
          final sessions = day.sessions
              .map(
                (session) => session.copyWith(
                  isCompleted: completedSessions.contains(
                    session.sessionNumber,
                  ),
                ),
              )
              .toList();
          return DayPlan(dayNumber: day.dayNumber, sessions: sessions);
        }).toList();

        final plan = WeeklyPlan(
          weekNumber: weekNum,
          days: days,
          daysPerWeek: basePlan.daysPerWeek,
          progressionFocus: basePlan.progressionFocus,
        );

        if (plan.isCompleted) _completedWeeks.add(weekNum);
        _plans[weekNum] = plan;
      }

      // The cache was just rebuilt, so any plan on screen is a stale object
      // no longer in it. Re-resolve it, keeping the week the patient was on.
      final openWeek = currentPlan?.weekNumber;
      if (openWeek != null) {
        currentPlan = _plans[openWeek];
        if (currentPlan != null) {
          currentDayIndex = _firstIncompleteDay(currentPlan!);
          currentSessionIndex = _firstIncompleteSession();
          secondsRemaining.value = _secondsForCurrentSession();
        }
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
    final session = currentSession;
    if (session == null || session.isCompleted) return;

    final hold = session.holdSeconds;
    // Items prescribed without a hold — clamshells, leg circles, the quick
    // pelvic floor squeezes — are counted by the patient, not timed. There is
    // nothing to count down, so the detail sheet offers "mark done" instead.
    if (hold == null) return;

    switch (phase) {
      case ExercisePhase.ready:
      case ExercisePhase.finished:
        currentRep = 1;
        phase = ExercisePhase.hold;
        secondsRemaining.value = hold;
      case ExercisePhase.betweenReps:
        currentRep++;
        phase = ExercisePhase.hold;
        secondsRemaining.value = hold;
      case ExercisePhase.hold:
      case ExercisePhase.rest:
        break; // resuming a countdown the patient paused
    }

    isTimerRunning = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 1) {
        secondsRemaining.value--;
        return;
      }
      _advancePhase(session);
    });
  }

  /// Moves to the next part of the rep, or ends the session.
  ///
  /// The timer used to be one flat countdown of reps x (hold + rest) that did
  /// nothing on reaching zero — no cue for when to contract or release, which
  /// is the whole point of a pelvic floor protocol.
  void _advancePhase(ExerciseSession session) {
    final totalReps = session.reps ?? 1;

    if (phase == ExercisePhase.hold) {
      final relax = session.relaxSeconds;
      if (relax != null) {
        phase = ExercisePhase.rest;
        secondsRemaining.value = relax;
        notifyListeners();
        return;
      }
      // No prescribed rest: stop the clock and wait for the patient rather
      // than inventing a gap the document does not give.
      if (currentRep < totalReps) {
        _timer?.cancel();
        isTimerRunning = false;
        phase = ExercisePhase.betweenReps;
        secondsRemaining.value = 0;
        notifyListeners();
        return;
      }
      _finishReps();
      return;
    }

    if (currentRep < totalReps) {
      currentRep++;
      phase = ExercisePhase.hold;
      secondsRemaining.value = session.holdSeconds ?? 0;
      notifyListeners();
      return;
    }

    _finishReps();
  }

  void _finishReps() {
    _timer?.cancel();
    isTimerRunning = false;
    phase = ExercisePhase.finished;
    secondsRemaining.value = 0;
    notifyListeners();
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

    final updatedSessions = day.sessions
        .map(
          (s) => s.sessionNumber == session.sessionNumber
              ? s.copyWith(isCompleted: true)
              : s,
        )
        .toList();

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
      daysPerWeek: plan.daysPerWeek,
      progressionFocus: plan.progressionFocus,
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
          'exercise_key': session.exerciseKey,
          'exercise_name': session.exerciseName,
          'reps': session.reps,
          'hold_seconds': session.holdSeconds,
          'rest_seconds': session.relaxSeconds,
          'completed': true,
          'duration_seconds': _durationSeconds(session),
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

  /// Prescribed seconds of work for [session]: reps x (hold + relax) x sets.
  ///
  /// Zero for items prescribed without a hold, which are counted rather than
  /// timed. Sets are included because one item now covers all of its sets.
  int _durationSeconds(ExerciseSession session) {
    final reps = session.reps ?? 0;
    final hold = session.holdSeconds ?? 0;
    final relax = session.relaxSeconds ?? 0;
    return reps * (hold + relax) * session.sets;
  }

  int _secondsForCurrentSession() {
    final session = currentSession;
    if (session == null) return 0;
    return _durationSeconds(session);
  }

  void _resetTimer() {
    _timer?.cancel();
    isTimerRunning = false;
    phase = ExercisePhase.ready;
    currentRep = 0;
    secondsRemaining.value = _secondsForCurrentSession();
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _plans.clear();
    _completedWeeks.clear();
    _protocol = protocolFor();
    _protocolStartDate = null;
    currentPlan = null;
    currentDayIndex = 0;
    currentSessionIndex = 0;
    isTimerRunning = false;
    phase = ExercisePhase.ready;
    currentRep = 0;
    secondsRemaining.value = 0;
    protocolRevision.value++;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    secondsRemaining.dispose();
    protocolRevision.dispose();
    super.dispose();
  }
}
