-- PathfinderAI Database Setup Script
-- Connect to your NeonDB PostgreSQL instance
-- Database: neondb
-- Host: ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech

-- ============================================================================
-- PATHFINDER AI DATABASE SCHEMA
-- ============================================================================

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS user_responses CASCADE;
DROP TABLE IF EXISTS test_results CASCADE;
DROP TABLE IF EXISTS counseling_sessions CASCADE;
DROP TABLE IF EXISTS ai_reports CASCADE;
DROP TABLE IF EXISTS test_questions CASCADE;
DROP TABLE IF EXISTS test_sets CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS teachers CASCADE;
DROP TABLE IF EXISTS parents CASCADE;
DROP TABLE IF EXISTS students CASCADE;

-- ============================================================================
-- CORE USER TABLES
-- ============================================================================

-- Students Table
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    education_category VARCHAR(50) NOT NULL,
    institution_name VARCHAR(255) NOT NULL,
    academic_year VARCHAR(50) NOT NULL,
    parent_contact VARCHAR(20) NOT NULL,
    preferred_language VARCHAR(20) NOT NULL DEFAULT 'english',
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
    verification_token VARCHAR(255),
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Parents Table
CREATE TABLE parents (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    occupation VARCHAR(255) NOT NULL,
    relationship_type VARCHAR(20) NOT NULL CHECK (relationship_type IN ('father', 'mother', 'guardian', 'other')),
    student_registration_id VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    state VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    preferred_language VARCHAR(20) NOT NULL DEFAULT 'english',
    password_hash VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    verification_token VARCHAR(255),
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Teachers Table
CREATE TABLE teachers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    employee_id VARCHAR(50) UNIQUE NOT NULL,
    institution_name VARCHAR(255) NOT NULL,
    designation VARCHAR(255) NOT NULL,
    subject_expertise TEXT NOT NULL, -- JSON array of subjects
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    years_of_experience INTEGER NOT NULL CHECK (years_of_experience >= 0),
    institution_address TEXT NOT NULL,
    state VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    pincode VARCHAR(10) NOT NULL,
    access_level VARCHAR(20) NOT NULL CHECK (access_level IN ('basic', 'intermediate', 'advanced')),
    preferred_language VARCHAR(20) NOT NULL DEFAULT 'english',
    password_hash VARCHAR(255) NOT NULL,
    is_verified BOOLEAN DEFAULT false,
    verification_token VARCHAR(255),
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- PSYCHOMETRIC TEST SYSTEM
-- ============================================================================

-- Education Categories
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    min_age INTEGER,
    max_age INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Test Sets (4 per category)
CREATE TABLE test_sets (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    set_number INTEGER NOT NULL CHECK (set_number BETWEEN 1 AND 4),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL DEFAULT 60,
    total_questions INTEGER NOT NULL DEFAULT 50,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(category_id, set_number)
);

-- Test Questions
CREATE TABLE test_questions (
    id SERIAL PRIMARY KEY,
    test_set_id INTEGER NOT NULL REFERENCES test_sets(id) ON DELETE CASCADE,
    question_number INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    question_type VARCHAR(50) NOT NULL DEFAULT 'multiple_choice',
    options JSONB, -- Array of options for multiple choice
    correct_answer VARCHAR(255),
    points INTEGER DEFAULT 1,
    difficulty_level VARCHAR(20) DEFAULT 'medium',
    category_tag VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(test_set_id, question_number)
);

-- ============================================================================
-- USER RESPONSES AND RESULTS
-- ============================================================================

-- User Test Responses
CREATE TABLE user_responses (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    test_set_id INTEGER NOT NULL REFERENCES test_sets(id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL REFERENCES test_questions(id) ON DELETE CASCADE,
    user_answer VARCHAR(255),
    is_correct BOOLEAN,
    time_taken_seconds INTEGER,
    response_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Test Results Summary
CREATE TABLE test_results (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    test_set_id INTEGER NOT NULL REFERENCES test_sets(id) ON DELETE CASCADE,
    total_questions INTEGER NOT NULL,
    correct_answers INTEGER NOT NULL,
    score_percentage DECIMAL(5,2) NOT NULL,
    time_taken_minutes INTEGER NOT NULL,
    completion_status VARCHAR(20) DEFAULT 'completed',
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- AI COUNSELING SYSTEM
-- ============================================================================

-- AI Generated Reports
CREATE TABLE ai_reports (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    test_result_id INTEGER REFERENCES test_results(id) ON DELETE CASCADE,
    report_type VARCHAR(50) NOT NULL DEFAULT 'career_guidance',
    ai_analysis JSONB NOT NULL, -- Detailed AI analysis
    career_recommendations JSONB, -- Career suggestions
    strengths JSONB, -- Student strengths
    improvement_areas JSONB, -- Areas for improvement
    confidence_score DECIMAL(3,2), -- AI confidence in analysis
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_reviewed BOOLEAN DEFAULT false,
    reviewed_by INTEGER REFERENCES teachers(id),
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Human Counseling Sessions
CREATE TABLE counseling_sessions (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    counselor_name VARCHAR(255) NOT NULL,
    counselor_email VARCHAR(255),
    counselor_phone VARCHAR(20),
    session_type VARCHAR(50) NOT NULL DEFAULT 'career_counseling',
    session_mode VARCHAR(20) NOT NULL DEFAULT 'online', -- online, offline, phone
    scheduled_at TIMESTAMP NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    session_status VARCHAR(20) DEFAULT 'scheduled', -- scheduled, completed, cancelled, rescheduled
    session_notes TEXT,
    payment_amount DECIMAL(10,2),
    payment_status VARCHAR(20) DEFAULT 'pending', -- pending, paid, refunded
    payment_id VARCHAR(255),
    meeting_link VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

-- Primary indexes for user tables
CREATE INDEX idx_students_email ON students(email);
CREATE INDEX idx_students_education_category ON students(education_category);
CREATE INDEX idx_students_verification ON students(is_verified, verification_token);
CREATE INDEX idx_students_created_at ON students(created_at);

CREATE INDEX idx_parents_email ON parents(email);
CREATE INDEX idx_parents_student_id ON parents(student_registration_id);
CREATE INDEX idx_parents_relationship ON parents(relationship_type);

CREATE INDEX idx_teachers_email ON teachers(email);
CREATE INDEX idx_teachers_employee_id ON teachers(employee_id);
CREATE INDEX idx_teachers_access_level ON teachers(access_level);
CREATE INDEX idx_teachers_institution ON teachers(institution_name);

-- Indexes for test system
CREATE INDEX idx_test_sets_category ON test_sets(category_id);
CREATE INDEX idx_test_questions_set ON test_questions(test_set_id);
CREATE INDEX idx_user_responses_student ON user_responses(student_id);
CREATE INDEX idx_user_responses_test_set ON user_responses(test_set_id);
CREATE INDEX idx_test_results_student ON test_results(student_id);
CREATE INDEX idx_test_results_completion ON test_results(completion_status, completed_at);

-- Indexes for AI and counseling
CREATE INDEX idx_ai_reports_student ON ai_reports(student_id);
CREATE INDEX idx_ai_reports_type ON ai_reports(report_type);
CREATE INDEX idx_counseling_sessions_student ON counseling_sessions(student_id);
CREATE INDEX idx_counseling_sessions_status ON counseling_sessions(session_status);
CREATE INDEX idx_counseling_sessions_scheduled ON counseling_sessions(scheduled_at);

-- ============================================================================
-- INITIAL DATA SETUP
-- ============================================================================

-- Insert Education Categories
INSERT INTO categories (name, display_name, description, min_age, max_age) VALUES
('tenth_fail', '10th Fail', 'Students who have not passed 10th grade', 14, 18),
('tenth_pass', '10th Pass', 'Students who have passed 10th grade', 15, 19),
('twelfth_fail', '12th Fail', 'Students who have not passed 12th grade', 16, 20),
('twelfth_pass', '12th Pass', 'Students who have passed 12th grade', 17, 21),
('diploma', 'Diploma', 'Students pursuing or completed diploma courses', 17, 25),
('undergraduate', 'Undergraduate', 'Students pursuing bachelor''s degree', 18, 25),
('graduate', 'Graduate', 'Students who have completed bachelor''s degree', 21, 30),
('postgraduate', 'Postgraduate', 'Students pursuing or completed master''s degree', 22, 35);

-- Create Test Sets (4 sets per category)
INSERT INTO test_sets (category_id, set_number, name, description, duration_minutes, total_questions)
SELECT 
    c.id,
    s.set_num,
    c.display_name || ' - Set ' || s.set_num,
    'Psychometric test set ' || s.set_num || ' for ' || c.display_name || ' students',
    60,
    50
FROM categories c
CROSS JOIN (SELECT generate_series(1, 4) as set_num) s;

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at
CREATE TRIGGER update_students_updated_at BEFORE UPDATE ON students FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_parents_updated_at BEFORE UPDATE ON parents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_teachers_updated_at BEFORE UPDATE ON teachers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_test_sets_updated_at BEFORE UPDATE ON test_sets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_test_questions_updated_at BEFORE UPDATE ON test_questions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_test_results_updated_at BEFORE UPDATE ON test_results FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ai_reports_updated_at BEFORE UPDATE ON ai_reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_counseling_sessions_updated_at BEFORE UPDATE ON counseling_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- VERIFICATION AND SUMMARY
-- ============================================================================

-- Display created tables
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public' 
ORDER BY tablename;

-- Display table sizes
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE schemaname = 'public'
ORDER BY tablename, attname;

-- Success message
SELECT 'PathfinderAI Database Setup Completed Successfully!' as status;
