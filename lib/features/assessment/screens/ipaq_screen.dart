import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/dashboard_notifier.dart';
import '../../exercise/exercise_notifier.dart';
import '../models/ipaq_model.dart';
import '../notifiers/assessment_summary_notifier.dart';
import '../notifiers/ipaq_notifier.dart';

class IpaqScreen extends StatefulWidget {
  const IpaqScreen({super.key});

  @override
  State<IpaqScreen> createState() => _IpaqScreenState();
}

class _IpaqScreenState extends State<IpaqScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<IpaqNotifier>();
    final steps = [
      _SittingStep(notifier: notifier),
      _ActivityStep(
        title: l10n.ipaq_q2,
        days: notifier.model.walkDays,
        hours: notifier.model.walkHours,
        mins: notifier.model.walkMins,
        onChanged: notifier.updateWalking,
      ),
      _ActivityStep(
        title: l10n.ipaq_q3,
        days: notifier.model.moderateDays,
        hours: notifier.model.moderateHours,
        mins: notifier.model.moderateMins,
        onChanged: notifier.updateModerate,
      ),
      _ActivityStep(
        title: l10n.ipaq_q4,
        days: notifier.model.vigorousDays,
        hours: notifier.model.vigorousHours,
        mins: notifier.model.vigorousMins,
        onChanged: notifier.updateVigorous,
      ),
      _IpaqResultStep(notifier: notifier),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ipaqTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_step + 1) / steps.length,
              minHeight: 6,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.primaryColor.withAlpha(32),
            ),
            Expanded(child: steps[_step]),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: Text(l10n.assessmentBack),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _step == steps.length - 1
                          ? () {
                              final summary = context
                                  .read<AssessmentSummaryNotifier>();
                              summary.saveIpaq(notifier.model);
                              context
                                  .read<DashboardNotifier>()
                                  .applyAssessmentSummary(summary);
                              context
                                  .read<ExerciseNotifier>()
                                  .loadRecommendedWeek(
                                    summary.recommendedStartWeek,
                                  );
                              context.go('/dashboard');
                            }
                          : () => setState(() => _step++),
                      child: Text(
                        _step == steps.length - 1
                            ? l10n.submit
                            : l10n.assessmentNext,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SittingStep extends StatelessWidget {
  const _SittingStep({required this.notifier});

  final IpaqNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StepScaffold(
      title: l10n.ipaq_q1,
      children: [
        _NumberField(
          label: l10n.hours,
          initialValue: notifier.model.sittingHours,
          onChanged: (value) => notifier.updateSitting(hours: value),
        ),
        _NumberField(
          label: l10n.minutes,
          initialValue: notifier.model.sittingMins,
          onChanged: (value) => notifier.updateSitting(mins: value),
        ),
      ],
    );
  }
}

class _ActivityStep extends StatelessWidget {
  const _ActivityStep({
    required this.title,
    required this.days,
    required this.hours,
    required this.mins,
    required this.onChanged,
  });

  final String title;
  final int days;
  final int hours;
  final int mins;
  final void Function({int? days, int? hours, int? mins}) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _StepScaffold(
      title: title,
      children: [
        _NumberField(
          label: l10n.days,
          initialValue: days,
          onChanged: (value) => onChanged(days: value.clamp(0, 7)),
        ),
        if (days > 0) ...[
          _NumberField(
            label: l10n.hours,
            initialValue: hours,
            onChanged: (value) => onChanged(hours: value),
          ),
          _NumberField(
            label: l10n.minutes,
            initialValue: mins,
            onChanged: (value) => onChanged(mins: value),
          ),
        ],
      ],
    );
  }
}

class _IpaqResultStep extends StatelessWidget {
  const _IpaqResultStep({required this.notifier});

  final IpaqNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final level = switch (notifier.model.activityLevel) {
      IPAQActivityLevel.high => l10n.activityHigh,
      IPAQActivityLevel.moderate => l10n.activityModerate,
      IPAQActivityLevel.low => l10n.activityLow,
    };

    return Center(
      child: Card(
        color: AppTheme.primaryColor.withAlpha(20),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.activityLevel),
              const SizedBox(height: 12),
              Chip(
                backgroundColor: AppTheme.primaryColor,
                label: Text(level, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              Text(
                '${l10n.totalMetMinutes}: ${notifier.model.totalMetMinutes.toStringAsFixed(1)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  const _StepScaffold({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final int initialValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue == 0 ? null : initialValue.toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (value) => onChanged(int.tryParse(value) ?? 0),
      ),
    );
  }
}
