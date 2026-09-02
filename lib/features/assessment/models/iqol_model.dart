import '../../../core/utils/supabase_row.dart';

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

  /// The 22 item columns on `public.iqol_results`, in questionnaire order.
  static const List<String> itemColumns = [
    'q1', 'q2', 'q3', 'q4', 'q5', 'q6', 'q7', 'q8', 'q9', 'q10', 'q11',
    'q12', 'q13', 'q14', 'q15', 'q16', 'q17', 'q18', 'q19', 'q20', 'q21', 'q22',
  ];

  /// Rebuilds the questionnaire from a row of `public.iqol_results`.
  ///
  /// `iqol_score` is not stored (it is dropped from the insert payload in
  /// AssessmentSummaryNotifier.saveIqol), but it does not need to be — [score]
  /// is derived from the items restored here.
  factory IQOLModel.fromSupabaseRow(Map<String, dynamic> row) {
    return IQOLModel(
      items: [
        for (final column in itemColumns) asInt(row[column]) ?? 0,
      ],
      durationYears: asInt(row['duration_years']) ?? 0,
      durationMonths: asInt(row['duration_months']) ?? 0,
      severity: asInt(row['severity']) ?? 1,
      stressLeak: asBool(row['stress_leak']),
      urgeLeak: asBool(row['urge_leak']),
      freqCode: asInt(row['freq_code']) ?? 0,
    );
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
