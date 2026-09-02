import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/ipaq_model.dart';

class IpaqNotifier extends ChangeNotifier {
  IPAQModel model = const IPAQModel();

  void updateSitting({int? hours, int? mins}) {
    model = model.copyWith(sittingHours: hours, sittingMins: mins);
    notifyListeners();
  }

  void updateWalking({int? days, int? hours, int? mins}) {
    model = model.copyWith(walkDays: days, walkHours: hours, walkMins: mins);
    computeActivityLevel();
  }

  void updateModerate({int? days, int? hours, int? mins}) {
    model = model.copyWith(
      moderateDays: days,
      moderateHours: hours,
      moderateMins: mins,
    );
    computeActivityLevel();
  }

  void updateVigorous({int? days, int? hours, int? mins}) {
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

  Future<IPAQModel> submit() async {
    if (Supabase.instance.client.auth.currentUser == null) return model;
    return model;
  }
}
