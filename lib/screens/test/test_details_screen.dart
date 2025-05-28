import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../profile_completion_screen.dart';
import 'test_instructions_screen.dart';

class TestDetailsScreen extends StatefulWidget {
  final TestSet testSet;

  const TestDetailsScreen({
    Key? key,
    required this.testSet,
  }) : super(key: key);

  @override
  State<TestDetailsScreen> createState() => _TestDetailsScreenState();
}

class _TestDetailsScreenState extends State<TestDetailsScreen> {
  final TestService _testService = TestService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  List<Question> _questions = [];
  Category? _category;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  void _checkProfileCompletion() {
    // Check if user profile is complete
    if (!_authService.isUserProfileComplete()) {
      // Show a dialog to inform the user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Profile Incomplete'),
            content: const Text(
              'You need to complete your profile and upload identity proof before taking tests. '
              'This is required for verification purposes.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileCompletionScreen(),
                    ),
                  );
                },
                child: const Text('Complete Profile'),
              ),
            ],
          ),
        );
      });
    } else {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load questions for the test set using the test service
      _questions = await _testService.getQuestionsForTestSet(widget.testSet.id);

      // Load category for the test set
      final categories = await _testService.getCategories();
      _category = categories.firstWhere(
        (c) => c.id == widget.testSet.categoryId,
        orElse: () => Category(id: 0, name: 'Unknown'),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load test details: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToInstructions() {
    // Check if user profile is complete before navigating
    if (!_authService.isUserProfileComplete()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Profile Incomplete'),
          content: const Text(
            'You need to complete your profile and upload identity proof before taking tests. '
            'This is required for verification purposes.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProfileCompletionScreen(),
                  ),
                );
              },
              child: const Text('Complete Profile'),
            ),
          ],
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TestInstructionsScreen(
            testSet: widget.testSet,
            questions: _questions,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Test Details',
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading test details...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadData,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Test header
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.testSet.title,
                              style: AppTextStyles.headline3,
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                            if (widget.testSet.description != null) ...[
                              Text(
                                widget.testSet.description!,
                                style: AppTextStyles.bodyText1,
                              ),
                              const SizedBox(height: AppDimensions.paddingM),
                            ],
                            Wrap(
                              spacing: AppDimensions.paddingM,
                              runSpacing: AppDimensions.paddingS,
                              children: [
                                if (_category != null)
                                  _buildInfoChip(
                                    'Category',
                                    _category!.name,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // Test information
                      const Text(
                        'Test Information',
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      _buildInfoRow('Number of Questions', '${_questions.length}'),
                      if (widget.testSet.timeLimit != null)
                        _buildInfoRow('Time Limit', '${widget.testSet.timeLimit} minutes'),
                      if (widget.testSet.passingScore != null)
                        _buildInfoRow('Passing Score', '${widget.testSet.passingScore}%'),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // Question preview
                      const Text(
                        'Question Preview',
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      if (_questions.isNotEmpty) ...[
                        _buildQuestionPreview(_questions.first),
                      ] else ...[
                        const Text(
                          'No questions available for this test',
                          style: AppTextStyles.bodyText1,
                        ),
                      ],
                      const SizedBox(height: AppDimensions.paddingXL),

                      // Start test button
                      CustomButton(
                        text: AppStrings.startTest,
                        onPressed: _questions.isNotEmpty ? () => _navigateToInstructions() : () {},
                        isFullWidth: true,
                        icon: Icons.play_arrow,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildQuestionPreview(Question question) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sample Question',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              question.questionText,
              style: AppTextStyles.bodyText1,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            const Text(
              'Options:',
              style: AppTextStyles.subtitle2,
            ),
            const SizedBox(height: AppDimensions.paddingS),
            if (question.optionA != null)
              _buildOptionItem('A', question.optionA!),
            if (question.optionB != null)
              _buildOptionItem('B', question.optionB!),
            if (question.optionC != null)
              _buildOptionItem('C', question.optionC!),
            if (question.optionD != null)
              _buildOptionItem('D', question.optionD!),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(String letter, String text) {
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              letter,
              style: AppTextStyles.bodyText2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyText2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodyText2,
          ),
          Text(
            value,
            style: AppTextStyles.bodyText2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            value,
            style: AppTextStyles.bodyText1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeInfo(
    String title,
    String description,
    IconData icon,
    int count,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Expanded(
                child: Text(
                  '$title ($count questions)',
                  style: AppTextStyles.subtitle2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Text(
              description,
              style: AppTextStyles.bodyText2,
            ),
          ),
        ],
      ),
    );
  }
}
