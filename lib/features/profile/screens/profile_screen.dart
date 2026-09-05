import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/locale/locale_notifier.dart';
import '../../auth/auth_notifier.dart';
import '../../dashboard/dashboard_notifier.dart';
import '../profile_labels.dart';
import '../profile_notifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileNotifier>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileNotifier>().profile;
    final currentUser = context.watch<AuthNotifier>().currentUser;
    final l10n = AppLocalizations.of(context)!;
    final displayEmail = (profile?.email ?? currentUser?.email)?.trim() ?? '';
    final displayName = _displayName(
      profile?.fullName,
      currentUser?.name,
      displayEmail,
      l10n,
    );
    final displayAge = _ageFromDateOfBirth(profile?.dateOfBirth);
    // Real figures, or nothing. These three were hardcoded to 1, 0% and 0
    // regardless of what the patient had actually done.
    final dashboard = context.watch<DashboardNotifier>().data;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/dashboard'),
            ),
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF00897B),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00897B), Color(0xFF004D40)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00897B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      displayName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      // The city sat here, under an email address standing in
                      // for the patient's name. The name belongs on the line
                      // above; the city is a profile detail like any other
                      // and is listed with the rest below.
                      displayEmail,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatCard(
                        label: l10n.weekLabel,
                        value: dashboard == null
                            ? '--'
                            : '${dashboard.currentWeek}',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: l10n.adherence,
                        value: dashboard == null
                            ? '--'
                            : '${dashboard.adherencePercentage.toStringAsFixed(0)}%',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: l10n.exercises,
                        value: dashboard == null
                            ? '--'
                            : '${dashboard.exercisesCompletedThisWeek}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Profile details
                  //
                  // Every answer the patient gives during setup is shown
                  // back here. The screen used to render six of them and
                  // silently drop the rest, so most of what was asked for
                  // after signing up appeared nowhere in the app.
                  _SectionTitle(l10n.profileDetails),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.cake_outlined,
                        label: l10n.age,
                        value: displayAge?.toString() ?? l10n.notProvided,
                      ),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: l10n.gender,
                        value: _orNotProvided(
                          profile?.gender == null
                              ? null
                              : genderLabel(profile!.gender!, l10n),
                          l10n,
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.phone_outlined,
                        label: l10n.phone,
                        value: _orNotProvided(profile?.phone, l10n),
                      ),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: l10n.email,
                        value: _orNotProvided(profile?.email, l10n),
                      ),
                      _InfoRow(
                        icon: Icons.work_outline,
                        label: l10n.occupation,
                        value: _orNotProvided(profile?.occupation, l10n),
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: l10n.city,
                        value: _orNotProvided(profile?.city, l10n),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _SectionTitle(l10n.healthInfo),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.medical_information_outlined,
                        label: l10n.incontinenceType,
                        value: _orNotProvided(
                          profile?.incontinenceType == null
                              ? null
                              : incontinenceLabel(
                                  profile!.incontinenceType,
                                  l10n,
                                ),
                          l10n,
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.timer_outlined,
                        label: l10n.symptomDuration,
                        value: profile == null
                            ? l10n.notProvided
                            : '${profile.symptomDurationMonths} ${l10n.months}',
                      ),
                      _InfoRow(
                        icon: Icons.local_hospital_outlined,
                        label: l10n.soughtTreatment,
                        value: _yesNo(profile?.hasSoughtTreatment, l10n),
                      ),
                      _InfoRow(
                        icon: Icons.bloodtype_outlined,
                        label: l10n.diabetes,
                        value: _yesNo(profile?.hasDiabetes, l10n),
                      ),
                      _InfoRow(
                        icon: Icons.monitor_heart_outlined,
                        label: l10n.hypertension,
                        value: _yesNo(profile?.hasHypertension, l10n),
                      ),
                      _InfoRow(
                        icon: Icons.height_outlined,
                        label: l10n.heightCm,
                        value: _orNotProvided(
                          _formatMeasurement(profile?.heightCm),
                          l10n,
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.monitor_weight_outlined,
                        label: l10n.weightKg,
                        value: _orNotProvided(
                          _formatMeasurement(profile?.weightKg),
                          l10n,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _SectionTitle(l10n.personalHistory),
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.favorite_outline,
                        label: l10n.maritalStatus,
                        value: _orNotProvided(
                          profile?.maritalStatus == null
                              ? null
                              : maritalLabel(profile!.maritalStatus!, l10n),
                          l10n,
                        ),
                      ),
                      _InfoRow(
                        icon: Icons.child_care_outlined,
                        label: l10n.children,
                        value: _yesNo(profile?.hasChildren, l10n),
                      ),
                      // The three rows below only mean anything for a patient
                      // who has children, and setup does not collect them
                      // otherwise.
                      if (profile?.hasChildren == true) ...[
                        _InfoRow(
                          icon: Icons.pregnant_woman_outlined,
                          label: l10n.deliveryTypeLabel,
                          value: _orNotProvided(
                            profile?.deliveryType == null
                                ? null
                                : deliveryLabel(profile!.deliveryType!, l10n),
                            l10n,
                          ),
                        ),
                        _InfoRow(
                          icon: Icons.escalator_warning_outlined,
                          label: l10n.childrenAgesLabel,
                          value: _orNotProvided(profile?.childrenAges, l10n),
                        ),
                        if (profile?.childbirthPainLevel != null)
                          _InfoRow(
                            icon: Icons.healing_outlined,
                            label: l10n.childbirthPain,
                            value: '${profile!.childbirthPainLevel} / 10',
                          ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Language
                  Text(
                    l10n.language,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A2E2B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _LanguagePicker(),
                  const SizedBox(height: 24),

                  // Edit button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/profile-setup'),
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(l10n.editProfile),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00897B),
                        side: const BorderSide(color: Color(0xFF00897B)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final auth = context.read<AuthNotifier>();
                        await auth.signOut();
                        if (!context.mounted) return;
                        context.go('/login');
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logOut),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The patient's name for the header.
  ///
  /// AuthNotifier falls back to the email address when the profile row has no
  /// full name, so taking it unconditionally printed the address twice: once
  /// as the name and again as the subtitle beneath it.
  String _displayName(
    String? profileName,
    String? sessionName,
    String email,
    AppLocalizations l10n,
  ) {
    for (final candidate in [profileName, sessionName]) {
      final name = candidate?.trim();
      if (name != null && name.isNotEmpty && name != email) return name;
    }
    return l10n.user;
  }

  int? _ageFromDateOfBirth(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }
}

/// Shows a value, or "Not provided" when the patient left it blank.
///
/// Blank and absent are the same thing to a reader, so an empty string is
/// treated as missing rather than rendered as an empty row.
String _orNotProvided(String? value, AppLocalizations l10n) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? l10n.notProvided : trimmed;
}

String _yesNo(bool? value, AppLocalizations l10n) => switch (value) {
  true => l10n.yes,
  false => l10n.no,
  null => l10n.notProvided,
};

/// Trims a trailing ".0" so a height entered as 165 does not read "165.0".
String? _formatMeasurement(double? value) {
  if (value == null) return null;
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A2E2B),
        ),
      ),
    );
  }
}

/// Lets the patient choose the app language.
///
/// The Kannada translation shipped complete and unreachable: MaterialApp set
/// no locale, so it appeared only if the whole device was in Kannada.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = context.watch<LocaleNotifier>();
    final current = notifier.locale?.languageCode;

    return RadioGroup<String?>(
      groupValue: current,
      onChanged: (value) =>
          notifier.setLocale(value == null ? null : Locale(value)),
      child: _InfoCard(
        children: [
          for (final option in <(String?, String)>[
            (null, l10n.languageSystem),
            ('en', l10n.languageEnglish),
            ('kn', l10n.languageKannada),
          ])
            RadioListTile<String?>(
              value: option.$1,
              activeColor: const Color(0xFF00897B),
              contentPadding: EdgeInsets.zero,
              title: Text(option.$2, style: GoogleFonts.poppins(fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00897B).withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00897B),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00897B).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF00897B)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A2E2B),
            ),
          ),
        ],
      ),
    );
  }
}
