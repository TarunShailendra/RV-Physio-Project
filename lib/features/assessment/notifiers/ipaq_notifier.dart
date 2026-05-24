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
    final level = _classifyActivity();
    model = model.copyWith(activityLevel: level);
    notifyListeners();
    return level;
  }

  IPAQActivityLevel _classifyActivity() {
    final activeDays = model.walkDays + model.moderateDays + model.vigorousDays;
    if (model.vigorousDays >= 3 && model.totalMetMinutes >= 1500) {
      return IPAQActivityLevel.high;
    }
    if (activeDays >= 7 && model.totalMetMinutes >= 3000) {
      return IPAQActivityLevel.high;
    }
    if (model.vigorousDays >= 3 && model.totalVigorousMins >= 20) {
      return IPAQActivityLevel.moderate;
    }
    if (model.moderateDays >= 5 && model.totalModerateMins >= 30) {
      return IPAQActivityLevel.moderate;
    }
    if (model.walkDays >= 5 && model.totalWalkMins >= 30) {
      return IPAQActivityLevel.moderate;
    }
    if (activeDays >= 5 && model.totalMetMinutes >= 600) {
      return IPAQActivityLevel.moderate;
    }
    return IPAQActivityLevel.low;
  }

  Future<IPAQModel> submit() async {
    if (Supabase.instance.client.auth.currentUser == null) return model;
    return model;
  }
}
