import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../assessment/notifiers/assessment_summary_notifier.dart';
import '../../exercise/exercise_notifier.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final summary = context.read<AssessmentSummaryNotifier>();
    final exercise = context.read<ExerciseNotifier>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(l10n.assessmentResult),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AssessmentTile(
              title: l10n.iciqTitle,
              icon: Icons.assignment_outlined,
              completed: summary.iciq != null,
              onTap: () => context.go('/assessment/iciq'),
            ),
            _AssessmentTile(
              title: l10n.ipaqTitle,
              icon: Icons.directions_walk,
              completed: summary.ipaq != null,
              locked: summary.iciq == null,
              onTap: summary.iciq == null
                  ? null
                  : () => context.go('/assessment/ipaq'),
            ),
            _AssessmentTile(
              title: l10n.iqolTitle,
              icon: Icons.favorite_outline,
              completed: summary.iqol != null,
              locked: summary.iciq == null ||
                  summary.ipaq == null ||
                  !exercise.isIqolAvailable,
              onTap: summary.iciq == null ||
                      summary.ipaq == null ||
                      !exercise.isIqolAvailable
                  ? null
                  : () => context.go('/assessment/iqol'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({
    required this.title,
    required this.icon,
    this.completed = false,
    this.locked = false,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final bool completed;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withAlpha(24),
          foregroundColor: AppTheme.primaryColor,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: locked ? Colors.grey : null,
          ),
        ),
        trailing: locked
            ? const Icon(Icons.lock, color: Colors.grey)
            : completed
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.chevron_right),
        onTap: locked ? null : onTap,
      ),
    );
  }
}
