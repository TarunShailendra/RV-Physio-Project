import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/dashboard/dashboard_notifier.dart';

/// The week the dashboard and the profile say the patient is on.
///
/// This was the highest week holding a completed session, which is a week
/// behind for the whole gap between finishing a week and logging the first
/// session of the next one — so at the start of every new week both screens
/// showed the previous week's number, exercise count and adherence.
void main() {
  const full = DashboardNotifier.daysPerWeek;
  const lastWeek = DashboardNotifier.totalWeeks;

  int currentWeek({
    Set<int> touched = const {},
    Map<int, int> completedDays = const {},
    int recommended = 1,
  }) => resolveCurrentWeek(
    weeksTouched: touched,
    completedDaysByWeek: completedDays,
    recommendedStartWeek: recommended,
  );

  test('a finished week moves the patient on before they log anything', () {
    expect(
      currentWeek(touched: {1}, completedDays: {1: full}),
      2,
      reason:
          'week 1 is done and week 2 is untouched, which is exactly the '
          'moment the old calculation still reported week 1',
    );
  });

  test('an unfinished week is the current one', () {
    expect(currentWeek(touched: {1}, completedDays: {1: 3}), 1);
    expect(currentWeek(touched: {1, 2}, completedDays: {1: full, 2: 6}), 2);
  });

  test('a patient who has done nothing sits on their recommended week', () {
    expect(currentWeek(recommended: 3), 3);
    expect(currentWeek(recommended: 1), 1);
  });

  test('activity outranks the recommendation once there is any', () {
    expect(
      currentWeek(touched: {4}, completedDays: {4: 2}, recommended: 1),
      4,
      reason: 'the recommendation is where to start, not where they are',
    );
  });

  test('several finished weeks are stepped over in one go', () {
    expect(
      currentWeek(
        touched: {1, 2, 3},
        completedDays: {1: full, 2: full, 3: full},
      ),
      4,
    );
  });

  test('a finished protocol stays on the last week', () {
    expect(
      currentWeek(
        touched: {for (var w = 1; w <= lastWeek; w++) w},
        completedDays: {for (var w = 1; w <= lastWeek; w++) w: full},
      ),
      lastWeek,
      reason: 'there is no week 9 to move on to',
    );
  });

  test('an out-of-range week does not escape the protocol', () {
    expect(currentWeek(recommended: 99), lastWeek);
    expect(currentWeek(recommended: 0), 1);
  });
}
