import 'package:flutter/foundation.dart';

import '../models/iqol_model.dart';

class IqolNotifier extends ChangeNotifier {
  IQOLModel model = IQOLModel(items: List<int>.filled(22, 0));

  double get score => model.score;

  void updateItem(int index, int value) {
    if (index < 0 || index >= 22) return;
    final items = [...model.items];
    items[index] = value;
    model = model.copyWith(items: items);
    notifyListeners();
  }

  void updateBackground({
    int? durationYears,
    int? durationMonths,
    int? severity,
    bool? stressLeak,
    bool? urgeLeak,
    int? freqCode,
  }) {
    model = model.copyWith(
      durationYears: durationYears,
      durationMonths: durationMonths,
      severity: severity,
      stressLeak: stressLeak,
      urgeLeak: urgeLeak,
      freqCode: freqCode,
    );
    notifyListeners();
  }

  IQOLModel submit() => model;
}
