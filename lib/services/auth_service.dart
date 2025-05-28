import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class AuthService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userCategoryIdKey = 'user_category_id';
  static const String _userProfileCompleteKey = 'user_profile_complete';

  final UserRepository _userRepository = UserRepository();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Current user data
  int? _currentUserId;
  String? _currentUserName;
  String? _currentUserEmail;
  int? _currentUserCategoryId;
  bool _isProfileComplete = false;
  User? _currentUser;

  // Getters for current user data
  int? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  int? get currentUserCategoryId => _currentUserCategoryId;
  bool get isProfileComplete => _isProfileComplete;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUserId != null;

  // Initialize auth service
  Future<void> initialize() async {
    await _loadUserDataFromPrefs();
  }

  // Register a new user
  Future<User> register(String name, String email, String password, int categoryId) async {
    try {
      // Check if email is already registered
      final existingUser = await _userRepository.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email is already registered');
      }

      // Hash password
      final passwordHash = _hashPassword(password);

      // Create user in database
      final user = await _userRepository.createUser(
        name,
        email,
        null, // phone
        null, // dateOfBirth
        null, // gender
      );

      // Save user data to shared preferences
      await _saveUserDataToPrefs(user.id, user.name, user.email, categoryId);

      // Update current user data
      _currentUserId = user.id;
      _currentUserName = user.name;
      _currentUserEmail = user.email;
      _currentUserCategoryId = categoryId;

      return user;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Login user
  Future<User> login(String email, String password) async {
    try {
      // Get user by email
      final user = await _userRepository.getUserByEmail(email);
      if (user == null) {
        throw Exception('User not found');
      }

      // For demo purposes, we'll skip password verification
      // In a real app, you would verify the password hash

      // Save user data to shared preferences
      await _saveUserDataToPrefs(user.id, user.name, user.email, 1); // Default to category 1

      // Update current user data
      _currentUserId = user.id;
      _currentUserName = user.name;
      _currentUserEmail = user.email;
      _currentUserCategoryId = 1; // Default to category 1

      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userNameKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userCategoryIdKey);

      // Clear current user data
      _currentUserId = null;
      _currentUserName = null;
      _currentUserEmail = null;
      _currentUserCategoryId = null;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Update user profile
  Future<User> updateProfile(
    String name,
    String email,
    int categoryId, {
    String? phone,
    DateTime? dateOfBirth,
    Gender? gender,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
  }) async {
    try {
      if (_currentUserId == null) {
        throw Exception('User not logged in');
      }

      // Get current user
      final user = await _userRepository.getUserById(_currentUserId!);
      if (user == null) {
        throw Exception('User not found');
      }

      // Update user in database
      final updatedUser = await _userRepository.updateUser(
        user.copyWith(
          name: name,
          email: email,
          phone: phone ?? user.phone,
          dateOfBirth: dateOfBirth ?? user.dateOfBirth,
          gender: gender ?? user.gender,
          address: address ?? user.address,
          city: city ?? user.city,
          state: state ?? user.state,
          country: country ?? user.country,
          pincode: pincode ?? user.pincode,
        ),
      );

      // Save updated user data to shared preferences
      await _saveUserDataToPrefs(updatedUser.id, updatedUser.name, updatedUser.email, categoryId);

      // Update current user data
      _currentUserName = updatedUser.name;
      _currentUserEmail = updatedUser.email;
      _currentUserCategoryId = categoryId;
      _currentUser = updatedUser;

      return updatedUser;
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  // Load user data from shared preferences
  Future<void> _loadUserDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt(_userIdKey);
      final userName = prefs.getString(_userNameKey);
      final userEmail = prefs.getString(_userEmailKey);
      final userCategoryId = prefs.getInt(_userCategoryIdKey);
      final isProfileComplete = prefs.getBool(_userProfileCompleteKey) ?? false;

      if (userId != null && userName != null) {
        _currentUserId = userId;
        _currentUserName = userName;
        _currentUserEmail = userEmail;
        _currentUserCategoryId = userCategoryId;
        _isProfileComplete = isProfileComplete;

        // Load full user data
        _currentUser = await _userRepository.getUserById(userId);
      }
    } catch (e) {
      // Ignore errors and treat as not logged in
      _currentUserId = null;
      _currentUserName = null;
      _currentUserEmail = null;
      _currentUserCategoryId = null;
      _isProfileComplete = false;
      _currentUser = null;
    }
  }

  // Save user data to shared preferences
  Future<void> _saveUserDataToPrefs(int userId, String userName, String? userEmail, int categoryId, {bool isProfileComplete = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_userIdKey, userId);
      await prefs.setString(_userNameKey, userName);
      if (userEmail != null) {
        await prefs.setString(_userEmailKey, userEmail);
      }
      await prefs.setInt(_userCategoryIdKey, categoryId);
      await prefs.setBool(_userProfileCompleteKey, isProfileComplete);

      // Update current user data
      _isProfileComplete = isProfileComplete;
    } catch (e) {
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Update profile completion status
  Future<User> updateProfileCompletionStatus(bool isComplete) async {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }

    final user = await _userRepository.updateProfileCompletionStatus(
      _currentUserId!,
      isComplete,
    );

    // Update shared preferences
    await _saveUserDataToPrefs(
      user.id,
      user.name,
      user.email,
      _currentUserCategoryId ?? 1,
      isProfileComplete: isComplete,
    );

    // Update current user data
    _isProfileComplete = isComplete;
    _currentUser = user;

    return user;
  }

  // Update identity proof
  Future<User> updateIdentityProof(
    String proofType,
    String proofNumber,
    String imagePath,
  ) async {
    if (!isLoggedIn) {
      throw Exception('User not logged in');
    }

    final user = await _userRepository.updateIdentityProof(
      _currentUserId!,
      proofType,
      proofNumber,
      imagePath,
    );

    // Update current user data
    _currentUser = user;

    return user;
  }

  // Check if profile is complete
  bool isUserProfileComplete() {
    if (!isLoggedIn || _currentUser == null) {
      return false;
    }

    final user = _currentUser!;

    // Check if all required fields are filled
    return user.isProfileComplete &&
           user.phone != null && user.phone!.isNotEmpty &&
           user.dateOfBirth != null &&
           user.gender != null &&
           user.address != null && user.address!.isNotEmpty &&
           user.city != null && user.city!.isNotEmpty &&
           user.state != null && user.state!.isNotEmpty &&
           user.country != null && user.country!.isNotEmpty &&
           user.pincode != null && user.pincode!.isNotEmpty &&
           user.identityProofType != null && user.identityProofType!.isNotEmpty &&
           user.identityProofNumber != null && user.identityProofNumber!.isNotEmpty &&
           user.identityProofImagePath != null && user.identityProofImagePath!.isNotEmpty;
  }
}
