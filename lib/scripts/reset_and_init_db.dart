import 'package:postgres/postgres.dart';
import '../config/database_config.dart';

/// Reset and initialize the comprehensive database schema for PathfinderAI
/// This drops existing tables and recreates them with the new schema
Future<void> main() async {
  print('🔄 Resetting and initializing PathfinderAI database schema...');

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

    // Drop existing tables in correct order (reverse dependency order)
    print('🗑️ Dropping existing tables...');
    await connection.execute('DROP TABLE IF EXISTS chatgpt_messages CASCADE');
    await connection.execute('DROP TABLE IF EXISTS chatgpt_conversations CASCADE');
    await connection.execute('DROP TABLE IF EXISTS counseling_sessions CASCADE');
    await connection.execute('DROP TABLE IF EXISTS ai_reports CASCADE');
    await connection.execute('DROP TABLE IF EXISTS user_responses CASCADE');
    await connection.execute('DROP TABLE IF EXISTS questions CASCADE');
    await connection.execute('DROP TABLE IF EXISTS test_sets CASCADE');
    await connection.execute('DROP TABLE IF EXISTS education_categories CASCADE');
    await connection.execute('DROP TABLE IF EXISTS counselors CASCADE');
    await connection.execute('DROP TABLE IF EXISTS teachers CASCADE');
    await connection.execute('DROP TABLE IF EXISTS parents CASCADE');
    await connection.execute('DROP TABLE IF EXISTS students CASCADE');
    await connection.execute('DROP TABLE IF EXISTS users CASCADE'); // Old table
    await connection.execute('DROP TABLE IF EXISTS categories CASCADE'); // Old table
    print('✅ Dropped existing tables');

    // Create Students table
    await connection.execute('''
      CREATE TABLE students (
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
      CREATE TABLE parents (
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
      CREATE TABLE teachers (
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
      CREATE TABLE counselors (
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

    // Create Education Categories table
    await connection.execute('''
      CREATE TABLE education_categories (
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

    // Create Test Sets table
    await connection.execute('''
      CREATE TABLE test_sets (
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

    // Create Questions table
    await connection.execute('''
      CREATE TABLE questions (
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
      CREATE TABLE user_responses (
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
      CREATE TABLE ai_reports (
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
      CREATE TABLE counseling_sessions (
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
      CREATE TABLE chatgpt_conversations (
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
      CREATE TABLE chatgpt_messages (
        id SERIAL PRIMARY KEY,
        conversation_id INTEGER REFERENCES chatgpt_conversations(id) ON DELETE CASCADE,
        message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('user', 'assistant')),
        message_content TEXT NOT NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        tokens_used INTEGER DEFAULT 0
      )
    ''');
    print('✅ Created chatgpt_messages table');

    print('🎉 Database schema reset and initialization completed successfully!');
    
  } catch (e) {
    print('❌ Error resetting database: $e');
    rethrow;
  } finally {
    await connection.close();
    print('🔌 Disconnected from PostgreSQL database');
  }
}
