import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class AssessmentScreen extends StatelessWidget {
  const AssessmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
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
              onTap: () => context.go('/assessment/iciq'),
            ),
            _AssessmentTile(
              title: l10n.ipaqTitle,
              icon: Icons.directions_walk,
              onTap: () => context.go('/assessment/ipaq'),
            ),
            _AssessmentTile(
              title: l10n.iqolTitle,
              icon: Icons.favorite_outline,
              onTap: () => context.go('/assessment/iqol'),
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
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withAlpha(24),
          foregroundColor: AppTheme.primaryColor,
          child: Icon(icon),
        ),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
