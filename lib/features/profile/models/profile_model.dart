class ProfileModel {
  const ProfileModel({
    required this.userId,
    required this.age,
    required this.city,
    required this.occupation,
    required this.incontinenceType,
    required this.symptomDurationMonths,
    required this.hasSoughtTreatment,
    this.fullName,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.profileCompletedAt,
  });

  final String userId;
  final int age;
  final String city;
  final String occupation;
  final String incontinenceType;
  final int symptomDurationMonths;
  final bool hasSoughtTreatment;
  final String? fullName;
  final String? phone;
  final String? email;
  final DateTime? dateOfBirth;
  final DateTime? profileCompletedAt;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'age': age,
      'city': city,
      'occupation': occupation,
      'incontinenceType': incontinenceType,
      'symptomDurationMonths': symptomDurationMonths,
      'hasSoughtTreatment': hasSoughtTreatment,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profileCompletedAt': profileCompletedAt?.toIso8601String(),
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: (json['userId'] ?? json['id']) as String,
      age: json['age'] as int? ?? 0,
      city: json['city'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      incontinenceType:
          (json['incontinenceType'] ?? json['incontinence_type']) as String? ??
          '',
      symptomDurationMonths:
          (json['symptomDurationMonths'] ?? json['symptom_duration_months'])
              as int? ??
          0,
      hasSoughtTreatment:
          (json['hasSoughtTreatment'] ?? json['has_sought_treatment'])
              as bool? ??
          false,
      fullName: (json['fullName'] ?? json['full_name']) as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
      profileCompletedAt: _parseDate(
        json['profileCompletedAt'] ?? json['profile_completed_at'],
      ),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
