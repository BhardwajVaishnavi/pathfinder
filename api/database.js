// Vercel Serverless Function for NeonDB PostgreSQL Operations
// Deploy this to Vercel to enable real database operations from your Flutter app

import { Client } from 'pg';
import cors from 'cors';

// CORS configuration
const corsOptions = {
  origin: ['http://localhost:8080', 'https://your-flutter-app.vercel.app'],
  methods: ['POST'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

// Database configuration using your actual NeonDB credentials
const dbConfig = {
  // Use pooled connection for better performance
  pooled: {
    host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
    database: 'neondb',
    user: 'neondb_owner',
    password: 'npg_hPHsRAyS2XV5',
    ssl: { rejectUnauthorized: false },
    port: 5432,
  },
  // Use unpooled connection for migrations or direct access
  unpooled: {
    host: 'ep-soft-sky-a4h1bku6.us-east-1.aws.neon.tech',
    database: 'neondb',
    user: 'neondb_owner',
    password: 'npg_hPHsRAyS2XV5',
    ssl: { rejectUnauthorized: false },
    port: 5432,
  }
};

// API Key for security (set this in your Vercel environment variables)
const API_KEY = process.env.API_KEY || 'your-secure-api-key';

export default async function handler(req, res) {
  // Enable CORS
  await cors(corsOptions)(req, res, () => {});

  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    // Verify API key
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Missing or invalid authorization header' });
    }

    const token = authHeader.split(' ')[1];
    if (token !== API_KEY) {
      return res.status(401).json({ error: 'Invalid API key' });
    }

    // Extract request data
    const { sql, parameters = {}, connectionType = 'pooled', operation } = req.body;

    if (!sql) {
      return res.status(400).json({ error: 'SQL query is required' });
    }

    // Choose connection type
    const config = connectionType === 'unpooled' ? dbConfig.unpooled : dbConfig.pooled;
    
    // Create database client
    const client = new Client(config);

    try {
      // Connect to database
      await client.connect();
      console.log(`✅ Connected to NeonDB (${connectionType})`);

      // Execute query
      let result;
      if (Object.keys(parameters).length > 0) {
        // Use parameterized query for security
        const paramValues = Object.keys(parameters).sort().map(key => parameters[key]);
        result = await client.query(sql, paramValues);
      } else {
        result = await client.query(sql);
      }

      console.log(`✅ Query executed successfully: ${operation || 'unknown'}`);

      // Return results
      res.status(200).json({
        success: true,
        rows: result.rows,
        rowCount: result.rowCount,
        command: result.command,
        connectionType,
        timestamp: new Date().toISOString(),
      });

    } catch (dbError) {
      console.error('❌ Database error:', dbError);
      res.status(500).json({
        error: 'Database operation failed',
        message: dbError.message,
        code: dbError.code,
      });
    } finally {
      // Always close the connection
      await client.end();
      console.log('🔌 Database connection closed');
    }

  } catch (error) {
    console.error('❌ API error:', error);
    res.status(500).json({
      error: 'Internal server error',
      message: error.message,
    });
  }
}

// Example usage from Flutter:
/*
final response = await http.post(
  Uri.parse('https://your-api.vercel.app/api/database'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your-secure-api-key',
  },
  body: jsonEncode({
    'sql': 'INSERT INTO students (name, email, phone) VALUES ($1, $2, $3) RETURNING id',
    'parameters': {
      '1': 'John Doe',
      '2': 'john@example.com',
      '3': '1234567890',
    },
    'connectionType': 'pooled',
    'operation': 'insert_student',
  }),
);
*/

// Database initialization queries
export const initQueries = {
  createStudentsTable: `
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
  `,
  
  createParentsTable: `
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
  `,
  
  createTeachersTable: `
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
  `,
  
  createIndexes: [
    'CREATE INDEX IF NOT EXISTS idx_students_email ON students(email);',
    'CREATE INDEX IF NOT EXISTS idx_parents_email ON parents(email);',
    'CREATE INDEX IF NOT EXISTS idx_teachers_email ON teachers(email);',
    'CREATE INDEX IF NOT EXISTS idx_teachers_employee_id ON teachers(employee_id);',
    'CREATE INDEX IF NOT EXISTS idx_students_education_category ON students(education_category);',
    'CREATE INDEX IF NOT EXISTS idx_parents_relationship ON parents(relationship_type);',
    'CREATE INDEX IF NOT EXISTS idx_teachers_access_level ON teachers(access_level);',
  ]
};
