class IciqResult {
  const IciqResult({
    required this.score,
    required this.severity,
    required this.timestamp,
    required this.diagnosticFlags,
  });

  final int score;
  final String severity;
  final DateTime timestamp;
  final List<String> diagnosticFlags;

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'diagnosticFlags': diagnosticFlags,
    };
  }

  factory IciqResult.fromJson(Map<String, dynamic> json) {
    return IciqResult(
      score: json['score'] as int,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      diagnosticFlags: List<String>.from(json['diagnosticFlags'] as List),
    );
  }
}
