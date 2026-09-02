/// Routing policy for the app.
///
/// Deliberately free of Flutter and GoRouter types: this decides who is
/// allowed where, which is worth being able to test directly rather than
/// through a widget tree.
library;

/// Routes reachable without being signed in. Everything else requires a
/// session — including the questionnaires, which previously accepted answers
/// from signed-out visitors and then silently discarded them, because the
/// save methods return early when there is no user id.
const Set<String> publicRoutes = {'/login', '/signup'};

/// Signed-in routes the assessment sequence must not redirect away from.
///
/// ICIQ is here because it is the entry point of the sequence; profile setup
/// and profile because a patient must be able to reach their own details at
/// any point in the protocol.
const Set<String> assessmentExemptRoutes = {
  '/profile-setup',
  '/profile',
  '/iciq',
  '/assessment/iciq',
};

/// Where a signed-out visitor is sent.
const String signedOutLanding = '/login';

/// Where a signed-in patient is sent when they land on an auth screen. The
/// assessment rules below then place them at the right step.
const String signedInLanding = '/dashboard';

/// Returns the path to redirect to, or null to allow [path].
///
/// Evaluated in two stages: authentication first, so no assessment rule can
/// ever admit a signed-out visitor, then the assessment sequence.
String? resolveRedirect({
  required String path,
  required bool isSignedIn,
  required bool hasIciq,
  required bool hasIpaq,
  required bool hasIqol,
  required bool isIqolAvailable,
}) {
  // 1. Authentication gate. Nothing below runs for a signed-out visitor.
  if (!isSignedIn) {
    return publicRoutes.contains(path) ? null : signedOutLanding;
  }

  // 2. A signed-in patient has no reason to sit on login or signup.
  if (publicRoutes.contains(path)) return signedInLanding;

  // 3. Assessment sequence, unchanged in behaviour for signed-in patients.
  if (assessmentExemptRoutes.contains(path)) return null;

  if (!hasIciq) return '/iciq';

  if (path == '/ipaq' || path == '/assessment/ipaq') return null;

  if (!hasIpaq) return '/ipaq';

  if (path == '/iqol' || path == '/assessment/iqol') {
    return isIqolAvailable ? null : '/exercise';
  }

  if (isIqolAvailable && !hasIqol) return '/iqol';

  return null;
}
