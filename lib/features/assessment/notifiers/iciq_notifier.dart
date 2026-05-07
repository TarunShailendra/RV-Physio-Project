import 'package:flutter/foundation.dart';

import '../models/iciq_model.dart';

class IciqNotifier extends ChangeNotifier {
  ICIQModel model = const ICIQModel();

  int get score => model.iciqScore;
  String get severityBand => model.severityBand;

  void setDob(DateTime value) {
    model = model.copyWith(dob: value);
    notifyListeners();
  }

  void setGender(String value) {
    model = model.copyWith(gender: value);
    notifyListeners();
  }

  void setLeakFrequency(int value) {
    model = model.copyWith(leakFrequency: value);
    notifyListeners();
  }

  void setLeakAmount(int value) {
    model = model.copyWith(leakAmount: value);
    notifyListeners();
  }

  void setLifeInterference(int value) {
    model = model.copyWith(lifeInterference: value);
    notifyListeners();
  }

  void toggleWhenLeak(String value) {
    final updated = [...model.whenLeaks];
    updated.contains(value) ? updated.remove(value) : updated.add(value);
    model = model.copyWith(whenLeaks: updated);
    notifyListeners();
  }

  ICIQModel submit() => model;
}
