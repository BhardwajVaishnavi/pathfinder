import 'package:equatable/equatable.dart';
import 'user_types.dart';
import 'user.dart';

class Student extends Equatable {
  final int id;
  final String fullName;
  final DateTime dateOfBirth;
  final Gender gender;
  final String email;
  final String phone;
  final EducationCategory educationCategory;
  final String currentInstitution;
  final String academicYear;
  final String parentGuardianContact;
  final Language preferredLanguage;
  final String address;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final String? identityProofType;
  final String? identityProofNumber;
  final String? identityProofImagePath;
  final bool isProfileComplete;
  final bool isVerified;
  final int? assignedTestSet; // Which test set (1-4) is assigned to this student
  final DateTime? testAssignedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Student({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.email,
    required this.phone,
    required this.educationCategory,
    required this.currentInstitution,
    required this.academicYear,
    required this.parentGuardianContact,
    required this.preferredLanguage,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    this.identityProofType,
    this.identityProofNumber,
    this.identityProofImagePath,
    this.isProfileComplete = false,
    this.isVerified = false,
    this.assignedTestSet,
    this.testAssignedAt,
    required this.createdAt,
    this.updatedAt,
  });

  Student copyWith({
    int? id,
    String? fullName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? email,
    String? phone,
    EducationCategory? educationCategory,
    String? currentInstitution,
    String? academicYear,
    String? parentGuardianContact,
    Language? preferredLanguage,
    String? address,
    String? state,
    String? district,
    String? city,
    String? pincode,
    String? identityProofType,
    String? identityProofNumber,
    String? identityProofImagePath,
    bool? isProfileComplete,
    bool? isVerified,
    int? assignedTestSet,
    DateTime? testAssignedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      educationCategory: educationCategory ?? this.educationCategory,
      currentInstitution: currentInstitution ?? this.currentInstitution,
      academicYear: academicYear ?? this.academicYear,
      parentGuardianContact: parentGuardianContact ?? this.parentGuardianContact,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      address: address ?? this.address,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      identityProofType: identityProofType ?? this.identityProofType,
      identityProofNumber: identityProofNumber ?? this.identityProofNumber,
      identityProofImagePath: identityProofImagePath ?? this.identityProofImagePath,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isVerified: isVerified ?? this.isVerified,
      assignedTestSet: assignedTestSet ?? this.assignedTestSet,
      testAssignedAt: testAssignedAt ?? this.testAssignedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender.value,
      'email': email,
      'phone': phone,
      'education_category': educationCategory.value,
      'current_institution': currentInstitution,
      'academic_year': academicYear,
      'parent_guardian_contact': parentGuardianContact,
      'preferred_language': preferredLanguage.value,
      'address': address,
      'state': state,
      'district': district,
      'city': city,
      'pincode': pincode,
      'identity_proof_type': identityProofType,
      'identity_proof_number': identityProofNumber,
      'identity_proof_image_path': identityProofImagePath,
      'is_profile_complete': isProfileComplete,
      'is_verified': isVerified,
      'assigned_test_set': assignedTestSet,
      'test_assigned_at': testAssignedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      fullName: map['full_name'],
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      gender: GenderExtension.fromString(map['gender']),
      email: map['email'],
      phone: map['phone'],
      educationCategory: EducationCategoryExtension.fromString(map['education_category']),
      currentInstitution: map['current_institution'],
      academicYear: map['academic_year'],
      parentGuardianContact: map['parent_guardian_contact'],
      preferredLanguage: LanguageExtension.fromString(map['preferred_language']),
      address: map['address'],
      state: map['state'],
      district: map['district'],
      city: map['city'],
      pincode: map['pincode'],
      identityProofType: map['identity_proof_type'],
      identityProofNumber: map['identity_proof_number'],
      identityProofImagePath: map['identity_proof_image_path'],
      isProfileComplete: map['is_profile_complete'] ?? false,
      isVerified: map['is_verified'] ?? false,
      assignedTestSet: map['assigned_test_set'],
      testAssignedAt: map['test_assigned_at'] != null ? DateTime.parse(map['test_assigned_at']) : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    dateOfBirth,
    gender,
    email,
    phone,
    educationCategory,
    currentInstitution,
    academicYear,
    parentGuardianContact,
    preferredLanguage,
    address,
    state,
    district,
    city,
    pincode,
    identityProofType,
    identityProofNumber,
    identityProofImagePath,
    isProfileComplete,
    isVerified,
    assignedTestSet,
    testAssignedAt,
    createdAt,
    updatedAt,
  ];
}
