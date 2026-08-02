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
  final _childrenAgesController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedIncontinenceTypeKey;
  bool _hasSoughtTreatment = false;
  String? _maritalStatus;
  bool? _hasChildren;
  String? _deliveryType;
  double _childbirthPainLevel = 0;
  bool _hasDiabetes = false;
  bool _hasHypertension = false;

  @override
  void dispose() {
    _cityController.dispose();
    _occupationController.dispose();
    _symptomDurationController.dispose();
    _childrenAgesController.dispose();
    _heightController.dispose();
    _weightController.dispose();
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _maritalStatus,
                      decoration: const InputDecoration(labelText: 'Marital status', border: OutlineInputBorder()),
                      items: const ['Single', 'Married', 'Separated', 'Divorced', 'Widowed']
                          .map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                      onChanged: (value) => setState(() => _maritalStatus = value),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _hasChildren ?? false,
                      title: const Text('Do you have children?'),
                      onChanged: (value) => setState(() => _hasChildren = value),
                    ),
                    if (_hasChildren == true) ...[
                      DropdownButtonFormField<String>(
                        value: _deliveryType,
                        decoration: const InputDecoration(labelText: 'Type of delivery', border: OutlineInputBorder()),
                        items: const ['Vaginal delivery', 'Caesarean section', 'Assisted delivery', 'Other']
                            .map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                        onChanged: (value) => setState(() => _deliveryType = value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(controller: _childrenAgesController, decoration: const InputDecoration(labelText: 'Age(s) of child / children', hintText: 'Example: 3, 7', border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      Text('Childbirth-related pain level: ${_childbirthPainLevel.round()} / 10'),
                      Slider(value: _childbirthPainLevel, min: 0, max: 10, divisions: 10, onChanged: (value) => setState(() => _childbirthPainLevel = value)),
                    ],
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: TextFormField(controller: _heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height (cm) — optional', border: OutlineInputBorder()))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight (kg) — optional', border: OutlineInputBorder()))),
                    ]),
                    const SizedBox(height: 12),
                    SwitchListTile(value: _hasDiabetes, title: const Text('Do you have diabetes?'), onChanged: (value) => setState(() => _hasDiabetes = value)),
                    SwitchListTile(value: _hasHypertension, title: const Text('Do you have hypertension?'), onChanged: (value) => setState(() => _hasHypertension = value)),
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
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please sign in again.'),
        ),
      );
      context.go('/login');
      return;
    }
    final parsedDob = _parseDob(currentUser.dob) ?? currentUser.dateOfBirth;

    // Map selected key back to English value for storage
    final incontinenceTypeValue = _getEnglishIncontinenceType(
      _selectedIncontinenceTypeKey!,
    );

    final profile = ProfileModel(
      userId: currentUser.id,
      age: currentUser.age,
      city: _cityController.text.trim(),
      occupation: _occupationController.text.trim(),
      incontinenceType: incontinenceTypeValue,
      symptomDurationMonths: int.parse(_symptomDurationController.text.trim()),
      hasSoughtTreatment: _hasSoughtTreatment,
      fullName: currentUser.name,
      phone: currentUser.phone,
      email: currentUser.email,
      dateOfBirth: parsedDob,
      maritalStatus: _maritalStatus,
      hasChildren: _hasChildren,
      deliveryType: _deliveryType,
      childrenAges: _childrenAgesController.text.trim().isEmpty ? null : _childrenAgesController.text.trim(),
      childbirthPainLevel: _hasChildren == true ? _childbirthPainLevel.round() : null,
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      hasDiabetes: _hasDiabetes,
      hasHypertension: _hasHypertension,
    );

    final profileNotifier = context.read<ProfileNotifier>();
    await profileNotifier.saveProfile(profile);

    if (mounted) {
      if (profileNotifier.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(profileNotifier.errorMessage!)),
        );
        return;
      }
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
