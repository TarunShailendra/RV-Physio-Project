class IQOLModel {
  const IQOLModel({
    this.items = const [],
    this.durationYears = 0,
    this.durationMonths = 0,
    this.severity = 1,
    this.stressLeak = false,
    this.urgeLeak = false,
    this.freqCode = 0,
  });

  final List<int> items;
  final int durationYears;
  final int durationMonths;
  final int severity;
  final bool stressLeak;
  final bool urgeLeak;
  final int freqCode;

  bool get isComplete =>
      items.length == 22 && items.every((item) => item >= 1 && item <= 5);

  double get score {
    final normalizedItems = List<int>.generate(
      22,
      (index) => index < items.length ? items[index] : 1,
    );
    final sum = normalizedItems.fold<int>(0, (total, item) => total + item);
    return ((sum - 22) / 88) * 100;
  }

  IQOLModel copyWith({
    List<int>? items,
    int? durationYears,
    int? durationMonths,
    int? severity,
    bool? stressLeak,
    bool? urgeLeak,
    int? freqCode,
  }) {
    return IQOLModel(
      items: items ?? this.items,
      durationYears: durationYears ?? this.durationYears,
      durationMonths: durationMonths ?? this.durationMonths,
      severity: severity ?? this.severity,
      stressLeak: stressLeak ?? this.stressLeak,
      urgeLeak: urgeLeak ?? this.urgeLeak,
      freqCode: freqCode ?? this.freqCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items,
      'durationYears': durationYears,
      'durationMonths': durationMonths,
      'severity': severity,
      'stressLeak': stressLeak,
      'urgeLeak': urgeLeak,
      'freqCode': freqCode,
      'score': score,
    };
  }

  factory IQOLModel.fromJson(Map<String, dynamic> json) {
    return IQOLModel(
      items: List<int>.from(json['items'] as List? ?? const []),
      durationYears: json['durationYears'] as int? ?? 0,
      durationMonths: json['durationMonths'] as int? ?? 0,
      severity: json['severity'] as int? ?? 1,
      stressLeak: json['stressLeak'] as bool? ?? false,
      urgeLeak: json['urgeLeak'] as bool? ?? false,
      freqCode: json['freqCode'] as int? ?? 0,
    );
  }
}
