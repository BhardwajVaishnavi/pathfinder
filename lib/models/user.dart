import 'package:equatable/equatable.dart';

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
  final String? country;
  final String? pincode;
  final String? identityProofType; // Aadhaar, PAN, Passport, etc.
  final String? identityProofNumber;
  final String? identityProofImagePath;
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
    this.country,
    this.pincode,
    this.identityProofType,
    this.identityProofNumber,
    this.identityProofImagePath,
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
    String? country,
    String? pincode,
    String? identityProofType,
    String? identityProofNumber,
    String? identityProofImagePath,
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
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      identityProofType: identityProofType ?? this.identityProofType,
      identityProofNumber: identityProofNumber ?? this.identityProofNumber,
      identityProofImagePath: identityProofImagePath ?? this.identityProofImagePath,
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
      'country': country,
      'pincode': pincode,
      'identity_proof_type': identityProofType,
      'identity_proof_number': identityProofNumber,
      'identity_proof_image_path': identityProofImagePath,
      'is_profile_complete': isProfileComplete,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      dateOfBirth: map['date_of_birth'] != null ? DateTime.parse(map['date_of_birth']) : null,
      gender: map['gender'] != null ? GenderExtension.fromString(map['gender']) : null,
      address: map['address'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      pincode: map['pincode'],
      identityProofType: map['identity_proof_type'],
      identityProofNumber: map['identity_proof_number'],
      identityProofImagePath: map['identity_proof_image_path'],
      isProfileComplete: map['is_profile_complete'] ?? false,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
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
    country,
    pincode,
    identityProofType,
    identityProofNumber,
    identityProofImagePath,
    isProfileComplete,
    createdAt
  ];
}
