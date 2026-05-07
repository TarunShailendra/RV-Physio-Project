import 'package:flutter/foundation.dart';

import 'models/user_model.dart';

class AuthNotifier extends ChangeNotifier {
  String? token;
  UserModel? currentUser;
  bool isLoading = false;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    isLoading = false;
    notifyListeners();
  }

  Future<void> signup(
    String name,
    String email,
    String password,
    String phone,
    int age,
  ) async {
    isLoading = true;
    notifyListeners();

    isLoading = false;
    notifyListeners();
  }
}
