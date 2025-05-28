import 'package:equatable/equatable.dart';
import 'user_types.dart';

enum CounselorSpecialization {
  careerGuidance,
  educationalPlanning,
  psychologicalCounseling,
  skillDevelopment,
  industryExpert,
  academicAdvisor,
}

extension CounselorSpecializationExtension on CounselorSpecialization {
  String get value {
    switch (this) {
      case CounselorSpecialization.careerGuidance:
        return 'career_guidance';
      case CounselorSpecialization.educationalPlanning:
        return 'educational_planning';
      case CounselorSpecialization.psychologicalCounseling:
        return 'psychological_counseling';
      case CounselorSpecialization.skillDevelopment:
        return 'skill_development';
      case CounselorSpecialization.industryExpert:
        return 'industry_expert';
      case CounselorSpecialization.academicAdvisor:
        return 'academic_advisor';
    }
  }

  String get displayName {
    switch (this) {
      case CounselorSpecialization.careerGuidance:
        return 'Career Guidance';
      case CounselorSpecialization.educationalPlanning:
        return 'Educational Planning';
      case CounselorSpecialization.psychologicalCounseling:
        return 'Psychological Counseling';
      case CounselorSpecialization.skillDevelopment:
        return 'Skill Development';
      case CounselorSpecialization.industryExpert:
        return 'Industry Expert';
      case CounselorSpecialization.academicAdvisor:
        return 'Academic Advisor';
    }
  }

  static CounselorSpecialization fromString(String value) {
    switch (value.toLowerCase()) {
      case 'career_guidance':
        return CounselorSpecialization.careerGuidance;
      case 'educational_planning':
        return CounselorSpecialization.educationalPlanning;
      case 'psychological_counseling':
        return CounselorSpecialization.psychologicalCounseling;
      case 'skill_development':
        return CounselorSpecialization.skillDevelopment;
      case 'industry_expert':
        return CounselorSpecialization.industryExpert;
      case 'academic_advisor':
        return CounselorSpecialization.academicAdvisor;
      default:
        return CounselorSpecialization.careerGuidance;
    }
  }
}

class Counselor extends Equatable {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final List<CounselorSpecialization> specializations;
  final int yearsOfExperience;
  final String qualifications;
  final String certifications;
  final double hourlyRate;
  final List<String> availableTimeSlots;
  final List<Language> supportedLanguages;
  final double rating;
  final int totalSessions;
  final String bio;
  final String profileImagePath;
  final bool isVerified;
  final bool isActive;
  final bool isAvailableOnline;
  final bool isAvailableOffline;
  final String address;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Counselor({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.specializations,
    required this.yearsOfExperience,
    required this.qualifications,
    required this.certifications,
    required this.hourlyRate,
    required this.availableTimeSlots,
    required this.supportedLanguages,
    this.rating = 0.0,
    this.totalSessions = 0,
    required this.bio,
    required this.profileImagePath,
    this.isVerified = false,
    this.isActive = true,
    this.isAvailableOnline = true,
    this.isAvailableOffline = false,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    required this.createdAt,
    this.updatedAt,
  });

  Counselor copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phone,
    List<CounselorSpecialization>? specializations,
    int? yearsOfExperience,
    String? qualifications,
    String? certifications,
    double? hourlyRate,
    List<String>? availableTimeSlots,
    List<Language>? supportedLanguages,
    double? rating,
    int? totalSessions,
    String? bio,
    String? profileImagePath,
    bool? isVerified,
    bool? isActive,
    bool? isAvailableOnline,
    bool? isAvailableOffline,
    String? address,
    String? state,
    String? district,
    String? city,
    String? pincode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Counselor(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specializations: specializations ?? this.specializations,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      qualifications: qualifications ?? this.qualifications,
      certifications: certifications ?? this.certifications,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      rating: rating ?? this.rating,
      totalSessions: totalSessions ?? this.totalSessions,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      isAvailableOnline: isAvailableOnline ?? this.isAvailableOnline,
      isAvailableOffline: isAvailableOffline ?? this.isAvailableOffline,
      address: address ?? this.address,
      state: state ?? this.state,
      district: district ?? this.district,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'specializations': specializations.map((s) => s.value).join(','),
      'years_of_experience': yearsOfExperience,
      'qualifications': qualifications,
      'certifications': certifications,
      'hourly_rate': hourlyRate,
      'available_time_slots': availableTimeSlots.join(','),
      'supported_languages': supportedLanguages.map((l) => l.value).join(','),
      'rating': rating,
      'total_sessions': totalSessions,
      'bio': bio,
      'profile_image_path': profileImagePath,
      'is_verified': isVerified,
      'is_active': isActive,
      'is_available_online': isAvailableOnline,
      'is_available_offline': isAvailableOffline,
      'address': address,
      'state': state,
      'district': district,
      'city': city,
      'pincode': pincode,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Counselor.fromMap(Map<String, dynamic> map) {
    return Counselor(
      id: map['id'],
      fullName: map['full_name'],
      email: map['email'],
      phone: map['phone'],
      specializations: map['specializations']
          .toString()
          .split(',')
          .map((s) => CounselorSpecializationExtension.fromString(s))
          .toList(),
      yearsOfExperience: map['years_of_experience'],
      qualifications: map['qualifications'],
      certifications: map['certifications'],
      hourlyRate: map['hourly_rate'].toDouble(),
      availableTimeSlots: map['available_time_slots'].toString().split(','),
      supportedLanguages: map['supported_languages']
          .toString()
          .split(',')
          .map((l) => LanguageExtension.fromString(l))
          .toList(),
      rating: map['rating']?.toDouble() ?? 0.0,
      totalSessions: map['total_sessions'] ?? 0,
      bio: map['bio'],
      profileImagePath: map['profile_image_path'],
      isVerified: map['is_verified'] ?? false,
      isActive: map['is_active'] ?? true,
      isAvailableOnline: map['is_available_online'] ?? true,
      isAvailableOffline: map['is_available_offline'] ?? false,
      address: map['address'],
      state: map['state'],
      district: map['district'],
      city: map['city'],
      pincode: map['pincode'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phone,
    specializations,
    yearsOfExperience,
    qualifications,
    certifications,
    hourlyRate,
    availableTimeSlots,
    supportedLanguages,
    rating,
    totalSessions,
    bio,
    profileImagePath,
    isVerified,
    isActive,
    isAvailableOnline,
    isAvailableOffline,
    address,
    state,
    district,
    city,
    pincode,
    createdAt,
    updatedAt,
  ];
}
