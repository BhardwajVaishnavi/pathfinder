import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final int id;
  final int testSetId;
  final String questionText;
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;
  final String? correctOption; // 'A', 'B', 'C', or 'D'
  final String? explanation;

  const Question({
    required this.id,
    required this.testSetId,
    required this.questionText,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    this.correctOption,
    this.explanation,
  });

  Question copyWith({
    int? id,
    int? testSetId,
    String? questionText,
    String? optionA,
    String? optionB,
    String? optionC,
    String? optionD,
    String? correctOption,
    String? explanation,
  }) {
    return Question(
      id: id ?? this.id,
      testSetId: testSetId ?? this.testSetId,
      questionText: questionText ?? this.questionText,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      optionC: optionC ?? this.optionC,
      optionD: optionD ?? this.optionD,
      correctOption: correctOption ?? this.correctOption,
      explanation: explanation ?? this.explanation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'test_set_id': testSetId,
      'question_text': questionText,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'correct_option': correctOption,
      'explanation': explanation,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      testSetId: map['test_set_id'],
      questionText: map['question_text'],
      optionA: map['option_a'],
      optionB: map['option_b'],
      optionC: map['option_c'],
      optionD: map['option_d'],
      correctOption: map['correct_option'],
      explanation: map['explanation'],
    );
  }

  List<String> get options {
    final result = <String>[];
    if (optionA != null) result.add(optionA!);
    if (optionB != null) result.add(optionB!);
    if (optionC != null) result.add(optionC!);
    if (optionD != null) result.add(optionD!);
    return result;
  }

  String? getOptionByLetter(String letter) {
    switch (letter) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
    id,
    testSetId,
    questionText,
    optionA,
    optionB,
    optionC,
    optionD,
    correctOption,
    explanation
  ];
}
