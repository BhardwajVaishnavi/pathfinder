import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'register_screen.dart';
import '../home_screen.dart';
import '../profile_completion_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get email and password from controllers
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Login user
      final authService = AuthService();
      await authService.login(email, password);

      if (!mounted) return;

      // Check if user profile is complete
      if (!authService.isUserProfileComplete()) {
        // Navigate to profile completion screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ProfileCompletionScreen()),
        );
      } else {
        // Navigate to home screen on successful login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Show error message
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.toString()}'),
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

                  // Login title
                  Text(
                    AppStrings.login,
                    style: AppTextStyles.headline3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

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
                    hint: 'Enter your password',
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
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: const Text(AppStrings.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Login button
                  CustomButton(
                    text: AppStrings.login,
                    onPressed: _login,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: AppDimensions.paddingXL),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.dontHaveAccount,
                        style: AppTextStyles.bodyText2,
                      ),
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: const Text(AppStrings.register),
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
