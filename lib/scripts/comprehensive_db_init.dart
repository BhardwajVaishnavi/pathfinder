import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

/// Comprehensive database initialization script for PathfinderAI
/// This creates all tables for the multi-user system with AI integration
Future<void> main() async {
  print('🚀 Initializing PathfinderAI comprehensive database schema...');

  final connection = PostgreSQLConnection(
    DatabaseConfig.host,
    DatabaseConfig.port,
    DatabaseConfig.database,
    username: DatabaseConfig.username,
    password: DatabaseConfig.password,
    useSSL: DatabaseConfig.useSSL,
  );

  try {
    await connection.open();
    print('✅ Connected to PostgreSQL database');

    // Create Students table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS students (
        id SERIAL PRIMARY KEY,
        full_name VARCHAR(255) NOT NULL,
        date_of_birth DATE NOT NULL,
        gender VARCHAR(20) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) NOT NULL,
        education_category VARCHAR(50) NOT NULL,
        current_institution VARCHAR(255) NOT NULL,
        academic_year VARCHAR(50) NOT NULL,
        parent_guardian_contact VARCHAR(20) NOT NULL,
        preferred_language VARCHAR(20) NOT NULL DEFAULT 'english',
        address TEXT NOT NULL,
        state VARCHAR(100) NOT NULL,
        district VARCHAR(100) NOT NULL,
        city VARCHAR(100) NOT NULL,
        pincode VARCHAR(10) NOT NULL,
        identity_proof_type VARCHAR(50),
        identity_proof_number VARCHAR(100),
        identity_proof_image_path TEXT,
        is_profile_complete BOOLEAN DEFAULT FALSE,
        is_verified BOOLEAN DEFAULT FALSE,
        assigned_test_set INTEGER,
        test_assigned_at TIMESTAMP,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
      )
    ''');
    print('✅ Created students table');

    // Create Parents table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS parents (
        id SERIAL PRIMARY KEY,
        full_name VARCHAR(255) NOT NULL,
        relationship_to_student VARCHAR(50) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) NOT NULL,
        occupation VARCHAR(255) NOT NULL,
        student_id INTEGER REFERENCES students(id) ON DELETE CASCADE,
        address TEXT NOT NULL,
        state VARCHAR(100) NOT NULL,
        district VARCHAR(100) NOT NULL,
        city VARCHAR(100) NOT NULL,
        pincode VARCHAR(10) NOT NULL,
        preferred_language VARCHAR(20) NOT NULL DEFAULT 'english',
        is_verified BOOLEAN DEFAULT FALSE,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
      )
    ''');
    print('✅ Created parents table');

    // Create Teachers table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS teachers (
        id SERIAL PRIMARY KEY,
        full_name VARCHAR(255) NOT NULL,
        employee_id VARCHAR(100) UNIQUE NOT NULL,
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
        access_level VARCHAR(20) DEFAULT 'basic',
        preferred_language VARCHAR(20) NOT NULL DEFAULT 'english',
        is_verified BOOLEAN DEFAULT FALSE,
        is_active BOOLEAN DEFAULT TRUE,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
      )
    ''');
    print('✅ Created teachers table');

    // Create Counselors table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS counselors (
        id SERIAL PRIMARY KEY,
        full_name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) NOT NULL,
        specializations TEXT NOT NULL,
        years_of_experience INTEGER NOT NULL,
        qualifications TEXT NOT NULL,
        certifications TEXT NOT NULL,
        hourly_rate DECIMAL(10,2) NOT NULL,
        available_time_slots TEXT NOT NULL,
        supported_languages TEXT NOT NULL,
        rating DECIMAL(3,2) DEFAULT 0.0,
        total_sessions INTEGER DEFAULT 0,
        bio TEXT NOT NULL,
        profile_image_path TEXT,
        is_verified BOOLEAN DEFAULT FALSE,
        is_active BOOLEAN DEFAULT TRUE,
        is_available_online BOOLEAN DEFAULT TRUE,
        is_available_offline BOOLEAN DEFAULT FALSE,
        address TEXT NOT NULL,
        state VARCHAR(100) NOT NULL,
        district VARCHAR(100) NOT NULL,
        city VARCHAR(100) NOT NULL,
        pincode VARCHAR(10) NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
      )
    ''');
    print('✅ Created counselors table');

    // Create Education Categories table (Enhanced)
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS education_categories (
        id SERIAL PRIMARY KEY,
        category_code VARCHAR(50) UNIQUE NOT NULL,
        display_name VARCHAR(255) NOT NULL,
        description TEXT,
        icon VARCHAR(50),
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('✅ Created education_categories table');

    // Create Test Sets table (4 sets per category)
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS test_sets (
        id SERIAL PRIMARY KEY,
        category_id INTEGER REFERENCES education_categories(id),
        set_number INTEGER NOT NULL CHECK (set_number BETWEEN 1 AND 4),
        title VARCHAR(255) NOT NULL,
        description TEXT,
        test_type VARCHAR(20) NOT NULL DEFAULT 'combined',
        time_limit_minutes INTEGER DEFAULT 60,
        passing_score INTEGER DEFAULT 70,
        total_questions INTEGER DEFAULT 50,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(category_id, set_number)
      )
    ''');
    print('✅ Created test_sets table');

    // Create Questions table (Enhanced for both aptitude and psychometric)
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        id SERIAL PRIMARY KEY,
        test_set_id INTEGER REFERENCES test_sets(id) ON DELETE CASCADE,
        question_type VARCHAR(20) NOT NULL DEFAULT 'aptitude',
        question_text TEXT NOT NULL,
        option_a TEXT,
        option_b TEXT,
        option_c TEXT,
        option_d TEXT,
        correct_option CHAR(1),
        explanation TEXT,
        difficulty_level VARCHAR(20) DEFAULT 'medium',
        skill_category VARCHAR(100),
        points INTEGER DEFAULT 1,
        time_limit_seconds INTEGER DEFAULT 120,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('✅ Created questions table');

    // Create User Responses table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS user_responses (
        id SERIAL PRIMARY KEY,
        student_id INTEGER REFERENCES students(id) ON DELETE CASCADE,
        question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE,
        test_set_id INTEGER REFERENCES test_sets(id) ON DELETE CASCADE,
        selected_option CHAR(1),
        is_correct BOOLEAN,
        response_time_seconds INTEGER,
        points_earned INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(student_id, question_id)
      )
    ''');
    print('✅ Created user_responses table');

    // Create AI Reports table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS ai_reports (
        id SERIAL PRIMARY KEY,
        student_id INTEGER REFERENCES students(id) ON DELETE CASCADE,
        test_type VARCHAR(20) NOT NULL DEFAULT 'combined',
        aptitude_score INTEGER NOT NULL,
        aptitude_percentage DECIMAL(5,2) NOT NULL,
        personality_traits JSONB,
        interest_areas JSONB,
        skill_gaps JSONB,
        career_recommendations JSONB,
        overall_analysis TEXT NOT NULL,
        strengths_analysis TEXT NOT NULL,
        improvement_areas TEXT NOT NULL,
        next_steps TEXT NOT NULL,
        is_chatgpt_trained BOOLEAN DEFAULT FALSE,
        chatgpt_model_id VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
      )
    ''');
    print('✅ Created ai_reports table');

    // Create Counseling Sessions table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS counseling_sessions (
        id SERIAL PRIMARY KEY,
        student_id INTEGER REFERENCES students(id) ON DELETE CASCADE,
        counselor_id INTEGER REFERENCES counselors(id) ON DELETE CASCADE,
        session_type VARCHAR(20) NOT NULL DEFAULT 'online',
        duration VARCHAR(10) NOT NULL DEFAULT '60',
        scheduled_date_time TIMESTAMP NOT NULL,
        status VARCHAR(20) DEFAULT 'scheduled',
        amount DECIMAL(10,2) NOT NULL,
        meeting_link TEXT,
        meeting_password VARCHAR(50),
        session_notes TEXT,
        recording_path TEXT,
        rating INTEGER CHECK (rating BETWEEN 1 AND 5),
        feedback TEXT,
        counselor_notes TEXT,
        actual_start_time TIMESTAMP,
        actual_end_time TIMESTAMP,
        is_payment_completed BOOLEAN DEFAULT FALSE,
        payment_transaction_id VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP
      )
    ''');
    print('✅ Created counseling_sessions table');

    // Create ChatGPT Conversations table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS chatgpt_conversations (
        id SERIAL PRIMARY KEY,
        student_id INTEGER REFERENCES students(id) ON DELETE CASCADE,
        ai_report_id INTEGER REFERENCES ai_reports(id) ON DELETE CASCADE,
        conversation_id VARCHAR(255) UNIQUE NOT NULL,
        message_count INTEGER DEFAULT 0,
        last_message_at TIMESTAMP,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('✅ Created chatgpt_conversations table');

    // Create ChatGPT Messages table
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS chatgpt_messages (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER REFERENCES chatgpt_conversations(id) ON DELETE CASCADE,
        message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('user', 'assistant')),
        message_content TEXT NOT NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        tokens_used INTEGER DEFAULT 0
      )
    ''');
    print('✅ Created chatgpt_messages table');

    // Insert Education Categories
    await connection.execute('''
      INSERT INTO education_categories (category_code, display_name, description, icon) VALUES
        ('tenth_fail', '10th Fail', 'Students who have not passed 10th grade', 'school'),
        ('tenth_pass', '10th Pass', 'Students who have passed 10th grade', 'school'),
        ('twelfth_fail', '12th Fail', 'Students who have not passed 12th grade', 'school'),
        ('twelfth_pass', '12th Pass', 'Students who have passed 12th grade', 'school'),
        ('graduate_arts', 'Graduate - Arts', 'Students with arts degree', 'brush'),
        ('graduate_science', 'Graduate - Science', 'Students with science degree', 'science'),
        ('graduate_commerce', 'Graduate - Commerce', 'Students with commerce degree', 'business'),
        ('engineering_cse', 'Engineering - CSE', 'Computer Science Engineering students', 'engineering'),
        ('engineering_ece', 'Engineering - ECE', 'Electronics & Communication Engineering students', 'engineering'),
        ('engineering_mechanical', 'Engineering - Mechanical', 'Mechanical Engineering students', 'engineering'),
        ('engineering_civil', 'Engineering - Civil', 'Civil Engineering students', 'engineering'),
        ('engineering_other', 'Engineering - Other', 'Other Engineering disciplines', 'engineering'),
        ('postgraduate', 'Postgraduate', 'Students with postgraduate degrees', 'school')
      ON CONFLICT (category_code) DO NOTHING
    ''');
    print('✅ Inserted education categories');

    // Create 4 test sets for each category
    final categories = [
      'tenth_fail', 'tenth_pass', 'twelfth_fail', 'twelfth_pass',
      'graduate_arts', 'graduate_science', 'graduate_commerce',
      'engineering_cse', 'engineering_ece', 'engineering_mechanical',
      'engineering_civil', 'engineering_other', 'postgraduate'
    ];

    for (int categoryIndex = 0; categoryIndex < categories.length; categoryIndex++) {
      final categoryCode = categories[categoryIndex];
      final categoryId = categoryIndex + 1;

      for (int setNumber = 1; setNumber <= 4; setNumber++) {
        await connection.execute('''
          INSERT INTO test_sets (category_id, set_number, title, description, test_type, time_limit_minutes, total_questions)
          VALUES (
            $categoryId,
            $setNumber,
            '${categoryCode.replaceAll('_', ' ').toUpperCase()} - Test Set $setNumber',
            'Comprehensive aptitude and psychometric assessment for ${categoryCode.replaceAll('_', ' ')} students - Set $setNumber',
            'combined',
            90,
            50
          )
          ON CONFLICT (category_id, set_number) DO NOTHING
        ''');
      }
    }
    print('✅ Created 4 test sets for each education category (52 total test sets)');

    // Create indexes for better performance
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_students_email ON students(email)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_students_education_category ON students(education_category)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_students_assigned_test_set ON students(assigned_test_set)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_user_responses_student_id ON user_responses(student_id)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_user_responses_test_set_id ON user_responses(test_set_id)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_ai_reports_student_id ON ai_reports(student_id)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_counseling_sessions_student_id ON counseling_sessions(student_id)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_counseling_sessions_counselor_id ON counseling_sessions(counselor_id)');
    await connection.execute('CREATE INDEX IF NOT EXISTS idx_counseling_sessions_scheduled_date ON counseling_sessions(scheduled_date_time)');
    print('✅ Created database indexes for performance optimization');

    print('🎉 Comprehensive PathfinderAI database initialization completed successfully!');
    print('📊 Database includes:');
    print('   - Multi-user system (Students, Parents, Teachers, Counselors)');
    print('   - 13 Education categories with 4 test sets each (52 total)');
    print('   - AI-powered reporting system');
    print('   - ChatGPT integration tables');
    print('   - Counseling session management');
    print('   - Performance optimized with indexes');

  } catch (e) {
    print('❌ Error initializing database: $e');
    rethrow;
  } finally {
    await connection.close();
    print('🔌 Disconnected from PostgreSQL database');
  }
}
