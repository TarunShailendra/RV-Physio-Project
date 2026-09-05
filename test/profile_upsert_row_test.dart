import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/profile/models/profile_model.dart';
import 'package:telerehab_app/features/profile/profile_notifier.dart';

/// Profile setup passes the patient's phone number and date of birth straight
/// back through from the session user; it does not ask for them again. When
/// the session user had lost them — the signup upsert races an auth event
/// that rebuilds the user from a profile row seeded without a date of birth —
/// the form upserted nulls over the values signup had written, and the
/// patient's age and phone number disappeared from a profile they had filled
/// in correctly.
void main() {
  ProfileModel model({String? phone, String? fullName, DateTime? dateOfBirth}) {
    return ProfileModel(
      userId: 'user-1',
      city: 'Bengaluru',
      occupation: 'Teacher',
      incontinenceType: 'Stress',
      symptomDurationMonths: 6,
      hasSoughtTreatment: true,
      fullName: fullName,
      phone: phone,
      dateOfBirth: dateOfBirth,
    );
  }

  final completedAt = DateTime.utc(2026, 1, 2, 3, 4);

  test('a missing phone, name or date of birth is left out of the row', () {
    final row = buildProfileUpsertRow(model(), completedAt);

    for (final column in ['phone', 'full_name', 'date_of_birth', 'email']) {
      expect(
        row.containsKey(column),
        isFalse,
        reason:
            'Sending $column as null would clear what signup wrote. An upsert '
            'leaves alone a column it is not given, so it must be omitted.',
      );
    }
  });

  test('values the form does have are still written', () {
    final row = buildProfileUpsertRow(
      model(
        phone: '9876543210',
        fullName: 'A Patient',
        dateOfBirth: DateTime(1990, 4, 5),
      ),
      completedAt,
    );

    expect(row['phone'], '9876543210');
    expect(row['full_name'], 'A Patient');
    // A Postgres `date` column takes no time part.
    expect(row['date_of_birth'], '1990-04-05');
  });

  test('a null in a column the form does own is still sent, so the patient '
      'can clear an answer', () {
    final row = buildProfileUpsertRow(model(), completedAt);

    for (final column in [
      'marital_status',
      'delivery_type',
      'children_ages',
      'childbirth_pain_level',
      'height_cm',
      'weight_kg',
      'gender',
      'has_children',
    ]) {
      expect(
        row.containsKey(column),
        isTrue,
        reason:
            'Profile setup asks for $column, so a null there means the '
            'patient left it blank and the stored value should be cleared.',
      );
      expect(row[column], isNull);
    }
  });
}
