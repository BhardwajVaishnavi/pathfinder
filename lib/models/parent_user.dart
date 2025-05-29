import 'package:equatable/equatable.dart';
import 'user_types.dart';

class ParentUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String occupation;
  final RelationshipType relationshipType;
  final String studentRegistrationId;
  final String address;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final Language preferredLanguage;
  final String passwordHash;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ParentUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.occupation,
    required this.relationshipType,
    required this.studentRegistrationId,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    required this.preferredLanguage,
    required this.passwordHash,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  ParentUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? occupation,
    RelationshipType? relationshipType,
    String? studentRegistrationId,
    String? address,
    String? state,
    String? district,
    String? city,
    String? pincode,
    Language? preferredLanguage,
    String? passwordHash,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParentUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      relationshipType: relationshipType ?? this.relationshipType,
      studentRegistrationId: studentRegistrationId ?? this.studentRegistrationId,
      address: address ?? this.address,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
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
      'email': email,
      'phone': phone,
      'occupation': occupation,
      'relationship_type': relationshipType.value,
      'student_registration_id': studentRegistrationId,
      'address': address,
      'state': state,
      'district': district,
      'city': city,
      'pincode': pincode,
      'preferred_language': preferredLanguage.value,
      'password_hash': passwordHash,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ParentUser.fromMap(Map<String, dynamic> map) {
    return ParentUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      occupation: map['occupation'],
      relationshipType: RelationshipTypeExtension.fromString(map['relationship_type']),
      studentRegistrationId: map['student_registration_id'],
      address: map['address'],
      state: map['state'],
      district: map['district'],
      city: map['city'],
      pincode: map['pincode'],
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
    email,
    phone,
    occupation,
    relationshipType,
    studentRegistrationId,
    address,
    state,
    district,
    city,
    pincode,
    preferredLanguage,
    passwordHash,
    isVerified,
    createdAt,
    updatedAt,
  ];
}
