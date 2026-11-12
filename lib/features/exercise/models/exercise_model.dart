import '../protocols/exercise_catalogue.dart';
import 'protocol.dart';

/// One prescribed item of a day's work, as the patient sees and completes it.
///
/// A session used to be one of five identical repeats of a single exercise.
/// Under the protocol document a day is a pelvic floor block plus up to
/// thirteen other exercises, so a session is now one item of that list and
/// [sessionNumber] is its position within the day.
///
/// [reps] and [holdSeconds] are nullable because the document prescribes
/// neither uniformly: diaphragmatic breathing is given without a rep count,
/// and several exercises are explicitly "no hold".
class ExerciseSession {
  const ExerciseSession({
    required this.week,
    required this.day,
    required this.sessionNumber,
    required this.exerciseKey,
    required this.exerciseName,
    required this.sets,
    required this.isCompleted,
    this.reps,
    this.holdSeconds,
    this.relaxSeconds,
    this.position,
  });

  final int week;
  final int day;

  /// One-based index of this item within its day. Written to
  /// exercise_logs.session_number, whose constraint allows 1 to 30.
  final int sessionNumber;

  /// Identifier from [exerciseCatalogue]; also written to the log row so it
  /// stays interpretable if the display name later changes.
  final String exerciseKey;
  final String exerciseName;
  final int? reps;
  final int? holdSeconds;
  final int? relaxSeconds;
  final int sets;
  final ExercisePosition? position;
  final bool isCompleted;

  ExerciseSession copyWith({bool? isCompleted}) => ExerciseSession(
    week: week,
    day: day,
    sessionNumber: sessionNumber,
    exerciseKey: exerciseKey,
    exerciseName: exerciseName,
    sets: sets,
    reps: reps,
    holdSeconds: holdSeconds,
    relaxSeconds: relaxSeconds,
    position: position,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}

class DayPlan {
  const DayPlan({required this.dayNumber, required this.sessions});

  final int dayNumber;
  final List<ExerciseSession> sessions;

  bool get isCompleted =>
      sessions.isNotEmpty && sessions.every((s) => s.isCompleted);
  int get completedCount => sessions.where((s) => s.isCompleted).length;
}

class WeeklyPlan {
  const WeeklyPlan({
    required this.weekNumber,
    required this.days,
    required this.daysPerWeek,
    required this.progressionFocus,
  });

  final int weekNumber;
  final List<DayPlan> days;

  /// Days the patient trains this week: three to five, from the protocol.
  /// This used to be a fixed seven for every patient and every week.
  final int daysPerWeek;

  /// The document's own label for what this stage is working towards, such as
  /// "Baseline activation" or "Functional + dynamic strength".
  final String progressionFocus;

  bool get isCompleted => days.every((d) => d.isCompleted);
  int get completedDays => days.where((d) => d.isCompleted).length;

  /// Expands one week of [protocol] into days of prescribed items.
  ///
  /// Every day within a week-block is identical. The document varies its
  /// prescriptions by block, never by day, and inventing per-day variation
  /// would be inventing clinical content.
  static WeeklyPlan forProtocol(Protocol protocol, int week) {
    final block = protocol.blockForWeek(week);
    return WeeklyPlan(
      weekNumber: week,
      daysPerWeek: block.daysPerWeek,
      progressionFocus: block.progressionFocus,
      days: List.generate(
        block.daysPerWeek,
        (dayIndex) => DayPlan(
          dayNumber: dayIndex + 1,
          sessions: [
            for (var i = 0; i < block.items.length; i++)
              _sessionFor(block.items[i], week, dayIndex + 1, i + 1),
          ],
        ),
      ),
    );
  }

  static ExerciseSession _sessionFor(
    PrescribedItem item,
    int week,
    int day,
    int sessionNumber,
  ) => ExerciseSession(
    week: week,
    day: day,
    sessionNumber: sessionNumber,
    exerciseKey: item.exerciseKey,
    exerciseName: exerciseCatalogue[item.exerciseKey] ?? item.exerciseKey,
    reps: item.reps,
    holdSeconds: item.holdSeconds,
    relaxSeconds: item.relaxSeconds,
    sets: item.sets,
    position: item.position,
    isCompleted: false,
  );
}
