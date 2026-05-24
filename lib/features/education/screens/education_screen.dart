import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_bottom_navigation.dart';
import '../../../l10n/app_localizations.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  static const List<_EducationArticle> _articles = [
    _EducationArticle(
      titleKey: 'whatIsUrinaryIncontinence',
      subtitleKey: 'understandingBasics',
      icon: Icons.info_outline,
    ),
    _EducationArticle(
      titleKey: 'typesOfIncontinence',
      subtitleKey: 'stressUrgeMixed',
      icon: Icons.category_outlined,
    ),
    _EducationArticle(
      titleKey: 'pelvicFloorMuscles',
      subtitleKey: 'anatomyFunction',
      icon: Icons.accessibility_new,
    ),
    _EducationArticle(
      titleKey: 'howPfmtWorks',
      subtitleKey: 'scienceBehindExercises',
      icon: Icons.fitness_center,
    ),
    _EducationArticle(
      titleKey: 'lifestyleChanges',
      subtitleKey: 'dietFluidHabits',
      icon: Icons.local_drink_outlined,
    ),
    _EducationArticle(
      titleKey: 'whenToSeeDoctor',
      subtitleKey: 'redFlagsReferrals',
      icon: Icons.medical_services_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text(l10n.education),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: const AppBottomNavigation(),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _articles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final article = _articles[index];

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      AppTheme.primaryColor.withAlpha(20), // 0.12 opacity
                  foregroundColor: AppTheme.primaryColor,
                  child: Icon(article.icon),
                ),
                title: Text(_getLocalizedTitle(article.titleKey, l10n)),
                subtitle: Text(_getLocalizedSubtitle(article.subtitleKey, l10n)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _EducationDetailScreen(
                        titleKey: article.titleKey,
                        subtitleKey: article.subtitleKey,
                        icon: article.icon,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _getLocalizedTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'whatIsUrinaryIncontinence':
        return l10n.whatIsUrinaryIncontinence;
      case 'typesOfIncontinence':
        return l10n.typesOfIncontinence;
      case 'pelvicFloorMuscles':
        return l10n.pelvicFloorMuscles;
      case 'howPfmtWorks':
        return l10n.howPfmtWorks;
      case 'lifestyleChanges':
        return l10n.lifestyleChanges;
      case 'whenToSeeDoctor':
        return l10n.whenToSeeDoctor;
      default:
        return '';
    }
  }

  String _getLocalizedSubtitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'understandingBasics':
        return l10n.understandingBasics;
      case 'stressUrgeMixed':
        return l10n.stressUrgeMixed;
      case 'anatomyFunction':
        return l10n.anatomyFunction;
      case 'scienceBehindExercises':
        return l10n.scienceBehindExercises;
      case 'dietFluidHabits':
        return l10n.dietFluidHabits;
      case 'redFlagsReferrals':
        return l10n.redFlagsReferrals;
      default:
        return '';
    }
  }
}

class _EducationDetailScreen extends StatelessWidget {
  const _EducationDetailScreen({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
  });

  final String titleKey;
  final String subtitleKey;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = _getLocalizedTitle(titleKey, l10n);
    final subtitle = _getLocalizedSubtitle(subtitleKey, l10n);
    final detailContent = _getLocalizedDetailContent(titleKey, l10n);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
            ),
            const SizedBox(height: 24),
            Text(
              detailContent,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedTitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'whatIsUrinaryIncontinence':
        return l10n.whatIsUrinaryIncontinence;
      case 'typesOfIncontinence':
        return l10n.typesOfIncontinence;
      case 'pelvicFloorMuscles':
        return l10n.pelvicFloorMuscles;
      case 'howPfmtWorks':
        return l10n.howPfmtWorks;
      case 'lifestyleChanges':
        return l10n.lifestyleChanges;
      case 'whenToSeeDoctor':
        return l10n.whenToSeeDoctor;
      default:
        return '';
    }
  }

  String _getLocalizedSubtitle(String key, AppLocalizations l10n) {
    switch (key) {
      case 'understandingBasics':
        return l10n.understandingBasics;
      case 'stressUrgeMixed':
        return l10n.stressUrgeMixed;
      case 'anatomyFunction':
        return l10n.anatomyFunction;
      case 'scienceBehindExercises':
        return l10n.scienceBehindExercises;
      case 'dietFluidHabits':
        return l10n.dietFluidHabits;
      case 'redFlagsReferrals':
        return l10n.redFlagsReferrals;
      default:
        return '';
    }
  }

  String _getLocalizedDetailContent(String key, AppLocalizations l10n) {
    switch (key) {
      case 'whatIsUrinaryIncontinence':
        return l10n.whatIsUrinaryIncontinenceDetail;
      case 'typesOfIncontinence':
        return l10n.typesOfIncontinenceDetail;
      case 'pelvicFloorMuscles':
        return l10n.pelvicFloorMusclesDetail;
      case 'howPfmtWorks':
        return l10n.howPfmtWorksDetail;
      case 'lifestyleChanges':
        return l10n.lifestyleChangesDetail;
      case 'whenToSeeDoctor':
        return l10n.whenToSeeDoctorDetail;
      default:
        return '';
    }
  }
}

class _EducationArticle {
  const _EducationArticle({
    required this.titleKey,
    required this.subtitleKey,
    required this.icon,
  });

  final String titleKey;
  final String subtitleKey;
  final IconData icon;
}
