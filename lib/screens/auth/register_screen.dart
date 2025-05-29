import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'login_screen.dart';
import '../home_screen.dart';
import '../profile_completion_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int _selectedCategoryId = 1; // Default to 10th Fail
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  EducationCategory _getEducationCategory(int categoryId) {
    switch (categoryId) {
      case 1:
        return EducationCategory.tenthFail;
      case 2:
        return EducationCategory.tenthPass;
      case 3:
        return EducationCategory.twelfthFail;
      case 4:
        return EducationCategory.twelfthPass;
      case 5:
        return EducationCategory.graduateScience;
      case 6:
        return EducationCategory.graduateCommerce;
      case 7:
        return EducationCategory.graduateArts;
      case 8:
        return EducationCategory.engineeringCse;
      case 9:
        return EducationCategory.postgraduate;
      default:
        return EducationCategory.tenthPass;
    }
  }

  Future<void> _register() async {
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
      final password = _passwordController.text.trim();

      // Register user as student (default registration type)
      final authService = MultiUserAuthService();
      await authService.registerStudent(
        fullName: name,
        email: email,
        phone: '0000000000', // Default phone for quick registration
        dateOfBirth: DateTime(2000, 1, 1), // Default date
        gender: Gender.other,
        educationCategory: _getEducationCategory(_selectedCategoryId),
        institutionName: 'Not specified',
        academicYear: '2023-24',
        parentContact: '0000000000',
        address: 'Not specified',
        state: 'Not specified',
        district: 'Not specified',
        city: 'Not specified',
        pincode: '000000',
        preferredLanguage: Language.english,
        identityType: IdentityProofType.aadhaar,
        identityNumber: '0000-0000-0000',
        password: password,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration successful! Welcome $name'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to home screen on successful registration
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      // Show error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo
                  const Icon(
                    Icons.psychology,
                    size: 80,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),

                  // App name
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.headline2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

                  // Register title
                  Text(
                    AppStrings.register,
                    style: AppTextStyles.headline3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

                  // Name field
                  CustomTextField(
                    label: AppStrings.name,
                    hint: 'Enter your full name',
                    controller: _nameController,
                    validator: Validators.validateName,
                    prefixIcon: const Icon(Icons.person_outline),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Email field
                  CustomTextField(
                    label: AppStrings.email,
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Password field
                  CustomTextField(
                    label: AppStrings.password,
                    hint: 'Create a password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                    textInputAction: TextInputAction.next,
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
                          color: AppColors.surface,
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
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

                  // Register button
                  CustomButton(
                    text: AppStrings.register,
                    onPressed: _register,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyHaveAccount,
                        style: AppTextStyles.bodyText2,
                      ),
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: const Text(AppStrings.login),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
