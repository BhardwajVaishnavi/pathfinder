import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

class EnhancedAuthService {
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _isLoggedInKey = 'is_logged_in';

  // Singleton pattern
  static final EnhancedAuthService _instance = EnhancedAuthService._internal();
  factory EnhancedAuthService() => _instance;
  EnhancedAuthService._internal();

  // Current user data
  int? _currentUserId;
  UserRole? _currentUserRole;
  String? _currentUserName;
  String? _currentUserEmail;
  bool _isLoggedIn = false;

  // User objects
  Student? _currentStudent;
  Parent? _currentParent;
  Teacher? _currentTeacher;
  Counselor? _currentCounselor;

  // Getters
  int? get currentUserId => _currentUserId;
  UserRole? get currentUserRole => _currentUserRole;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  bool get isLoggedIn => _isLoggedIn;
  
  Student? get currentStudent => _currentStudent;
  Parent? get currentParent => _currentParent;
  Teacher? get currentTeacher => _currentTeacher;
  Counselor? get currentCounselor => _currentCounselor;

  // Initialize auth service
  Future<void> initialize() async {
    await _loadUserDataFromPrefs();
  }

  // Student Registration
  Future<Student> registerStudent({
    required String fullName,
    required DateTime dateOfBirth,
    required Gender gender,
    required String email,
    required String phone,
    required String password,
    required EducationCategory educationCategory,
    required String currentInstitution,
    required String academicYear,
    required String parentGuardianContact,
    required Language preferredLanguage,
    required String address,
    required String state,
    required String district,
    required String city,
    required String pincode,
  }) async {
    try {
      // Check if email already exists
      if (await _emailExists(email)) {
        throw Exception('Email is already registered');
      }

      final passwordHash = _hashPassword(password);
      final now = DateTime.now();

      // Assign random test set (1-4)
      final assignedTestSet = Random().nextInt(4) + 1;

      final student = Student(
        id: 0, // Will be set by database
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        email: email,
        phone: phone,
        educationCategory: educationCategory,
        currentInstitution: currentInstitution,
        academicYear: academicYear,
        parentGuardianContact: parentGuardianContact,
        preferredLanguage: preferredLanguage,
        address: address,
        state: state,
        district: district,
        city: city,
        pincode: pincode,
        assignedTestSet: assignedTestSet,
        testAssignedAt: now,
        createdAt: now,
      );

      // Save to database (implementation needed in repository)
      final savedStudent = await _saveStudentToDatabase(student, passwordHash);
      
      // Set current user
      await _setCurrentUser(savedStudent.id, UserRole.student, savedStudent.fullName, savedStudent.email);
      _currentStudent = savedStudent;

      return savedStudent;
    } catch (e) {
      throw Exception('Student registration failed: ${e.toString()}');
    }
  }

  // Parent Registration
  Future<Parent> registerParent({
    required String fullName,
    required RelationshipType relationshipToStudent,
    required String email,
    required String phone,
    required String password,
    required String occupation,
    required int studentId,
    required String address,
    required String state,
    required String district,
    required String city,
    required String pincode,
    required Language preferredLanguage,
  }) async {
    try {
      if (await _emailExists(email)) {
        throw Exception('Email is already registered');
      }

      final passwordHash = _hashPassword(password);
      final now = DateTime.now();

      final parent = Parent(
        id: 0,
        fullName: fullName,
        relationshipToStudent: relationshipToStudent,
        email: email,
        phone: phone,
        occupation: occupation,
        studentId: studentId,
        address: address,
        state: state,
        district: district,
        city: city,
        pincode: pincode,
        preferredLanguage: preferredLanguage,
        createdAt: now,
      );

      final savedParent = await _saveParentToDatabase(parent, passwordHash);
      
      await _setCurrentUser(savedParent.id, UserRole.parent, savedParent.fullName, savedParent.email);
      _currentParent = savedParent;

      return savedParent;
    } catch (e) {
      throw Exception('Parent registration failed: ${e.toString()}');
    }
  }

  // Teacher Registration
  Future<Teacher> registerTeacher({
    required String fullName,
    required String employeeId,
    required String institutionName,
    required String designation,
    required List<String> subjectExpertise,
    required String email,
    required String phone,
    required String password,
    required int yearsOfExperience,
    required String institutionAddress,
    required String state,
    required String district,
    required String city,
    required String pincode,
    required Language preferredLanguage,
    AdminAccessLevel accessLevel = AdminAccessLevel.basic,
  }) async {
    try {
      if (await _emailExists(email)) {
        throw Exception('Email is already registered');
      }

      final passwordHash = _hashPassword(password);
      final now = DateTime.now();

      final teacher = Teacher(
        id: 0,
        fullName: fullName,
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
        createdAt: now,
      );

      final savedTeacher = await _saveTeacherToDatabase(teacher, passwordHash);
      
      await _setCurrentUser(savedTeacher.id, UserRole.teacher, savedTeacher.fullName, savedTeacher.email);
      _currentTeacher = savedTeacher;

      return savedTeacher;
    } catch (e) {
      throw Exception('Teacher registration failed: ${e.toString()}');
    }
  }

  // Universal Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final passwordHash = _hashPassword(password);
      
      // Try to find user in each table
      final userInfo = await _findUserByEmailAndPassword(email, passwordHash);
      
      if (userInfo == null) {
        throw Exception('Invalid email or password');
      }

      await _setCurrentUser(userInfo['id'], userInfo['role'], userInfo['name'], email);
      
      // Load specific user data based on role
      await _loadUserSpecificData(userInfo['role'], userInfo['id']);

      return {
        'user_id': userInfo['id'],
        'role': userInfo['role'],
        'name': userInfo['name'],
        'email': email,
      };
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _currentUserId = null;
      _currentUserRole = null;
      _currentUserName = null;
      _currentUserEmail = null;
      _isLoggedIn = false;
      
      _currentStudent = null;
      _currentParent = null;
      _currentTeacher = null;
      _currentCounselor = null;
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Private helper methods
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> _emailExists(String email) async {
    // Check in all user tables
    // Implementation needed in repositories
    return false; // Placeholder
  }

  Future<Student> _saveStudentToDatabase(Student student, String passwordHash) async {
    // Implementation needed in repository
    throw UnimplementedError('Student repository save method needed');
  }

  Future<Parent> _saveParentToDatabase(Parent parent, String passwordHash) async {
    // Implementation needed in repository
    throw UnimplementedError('Parent repository save method needed');
  }

  Future<Teacher> _saveTeacherToDatabase(Teacher teacher, String passwordHash) async {
    // Implementation needed in repository
    throw UnimplementedError('Teacher repository save method needed');
  }

  Future<Map<String, dynamic>?> _findUserByEmailAndPassword(String email, String passwordHash) async {
    // Implementation needed to search across all user tables
    throw UnimplementedError('Multi-table user search needed');
  }

  Future<void> _setCurrentUser(int userId, UserRole role, String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userRoleKey, role.value);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setBool(_isLoggedInKey, true);
    
    _currentUserId = userId;
    _currentUserRole = role;
    _currentUserName = name;
    _currentUserEmail = email;
    _isLoggedIn = true;
  }

  Future<void> _loadUserDataFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _currentUserId = prefs.getInt(_userIdKey);
      _currentUserName = prefs.getString(_userNameKey);
      _currentUserEmail = prefs.getString(_userEmailKey);
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      final roleString = prefs.getString(_userRoleKey);
      if (roleString != null) {
        _currentUserRole = UserRoleExtension.fromString(roleString);
      }

      if (_isLoggedIn && _currentUserId != null && _currentUserRole != null) {
        await _loadUserSpecificData(_currentUserRole!, _currentUserId!);
      }
    } catch (e) {
      // Clear data on error
      await logout();
    }
  }

  Future<void> _loadUserSpecificData(UserRole role, int userId) async {
    // Load specific user data based on role
    // Implementation needed in repositories
  }
}
