/// The stored vocabulary for the profile's categorical answers, and the
/// translations shown for each value.
///
/// Values are kept in English in the database so every row speaks one
/// language whatever the patient had the app set to; only the labels here are
/// translated. The setup form and the profile display both read from this
/// file, so what the patient picks and what they are later shown cannot drift
/// apart.
library;

import '../../l10n/app_localizations.dart';

const List<String> incontinenceTypeKeys = [
  'stress',
  'urge',
  'mixed',
  'unknown',
];

const List<String> maritalStatuses = [
  'Single',
  'Married',
  'Separated',
  'Divorced',
  'Widowed',
];

const List<String> deliveryTypes = [
  'Vaginal delivery',
  'Caesarean section',
  'Assisted delivery',
  'Other',
];

const List<String> genders = [
  'Female',
  'Male',
  'Non-binary',
  'Prefer not to say',
];

String maritalLabel(String value, AppLocalizations l10n) => switch (value) {
  'Single' => l10n.maritalSingle,
  'Married' => l10n.maritalMarried,
  'Separated' => l10n.maritalSeparated,
  'Divorced' => l10n.maritalDivorced,
  _ => l10n.maritalWidowed,
};

String deliveryLabel(String value, AppLocalizations l10n) => switch (value) {
  'Vaginal delivery' => l10n.deliveryVaginal,
  'Caesarean section' => l10n.deliveryCaesarean,
  'Assisted delivery' => l10n.deliveryAssisted,
  _ => l10n.deliveryOther,
};

String genderLabel(String value, AppLocalizations l10n) => switch (value) {
  'Female' => l10n.female,
  'Male' => l10n.male,
  'Non-binary' => l10n.genderNonBinary,
  _ => l10n.genderPreferNotToSay,
};

/// Translates a stored incontinence type. Accepts the stored value in any
/// case, since [incontinenceTypeKeys] is lower case but the column holds
/// 'Stress', 'Urge' and so on.
String incontinenceLabel(String value, AppLocalizations l10n) =>
    switch (value.trim().toLowerCase()) {
      'stress' => l10n.stressIncontinence,
      'urge' => l10n.urgeIncontinence,
      'mixed' => l10n.mixedIncontinence,
      'unknown' => l10n.unknownIncontinence,
      _ => value,
    };
