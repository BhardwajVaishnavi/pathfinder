import 'package:equatable/equatable.dart';

class UserResponse extends Equatable {
  final int id;
  final int userId;
  final int questionId;
  final String? selectedOption; // 'A', 'B', 'C', or 'D'
  final bool? isCorrect;
  final int? responseTime; // in seconds
  final DateTime? createdAt;

  const UserResponse({
    required this.id,
    required this.userId,
    required this.questionId,
    this.selectedOption,
    this.isCorrect,
    this.responseTime,
    this.createdAt,
  });

  UserResponse copyWith({
    int? id,
    int? userId,
    int? questionId,
    String? selectedOption,
    bool? isCorrect,
    int? responseTime,
    DateTime? createdAt,
  }) {
    return UserResponse(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questionId: questionId ?? this.questionId,
      selectedOption: selectedOption ?? this.selectedOption,
      isCorrect: isCorrect ?? this.isCorrect,
      responseTime: responseTime ?? this.responseTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'question_id': questionId,
      'selected_option': selectedOption,
      'is_correct': isCorrect != null ? (isCorrect! ? 1 : 0) : null,
      'response_time': responseTime,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory UserResponse.fromMap(Map<String, dynamic> map) {
    return UserResponse(
      id: map['id'],
      userId: map['user_id'],
      questionId: map['question_id'],
      selectedOption: map['selected_option'],
      isCorrect: map['is_correct'] != null ? map['is_correct'] == 1 : null,
      responseTime: map['response_time'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    questionId,
    selectedOption,
    isCorrect,
    responseTime,
    createdAt
  ];
}
