class ExerciseSession {
 const ExerciseSession({
 required this.week,
 required this.day,
 required this.sessionNumber,
 required this.exerciseName,
 required this.reps,
 required this.holdSeconds,
 required this.restSeconds,
 required this.isCompleted,
 });

 final int week;
 final int day;
 final int sessionNumber;
 final String exerciseName;
 final int reps;
 final int holdSeconds;
 final int restSeconds;
 final bool isCompleted;
}

class DayPlan {
 const DayPlan({
 required this.dayNumber,
 required this.sessions,
 });

 final int dayNumber;
 final List<ExerciseSession> sessions;

 bool get isCompleted => sessions.every((s) => s.isCompleted);
 int get completedCount => sessions.where((s) => s.isCompleted).length;
}

class WeeklyPlan {
 const WeeklyPlan({
 required this.weekNumber,
 required this.days,
 required this.difficultyLabel,
 });

 final int weekNumber;
 final List<DayPlan> days;
 final String difficultyLabel;

 bool get isCompleted => days.every((d) => d.isCompleted);
 int get completedDays => days.where((d) => d.isCompleted).length;

 static WeeklyPlan getWeekPlan(int week) {
 final config = switch (week) {
 1 || 2 => const _WeeklyPlanConfig(
 exerciseName: 'Pelvic Floor Contraction',
 reps: 10,
 holdSeconds: 5,
 restSeconds: 5,
 difficultyLabel: 'Beginner',
 ),
 3 || 4 => const _WeeklyPlanConfig(
 exerciseName: 'Extended Hold Contraction',
 reps: 10,
 holdSeconds: 8,
 restSeconds: 4,
 difficultyLabel: 'Beginner',
 ),
 5 || 6 => const _WeeklyPlanConfig(
 exerciseName: 'Rapid Contractions',
 reps: 15,
 holdSeconds: 3,
 restSeconds: 3,
 difficultyLabel: 'Intermediate',
 ),
 7 || 8 => const _WeeklyPlanConfig(
 exerciseName: 'Advanced Hold + Rapid Mix',
 reps: 20,
 holdSeconds: 10,
 restSeconds: 3,
 difficultyLabel: 'Advanced',
 ),
 _ => throw ArgumentError.value(week, 'week', 'Must be between 1 and 8'),
 };

 return WeeklyPlan(
 weekNumber: week,
 difficultyLabel: config.difficultyLabel,
 days: List.generate(7, (dayIndex) => DayPlan(
 dayNumber: dayIndex + 1,
 sessions: List.generate(5, (sessionIndex) => ExerciseSession(
 week: week,
 day: dayIndex + 1,
 sessionNumber: sessionIndex + 1,
 exerciseName: config.exerciseName,
 reps: config.reps,
 holdSeconds: config.holdSeconds,
 restSeconds: config.restSeconds,
 isCompleted: false,
 )),
 )),
 );
 }
}

class _WeeklyPlanConfig {
 const _WeeklyPlanConfig({
 required this.exerciseName,
 required this.reps,
 required this.holdSeconds,
 required this.restSeconds,
 required this.difficultyLabel,
 });

 final String exerciseName;
 final int reps;
 final int holdSeconds;
 final int restSeconds;
 final String difficultyLabel;
}
