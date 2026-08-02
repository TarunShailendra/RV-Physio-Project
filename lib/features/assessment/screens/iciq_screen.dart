import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth_notifier.dart';
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
  bool _triedToAdvance = false;

  bool _isCurrentStepAnswered(IciqNotifier notifier) {
    switch (_step) {
      case 0:
        return notifier.model.leakFrequency != -1;
      case 1:
        return notifier.model.leakAmount != -1;
      case 2:
        return notifier.model.lifeInterference != -1;
      case 3:
        return notifier.model.whenLeaks.isNotEmpty;
      default:
        return true;
    }
  }

  void _handleNext(IciqNotifier notifier) {
    setState(() => _triedToAdvance = true);
    if (_isCurrentStepAnswered(notifier)) {
      setState(() {
        _triedToAdvance = false;
        _step++;
      });
    }
  }

  Future<void> _handleIciqComplete(
    BuildContext context,
    IciqNotifier notifier,
  ) async {
    setState(() => _triedToAdvance = true);
    if (!_isCurrentStepAnswered(notifier)) return;

    final summary = context.read<AssessmentSummaryNotifier>();
    summary.saveIciq(await notifier.submit());
    if (!context.mounted) return;

    context.read<DashboardNotifier>().applyAssessmentSummary(summary);
    context.read<ExerciseNotifier>().loadRecommendedWeek(
      summary.recommendedStartWeek,
    );

    final severity = notifier.severityBand;

    if (severity == 'severe') {
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.iciqHighSeverityTitle),
          content: Text(AppLocalizations.of(ctx)!.iciqHighSeverityMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.of(ctx)!.ok),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      context.go('/ipaq');
    } else {
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(ctx)!.iciqOfferExercisesTitle),
          content: Text(AppLocalizations.of(ctx)!.iciqOfferExercisesMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(AppLocalizations.of(ctx)!.no),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.of(ctx)!.yes),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      context.go('/ipaq');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<IciqNotifier>();
    final steps = [
      _FrequencyStep(notifier: notifier, showError: _triedToAdvance),
      _AmountStep(notifier: notifier, showError: _triedToAdvance),
      _InterferenceStep(notifier: notifier, showError: _triedToAdvance),
      _WhenLeaksStep(notifier: notifier, showError: _triedToAdvance),
      _ResultStep(notifier: notifier),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(l10n.iciqTitle),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / steps.length,
                    minHeight: 6,
                    color: const Color(0xFF4DB6AC),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.assessmentStep(_step + 1, steps.length),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ),
              Expanded(child: IntrinsicHeight(child: steps[_step])),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => setState(() {
                            _triedToAdvance = false;
                            _step--;
                          }),
                          child: Text(l10n.assessmentBack),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00897B).withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00897B),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _step == steps.length - 1
                              ? () => _handleIciqComplete(context, notifier)
                              : () => _handleNext(notifier),
                          child: Text(
                            _step == steps.length - 1
                                ? l10n.continueText
                                : l10n.assessmentNext,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrequencyStep extends StatelessWidget {
  const _FrequencyStep({required this.notifier, required this.showError});

  final IciqNotifier notifier;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: GlassLabeledSlider(
        title: l10n.iciq_q3,
        value: notifier.model.leakFrequency,
        min: 0,
        max: 5,
        showError: showError,
        isRequired: true,
        errorMessage: 'Please answer all questions',
        currentLabel: _frequencyLabel(notifier.model.leakFrequency, l10n),
        minLabel: l10n.never,
        maxLabel: l10n.allTheTime,
        onChanged: (value) => notifier.setLeakFrequency(value),
      ),
    );
  }

  String _frequencyLabel(int value, AppLocalizations l10n) {
    final labels = [
      l10n.never,
      l10n.onceAWeekOrLess,
      l10n.twoOrThreeTimesAWeek,
      l10n.onceADay,
      l10n.severalTimesADay,
      l10n.allTheTime,
    ];
    if (value >= 0 && value < labels.length) return '$value â€” ${labels[value]}';
    return '';
  }
}

class _AmountStep extends StatelessWidget {
  const _AmountStep({required this.notifier, required this.showError});

  final IciqNotifier notifier;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: GlassLabeledSlider(
        title: l10n.iciq_q4,
        value: notifier.model.leakAmount,
        min: 1,
        max: 3,
        showError: showError,
        isRequired: true,
        errorMessage: 'Please answer all questions',
        currentLabel: _amountLabel(notifier.model.leakAmount, l10n),
        minLabel: l10n.none,
        maxLabel: l10n.moderateAmount,
        onChanged: (value) => notifier.setLeakAmount(value),
      ),
    );
  }

  String _amountLabel(int value, AppLocalizations l10n) {
    if (value == 1) return '1 â€” ${l10n.none}';
    if (value == 2) return '2 â€” ${l10n.smallAmount}';
    if (value == 3) return '3 â€” ${l10n.moderateAmount}';
    return '';
  }
}

class _InterferenceStep extends StatelessWidget {
  const _InterferenceStep({required this.notifier, required this.showError});

  final IciqNotifier notifier;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: GlassLabeledSlider(
        title: l10n.iciq_q5,
        value: notifier.model.lifeInterference,
        min: 0,
        max: 10,
        showError: showError,
        isRequired: true,
        errorMessage: 'Please answer all questions',
        currentLabel: notifier.model.lifeInterference == -1
            ? ''
            : '${notifier.model.lifeInterference}',
        minLabel: l10n.notAtAll,
        maxLabel: l10n.aGreatDeal,
        onChanged: (value) => notifier.setLifeInterference(value),
      ),
    );
  }
}

class _WhenLeaksStep extends StatelessWidget {
  const _WhenLeaksStep({required this.notifier, required this.showError});

  final IciqNotifier notifier;
  final bool showError;

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
        _RequiredQuestionLabel(
          label: l10n.iciq_q6,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 12),
        GlassCard(
          hasError: showError && notifier.model.whenLeaks.isEmpty,
          padding: const EdgeInsets.symmetric(vertical: 8),
          opacity: 0.12,
          child: Column(
            children: [
              for (final option in options)
                GlassCard(
                  borderRadius: 12,
                  padding: EdgeInsets.zero,
                  opacity: 0.06,
                  child: CheckboxListTile(
                    value: notifier.model.whenLeaks.contains(option),
                    activeColor: const Color(0xFF4DB6AC),
                    checkboxShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    title: Text(
                      option,
                      style: const TextStyle(color: Colors.white),
                    ),
                    onChanged: (_) => notifier.toggleWhenLeak(option),
                  ),
                ),
            ],
          ),
        ),
        if (showError && notifier.model.whenLeaks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Please answer all questions',
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _RequiredQuestionLabel extends StatelessWidget {
  const _RequiredQuestionLabel({required this.label, this.style});

  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
      style: style,
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
        child: GlassCard(
          padding: const EdgeInsets.all(32),
          opacity: 0.12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.assessmentResult,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              Text(
                notifier.score.toString(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: const Color(0xFF80CBC4),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4DB6AC).withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '${l10n.iciqSeverity}: $severity',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
