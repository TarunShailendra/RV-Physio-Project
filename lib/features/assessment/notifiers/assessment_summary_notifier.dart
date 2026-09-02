import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/iciq_model.dart';
import '../models/ipaq_model.dart';
import '../models/iqol_model.dart';

class AssessmentSummaryNotifier extends ChangeNotifier {
  ICIQModel? iciq;
  IQOLModel? iqol;
  IPAQModel? ipaq;

  final _client = Supabase.instance.client;

  int get recommendedStartWeek {
    final iciqScore = iciq?.iciqScore;
    final iqolScore = iqol?.score;
    final activityLevel = ipaq?.activityLevel;
    final hasSevereSymptoms = iciqScore != null && iciqScore >= 15;
    final hasLowerQualityOfLife = iqolScore != null && iqolScore < 50;
    if (hasSevereSymptoms ||
        hasLowerQualityOfLife ||
        activityLevel == IPAQActivityLevel.low) {
      return 1;
    }
    if (activityLevel == IPAQActivityLevel.high &&
        (iciqScore == null || iciqScore <= 7) &&
        (iqolScore == null || iqolScore >= 75)) {
      return 3;
    }
    if ((activityLevel == IPAQActivityLevel.moderate ||
            activityLevel == IPAQActivityLevel.high ||
            (iqolScore != null && iqolScore >= 75)) &&
        (iciqScore == null || iciqScore <= 14) &&
        (iqolScore == null || iqolScore >= 60)) {
      return 2;
    }
    return 1;
  }

  Future<void> saveIciq(ICIQModel value) async {
    iciq = value;
    notifyListeners();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      await _client.from('iciq_results').insert({
  'user_id': userId,
  'leak_frequency': value.leakFrequency < 0 ? 0 : value.leakFrequency,
  'leak_amount': value.leakAmount < 0 ? 0 : value.leakAmount,
  'life_interference': value.lifeInterference < 0 ? 0 : value.lifeInterference,
  'when_leaks': value.whenLeaks,
});
      debugPrint('ICIQ saved successfully');
    } catch (e) {
      debugPrint('ICIQ save error: $e');
    }
  }

  Future<void> saveIqol(IQOLModel value) async {
    iqol = value;
    notifyListeners();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      // Build q1-q22 map from items list
      final Map<String, dynamic> qMap = {};
      for (int i = 0; i < 22; i++) {
        qMap['q${i + 1}'] = i < value.items.length ? value.items[i] : 0;
      }
      await _client.from('iqol_results').insert({
  'user_id': userId,
  ...qMap,
  'duration_years': value.durationYears,
  'duration_months': value.durationMonths,
  'severity': value.severity,
  'stress_leak': value.stressLeak,
  'urge_leak': value.urgeLeak,
  'freq_code': value.freqCode,
  // removed: iqol_score
});
      debugPrint('IQOL saved successfully');
    } catch (e) {
      debugPrint('IQOL save error: $e');
    }
  }

  Future<void> saveIpaq(IPAQModel value) async {
    ipaq = value;
    notifyListeners();
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;
      await _client.from('ipaq_results').insert({
  'user_id': userId,
  'sitting_hours': value.sittingHours,
  'sitting_mins': value.sittingMins,
  'walk_days': value.walkDays,
  'walk_hours': value.walkHours,
  'walk_mins': value.walkMins,
  'moderate_days': value.moderateDays,
  'moderate_hours': value.moderateHours,
  'moderate_mins': value.moderateMins,
  'vigorous_days': value.vigorousDays,
  'vigorous_hours': value.vigorousHours,
  'vigorous_mins': value.vigorousMins,
  // removed: activity_level
});
      debugPrint('IPAQ saved successfully');
    } catch (e) {
      debugPrint('IPAQ save error: $e');
    }
  }

  /// Restores each questionnaire's most recent submission from Supabase.
  ///
  /// A questionnaire with no stored row is reset to null rather than left as
  /// it was, so this is authoritative: signing in as a different patient
  /// cannot leave the previous one's results in memory.
  ///
  /// Each questionnaire is loaded in its own try/catch so that one unreadable
  /// table does not discard the other two. On failure the in-memory value is
  /// left untouched, so a transient network error does not wipe results that
  /// were already loaded.
  Future<void> checkCompletedAssessments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      iciq = await _fetchIciq(userId);
    } catch (e) {
      debugPrint('ICIQ restore failed: $e');
    }

    try {
      ipaq = await _fetchIpaq(userId);
    } catch (e) {
      debugPrint('IPAQ restore failed: $e');
    }

    try {
      iqol = await _fetchIqol(userId);
    } catch (e) {
      debugPrint('IQOL restore failed: $e');
    }

    notifyListeners();
  }

  // Assessments are inserted rather than upserted, so a patient who retakes
  // one has several rows. Newest wins.
  Future<ICIQModel?> _fetchIciq(String userId) async {
    final row = await _client
        .from('iciq_results')
        .select('leak_frequency, leak_amount, life_interference, when_leaks')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return row == null ? null : ICIQModel.fromSupabaseRow(row);
  }

  Future<IPAQModel?> _fetchIpaq(String userId) async {
    final row = await _client
        .from('ipaq_results')
        .select(
          'sitting_hours, sitting_mins, '
          'walk_days, walk_hours, walk_mins, '
          'moderate_days, moderate_hours, moderate_mins, '
          'vigorous_days, vigorous_hours, vigorous_mins',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return row == null ? null : IPAQModel.fromSupabaseRow(row);
  }

  Future<IQOLModel?> _fetchIqol(String userId) async {
    final columns = [
      ...IQOLModel.itemColumns,
      'duration_years',
      'duration_months',
      'severity',
      'stress_leak',
      'urge_leak',
      'freq_code',
    ].join(', ');

    final row = await _client
        .from('iqol_results')
        .select(columns)
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    return row == null ? null : IQOLModel.fromSupabaseRow(row);
  }

  void reset() {
    iciq = null;
    iqol = null;
    ipaq = null;
    notifyListeners();
  }
}