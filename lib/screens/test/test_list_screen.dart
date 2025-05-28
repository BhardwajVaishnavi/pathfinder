import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../profile_completion_screen.dart';
import 'test_set_list_screen.dart';

class TestListScreen extends StatefulWidget {
  const TestListScreen({Key? key}) : super(key: key);

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final TestService _testService = TestService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  List<Category> _categories = [];
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
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load categories using the test service
      _categories = await _testService.getCategories();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load categories: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToTestSetList(Category category) {
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
          builder: (_) => TestSetListScreen(category: category),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education Categories'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading categories...')
          : _errorMessage.isNotEmpty
              ? ErrorMessage(
                  message: _errorMessage,
                  onRetry: _loadCategories,
                )
              : _categories.isEmpty
                  ? const Center(
                      child: Text(
                        'No categories available',
                        style: AppTextStyles.subtitle1,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return _buildCategoryCard(category);
                      },
                    ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: InkWell(
        onTap: () => _navigateToTestSetList(category),
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                    child: Icon(
                      _getCategoryIcon(category.icon),
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: AppTextStyles.subtitle1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (category.description != null) ...[
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  category.description!,
                  style: AppTextStyles.bodyText1,
                ),
              ],
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    text: 'View Tests',
                    onPressed: () => _navigateToTestSetList(category),
                    type: ButtonType.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'school':
        return Icons.school;
      case 'science':
        return Icons.science;
      case 'business':
        return Icons.business;
      case 'brush':
        return Icons.brush;
      case 'engineering':
        return Icons.engineering;
      default:
        return Icons.category;
    }
  }
}
