import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth_notifier.dart';
import '../models/profile_model.dart';
import '../profile_notifier.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const List<String> _incontinenceTypeKeys = [
    'stress',
    'urge',
    'mixed',
    'unknown',
  ];

  final _formKey = GlobalKey<FormState>();
  final _cityController = TextEditingController();
  final _occupationController = TextEditingController();
  final _symptomDurationController = TextEditingController();
  String? _selectedIncontinenceTypeKey;
  bool _hasSoughtTreatment = false;

  @override
  void dispose() {
    _cityController.dispose();
    _occupationController.dispose();
    _symptomDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileNotifier = context.watch<ProfileNotifier>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        title: Text(l10n.profileSetup),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.profileStep1,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 1 / 3,
                      minHeight: 6,
                      backgroundColor: AppTheme.primaryColor.withValues(
                        alpha: 0.12,
                      ),
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _cityController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.city,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((value?.trim() ?? '').isEmpty) {
                          return l10n.enterYourCity;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _occupationController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.occupation,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((value?.trim() ?? '').isEmpty) {
                          return l10n.enterYourOccupation;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedIncontinenceTypeKey,
                      decoration: InputDecoration(
                        labelText: l10n.incontinenceType,
                        border: const OutlineInputBorder(),
                      ),
                      items: _incontinenceTypeKeys.map((key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(_getLocalizedIncontinenceType(key, l10n)),
                        );
                      }).toList(),
                      onChanged: profileNotifier.isLoading
                          ? null
                          : (value) => setState(() {
                              _selectedIncontinenceTypeKey = value;
                            }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.selectIncontinenceType;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _symptomDurationController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: l10n.symptomDurationMonths,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final duration = int.tryParse(value?.trim() ?? '');
                        if (duration == null) {
                          return l10n.enterValidDuration;
                        }
                        if (duration < 0) {
                          return l10n.durationCannotBeNegative;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: SwitchListTile(
                        value: _hasSoughtTreatment,
                        activeThumbColor: AppTheme.primaryColor,
                        title: Text(l10n.haveYouSoughtTreatment),
                        onChanged: profileNotifier.isLoading
                            ? null
                            : (value) => setState(() {
                                _hasSoughtTreatment = value;
                              }),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: profileNotifier.isLoading
                          ? null
                          : _handleSubmit,
                      child: profileNotifier.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.continueText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getLocalizedIncontinenceType(String key, AppLocalizations l10n) {
    switch (key) {
      case 'stress':
        return l10n.stressIncontinence;
      case 'urge':
        return l10n.urgeIncontinence;
      case 'mixed':
        return l10n.mixedIncontinence;
      case 'unknown':
        return l10n.unknownIncontinence;
      default:
        return key;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authNotifier = context.read<AuthNotifier>();
    final currentUser = authNotifier.currentUser;
    final parsedDob = _parseDob(currentUser?.dob) ?? currentUser?.dateOfBirth;

    // Map selected key back to English value for storage
    final incontinenceTypeValue = _getEnglishIncontinenceType(
      _selectedIncontinenceTypeKey!,
    );

    final profile = ProfileModel(
      userId: currentUser?.id ?? 'mock_user_id',
      age: currentUser?.age ?? 0,
      city: _cityController.text.trim(),
      occupation: _occupationController.text.trim(),
      incontinenceType: incontinenceTypeValue,
      symptomDurationMonths: int.parse(_symptomDurationController.text.trim()),
      hasSoughtTreatment: _hasSoughtTreatment,
      fullName: currentUser?.name,
      phone: currentUser?.phone,
      email: currentUser?.email,
      dateOfBirth: parsedDob,
    );

    await context.read<ProfileNotifier>().saveProfile(profile);

    if (mounted) {
      context.go('/iciq');
    }
  }

  DateTime? _parseDob(String? dob) {
    if (dob != null && dob.isNotEmpty) {
      final parts = dob.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    }
    return null;
  }

  String _getEnglishIncontinenceType(String key) {
    switch (key) {
      case 'stress':
        return 'Stress';
      case 'urge':
        return 'Urge';
      case 'mixed':
        return 'Mixed';
      case 'unknown':
        return 'Unknown';
      default:
        return 'Unknown';
    }
  }
}
