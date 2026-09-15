import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../l10n/app_localizations.dart';
import '../../assessment/notifiers/assessment_summary_notifier.dart';
import '../content/exercise_content.dart';
import '../exercise_notifier.dart';
import '../models/exercise_model.dart';
import 'exercise_detail_sheet.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final exercise = context.read<ExerciseNotifier>();
        // Only place the patient if no week is open. This ran unconditionally,
        // so navigating to the dashboard and back always jumped to the highest
        // unlocked week and discarded their position.
        if (exercise.currentPlan != null) return;
        final summary = context.read<AssessmentSummaryNotifier>();
        exercise.applyProtocol(summary.protocol);
        // applyProtocol only adopts the plan; it does not open a week, so the
        // screen would sit on its spinner without this.
        exercise.loadWeek(exercise.highestUnlockedWeek);
      } catch (e) {
        debugPrint('Exercise init error: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ExerciseNotifier>();
    final plan = notifier.currentPlan;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(l10n.exercise),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.health_and_safety_outlined),
            tooltip: l10n.safetyGuidance,
            onPressed: () => _showSafety(context),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavigation(),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : _ExerciseContent(notifier: notifier, plan: plan),
    );
  }
}

void _showSafety(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(
            l10n.safetyGuidance,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.doLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          for (final rule in generalDos)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rule)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l10n.dontLabel,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          for (final rule in generalDonts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.cancel_outlined,
                    size: 18,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rule)),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _ExerciseContent extends StatelessWidget {
  const _ExerciseContent({required this.notifier, required this.plan});

  final ExerciseNotifier notifier;
  final WeeklyPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentDay = notifier.currentDay;

    if (currentDay == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final week = index + 1;
                final isSelected = week == plan.weekNumber;
                return ChoiceChip(
                  label: Text(l10n.weekNumber(week)),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                  onSelected: notifier.canAccessWeek(week)
                      ? (_) => notifier.loadWeek(week)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          Card(
            color: AppTheme.primaryColor.withAlpha(26),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weekDifficulty(plan.weekNumber, plan.progressionFocus),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    // The denominator is this week's own prescribed days,
                    // three to five, not a fixed seven.
                    value: plan.daysPerWeek == 0
                        ? 0
                        : plan.completedDays / plan.daysPerWeek,
                    minHeight: 8,
                    backgroundColor: AppTheme.primaryColor.withAlpha(41),
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.daysDoneOfTotal(plan.completedDays, plan.daysPerWeek),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: plan.days.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final day = plan.days[index];
                final isSelected = index == notifier.currentDayIndex;
                return ChoiceChip(
                  label: Text(l10n.dayNumber(day.dayNumber)),
                  selected: isSelected,
                  selectedColor: day.isCompleted
                      ? Colors.green
                      : AppTheme.primaryColor,
                  backgroundColor: day.isCompleted
                      ? Colors.green.shade100
                      : Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: day.isCompleted
                        ? Colors.green
                        : isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                  onSelected: (_) => notifier.selectDay(index),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Text(
                l10n.dayNumber(currentDay.dayNumber),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                l10n.itemsDoneOfTotal(
                  currentDay.completedCount,
                  currentDay.sessions.length,
                ),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // The day as a checklist. It used to be five repeats of one exercise
          // driven by a single timer; a day is now up to fifteen different
          // exercises, so the patient works through them at their own pace and
          // can leave and come back without losing their place.
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < currentDay.sessions.length; i++)
                  _ItemRow(
                    session: currentDay.sessions[i],
                    dayIndex: notifier.currentDayIndex,
                    sessionIndex: i,
                    isLast: i == currentDay.sessions.length - 1,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.session,
    required this.dayIndex,
    required this.sessionIndex,
    required this.isLast,
  });

  final ExerciseSession session;
  final int dayIndex;
  final int sessionIndex;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dose = _dose(session, l10n);
    final subtitleParts = <String>[
      if (dose.isNotEmpty) dose,
      if (session.sets > 1) l10n.setsLabel(session.sets),
    ];

    return Column(
      children: [
        ListTile(
          // ListView recycles elements, and a row without a stable key picks
          // up its neighbour's state. The bladder diary shipped exactly that
          // bug once already.
          key: ValueKey(
            'item-${session.week}-${session.day}-${session.sessionNumber}',
          ),
          leading: Icon(
            session.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: session.isCompleted ? Colors.green.shade700 : Colors.grey,
          ),
          title: Text(session.exerciseName),
          subtitle: subtitleParts.isEmpty
              ? null
              : Text(subtitleParts.join(' · ')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              showExerciseDetail(context, session, dayIndex, sessionIndex),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }

  /// "12 reps - 10s hold", "12 reps", or nothing at all for an item the
  /// document prescribes without a count, such as diaphragmatic breathing.
  String _dose(ExerciseSession session, AppLocalizations l10n) {
    final reps = session.reps;
    if (reps == null) return '';
    final hold = session.holdSeconds;
    return hold == null ? l10n.repsOnly(reps) : l10n.repsAndHold(reps, hold);
  }
}
