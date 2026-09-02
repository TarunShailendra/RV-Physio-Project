import '../../../core/utils/supabase_row.dart';

enum IPAQActivityLevel { low, moderate, high }

class IPAQModel {
  const IPAQModel({
    this.sittingHours = 0,
    this.sittingMins = 0,
    this.walkDays = 0,
    this.walkHours = 0,
    this.walkMins = 0,
    this.moderateDays = 0,
    this.moderateHours = 0,
    this.moderateMins = 0,
    this.vigorousDays = 0,
    this.vigorousHours = 0,
    this.vigorousMins = 0,
    this.activityLevel = IPAQActivityLevel.low,
  });

  final int sittingHours;
  final int sittingMins;
  final int walkDays;
  final int walkHours;
  final int walkMins;
  final int moderateDays;
  final int moderateHours;
  final int moderateMins;
  final int vigorousDays;
  final int vigorousHours;
  final int vigorousMins;
  final IPAQActivityLevel activityLevel;

  int get totalWalkMins => (walkHours * 60) + walkMins;
  int get totalModerateMins => (moderateHours * 60) + moderateMins;
  int get totalVigorousMins => (vigorousHours * 60) + vigorousMins;

  double get walkingMetMinutes => 3.3 * totalWalkMins * walkDays;
  double get moderateMetMinutes => 4.0 * totalModerateMins * moderateDays;
  double get vigorousMetMinutes => 8.0 * totalVigorousMins * vigorousDays;
  double get totalMetMinutes =>
      walkingMetMinutes + moderateMetMinutes + vigorousMetMinutes;

  /// IPAQ short-form classification derived from the stored answers.
  ///
  /// This lives on the model rather than in IpaqNotifier because
  /// `activity_level` is not a persisted column — a questionnaire restored
  /// from Supabase has to recompute it, and it must classify identically to
  /// one filled in live.
  IPAQActivityLevel get computedActivityLevel {
    final activeDays = walkDays + moderateDays + vigorousDays;
    if (vigorousDays >= 3 && totalMetMinutes >= 1500) {
      return IPAQActivityLevel.high;
    }
    if (activeDays >= 7 && totalMetMinutes >= 3000) {
      return IPAQActivityLevel.high;
    }
    if (vigorousDays >= 3 && totalVigorousMins >= 20) {
      return IPAQActivityLevel.moderate;
    }
    if (moderateDays >= 5 && totalModerateMins >= 30) {
      return IPAQActivityLevel.moderate;
    }
    if (walkDays >= 5 && totalWalkMins >= 30) {
      return IPAQActivityLevel.moderate;
    }
    if (activeDays >= 5 && totalMetMinutes >= 600) {
      return IPAQActivityLevel.moderate;
    }
    return IPAQActivityLevel.low;
  }

  IPAQModel copyWith({
    int? sittingHours,
    int? sittingMins,
    int? walkDays,
    int? walkHours,
    int? walkMins,
    int? moderateDays,
    int? moderateHours,
    int? moderateMins,
    int? vigorousDays,
    int? vigorousHours,
    int? vigorousMins,
    IPAQActivityLevel? activityLevel,
  }) {
    return IPAQModel(
      sittingHours: sittingHours ?? this.sittingHours,
      sittingMins: sittingMins ?? this.sittingMins,
      walkDays: walkDays ?? this.walkDays,
      walkHours: walkHours ?? this.walkHours,
      walkMins: walkMins ?? this.walkMins,
      moderateDays: moderateDays ?? this.moderateDays,
      moderateHours: moderateHours ?? this.moderateHours,
      moderateMins: moderateMins ?? this.moderateMins,
      vigorousDays: vigorousDays ?? this.vigorousDays,
      vigorousHours: vigorousHours ?? this.vigorousHours,
      vigorousMins: vigorousMins ?? this.vigorousMins,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sittingHours': sittingHours,
      'sittingMins': sittingMins,
      'walkDays': walkDays,
      'walkHours': walkHours,
      'walkMins': walkMins,
      'moderateDays': moderateDays,
      'moderateHours': moderateHours,
      'moderateMins': moderateMins,
      'vigorousDays': vigorousDays,
      'vigorousHours': vigorousHours,
      'vigorousMins': vigorousMins,
      'activityLevel': activityLevel.name,
      'totalMetMinutes': totalMetMinutes,
    };
  }

  /// Rebuilds the questionnaire from a row of `public.ipaq_results`.
  ///
  /// `activity_level` is not stored (it is dropped from the insert payload in
  /// AssessmentSummaryNotifier.saveIpaq), so it is recomputed here from the
  /// restored answers.
  factory IPAQModel.fromSupabaseRow(Map<String, dynamic> row) {
    final restored = IPAQModel(
      sittingHours: asInt(row['sitting_hours']) ?? 0,
      sittingMins: asInt(row['sitting_mins']) ?? 0,
      walkDays: asInt(row['walk_days']) ?? 0,
      walkHours: asInt(row['walk_hours']) ?? 0,
      walkMins: asInt(row['walk_mins']) ?? 0,
      moderateDays: asInt(row['moderate_days']) ?? 0,
      moderateHours: asInt(row['moderate_hours']) ?? 0,
      moderateMins: asInt(row['moderate_mins']) ?? 0,
      vigorousDays: asInt(row['vigorous_days']) ?? 0,
      vigorousHours: asInt(row['vigorous_hours']) ?? 0,
      vigorousMins: asInt(row['vigorous_mins']) ?? 0,
    );
    return restored.copyWith(activityLevel: restored.computedActivityLevel);
  }

  factory IPAQModel.fromJson(Map<String, dynamic> json) {
    return IPAQModel(
      sittingHours: json['sittingHours'] as int? ?? 0,
      sittingMins: json['sittingMins'] as int? ?? 0,
      walkDays: json['walkDays'] as int? ?? 0,
      walkHours: json['walkHours'] as int? ?? 0,
      walkMins: json['walkMins'] as int? ?? 0,
      moderateDays: json['moderateDays'] as int? ?? 0,
      moderateHours: json['moderateHours'] as int? ?? 0,
      moderateMins: json['moderateMins'] as int? ?? 0,
      vigorousDays: json['vigorousDays'] as int? ?? 0,
      vigorousHours: json['vigorousHours'] as int? ?? 0,
      vigorousMins: json['vigorousMins'] as int? ?? 0,
      activityLevel: IPAQActivityLevel.values.byName(
        json['activityLevel'] as String? ?? IPAQActivityLevel.low.name,
      ),
    );
  }
}
