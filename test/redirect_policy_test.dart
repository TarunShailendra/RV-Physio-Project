import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/app.dart';
import 'package:telerehab_app/core/routing/redirect_policy.dart';

/// Covers the route guard.
///
/// The router previously gated only on assessment completion and never asked
/// whether anyone was signed in, so /dashboard, /exercise, /bladder-diary,
/// /education and /profile were all reachable while signed out — and a
/// signed-out visitor sent to /iciq could fill in the questionnaire and have
/// it silently discarded, because the save methods return early with no user.
void main() {
  /// A signed-in patient at the far end of the protocol, so assessment rules
  /// never mask an authentication result.
  String? redirectFor(String path, {required bool isSignedIn}) =>
      resolveRedirect(
        path: path,
        isSignedIn: isSignedIn,
        hasCompletedProfile: true,
        hasIciq: true,
        hasIpaq: true,
        hasIqol: true,
        isIqolAvailable: true,
      );

  group('authentication gate', () {
    test('every route in the app is either public or requires a session', () {
      // Enumerated from the real route table, so a route added later without
      // a decision about who may reach it fails here.
      for (final path in appRouteBuilders.keys) {
        final result = redirectFor(path, isSignedIn: false);
        if (publicRoutes.contains(path)) {
          expect(
            result,
            isNull,
            reason: '$path is public and must be reachable signed out',
          );
        } else {
          expect(
            result,
            signedOutLanding,
            reason: '$path must redirect a signed-out visitor to the login screen',
          );
        }
      }
    });

    test('the routes that were reachable signed out are now guarded', () {
      for (final path in [
        '/',
        '/dashboard',
        '/exercise',
        '/bladder-diary',
        '/education',
        '/profile',
        '/profile-setup',
        '/reassessment',
        '/assessment',
      ]) {
        expect(redirectFor(path, isSignedIn: false), '/login', reason: path);
      }
    });

    test('the questionnaires no longer accept signed-out answers', () {
      for (final path in [
        '/iciq',
        '/assessment/iciq',
        '/ipaq',
        '/assessment/ipaq',
        '/iqol',
        '/assessment/iqol',
      ]) {
        expect(redirectFor(path, isSignedIn: false), '/login', reason: path);
      }
    });

    test('login and signup stay reachable signed out', () {
      expect(redirectFor('/login', isSignedIn: false), isNull);
      expect(redirectFor('/signup', isSignedIn: false), isNull);
    });

    test('an unknown path is refused rather than allowed', () {
      expect(redirectFor('/some/unrouted/path', isSignedIn: false), '/login');
    });

    test('a signed-in patient is moved off the auth screens', () {
      expect(redirectFor('/login', isSignedIn: true), signedInLanding);
      expect(redirectFor('/signup', isSignedIn: true), signedInLanding);
    });
  });

  group('details are collected before the questionnaires', () {
    String? forPath(String path, {required bool hasCompletedProfile}) =>
        resolveRedirect(
          path: path,
          isSignedIn: true,
          hasCompletedProfile: hasCompletedProfile,
          hasIciq: false,
          hasIpaq: false,
          hasIqol: false,
          isIqolAvailable: false,
        );

    test('a patient who has just signed up is sent to profile setup', () {
      // Signup and login each navigated here themselves, but the guard moves
      // a patient off the auth screen the instant sign-in completes, so that
      // navigation never ran and profile setup was unreachable.
      expect(forPath('/dashboard', hasCompletedProfile: false),
          profileSetupRoute);
      expect(forPath('/iciq', hasCompletedProfile: false), profileSetupRoute);
      expect(forPath('/exercise', hasCompletedProfile: false),
          profileSetupRoute);
    });

    test('profile setup itself is reachable, so the chain settles', () {
      expect(forPath(profileSetupRoute, hasCompletedProfile: false), isNull);
    });

    test('once the details are in, the assessment sequence takes over', () {
      expect(forPath('/dashboard', hasCompletedProfile: true), '/iciq');
    });

    test('a signed-out visitor is still stopped first', () {
      expect(
        resolveRedirect(
          path: '/dashboard',
          isSignedIn: false,
          hasCompletedProfile: false,
          hasIciq: false,
          hasIpaq: false,
          hasIqol: false,
          isIqolAvailable: false,
        ),
        signedOutLanding,
        reason: 'authentication comes before profile completeness',
      );
    });
  });

  group('assessment sequence, for signed-in patients', () {
    String? redirect(
      String path, {
      bool hasIciq = false,
      bool hasIpaq = false,
      bool hasIqol = false,
      bool isIqolAvailable = false,
    }) => resolveRedirect(
      path: path,
      isSignedIn: true,
      hasCompletedProfile: true,
      hasIciq: hasIciq,
      hasIpaq: hasIpaq,
      hasIqol: hasIqol,
      isIqolAvailable: isIqolAvailable,
    );

    test('everything funnels to ICIQ until it is done', () {
      expect(redirect('/dashboard'), '/iciq');
      expect(redirect('/exercise'), '/iciq');
      expect(redirect('/ipaq'), '/iciq');
    });

    test('ICIQ itself is always reachable', () {
      expect(redirect('/iciq'), isNull);
      expect(redirect('/assessment/iciq'), isNull);
    });

    test('IPAQ unlocks once ICIQ is done', () {
      expect(redirect('/ipaq', hasIciq: true), isNull);
      expect(redirect('/assessment/ipaq', hasIciq: true), isNull);
      expect(redirect('/dashboard', hasIciq: true), '/ipaq');
    });

    test('IQOL waits on the exercise protocol', () {
      expect(
        redirect('/iqol', hasIciq: true, hasIpaq: true),
        '/exercise',
        reason: 'not yet available',
      );
      expect(
        redirect(
          '/iqol',
          hasIciq: true,
          hasIpaq: true,
          isIqolAvailable: true,
        ),
        isNull,
      );
    });

    test('IQOL becomes compulsory once available', () {
      expect(
        redirect(
          '/dashboard',
          hasIciq: true,
          hasIpaq: true,
          isIqolAvailable: true,
        ),
        '/iqol',
      );
      expect(
        redirect(
          '/dashboard',
          hasIciq: true,
          hasIpaq: true,
          hasIqol: true,
          isIqolAvailable: true,
        ),
        isNull,
      );
    });

    test('profile stays reachable at every step of the protocol', () {
      expect(redirect('/profile'), isNull);
      expect(redirect('/profile-setup'), isNull);
      expect(redirect('/profile', hasIciq: true, isIqolAvailable: true), isNull);
    });
  });

  group('redirects terminate', () {
    // GoRouter gives up after redirectLimit hops, so every starting point must
    // settle on a path the guard then allows.
    test('no chain loops, from any route in either auth state', () {
      for (final signedIn in [true, false]) {
        for (final start in appRouteBuilders.keys) {
          var path = start;
          var hops = 0;
          while (hops < 5) {
            final next = resolveRedirect(
              path: path,
              isSignedIn: signedIn,
              hasCompletedProfile: false,
              hasIciq: false,
              hasIpaq: false,
              hasIqol: false,
              isIqolAvailable: false,
            );
            if (next == null) break;
            path = next;
            hops++;
          }
          expect(
            hops,
            lessThan(5),
            reason: 'redirect from $start (signedIn: $signedIn) did not settle',
          );
        }
      }
    });
  });
}
