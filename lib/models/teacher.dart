import 'package:equatable/equatable.dart';
import 'user_types.dart';

class Teacher extends Equatable {
  final int id;
  final String fullName;
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
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Teacher({
    required this.id,
    required this.fullName,
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
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  Teacher copyWith({
    int? id,
    String? fullName,
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
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
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
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
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
      'is_verified': isVerified,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      fullName: map['full_name'],
      employeeId: map['employee_id'],
      institutionName: map['institution_name'],
      designation: map['designation'],
      subjectExpertise: map['subject_expertise'].toString().split(','),
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
      isVerified: map['is_verified'] ?? false,
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
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
    isVerified,
    isActive,
    createdAt,
    updatedAt,
  ];
}
