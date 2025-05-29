import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../models/teacher_user.dart';
import '../../services/multi_user_auth_service.dart';
import '../../utils/utils.dart';
import '../../widgets/widgets.dart';
import 'login_screen.dart';

class TeacherRegistrationScreen extends StatefulWidget {
  const TeacherRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<TeacherRegistrationScreen> createState() => _TeacherRegistrationScreenState();
}

class _TeacherRegistrationScreenState extends State<TeacherRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers for all required fields
  final _fullNameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _institutionNameController = TextEditingController();
  final _designationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _yearsOfExperienceController = TextEditingController();
  final _institutionAddressController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _passwordController = TextEditingController();

  // Selected values
  Language _selectedLanguage = Language.english;
  AdminAccessLevel _selectedAccessLevel = AdminAccessLevel.basic;
  List<String> _selectedSubjects = [];

  bool _obscurePassword = true;

  final List<String> _availableSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Hindi',
    'History',
    'Geography',
    'Economics',
    'Political Science',
    'Computer Science',
    'Psychology',
    'Sociology',
    'Philosophy',
    'Commerce',
    'Accountancy',
    'Business Studies',
    'Engineering',
    'Other',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _employeeIdController.dispose();
    _institutionNameController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _yearsOfExperienceController.dispose();
    _institutionAddressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _passwordController.dispose();
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

  void _showSubjectSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Subject Expertise'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: _availableSubjects.length,
                  itemBuilder: (context, index) {
                    final subject = _availableSubjects[index];
                    return CheckboxListTile(
                      title: Text(subject),
                      value: _selectedSubjects.contains(subject),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            _selectedSubjects.add(subject);
                          } else {
                            _selectedSubjects.remove(subject);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjects.isEmpty) {
      _showError('Please select at least one subject expertise');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = MultiUserAuthService();

      // Register teacher with all collected data
      final teacherUser = await authService.registerTeacher(
        fullName: _fullNameController.text.trim(),
        employeeId: _employeeIdController.text.trim(),
        institutionName: _institutionNameController.text.trim(),
        designation: _designationController.text.trim(),
        subjectExpertise: _selectedSubjects,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        yearsOfExperience: int.parse(_yearsOfExperienceController.text.trim()),
        institutionAddress: _institutionAddressController.text.trim(),
        state: _stateController.text.trim(),
        district: _districtController.text.trim(),
        city: _cityController.text.trim(),
        pincode: _pincodeController.text.trim(),
        accessLevel: _selectedAccessLevel,
        preferredLanguage: _selectedLanguage,
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teacher registration successful! Data saved to database.'),
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
        title: const Text('Teacher Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teacher Information',
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

              // Employee ID
              CustomTextField(
                label: 'Employee ID *',
                hint: 'Enter your employee ID',
                controller: _employeeIdController,
                validator: (value) => value?.isEmpty == true ? 'Please enter your employee ID' : null,
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Institution Name
              CustomTextField(
                label: 'Institution Name *',
                hint: 'Enter your institution name',
                controller: _institutionNameController,
                validator: (value) => value?.isEmpty == true ? 'Please enter institution name' : null,
                prefixIcon: const Icon(Icons.school_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Designation
              CustomTextField(
                label: 'Designation/Position *',
                hint: 'e.g., Assistant Professor, Teacher, HOD',
                controller: _designationController,
                validator: (value) => value?.isEmpty == true ? 'Please enter your designation' : null,
                prefixIcon: const Icon(Icons.work_outline),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Subject Expertise
              Text('Subject Expertise *', style: AppTextStyles.subtitle2),
              const SizedBox(height: AppDimensions.paddingS),
              GestureDetector(
                onTap: _showSubjectSelectionDialog,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.subject_outlined),
                      const SizedBox(width: AppDimensions.paddingM),
                      Expanded(
                        child: Text(
                          _selectedSubjects.isEmpty
                            ? 'Select your subject expertise'
                            : '${_selectedSubjects.length} subjects selected',
                          style: _selectedSubjects.isEmpty
                            ? AppTextStyles.bodyText1.copyWith(color: AppColors.textSecondary)
                            : AppTextStyles.bodyText1,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              if (_selectedSubjects.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingS),
                Wrap(
                  spacing: AppDimensions.paddingS,
                  children: _selectedSubjects.map((subject) {
                    return Chip(
                      label: Text(subject),
                      onDeleted: () {
                        setState(() {
                          _selectedSubjects.remove(subject);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
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

              // Years of Experience
              CustomTextField(
                label: 'Years of Experience *',
                hint: 'Enter years of teaching experience',
                controller: _yearsOfExperienceController,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Please enter years of experience' : null,
                prefixIcon: const Icon(Icons.timeline_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Institution Address
              CustomTextField(
                label: 'Institution Address *',
                hint: 'Enter institution address',
                controller: _institutionAddressController,
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Please enter institution address' : null,
                prefixIcon: const Icon(Icons.location_on_outlined),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // State
              CustomTextField(
                label: 'State *',
                hint: 'Enter your state',
                controller: _stateController,
                validator: (value) => value?.isEmpty == true ? 'Please enter your state' : null,
                prefixIcon: const Icon(Icons.map_outlined),
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

              // Administrative Access Level
              Text('Administrative Access Level', style: AppTextStyles.subtitle2),
              const SizedBox(height: AppDimensions.paddingS),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<AdminAccessLevel>(
                    value: _selectedAccessLevel,
                    isExpanded: true,
                    items: AdminAccessLevel.values.map((level) {
                      return DropdownMenuItem(
                        value: level,
                        child: Text(level.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAccessLevel = value!;
                      });
                    },
                  ),
                ),
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
                text: 'Register as Teacher',
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
