import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/glass_theme.dart';
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
  bool _triedToAdvance = false;

  bool _isCurrentStepAnswered(IpaqNotifier notifier) {
    switch (_step) {
      case 0:
        return notifier.model.sittingHours > 0 ||
            notifier.model.sittingMins > 0;
      case 1:
        return notifier.model.walkDays > 0;
      case 2:
        return notifier.model.moderateDays > 0;
      case 3:
        return notifier.model.vigorousDays > 0;
      default:
        return true;
    }
  }

  void _handleNext(IpaqNotifier notifier) {
    setState(() => _triedToAdvance = true);
    if (_isCurrentStepAnswered(notifier)) {
      setState(() {
        _triedToAdvance = false;
        _step++;
      });
    }
  }

  void _handleSubmit() async {
    final notifier = context.read<IpaqNotifier>();
    if (!_isCurrentStepAnswered(notifier)) return;

    final summary = context.read<AssessmentSummaryNotifier>();
    summary.saveIpaq(notifier.model);
    if (!mounted) return;
    context.read<DashboardNotifier>().applyAssessmentSummary(summary);
    context.read<ExerciseNotifier>().loadRecommendedWeek(
      summary.recommendedStartWeek,
    );
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<IpaqNotifier>();
    final steps = [
      _SittingStep(notifier: notifier, showError: _triedToAdvance),
      _ActivityStep(
        label: '${l10n.ipaq_q2}\nExamples: walking for transport, work, or recreation.',
        days: notifier.model.walkDays,
        hours: notifier.model.walkHours,
        mins: notifier.model.walkMins,
        showError: _triedToAdvance,
        onChanged: notifier.updateWalking,
      ),
      _ActivityStep(
        label: '${l10n.ipaq_q3}\nExamples: brisk cycling, cleaning, gardening, or swimming.',
        days: notifier.model.moderateDays,
        hours: notifier.model.moderateHours,
        mins: notifier.model.moderateMins,
        showError: _triedToAdvance,
        onChanged: notifier.updateModerate,
      ),
      _ActivityStep(
        label: '${l10n.ipaq_q4}\nExamples: running, aerobics, heavy lifting, or fast cycling.',
        days: notifier.model.vigorousDays,
        hours: notifier.model.vigorousHours,
        mins: notifier.model.vigorousMins,
        showError: _triedToAdvance,
        onChanged: notifier.updateVigorous,
      ),
      _IpaqResultStep(notifier: notifier),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(l10n.ipaqTitle),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                              color: Colors.white.withValues(alpha: 0.5),
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
                              color: const Color(0xFF00897B).withValues(alpha: 0.5),
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
                              ? _handleSubmit
                              : () => _handleNext(notifier),
                          child: Text(
                            _step == steps.length - 1
                                ? l10n.submit
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

class _SittingStep extends StatelessWidget {
  const _SittingStep({required this.notifier, required this.showError});

  final IpaqNotifier notifier;
  final bool showError;

  bool get _answered =>
      notifier.model.sittingHours > 0 || notifier.model.sittingMins > 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _RequiredQuestionLabel(
            label: l10n.ipaq_q1,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          GlassLabeledSlider(
            title: l10n.hours,
            value: notifier.model.sittingHours,
            min: 0,
            max: 24,
            showError: showError && !_answered,
            currentLabel: notifier.model.sittingHours == 0
                ? ''
                : '${notifier.model.sittingHours} ${l10n.hours}',
            minLabel: '0 ${l10n.hours}',
            maxLabel: '24 ${l10n.hours}',
            onChanged: (value) => notifier.updateSitting(hours: value),
          ),
          const SizedBox(height: 20),
          GlassLabeledSlider(
            title: l10n.minutes,
            value: notifier.model.sittingMins,
            min: 0,
            max: 59,
            showError: showError && !_answered,
            currentLabel: notifier.model.sittingMins == 0
                ? ''
                : '${notifier.model.sittingMins} ${l10n.minutes}',
            minLabel: '0 ${l10n.minutes}',
            maxLabel: '59 ${l10n.minutes}',
            onChanged: (value) => notifier.updateSitting(mins: value),
          ),
          if (showError && !_answered)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Please answer all questions',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityStep extends StatelessWidget {
  const _ActivityStep({
    required this.label,
    required this.days,
    required this.hours,
    required this.mins,
    required this.showError,
    required this.onChanged,
  });

  final String label;
  final int days;
  final int hours;
  final int mins;
  final bool showError;
  final void Function({int? days, int? hours, int? mins}) onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final answered = days > 0;

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _RequiredQuestionLabel(
            label: label,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          GlassLabeledSlider(
            title: l10n.days,
            value: days,
            min: 0,
            max: 7,
            showError: showError && !answered,
            currentLabel: days == 0 ? '' : '$days ${l10n.days}',
            minLabel: l10n.noDays,
            maxLabel: l10n.allSevenDays,
            onChanged: (value) => onChanged(days: value),
          ),
          if (days > 0) ...[
            const SizedBox(height: 20),
            _NumberField(
              label: l10n.hours,
              initialValue: hours,
              showError: false,
              onChanged: (value) => onChanged(hours: value),
            ),
            const SizedBox(height: 12),
            _NumberField(
              label: l10n.minutes,
              initialValue: mins,
              showError: false,
              onChanged: (value) => onChanged(mins: value),
            ),
          ],
          if (showError && !answered)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Please answer all questions',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
        ],
      ),
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
      child: GlassCard(
        padding: const EdgeInsets.all(28),
        opacity: 0.12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.activityLevel,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4DB6AC).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF80CBC4).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                level,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n.totalMetMinutes}: ${notifier.model.totalMetMinutes.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.initialValue,
    required this.showError,
    required this.onChanged,
  });

  final String label;
  final int initialValue;
  final bool showError;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hasError: showError,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      borderRadius: 14,
      opacity: 0.12,
      child: TextFormField(
        initialValue: initialValue == 0 ? null : initialValue.toString(),
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF4DB6AC), width: 2),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.08),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) => onChanged(int.tryParse(value) ?? 0),
      ),
    );
  }
}
