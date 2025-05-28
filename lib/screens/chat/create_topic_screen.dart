import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../achievements_screen.dart';

class CreateTopicScreen extends StatefulWidget {
  final List<Category> categories;
  final Function(ChatTopic) onTopicCreated;

  const CreateTopicScreen({
    Key? key,
    required this.categories,
    required this.onTopicCreated,
  }) : super(key: key);

  @override
  State<CreateTopicScreen> createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final ChatService _chatService = ChatService();
  final AchievementService _achievementService = AchievementService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int? _selectedCategoryId;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTopic() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      setState(() {
        _errorMessage = 'Please select a category';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final topic = await _chatService.createTopic(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategoryId!,
      );

      // Unlock achievement for creating a topic
      final achievement = await _achievementService.unlockAchievement('community_contributor');
      if (achievement != null) {
        // Show a snackbar to notify the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Achievement Unlocked: ${achievement.title}'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                );
              },
            ),
          ),
        );

        // Update badge progress
        await _achievementService.updateBadgeProgress('community_star', 1);
      }

      widget.onTopicCreated(topic);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create topic: ${e.toString()}';
      });
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
        title: const Text('Create Topic'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Creating topic...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start a new discussion',
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    const Text(
                      'Share your thoughts, ask questions, or discuss topics with the community.',
                      style: AppTextStyles.bodyText1,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Category dropdown
                    const Text(
                      'Category',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingM,
                        ),
                        hintText: 'Select a category',
                      ),
                      items: widget.categories.map((category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Title field
                    const Text(
                      'Title',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingM,
                        ),
                        hintText: 'Enter a title for your topic',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        if (value.trim().length < 5) {
                          return 'Title must be at least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Description field
                    const Text(
                      'Description',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingM,
                        ),
                        hintText: 'Enter a description for your topic',
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Error message
                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          border: Border.all(color: AppColors.error),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: AppTextStyles.bodyText2.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingL),
                    ],

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Create Topic',
                        onPressed: _createTopic,
                        icon: Icons.add,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
