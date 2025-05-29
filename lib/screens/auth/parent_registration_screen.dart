import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../models/parent_user.dart';
import '../../services/multi_user_auth_service.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'login_screen.dart';

class ParentRegistrationScreen extends StatefulWidget {
  const ParentRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<ParentRegistrationScreen> createState() => _ParentRegistrationScreenState();
}

class _ParentRegistrationScreenState extends State<ParentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for all required fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _occupationController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Selected values
  RelationshipType _selectedRelationship = RelationshipType.father;
  Language _selectedLanguage = Language.english;

  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _occupationController.dispose();
    _studentIdController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = MultiUserAuthService();

      // Register parent with all collected data
      final parentUser = await authService.registerParent(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        occupation: _occupationController.text.trim(),
        relationshipType: _selectedRelationship,
        studentRegistrationId: _studentIdController.text.trim(),
        address: _addressController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        preferredLanguage: _selectedLanguage,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parent registration successful! Data saved to database.'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Registration failed: ${e.toString()}');
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
      appBar: AppBar(
        title: const Text('Parent Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parent/Guardian Information',
                style: AppTextStyles.headline3,
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Full Name
              CustomTextField(
                label: 'Full Name *',
                hint: 'Enter your full name',
                controller: _fullNameController,
                validator: Validators.validateName,
                prefixIcon: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Relationship to Student
              Text('Relationship to Student *', style: AppTextStyles.subtitle2),
              const SizedBox(height: AppDimensions.paddingS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RelationshipType>(
                    value: _selectedRelationship,
                    isExpanded: true,
                    items: RelationshipType.values.map((relationship) {
                      return DropdownMenuItem(
                        value: relationship,
                        child: Text(relationship.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedRelationship = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Email
              CustomTextField(
                label: 'Email Address *',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Phone
              CustomTextField(
                label: 'Phone Number *',
                hint: 'Enter your phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty == true ? 'Please enter your phone number' : null,
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Occupation
              CustomTextField(
                label: 'Occupation *',
                hint: 'Enter your occupation',
                controller: _occupationController,
                validator: (value) => value?.isEmpty == true ? 'Please enter your occupation' : null,
                prefixIcon: const Icon(Icons.work_outline),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Student Registration ID
              CustomTextField(
                label: 'Student Registration ID *',
                hint: 'Enter your child\'s registration ID',
                controller: _studentIdController,
                validator: (value) => value?.isEmpty == true ? 'Please enter student registration ID' : null,
                prefixIcon: const Icon(Icons.school_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Address
              CustomTextField(
                label: 'Address *',
                hint: 'Enter your complete address',
                controller: _addressController,
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Please enter your address' : null,
                prefixIcon: const Icon(Icons.home_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // State
              CustomTextField(
                label: 'State *',
                hint: 'Enter your state',
                controller: _stateController,
                validator: (value) => value?.isEmpty == true ? 'Please enter your state' : null,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // District
              CustomTextField(
                label: 'District *',
                hint: 'Enter your district',
                controller: _districtController,
                validator: (value) => value?.isEmpty == true ? 'Please enter your district' : null,
                prefixIcon: const Icon(Icons.location_city_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // City
              CustomTextField(
                label: 'City *',
                hint: 'Enter your city',
                controller: _cityController,
                validator: (value) => value?.isEmpty == true ? 'Please enter your city' : null,
                prefixIcon: const Icon(Icons.location_city),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Pincode
              CustomTextField(
                label: 'Pincode *',
                hint: 'Enter your pincode',
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Please enter your pincode' : null,
                prefixIcon: const Icon(Icons.pin_drop_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Preferred Language
              Text('Preferred Communication Language *', style: AppTextStyles.subtitle2),
              const SizedBox(height: AppDimensions.paddingS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Language>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    items: Language.values.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(language.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Password
              CustomTextField(
                label: 'Password *',
                hint: 'Create a password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: Validators.validatePassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // Register button
              CustomButton(
                text: 'Register as Parent',
                onPressed: _register,
                isLoading: _isLoading,
                isFullWidth: true,
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: AppTextStyles.bodyText2,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text('Login'),
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
