import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/user_model.dart';
import '../assessment/notifiers/assessment_summary_notifier.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({AssessmentSummaryNotifier? assessmentNotifier}) : _assessmentNotifier = assessmentNotifier;

  final AssessmentSummaryNotifier? _assessmentNotifier;

  SupabaseClient get _supabase => Supabase.instance.client;

  String? token;
  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user != null) {
        final profileRow = await _supabase
            .from('profiles')
            .select('full_name, city, date_of_birth, phone, email')
            .eq('id', user.id)
            .maybeSingle();

        final fullName = profileRow?['full_name']?.toString().trim() ?? '';
        final city = profileRow?['city']?.toString().trim() ?? '';
        final isProfileComplete = fullName.isNotEmpty && city.isNotEmpty;

        currentUser = UserModel(
          id: user.id,
          name: fullName.isNotEmpty ? fullName : user.email ?? email.trim(),
          email: profileRow?['email']?.toString() ?? user.email ?? email.trim(),
          phone: profileRow?['phone']?.toString() ?? '',
          age: 0,
          dateOfBirth: _parseDate(profileRow?['date_of_birth']),
          isProfileComplete: isProfileComplete,
        );

        // Update assessment completion status from Supabase for this user
        await _assessmentNotifier?.checkCompletedAssessments();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(
    String fullName,
    String email,
    String password,
    String phone,
    int age, {
    String? dob,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim(), 'phone': phone.trim()},
      );
      final user = response.user;
      if (user != null) {
        DateTime? parsedDob;
        if (dob != null && dob.isNotEmpty) {
          final parts = dob.split('/');
          if (parts.length == 3) {
            parsedDob = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }

        await _supabase.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'email': email.trim(),
          'date_of_birth': parsedDob?.toIso8601String().split('T').first,
        }, onConflict: 'id');

        currentUser = UserModel(
          id: user.id,
          name: fullName.trim(),
          email: email.trim(),
          phone: phone.trim(),
          age: age,
          dob: dob,
          dateOfBirth: parsedDob,
        );

        // Update assessment completion status from Supabase for this user
        await _assessmentNotifier?.checkCompletedAssessments();
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
