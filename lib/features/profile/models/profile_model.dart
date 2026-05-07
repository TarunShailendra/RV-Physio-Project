class ProfileModel {
  const ProfileModel({
    required this.userId,
    required this.age,
    required this.city,
    required this.occupation,
    required this.incontinenceType,
    required this.symptomDurationMonths,
    required this.hasSoughtTreatment,
  });

  final String userId;
  final int age;
  final String city;
  final String occupation;
  final String incontinenceType;
  final int symptomDurationMonths;
  final bool hasSoughtTreatment;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'age': age,
      'city': city,
      'occupation': occupation,
      'incontinenceType': incontinenceType,
      'symptomDurationMonths': symptomDurationMonths,
      'hasSoughtTreatment': hasSoughtTreatment,
    };
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String,
      age: json['age'] as int,
      city: json['city'] as String,
      occupation: json['occupation'] as String,
      incontinenceType: json['incontinenceType'] as String,
      symptomDurationMonths: json['symptomDurationMonths'] as int,
      hasSoughtTreatment: json['hasSoughtTreatment'] as bool,
    );
  }
}
