import 'package:flutter_test/flutter_test.dart';
import 'package:telerehab_app/features/assessment/models/ipaq_model.dart';
import 'package:telerehab_app/features/dashboard/dashboard_notifier.dart';
import 'package:telerehab_app/features/exercise/protocols/protocol_lookup.dart';

/// The week the dashboard and the profile say the patient is on.
///
/// This was the highest week holding a completed session, which is a week
/// behind for the whole gap between finishing a week and logging the first
/// session of the next one — so at the start of every new week both screens
/// showed the previous week's number, exercise count and adherence.
///
/// Two things changed with the protocols. A week is finished when its own
/// prescribed day count is met, three to five rather than a fixed seven; and
/// the recommendedStartWeek parameter is gone, because the questionnaires now
/// choose the programme instead of a starting week and every patient begins
/// their own protocol at week 1.
void main() {
  const lastWeek = DashboardNotifier.totalWeeks;

  // Five days every week, so a "full" week is the same number throughout and
  // these cases read the way they did before.
  final steady = protocolFor(
    severityBand: 'mild',
    activity: IPAQActivityLevel.high,
  );
  const full = 5;

  int currentWeek({
    Set<int> touched = const {},
    Map<int, int> completedDays = const {},
  }) => resolveCurrentWeek(
    weeksTouched: touched,
    completedDaysByWeek: completedDays,
    protocol: steady,
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
    expect(currentWeek(touched: {1, 2}, completedDays: {1: full, 2: 4}), 2);
  });

  test('a patient who has done nothing is on week one', () {
    expect(currentWeek(), 1);
  });

  test('activity decides where the patient is', () {
    expect(currentWeek(touched: {4}, completedDays: {4: 2}), 4);
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

  test('a week is judged against its own prescribed day count', () {
    // Mild + low activity is three days in week 1 and five by week 8, so the
    // same three completed days finish one week and not the other.
    final varying = protocolFor(
      severityBand: 'mild',
      activity: IPAQActivityLevel.low,
    );
    int week(Set<int> touched, Map<int, int> days) => resolveCurrentWeek(
      weeksTouched: touched,
      completedDaysByWeek: days,
      protocol: varying,
    );

    expect(week({1}, {1: 3}), 2, reason: 'week 1 prescribes three days');
    expect(week({3}, {3: 3}), 3, reason: 'weeks 3-4 prescribe four');
  });
}
