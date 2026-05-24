class ICIQModel {
  const ICIQModel({
    this.leakFrequency = -1,
    this.leakAmount = 1,
    this.lifeInterference = -1,
    this.whenLeaks = const [],
    this.dob,
    this.gender,
  });

  // -1 = not yet answered by the user; valid scale answers start at 0
  final int leakFrequency;
  final int leakAmount;
  final int lifeInterference;
  final List<String> whenLeaks;
  final DateTime? dob;
  final String? gender;

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

  factory ICIQModel.fromJson(Map<String, dynamic> json) {
    return ICIQModel(
      leakFrequency: json['leakFrequency'] as int? ?? -1,
      leakAmount: json['leakAmount'] as int? ?? -1,
      lifeInterference: json['lifeInterference'] as int? ?? -1,
      whenLeaks: List<String>.from(json['whenLeaks'] as List? ?? const []),
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      gender: json['gender'] as String?,
    );
  }
}