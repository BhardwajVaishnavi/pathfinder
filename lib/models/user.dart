import 'package:equatable/equatable.dart';
import 'user_types.dart';

enum Gender {
  male,
  female,
  other,
}

extension GenderExtension on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (gender) => gender.value == value,
      orElse: () => Gender.other,
    );
  }
}

class User extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? district;
  final String? country;
  final String? pincode;
  final String? identityProofType; // Aadhaar, PAN, Passport, etc.
  final String? identityProofNumber;
  final String? identityProofImagePath;
  final EducationCategory? educationCategory;
  final String? institutionName;
  final String? academicYear;
  final String? parentContact;
  final Language? preferredLanguage;
  final String? passwordHash;
  final bool isProfileComplete;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.district,
    this.country,
    this.pincode,
    this.identityProofType,
    this.identityProofNumber,
    this.identityProofImagePath,
    this.educationCategory,
    this.institutionName,
    this.academicYear,
    this.parentContact,
    this.preferredLanguage,
    this.passwordHash,
    this.isProfileComplete = false,
    this.createdAt,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    Gender? gender,
    String? address,
    String? city,
    String? state,
    String? district,
    String? country,
    String? pincode,
    String? identityProofType,
    String? identityProofNumber,
    String? identityProofImagePath,
    EducationCategory? educationCategory,
    String? institutionName,
    String? academicYear,
    String? parentContact,
    Language? preferredLanguage,
    String? passwordHash,
    bool? isProfileComplete,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      district: district ?? this.district,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      identityProofType: identityProofType ?? this.identityProofType,
      identityProofNumber: identityProofNumber ?? this.identityProofNumber,
      identityProofImagePath: identityProofImagePath ?? this.identityProofImagePath,
      educationCategory: educationCategory ?? this.educationCategory,
      institutionName: institutionName ?? this.institutionName,
      academicYear: academicYear ?? this.academicYear,
      parentContact: parentContact ?? this.parentContact,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      passwordHash: passwordHash ?? this.passwordHash,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender?.value,
      'address': address,
      'city': city,
      'state': state,
      'district': district,
      'country': country,
      'pincode': pincode,
      'identity_proof_type': identityProofType,
      'identity_proof_number': identityProofNumber,
      'identity_proof_image_path': identityProofImagePath,
      'education_category': educationCategory?.toString().split('.').last,
      'institution_name': institutionName,
      'academic_year': academicYear,
      'parent_contact': parentContact,
      'preferred_language': preferredLanguage?.value,
      'password_hash': passwordHash,
      'is_profile_complete': isProfileComplete,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    try {
      return User(
        id: map['id'] ?? 0,
        name: map['name'] ?? map['full_name'] ?? 'Unknown User',
        email: map['email'],
        phone: map['phone'],
        dateOfBirth: map['date_of_birth'] != null ? DateTime.parse(map['date_of_birth'].toString()) : null,
        gender: map['gender'] != null ? GenderExtension.fromString(map['gender'].toString()) : null,
        address: map['address'],
        city: map['city'],
        state: map['state'],
        district: map['district'],
        country: map['country'],
        pincode: map['pincode'],
        identityProofType: map['identity_proof_type'],
        identityProofNumber: map['identity_proof_number'],
        identityProofImagePath: map['identity_proof_image_path'],
        educationCategory: map['education_category'] != null ? EducationCategoryExtension.fromString(map['education_category'].toString()) : null,
        institutionName: map['institution_name'],
        academicYear: map['academic_year'],
        parentContact: map['parent_contact'],
        preferredLanguage: map['preferred_language'] != null ? LanguageExtension.fromString(map['preferred_language'].toString()) : null,
        passwordHash: map['password_hash'],
        isProfileComplete: map['is_profile_complete'] ?? false,
        createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'].toString()) : null,
      );
    } catch (e) {
      print('❌ Error in User.fromMap: $e');
      print('   Map data: $map');
      rethrow;
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    dateOfBirth,
    gender,
    address,
    city,
    state,
    district,
    country,
    pincode,
    identityProofType,
    identityProofNumber,
    identityProofImagePath,
    educationCategory,
    institutionName,
    academicYear,
    parentContact,
    preferredLanguage,
    passwordHash,
    isProfileComplete,
    createdAt
  ];
}
