import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/dashboard_notifier.dart';
import '../../exercise/exercise_notifier.dart';
import '../notifiers/assessment_summary_notifier.dart';
import '../notifiers/iqol_notifier.dart';

class IqolScreen extends StatefulWidget {
  const IqolScreen({super.key});

  @override
  State<IqolScreen> createState() => _IqolScreenState();
}

class _IqolScreenState extends State<IqolScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<IqolNotifier>();
    final questions = _questions(l10n);
    final options = [
      l10n.iqolExtremely,
      l10n.iqolQuiteABit,
      l10n.iqolModerately,
      l10n.iqolALittle,
      l10n.iqolNotAtAll,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.iqolTitle),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_page + 1) / 24,
              minHeight: 6,
              color: AppTheme.primaryColor,
              backgroundColor: AppTheme.primaryColor.withAlpha(32),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => _page = value),
                itemCount: 24,
                itemBuilder: (context, index) {
                  if (index < 22) {
                    return _QuestionPage(
                      title: questions[index],
                      groupValue: notifier.model.items[index] == 0
                          ? null
                          : notifier.model.items[index],
                      options: options,
                      onChanged: (value) => notifier.updateItem(index, value),
                    );
                  }
                  if (index == 22) {
                    return _AboutPage(notifier: notifier);
                  }
                  return _IqolResultPage(notifier: notifier);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_page > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _controller.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        ),
                        child: Text(l10n.assessmentBack),
                      ),
                    ),
                  if (_page > 0) const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _page == 23
                          ? () {
                              final summary = context
                                  .read<AssessmentSummaryNotifier>();
                              summary.saveIqol(notifier.submit());
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
                          : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                      child: Text(
                        _page == 23 ? l10n.submit : l10n.assessmentNext,
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

  List<String> _questions(AppLocalizations l10n) => [
    l10n.iqolQ1,
    l10n.iqolQ2,
    l10n.iqolQ3,
    l10n.iqolQ4,
    l10n.iqolQ5,
    l10n.iqolQ6,
    l10n.iqolQ7,
    l10n.iqolQ8,
    l10n.iqolQ9,
    l10n.iqolQ10,
    l10n.iqolQ11,
    l10n.iqolQ12,
    l10n.iqolQ13,
    l10n.iqolQ14,
    l10n.iqolQ15,
    l10n.iqolQ16,
    l10n.iqolQ17,
    l10n.iqolQ18,
    l10n.iqolQ19,
    l10n.iqolQ20,
    l10n.iqolQ21,
    l10n.iqolQ22,
  ];
}

class _QuestionPage extends StatelessWidget {
  const _QuestionPage({
    required this.title,
    required this.groupValue,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final int? groupValue;
  final List<String> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        RadioGroup<int>(
          groupValue: groupValue,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          child: Column(
            children: [
              for (var index = 0; index < options.length; index++)
                Card(
                  child: RadioListTile<int>(
                    value: index + 1,
                    title: Text(options[index]),
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

class _AboutPage extends StatelessWidget {
  const _AboutPage({required this.notifier});

  final IqolNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.iqolAboutTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _NumberField(
          label: l10n.iqol_about_q1,
          onChanged: (value) => notifier.updateBackground(durationYears: value),
        ),
        _NumberField(
          label: l10n.iqol_about_q2,
          onChanged: (value) =>
              notifier.updateBackground(durationMonths: value),
        ),
        _NumberField(
          label: l10n.iqol_about_q3,
          onChanged: (value) => notifier.updateBackground(severity: value),
        ),
        SwitchListTile(
          title: Text(l10n.iqol_about_q4),
          value: notifier.model.stressLeak,
          activeThumbColor: AppTheme.primaryColor,
          onChanged: (value) => notifier.updateBackground(stressLeak: value),
        ),
        SwitchListTile(
          title: Text(l10n.iqol_about_q5),
          value: notifier.model.urgeLeak,
          activeThumbColor: AppTheme.primaryColor,
          onChanged: (value) => notifier.updateBackground(urgeLeak: value),
        ),
        _NumberField(
          label: l10n.iqol_about_q6,
          onChanged: (value) => notifier.updateBackground(freqCode: value),
        ),
      ],
    );
  }
}

class _IqolResultPage extends StatelessWidget {
  const _IqolResultPage({required this.notifier});

  final IqolNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final score = notifier.score.clamp(0, 100);
    return Center(
      child: CircularPercentIndicator(
        radius: 100,
        lineWidth: 14,
        percent: score / 100,
        circularStrokeCap: CircularStrokeCap.round,
        progressColor: AppTheme.primaryColor,
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.iqolScoreOutOf100),
            Text(
              score.toStringAsFixed(1),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.label, required this.onChanged});

  final String label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
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
