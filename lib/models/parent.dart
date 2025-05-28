import 'package:equatable/equatable.dart';
import 'user_types.dart';

class Parent extends Equatable {
  final int id;
  final String fullName;
  final RelationshipType relationshipToStudent;
  final String email;
  final String phone;
  final String occupation;
  final int studentId; // Linked student's ID
  final String address;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final Language preferredLanguage;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Parent({
    required this.id,
    required this.fullName,
    required this.relationshipToStudent,
    required this.email,
    required this.phone,
    required this.occupation,
    required this.studentId,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    required this.preferredLanguage,
    this.isVerified = false,
    required this.createdAt,
    this.updatedAt,
  });

  Parent copyWith({
    int? id,
    String? fullName,
    RelationshipType? relationshipToStudent,
    String? email,
    String? phone,
    String? occupation,
    int? studentId,
    String? address,
    String? state,
    String? district,
    String? city,
    String? pincode,
    Language? preferredLanguage,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Parent(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      relationshipToStudent: relationshipToStudent ?? this.relationshipToStudent,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      occupation: occupation ?? this.occupation,
      studentId: studentId ?? this.studentId,
      address: address ?? this.address,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'relationship_to_student': relationshipToStudent.value,
      'email': email,
      'phone': phone,
      'occupation': occupation,
      'student_id': studentId,
      'address': address,
      'state': state,
      'district': district,
      'city': city,
      'pincode': pincode,
      'preferred_language': preferredLanguage.value,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Parent.fromMap(Map<String, dynamic> map) {
    return Parent(
      id: map['id'],
      fullName: map['full_name'],
      relationshipToStudent: RelationshipTypeExtension.fromString(map['relationship_to_student']),
      email: map['email'],
      phone: map['phone'],
      occupation: map['occupation'],
      studentId: map['student_id'],
      address: map['address'],
      state: map['state'],
      district: map['district'],
      city: map['city'],
      pincode: map['pincode'],
      preferredLanguage: LanguageExtension.fromString(map['preferred_language']),
      isVerified: map['is_verified'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    relationshipToStudent,
    email,
    phone,
    occupation,
    studentId,
    address,
    state,
    district,
    city,
    pincode,
    preferredLanguage,
    isVerified,
    createdAt,
    updatedAt,
  ];
}
