import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/iciq_model.dart';
import '../models/ipaq_model.dart';
import '../models/iqol_model.dart';

/// What happened to a save. The screens need to tell these apart: a rejected
/// write is worth retrying, a lapsed session is not.
enum AssessmentSaveResult { saved, notSignedIn, incomplete, failed }

class AssessmentSummaryNotifier extends ChangeNotifier {
  ICIQModel? iciq;
  IQOLModel? iqol;
  IPAQModel? ipaq;

  // Resolved lazily. As an eager field initialiser this threw whenever the
  // notifier was built before Supabase.initialize(), which made the class
  // impossible to construct in a test and made AppProviders' own
  // `?? AssessmentSummaryNotifier()` fallback unusable.
  SupabaseClient get _client => Supabase.instance.client;

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

  /// Saves the ICIQ.
  ///
  /// The in-memory value is set only once the write lands. Setting it first
  /// meant a failed save still left the app — and the route guard — believing
  /// the questionnaire was done.
  ///
  /// Answers are sent as given. They used to be clamped with `< 0 ? 0 :`,
  /// which stored an unanswered question as the mildest possible response,
  /// indistinguishable in the database from a genuinely asymptomatic patient.
  Future<AssessmentSaveResult> saveIciq(ICIQModel value) async {
    if (!value.isComplete) return AssessmentSaveResult.incomplete;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return AssessmentSaveResult.notSignedIn;

    try {
      await _client.from('iciq_results').insert({
        'user_id': userId,
        'leak_frequency': value.leakFrequency,
        'leak_amount': value.leakAmount,
        'life_interference': value.lifeInterference,
        'when_leaks': value.whenLeaks,
      });
    } catch (e) {
      debugPrint('ICIQ save error: $e');
      return AssessmentSaveResult.failed;
    }

    iciq = value;
    notifyListeners();
    return AssessmentSaveResult.saved;
  }

  Future<AssessmentSaveResult> saveIqol(IQOLModel value) async {
    if (!value.isComplete) return AssessmentSaveResult.incomplete;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return AssessmentSaveResult.notSignedIn;

    try {
      final qMap = <String, dynamic>{
        for (var i = 0; i < IQOLModel.itemColumns.length; i++)
          IQOLModel.itemColumns[i]: value.items[i],
      };
      await _client.from('iqol_results').insert({
        'user_id': userId,
        ...qMap,
        'duration_years': value.durationYears,
        'duration_months': value.durationMonths,
        'severity': value.severity,
        'stress_leak': value.stressLeak,
        'urge_leak': value.urgeLeak,
        'freq_code': value.freqCode,
        // `iqol_score` is deliberately absent: it is a generated column in
        // Postgres, which rejects an insert that supplies a value for one
        // (SQLSTATE 428C9). The database derives it from the items above.
      });
    } catch (e) {
      debugPrint('IQOL save error: $e');
      return AssessmentSaveResult.failed;
    }

    iqol = value;
    notifyListeners();
    return AssessmentSaveResult.saved;
  }

  Future<AssessmentSaveResult> saveIpaq(IPAQModel value) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return AssessmentSaveResult.notSignedIn;

    try {
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
        // `activity_level` is deliberately absent: it is a generated column in
        // Postgres, which rejects an insert that supplies a value for one
        // (SQLSTATE 428C9). The database derives it from the answers above,
        // and IPAQModel.fromSupabaseRow recomputes it on the way back out.
      });
    } catch (e) {
      debugPrint('IPAQ save error: $e');
      return AssessmentSaveResult.failed;
    }

    ipaq = value;
    notifyListeners();
    return AssessmentSaveResult.saved;
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
