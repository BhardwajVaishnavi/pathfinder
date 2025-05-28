import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';

class TestAnalysisScreen extends StatefulWidget {
  final TestSet testSet;
  final List<Question> questions;
  final List<UserResponse> userResponses;
  final Report report;

  const TestAnalysisScreen({
    Key? key,
    required this.testSet,
    required this.questions,
    required this.userResponses,
    required this.report,
  }) : super(key: key);

  @override
  State<TestAnalysisScreen> createState() => _TestAnalysisScreenState();
}

class _TestAnalysisScreenState extends State<TestAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Question _getQuestionById(int id) {
    return widget.questions.firstWhere((q) => q.id == id);
  }

  UserResponse? _getUserResponseForQuestion(int questionId) {
    try {
      return widget.userResponses.firstWhere((r) => r.questionId == questionId);
    } catch (e) {
      return null;
    }
  }

  List<UserResponse> get _correctResponses {
    return widget.userResponses.where((r) => r.isCorrect == true).toList();
  }

  List<UserResponse> get _incorrectResponses {
    return widget.userResponses.where((r) => r.isCorrect == false).toList();
  }

  List<Question> get _skippedQuestions {
    final answeredQuestionIds = widget.userResponses.map((r) => r.questionId).toSet();
    return widget.questions.where((q) => !answeredQuestionIds.contains(q.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Test Analysis',
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.surface,
              labelColor: AppColors.surface,
              unselectedLabelColor: AppColors.surface.withOpacity(0.7),
              tabs: const [
                Tab(text: 'All Questions'),
                Tab(text: 'Correct'),
                Tab(text: 'Incorrect'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All questions
                _buildQuestionsList(widget.questions),

                // Correct answers
                _correctResponses.isEmpty
                    ? const Center(
                        child: Text(
                          'No correct answers',
                          style: AppTextStyles.subtitle1,
                        ),
                      )
                    : _buildQuestionsList(
                        _correctResponses.map((r) => _getQuestionById(r.questionId)).toList(),
                      ),

                // Incorrect answers
                _incorrectResponses.isEmpty && _skippedQuestions.isEmpty
                    ? const Center(
                        child: Text(
                          'No incorrect or skipped questions',
                          style: AppTextStyles.subtitle1,
                        ),
                      )
                    : _buildQuestionsList([
                        ..._incorrectResponses.map((r) => _getQuestionById(r.questionId)).toList(),
                        ..._skippedQuestions,
                      ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem(String letter, String text, bool isCorrect, bool isSelected) {
    Color color;
    if (isSelected && isCorrect) {
      color = AppColors.success;
    } else if (isSelected && !isCorrect) {
      color = AppColors.error;
    } else if (isCorrect) {
      color = AppColors.success.withOpacity(0.5);
    } else {
      color = AppColors.textPrimary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected || isCorrect ? color.withOpacity(0.1) : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(
                color: color,
                width: isSelected || isCorrect ? 2 : 1,
              ),
            ),
            child: Text(
              letter,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyText2.copyWith(
                color: color,
                fontWeight: isSelected || isCorrect ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(List<Question> questions) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        final userResponse = _getUserResponseForQuestion(question.id);

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: ExpansionTile(
            title: Text(
              'Question ${widget.questions.indexOf(question) + 1}',
              style: AppTextStyles.subtitle1,
            ),
            subtitle: Text(
              question.questionText.length > 50
                  ? '${question.questionText.substring(0, 50)}...'
                  : question.questionText,
              style: AppTextStyles.bodyText2,
            ),
            leading: Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: userResponse?.isCorrect == true
                    ? AppColors.success.withOpacity(0.1)
                    : userResponse?.isCorrect == false
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(
                userResponse?.isCorrect == true
                    ? Icons.check_circle
                    : userResponse?.isCorrect == false
                        ? Icons.cancel
                        : Icons.help,
                color: userResponse?.isCorrect == true
                    ? AppColors.success
                    : userResponse?.isCorrect == false
                        ? AppColors.error
                        : AppColors.warning,
              ),
            ),
            trailing: Text(
              userResponse?.isCorrect == true ? 'Correct' : (userResponse == null ? 'Skipped' : 'Incorrect'),
              style: AppTextStyles.bodyText1.copyWith(
                fontWeight: FontWeight.bold,
                color: userResponse?.isCorrect == true
                    ? AppColors.success
                    : userResponse?.isCorrect == false
                        ? AppColors.error
                        : AppColors.warning,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      question.questionText,
                      style: AppTextStyles.bodyText1,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Options
                    const Text(
                      'Options:',
                      style: AppTextStyles.subtitle2,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),

                    if (question.optionA != null)
                      _buildOptionItem('A', question.optionA!, question.correctOption == 'A', userResponse?.selectedOption == 'A'),
                    if (question.optionB != null)
                      _buildOptionItem('B', question.optionB!, question.correctOption == 'B', userResponse?.selectedOption == 'B'),
                    if (question.optionC != null)
                      _buildOptionItem('C', question.optionC!, question.correctOption == 'C', userResponse?.selectedOption == 'C'),
                    if (question.optionD != null)
                      _buildOptionItem('D', question.optionD!, question.correctOption == 'D', userResponse?.selectedOption == 'D'),

                    const SizedBox(height: AppDimensions.paddingM),

                    // Correct answer
                    if (question.correctOption != null) ...[
                      Wrap(
                        children: [
                          const Text(
                            'Correct Answer: ',
                            style: AppTextStyles.bodyText2,
                          ),
                          Text(
                            'Option ${question.correctOption}',
                            style: AppTextStyles.bodyText2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                    ],

                    // User response
                    Wrap(
                      children: [
                        const Text(
                          'Your Answer: ',
                          style: AppTextStyles.bodyText2,
                        ),
                        Text(
                          userResponse?.selectedOption != null
                              ? 'Option ${userResponse!.selectedOption}'
                              : 'Not answered',
                          style: AppTextStyles.bodyText2.copyWith(
                            fontWeight: FontWeight.bold,
                            color: userResponse?.isCorrect == true
                                ? AppColors.success
                                : userResponse?.isCorrect == false
                                    ? AppColors.error
                                    : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Explanation
                    if (question.explanation != null && (userResponse?.isCorrect == false || userResponse == null)) ...[
                      const SizedBox(height: AppDimensions.paddingL),
                      const Text(
                        'Explanation:',
                        style: AppTextStyles.subtitle2,
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        question.explanation!,
                        style: AppTextStyles.bodyText2,
                      ),
                    ] else if (userResponse?.isCorrect == false || userResponse == null) ...[
                      const SizedBox(height: AppDimensions.paddingL),
                      const Text(
                        'Explanation:',
                        style: AppTextStyles.subtitle2,
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      const Text(
                        'No explanation available for this question.',
                        style: AppTextStyles.bodyText2,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
