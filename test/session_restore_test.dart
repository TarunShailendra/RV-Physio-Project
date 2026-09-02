import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/features/auth/auth_notifier.dart';

/// Covers session restore: a patient who was signed in when the app was last
/// closed must still be signed in when it reopens.
///
/// AuthNotifier used to set currentUser only inside login() and signup(), so
/// after a restart Supabase held a valid session while the app believed nobody
/// was signed in — which is what made profile setup announce "Your session has
/// expired" to a signed-in patient.
///
/// This file gets its own Supabase.initialize because the client is a
/// singleton and this suite needs storage that yields a session.
void main() {
  const userId = '11111111-1111-1111-1111-111111111111';

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:1',
      anonKey: 'test-anon-key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: _StoredSessionStorage(userId: userId),
        autoRefreshToken: false,
      ),
    );
  });

  test('Supabase recovers the stored session', () {
    expect(Supabase.instance.client.auth.currentUser, isNotNull);
    expect(Supabase.instance.client.auth.currentUser!.id, userId);
  });

  test('initialize() adopts the restored session', () async {
    final auth = AuthNotifier();
    expect(auth.currentUser, isNull, reason: 'nothing adopted yet');

    await auth.initialize();

    expect(
      auth.currentUser,
      isNotNull,
      reason: 'a restored session must produce a signed-in user',
    );
    expect(auth.currentUser!.id, userId);

    // Idempotent: calling twice must not stack a second auth subscription or
    // change who is signed in.
    await auth.initialize();
    expect(auth.currentUser!.id, userId);

    auth.dispose();
  });

  test('a signed-in user survives an unreadable profiles table', () async {
    // Every request in this suite fails, so the profile lookup inside
    // initialize() throws. The patient is still signed in, and the user model
    // falls back to the auth record rather than coming back null.
    final auth = AuthNotifier();
    await auth.initialize();

    expect(auth.currentUser, isNotNull);
    expect(auth.currentUser!.email, 'asha@example.com');
    expect(
      auth.currentUser!.isProfileComplete,
      isFalse,
      reason: 'no profile row was readable, so setup is not complete',
    );
    auth.dispose();
  });

  test('initialize() runs the sign-in data loaders', () async {
    // Exercise progress used to be loaded once in main(), before anyone could
    // be signed in, so it returned immediately and completed weeks did not come
    // back until the next cold start.
    final ran = <String>[];
    final auth = AuthNotifier(
      onSignedIn: [
        () async => ran.add('assessments'),
        () async => ran.add('exercise'),
      ],
    );

    await auth.initialize();

    expect(ran, ['assessments', 'exercise']);
    auth.dispose();
  });

  test('one failing loader does not stop the others', () async {
    final ran = <String>[];
    final auth = AuthNotifier(
      onSignedIn: [
        () async => throw StateError('table unreadable'),
        () async => ran.add('exercise'),
      ],
    );

    await auth.initialize();

    expect(ran, ['exercise']);
    auth.dispose();
  });

  test('initialize() notifies listeners once the user is adopted', () async {
    final auth = AuthNotifier();
    var notifications = 0;
    auth.addListener(() => notifications++);

    await auth.initialize();

    expect(notifications, greaterThan(0));
    auth.dispose();
  });
}

/// A [LocalStorage] holding a session, standing in for one Supabase persisted
/// on the device during a previous run.
class _StoredSessionStorage extends LocalStorage {
  const _StoredSessionStorage({required this.userId});

  final String userId;

  String get _session => jsonEncode({
    'access_token': 'stored-access-token',
    'token_type': 'bearer',
    'expires_in': 3600,
    // Far future, so recovery does not attempt a refresh.
    'expires_at': 4102444800,
    'refresh_token': 'stored-refresh-token',
    'user': {
      'id': userId,
      'aud': 'authenticated',
      'role': 'authenticated',
      'email': 'asha@example.com',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
      'created_at': '2026-01-01T00:00:00Z',
    },
  });

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> hasAccessToken() async => true;

  @override
  Future<String?> accessToken() async => _session;

  @override
  Future<void> removePersistedSession() async {}

  @override
  Future<void> persistSession(String persistSessionString) async {}
}
