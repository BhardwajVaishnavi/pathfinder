import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart'; // Removed for build
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/multi_user_auth_service.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import '../profile_completion_screen.dart';
import '../home_screen.dart';
import 'login_screen.dart';

class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Controllers for all required fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _institutionController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _parentContactController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _identityNumberController = TextEditingController();

  // Selected values
  DateTime? _dateOfBirth;
  Gender _selectedGender = Gender.male;
  EducationCategory _selectedEducationCategory = EducationCategory.tenthPass;
  Language _selectedLanguage = Language.english;
  String _selectedIdentityType = 'Aadhaar Card';
  String? _identityProofImagePath; // Changed from XFile for build

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _identityTypes = [
    'Aadhaar Card',
    'PAN Card',
    'Passport',
    'Voter ID',
    'Driving License',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _institutionController.dispose();
    _academicYearController.dispose();
    _parentContactController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _identityNumberController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _register();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _validatePersonalInfo();
      case 1:
        return _validateEducationInfo();
      case 2:
        return _validateIdentityInfo();
      default:
        return false;
    }
  }

  bool _validatePersonalInfo() {
    if (_fullNameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (_emailController.text.trim().isEmpty || !_isValidEmail(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return false;
    }
    if (_phoneController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_dateOfBirth == null) {
      _showError('Please select your date of birth');
      return false;
    }
    if (_passwordController.text.trim().length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    return true;
  }

  bool _validateEducationInfo() {
    if (_institutionController.text.trim().isEmpty) {
      _showError('Please enter your institution name');
      return false;
    }
    if (_academicYearController.text.trim().isEmpty) {
      _showError('Please enter your academic year');
      return false;
    }
    if (_parentContactController.text.trim().isEmpty) {
      _showError('Please enter parent/guardian contact');
      return false;
    }
    return true;
  }

  bool _validateIdentityInfo() {
    if (_addressController.text.trim().isEmpty) {
      _showError('Please enter your address');
      return false;
    }
    if (_stateController.text.trim().isEmpty) {
      _showError('Please enter your state');
      return false;
    }
    if (_districtController.text.trim().isEmpty) {
      _showError('Please enter your district');
      return false;
    }
    if (_cityController.text.trim().isEmpty) {
      _showError('Please enter your city');
      return false;
    }
    if (_pincodeController.text.trim().isEmpty) {
      _showError('Please enter your pincode');
      return false;
    }
    if (_identityNumberController.text.trim().isEmpty) {
      _showError('Please enter your identity proof number');
      return false;
    }
    if (_identityProofImagePath == null) {
      _showError('Please upload your identity proof image');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _pickIdentityImage() async {
    // Simplified for build - just set a dummy path
    setState(() {
      _identityProofImagePath = 'dummy_image_path.jpg';
    });
    _showError('Image picker temporarily disabled for build');
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _register() async {
    if (!_validateCurrentPage()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = MultiUserAuthService();

      // Register student with all collected data
      final user = await authService.registerStudent(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _dateOfBirth!,
        gender: _selectedGender,
        password: _passwordController.text.trim(),
        educationCategory: _selectedEducationCategory,
        institutionName: _institutionController.text.trim(),
        academicYear: _academicYearController.text.trim(),
        parentContact: _parentContactController.text.trim(),
        preferredLanguage: _selectedLanguage,
        address: _addressController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        identityType: _selectedIdentityType,
        identityNumber: _identityNumberController.text.trim(),
        identityProofImagePath: _identityProofImagePath!,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Welcome to PathfinderAI!'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 3),
        ),
      );

      // Navigate to home screen since profile is complete
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
        title: const Text('Student Registration'),
        leading: _currentPage > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _previousPage,
            )
          : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / 3,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildPersonalInfoPage(),
                _buildEducationInfoPage(),
                _buildIdentityInfoPage(),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: CustomButton(
                    text: _currentPage == 2 ? 'Register' : 'Next',
                    onPressed: _nextPage,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Full Name
            CustomTextField(
              label: 'Full Name *',
              hint: 'Enter your full name',
              controller: _fullNameController,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Email
            CustomTextField(
              label: 'Email Address *',
              hint: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Phone
            CustomTextField(
              label: 'Phone Number *',
              hint: 'Enter your phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Date of Birth
            GestureDetector(
              onTap: _selectDateOfBirth,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined),
                    const SizedBox(width: AppDimensions.paddingM),
                    Text(
                      _dateOfBirth != null
                        ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                        : 'Select Date of Birth *',
                      style: _dateOfBirth != null
                        ? AppTextStyles.bodyText1
                        : AppTextStyles.bodyText1.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Gender
            Text('Gender *', style: AppTextStyles.subtitle2),
            const SizedBox(height: AppDimensions.paddingS),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<Gender>(
                    title: const Text('Male'),
                    value: Gender.male,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<Gender>(
                    title: const Text('Female'),
                    value: Gender.female,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingL),

            // Password
            CustomTextField(
              label: 'Password *',
              hint: 'Create a password',
              controller: _passwordController,
              obscureText: _obscurePassword,
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
            const SizedBox(height: AppDimensions.paddingL),

            // Confirm Password
            CustomTextField(
              label: 'Confirm Password *',
              hint: 'Confirm your password',
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education Information',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Education Category
          Text('Education Category *', style: AppTextStyles.subtitle2),
          const SizedBox(height: AppDimensions.paddingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<EducationCategory>(
                value: _selectedEducationCategory,
                isExpanded: true,
                items: EducationCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEducationCategory = value!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Current Institution
          CustomTextField(
            label: 'Current Institution Name *',
            hint: 'Enter your school/college name',
            controller: _institutionController,
            prefixIcon: const Icon(Icons.school_outlined),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Academic Year
          CustomTextField(
            label: 'Academic Year/Semester *',
            hint: 'e.g., 2023-24, 3rd Semester',
            controller: _academicYearController,
            prefixIcon: const Icon(Icons.calendar_view_month_outlined),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Parent/Guardian Contact
          CustomTextField(
            label: 'Parent/Guardian Contact *',
            hint: 'Enter parent/guardian phone number',
            controller: _parentContactController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.contact_phone_outlined),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Preferred Language
          Text('Preferred Language *', style: AppTextStyles.subtitle2),
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
        ],
      ),
    );
  }

  Widget _buildIdentityInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address & Identity Verification',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Address
          CustomTextField(
            label: 'Address *',
            hint: 'Enter your complete address',
            controller: _addressController,
            maxLines: 3,
            prefixIcon: const Icon(Icons.home_outlined),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // State
          CustomTextField(
            label: 'State *',
            hint: 'Enter your state',
            controller: _stateController,
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // District
          CustomTextField(
            label: 'District *',
            hint: 'Enter your district',
            controller: _districtController,
            prefixIcon: const Icon(Icons.location_city_outlined),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // City
          CustomTextField(
            label: 'City *',
            hint: 'Enter your city',
            controller: _cityController,
            prefixIcon: const Icon(Icons.location_city),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Pincode
          CustomTextField(
            label: 'Pincode *',
            hint: 'Enter your pincode',
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.pin_drop_outlined),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Identity Proof Type
          Text('Identity Proof Type *', style: AppTextStyles.subtitle2),
          const SizedBox(height: AppDimensions.paddingS),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedIdentityType,
                isExpanded: true,
                items: _identityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIdentityType = value!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Identity Number
          CustomTextField(
            label: 'Identity Proof Number *',
            hint: 'Enter your ${_selectedIdentityType.toLowerCase()} number',
            controller: _identityNumberController,
            prefixIcon: const Icon(Icons.credit_card_outlined),
          ),
          const SizedBox(height: AppDimensions.paddingL),

          // Identity Proof Image
          Text('Upload Identity Proof *', style: AppTextStyles.subtitle2),
          const SizedBox(height: AppDimensions.paddingS),
          GestureDetector(
            onTap: _pickIdentityImage,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: _identityProofImagePath != null
                ? Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.success, size: 32),
                            const SizedBox(height: AppDimensions.paddingS),
                            Text(
                              'Image Selected',
                              style: AppTextStyles.bodyText2.copyWith(color: AppColors.success),
                            ),
                            Text(
                              'Tap to change',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 32, color: AppColors.textSecondary),
                        SizedBox(height: AppDimensions.paddingS),
                        Text(
                          'Tap to upload identity proof',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Text(
                          'JPG, PNG (Max 5MB)',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
