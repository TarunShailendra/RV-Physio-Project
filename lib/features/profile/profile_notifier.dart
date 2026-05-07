import 'package:flutter/foundation.dart';

import 'models/profile_model.dart';

class ProfileNotifier extends ChangeNotifier {
  ProfileModel? profile;
  bool isLoading = false;

  Future<void> saveProfile(ProfileModel p) async {
    isLoading = true;
    notifyListeners();

    profile = p;

    isLoading = false;
    notifyListeners();
  }
}
