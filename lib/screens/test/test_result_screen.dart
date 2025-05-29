import 'package:flutter/material.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart'; // Removed for build
// import 'package:percent_indicator/linear_percent_indicator.dart'; // Removed for build
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../home_screen.dart';
import 'test_analysis_screen.dart';
import 'test_session_screen.dart';

class TestResultScreen extends StatefulWidget {
  final TestSet testSet;
  final List<Question> questions;
  final List<UserResponse> userResponses;
  final Report report;

  const TestResultScreen({
    Key? key,
    required this.testSet,
    required this.questions,
    required this.userResponses,
    required this.report,
  }) : super(key: key);

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen> {
  final TestCompletionService _completionService = TestCompletionService();
  final PDFReportService _pdfService = PDFReportService();
  final TestService _testService = TestService();

  bool _isCheckingNextTest = false;
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    _markTestCompleted();
    // Don't immediately check for next test - let user see results first
  }

  /// Mark the current test as completed
  Future<void> _markTestCompleted() async {
    final testType = _completionService.getTestTypeFromTestSet(widget.testSet);
    await _completionService.markTestCompleted(testType);
  }

  /// Check if there's a next test to take and show option
  Future<void> _checkForNextTest() async {
    setState(() {
      _isCheckingNextTest = true;
    });

    try {
      final nextTest = await _completionService.getNextPendingTest();
      if (nextTest != null && mounted) {
        // Show dialog asking if user wants to take the next test
        _showNextTestDialog(nextTest);
      } else if (mounted) {
        // All tests completed
        _showAllTestsCompletedDialog();
      }
    } catch (e) {
      print('Error checking for next test: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingNextTest = false;
        });
      }
    }
  }

  /// Show dialog when all tests are completed
  void _showAllTestsCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(
          'Congratulations! 🎉',
          style: AppTextStyles.headline3.copyWith(color: AppColors.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have successfully completed all available tests!',
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Your comprehensive assessment is now complete. You can:',
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Text(
              '• Download your detailed PDF reports',
              style: AppTextStyles.bodyText2.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '• View detailed analysis of your performance',
              style: AppTextStyles.bodyText2.copyWith(color: AppColors.textSecondary),
            ),
            Text(
              '• Share your results with counselors',
              style: AppTextStyles.bodyText2.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
            ),
            child: Text(
              'Great!',
              style: TextStyle(color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }

  /// Show dialog for next test option
  void _showNextTestDialog(TestSet nextTest) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(
          'Next Test Available',
          style: AppTextStyles.headline3.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Great job completing the ${widget.testSet.title}!',
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Your next test is ready:',
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              nextTest.title,
              style: AppTextStyles.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            if (nextTest.description != null) ...[
              const SizedBox(height: 8),
              Text(
                nextTest.description!,
                style: AppTextStyles.bodyText2.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Would you like to start it now?',
              style: AppTextStyles.bodyText1.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Later',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startNextTest(nextTest);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
            ),
            child: Text(
              'Start Now',
              style: TextStyle(color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }

  /// Start the next test
  Future<void> _startNextTest(TestSet nextTest) async {
    try {
      final questions = await _testService.getQuestionsForTestSet(nextTest.id);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TestSessionScreen(
              testSet: nextTest,
              questions: questions,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting next test: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate and download PDF report
  Future<void> _downloadPDFReport() async {
    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      final pdfBytes = await _pdfService.generateTestReport(
        testSet: widget.testSet,
        report: widget.report,
        questions: widget.questions,
        userResponses: widget.userResponses,
      );

      final fileName = '${widget.testSet.title.replaceAll(' ', '_')}_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await _pdfService.downloadPDFReport(pdfBytes, fileName);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📄 PDF Report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _navigateToAnalysis(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TestAnalysisScreen(
          testSet: widget.testSet,
          questions: widget.questions,
          userResponses: widget.userResponses,
          report: widget.report,
        ),
      ),
    );
  }

  String _getResultMessage() {
    if (widget.report.percentage != null) {
      if (widget.report.percentage! >= 90) {
        return 'Excellent! You have demonstrated exceptional understanding of the subject matter.';
      } else if (widget.report.percentage! >= 80) {
        return 'Great job! You have a strong grasp of the concepts.';
      } else if (widget.report.percentage! >= 70) {
        return 'Good work! You have a solid understanding of most concepts.';
      } else if (widget.report.percentage! >= 60) {
        return 'You passed! There are some areas where you can improve.';
      } else {
        return 'You need more practice. Review the concepts and try again.';
      }
    } else {
      return 'Test completed. Review your answers to improve.';
    }
  }

  Color _getResultColor() {
    if (widget.report.percentage != null) {
      if (widget.report.percentage! >= 70) {
        return AppColors.success;
      } else if (widget.report.percentage! >= 60) {
        return AppColors.warning;
      } else {
        return AppColors.error;
      }
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = _getResultColor();
    final totalQuestions = widget.report.totalQuestions ?? widget.questions.length;
    final correctAnswers = widget.report.correctAnswers ?? 0;
    final incorrectAnswers = widget.report.incorrectAnswers ?? 0;
    final skippedQuestions = totalQuestions - (correctAnswers + incorrectAnswers);

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.testResults,
        showBackButton: false,
        actions: [
          ShareButton(
            type: ShareType.testResult,
            data: {
              'report': widget.report,
              'testSet': widget.testSet,
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Test title
            Text(
              widget.testSet.title,
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Completed on ${widget.report.createdAt != null ? DateFormatter.formatDateTime(widget.report.createdAt!) : 'Unknown date'}',
              style: AppTextStyles.bodyText2.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Score circle - simplified for build
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: resultColor, width: 15),
                color: resultColor.withOpacity(0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(widget.report.percentage ?? 0).toStringAsFixed(1)}%',
                      style: AppTextStyles.headline1.copyWith(
                        color: resultColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score',
                      style: AppTextStyles.bodyText1.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Result message
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(color: resultColor),
              ),
              child: Text(
                _getResultMessage(),
                style: AppTextStyles.subtitle1.copyWith(
                  color: resultColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Score details
            Text(
              'Score Details',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            if (widget.report.score != null)
              _buildScoreDetail(
                'Score',
                '${widget.report.score} / 100',
              ),
            _buildScoreDetail(
              'Questions Answered',
              '${correctAnswers + incorrectAnswers} / $totalQuestions',
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Performance breakdown
            Text(
              'Performance Breakdown',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            _buildPerformanceBar(
              'Correct',
              correctAnswers,
              totalQuestions,
              AppColors.success,
            ),
            _buildPerformanceBar(
              'Incorrect',
              incorrectAnswers,
              totalQuestions,
              AppColors.error,
            ),
            _buildPerformanceBar(
              'Skipped',
              skippedQuestions,
              totalQuestions,
              AppColors.warning,
            ),
            const SizedBox(height: AppDimensions.paddingXL),

            // Action buttons
            Column(
              children: [
                // First row - Analysis and PDF Download
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'View Analysis',
                        onPressed: () => _navigateToAnalysis(context),
                        icon: Icons.analytics,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: CustomButton(
                        text: _isGeneratingPDF ? 'Generating...' : 'Download PDF',
                        onPressed: _isGeneratingPDF ? () {} : () => _downloadPDFReport(),
                        icon: _isGeneratingPDF ? Icons.hourglass_empty : Icons.picture_as_pdf,
                        type: ButtonType.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.paddingM),
                // Second row - Next Test and Home buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: _isCheckingNextTest ? 'Checking...' : 'Next Test',
                        onPressed: _isCheckingNextTest ? () {} : () => _checkForNextTest(),
                        icon: _isCheckingNextTest ? Icons.hourglass_empty : Icons.arrow_forward,
                        type: ButtonType.secondary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Expanded(
                      child: CustomButton(
                        text: 'Back to Home',
                        onPressed: () => _navigateToHome(context),
                        type: ButtonType.outline,
                        icon: Icons.home,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyText2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Text(
            value,
            style: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBar(
    String label,
    int value,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? value / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyText1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Text(
                '$value / $total (${(percentage * 100).toStringAsFixed(1)}%)',
                style: AppTextStyles.bodyText2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          Container(
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: color.withOpacity(0.2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
