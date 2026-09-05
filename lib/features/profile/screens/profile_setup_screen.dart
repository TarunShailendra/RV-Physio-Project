import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/auth_notifier.dart';
import '../models/profile_model.dart';
import '../profile_labels.dart';
import '../profile_notifier.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _occupationController = TextEditingController();
  final _symptomDurationController = TextEditingController();
  final _childrenAgesController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _dateOfBirth;
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
      // A row alone does not mean the patient has filled this in: signup
      // creates a stub holding only name, phone and email. Treat it as an
      // edit only once the form has actually been completed, otherwise a new
      // patient is sent to their profile instead of on to the assessment.
      _isEditing = p.city.trim().isNotEmpty;
      _phoneController.text = p.phone ?? '';
      _dateOfBirth = p.dateOfBirth;
      _cityController.text = p.city;
      _occupationController.text = p.occupation;
      _symptomDurationController.text = p.symptomDurationMonths.toString();
      _selectedIncontinenceTypeKey = _keyForIncontinenceType(
        p.incontinenceType,
      );
      _hasSoughtTreatment = p.hasSoughtTreatment;
      _maritalStatus = p.maritalStatus;
      _hasChildren = p.hasChildren;
      _deliveryType = p.deliveryType;
      _childrenAgesController.text = p.childrenAges ?? '';
      _childbirthPainLevel = (p.childbirthPainLevel ?? 0)
          .clamp(0, 10)
          .toDouble();
      _heightController.text = p.heightCm?.toString() ?? '';
      _weightController.text = p.weightKg?.toString() ?? '';
      _hasDiabetes = p.hasDiabetes;
      _hasHypertension = p.hasHypertension;
      _gender = p.gender;
    });
  }

  String _formatDob(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/'
      '${value.year}';

  Future<void> _pickDateOfBirth(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(now.year - 120),
      // A date of birth cannot be in the future, so the picker will not offer
      // one; the signup form has to say so in words because its three
      // dropdowns can be set to anything.
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    setState(() => _dateOfBirth = picked);
    field.didChange(picked);
  }

  /// Inverse of [_getEnglishIncontinenceType]. Returns null for anything the
  /// dropdown does not offer, so it cannot be handed a value it has no item
  /// for.
  String? _keyForIncontinenceType(String stored) {
    final key = stored.trim().toLowerCase();
    return incontinenceTypeKeys.contains(key) ? key : null;
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
                    // Signup asks for these two, but nothing asked for
                    // them again, so a patient whose row had lost them had no
                    // way to put them back and their profile showed no phone
                    // number and no age.
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: InputDecoration(
                        labelText: l10n.phone,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) return l10n.enterPhoneNumber;
                        if (phone.length < 10) return l10n.enterValidPhone;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FormField<DateTime>(
                      initialValue: _dateOfBirth,
                      validator: (_) =>
                          _dateOfBirth == null ? l10n.selectDateOfBirth : null,
                      builder: (field) => InkWell(
                        onTap: () => _pickDateOfBirth(field),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.dateOfBirth,
                            border: const OutlineInputBorder(),
                            errorText: field.errorText,
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _dateOfBirth == null
                                ? l10n.notProvided
                                : _formatDob(_dateOfBirth!),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
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
                      items: incontinenceTypeKeys.map((key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(incontinenceLabel(key, l10n)),
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
                      items: maritalStatuses
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(maritalLabel(value, l10n)),
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
                        items: deliveryTypes
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(deliveryLabel(value, l10n)),
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
                        Text(
                          l10n.childbirthPainLevel(
                            _childbirthPainLevel.round(),
                          ),
                        ),
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
                      items: genders
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(genderLabel(value, l10n)),
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
    // The form owns these now. Falling back to the session user kept a stale
    // null in play whenever the profile row had lost its date of birth.
    final parsedDob = _dateOfBirth ?? currentUser.dateOfBirth;
    final phone = _phoneController.text.trim();

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
      phone: phone.isEmpty ? currentUser.phone : phone,
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

    // Refresh before navigating, so the guard sees the completed profile.
    // Uses the notifier captured above rather than reading from context,
    // which is no longer safe after the await.
    await authNotifier.refreshProfile();

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
