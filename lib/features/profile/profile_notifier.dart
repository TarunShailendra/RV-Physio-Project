import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/profile_model.dart';

/// Columns that signup fills in and profile setup does not ask about again.
/// A null for one of these means "not loaded", never "clear it".
const _signupOwnedColumns = {'full_name', 'phone', 'email', 'date_of_birth'};

/// Builds the row `saveProfile` upserts.
///
/// Split out of the notifier so it can be tested: the notifier itself reaches
/// through `Supabase.instance.client`, which no unit test here can stand up.
@visibleForTesting
Map<String, dynamic> buildProfileUpsertRow(
  ProfileModel p,
  DateTime completedAt,
) {
  final row = <String, dynamic>{
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
    'marital_status': p.maritalStatus,
    'has_children': p.hasChildren,
    'delivery_type': p.deliveryType,
    'children_ages': p.childrenAges,
    'childbirth_pain_level': p.childbirthPainLevel,
    'height_cm': p.heightCm,
    'weight_kg': p.weightKg,
    'has_diabetes': p.hasDiabetes,
    'has_hypertension': p.hasHypertension,
    'gender': p.gender,
  };

  // Signup owns full_name, phone, email and date_of_birth; profile setup only
  // passes them back through. Sending them as null would blank out what
  // signup wrote, which is how patients ended up with no phone number and no
  // age on a profile they had filled in correctly. An upsert leaves alone a
  // column it is not given, so dropping the nulls keeps the stored value.
  row.removeWhere(
    (key, value) => value == null && _signupOwnedColumns.contains(key),
  );

  return row;
}

class ProfileNotifier extends ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;

  ProfileModel? profile;
  bool isLoading = false;
  String? errorMessage;

  /// Clears the loaded profile. Called when the session ends so the next
  /// patient to sign in on this device does not see the previous one's data.
  void reset() {
    profile = null;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

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
            'id, full_name, city, occupation, incontinence_type, symptom_duration_months, has_sought_treatment, date_of_birth, profile_completed_at, phone, email, marital_status, has_children, delivery_type, children_ages, childbirth_pain_level, height_cm, weight_kg, has_diabetes, has_hypertension, gender',
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
      final row = buildProfileUpsertRow(p, completedAt);

      await _supabase.from('profiles').upsert(row, onConflict: 'id');
      profile = ProfileModel(
        userId: p.userId,
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
        maritalStatus: p.maritalStatus,
        hasChildren: p.hasChildren,
        deliveryType: p.deliveryType,
        childrenAges: p.childrenAges,
        childbirthPainLevel: p.childbirthPainLevel,
        heightCm: p.heightCm,
        weightKg: p.weightKg,
        hasDiabetes: p.hasDiabetes,
        hasHypertension: p.hasHypertension,
        gender: p.gender,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
