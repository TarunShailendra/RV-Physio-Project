import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/user_model.dart';

/// Why an auth call failed, so screens can say something a patient can act on.
///
/// errorMessage used to carry `e.toString()` straight to a snackbar, which put
/// Postgres codes and RLS policy names in front of patients and made a network
/// timeout indistinguishable from a wrong password.
enum AuthFailure { none, invalidCredentials, network, unknown }

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({
    List<Future<void> Function()> onSignedIn = const [],
    List<VoidCallback> onSessionEnded = const [],
  }) : _onSignedIn = onSignedIn,
       _onSessionEnded = onSessionEnded;

  /// Run once a patient is signed in, to pull their data back from Supabase.
  ///
  /// Previously only the assessment summary was refreshed here. Exercise
  /// progress was loaded once in main(), before anyone could be signed in, so
  /// it returned immediately and completed weeks did not come back until the
  /// next cold start with a session already on disk.
  final List<Future<void> Function()> _onSignedIn;

  /// Run when the session ends, to clear every notifier holding patient data.
  /// Registered in main.dart so that the provider list is the single place
  /// this has to be kept in step.
  final List<VoidCallback> _onSessionEnded;

  StreamSubscription<AuthState>? _authSubscription;

  SupabaseClient get _supabase => Supabase.instance.client;

  String? token;
  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  /// Set when a signup was refused because the address already has an account.
  ///
  /// The signup screen has always had a message for this, but nothing ever set
  /// the flag it reads, so a duplicate registration surfaced as a raw
  /// exception string instead.
  bool emailAlreadyRegistered = false;

  /// Kind of the last failure. [errorMessage] is kept for logs.
  AuthFailure failure = AuthFailure.none;

  static AuthFailure _classify(Object error) {
    if (error is AuthApiException) return AuthFailure.invalidCredentials;
    if (error is AuthRetryableFetchException) return AuthFailure.network;
    final text = error.toString().toLowerCase();
    if (text.contains('socket') ||
        text.contains('failed host lookup') ||
        text.contains('connection') ||
        text.contains('timeout')) {
      return AuthFailure.network;
    }
    if (error is AuthException) return AuthFailure.invalidCredentials;
    return AuthFailure.unknown;
  }

  /// Adopts a session that Supabase restored from storage, and keeps
  /// [currentUser] in step with sign-in and sign-out from then on.
  ///
  /// Call once, after `Supabase.initialize()`. This is deliberately not done in
  /// the constructor: touching `Supabase.instance` there would make the class
  /// impossible to build before Supabase is initialised, which is the defect
  /// that currently makes AssessmentSummaryNotifier untestable.
  Future<void> initialize() async {
    _authSubscription ??= _supabase.auth.onAuthStateChange.listen(
      _handleAuthStateChange,
    );

    final user = _supabase.auth.currentUser;
    if (user != null && currentUser == null) {
      currentUser = await _buildUserFromProfile(user);
      notifyListeners();
      await _loadSignedInData();
    }
  }

  /// Runs the sign-in loaders, joining a run already in flight rather than
  /// starting a second one. sign-in reaches here twice — once from login() or
  /// signup(), once from the auth event they raise — and the two would
  /// otherwise fetch everything twice over.
  Future<void> _loadSignedInData() {
    return _signedInDataLoad ??= _runSignedInLoaders().whenComplete(
      () => _signedInDataLoad = null,
    );
  }

  Future<void> _runSignedInLoaders() async {
    for (final load in _onSignedIn) {
      try {
        await load();
      } catch (e) {
        // One loader failing must not stop the others.
        debugPrint('sign-in data load failed: $e');
      }
    }
  }

  /// The sign-in data load currently in flight, if any. See
  /// [_loadSignedInData].
  Future<void>? _signedInDataLoad;

  void _handleAuthStateChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.signedOut:
        _clearSession();
        break;
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.userUpdated:
        final user = state.session?.user;
        if (user != null) {
          // The loaders belong here and not only in login() and signup(), so
          // that a session which starts any other way still pulls the
          // patient's assessments and progress. Without them the route guard
          // never learns which questionnaires are done.
          unawaited(_refreshCurrentUser(user).then((_) => _loadSignedInData()));
        }
        break;
      // initialSession is covered by initialize(), so that startup is
      // deterministic rather than dependent on stream timing. tokenRefreshed
      // and passwordRecovery do not change who is signed in.
      default:
        break;
    }
  }

  /// Re-reads the patient's profile, so isProfileComplete reflects a save
  /// that just happened. Without this the route guard sends them back to the
  /// form they have only now finished.
  Future<void> refreshProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _refreshCurrentUser(user);
  }

  Future<void> _refreshCurrentUser(User user) async {
    final refreshed = await _buildUserFromProfile(user);
    // The session can end while the profile is loading.
    if (_supabase.auth.currentUser == null) return;
    currentUser = refreshed;
    notifyListeners();
  }

  /// Ends the session on this device and clears every trace of the patient.
  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.signOut();
    } catch (e) {
      // Clear locally regardless of the result: if the network call failed the
      // patient still expects to be signed out on this device, and leaving
      // their data on screen is the worse outcome.
      debugPrint('signOut failed, clearing local session anyway: $e');
    } finally {
      _clearSession();
      isLoading = false;
      notifyListeners();
    }
  }

  void _clearSession() {
    currentUser = null;
    token = null;
    errorMessage = null;
    failure = AuthFailure.none;
    for (final reset in _onSessionEnded) {
      reset();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    failure = AuthFailure.none;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;
      if (user != null) {
        currentUser = await _buildUserFromProfile(
          user,
          fallbackEmail: email.trim(),
        );

        await _loadSignedInData();
      }
    } catch (e) {
      debugPrint('login failed: $e');
      errorMessage = e.toString();
      failure = _classify(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signup(
    String fullName,
    String email,
    String password,
    String phone,
    int age, {
    String? dob,
  }) async {
    isLoading = true;
    errorMessage = null;
    emailAlreadyRegistered = false;
    failure = AuthFailure.none;
    notifyListeners();

    try {
      // Parsed before the call, not after, so the date of birth can travel in
      // the auth metadata. signUp fires a signedIn event that rebuilds
      // currentUser from the profiles row; if the row is seeded from metadata
      // that carries no date of birth, the patient's is lost before profile
      // setup ever reads it.
      final parsedDob = _parseDobString(dob);

      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'date_of_birth': _dateOnly(parsedDob),
        },
      );
      final user = response.user;

      // With email-enumeration protection on, Supabase returns a user with no
      // identities rather than an error when the address is already taken.
      if (user != null && (user.identities?.isEmpty ?? false)) {
        emailAlreadyRegistered = true;
        return;
      }

      if (user != null) {
        // With email confirmation on there is no session yet, so this write
        // has no auth.uid() and RLS rejects it. The details are already in the
        // auth record's metadata, so the row is created on first sign-in
        // instead of failing here and being reported as a signup error.
        if (response.session != null) {
          await _supabase.from('profiles').upsert({
            'id': user.id,
            'full_name': fullName.trim(),
            'phone': phone.trim(),
            'email': email.trim(),
            'date_of_birth': _dateOnly(parsedDob),
          }, onConflict: 'id');
        }

        currentUser = UserModel(
          id: user.id,
          name: fullName.trim(),
          email: email.trim(),
          phone: phone.trim(),
          age: age,
          dob: dob,
          dateOfBirth: parsedDob,
        );

        await _loadSignedInData();
      }
    } on AuthException catch (e) {
      // With enumeration protection off, it comes back as an error instead.
      final message = e.message.toLowerCase();
      if (message.contains('already registered') ||
          message.contains('already been registered') ||
          message.contains('user already exists')) {
        emailAlreadyRegistered = true;
      } else {
        errorMessage = e.message;
        failure = _classify(e);
      }
    } catch (e) {
      debugPrint('signup failed: $e');
      errorMessage = e.toString();
      failure = _classify(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Builds the in-memory user from the auth record plus the patient's
  /// profile row. Shared by sign-in and by session restore so both produce
  /// the same [UserModel] for the same account.
  Future<UserModel> _buildUserFromProfile(
    User user, {
    String? fallbackEmail,
  }) async {
    Map<String, dynamic>? profileRow;
    try {
      profileRow = await _supabase
          .from('profiles')
          .select('full_name, city, date_of_birth, phone, email')
          .eq('id', user.id)
          .maybeSingle();
    } catch (e) {
      // A readable session with an unreadable profile is still a signed-in
      // patient — fall back to the auth record rather than reporting no user.
      debugPrint('profile lookup failed during session restore: $e');
    }

    // No row yet: a signup that had to wait for email confirmation never got
    // to write one. Seed it from the auth metadata captured at signup.
    profileRow ??= await _createProfileFromMetadata(user);

    final fullName = profileRow?['full_name']?.toString().trim() ?? '';
    final city = profileRow?['city']?.toString().trim() ?? '';
    final resolvedEmail =
        profileRow?['email']?.toString() ?? user.email ?? fallbackEmail ?? '';

    final dateOfBirth = _parseDate(profileRow?['date_of_birth']);

    return UserModel(
      id: user.id,
      name: fullName.isNotEmpty ? fullName : resolvedEmail,
      email: resolvedEmail,
      phone: profileRow?['phone']?.toString() ?? '',
      // Derived rather than left at 0. age and dob used to be filled only by
      // signup, so any rebuild of the session user silently zeroed them while
      // dateOfBirth carried the truth.
      age: _ageFromDateOfBirth(dateOfBirth) ?? 0,
      dob: dateOfBirth == null
          ? null
          : '${dateOfBirth.day.toString().padLeft(2, '0')}/'
                '${dateOfBirth.month.toString().padLeft(2, '0')}/'
                '${dateOfBirth.year}',
      dateOfBirth: dateOfBirth,
      isProfileComplete: fullName.isNotEmpty && city.isNotEmpty,
    );
  }

  /// Creates the patient's profile row from the metadata stored at signup.
  /// Returns null if it cannot be written.
  Future<Map<String, dynamic>?> _createProfileFromMetadata(User user) async {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final fullName = metadata['full_name']?.toString().trim() ?? '';
    final phone = metadata['phone']?.toString().trim() ?? '';
    final dateOfBirth = metadata['date_of_birth']?.toString().trim();
    if (fullName.isEmpty && phone.isEmpty && user.email == null) return null;

    final row = {
      'id': user.id,
      'full_name': fullName,
      'phone': phone,
      'email': user.email,
      // Signup collects this, so it belongs in the seeded row. Leaving it out
      // meant a patient whose row was seeded here had no date of birth, and
      // profile setup then wrote that null back over the real one.
      'date_of_birth': (dateOfBirth == null || dateOfBirth.isEmpty)
          ? null
          : dateOfBirth,
    };
    try {
      await _supabase.from('profiles').upsert(row, onConflict: 'id');
      return row;
    } catch (e) {
      debugPrint('could not seed profile from signup metadata: $e');
      return null;
    }
  }

  int? _ageFromDateOfBirth(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }

  /// Parses the `dd/MM/yyyy` string the signup form produces.
  DateTime? _parseDobString(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    final parts = dob.split('/');
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
  }

  /// Formats a date for a Postgres `date` column, which takes no time part.
  String? _dateOnly(DateTime? value) =>
      value?.toIso8601String().split('T').first;

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
