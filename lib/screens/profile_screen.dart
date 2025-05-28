import 'package:flutter/material.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  int _selectedCategoryId = 1; // Default to 10th Fail
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current user data from auth service
      final authService = AuthService();
      await authService.initialize();

      if (!authService.isLoggedIn) {
        // If not logged in, navigate to login screen
        if (!mounted) return;
        _logout();
        return;
      }

      // Get user from database
      final userRepository = UserRepository();
      final user = await userRepository.getUserById(authService.currentUserId!);

      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email ?? '';
        _selectedCategoryId = authService.currentUserCategoryId ?? 1;
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load profile: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get user input
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      // Update user profile
      final authService = AuthService();
      await authService.updateProfile(name, email, _selectedCategoryId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      // Logout user
      final authService = AuthService();
      await authService.logout();

      // Navigate to login screen
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to logout: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading profile...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile picture
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person,
                        size: 80,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Name field
                    CustomTextField(
                      label: AppStrings.name,
                      controller: _nameController,
                      validator: Validators.validateName,
                      enabled: _isEditing,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Email field
                    CustomTextField(
                      label: AppStrings.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      enabled: _isEditing,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Education level dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.educationLevel,
                          style: AppTextStyles.subtitle2,
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingM,
                            vertical: AppDimensions.paddingS,
                          ),
                          decoration: BoxDecoration(
                            color: _isEditing ? AppColors.surface : AppColors.background,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedCategoryId,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              items: [
                                DropdownMenuItem<int>(value: 1, child: Text('10th Fail')),
                                DropdownMenuItem<int>(value: 2, child: Text('10th Pass')),
                                DropdownMenuItem<int>(value: 3, child: Text('12th Fail')),
                                DropdownMenuItem<int>(value: 4, child: Text('12th Pass')),
                                DropdownMenuItem<int>(value: 5, child: Text('Graduate (Science)')),
                                DropdownMenuItem<int>(value: 6, child: Text('Graduate (Commerce)')),
                                DropdownMenuItem<int>(value: 7, child: Text('Graduate (Arts)')),
                                DropdownMenuItem<int>(value: 8, child: Text('Graduate (BTech)')),
                                DropdownMenuItem<int>(value: 9, child: Text('Postgraduate')),
                              ],
                              onChanged: _isEditing
                                  ? (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedCategoryId = value;
                                        });
                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingXL),

                    // Action buttons
                    if (_isEditing) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: AppStrings.cancel,
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _loadUserData(); // Reset to original data
                                });
                              },
                              type: ButtonType.outline,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: CustomButton(
                              text: AppStrings.save,
                              onPressed: _updateProfile,
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      CustomButton(
                        text: 'Logout',
                        onPressed: () => _logout(),
                        type: ButtonType.outline,
                        icon: Icons.logout,
                        isFullWidth: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
