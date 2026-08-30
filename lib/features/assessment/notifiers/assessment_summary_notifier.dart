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
        'iqol_score': value.score,
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
        'walk_met': value.walkingMetMinutes,
        'moderate_met': value.moderateMetMinutes,
        'vigorous_met': value.vigorousMetMinutes,
        'total_met': value.totalMetMinutes,
        'activity_level': value.activityLevel.name,
      });
      debugPrint('IPAQ saved successfully');
    } catch (e) {
      debugPrint('IPAQ save error: $e');
    }
  }

  void reset() {
    iciq = null;
    iqol = null;
    ipaq = null;
    notifyListeners();
  }
}