import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'notifiers/assessment_summary_notifier.dart';

/// Reports the outcome of saving a questionnaire.
///
/// Returns true when the answers were stored and the caller may move on.
/// Otherwise it tells the patient what went wrong and returns false, so the
/// screen stays put rather than advancing as though the save had worked.
bool reportAssessmentSave(BuildContext context, AssessmentSaveResult result) {
  if (result == AssessmentSaveResult.saved) return true;

  final l10n = AppLocalizations.of(context)!;
  final message = switch (result) {
    AssessmentSaveResult.notSignedIn => l10n.assessmentSaveSignedOut,
    AssessmentSaveResult.incomplete => l10n.completeAllQuestions,
    _ => l10n.assessmentSaveFailed,
  };

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 6)),
  );
  return false;
}
