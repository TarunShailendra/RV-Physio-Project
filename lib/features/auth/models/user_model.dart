class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    this.dob,
    this.dateOfBirth,
    this.isProfileComplete = false,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String? dob;
  final DateTime? dateOfBirth;
  final bool isProfileComplete;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? dob,
    DateTime? dateOfBirth,
    bool? isProfileComplete,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      dob: dob ?? this.dob,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'dob': dob,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'isProfileComplete': isProfileComplete,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      age: json['age'] as int,
      dob: json['dob'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.tryParse(json['dateOfBirth'] as String),
      isProfileComplete: json['isProfileComplete'] as bool? ?? false,
    );
  }
}
