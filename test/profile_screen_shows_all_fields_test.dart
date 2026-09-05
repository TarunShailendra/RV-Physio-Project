import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The profile screen once rendered six of the fifteen answers the setup form
/// collects. Everything else — marital status, children, delivery type,
/// height, weight, diabetes, hypertension, gender and the rest — was written
/// to Supabase and then shown nowhere, so patients filled in a long form after
/// signing up and never saw any of it again.
///
/// This is a source-level check rather than a widget test because the profile
/// screen reads its data through `Supabase.instance.client`, which cannot be
/// stood up in a unit test without a network harness. Checking the source
/// still catches the regression that actually happened: a field added to the
/// form and the model, and forgotten in the display.
void main() {
  /// Every optional-or-categorical field the setup form collects, mapped to
  /// the `ProfileModel` getter the profile screen must read to show it.
  const displayedFields = <String>[
    'gender',
    'phone',
    'email',
    'occupation',
    'city',
    'incontinenceType',
    'symptomDurationMonths',
    'hasSoughtTreatment',
    'hasDiabetes',
    'hasHypertension',
    'heightCm',
    'weightKg',
    'maritalStatus',
    'hasChildren',
    'deliveryType',
    'childrenAges',
    'childbirthPainLevel',
    'dateOfBirth',
  ];

  test('the profile screen displays every field the setup form collects', () {
    final source = File(
      'lib/features/profile/screens/profile_screen.dart',
    ).readAsStringSync();

    for (final field in displayedFields) {
      expect(
        source,
        contains(field),
        reason:
            'ProfileModel.$field is collected during setup but the profile '
            'screen never reads it, so the patient cannot see what they '
            'entered. Add a row for it in profile_screen.dart.',
      );
    }
  });

  test('the profile screen translates stored values rather than showing the '
      'English kept in the database', () {
    final source = File(
      'lib/features/profile/screens/profile_screen.dart',
    ).readAsStringSync();

    for (final mapper in [
      'genderLabel(',
      'maritalLabel(',
      'deliveryLabel(',
      'incontinenceLabel(',
    ]) {
      expect(
        source,
        contains(mapper),
        reason:
            'Categorical answers are stored in English so the database keeps '
            'one vocabulary. $mapper from profile_labels.dart turns them back '
            "into the patient's language for display.",
      );
    }
  });
}
