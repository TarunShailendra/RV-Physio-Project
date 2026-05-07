class DashboardModel {
  const DashboardModel({
    required this.currentWeek,
    this.totalWeeks = 8,
    required this.exercisesCompletedThisWeek,
    required this.exercisesTargetThisWeek,
    required this.adherencePercentage,
    required this.iciqScorePre,
    required this.iciqScorePost,
    required this.weeklyAdherence,
  });

  final int currentWeek;
  final int totalWeeks;
  final int exercisesCompletedThisWeek;
  final int exercisesTargetThisWeek;
  final double adherencePercentage;
  final int iciqScorePre;
  final int iciqScorePost;
  final List<double> weeklyAdherence;

  DashboardModel copyWith({
    int? currentWeek,
    int? totalWeeks,
    int? exercisesCompletedThisWeek,
    int? exercisesTargetThisWeek,
    double? adherencePercentage,
    int? iciqScorePre,
    int? iciqScorePost,
    List<double>? weeklyAdherence,
  }) {
    return DashboardModel(
      currentWeek: currentWeek ?? this.currentWeek,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      exercisesCompletedThisWeek:
          exercisesCompletedThisWeek ?? this.exercisesCompletedThisWeek,
      exercisesTargetThisWeek:
          exercisesTargetThisWeek ?? this.exercisesTargetThisWeek,
      adherencePercentage: adherencePercentage ?? this.adherencePercentage,
      iciqScorePre: iciqScorePre ?? this.iciqScorePre,
      iciqScorePost: iciqScorePost ?? this.iciqScorePost,
      weeklyAdherence: weeklyAdherence ?? this.weeklyAdherence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentWeek': currentWeek,
      'totalWeeks': totalWeeks,
      'exercisesCompletedThisWeek': exercisesCompletedThisWeek,
      'exercisesTargetThisWeek': exercisesTargetThisWeek,
      'adherencePercentage': adherencePercentage,
      'iciqScorePre': iciqScorePre,
      'iciqScorePost': iciqScorePost,
      'weeklyAdherence': weeklyAdherence,
    };
  }

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      currentWeek: json['currentWeek'] as int,
      totalWeeks: json['totalWeeks'] as int? ?? 8,
      exercisesCompletedThisWeek: json['exercisesCompletedThisWeek'] as int,
      exercisesTargetThisWeek: json['exercisesTargetThisWeek'] as int,
      adherencePercentage: (json['adherencePercentage'] as num).toDouble(),
      iciqScorePre: json['iciqScorePre'] as int,
      iciqScorePost: json['iciqScorePost'] as int,
      weeklyAdherence: (json['weeklyAdherence'] as List)
          .map((value) => (value as num).toDouble())
          .toList(),
    );
  }
}
