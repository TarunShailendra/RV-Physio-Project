import '../../../core/utils/supabase_row.dart';

class ICIQModel {
  const ICIQModel({
    this.leakFrequency = unanswered,
    this.leakAmount = unanswered,
    this.lifeInterference = unanswered,
    this.whenLeaks = const [],
    this.dob,
    this.gender,
  });

  /// Marks a question the patient has not answered yet. Valid scale answers
  /// start at 0, so this cannot collide with a real response.
  ///
  /// leakAmount used to default to 1 instead, which meant "has this been
  /// answered?" was always true for it: the question could be tapped straight
  /// past and was then recorded as "1 - none".
  static const int unanswered = -1;

  final int leakFrequency;
  final int leakAmount;
  final int lifeInterference;
  final List<String> whenLeaks;
  final DateTime? dob;
  final String? gender;

  bool get hasLeakFrequency => leakFrequency != unanswered;
  bool get hasLeakAmount => leakAmount != unanswered;
  bool get hasLifeInterference => lifeInterference != unanswered;
  bool get hasWhenLeaks => whenLeaks.isNotEmpty;

  /// Every required question has a response. The questionnaire should not be
  /// scored or saved before this holds.
  bool get isComplete =>
      hasLeakFrequency && hasLeakAmount && hasLifeInterference && hasWhenLeaks;

  int get iciqScore {
    final lf = leakFrequency < 0 ? 0 : leakFrequency;
    final la = leakAmount < 0 ? 0 : leakAmount;
    final li = lifeInterference < 0 ? 0 : lifeInterference;
    return lf + la + li;
  }

  String get severityBand {
    final score = iciqScore;
    if (score <= 7) return 'mild';
    if (score <= 14) return 'moderate';
    return 'severe';
  }

  ICIQModel copyWith({
    int? leakFrequency,
    int? leakAmount,
    int? lifeInterference,
    List<String>? whenLeaks,
    DateTime? dob,
    String? gender,
  }) {
    return ICIQModel(
      leakFrequency: leakFrequency ?? this.leakFrequency,
      leakAmount: leakAmount ?? this.leakAmount,
      lifeInterference: lifeInterference ?? this.lifeInterference,
      whenLeaks: whenLeaks ?? this.whenLeaks,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leakFrequency': leakFrequency,
      'leakAmount': leakAmount,
      'lifeInterference': lifeInterference,
      'whenLeaks': whenLeaks,
      'dob': dob?.toIso8601String(),
      'gender': gender,
      'iciqScore': iciqScore,
    };
  }

  /// Rebuilds the questionnaire from a row of `public.iciq_results`.
  ///
  /// Column names are snake_case here, unlike [ICIQModel.fromJson], which reads
  /// the camelCase shape produced by [toJson].
  factory ICIQModel.fromSupabaseRow(Map<String, dynamic> row) {
    return ICIQModel(
      leakFrequency: asInt(row['leak_frequency']) ?? unanswered,
      leakAmount: asInt(row['leak_amount']) ?? unanswered,
      lifeInterference: asInt(row['life_interference']) ?? unanswered,
      whenLeaks: asStringList(row['when_leaks']),
    );
  }

  factory ICIQModel.fromJson(Map<String, dynamic> json) {
    return ICIQModel(
      leakFrequency: json['leakFrequency'] as int? ?? unanswered,
      leakAmount: json['leakAmount'] as int? ?? unanswered,
      lifeInterference: json['lifeInterference'] as int? ?? unanswered,
      whenLeaks: List<String>.from(json['whenLeaks'] as List? ?? const []),
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      gender: json['gender'] as String?,
    );
  }
}