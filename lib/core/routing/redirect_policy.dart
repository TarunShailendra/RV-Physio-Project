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
/// rules below then place them at the right step.
const String signedInLanding = '/dashboard';

/// Where a patient completes their details, before any questionnaire.
const String profileSetupRoute = '/profile-setup';

/// Returns the path to redirect to, or null to allow [path].
///
/// Evaluated in two stages: authentication first, so no assessment rule can
/// ever admit a signed-out visitor, then the assessment sequence.
String? resolveRedirect({
  required String path,
  required bool isSignedIn,
  required bool hasCompletedProfile,
  required bool assessmentsLoaded,
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

  // 3. Details before questionnaires.
  //
  // This has to live here rather than in the screens. The login and signup
  // screens each navigated to profile setup themselves, but rule 2 combined
  // with the router's refreshListenable moves a patient off the auth screen
  // the instant sign-in completes — before that navigation runs — so the
  // screen was unmounted and profile setup was never reached.
  if (!hasCompletedProfile) {
    return path == profileSetupRoute ? null : profileSetupRoute;
  }

  // 4. Assessment sequence.
  if (assessmentExemptRoutes.contains(path)) return null;

  // Nothing below can tell a questionnaire that was never done from one that
  // has not been read back from Supabase yet, and sign-in publishes the
  // patient before their results arrive. Sending them to the ICIQ on that
  // evidence meant every login reopened questionnaires they had already
  // filled in. Leave them where they are until the answer is actually known;
  // the guard runs again when the load completes.
  if (!assessmentsLoaded) return null;

  if (!hasIciq) return '/iciq';

  if (path == '/ipaq' || path == '/assessment/ipaq') return null;

  if (!hasIpaq) return '/ipaq';

  if (path == '/iqol' || path == '/assessment/iqol') {
    return isIqolAvailable ? null : '/exercise';
  }

  if (isIqolAvailable && !hasIqol) return '/iqol';

  return null;
}
