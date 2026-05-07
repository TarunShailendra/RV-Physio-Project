import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/dashboard_notifier.dart';
import '../../exercise/exercise_notifier.dart';
import '../notifiers/assessment_summary_notifier.dart';
import '../notifiers/iciq_notifier.dart';

class IciqScreen extends StatefulWidget {
  const IciqScreen({super.key});

  @override
  State<IciqScreen> createState() => _IciqScreenState();
}

class _IciqScreenState extends State<IciqScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<IciqNotifier>();
    final steps = [
      _ProfileStep(notifier: notifier),
      _FrequencyStep(notifier: notifier),
      _AmountStep(notifier: notifier),
      _InterferenceStep(notifier: notifier),
      _WhenLeaksStep(notifier: notifier),
      _ResultStep(notifier: notifier),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.iciqTitle),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.assessmentStep(_step + 1, steps.length),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
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
                              summary.saveIciq(notifier.submit());
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
                            ? l10n.continueText
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

class _ProfileStep extends StatelessWidget {
  const _ProfileStep({required this.notifier});

  final IciqNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dob = notifier.model.dob;
    final genderOptions = [l10n.female, l10n.male, l10n.other];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: Text(l10n.dateOfBirth),
            subtitle: Text(
              dob == null
                  ? l10n.selectDateOfBirth
                  : '${dob.day}/${dob.month}/${dob.year}',
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: DateTime(1985),
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (selected != null) notifier.setDob(selected);
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(l10n.gender, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        RadioGroup<String>(
          groupValue: notifier.model.gender,
          onChanged: (value) {
            if (value != null) notifier.setGender(value);
          },
          child: Column(
            children: [
              for (final option in genderOptions)
                Card(
                  child: RadioListTile<String>(
                    value: option,
                    title: Text(option),
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrequencyStep extends StatelessWidget {
  const _FrequencyStep({required this.notifier});

  final IciqNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      _Option(0, l10n.never),
      _Option(1, l10n.onceAWeekOrLess),
      _Option(2, l10n.twoOrThreeTimesAWeek),
      _Option(3, l10n.onceADay),
      _Option(4, l10n.severalTimesADay),
      _Option(5, l10n.allTheTime),
    ];

    return _RadioStep<int>(
      title: l10n.iciq_q3,
      value: notifier.model.leakFrequency,
      options: options,
      onChanged: notifier.setLeakFrequency,
    );
  }
}

class _AmountStep extends StatelessWidget {
  const _AmountStep({required this.notifier});

  final IciqNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      _Option(0, l10n.none),
      _Option(2, l10n.smallAmount),
      _Option(4, l10n.moderateAmount),
      _Option(6, l10n.largeAmount),
    ];

    return _RadioStep<int>(
      title: l10n.iciq_q4,
      value: notifier.model.leakAmount,
      options: options,
      onChanged: notifier.setLeakAmount,
    );
  }
}

class _InterferenceStep extends StatelessWidget {
  const _InterferenceStep({required this.notifier});

  final IciqNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.iciq_q5, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  notifier.model.lifeInterference.toString(),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Slider(
                  min: 0,
                  max: 10,
                  divisions: 10,
                  value: notifier.model.lifeInterference.toDouble(),
                  activeColor: AppTheme.primaryColor,
                  label: notifier.model.lifeInterference.toString(),
                  onChanged: (value) =>
                      notifier.setLifeInterference(value.round()),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WhenLeaksStep extends StatelessWidget {
  const _WhenLeaksStep({required this.notifier});

  final IciqNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = [
      l10n.iciqWhenLeaksNever,
      l10n.iciqWhenLeaksBeforeToilet,
      l10n.iciqWhenLeaksCoughSneeze,
      l10n.iciqWhenLeaksAsleep,
      l10n.iciqWhenLeaksActivity,
      l10n.iciqWhenLeaksAfterUrination,
      l10n.iciqWhenLeaksNoReason,
      l10n.iciqWhenLeaksAllTime,
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.iciq_q6, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (final option in options)
          Card(
            child: CheckboxListTile(
              value: notifier.model.whenLeaks.contains(option),
              activeColor: AppTheme.primaryColor,
              title: Text(option),
              onChanged: (_) => notifier.toggleWhenLeak(option),
            ),
          ),
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({required this.notifier});

  final IciqNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final severity = switch (notifier.severityBand) {
      'mild' => l10n.severityMild,
      'moderate' => l10n.severityModerate,
      _ => l10n.severitySevere,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: AppTheme.primaryColor.withAlpha(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.assessmentResult),
                const SizedBox(height: 12),
                Text(
                  notifier.score.toString(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('${l10n.iciqSeverity}: $severity'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioStep<T> extends StatelessWidget {
  const _RadioStep({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final T value;
  final List<_Option<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        RadioGroup<T>(
          groupValue: value,
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
          child: Column(
            children: [
              for (final option in options)
                Card(
                  child: RadioListTile<T>(
                    value: option.value,
                    title: Text(option.label),
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Option<T> {
  const _Option(this.value, this.label);

  final T value;
  final String label;
}
