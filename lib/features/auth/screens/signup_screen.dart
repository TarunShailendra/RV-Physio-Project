import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart'; // âœ… added
import '../auth_notifier.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDob;
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  bool _emailTaken = false;

  static const _months = [
    (1, 'Jan'),
    (2, 'Feb'),
    (3, 'Mar'),
    (4, 'Apr'),
    (5, 'May'),
    (6, 'Jun'),
    (7, 'Jul'),
    (8, 'Aug'),
    (9, 'Sep'),
    (10, 'Oct'),
    (11, 'Nov'),
    (12, 'Dec'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final l10n = AppLocalizations.of(context)!; // âœ…

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.signUp), // âœ…
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: authNotifier.isLoading ? null : () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.createAccount, // âœ…
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      decoration: InputDecoration(
                        labelText: l10n.name, // âœ…
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((value?.trim() ?? '').isEmpty) {
                          return l10n.enterYourName; // âœ… new key
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: l10n.email, // âœ…
                        border: const OutlineInputBorder(),
                        errorStyle: const TextStyle(fontSize: 14),
                      ),
                      onChanged: (_) {
                        if (_emailTaken) setState(() => _emailTaken = false);
                      },
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return l10n.enterYourEmail; // âœ… new key
                        }
                        if (!email.contains('@')) {
                          return l10n.enterValidEmail; // âœ… new key
                        }
                        if (_emailTaken) {
                          return 'This email is already registered';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: l10n.password, // âœ…
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) {
                          return l10n.enterPassword; // âœ… new key (or reuse)
                        }
                        if (password.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!RegExp(
                          r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]',
                        ).hasMatch(password)) {
                          return 'Password must contain at least one special character';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      decoration: InputDecoration(
                        labelText: l10n.phone, // âœ…
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty) {
                          return l10n.enterPhoneNumber; // âœ… new key
                        }
                        if (phone.length < 10) {
                          return l10n.enterValidPhone; // âœ… new key
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FormField<DateTime>(
                      validator: (_) {
                        if (_selectedDay == null ||
                            _selectedMonth == null ||
                            _selectedYear == null) {
                          return l10n.selectDateOfBirth;
                        }
                        return null;
                      },
                      builder: (field) {
                        final now = DateTime.now();
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.dateOfBirth,
                            border: const OutlineInputBorder(),
                            errorText: field.errorText,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedDay,
                                    hint: const Text('Day'),
                                    isExpanded: true,
                                    items: [
                                      for (var day = 1; day <= 31; day++)
                                        DropdownMenuItem<int>(
                                          value: day,
                                          child: Text(day.toString()),
                                        ),
                                    ],
                                    onChanged: authNotifier.isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedDay = value;
                                              _updateSelectedDob();
                                              field.didChange(_selectedDob);
                                            });
                                          },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedMonth,
                                    hint: const Text('Month'),
                                    isExpanded: true,
                                    items: [
                                      for (final month in _months)
                                        DropdownMenuItem<int>(
                                          value: month.$1,
                                          child: Text(month.$2),
                                        ),
                                    ],
                                    onChanged: authNotifier.isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedMonth = value;
                                              _updateSelectedDob();
                                              field.didChange(_selectedDob);
                                            });
                                          },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedYear,
                                    hint: const Text('Year'),
                                    isExpanded: true,
                                    items: [
                                      for (
                                        var year = now.year;
                                        year >= 1930;
                                        year--
                                      )
                                        DropdownMenuItem<int>(
                                          value: year,
                                          child: Text(year.toString()),
                                        ),
                                    ],
                                    onChanged: authNotifier.isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedYear = value;
                                              _updateSelectedDob();
                                              field.didChange(_selectedDob);
                                            });
                                          },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: authNotifier.isLoading ? null : _handleSignup,
                      child: authNotifier.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.signUp), // âœ…
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: authNotifier.isLoading
                          ? null
                          : () => context.go('/login'),
                      child: Text(l10n.backToLogin), // âœ…
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

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();

    final authNotifier = context.read<AuthNotifier>();
    await authNotifier.signup(
      _nameController.text.trim(),
      email,
      _passwordController.text,
      _phoneController.text.trim(),
      _ageFromDateOfBirth(_selectedDob!),
      dob: _selectedDob != null
          ? '${_selectedDob!.day.toString().padLeft(2, '0')}/${_selectedDob!.month.toString().padLeft(2, '0')}/${_selectedDob!.year}'
          : null,
    );

    if (mounted) {
      if (authNotifier.currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authNotifier.errorMessage ??
                  'Unable to create your account. Please try again.',
            ),
          ),
        );
        return;
      }
      context.go('/profile-setup');
    }
  }

  void _updateSelectedDob() {
    if (_selectedDay == null ||
        _selectedMonth == null ||
        _selectedYear == null) {
      _selectedDob = null;
      return;
    }

    _selectedDob = DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
  }

  int _ageFromDateOfBirth(DateTime dateOfBirth) {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
