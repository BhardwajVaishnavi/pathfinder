# NeonDB PostgreSQL Deployment Guide

## 🗄️ Your Database Configuration

### Connection Details
```
Pooled Connection (Recommended):
postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require

Unpooled Connection (For Prisma <5.10):
postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6.us-east-1.aws.neon.tech/neondb?sslmode=require
```

### Database Details
- **Host (Pooled)**: ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech
- **Host (Unpooled)**: ep-soft-sky-a4h1bku6.us-east-1.aws.neon.tech
- **Database**: neondb
- **Username**: neondb_owner
- **Password**: npg_hPHsRAyS2XV5
- **SSL Mode**: require

## 🚀 Deployment Steps

### 1. Set Up Serverless API (Vercel)

#### Install Dependencies
```bash
npm init -y
npm install pg cors
npm install -D @vercel/node
```

#### Create vercel.json
```json
{
  "functions": {
    "api/database.js": {
      "runtime": "@vercel/node"
    }
  },
  "env": {
    "API_KEY": "your-secure-api-key-here"
  }
}
```

#### Deploy to Vercel
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables
vercel env add API_KEY
```

### 2. Update Flutter App

#### Update NeonDBService
```dart
// Update API endpoint in lib/services/neondb_service.dart
static const String _apiEndpoint = 'https://your-pathfinder-api.vercel.app/api/database';
```

#### Update Environment Configuration
```dart
// Create lib/config/environment.dart
class Environment {
  static const String apiEndpoint = String.fromEnvironment(
    'API_ENDPOINT',
    defaultValue: 'https://your-pathfinder-api.vercel.app/api/database',
  );
  
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'your-secure-api-key',
  );
}
```

### 3. Database Schema Setup

#### Connect to NeonDB
```bash
# Using psql
psql "postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require"
```

#### Create Tables
```sql
-- Students table
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

-- Parents table
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

-- Teachers table
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

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_students_email ON students(email);
CREATE INDEX IF NOT EXISTS idx_parents_email ON parents(email);
CREATE INDEX IF NOT EXISTS idx_teachers_email ON teachers(email);
CREATE INDEX IF NOT EXISTS idx_teachers_employee_id ON teachers(employee_id);
```

### 4. Testing the Connection

#### Test API Endpoint
```bash
curl -X POST https://your-pathfinder-api.vercel.app/api/database \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-secure-api-key" \
  -d '{
    "sql": "SELECT COUNT(*) as total FROM students",
    "connectionType": "pooled",
    "operation": "test_connection"
  }'
```

#### Test from Flutter
```dart
// Test in your Flutter app
final authService = MultiUserAuthService();
await authService.initialize();

// Try registering a test student
final user = await authService.registerStudent(
  fullName: 'Test User',
  email: 'test@example.com',
  // ... other parameters
);
```

### 5. Production Considerations

#### Security
- ✅ Use environment variables for sensitive data
- ✅ Implement API key authentication
- ✅ Enable CORS for your domain only
- ✅ Use HTTPS for all connections
- ✅ Implement rate limiting

#### Performance
- ✅ Use pooled connections for better performance
- ✅ Implement connection pooling
- ✅ Add database indexes for frequently queried fields
- ✅ Use prepared statements to prevent SQL injection
- ✅ Implement caching for read-heavy operations

#### Monitoring
- ✅ Set up logging for database operations
- ✅ Monitor connection pool usage
- ✅ Track query performance
- ✅ Set up alerts for errors
- ✅ Monitor database resource usage

### 6. Backup and Recovery

#### Automated Backups
```bash
# NeonDB provides automatic backups
# Configure backup retention in NeonDB console
```

#### Manual Backup
```bash
pg_dump "postgresql://neondb_owner:npg_hPHsRAyS2XV5@ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require" > backup.sql
```

### 7. Scaling Considerations

#### Connection Limits
- Pooled connection: Higher connection limits
- Unpooled connection: Lower connection limits
- Use connection pooling in production

#### Read Replicas
- Consider read replicas for read-heavy workloads
- Use unpooled connection for read replicas

#### Caching
- Implement Redis for session management
- Cache frequently accessed data
- Use CDN for static assets

## 🔧 Troubleshooting

### Common Issues

#### Connection Timeout
```
Solution: Use pooled connection and implement retry logic
```

#### SSL Certificate Issues
```
Solution: Ensure sslmode=require in connection string
```

#### Connection Pool Exhaustion
```
Solution: Implement proper connection management and pooling
```

#### Query Performance
```
Solution: Add appropriate indexes and optimize queries
```

## 📊 Monitoring Dashboard

### Key Metrics to Monitor
- Connection count
- Query execution time
- Error rates
- Database size
- Active sessions
- Cache hit ratio

### Recommended Tools
- NeonDB Console
- Vercel Analytics
- Sentry for error tracking
- DataDog for comprehensive monitoring

## 🎯 Next Steps

1. **Deploy API to Vercel**
2. **Update Flutter app configuration**
3. **Create database tables**
4. **Test end-to-end functionality**
5. **Set up monitoring and alerts**
6. **Implement backup strategy**
7. **Optimize for production load**

Your NeonDB PostgreSQL integration is now ready for production deployment! 🚀
