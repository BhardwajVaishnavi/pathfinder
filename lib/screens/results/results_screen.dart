import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../test/test_result_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final TestService _testService = TestService();

  bool _isLoading = false;
  List<Report> _reports = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTestResults();
  }

  Future<void> _loadTestResults() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load reports using the test service
      _reports = await _testService.getUserReports();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load test results: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewTestResult(Report report) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get test set
      final testSets = await _testService.getTestSetsForCategory(1); // Default to category 1
      final testSet = testSets.firstWhere(
        (ts) => ts.id == report.testSetId,
        orElse: () => TestSet(
          id: report.testSetId,
          categoryId: 1, // Default to 10th Fail
          title: 'Test ${report.testSetId}',
          description: 'Description for test ${report.testSetId}',
          timeLimit: 60,
          passingScore: 70,
        ),
      );

      // Get questions
      final questions = await _testService.getQuestionsForTestSet(report.testSetId);

      // Generate user responses
      final userResponses = List.generate(
        (report.correctAnswers ?? 0) + (report.incorrectAnswers ?? 0),
        (index) {
          final isCorrect = index < (report.correctAnswers ?? 0);
          return UserResponse(
            id: index + 1,
            userId: report.userId,
            questionId: index < questions.length ? questions[index].id : index + 1,
            selectedOption: isCorrect ? questions[index % questions.length].correctOption : 'B',
            isCorrect: isCorrect,
            responseTime: 30,
            createdAt: report.createdAt,
          );
        },
      );

      // Navigate to test result screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TestResultScreen(
            testSet: testSet,
            questions: questions,
            userResponses: userResponses,
            report: report,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading results...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadTestResults,
                )
              : _reports.isEmpty
                  ? const Center(
                      child: Text(
                        'No test results found',
                        style: AppTextStyles.subtitle1,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      itemCount: _reports.length,
                      itemBuilder: (context, index) {
                        final report = _reports[index];
                        return _buildResultCard(report);
                      },
                    ),
    );
  }

  Widget _buildResultCard(Report report) {
    final resultColor = (report.percentage ?? 0) >= 70
        ? AppColors.success
        : (report.percentage ?? 0) >= 60
            ? AppColors.warning
            : AppColors.error;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () => _viewTestResult(report),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: resultColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${(report.percentage ?? 0).toStringAsFixed(0)}%',
                        style: AppTextStyles.subtitle1.copyWith(
                          color: resultColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test ${report.testSetId}', // TODO: Replace with actual test title
                          style: AppTextStyles.subtitle1,
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          'Completed on ${report.createdAt != null ? DateFormatter.formatDate(report.createdAt!) : 'Unknown date'}',
                          style: AppTextStyles.bodyText2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              LinearProgressIndicator(
                value: (report.percentage ?? 0) / 100,
                backgroundColor: resultColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(resultColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score: ${report.score ?? 0}/100',
                    style: AppTextStyles.bodyText2,
                  ),
                  const SizedBox(height: AppDimensions.paddingXS),
                  Text(
                    'Correct: ${report.correctAnswers ?? 0}/${report.totalQuestions ?? 0}',
                    style: AppTextStyles.bodyText2,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'View Details',
                    onPressed: () => _viewTestResult(report),
                    type: ButtonType.outline,
                    icon: Icons.visibility,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
