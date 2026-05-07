class ExerciseSession {
  const ExerciseSession({
    required this.week,
    required this.day,
    required this.exerciseName,
    required this.reps,
    required this.holdSeconds,
    required this.restSeconds,
    required this.isCompleted,
  });

  final int week;
  final int day;
  final String exerciseName;
  final int reps;
  final int holdSeconds;
  final int restSeconds;
  final bool isCompleted;

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'day': day,
      'exerciseName': exerciseName,
      'reps': reps,
      'holdSeconds': holdSeconds,
      'restSeconds': restSeconds,
      'isCompleted': isCompleted,
    };
  }

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      week: json['week'] as int,
      day: json['day'] as int,
      exerciseName: json['exerciseName'] as String,
      reps: json['reps'] as int,
      holdSeconds: json['holdSeconds'] as int,
      restSeconds: json['restSeconds'] as int,
      isCompleted: json['isCompleted'] as bool,
    );
  }
}

class WeeklyPlan {
  const WeeklyPlan({
    required this.weekNumber,
    required this.sessions,
    required this.difficultyLabel,
  });

  final int weekNumber;
  final List<ExerciseSession> sessions;
  final String difficultyLabel;

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
      sessions: List.generate(
        5,
        (index) => ExerciseSession(
          week: week,
          day: index + 1,
          exerciseName: config.exerciseName,
          reps: config.reps,
          holdSeconds: config.holdSeconds,
          restSeconds: config.restSeconds,
          isCompleted: false,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekNumber': weekNumber,
      'sessions': sessions.map((session) => session.toJson()).toList(),
      'difficultyLabel': difficultyLabel,
    };
  }

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyPlan(
      weekNumber: json['weekNumber'] as int,
      sessions: (json['sessions'] as List)
          .map(
            (session) =>
                ExerciseSession.fromJson(session as Map<String, dynamic>),
          )
          .toList(),
      difficultyLabel: json['difficultyLabel'] as String,
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
