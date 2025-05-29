import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../profile_completion_screen.dart';
import 'test_details_screen.dart';

class TestSetListScreen extends StatefulWidget {
  final Category category;

  const TestSetListScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<TestSetListScreen> createState() => _TestSetListScreenState();
}

class _TestSetListScreenState extends State<TestSetListScreen> {
  final TestService _testService = TestService();
  final MultiUserAuthService _authService = MultiUserAuthService();
  final TestCompletionService _completionService = TestCompletionService();

  bool _isLoading = false;
  List<TestSet> _testSets = [];
  String _errorMessage = '';
  Map<String, bool> _completionStatus = {};

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();
  }

  void _checkProfileCompletion() {
    // For test users, profile is already complete, so load test sets directly
    if (_authService.isLoggedIn && _authService.currentUser?.isProfileComplete == true) {
      _loadTestSets();
    } else {
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
    }
  }

  Future<void> _loadTestSets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load test sets for the selected category using the test service
      _testSets = await _testService.getTestSetsForCategory(widget.category.id);

      // Load completion status for each test
      _completionStatus = await _completionService.getTestCompletionStatus();

      print('📊 Test completion status: $_completionStatus');
      print('📝 Available test sets: ${_testSets.map((t) => t.title).toList()}');

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load tests: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToTestDetails(TestSet testSet) {
    // Check if test is already completed
    final testType = _completionService.getTestTypeFromTestSet(testSet);
    final isCompleted = _completionStatus[testType] ?? false;

    if (isCompleted) {
      // Show dialog that test is already completed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Test Already Completed'),
          content: Text(
            'You have already completed the ${testSet.title}. '
            'Each test can only be taken once to ensure fair assessment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // For test users, profile is already complete, so navigate directly
    if (_authService.isLoggedIn && _authService.currentUser?.isProfileComplete == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TestDetailsScreen(testSet: testSet),
        ),
      );
    } else {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading tests...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadTestSets,
                )
              : _testSets.isEmpty
                  ? const Center(
                      child: Text(
                        'No tests available for this category',
                        style: AppTextStyles.subtitle1,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      itemCount: _testSets.length,
                      itemBuilder: (context, index) {
                        final testSet = _testSets[index];
                        return _buildTestSetCard(testSet);
                      },
                    ),
    );
  }

  Widget _buildTestSetCard(TestSet testSet) {
    final testType = _completionService.getTestTypeFromTestSet(testSet);
    final isCompleted = _completionStatus[testType] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () => _navigateToTestDetails(testSet),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check_circle : Icons.assignment_outlined,
                      size: 32,
                      color: isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                testSet.title,
                                style: AppTextStyles.subtitle1,
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (testSet.timeLimit != null) ...[
                          const SizedBox(height: AppDimensions.paddingXS),
                          Text(
                            'Time Limit: ${testSet.timeLimit} minutes',
                            style: AppTextStyles.bodyText2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (testSet.description != null) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  testSet.description!,
                  style: AppTextStyles.bodyText1,
                ),
              ],
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (testSet.passingScore != null)
                    Text(
                      'Passing Score: ${testSet.passingScore}%',
                      style: AppTextStyles.bodyText2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  CustomButton(
                    text: isCompleted ? 'Completed' : 'Start Test',
                    onPressed: () => _navigateToTestDetails(testSet),
                    type: ButtonType.outline,
                    icon: isCompleted ? Icons.check : null,
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
