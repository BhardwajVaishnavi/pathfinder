# PathfinderAI Database Generator

## 🗄️ Generate Your NeonDB PostgreSQL Database

This script will connect to your actual NeonDB PostgreSQL instance and create all the necessary tables for the PathfinderAI application.

### 📋 Your Database Details

```
Pooled Connection:
postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require

Unpooled Connection:
postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6.us-east-1.aws.neon.tech/neondb?sslmode=require
```

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd scripts
npm install
```

### 2. Test Connection

```bash
npm run test-connection
```

This will verify that your NeonDB connection is working properly.

### 3. Generate Database

```bash
npm run generate
```

This will create all tables, indexes, and initial data in your NeonDB instance.

## 📊 What Gets Created

### 🏗️ Database Tables

#### **User Management**
- `students` - Student profiles and authentication
- `parents` - Parent/guardian information
- `teachers` - Teacher profiles and access levels

#### **Psychometric Test System**
- `categories` - Education level categories (10th fail/pass, 12th fail/pass, etc.)
- `test_sets` - 4 test sets per category (32 total test sets)
- `test_questions` - Individual questions for each test set
- `user_responses` - Student answers and response tracking
- `test_results` - Test completion summaries and scores

#### **AI Counseling System**
- `ai_reports` - AI-generated career guidance reports
- `counseling_sessions` - Human counselor booking and session management

### 🔍 Performance Indexes

```sql
-- User table indexes
CREATE INDEX idx_students_email ON students(email);
CREATE INDEX idx_students_education_category ON students(education_category);
CREATE INDEX idx_parents_student_id ON parents(student_registration_id);
CREATE INDEX idx_teachers_employee_id ON teachers(employee_id);

-- Test system indexes
CREATE INDEX idx_test_sets_category ON test_sets(category_id);
CREATE INDEX idx_user_responses_student ON user_responses(student_id);
CREATE INDEX idx_test_results_completion ON test_results(completion_status);

-- AI and counseling indexes
CREATE INDEX idx_ai_reports_student ON ai_reports(student_id);
CREATE INDEX idx_counseling_sessions_status ON counseling_sessions(session_status);
```

### 📚 Initial Data

#### **Education Categories**
- 10th Fail (ages 14-18)
- 10th Pass (ages 15-19)
- 12th Fail (ages 16-20)
- 12th Pass (ages 17-21)
- Diploma (ages 17-25)
- Undergraduate (ages 18-25)
- Graduate (ages 21-30)
- Postgraduate (ages 22-35)

#### **Test Sets**
- 4 test sets per education category
- 32 total test sets
- 50 questions per test set
- 60-minute duration per test

## 🛠️ Advanced Usage

### Use Unpooled Connection

```bash
npm run generate:unpooled
```

### Manual SQL Execution

You can also run the SQL script manually:

```bash
psql "postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require" -f setup_database.sql
```

## 📊 Verification

After running the generator, you can verify the setup:

### Check Tables

```sql
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
```

### Check Data

```sql
-- Education categories
SELECT * FROM categories;

-- Test sets
SELECT c.display_name, COUNT(ts.id) as test_sets
FROM categories c
LEFT JOIN test_sets ts ON c.id = ts.category_id
GROUP BY c.id, c.display_name
ORDER BY c.id;
```

### Check Indexes

```sql
SELECT indexname FROM pg_indexes WHERE schemaname = 'public' ORDER BY indexname;
```

## 🔧 Troubleshooting

### Connection Issues

If you get connection errors:

1. **Check Internet Connection**
   ```bash
   ping ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech
   ```

2. **Verify Credentials**
   - Ensure the connection string is correct
   - Check if your NeonDB instance is active

3. **SSL Issues**
   - The script uses `rejectUnauthorized: false` for SSL
   - This is safe for NeonDB connections

### Permission Issues

If you get permission errors:

1. **Check User Permissions**
   ```sql
   SELECT * FROM information_schema.role_table_grants WHERE grantee = 'neondb_owner';
   ```

2. **Verify Database Access**
   ```sql
   SELECT current_user, current_database();
   ```

### Table Already Exists

If tables already exist, the script will:
- Drop existing tables (with CASCADE)
- Recreate them with fresh structure
- This ensures a clean setup

## 📱 Flutter App Integration

After generating the database, your Flutter app can connect using:

### Update NeonDBService

```dart
// In lib/services/neondb_service.dart
static const String _apiEndpoint = 'https://your-pathfinder-api.vercel.app/api/database';
```

### Test Registration

1. Run your Flutter app
2. Navigate to the test registration screen
3. Try registering a student, parent, or teacher
4. Data will be saved to your real NeonDB instance

## 🎯 Next Steps

1. **✅ Generate Database** - Run this script
2. **🚀 Deploy API** - Deploy the Vercel serverless function
3. **📱 Update Flutter** - Point to your API endpoint
4. **🧪 Test End-to-End** - Verify complete functionality
5. **📊 Monitor Usage** - Set up database monitoring

## 📞 Support

If you encounter any issues:

1. Check the console output for detailed error messages
2. Verify your NeonDB instance is active
3. Ensure your connection string is correct
4. Test with the connection test script first

## 🎉 Success!

Once completed, you'll have:
- ✅ Complete PathfinderAI database schema
- ✅ All necessary tables and relationships
- ✅ Performance-optimized indexes
- ✅ Initial education categories and test sets
- ✅ Ready for production use

Your PathfinderAI app is now ready to use real PostgreSQL data! 🚀
