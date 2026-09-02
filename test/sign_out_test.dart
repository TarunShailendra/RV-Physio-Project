import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telerehab_app/features/assessment/models/iciq_model.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/assessment/models/iqol_model.dart';
import 'package:telerehab_app/features/assessment/notifiers/assessment_summary_notifier.dart';
import 'package:telerehab_app/features/assessment/notifiers/iciq_notifier.dart';
import 'package:telerehab_app/features/assessment/notifiers/ipaq_notifier.dart';
import 'package:telerehab_app/features/assessment/notifiers/iqol_notifier.dart';
import 'package:telerehab_app/features/auth/auth_notifier.dart';
import 'package:telerehab_app/features/auth/models/user_model.dart';
import 'package:telerehab_app/features/bladder_diary/bladder_diary_notifier.dart';
import 'package:telerehab_app/features/bladder_diary/models/diary_entry.dart';
import 'package:telerehab_app/features/dashboard/dashboard_notifier.dart';
import 'package:telerehab_app/features/dashboard/models/dashboard_model.dart';
import 'package:telerehab_app/features/exercise/exercise_notifier.dart';
import 'package:telerehab_app/features/profile/models/profile_model.dart';
import 'package:telerehab_app/features/profile/profile_notifier.dart';

/// Covers the sign-out contract: ending a session must clear every notifier
/// holding patient data, not just navigate to the login screen.
///
/// Supabase is initialised against an unreachable host with no local storage,
/// so there is never a session. signOut() therefore fails at the gotrue layer,
/// which is the interesting case: the patient must still be signed out on this
/// device even when the server call does not succeed.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Supabase.initialize builds a shared_preferences-backed PKCE store
    // regardless of the localStorage passed below, so it needs the mock.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:1',
      anonKey: 'test-anon-key',
      authOptions: const FlutterAuthClientOptions(
        localStorage: EmptyLocalStorage(),
        autoRefreshToken: false,
      ),
    );
  });

  test('signOut clears every notifier wired up in main()', () async {
    // The same set of notifiers main() registers, each holding data belonging
    // to the patient who is about to sign out.
    final assessment = AssessmentSummaryNotifier()
      ..iciq = const ICIQModel(
        leakFrequency: 5,
        leakAmount: 3,
        lifeInterference: 9,
      )
      ..ipaq = const IPAQModel(walkDays: 5)
      ..iqol = IQOLModel(items: List<int>.filled(22, 4));

    final exercise = ExerciseNotifierUnderTest()..loadWeek(1);

    final dashboard = DashboardNotifier()
      ..data = const DashboardModel(
        currentWeek: 3,
        exercisesCompletedThisWeek: 4,
        exercisesTargetThisWeek: 7,
        adherencePercentage: 57,
        iciqScorePre: 17,
        iciqScorePost: 0,
        weeklyAdherence: [100, 100, 57, 0, 0, 0, 0, 0],
      );

    final profile = ProfileNotifier()
      ..profile = const ProfileModel(
        userId: 'u1',
        age: 34,
        city: 'Bengaluru',
        occupation: 'Teacher',
        incontinenceType: 'Stress',
        symptomDurationMonths: 18,
        hasSoughtTreatment: true,
        fullName: 'Asha R',
      );

    final diary = BladderDiaryNotifier()
      ..addEntry(
        DiaryEntry(
          time: DateTime(2026, 9, 2, 7),
          fluidType: 'Tea',
          fluidAmountMl: 200,
          hadUrgency: true,
          hadLeakage: false,
          padUsage: 'none',
        ),
      );

    final iciq = IciqNotifier()..setLeakFrequency(4);
    final ipaq = IpaqNotifier()..updateWalking(days: 5, hours: 0, mins: 40);
    final iqol = IqolNotifier()..updateItem(0, 3);

    final auth = AuthNotifier(
      onSessionEnded: [
        assessment.reset,
        exercise.reset,
        dashboard.reset,
        profile.reset,
        diary.reset,
        iciq.reset,
        ipaq.reset,
        iqol.reset,
      ],
    );
    auth.currentUser = const UserModel(
      id: 'u1',
      name: 'Asha R',
      email: 'asha@example.com',
      phone: '9999999999',
      age: 34,
    );

    // Everything is populated before signing out.
    expect(auth.currentUser, isNotNull);
    expect(assessment.iciq, isNotNull);
    expect(exercise.currentPlan, isNotNull);
    expect(dashboard.data, isNotNull);
    expect(profile.profile, isNotNull);
    expect(diary.days, isNotEmpty);
    expect(iciq.model.leakFrequency, 4);
    expect(ipaq.model.walkDays, 5);
    expect(iqol.model.items.first, 3);

    await auth.signOut();

    expect(auth.currentUser, isNull, reason: 'auth user must be cleared');
    expect(auth.token, isNull);
    expect(assessment.iciq, isNull, reason: 'ICIQ result must be cleared');
    expect(assessment.ipaq, isNull, reason: 'IPAQ result must be cleared');
    expect(assessment.iqol, isNull, reason: 'IQOL result must be cleared');
    expect(exercise.currentPlan, isNull, reason: 'exercise plan must be cleared');
    expect(dashboard.data, isNull, reason: 'dashboard must be cleared');
    expect(profile.profile, isNull, reason: 'profile must be cleared');
    expect(diary.days, isEmpty, reason: 'diary entries must be cleared');
    expect(iciq.model.leakFrequency, -1, reason: 'ICIQ answers must be cleared');
    expect(ipaq.model.walkDays, 0, reason: 'IPAQ answers must be cleared');
    expect(iqol.model.items.first, 0, reason: 'IQOL answers must be cleared');
  });

  test('signOut notifies listeners so guarded screens rebuild', () async {
    var notifications = 0;
    final auth = AuthNotifier()..addListener(() => notifications++);
    auth.currentUser = const UserModel(
      id: 'u1',
      name: 'Asha R',
      email: 'asha@example.com',
      phone: '',
      age: 0,
    );

    await auth.signOut();

    expect(notifications, greaterThan(0));
    expect(auth.currentUser, isNull);
  });

  test('signOut is safe with no reset callbacks registered', () async {
    final auth = AuthNotifier();
    await auth.signOut();
    expect(auth.currentUser, isNull);
  });

}

/// ExerciseNotifier.loadWeek() reads no Supabase state, so it can be driven
/// directly. Named for clarity at the call site.
typedef ExerciseNotifierUnderTest = ExerciseNotifier;
