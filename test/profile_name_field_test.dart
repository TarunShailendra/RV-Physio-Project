import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/profile/models/profile_model.dart';
import 'package:telerehab_app/features/profile/profile_notifier.dart';

/// The profile header read "User" for a patient whose full_name was blank, and
/// there was no way to fix it from inside the app.
///
/// Two things caused that. Profile setup never asked for a name, and it wrote
/// `currentUser.name` into full_name — a value AuthNotifier falls back to the
/// email for when full_name is empty. So the email went into the name column,
/// and the header, which refuses to show an email as a name, fell through to
/// "User". Saving the profile could never break the loop.
void main() {
  final source = File(
    'lib/features/profile/screens/profile_setup_screen.dart',
  ).readAsStringSync();

  test('profile setup asks for the patient name', () {
    expect(
      source,
      contains('_fullNameController'),
      reason: 'the form must collect a name, not just read one back',
    );
    expect(source, contains('l10n.enterYourName'));
  });

  test('profile setup saves the typed name, not the session fallback', () {
    expect(
      source,
      contains('fullName: _fullNameController.text.trim()'),
      reason: 'writing currentUser.name put the email into full_name',
    );
    expect(
      source,
      isNot(contains('fullName: currentUser.name')),
      reason: 'this is the line that created the loop',
    );
  });

  test('a stored name equal to the email is not offered back as a name', () {
    expect(source, contains('storedName == storedEmail'));
  });

  test('the typed name reaches the row that is upserted', () {
    final row = buildProfileUpsertRow(
      ProfileModel(
        userId: 'u1',
        city: 'Bengaluru',
        occupation: 'Teacher',
        incontinenceType: 'stress',
        symptomDurationMonths: 6,
        hasSoughtTreatment: false,
        fullName: 'Tarun Shailendra',
        email: 'fin@gmail.com',
      ),
      DateTime.utc(2026, 9, 15),
    );

    expect(row['full_name'], 'Tarun Shailendra');
    expect(
      row['full_name'],
      isNot(row['email']),
      reason: 'the name column must never hold the email address',
    );
  });
}
