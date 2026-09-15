import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../content/exercise_content.dart';
import '../exercise_notifier.dart';
import '../models/exercise_model.dart';
import '../models/protocol.dart';

/// Opens one exercise: what it is, how to do it, what not to do, and — when
/// the document prescribes a hold — a timer for it.
///
/// Before this existed the app showed an exercise name and a rep count and
/// left the patient to work out the rest. The instructions come from the
/// protocol document and are the same text a physiotherapist would read out.
Future<void> showExerciseDetail(
  BuildContext context,
  ExerciseSession session,
  int dayIndex,
  int sessionIndex,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) => _ExerciseDetail(
        session: session,
        dayIndex: dayIndex,
        sessionIndex: sessionIndex,
        scrollController: scrollController,
      ),
    ),
  );
}

class _ExerciseDetail extends StatelessWidget {
  const _ExerciseDetail({
    required this.session,
    required this.dayIndex,
    required this.sessionIndex,
    required this.scrollController,
  });

  final ExerciseSession session;
  final int dayIndex;
  final int sessionIndex;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<ExerciseNotifier>();
    final language = Localizations.localeOf(context).languageCode;
    final text = exerciseContent[session.exerciseKey]?.forLocale(language);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Text(
          session.exerciseName,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (session.position != null)
              _Chip(label: _positionLabel(session.position!, l10n)),
            if (session.reps != null)
              _Chip(
                label: session.holdSeconds == null
                    ? l10n.repsOnly(session.reps!)
                    : l10n.repsAndHold(session.reps!, session.holdSeconds!),
              ),
            if (session.sets > 1) _Chip(label: l10n.setsLabel(session.sets)),
          ],
        ),
        const SizedBox(height: 20),

        if (text != null) ...[
          _Heading(l10n.startingPosition),
          Text(text.startingPosition),
          const SizedBox(height: 20),
          _Heading(l10n.howToDoIt),
          for (var i = 0; i < text.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${i + 1}.',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(child: Text(text.steps[i])),
                ],
              ),
            ),
          if (text.tip != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(text.tip!)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _RuleList(
            title: l10n.doLabel,
            rules: text.dos,
            icon: Icons.check_circle_outline,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 12),
          _RuleList(
            title: l10n.dontLabel,
            rules: text.donts,
            icon: Icons.cancel_outlined,
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 24),
        ],

        // Exercises the document prescribes without a hold are counted by the
        // patient, not timed, so there is no countdown to show for them.
        if (session.holdSeconds != null) ...[
          _Timer(session: session, notifier: notifier),
          const SizedBox(height: 20),
        ],

        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: session.isCompleted
              ? null
              : () async {
                  final navigator = Navigator.of(context);
                  await notifier.completeSession(dayIndex, sessionIndex);
                  navigator.pop();
                },
          child: Text(l10n.markAsDone),
        ),
      ],
    );
  }

  String _positionLabel(ExercisePosition position, AppLocalizations l10n) =>
      switch (position) {
        ExercisePosition.supine => l10n.positionSupine,
        ExercisePosition.sitting => l10n.positionSitting,
        ExercisePosition.standing => l10n.positionStanding,
      };
}

class _Timer extends StatelessWidget {
  const _Timer({required this.session, required this.notifier});

  final ExerciseSession session;
  final ExerciseNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBetweenReps = notifier.phase == ExercisePhase.betweenReps;

    return Column(
      children: [
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor, width: 8),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _phaseLabel(notifier.phase, l10n),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
              ),
              // Only this rebuilds on each tick of the countdown.
              ValueListenableBuilder<int>(
                valueListenable: notifier.secondsRemaining,
                builder: (context, seconds, _) => Text(
                  l10n.seconds(seconds),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (notifier.currentRep > 0 && session.reps != null)
                Text(
                  '${notifier.currentRep} / ${session.reps}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: notifier.isTimerRunning
              ? notifier.pauseTimer
              : notifier.startTimer,
          icon: Icon(
            notifier.isTimerRunning
                ? Icons.pause
                : isBetweenReps
                ? Icons.skip_next
                : Icons.play_arrow,
          ),
          label: Text(
            notifier.isTimerRunning
                ? l10n.pause
                : isBetweenReps
                ? l10n.nextRep
                : l10n.start,
          ),
        ),
      ],
    );
  }

  String _phaseLabel(ExercisePhase phase, AppLocalizations l10n) =>
      switch (phase) {
        ExercisePhase.hold => l10n.hold,
        ExercisePhase.rest => l10n.rest,
        ExercisePhase.betweenReps => l10n.nextRep,
        ExercisePhase.finished => l10n.markAsDone,
        ExercisePhase.ready => l10n.start,
      };
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _RuleList extends StatelessWidget {
  const _RuleList({
    required this.title,
    required this.rules,
    required this.icon,
    required this.color,
  });

  final String title;
  final List<String> rules;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Heading(title),
      for (final rule in rules)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(rule)),
            ],
          ),
        ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppTheme.primaryColor.withAlpha(26),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: Theme.of(context).textTheme.bodySmall),
  );
}
