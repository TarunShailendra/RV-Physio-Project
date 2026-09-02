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

  /// Stored values stay English so the database keeps one vocabulary; only
  /// the labels are translated. Mirrors _incontinenceTypeKeys above.
  static const List<String> _maritalStatuses = [
    'Single',
    'Married',
    'Separated',
    'Divorced',
    'Widowed',
  ];
  static const List<String> _deliveryTypes = [
    'Vaginal delivery',
    'Caesarean section',
    'Assisted delivery',
    'Other',
  ];
  static const List<String> _genders = [
    'Female',
    'Male',
    'Non-binary',
    'Prefer not to say',
  ];

  String _maritalLabel(String value, AppLocalizations l10n) => switch (value) {
    'Single' => l10n.maritalSingle,
    'Married' => l10n.maritalMarried,
    'Separated' => l10n.maritalSeparated,
    'Divorced' => l10n.maritalDivorced,
    _ => l10n.maritalWidowed,
  };

  String _deliveryLabel(String value, AppLocalizations l10n) => switch (value) {
    'Vaginal delivery' => l10n.deliveryVaginal,
    'Caesarean section' => l10n.deliveryCaesarean,
    'Assisted delivery' => l10n.deliveryAssisted,
    _ => l10n.deliveryOther,
  };

  String _genderLabel(String value, AppLocalizations l10n) => switch (value) {
    'Female' => l10n.female,
    'Male' => l10n.male,
    'Non-binary' => l10n.genderNonBinary,
    _ => l10n.genderPreferNotToSay,
  };

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
  String? _gender;

  /// True when the screen opened onto an existing profile, i.e. the patient
  /// came from Edit Profile rather than from signup.
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Without this the form opens blank and saveProfile upserts the full
    // column set, so editing one field nulled out everything else.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExisting());
  }

  Future<void> _loadExisting() async {
    final notifier = context.read<ProfileNotifier>();
    await notifier.loadProfile();
    if (!mounted) return;
    final p = notifier.profile;
    if (p == null) return;

    setState(() {
      _isEditing = true;
      _cityController.text = p.city;
      _occupationController.text = p.occupation;
      _symptomDurationController.text = p.symptomDurationMonths.toString();
      _selectedIncontinenceTypeKey = _keyForIncontinenceType(p.incontinenceType);
      _hasSoughtTreatment = p.hasSoughtTreatment;
      _maritalStatus = p.maritalStatus;
      _hasChildren = p.hasChildren;
      _deliveryType = p.deliveryType;
      _childrenAgesController.text = p.childrenAges ?? '';
      _childbirthPainLevel = (p.childbirthPainLevel ?? 0).clamp(0, 10).toDouble();
      _heightController.text = p.heightCm?.toString() ?? '';
      _weightController.text = p.weightKg?.toString() ?? '';
      _hasDiabetes = p.hasDiabetes;
      _hasHypertension = p.hasHypertension;
      _gender = p.gender;
    });
  }

  /// Inverse of [_getEnglishIncontinenceType]. Returns null for anything the
  /// dropdown does not offer, so it cannot be handed a value it has no item
  /// for.
  String? _keyForIncontinenceType(String stored) {
    final key = stored.trim().toLowerCase();
    return _incontinenceTypeKeys.contains(key) ? key : null;
  }

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
          onPressed: () => context.go(_isEditing ? '/profile' : '/login'),
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
                      l10n.profileSetup,
                      style: Theme.of(context).textTheme.titleLarge,
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
                      initialValue: _selectedIncontinenceTypeKey,
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
                      initialValue: _maritalStatus,
                      decoration: InputDecoration(
                        labelText: l10n.maritalStatus,
                        border: const OutlineInputBorder(),
                      ),
                      items: _maritalStatuses
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_maritalLabel(value, l10n)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _maritalStatus = value),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: _hasChildren ?? false,
                      title: Text(l10n.haveChildren),
                      onChanged: (value) =>
                          setState(() => _hasChildren = value),
                    ),
                    if (_hasChildren == true) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _deliveryType,
                        decoration: InputDecoration(
                          labelText: l10n.deliveryTypeLabel,
                          border: const OutlineInputBorder(),
                        ),
                        items: _deliveryTypes
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(_deliveryLabel(value, l10n)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _deliveryType = value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _childrenAgesController,
                        decoration: InputDecoration(
                          labelText: l10n.childrenAgesLabel,
                          hintText: l10n.childrenAgesHint,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      if (_deliveryType != null &&
                          _deliveryType != 'Vaginal delivery') ...[
                        const SizedBox(height: 12),
                        Text(l10n.childbirthPainLevel(_childbirthPainLevel.round())),
                        Slider(
                          value: _childbirthPainLevel,
                          min: 0,
                          max: 10,
                          divisions: 10,
                          onChanged: (value) =>
                              setState(() => _childbirthPainLevel = value),
                        ),
                      ],
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.heightCmOptional,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n.weightKgOptional,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _hasDiabetes,
                      title: Text(l10n.haveDiabetes),
                      onChanged: (value) =>
                          setState(() => _hasDiabetes = value),
                    ),
                    SwitchListTile(
                      value: _hasHypertension,
                      title: Text(l10n.haveHypertension),
                      onChanged: (value) =>
                          setState(() => _hasHypertension = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: InputDecoration(
                        labelText: l10n.gender,
                        border: const OutlineInputBorder(),
                      ),
                      items: _genders
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_genderLabel(value, l10n)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value),
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
      childrenAges: _childrenAgesController.text.trim().isEmpty
          ? null
          : _childrenAgesController.text.trim(),
      childbirthPainLevel:
          _hasChildren == true &&
              _deliveryType != null &&
              _deliveryType != 'Vaginal delivery'
          ? _childbirthPainLevel.round()
          : null,
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      hasDiabetes: _hasDiabetes,
      hasHypertension: _hasHypertension,
      gender: _gender,
    );

    final profileNotifier = context.read<ProfileNotifier>();
    await profileNotifier.saveProfile(profile);

    if (mounted) {
      if (profileNotifier.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(profileNotifier.errorMessage!)));
        return;
      }
      // Signup continues into the assessment; an edit goes back where it
      // came from. This always went to the ICIQ.
      context.go(_isEditing ? '/profile' : '/iciq');
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
