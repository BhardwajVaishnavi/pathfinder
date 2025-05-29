import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../models/parent_user.dart';
import '../models/teacher_user.dart';
import '../repositories/repositories.dart';
import 'neondb_service.dart';

class MultiUserAuthService {
  static const String _userIdKey = 'user_id';
  static const String _userTypeKey = 'user_type';
  static const String _userDataKey = 'user_data';

  final UserRepository _userRepository = UserRepository();
  final NeonDBService _dbService = NeonDBService();

  // Singleton pattern
  static final MultiUserAuthService _instance = MultiUserAuthService._internal();

  factory MultiUserAuthService() {
    return _instance;
  }

  MultiUserAuthService._internal();

  // Current user data
  int? _currentUserId;
  UserRole? _currentUserType;
  dynamic _currentUser; // Can be User, ParentUser, or TeacherUser

  // Getters
  int? get currentUserId => _currentUserId;
  UserRole? get currentUserType => _currentUserType;
  dynamic get currentUser => _currentUser;
  bool get isLoggedIn => _currentUserId != null;

  // Initialize service
  Future<void> initialize() async {
    try {
      await _dbService.initialize();
      await _loadUserDataFromPrefs();
      print('✅ MultiUserAuthService initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize MultiUserAuthService: $e');
      // Continue with local storage only if database fails
      await _loadUserDataFromPrefs();
    }
  }

  // Register Student
  Future<User> registerStudent({
    required String fullName,
    required String email,
    required String phone,
    required DateTime dateOfBirth,
    required Gender gender,
    required String password,
    required EducationCategory educationCategory,
    required String institutionName,
    required String academicYear,
    required String parentContact,
    required Language preferredLanguage,
    required String address,
    required String state,
    required String district,
    required String city,
    required String pincode,
    required String identityType,
    required String identityNumber,
    required XFile identityProofImage,
  }) async {
    try {
      // Check if email already exists in PostgreSQL
      final existingUser = await _dbService.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email is already registered');
      }

      // Hash password
      final passwordHash = _hashPassword(password);

      // Save identity proof image
      final imagePath = await _saveIdentityProofImage(identityProofImage, email);

      // Create complete user object
      final user = User(
        id: 0, // Will be set by database
        name: fullName,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        gender: gender,
        address: address,
        state: state,
        district: district,
        city: city,
        country: 'India',
        pincode: pincode,
        educationCategory: educationCategory,
        institutionName: institutionName,
        academicYear: academicYear,
        parentContact: parentContact,
        preferredLanguage: preferredLanguage,
        identityProofType: identityType,
        identityProofNumber: identityNumber,
        identityProofImagePath: imagePath,
        passwordHash: passwordHash,
        isProfileComplete: true,
        createdAt: DateTime.now(),
      );

      // Save to PostgreSQL database
      final savedUser = await _dbService.insertStudent(user);

      // Save to preferences for session management
      await _saveUserDataToPrefs(savedUser.id, UserRole.student, savedUser);

      // Update current user
      _currentUserId = savedUser.id;
      _currentUserType = UserRole.student;
      _currentUser = savedUser;

      print('✅ Student registered successfully in PostgreSQL: ${savedUser.email}');
      return savedUser;
    } catch (e) {
      print('❌ Student registration failed: $e');
      throw Exception('Student registration failed: ${e.toString()}');
    }
  }

  // Register Parent
  Future<ParentUser> registerParent({
    required String fullName,
    required String email,
    required String phone,
    required String occupation,
    required RelationshipType relationshipType,
    required String studentRegistrationId,
    required String address,
    required String state,
    required String district,
    required String city,
    required String pincode,
    required Language preferredLanguage,
    required String password,
  }) async {
    try {
      // Check if email already exists in PostgreSQL
      final existingUser = await _dbService.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email is already registered');
      }

      // Hash password
      final passwordHash = _hashPassword(password);

      // Create parent user
      final parentUser = ParentUser(
        id: 0, // Will be set by database
        name: fullName,
        email: email,
        phone: phone,
        occupation: occupation,
        relationshipType: relationshipType,
        studentRegistrationId: studentRegistrationId,
        address: address,
        state: state,
        district: district,
        city: city,
        pincode: pincode,
        preferredLanguage: preferredLanguage,
        passwordHash: passwordHash,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      // Save to PostgreSQL database
      final savedParent = await _dbService.insertParent(parentUser);

      // Save to preferences for session management
      await _saveUserDataToPrefs(savedParent.id, UserRole.parent, savedParent);

      // Update current user
      _currentUserId = savedParent.id;
      _currentUserType = UserRole.parent;
      _currentUser = savedParent;

      print('✅ Parent registered successfully in PostgreSQL: ${savedParent.email}');
      return savedParent;
    } catch (e) {
      print('❌ Parent registration failed: $e');
      throw Exception('Parent registration failed: ${e.toString()}');
    }
  }

  // Register Teacher
  Future<TeacherUser> registerTeacher({
    required String fullName,
    required String employeeId,
    required String institutionName,
    required String designation,
    required List<String> subjectExpertise,
    required String email,
    required String phone,
    required int yearsOfExperience,
    required String institutionAddress,
    required String state,
    required String district,
    required String city,
    required String pincode,
    required AdminAccessLevel accessLevel,
    required Language preferredLanguage,
    required String password,
  }) async {
    try {
      // Check if email already exists in PostgreSQL
      final existingUser = await _dbService.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('Email is already registered');
      }

      // Hash password
      final passwordHash = _hashPassword(password);

      // Create teacher user
      final teacherUser = TeacherUser(
        id: 0, // Will be set by database
        name: fullName,
        employeeId: employeeId,
        institutionName: institutionName,
        designation: designation,
        subjectExpertise: subjectExpertise,
        email: email,
        phone: phone,
        yearsOfExperience: yearsOfExperience,
        institutionAddress: institutionAddress,
        state: state,
        district: district,
        city: city,
        pincode: pincode,
        accessLevel: accessLevel,
        preferredLanguage: preferredLanguage,
        passwordHash: passwordHash,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      // Save to PostgreSQL database
      final savedTeacher = await _dbService.insertTeacher(teacherUser);

      // Save to preferences for session management
      await _saveUserDataToPrefs(savedTeacher.id, UserRole.teacher, savedTeacher);

      // Update current user
      _currentUserId = savedTeacher.id;
      _currentUserType = UserRole.teacher;
      _currentUser = savedTeacher;

      print('✅ Teacher registered successfully in PostgreSQL: ${savedTeacher.email}');
      return savedTeacher;
    } catch (e) {
      print('❌ Teacher registration failed: $e');
      throw Exception('Teacher registration failed: ${e.toString()}');
    }
  }

  // Login
  Future<dynamic> login(String email, String password) async {
    try {
      // Get user from PostgreSQL database
      final userResult = await _dbService.getUserByEmail(email);
      if (userResult == null) {
        throw Exception('User not found');
      }

      final userType = userResult['user_type'] as String;
      final userData = userResult['data'] as Map<String, dynamic>;

      // Verify password
      final passwordHash = _hashPassword(password);
      if (userData['password_hash'] != passwordHash) {
        throw Exception('Invalid password');
      }

      // Determine user role and create appropriate object
      UserRole role;
      dynamic user;

      switch (userType) {
        case 'student':
          role = UserRole.student;
          user = User.fromMap(userData);
          break;
        case 'parent':
          role = UserRole.parent;
          user = ParentUser.fromMap(userData);
          break;
        case 'teacher':
          role = UserRole.teacher;
          user = TeacherUser.fromMap(userData);
          break;
        default:
          throw Exception('Unknown user type: $userType');
      }

      // Save to preferences for session management
      await _saveUserDataToPrefs(user.id, role, user);

      // Update current user
      _currentUserId = user.id;
      _currentUserType = role;
      _currentUser = user;

      print('✅ User logged in successfully: ${user.email} (${userType})');
      return user;
    } catch (e) {
      print('❌ Login failed: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_userTypeKey);
      await prefs.remove(_userDataKey);

      _currentUserId = null;
      _currentUserType = null;
      _currentUser = null;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Get database statistics
  Future<Map<String, int>> getDatabaseStatistics() async {
    try {
      return _dbService.getStatistics();
    } catch (e) {
      print('❌ Failed to get database statistics: $e');
      return {
        'total_users': 0,
        'total_students': 0,
        'total_parents': 0,
        'total_teachers': 0,
      };
    }
  }

  // Private methods
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> _saveIdentityProofImage(XFile imageFile, String userEmail) async {
    try {
      // Create a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final fileName = '${userEmail}_identity_$timestamp.$extension';

      // For now, return the original path
      // In production, you would upload to cloud storage
      return imageFile.path;
    } catch (e) {
      throw Exception('Failed to save identity proof image: ${e.toString()}');
    }
  }

  Future<void> _saveUserDataToPrefs(int userId, UserRole userType, dynamic userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(_userIdKey, userId);
      await prefs.setString(_userTypeKey, userType.value);

      // Convert user data to JSON
      String userDataJson;
      if (userData is User) {
        userDataJson = jsonEncode(userData.toMap());
      } else if (userData is ParentUser) {
        userDataJson = jsonEncode(userData.toMap());
      } else if (userData is TeacherUser) {
        userDataJson = jsonEncode(userData.toMap());
      } else {
        throw Exception('Unknown user type');
      }

      await prefs.setString(_userDataKey, userDataJson);
    } catch (e) {
      throw Exception('Failed to save user data: ${e.toString()}');
    }
  }

  Future<void> _loadUserDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userId = prefs.getInt(_userIdKey);
      final userTypeString = prefs.getString(_userTypeKey);
      final userDataJson = prefs.getString(_userDataKey);

      if (userId != null && userTypeString != null && userDataJson != null) {
        _currentUserId = userId;
        _currentUserType = UserRoleExtension.fromString(userTypeString);

        final userDataMap = jsonDecode(userDataJson) as Map<String, dynamic>;

        switch (_currentUserType) {
          case UserRole.student:
            _currentUser = User.fromMap(userDataMap);
            break;
          case UserRole.parent:
            _currentUser = ParentUser.fromMap(userDataMap);
            break;
          case UserRole.teacher:
            _currentUser = TeacherUser.fromMap(userDataMap);
            break;
          default:
            _currentUser = null;
        }
      }
    } catch (e) {
      // If loading fails, treat as not logged in
      _currentUserId = null;
      _currentUserType = null;
      _currentUser = null;
    }
  }
}
