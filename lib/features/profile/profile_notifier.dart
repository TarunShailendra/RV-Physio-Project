import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/profile_model.dart';

class ProfileNotifier extends ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;

  ProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final row = await _supabase
          .from('profiles')
          .select(
            'id, full_name, city, occupation, incontinence_type, symptom_duration_months, has_sought_treatment, date_of_birth, profile_completed_at, phone, email',
          )
          .eq('id', user.id)
          .maybeSingle();
      profile = row == null ? null : ProfileModel.fromJson(row);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile(ProfileModel p) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final completedAt = p.profileCompletedAt ?? DateTime.now();
      final row = {
        'id': p.userId,
        'full_name': p.fullName,
        'city': p.city,
        'occupation': p.occupation,
        'incontinence_type': p.incontinenceType,
        'symptom_duration_months': p.symptomDurationMonths,
        'has_sought_treatment': p.hasSoughtTreatment,
        'date_of_birth': p.dateOfBirth?.toIso8601String().split('T').first,
        'profile_completed_at': completedAt.toIso8601String(),
        'phone': p.phone,
        'email': p.email,
      };

      await _supabase.from('profiles').upsert(row, onConflict: 'id');
      profile = ProfileModel(
        userId: p.userId,
        age: p.age,
        city: p.city,
        occupation: p.occupation,
        incontinenceType: p.incontinenceType,
        symptomDurationMonths: p.symptomDurationMonths,
        hasSoughtTreatment: p.hasSoughtTreatment,
        fullName: p.fullName,
        phone: p.phone,
        email: p.email,
        dateOfBirth: p.dateOfBirth,
        profileCompletedAt: completedAt,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
