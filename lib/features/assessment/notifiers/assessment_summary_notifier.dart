import 'package:flutter/foundation.dart';

import '../models/iciq_model.dart';
import '../models/ipaq_model.dart';
import '../models/iqol_model.dart';

class AssessmentSummaryNotifier extends ChangeNotifier {
  ICIQModel? iciq;
  IQOLModel? iqol;
  IPAQModel? ipaq;

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

  void saveIciq(ICIQModel value) {
    iciq = value;
    notifyListeners();
  }

  void saveIqol(IQOLModel value) {
    iqol = value;
    notifyListeners();
  }

  void saveIpaq(IPAQModel value) {
    ipaq = value;
    notifyListeners();
  }
}
