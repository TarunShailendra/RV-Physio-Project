import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/user_model.dart';
import '../assessment/notifiers/assessment_summary_notifier.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({
    AssessmentSummaryNotifier? assessmentNotifier,
    List<VoidCallback> onSessionEnded = const [],
  }) : _assessmentNotifier = assessmentNotifier,
       _onSessionEnded = onSessionEnded;

  final AssessmentSummaryNotifier? _assessmentNotifier;

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
    }
  }

  void _handleAuthStateChange(AuthState state) {
    switch (state.event) {
      case AuthChangeEvent.signedOut:
        _clearSession();
        break;
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.userUpdated:
        final user = state.session?.user;
        if (user != null) {
          unawaited(_refreshCurrentUser(user));
        }
        break;
      // initialSession is covered by initialize(), so that startup is
      // deterministic rather than dependent on stream timing. tokenRefreshed
      // and passwordRecovery do not change who is signed in.
      default:
        break;
    }
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
    for (final reset in _onSessionEnded) {
      reset();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
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

        // Update assessment completion status from Supabase for this user
        await _assessmentNotifier?.checkCompletedAssessments();
      }
    } catch (e) {
      errorMessage = e.toString();
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
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim(), 'phone': phone.trim()},
      );
      final user = response.user;
      if (user != null) {
        DateTime? parsedDob;
        if (dob != null && dob.isNotEmpty) {
          final parts = dob.split('/');
          if (parts.length == 3) {
            parsedDob = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }

        await _supabase.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'email': email.trim(),
          'date_of_birth': parsedDob?.toIso8601String().split('T').first,
        }, onConflict: 'id');

        currentUser = UserModel(
          id: user.id,
          name: fullName.trim(),
          email: email.trim(),
          phone: phone.trim(),
          age: age,
          dob: dob,
          dateOfBirth: parsedDob,
        );

        // Update assessment completion status from Supabase for this user
        await _assessmentNotifier?.checkCompletedAssessments();
      }
    } catch (e) {
      errorMessage = e.toString();
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

    final fullName = profileRow?['full_name']?.toString().trim() ?? '';
    final city = profileRow?['city']?.toString().trim() ?? '';
    final resolvedEmail =
        profileRow?['email']?.toString() ?? user.email ?? fallbackEmail ?? '';

    return UserModel(
      id: user.id,
      name: fullName.isNotEmpty ? fullName : resolvedEmail,
      email: resolvedEmail,
      phone: profileRow?['phone']?.toString() ?? '',
      age: 0,
      dateOfBirth: _parseDate(profileRow?['date_of_birth']),
      isProfileComplete: fullName.isNotEmpty && city.isNotEmpty,
    );
  }

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
