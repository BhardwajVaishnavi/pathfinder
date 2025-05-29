import 'package:equatable/equatable.dart';
import 'user_types.dart';

class TeacherUser extends Equatable {
  final int id;
  final String name;
  final String employeeId;
  final String institutionName;
  final String designation;
  final List<String> subjectExpertise;
  final String email;
  final String phone;
  final int yearsOfExperience;
  final String institutionAddress;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final AdminAccessLevel accessLevel;
  final Language preferredLanguage;
  final String passwordHash;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TeacherUser({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.institutionName,
    required this.designation,
    required this.subjectExpertise,
    required this.email,
    required this.phone,
    required this.yearsOfExperience,
    required this.institutionAddress,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    required this.accessLevel,
    required this.preferredLanguage,
    required this.passwordHash,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  TeacherUser copyWith({
    int? id,
    String? name,
    String? employeeId,
    String? institutionName,
    String? designation,
    List<String>? subjectExpertise,
    String? email,
    String? phone,
    int? yearsOfExperience,
    String? institutionAddress,
    String? state,
    String? district,
    String? city,
    String? pincode,
    AdminAccessLevel? accessLevel,
    Language? preferredLanguage,
    String? passwordHash,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherUser(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      institutionName: institutionName ?? this.institutionName,
      designation: designation ?? this.designation,
      subjectExpertise: subjectExpertise ?? this.subjectExpertise,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      institutionAddress: institutionAddress ?? this.institutionAddress,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      accessLevel: accessLevel ?? this.accessLevel,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      passwordHash: passwordHash ?? this.passwordHash,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'employee_id': employeeId,
      'institution_name': institutionName,
      'designation': designation,
      'subject_expertise': subjectExpertise.join(','),
      'email': email,
      'phone': phone,
      'years_of_experience': yearsOfExperience,
      'institution_address': institutionAddress,
      'state': state,
      'district': district,
      'city': city,
      'pincode': pincode,
      'access_level': accessLevel.value,
      'preferred_language': preferredLanguage.value,
      'password_hash': passwordHash,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory TeacherUser.fromMap(Map<String, dynamic> map) {
    return TeacherUser(
      id: map['id'],
      name: map['name'],
      employeeId: map['employee_id'],
      institutionName: map['institution_name'],
      designation: map['designation'],
      subjectExpertise: map['subject_expertise'].split(','),
      email: map['email'],
      phone: map['phone'],
      yearsOfExperience: map['years_of_experience'],
      institutionAddress: map['institution_address'],
      state: map['state'],
      district: map['district'],
      city: map['city'],
      pincode: map['pincode'],
      accessLevel: AdminAccessLevelExtension.fromString(map['access_level']),
      preferredLanguage: LanguageExtension.fromString(map['preferred_language']),
      passwordHash: map['password_hash'],
      isVerified: map['is_verified'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    employeeId,
    institutionName,
    designation,
    subjectExpertise,
    email,
    phone,
    yearsOfExperience,
    institutionAddress,
    state,
    district,
    city,
    pincode,
    accessLevel,
    preferredLanguage,
    passwordHash,
    isVerified,
    createdAt,
    updatedAt,
  ];
}
