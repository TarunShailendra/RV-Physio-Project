class ICIQModel {
  const ICIQModel({
    this.leakFrequency = 0,
    this.leakAmount = 0,
    this.lifeInterference = 0,
    this.whenLeaks = const [],
    this.dob,
    this.gender,
  });

  final int leakFrequency;
  final int leakAmount;
  final int lifeInterference;
  final List<String> whenLeaks;
  final DateTime? dob;
  final String? gender;

  int get iciqScore => leakFrequency + leakAmount + lifeInterference;

  String get severityBand {
    if (iciqScore <= 7) return 'mild';
    if (iciqScore <= 14) return 'moderate';
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
      leakFrequency: json['leakFrequency'] as int? ?? 0,
      leakAmount: json['leakAmount'] as int? ?? 0,
      lifeInterference: json['lifeInterference'] as int? ?? 0,
      whenLeaks: List<String>.from(json['whenLeaks'] as List? ?? const []),
      dob: json['dob'] == null ? null : DateTime.parse(json['dob'] as String),
      gender: json['gender'] as String?,
    );
  }
}
