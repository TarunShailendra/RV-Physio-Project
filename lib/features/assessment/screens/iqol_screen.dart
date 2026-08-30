import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/glass_theme.dart';
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
  bool _triedToAdvance = false;

  bool _isCurrentPageAnswered(IqolNotifier notifier) {
    if (_page < 22) {
      return notifier.model.items[_page] != 0;
    }
    if (_page == 22) {
      return notifier.model.durationYears > 0 ||
          notifier.model.durationMonths > 0;
    }
    return true;
  }

  void _handleNext(IqolNotifier notifier) {
    setState(() => _triedToAdvance = true);
    if (!_isCurrentPageAnswered(notifier)) return;

    setState(() => _triedToAdvance = false);
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _handleSubmit() async {
    final notifier = context.read<IqolNotifier>();
    if (!_isCurrentPageAnswered(notifier)) return;

    final summary = context.read<AssessmentSummaryNotifier>();
    final dashboardNotifier = context.read<DashboardNotifier>();
    final exerciseNotifier = context.read<ExerciseNotifier>();
    summary.saveIqol(await notifier.submit());
    if (!mounted) return;
    dashboardNotifier.applyAssessmentSummary(summary);
    exerciseNotifier.loadRecommendedWeek(summary.recommendedStartWeek);
    context.go('/dashboard');
  }

  void _goBack() {
    setState(() => _triedToAdvance = false);
    _controller.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<IqolNotifier>();
    final options = [
      l10n.iqolExtremely,
      l10n.iqolQuiteABit,
      l10n.iqolModerately,
      l10n.iqolALittle,
      l10n.iqolNotAtAll,
    ];
    final questions = _questions(l10n);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.iqolTitle),
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
                    value: (_page + 1) / 24,
                    minHeight: 6,
                    color: const Color(0xFF4DB6AC),
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (value) => setState(() {
                    _page = value;
                    _triedToAdvance = false;
                  }),
                  itemCount: 24,
                  itemBuilder: (context, index) {
                    if (index < 22) {
                      return _QuestionPage(
                        title: questions[index],
                        value: notifier.model.items[index],
                        showError: _triedToAdvance,
                        options: options,
                        onChanged: (v) => notifier.updateItem(index, v),
                      );
                    }
                    if (index == 22) {
                      return _AboutPage(
                        notifier: notifier,
                        showError: _triedToAdvance,
                        l10n: l10n,
                      );
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
                          onPressed: _goBack,
                          child: Text(l10n.assessmentBack),
                        ),
                      ),
                    if (_page > 0) const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF00897B,
                              ).withValues(alpha: 0.5),
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
                          onPressed: _page == 23
                              ? _handleSubmit
                              : () => _handleNext(notifier),
                          child: Text(
                            _page == 23 ? l10n.submit : l10n.assessmentNext,
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
    required this.value,
    required this.showError,
    required this.options,
    required this.onChanged,
  });

  final String title;
  final int value;
  final bool showError;
  final List<String> options;
  final ValueChanged<int> onChanged;

  int get _displayValue => value == 0 ? 1 : value;

  String get _currentLabel {
    if (value == 0) return '';
    final index = value - 1;
    if (index >= 0 && index < options.length) {
      return '$value — ${options[index]}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final unanswered = value == 0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _RequiredQuestionLabel(
          label: title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 16),
        GlassCard(
          hasError: showError && unanswered,
          padding: const EdgeInsets.all(20),
          opacity: 0.12,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _currentLabel.isEmpty ? '--' : _currentLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              if (_currentLabel.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Score: $value / 5',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF4DB6AC),
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFF00897B).withValues(alpha: 0.2),
                  valueIndicatorColor: const Color(0xFF00897B),
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                  thumbShape: GlowingThumbShape(),
                ),
                child: Slider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  value: _displayValue.toDouble(),
                  onChanged: (v) => onChanged(v.round()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        options.first,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        options.last,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showError && unanswered)
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

class _AboutPage extends StatelessWidget {
  const _AboutPage({
    required this.notifier,
    required this.showError,
    required this.l10n,
  });

  final IqolNotifier notifier;
  final bool showError;
  final AppLocalizations l10n;

  bool get _answered =>
      notifier.model.durationYears > 0 || notifier.model.durationMonths > 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _RequiredQuestionLabel(
          label: l10n.iqolAboutTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        GlassLabeledSlider(
          title: l10n.iqol_about_q1,
          value: notifier.model.durationYears,
          min: 0,
          max: 80,
          showError: showError && !_answered,
          currentLabel: notifier.model.durationYears == 0
              ? ''
              : '${notifier.model.durationYears}',
          minLabel: '0',
          maxLabel: '80',
          onChanged: (v) => notifier.updateBackground(durationYears: v),
        ),
        const SizedBox(height: 20),
        GlassLabeledSlider(
          title: l10n.iqol_about_q2,
          value: notifier.model.durationMonths,
          min: 0,
          max: 11,
          showError: showError && !_answered,
          currentLabel: notifier.model.durationMonths == 0
              ? ''
              : '${notifier.model.durationMonths}',
          minLabel: '0',
          maxLabel: '11',
          onChanged: (v) => notifier.updateBackground(durationMonths: v),
        ),
        const SizedBox(height: 20),
        GlassLabeledSlider(
          title: l10n.iqol_about_q3,
          value: notifier.model.severity,
          min: 0,
          max: 5,
          showError: false,
          currentLabel: notifier.model.severity == 0
              ? ''
              : '${notifier.model.severity}',
          minLabel: '0',
          maxLabel: '5',
          onChanged: (v) => notifier.updateBackground(severity: v),
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          opacity: 0.12,
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  l10n.iqol_about_q4,
                  style: const TextStyle(color: Colors.white),
                ),
                activeThumbColor: const Color(0xFF4DB6AC),
                onChanged: (value) =>
                    notifier.updateBackground(stressLeak: value),
                value: notifier.model.stressLeak,
                activeTrackColor: const Color(
                  0xFF00897B,
                ).withValues(alpha: 0.5),
              ),
              SwitchListTile(
                title: Text(
                  l10n.iqol_about_q5,
                  style: const TextStyle(color: Colors.white),
                ),
                activeThumbColor: const Color(0xFF4DB6AC),
                onChanged: (value) =>
                    notifier.updateBackground(urgeLeak: value),
                value: notifier.model.urgeLeak,
                activeTrackColor: const Color(
                  0xFF00897B,
                ).withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassLabeledSlider(
          title: l10n.iqol_about_q6,
          value: notifier.model.freqCode,
          min: 0,
          max: 5,
          showError: false,
          currentLabel: notifier.model.freqCode == 0
              ? ''
              : '${notifier.model.freqCode}',
          minLabel: '0',
          maxLabel: '5',
          onChanged: (v) => notifier.updateBackground(freqCode: v),
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
    );
  }
}

class _IqolResultPage extends StatelessWidget {
  const _IqolResultPage({required this.notifier});

  final IqolNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final score = notifier.score.clamp(0.0, 100.0);
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        opacity: 0.12,
        child: CircularPercentIndicator(
          radius: 90,
          lineWidth: 12,
          percent: score / 100,
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: const Color(0xFF4DB6AC),
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.iqolScoreOutOf100,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                score.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
