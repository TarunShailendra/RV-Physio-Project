import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ipaq_model.dart';

/// The four questions the IPAQ short form asks about.
enum IpaqQuestion { sitting, walking, moderate, vigorous }

class IpaqNotifier extends ChangeNotifier {
  IPAQModel model = const IPAQModel();

  /// Questions the patient has responded to.
  ///
  /// Tracked separately from the values because 0 is a legitimate answer to
  /// every one of them — "no days of vigorous activity" is the expected
  /// response for much of this app's population. The screen used to require
  /// days > 0 to advance, so a sedentary patient could not complete the
  /// questionnaire without entering something untrue.
  final Set<IpaqQuestion> _answered = {};

  bool isAnswered(IpaqQuestion question) => _answered.contains(question);

  void updateSitting({int? hours, int? mins}) {
    _answered.add(IpaqQuestion.sitting);
    model = model.copyWith(sittingHours: hours, sittingMins: mins);
    notifyListeners();
  }

  void updateWalking({int? days, int? hours, int? mins}) {
    _answered.add(IpaqQuestion.walking);
    model = model.copyWith(walkDays: days, walkHours: hours, walkMins: mins);
    computeActivityLevel();
  }

  void updateModerate({int? days, int? hours, int? mins}) {
    _answered.add(IpaqQuestion.moderate);
    model = model.copyWith(
      moderateDays: days,
      moderateHours: hours,
      moderateMins: mins,
    );
    computeActivityLevel();
  }

  void updateVigorous({int? days, int? hours, int? mins}) {
    _answered.add(IpaqQuestion.vigorous);
    model = model.copyWith(
      vigorousDays: days,
      vigorousHours: hours,
      vigorousMins: mins,
    );
    computeActivityLevel();
  }

  IPAQActivityLevel computeActivityLevel() {
    // Classification lives on IPAQModel so that a questionnaire restored from
    // Supabase is scored by exactly the same rules as one filled in here.
    final level = model.computedActivityLevel;
    model = model.copyWith(activityLevel: level);
    notifyListeners();
    return level;
  }

  /// Clears the in-progress questionnaire when the session ends.
  void reset() {
    model = const IPAQModel();
    _answered.clear();
    notifyListeners();
  }

  Future<IPAQModel> submit() async {
    if (Supabase.instance.client.auth.currentUser == null) return model;
    return model;
  }
}
