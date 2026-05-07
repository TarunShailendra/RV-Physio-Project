import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../l10n/app_localizations.dart';
import '../../assessment/notifiers/assessment_summary_notifier.dart';
import '../exercise_notifier.dart';
import '../models/exercise_model.dart';

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
      final summary = context.read<AssessmentSummaryNotifier>();
      context.read<ExerciseNotifier>().loadRecommendedWeek(
        summary.recommendedStartWeek,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ExerciseNotifier>();
    final plan = notifier.currentPlan;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exercise),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const AppBottomNavigation(),
      body: plan == null
          ? const Center(child: CircularProgressIndicator())
          : _ExerciseContent(notifier: notifier, plan: plan),
    );
  }
}

class _ExerciseContent extends StatelessWidget {
  const _ExerciseContent({required this.notifier, required this.plan});

  final ExerciseNotifier notifier;
  final WeeklyPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final completedCount = plan.sessions
        .where((session) => session.isCompleted)
        .length;
    final currentSession = plan.sessions[notifier.currentSessionIndex];

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
                  onSelected: (_) => notifier.loadWeek(week),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weekProgress(plan.weekNumber, 8),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: plan.weekNumber / 8,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: AppTheme.primaryColor.withAlpha(26),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weekDifficulty(plan.weekNumber, plan.difficultyLabel),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: completedCount / plan.sessions.length,
                    minHeight: 8,
                    backgroundColor: AppTheme.primaryColor.withAlpha(41),
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.completedCount(completedCount, plan.sessions.length),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSession.exerciseName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _SessionDetail(
                    label: l10n.reps,
                    value: currentSession.reps.toString(),
                  ),
                  _SessionDetail(
                    label: l10n.hold,
                    value: l10n.seconds(currentSession.holdSeconds),
                  ),
                  _SessionDetail(
                    label: l10n.rest,
                    value: l10n.seconds(currentSession.restSeconds),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor, width: 10),
              ),
              alignment: Alignment.center,
              child: Text(
                _formatSeconds(notifier.timerSecondsRemaining, l10n),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: notifier.isTimerRunning
                  ? notifier.pauseTimer
                  : notifier.startTimer,
              icon: Icon(
                notifier.isTimerRunning ? Icons.pause : Icons.play_arrow,
              ),
              label: Text(notifier.isTimerRunning ? l10n.pause : l10n.start),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: currentSession.isCompleted
                ? null
                : () => notifier.completeSession(notifier.currentSessionIndex),
            child: Text(l10n.completeSession),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final session in plan.sessions)
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: session.isCompleted
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSeconds(int seconds, AppLocalizations l10n) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes == 0) {
      return l10n.seconds(remainingSeconds);
    }
    return l10n.minutesAndSeconds(minutes, remainingSeconds);
  }
}

class _SessionDetail extends StatelessWidget {
  const _SessionDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
