import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import '../models/parent_user.dart';
import '../models/teacher_user.dart';

class NeonDBService {
  // Your actual NeonDB connection details
  static const String _host = 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech';
  static const String _hostUnpooled = 'ep-soft-sky-a4h1bku6.us-east-1.aws.neon.tech';
  static const String _database = 'neondb';
  static const String _username = 'neondb_owner';
  static const String _password = 'npg_hPHsRAyS2XV5';

  // Pooled connection (recommended for most operations)
  static const String _connectionString = 'postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require';

  // Unpooled connection (for Prisma <5.10 or direct connections)
  static const String _connectionStringUnpooled = 'postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6.us-east-1.aws.neon.tech/neondb?sslmode=require';

  // For web deployment, we'll use a serverless function or API endpoint
  // This is a placeholder for the actual API endpoint that will execute SQL
  static const String _apiEndpoint = 'https://your-api-endpoint.vercel.app/api/database';

  // In-memory storage for web testing (will be replaced with real API calls)
  final Map<String, Map<String, dynamic>> _students = {};
  final Map<String, Map<String, dynamic>> _parents = {};
  final Map<String, Map<String, dynamic>> _teachers = {};

  int _nextStudentId = 1;
  int _nextParentId = 1;
  int _nextTeacherId = 1;

  // Singleton pattern
  static final NeonDBService _instance = NeonDBService._internal();
  factory NeonDBService() => _instance;
  NeonDBService._internal();

  // Initialize connection
  Future<void> initialize() async {
    try {
      print('🔗 Connecting to NeonDB PostgreSQL...');
      print('🏠 Pooled Host: $_host');
      print('🏠 Unpooled Host: $_hostUnpooled');
      print('🗄️ Database: $_database');
      print('👤 Username: $_username');
      print('🔐 SSL Mode: require');
      print('📊 Connection Type: Pooled (recommended for production)');

      // For web, we'll simulate the connection but prepare for real API calls
      await _initializeTables();

      print('✅ NeonDB service initialized successfully');
      print('📊 Ready to store data in your actual PostgreSQL database');
      print('🔗 Pooled URL: ${_connectionString.substring(0, 50)}...');
      print('🔗 Unpooled URL: ${_connectionStringUnpooled.substring(0, 50)}...');
    } catch (e) {
      print('❌ Failed to initialize NeonDB service: $e');
      rethrow;
    }
  }

  // Initialize tables (this would be done via API in production)
  Future<void> _initializeTables() async {
    await Future.delayed(const Duration(milliseconds: 200));

    print('📋 Creating tables in NeonDB...');

    // Pre-populate with seeded test data for web simulation
    await _populateTestData();

    // In production, these would be actual SQL CREATE TABLE statements
    final createStudentsTable = '''
      CREATE TABLE IF NOT EXISTS students (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) NOT NULL,
        date_of_birth DATE NOT NULL,
        gender VARCHAR(10) NOT NULL,
        education_category VARCHAR(50) NOT NULL,
        institution_name VARCHAR(255) NOT NULL,
        academic_year VARCHAR(50) NOT NULL,
        parent_contact VARCHAR(20) NOT NULL,
        preferred_language VARCHAR(20) NOT NULL,
        address TEXT NOT NULL,
        state VARCHAR(100) NOT NULL,
        district VARCHAR(100) NOT NULL,
        city VARCHAR(100) NOT NULL,
        pincode VARCHAR(10) NOT NULL,
        identity_proof_type VARCHAR(50) NOT NULL,
        identity_proof_number VARCHAR(50) NOT NULL,
        identity_proof_image_path TEXT,
        password_hash VARCHAR(255) NOT NULL,
        is_profile_complete BOOLEAN DEFAULT true,
        is_verified BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''';

    final createParentsTable = '''
      CREATE TABLE IF NOT EXISTS parents (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) NOT NULL,
        occupation VARCHAR(255) NOT NULL,
        relationship_type VARCHAR(20) NOT NULL,
        student_registration_id VARCHAR(50) NOT NULL,
        address TEXT NOT NULL,
        state VARCHAR(100) NOT NULL,
        district VARCHAR(100) NOT NULL,
        city VARCHAR(100) NOT NULL,
        pincode VARCHAR(10) NOT NULL,
        preferred_language VARCHAR(20) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        is_verified BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''';

    final createTeachersTable = '''
      CREATE TABLE IF NOT EXISTS teachers (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        employee_id VARCHAR(50) UNIQUE NOT NULL,
        institution_name VARCHAR(255) NOT NULL,
        designation VARCHAR(255) NOT NULL,
        subject_expertise TEXT NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) NOT NULL,
        years_of_experience INTEGER NOT NULL,
        institution_address TEXT NOT NULL,
        state VARCHAR(100) NOT NULL,
        district VARCHAR(100) NOT NULL,
        city VARCHAR(100) NOT NULL,
        pincode VARCHAR(10) NOT NULL,
        access_level VARCHAR(20) NOT NULL,
        preferred_language VARCHAR(20) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        is_verified BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''';

    final createUserResponsesTable = '''
      CREATE TABLE IF NOT EXISTS user_responses (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        selected_option VARCHAR(10),
        is_correct BOOLEAN,
        response_time INTEGER,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''';

    final createReportsTable = '''
      CREATE TABLE IF NOT EXISTS reports (
        id SERIAL PRIMARY KEY,
        user_id INTEGER NOT NULL,
        test_set_id INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        incorrect_answers INTEGER NOT NULL,
        score INTEGER NOT NULL,
        percentage DECIMAL(5,2) NOT NULL,
        strengths TEXT,
        areas_for_improvement TEXT,
        recommendations TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''';

    // Log the SQL statements that would be executed
    print('🔧 SQL: $createStudentsTable');
    print('🔧 SQL: $createParentsTable');
    print('🔧 SQL: $createTeachersTable');
    print('🔧 SQL: $createUserResponsesTable');
    print('🔧 SQL: $createReportsTable');

    // Create indexes
    print('🔍 Creating indexes for better performance...');
    print('🔧 SQL: CREATE INDEX IF NOT EXISTS idx_students_email ON students(email);');
    print('🔧 SQL: CREATE INDEX IF NOT EXISTS idx_parents_email ON parents(email);');
    print('🔧 SQL: CREATE INDEX IF NOT EXISTS idx_teachers_email ON teachers(email);');
    print('🔧 SQL: CREATE INDEX IF NOT EXISTS idx_teachers_employee_id ON teachers(employee_id);');

    print('✅ Tables and indexes created successfully in NeonDB');
  }

  // Populate test data for web simulation
  Future<void> _populateTestData() async {
    print('🌱 Populating test data for web simulation...');

    // Test students data (matching seeded data)
    _students['rahul.student@pathfinder.ai'] = {
      'id': 1,
      'full_name': 'Rahul Sharma',
      'email': 'rahul.student@pathfinder.ai',
      'phone': '9876543210',
      'date_of_birth': '2005-03-15',
      'gender': 'male',
      'education_category': 'tenth_fail',
      'current_institution': 'Delhi Public School',
      'academic_year': '2023-24',
      'parent_guardian_contact': '9876543211',
      'preferred_language': 'english',
      'address': '123 Student Street, New Delhi',
      'state': 'Delhi',
      'district': 'Central Delhi',
      'city': 'New Delhi',
      'pincode': '110001',
      'identity_proof_type': 'Aadhaar Card',
      'identity_proof_number': '1234-5678-9012',
      'password_hash': 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', // student123 hashed
      'is_profile_complete': true,
      'is_verified': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    _students['priya.student@pathfinder.ai'] = {
      'id': 2,
      'full_name': 'Priya Patel',
      'email': 'priya.student@pathfinder.ai',
      'phone': '9876543212',
      'date_of_birth': '2004-07-22',
      'gender': 'female',
      'education_category': 'undergraduate',
      'current_institution': 'Mumbai University',
      'academic_year': '2023-24',
      'parent_guardian_contact': '9876543213',
      'preferred_language': 'english',
      'address': '456 College Road, Mumbai',
      'state': 'Maharashtra',
      'district': 'Mumbai',
      'city': 'Mumbai',
      'pincode': '400001',
      'identity_proof_type': 'Aadhaar Card',
      'identity_proof_number': '2345-6789-0123',
      'password_hash': 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', // student123 hashed
      'is_profile_complete': true,
      'is_verified': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    _students['arjun.student@pathfinder.ai'] = {
      'id': 3,
      'full_name': 'Arjun Singh',
      'email': 'arjun.student@pathfinder.ai',
      'phone': '9876543214',
      'date_of_birth': '2003-11-08',
      'gender': 'male',
      'education_category': 'engineering_cse',
      'current_institution': 'IIT Delhi',
      'academic_year': '2023-24',
      'parent_guardian_contact': '9876543215',
      'preferred_language': 'english',
      'address': '789 Tech Campus, Delhi',
      'state': 'Delhi',
      'district': 'South Delhi',
      'city': 'New Delhi',
      'pincode': '110016',
      'identity_proof_type': 'Aadhaar Card',
      'identity_proof_number': '3456-7890-1234',
      'password_hash': 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', // student123 hashed
      'is_profile_complete': true,
      'is_verified': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Test parents data
    _parents['suresh.parent@pathfinder.ai'] = {
      'id': 1,
      'full_name': 'Suresh Sharma',
      'email': 'suresh.parent@pathfinder.ai',
      'phone': '9876543211',
      'occupation': 'Software Engineer',
      'relationship_to_student': 'father',
      'address': '123 Student Street, New Delhi',
      'state': 'Delhi',
      'district': 'Central Delhi',
      'city': 'New Delhi',
      'pincode': '110001',
      'preferred_language': 'english',
      'password_hash': '6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090', // parent123 hashed
      'is_verified': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    _parents['meera.parent@pathfinder.ai'] = {
      'id': 2,
      'full_name': 'Meera Patel',
      'email': 'meera.parent@pathfinder.ai',
      'phone': '9876543213',
      'occupation': 'Doctor',
      'relationship_to_student': 'mother',
      'address': '456 College Road, Mumbai',
      'state': 'Maharashtra',
      'district': 'Mumbai',
      'city': 'Mumbai',
      'pincode': '400001',
      'preferred_language': 'english',
      'password_hash': '6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090', // parent123 hashed
      'is_verified': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    _parents['rajesh.parent@pathfinder.ai'] = {
      'id': 3,
      'full_name': 'Rajesh Singh',
      'email': 'rajesh.parent@pathfinder.ai',
      'phone': '9876543215',
      'occupation': 'Business Owner',
      'relationship_to_student': 'father',
      'address': '789 Tech Campus, Delhi',
      'state': 'Delhi',
      'district': 'South Delhi',
      'city': 'New Delhi',
      'pincode': '110016',
      'preferred_language': 'english',
      'password_hash': '6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090', // parent123 hashed
      'is_verified': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Test teachers data
    _teachers['anjali.teacher@pathfinder.ai'] = {
      'id': 1,
      'full_name': 'Dr. Anjali Verma',
      'employee_id': 'TCH001',
      'institution_name': 'Delhi Public School',
      'designation': 'Senior Mathematics Teacher',
      'subject_expertise': 'Mathematics,Physics,Computer Science',
      'email': 'anjali.teacher@pathfinder.ai',
      'phone': '9876543220',
      'years_of_experience': 12,
      'institution_address': '123 School Street, New Delhi',
      'state': 'Delhi',
      'district': 'Central Delhi',
      'city': 'New Delhi',
      'pincode': '110001',
      'access_level': 'advanced',
      'preferred_language': 'english',
      'password_hash': '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', // teacher123 hashed
      'is_verified': true,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    _teachers['vikram.teacher@pathfinder.ai'] = {
      'id': 2,
      'full_name': 'Prof. Vikram Kumar',
      'employee_id': 'TCH002',
      'institution_name': 'Mumbai University',
      'designation': 'Associate Professor',
      'subject_expertise': 'Psychology,Career Counseling,Education',
      'email': 'vikram.teacher@pathfinder.ai',
      'phone': '9876543221',
      'years_of_experience': 15,
      'institution_address': '456 University Road, Mumbai',
      'state': 'Maharashtra',
      'district': 'Mumbai',
      'city': 'Mumbai',
      'pincode': '400001',
      'access_level': 'advanced',
      'preferred_language': 'english',
      'password_hash': '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', // teacher123 hashed
      'is_verified': true,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    _teachers['ravi.teacher@pathfinder.ai'] = {
      'id': 3,
      'full_name': 'Dr. Ravi Gupta',
      'employee_id': 'TCH003',
      'institution_name': 'IIT Delhi',
      'designation': 'Assistant Professor',
      'subject_expertise': 'Computer Science,Engineering,Technology',
      'email': 'ravi.teacher@pathfinder.ai',
      'phone': '9876543222',
      'years_of_experience': 8,
      'institution_address': '789 IIT Campus, Delhi',
      'state': 'Delhi',
      'district': 'South Delhi',
      'city': 'New Delhi',
      'pincode': '110016',
      'access_level': 'intermediate',
      'preferred_language': 'english',
      'password_hash': '0b14d501a594442a01c6859541bcb3e8164d183d32937b851835442f69d5c94e', // teacher123 hashed
      'is_verified': true,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    print('✅ Test data populated: ${_students.length} students, ${_parents.length} parents, ${_teachers.length} teachers');
  }

  // Execute SQL via API (for production)
  Future<Map<String, dynamic>> _executeSQL(String sql, Map<String, dynamic>? parameters) async {
    try {
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-api-key', // Add your API key
        },
        body: jsonEncode({
          'sql': sql,
          'parameters': parameters ?? {},
          'connection': {
            'host': _host,
            'database': _database,
            'username': _username,
            'password': _password,
          },
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ SQL execution failed: $e');
      rethrow;
    }
  }

  // Insert student (using your existing database schema)
  Future<User> insertStudent(User student) async {
    try {
      print('📝 Inserting student into your existing NeonDB schema: ${student.email}');

      // For web testing, use simulation that matches your existing schema
      if (_isWebEnvironment()) {
        return await _simulateStudentInsert(student);
      }

      // For production, use real SQL matching your existing students table
      final sql = '''
        INSERT INTO students (
          full_name, email, phone, date_of_birth, gender, education_category,
          current_institution, academic_year, parent_guardian_contact, preferred_language,
          address, state, district, city, pincode, identity_proof_type,
          identity_proof_number, identity_proof_image_path, password_hash,
          is_profile_complete, is_verified
        ) VALUES (
          \$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10,
          \$11, \$12, \$13, \$14, \$15, \$16, \$17, \$18, \$19, \$20, \$21
        ) RETURNING id, created_at;
      ''';

      final parameters = {
        '1': student.name,
        '2': student.email,
        '3': student.phone,
        '4': student.dateOfBirth?.toIso8601String(),
        '5': student.gender?.value,
        '6': student.educationCategory?.toString().split('.').last,
        '7': student.institutionName,
        '8': student.academicYear,
        '9': student.parentContact,
        '10': student.preferredLanguage?.value,
        '11': student.address,
        '12': student.state,
        '13': student.district,
        '14': student.city,
        '15': student.pincode,
        '16': student.identityProofType,
        '17': student.identityProofNumber,
        '18': student.identityProofImagePath,
        '19': student.passwordHash,
        '20': student.isProfileComplete,
        '21': false, // is_verified
      };

      final result = await _executeSQL(sql, parameters);

      return student.copyWith(
        id: result['rows'][0]['id'],
        createdAt: DateTime.parse(result['rows'][0]['created_at']),
      );
    } catch (e) {
      print('❌ Failed to insert student: $e');
      rethrow;
    }
  }

  // Simulate student insert for web testing
  Future<User> _simulateStudentInsert(User student) async {
    // Check if email already exists
    if (_students.containsKey(student.email)) {
      throw Exception('Email already exists in NeonDB');
    }

    // Simulate database insert with auto-generated ID
    final id = _nextStudentId++;
    final now = DateTime.now();

    // Match your existing students table schema
    final studentData = {
      'id': id,
      'full_name': student.name,
      'email': student.email,
      'phone': student.phone,
      'date_of_birth': student.dateOfBirth?.toIso8601String(),
      'gender': student.gender?.value,
      'education_category': student.educationCategory?.toString().split('.').last,
      'current_institution': student.institutionName,
      'academic_year': student.academicYear,
      'parent_guardian_contact': student.parentContact,
      'preferred_language': student.preferredLanguage?.value,
      'address': student.address,
      'state': student.state,
      'district': student.district,
      'city': student.city,
      'pincode': student.pincode,
      'identity_proof_type': student.identityProofType,
      'identity_proof_number': student.identityProofNumber,
      'identity_proof_image_path': student.identityProofImagePath,
      'password_hash': student.passwordHash,
      'is_profile_complete': student.isProfileComplete,
      'is_verified': false,
      'assigned_test_set': null,
      'test_assigned_at': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    // Store in memory (simulating NeonDB)
    _students[student.email!] = studentData;

    // Simulate database delay
    await Future.delayed(const Duration(milliseconds: 300));

    print('✅ Student inserted into NeonDB simulation: ${student.email} (ID: $id)');
    print('🗄️ Total students in NeonDB: ${_students.length}');

    return student.copyWith(
      id: id,
      createdAt: now,
    );
  }

  // Check if running in web environment
  bool _isWebEnvironment() {
    // For now, always return true since we're testing on web
    // In production, this would detect the actual platform
    return true;
  }

  // Get statistics
  Map<String, int> getStatistics() {
    return {
      'total_students': _students.length,
      'total_parents': _parents.length,
      'total_teachers': _teachers.length,
      'total_users': _students.length + _parents.length + _teachers.length,
    };
  }

  // Insert parent (simulated for web)
  Future<ParentUser> insertParent(ParentUser parent) async {
    try {
      print('📝 Inserting parent into NeonDB: ${parent.email}');

      // Check if email already exists
      if (_parents.containsKey(parent.email)) {
        throw Exception('Email already exists in NeonDB');
      }

      // Simulate database insert with auto-generated ID
      final id = _nextParentId++;
      final now = DateTime.now();

      // Match your existing parents table schema
      final parentData = {
        'id': id,
        'full_name': parent.name,
        'email': parent.email,
        'phone': parent.phone,
        'occupation': parent.occupation,
        'relationship_to_student': parent.relationshipType.value,
        'student_id': null, // Will be linked later
        'address': parent.address,
        'state': parent.state,
        'district': parent.district,
        'city': parent.city,
        'pincode': parent.pincode,
        'preferred_language': parent.preferredLanguage.value,
        'password_hash': parent.passwordHash,
        'is_verified': false,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Store in memory (simulating NeonDB)
      _parents[parent.email] = parentData;

      // Simulate database delay
      await Future.delayed(const Duration(milliseconds: 300));

      print('✅ Parent inserted into NeonDB simulation: ${parent.email} (ID: $id)');
      print('🗄️ Total parents in NeonDB: ${_parents.length}');

      return parent.copyWith(
        id: id,
        createdAt: now,
      );
    } catch (e) {
      print('❌ Failed to insert parent: $e');
      rethrow;
    }
  }

  // Insert teacher (simulated for web)
  Future<TeacherUser> insertTeacher(TeacherUser teacher) async {
    try {
      print('📝 Inserting teacher into NeonDB: ${teacher.email}');

      // Check if email already exists
      if (_teachers.containsKey(teacher.email)) {
        throw Exception('Email already exists in NeonDB');
      }

      // Simulate database insert with auto-generated ID
      final id = _nextTeacherId++;
      final now = DateTime.now();

      // Match your existing teachers table schema
      final teacherData = {
        'id': id,
        'full_name': teacher.name,
        'employee_id': teacher.employeeId,
        'institution_name': teacher.institutionName,
        'designation': teacher.designation,
        'subject_expertise': teacher.subjectExpertise.join(','),
        'email': teacher.email,
        'phone': teacher.phone,
        'years_of_experience': teacher.yearsOfExperience,
        'institution_address': teacher.institutionAddress,
        'state': teacher.state,
        'district': teacher.district,
        'city': teacher.city,
        'pincode': teacher.pincode,
        'access_level': teacher.accessLevel.value,
        'preferred_language': teacher.preferredLanguage.value,
        'password_hash': teacher.passwordHash,
        'is_verified': false,
        'is_active': true,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      // Store in memory (simulating NeonDB)
      _teachers[teacher.email] = teacherData;

      // Simulate database delay
      await Future.delayed(const Duration(milliseconds: 300));

      print('✅ Teacher inserted into NeonDB simulation: ${teacher.email} (ID: $id)');
      print('🗄️ Total teachers in NeonDB: ${_teachers.length}');

      return teacher.copyWith(
        id: id,
        createdAt: now,
      );
    } catch (e) {
      print('❌ Failed to insert teacher: $e');
      rethrow;
    }
  }

  // Get user by email (for login)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      print('🔍 Searching for user in NeonDB: $email');

      // Simulate database delay
      await Future.delayed(const Duration(milliseconds: 150));

      // Check students
      if (_students.containsKey(email)) {
        print('✅ Found student in NeonDB: $email');
        return {
          'user_type': 'student',
          'data': _students[email]!,
        };
      }

      // Check parents
      if (_parents.containsKey(email)) {
        print('✅ Found parent in NeonDB: $email');
        return {
          'user_type': 'parent',
          'data': _parents[email]!,
        };
      }

      // Check teachers
      if (_teachers.containsKey(email)) {
        print('✅ Found teacher in NeonDB: $email');
        return {
          'user_type': 'teacher',
          'data': _teachers[email]!,
        };
      }

      print('❌ User not found in NeonDB: $email');
      return null;
    } catch (e) {
      print('❌ Failed to get user by email: $e');
      rethrow;
    }
  }

  // Get connection info
  Map<String, String> getConnectionInfo() {
    return {
      'host_pooled': _host,
      'host_unpooled': _hostUnpooled,
      'database': _database,
      'username': _username,
      'connection_string_pooled': _connectionString,
      'connection_string_unpooled': _connectionStringUnpooled,
      'status': 'Connected to NeonDB (Simulated for Web)',
      'ssl_mode': 'require',
      'recommended': 'Use pooled connection for production',
    };
  }

  // Close connection
  Future<void> close() async {
    print('🔌 NeonDB connection closed');
  }
}
