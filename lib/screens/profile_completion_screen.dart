import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/models.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _identityProofNumberController = TextEditingController();

  DateTime? _dateOfBirth;
  Gender? _selectedGender;
  String? _selectedIdentityProofType;
  File? _identityProofImage;
  bool _isLoading = false;
  String _errorMessage = '';

  final List<String> _identityProofTypes = [
    'Aadhaar Card',
    'PAN Card',
    'Passport',
    'Voter ID',
    'Driving License',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _identityProofNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!_authService.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _phoneController.text = user.phone ?? '';
        _addressController.text = user.address ?? '';
        _cityController.text = user.city ?? '';
        _stateController.text = user.state ?? '';
        _countryController.text = user.country ?? '';
        _pincodeController.text = user.pincode ?? '';
        _dateOfBirth = user.dateOfBirth;
        _selectedGender = user.gender;
        _selectedIdentityProofType = user.identityProofType;
        _identityProofNumberController.text = user.identityProofNumber ?? '';

        // Load identity proof image if available
        if (user.identityProofImagePath != null && user.identityProofImagePath!.isNotEmpty) {
          _identityProofImage = File(user.identityProofImagePath!);
        }
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _identityProofImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<String> _saveImageToAppDirectory(File image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'identity_proof_${_authService.currentUserId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedImage = await image.copy('${appDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      throw Exception('Failed to save image: ${e.toString()}');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateOfBirth == null) {
      setState(() {
        _errorMessage = 'Please select your date of birth';
      });
      return;
    }

    if (_selectedGender == null) {
      setState(() {
        _errorMessage = 'Please select your gender';
      });
      return;
    }

    if (_selectedIdentityProofType == null) {
      setState(() {
        _errorMessage = 'Please select an identity proof type';
      });
      return;
    }

    if (_identityProofImage == null) {
      setState(() {
        _errorMessage = 'Please upload your identity proof';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Save the image to app directory
      final imagePath = await _saveImageToAppDirectory(_identityProofImage!);

      // Update user profile
      final user = _authService.currentUser!;
      final updatedUser = await _authService.updateProfile(
        user.name,
        user.email ?? '',
        _authService.currentUserCategoryId ?? 1,
      );

      // Update user with additional details
      final userWithDetails = await _authService.updateProfile(
        updatedUser.name,
        updatedUser.email ?? '',
        _authService.currentUserCategoryId ?? 1,
        phone: _phoneController.text,
        dateOfBirth: _dateOfBirth,
        gender: _selectedGender,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        pincode: _pincodeController.text,
      );

      // Update identity proof
      await _authService.updateIdentityProof(
        _selectedIdentityProofType!,
        _identityProofNumberController.text,
        imagePath,
      );

      // Mark profile as complete
      await _authService.updateProfileCompletionStatus(true);

      // Navigate to home screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save profile: ${e.toString()}';
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
        title: const Text('Complete Your Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Saving profile...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please complete your profile to continue',
                      style: AppTextStyles.headline3,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    const Text(
                      'We need this information to provide you with personalized test recommendations and to verify your identity.',
                      style: AppTextStyles.bodyText1,
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Personal Information Section
                    const SectionHeader(title: 'Personal Information'),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Phone Number
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Date of Birth
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _dateOfBirth ?? DateTime(2000),
                          firstDate: DateTime(1950),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != _dateOfBirth) {
                          setState(() {
                            _dateOfBirth = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _dateOfBirth == null
                              ? 'Select Date of Birth'
                              : DateFormat('dd/MM/yyyy').format(_dateOfBirth!),
                          style: _dateOfBirth == null
                              ? AppTextStyles.bodyText1.copyWith(color: AppColors.textSecondary)
                              : AppTextStyles.bodyText1,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Gender
                    DropdownButtonFormField<Gender>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: Gender.values.map((gender) {
                        return DropdownMenuItem<Gender>(
                          value: gender,
                          child: Text(gender.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Address Section
                    const SectionHeader(title: 'Address Information'),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // City
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // State
                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        prefixIcon: Icon(Icons.map),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your state';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Country
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        prefixIcon: Icon(Icons.public),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Pincode
                    TextFormField(
                      controller: _pincodeController,
                      decoration: const InputDecoration(
                        labelText: 'Pincode',
                        prefixIcon: Icon(Icons.pin_drop),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your pincode';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Identity Proof Section
                    const SectionHeader(title: 'Identity Verification'),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Identity Proof Type
                    DropdownButtonFormField<String>(
                      value: _selectedIdentityProofType,
                      decoration: const InputDecoration(
                        labelText: 'Identity Proof Type',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      items: _identityProofTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedIdentityProofType = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Identity Proof Number
                    TextFormField(
                      controller: _identityProofNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Identity Proof Number',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your identity proof number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Identity Proof Image
                    const Text(
                      'Upload Identity Proof',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: AppDimensions.paddingS),
                    InkWell(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: _identityProofImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                child: Image.file(
                                  _identityProofImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_a_photo,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(height: AppDimensions.paddingM),
                                  Text(
                                    'Tap to upload identity proof',
                                    style: AppTextStyles.bodyText1,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Error message
                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
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
                        text: 'Save Profile',
                        onPressed: _saveProfile,
                        icon: Icons.save,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                  ],
                ),
              ),
            ),
    );
  }
}
