import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'test_result_screen.dart';

class TestSessionScreen extends StatefulWidget {
  final TestSet testSet;
  final List<Question> questions;

  const TestSessionScreen({
    Key? key,
    required this.testSet,
    required this.questions,
  }) : super(key: key);

  @override
  State<TestSessionScreen> createState() => _TestSessionScreenState();
}

class _TestSessionScreenState extends State<TestSessionScreen> {
  final TestService _testService = TestService();

  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, String> _userResponses = {};
  bool _isSubmitting = false;

  // Timer variables
  late Timer _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Set timer based on test set time limit or default to 60 minutes
    _remainingSeconds = (widget.testSet.timeLimit ?? 60) * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer.cancel();
          _submitTest();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds / 60).floor();
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _navigateToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _saveResponse(int questionId, String response) {
    setState(() {
      _userResponses[questionId] = response;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _generateStrengths(List<Question> questions, List<UserResponse> userResponses) {
    // Group questions by topic or category and identify strengths
    final Map<String, int> correctByTopic = {};
    final Map<String, int> totalByTopic = {};

    // For now, we'll use a simple approach
    int correctCount = userResponses.where((r) => r.isCorrect == true).length;
    double percentage = questions.isNotEmpty ? (correctCount / questions.length) * 100 : 0;

    if (percentage >= 80) {
      return 'Strong overall performance across all question types.';
    } else if (percentage >= 60) {
      return 'Good understanding of most concepts tested.';
    } else {
      return 'Some areas of strength identified, but further practice recommended.';
    }
  }

  String _generateAreasForImprovement(List<Question> questions, List<UserResponse> userResponses) {
    // Identify areas where the user struggled
    final incorrectResponses = userResponses.where((r) => r.isCorrect == false).toList();

    if (incorrectResponses.isEmpty) {
      return 'No specific areas for improvement identified.';
    }

    // For now, we'll use a simple approach
    if (incorrectResponses.length > questions.length * 0.5) {
      return 'Significant improvement needed across multiple areas.';
    } else if (incorrectResponses.length > questions.length * 0.3) {
      return 'Some improvement needed in specific areas.';
    } else {
      return 'Minor improvements could be made in a few areas.';
    }
  }

  String _generateRecommendations(double percentage) {
    if (percentage >= 90) {
      return 'Consider advancing to more challenging material.';
    } else if (percentage >= 70) {
      return 'Continue practicing with similar difficulty level.';
    } else if (percentage >= 50) {
      return 'Review the concepts covered in this test and try again.';
    } else {
      return 'Consider reviewing fundamental concepts before retaking this test.';
    }
  }

  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Test'),
        content: const Text('Are you sure you want to submit your test? You cannot change your answers after submission.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _submitTest();
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTest() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get time spent in seconds
      final timeSpentInSeconds = (widget.testSet.timeLimit ?? 60) * 60 - _remainingSeconds;

      // Submit test using the test service
      final report = await _testService.submitTest(
        widget.testSet.id,
        widget.questions,
        _userResponses,
        timeSpentInSeconds,
      );

      // Generate user responses for display
      final List<UserResponse> userResponses = [];

      for (final question in widget.questions) {
        final selectedOption = _userResponses[question.id];
        final isCorrect = selectedOption == question.correctOption;

        userResponses.add(UserResponse(
          id: 0,
          userId: report.userId,
          questionId: question.id,
          selectedOption: selectedOption ?? '',
          isCorrect: selectedOption != null ? isCorrect : null,
          responseTime: timeSpentInSeconds ~/ widget.questions.length, // Approximate time per question
          createdAt: DateTime.now(),
        ));
      }

      if (!mounted) return;

      // Navigate to results screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TestResultScreen(
            testSet: widget.testSet,
            questions: widget.questions,
            userResponses: userResponses,
            report: report,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting test: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Test'),
            content: const Text('Are you sure you want to exit the test? Your progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(AppStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.testSet.title),
          centerTitle: true,
          actions: [
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: _remainingSeconds < 300 ? AppColors.error.withOpacity(0.2) : AppColors.surface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: _remainingSeconds < 300 ? AppColors.error : AppColors.surface,
                    ),
                    const SizedBox(width: AppDimensions.paddingXS),
                    Text(
                      _formattedTime,
                      style: AppTextStyles.bodyText2.copyWith(
                        color: _remainingSeconds < 300 ? AppColors.error : AppColors.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
          ],
        ),
        body: _isSubmitting
            ? const LoadingIndicator(message: 'Submitting test...')
            : Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.questions.length,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),

                  // Question counter
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${_currentIndex + 1} of ${widget.questions.length}',
                          style: AppTextStyles.subtitle2,
                        ),
                        Text(
                          'Time remaining: ${_formatTime(_remainingSeconds)}',
                          style: AppTextStyles.subtitle2,
                        ),
                      ],
                    ),
                  ),

                  // Questions
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.questions.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final question = widget.questions[index];
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          child: _buildQuestionWidget(question),
                        );
                      },
                    ),
                  ),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentIndex > 0)
                          CustomButton(
                            text: AppStrings.previousQuestion,
                            onPressed: () => _navigateToQuestion(_currentIndex - 1),
                            type: ButtonType.outline,
                            icon: Icons.arrow_back,
                          )
                        else
                          const SizedBox(),
                        if (_currentIndex < widget.questions.length - 1)
                          CustomButton(
                            text: AppStrings.nextQuestion,
                            onPressed: () => _navigateToQuestion(_currentIndex + 1),
                            icon: Icons.arrow_forward,
                          )
                        else
                          CustomButton(
                            text: AppStrings.submitTest,
                            onPressed: _showSubmitConfirmation,
                            icon: Icons.check_circle,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: _isSubmitting
            ? null
            : Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingS),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.questions.length,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                  itemBuilder: (context, index) {
                    final isAnswered = _userResponses.containsKey(widget.questions[index].id);
                    final isCurrentQuestion = index == _currentIndex;

                    return GestureDetector(
                      onTap: () => _navigateToQuestion(index),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isCurrentQuestion
                              ? AppColors.primary
                              : isAnswered
                                  ? AppColors.success.withOpacity(0.2)
                                  : AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCurrentQuestion
                                ? AppColors.primary
                                : isAnswered
                                    ? AppColors.success
                                    : AppColors.divider,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isCurrentQuestion
                                  ? AppColors.surface
                                  : isAnswered
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildQuestionWidget(Question question) {
    final currentResponse = _userResponses[question.id];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.questionText,
          style: AppTextStyles.headline3,
        ),
        const SizedBox(height: AppDimensions.paddingXL),

        // Multiple choice options
        if (question.optionA != null)
          _buildMultipleChoiceOption(
            question.id,
            'A',
            question.optionA!,
            'A' == currentResponse,
            (response) => _saveResponse(question.id, response),
          ),
        if (question.optionB != null)
          _buildMultipleChoiceOption(
            question.id,
            'B',
            question.optionB!,
            'B' == currentResponse,
            (response) => _saveResponse(question.id, response),
          ),
        if (question.optionC != null)
          _buildMultipleChoiceOption(
            question.id,
            'C',
            question.optionC!,
            'C' == currentResponse,
            (response) => _saveResponse(question.id, response),
          ),
        if (question.optionD != null)
          _buildMultipleChoiceOption(
            question.id,
            'D',
            question.optionD!,
            'D' == currentResponse,
            (response) => _saveResponse(question.id, response),
          ),
      ],
    );
  }

  Widget _buildMultipleChoiceOption(
    int questionId,
    String optionLetter,
    String optionText,
    bool isSelected,
    Function(String) onSelect,
  ) {
    return InkWell(
      onTap: () => onSelect(optionLetter),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : AppColors.surface,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
              child: Center(
                child: Text(
                  optionLetter,
                  style: TextStyle(
                    color: isSelected ? AppColors.surface : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Expanded(
              child: Text(
                optionText,
                style: AppTextStyles.bodyText1.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
