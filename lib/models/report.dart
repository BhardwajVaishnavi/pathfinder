import 'package:equatable/equatable.dart';

class Report extends Equatable {
  final int id;
  final int userId;
  final int testSetId;
  final int? totalQuestions;
  final int? correctAnswers;
  final int? incorrectAnswers;
  final int? score;
  final double? percentage;
  final String? strengths;
  final String? areasForImprovement;
  final String? recommendations;
  final DateTime? createdAt;

  const Report({
    required this.id,
    required this.userId,
    required this.testSetId,
    this.totalQuestions,
    this.correctAnswers,
    this.incorrectAnswers,
    this.score,
    this.percentage,
    this.strengths,
    this.areasForImprovement,
    this.recommendations,
    this.createdAt,
  });

  Report copyWith({
    int? id,
    int? userId,
    int? testSetId,
    int? totalQuestions,
    int? correctAnswers,
    int? incorrectAnswers,
    int? score,
    double? percentage,
    String? strengths,
    String? areasForImprovement,
    String? recommendations,
    DateTime? createdAt,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      testSetId: testSetId ?? this.testSetId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      score: score ?? this.score,
      percentage: percentage ?? this.percentage,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      recommendations: recommendations ?? this.recommendations,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'test_set_id': testSetId,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'incorrect_answers': incorrectAnswers,
      'score': score,
      'percentage': percentage,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
      'recommendations': recommendations,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      userId: map['user_id'],
      testSetId: map['test_set_id'],
      totalQuestions: map['total_questions'],
      correctAnswers: map['correct_answers'],
      incorrectAnswers: map['incorrect_answers'],
      score: map['score'],
      percentage: map['percentage'],
      strengths: map['strengths'],
      areasForImprovement: map['areas_for_improvement'],
      recommendations: map['recommendations'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    testSetId,
    totalQuestions,
    correctAnswers,
    incorrectAnswers,
    score,
    percentage,
    strengths,
    areasForImprovement,
    recommendations,
    createdAt
  ];
}
