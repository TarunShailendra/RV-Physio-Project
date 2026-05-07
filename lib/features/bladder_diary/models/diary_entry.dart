class DiaryEntry {
  const DiaryEntry({
    required this.time,
    required this.fluidType,
    required this.fluidAmountMl,
    required this.hadUrgency,
    required this.hadLeakage,
    required this.padUsage,
  });

  final DateTime time;
  final String fluidType;
  final double fluidAmountMl;
  final bool hadUrgency;
  final bool hadLeakage;
  final String padUsage;

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'fluidType': fluidType,
      'fluidAmountMl': fluidAmountMl,
      'hadUrgency': hadUrgency,
      'hadLeakage': hadLeakage,
      'padUsage': padUsage,
    };
  }

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      time: DateTime.parse(json['time'] as String),
      fluidType: json['fluidType'] as String,
      fluidAmountMl: (json['fluidAmountMl'] as num).toDouble(),
      hadUrgency: json['hadUrgency'] as bool,
      hadLeakage: json['hadLeakage'] as bool,
      padUsage: json['padUsage'] as String,
    );
  }
}

class DiaryDay {
  const DiaryDay({
    required this.date,
    required this.entries,
  });

  final DateTime date;
  final List<DiaryEntry> entries;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
  }

  factory DiaryDay.fromJson(Map<String, dynamic> json) {
    return DiaryDay(
      date: DateTime.parse(json['date'] as String),
      entries: (json['entries'] as List)
          .map((entry) => DiaryEntry.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}
