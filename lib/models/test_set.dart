import 'package:equatable/equatable.dart';

class TestSet extends Equatable {
  final int id;
  final int categoryId;
  final String title;
  final String? description;
  final int? timeLimit; // in minutes
  final int? passingScore; // percentage

  const TestSet({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    this.timeLimit,
    this.passingScore,
  });

  TestSet copyWith({
    int? id,
    int? categoryId,
    String? title,
    String? description,
    int? timeLimit,
    int? passingScore,
  }) {
    return TestSet(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      timeLimit: timeLimit ?? this.timeLimit,
      passingScore: passingScore ?? this.passingScore,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'time_limit': timeLimit,
      'passing_score': passingScore,
    };
  }

  factory TestSet.fromMap(Map<String, dynamic> map) {
    return TestSet(
      id: map['id'],
      categoryId: map['category_id'],
      title: map['title'],
      description: map['description'],
      timeLimit: map['time_limit'],
      passingScore: map['passing_score'],
    );
  }

  @override
  List<Object?> get props => [id, categoryId, title, description, timeLimit, passingScore];
}
