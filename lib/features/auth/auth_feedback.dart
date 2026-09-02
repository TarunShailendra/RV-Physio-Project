import '../../l10n/app_localizations.dart';
import 'auth_notifier.dart';

/// A message a patient can act on, for the kind of failure that occurred.
String authFailureMessage(AuthFailure failure, AppLocalizations l10n) {
  switch (failure) {
    case AuthFailure.invalidCredentials:
      return l10n.invalidCredentials;
    case AuthFailure.network:
      return l10n.networkUnavailable;
    case AuthFailure.none:
    case AuthFailure.unknown:
      return l10n.somethingWentWrong;
  }
}
