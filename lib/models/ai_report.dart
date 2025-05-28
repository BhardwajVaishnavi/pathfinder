import 'package:equatable/equatable.dart';

enum TestType {
  aptitude,
  psychometric,
  combined,
}

extension TestTypeExtension on TestType {
  String get value {
    switch (this) {
      case TestType.aptitude:
        return 'aptitude';
      case TestType.psychometric:
        return 'psychometric';
      case TestType.combined:
        return 'combined';
    }
  }

  String get displayName {
    switch (this) {
      case TestType.aptitude:
        return 'Aptitude Test';
      case TestType.psychometric:
        return 'Psychometric Test';
      case TestType.combined:
        return 'Combined Assessment';
    }
  }

  static TestType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'aptitude':
        return TestType.aptitude;
      case 'psychometric':
        return TestType.psychometric;
      case 'combined':
        return TestType.combined;
      default:
        return TestType.combined;
    }
  }
}

class PersonalityTrait extends Equatable {
  final String name;
  final double score; // 0.0 to 1.0
  final String description;

  const PersonalityTrait({
    required this.name,
    required this.score,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'score': score,
      'description': description,
    };
  }

  factory PersonalityTrait.fromMap(Map<String, dynamic> map) {
    return PersonalityTrait(
      name: map['name'],
      score: map['score'].toDouble(),
      description: map['description'],
    );
  }

  @override
  List<Object?> get props => [name, score, description];
}

class InterestArea extends Equatable {
  final String area;
  final double score; // 0.0 to 1.0
  final List<String> relatedCareers;

  const InterestArea({
    required this.area,
    required this.score,
    required this.relatedCareers,
  });

  Map<String, dynamic> toMap() {
    return {
      'area': area,
      'score': score,
      'related_careers': relatedCareers,
    };
  }

  factory InterestArea.fromMap(Map<String, dynamic> map) {
    return InterestArea(
      area: map['area'],
      score: map['score'].toDouble(),
      relatedCareers: List<String>.from(map['related_careers']),
    );
  }

  @override
  List<Object?> get props => [area, score, relatedCareers];
}

class SkillGap extends Equatable {
  final String skillName;
  final double currentLevel; // 0.0 to 1.0
  final double requiredLevel; // 0.0 to 1.0
  final List<String> improvementSuggestions;

  const SkillGap({
    required this.skillName,
    required this.currentLevel,
    required this.requiredLevel,
    required this.improvementSuggestions,
  });

  double get gapPercentage => (requiredLevel - currentLevel) * 100;

  Map<String, dynamic> toMap() {
    return {
      'skill_name': skillName,
      'current_level': currentLevel,
      'required_level': requiredLevel,
      'improvement_suggestions': improvementSuggestions,
    };
  }

  factory SkillGap.fromMap(Map<String, dynamic> map) {
    return SkillGap(
      skillName: map['skill_name'],
      currentLevel: map['current_level'].toDouble(),
      requiredLevel: map['required_level'].toDouble(),
      improvementSuggestions: List<String>.from(map['improvement_suggestions']),
    );
  }

  @override
  List<Object?> get props => [skillName, currentLevel, requiredLevel, improvementSuggestions];
}

class CareerRecommendation extends Equatable {
  final String careerTitle;
  final double compatibilityScore; // 0.0 to 1.0
  final String description;
  final List<String> requiredSkills;
  final List<String> educationPath;
  final String salaryRange;
  final String jobOutlook;

  const CareerRecommendation({
    required this.careerTitle,
    required this.compatibilityScore,
    required this.description,
    required this.requiredSkills,
    required this.educationPath,
    required this.salaryRange,
    required this.jobOutlook,
  });

  Map<String, dynamic> toMap() {
    return {
      'career_title': careerTitle,
      'compatibility_score': compatibilityScore,
      'description': description,
      'required_skills': requiredSkills,
      'education_path': educationPath,
      'salary_range': salaryRange,
      'job_outlook': jobOutlook,
    };
  }

  factory CareerRecommendation.fromMap(Map<String, dynamic> map) {
    return CareerRecommendation(
      careerTitle: map['career_title'],
      compatibilityScore: map['compatibility_score'].toDouble(),
      description: map['description'],
      requiredSkills: List<String>.from(map['required_skills']),
      educationPath: List<String>.from(map['education_path']),
      salaryRange: map['salary_range'],
      jobOutlook: map['job_outlook'],
    );
  }

  @override
  List<Object?> get props => [
    careerTitle,
    compatibilityScore,
    description,
    requiredSkills,
    educationPath,
    salaryRange,
    jobOutlook,
  ];
}

class AIReport extends Equatable {
  final int id;
  final int studentId;
  final TestType testType;
  final int aptitudeScore;
  final double aptitudePercentage;
  final List<PersonalityTrait> personalityTraits;
  final List<InterestArea> interestAreas;
  final List<SkillGap> skillGaps;
  final List<CareerRecommendation> careerRecommendations;
  final String overallAnalysis;
  final String strengthsAnalysis;
  final String improvementAreas;
  final String nextSteps;
  final bool isChatGPTTrained; // Whether this report has been used to train ChatGPT
  final String? chatGPTModelId; // ID of the trained ChatGPT model
  final DateTime createdAt;
  final DateTime? updatedAt;

  const AIReport({
    required this.id,
    required this.studentId,
    required this.testType,
    required this.aptitudeScore,
    required this.aptitudePercentage,
    required this.personalityTraits,
    required this.interestAreas,
    required this.skillGaps,
    required this.careerRecommendations,
    required this.overallAnalysis,
    required this.strengthsAnalysis,
    required this.improvementAreas,
    required this.nextSteps,
    this.isChatGPTTrained = false,
    this.chatGPTModelId,
    required this.createdAt,
    this.updatedAt,
  });

  AIReport copyWith({
    int? id,
    int? studentId,
    TestType? testType,
    int? aptitudeScore,
    double? aptitudePercentage,
    List<PersonalityTrait>? personalityTraits,
    List<InterestArea>? interestAreas,
    List<SkillGap>? skillGaps,
    List<CareerRecommendation>? careerRecommendations,
    String? overallAnalysis,
    String? strengthsAnalysis,
    String? improvementAreas,
    String? nextSteps,
    bool? isChatGPTTrained,
    String? chatGPTModelId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIReport(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      testType: testType ?? this.testType,
      aptitudeScore: aptitudeScore ?? this.aptitudeScore,
      aptitudePercentage: aptitudePercentage ?? this.aptitudePercentage,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      interestAreas: interestAreas ?? this.interestAreas,
      skillGaps: skillGaps ?? this.skillGaps,
      careerRecommendations: careerRecommendations ?? this.careerRecommendations,
      overallAnalysis: overallAnalysis ?? this.overallAnalysis,
      strengthsAnalysis: strengthsAnalysis ?? this.strengthsAnalysis,
      improvementAreas: improvementAreas ?? this.improvementAreas,
      nextSteps: nextSteps ?? this.nextSteps,
      isChatGPTTrained: isChatGPTTrained ?? this.isChatGPTTrained,
      chatGPTModelId: chatGPTModelId ?? this.chatGPTModelId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'test_type': testType.value,
      'aptitude_score': aptitudeScore,
      'aptitude_percentage': aptitudePercentage,
      'personality_traits': personalityTraits.map((t) => t.toMap()).toList(),
      'interest_areas': interestAreas.map((i) => i.toMap()).toList(),
      'skill_gaps': skillGaps.map((s) => s.toMap()).toList(),
      'career_recommendations': careerRecommendations.map((c) => c.toMap()).toList(),
      'overall_analysis': overallAnalysis,
      'strengths_analysis': strengthsAnalysis,
      'improvement_areas': improvementAreas,
      'next_steps': nextSteps,
      'is_chatgpt_trained': isChatGPTTrained,
      'chatgpt_model_id': chatGPTModelId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AIReport.fromMap(Map<String, dynamic> map) {
    return AIReport(
      id: map['id'],
      studentId: map['student_id'],
      testType: TestTypeExtension.fromString(map['test_type']),
      aptitudeScore: map['aptitude_score'],
      aptitudePercentage: map['aptitude_percentage'].toDouble(),
      personalityTraits: (map['personality_traits'] as List)
          .map((t) => PersonalityTrait.fromMap(t))
          .toList(),
      interestAreas: (map['interest_areas'] as List)
          .map((i) => InterestArea.fromMap(i))
          .toList(),
      skillGaps: (map['skill_gaps'] as List)
          .map((s) => SkillGap.fromMap(s))
          .toList(),
      careerRecommendations: (map['career_recommendations'] as List)
          .map((c) => CareerRecommendation.fromMap(c))
          .toList(),
      overallAnalysis: map['overall_analysis'],
      strengthsAnalysis: map['strengths_analysis'],
      improvementAreas: map['improvement_areas'],
      nextSteps: map['next_steps'],
      isChatGPTTrained: map['is_chatgpt_trained'] ?? false,
      chatGPTModelId: map['chatgpt_model_id'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    studentId,
    testType,
    aptitudeScore,
    aptitudePercentage,
    personalityTraits,
    interestAreas,
    skillGaps,
    careerRecommendations,
    overallAnalysis,
    strengthsAnalysis,
    improvementAreas,
    nextSteps,
    isChatGPTTrained,
    chatGPTModelId,
    createdAt,
    updatedAt,
  ];
}
