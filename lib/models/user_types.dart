import 'package:equatable/equatable.dart';

// User role enumeration
enum UserRole {
  student,
  parent,
  teacher,
  counselor,
  admin,
}

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.student:
        return 'student';
      case UserRole.parent:
        return 'parent';
      case UserRole.teacher:
        return 'teacher';
      case UserRole.counselor:
        return 'counselor';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'parent':
        return UserRole.parent;
      case 'teacher':
        return UserRole.teacher;
      case 'counselor':
        return UserRole.counselor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}

// Educational categories
enum EducationCategory {
  tenthFail,
  tenthPass,
  twelfthFail,
  twelfthPass,
  graduateArts,
  graduateScience,
  graduateCommerce,
  engineeringCSE,
  engineeringECE,
  engineeringMechanical,
  engineeringCivil,
  engineeringOther,
  postgraduate,
}

extension EducationCategoryExtension on EducationCategory {
  String get value {
    switch (this) {
      case EducationCategory.tenthFail:
        return 'tenth_fail';
      case EducationCategory.tenthPass:
        return 'tenth_pass';
      case EducationCategory.twelfthFail:
        return 'twelfth_fail';
      case EducationCategory.twelfthPass:
        return 'twelfth_pass';
      case EducationCategory.graduateArts:
        return 'graduate_arts';
      case EducationCategory.graduateScience:
        return 'graduate_science';
      case EducationCategory.graduateCommerce:
        return 'graduate_commerce';
      case EducationCategory.engineeringCSE:
        return 'engineering_cse';
      case EducationCategory.engineeringECE:
        return 'engineering_ece';
      case EducationCategory.engineeringMechanical:
        return 'engineering_mechanical';
      case EducationCategory.engineeringCivil:
        return 'engineering_civil';
      case EducationCategory.engineeringOther:
        return 'engineering_other';
      case EducationCategory.postgraduate:
        return 'postgraduate';
    }
  }

  String get displayName {
    switch (this) {
      case EducationCategory.tenthFail:
        return '10th Fail';
      case EducationCategory.tenthPass:
        return '10th Pass';
      case EducationCategory.twelfthFail:
        return '12th Fail';
      case EducationCategory.twelfthPass:
        return '12th Pass';
      case EducationCategory.graduateArts:
        return 'Graduate - Arts';
      case EducationCategory.graduateScience:
        return 'Graduate - Science';
      case EducationCategory.graduateCommerce:
        return 'Graduate - Commerce';
      case EducationCategory.engineeringCSE:
        return 'Engineering - CSE';
      case EducationCategory.engineeringECE:
        return 'Engineering - ECE';
      case EducationCategory.engineeringMechanical:
        return 'Engineering - Mechanical';
      case EducationCategory.engineeringCivil:
        return 'Engineering - Civil';
      case EducationCategory.engineeringOther:
        return 'Engineering - Other';
      case EducationCategory.postgraduate:
        return 'Postgraduate';
    }
  }

  static EducationCategory fromString(String value) {
    switch (value.toLowerCase()) {
      case 'tenth_fail':
        return EducationCategory.tenthFail;
      case 'tenth_pass':
        return EducationCategory.tenthPass;
      case 'twelfth_fail':
        return EducationCategory.twelfthFail;
      case 'twelfth_pass':
        return EducationCategory.twelfthPass;
      case 'graduate_arts':
        return EducationCategory.graduateArts;
      case 'graduate_science':
        return EducationCategory.graduateScience;
      case 'graduate_commerce':
        return EducationCategory.graduateCommerce;
      case 'engineering_cse':
        return EducationCategory.engineeringCSE;
      case 'engineering_ece':
        return EducationCategory.engineeringECE;
      case 'engineering_mechanical':
        return EducationCategory.engineeringMechanical;
      case 'engineering_civil':
        return EducationCategory.engineeringCivil;
      case 'engineering_other':
        return EducationCategory.engineeringOther;
      case 'postgraduate':
        return EducationCategory.postgraduate;
      default:
        return EducationCategory.tenthPass;
    }
  }
}

// Language preferences
enum Language {
  english,
  hindi,
  odia,
  bengali,
  tamil,
  telugu,
  marathi,
  gujarati,
}

extension LanguageExtension on Language {
  String get value {
    switch (this) {
      case Language.english:
        return 'english';
      case Language.hindi:
        return 'hindi';
      case Language.odia:
        return 'odia';
      case Language.bengali:
        return 'bengali';
      case Language.tamil:
        return 'tamil';
      case Language.telugu:
        return 'telugu';
      case Language.marathi:
        return 'marathi';
      case Language.gujarati:
        return 'gujarati';
    }
  }

  String get displayName {
    switch (this) {
      case Language.english:
        return 'English';
      case Language.hindi:
        return 'Hindi';
      case Language.odia:
        return 'Odia';
      case Language.bengali:
        return 'Bengali';
      case Language.tamil:
        return 'Tamil';
      case Language.telugu:
        return 'Telugu';
      case Language.marathi:
        return 'Marathi';
      case Language.gujarati:
        return 'Gujarati';
    }
  }

  static Language fromString(String value) {
    switch (value.toLowerCase()) {
      case 'english':
        return Language.english;
      case 'hindi':
        return Language.hindi;
      case 'odia':
        return Language.odia;
      case 'bengali':
        return Language.bengali;
      case 'tamil':
        return Language.tamil;
      case 'telugu':
        return Language.telugu;
      case 'marathi':
        return Language.marathi;
      case 'gujarati':
        return Language.gujarati;
      default:
        return Language.english;
    }
  }
}

// Relationship types for parents
enum RelationshipType {
  father,
  mother,
  guardian,
  uncle,
  aunt,
  grandparent,
  other,
}

extension RelationshipTypeExtension on RelationshipType {
  String get value {
    switch (this) {
      case RelationshipType.father:
        return 'father';
      case RelationshipType.mother:
        return 'mother';
      case RelationshipType.guardian:
        return 'guardian';
      case RelationshipType.uncle:
        return 'uncle';
      case RelationshipType.aunt:
        return 'aunt';
      case RelationshipType.grandparent:
        return 'grandparent';
      case RelationshipType.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case RelationshipType.father:
        return 'Father';
      case RelationshipType.mother:
        return 'Mother';
      case RelationshipType.guardian:
        return 'Guardian';
      case RelationshipType.uncle:
        return 'Uncle';
      case RelationshipType.aunt:
        return 'Aunt';
      case RelationshipType.grandparent:
        return 'Grandparent';
      case RelationshipType.other:
        return 'Other';
    }
  }

  static RelationshipType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'father':
        return RelationshipType.father;
      case 'mother':
        return RelationshipType.mother;
      case 'guardian':
        return RelationshipType.guardian;
      case 'uncle':
        return RelationshipType.uncle;
      case 'aunt':
        return RelationshipType.aunt;
      case 'grandparent':
        return RelationshipType.grandparent;
      case 'other':
        return RelationshipType.other;
      default:
        return RelationshipType.guardian;
    }
  }
}

// Admin access levels for teachers
enum AdminAccessLevel {
  basic,
  intermediate,
  advanced,
}

extension AdminAccessLevelExtension on AdminAccessLevel {
  String get value {
    switch (this) {
      case AdminAccessLevel.basic:
        return 'basic';
      case AdminAccessLevel.intermediate:
        return 'intermediate';
      case AdminAccessLevel.advanced:
        return 'advanced';
    }
  }

  String get displayName {
    switch (this) {
      case AdminAccessLevel.basic:
        return 'Basic Access';
      case AdminAccessLevel.intermediate:
        return 'Intermediate Access';
      case AdminAccessLevel.advanced:
        return 'Advanced Access';
    }
  }

  static AdminAccessLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'basic':
        return AdminAccessLevel.basic;
      case 'intermediate':
        return AdminAccessLevel.intermediate;
      case 'advanced':
        return AdminAccessLevel.advanced;
      default:
        return AdminAccessLevel.basic;
    }
  }
}
