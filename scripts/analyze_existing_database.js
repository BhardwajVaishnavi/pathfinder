#!/usr/bin/env node

/**
 * Analyze Existing NeonDB Structure
 * Check what tables and data already exist
 */

const { Client } = require('pg');

const connectionConfig = {
  host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
  database: 'neondb',
  user: 'neondb_owner',
  password: 'npg_hPHsRAyS2XV5',
  port: 5432,
  ssl: {
    rejectUnauthorized: false
  }
};

async function analyzeDatabase() {
  console.log('🔍 Analyzing Your Existing NeonDB Structure');
  console.log('==========================================');
  console.log('');

  const client = new Client(connectionConfig);

  try {
    await client.connect();
    console.log('✅ Connected to NeonDB');
    console.log('');

    // Get detailed table information
    const tablesQuery = `
      SELECT 
        t.table_name,
        t.table_type,
        (SELECT COUNT(*) FROM information_schema.columns c WHERE c.table_name = t.table_name) as column_count
      FROM information_schema.tables t
      WHERE t.table_schema = 'public'
      ORDER BY t.table_name
    `;

    const tablesResult = await client.query(tablesQuery);
    
    console.log(`📋 Found ${tablesResult.rows.length} tables in your database:`);
    console.log('');

    for (const table of tablesResult.rows) {
      console.log(`📄 ${table.table_name} (${table.column_count} columns)`);
      
      // Get column details
      const columnsQuery = `
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_name = $1
        ORDER BY ordinal_position
      `;
      
      const columnsResult = await client.query(columnsQuery, [table.table_name]);
      
      columnsResult.rows.forEach(col => {
        const nullable = col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
        const defaultVal = col.column_default ? ` DEFAULT ${col.column_default}` : '';
        console.log(`   • ${col.column_name}: ${col.data_type} ${nullable}${defaultVal}`);
      });

      // Get row count
      try {
        const countResult = await client.query(`SELECT COUNT(*) as count FROM ${table.table_name}`);
        console.log(`   📊 Rows: ${countResult.rows[0].count}`);
      } catch (error) {
        console.log(`   📊 Rows: Unable to count (${error.message})`);
      }
      
      console.log('');
    }

    // Check for indexes
    const indexesQuery = `
      SELECT indexname, tablename, indexdef
      FROM pg_indexes
      WHERE schemaname = 'public'
      AND indexname NOT LIKE '%_pkey'
      ORDER BY tablename, indexname
    `;

    const indexesResult = await client.query(indexesQuery);
    
    console.log(`🔍 Found ${indexesResult.rows.length} custom indexes:`);
    indexesResult.rows.forEach(idx => {
      console.log(`   • ${idx.indexname} on ${idx.tablename}`);
    });
    console.log('');

    // Check for foreign keys
    const fkQuery = `
      SELECT
        tc.table_name,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
      FROM information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
        AND tc.table_schema = kcu.table_schema
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
        AND ccu.table_schema = tc.table_schema
      WHERE tc.constraint_type = 'FOREIGN KEY'
        AND tc.table_schema = 'public'
      ORDER BY tc.table_name, kcu.column_name
    `;

    const fkResult = await client.query(fkQuery);
    
    console.log(`🔗 Found ${fkResult.rows.length} foreign key relationships:`);
    fkResult.rows.forEach(fk => {
      console.log(`   • ${fk.table_name}.${fk.column_name} → ${fk.foreign_table_name}.${fk.foreign_column_name}`);
    });
    console.log('');

    // Check specific PathfinderAI tables
    const pathfinderTables = [
      'students', 'parents', 'teachers',
      'education_categories', 'test_sets', 'questions',
      'user_responses', 'test_attempts', 'reports',
      'counseling_sessions', 'ai_reports'
    ];

    console.log('🎯 PathfinderAI Table Status:');
    console.log('============================');

    for (const tableName of pathfinderTables) {
      const exists = tablesResult.rows.find(t => t.table_name === tableName);
      if (exists) {
        const countResult = await client.query(`SELECT COUNT(*) as count FROM ${tableName}`);
        console.log(`✅ ${tableName} - ${countResult.rows[0].count} records`);
      } else {
        console.log(`❌ ${tableName} - Missing`);
      }
    }
    console.log('');

    // Sample data from key tables
    console.log('📊 Sample Data:');
    console.log('===============');

    // Students sample
    try {
      const studentsResult = await client.query('SELECT id, name, email, education_category FROM students LIMIT 3');
      if (studentsResult.rows.length > 0) {
        console.log('👥 Students:');
        studentsResult.rows.forEach(student => {
          console.log(`   • ID: ${student.id}, Name: ${student.name}, Email: ${student.email}, Category: ${student.education_category || 'N/A'}`);
        });
      }
    } catch (error) {
      console.log('👥 Students: No data or table structure different');
    }

    // Education categories sample
    try {
      const categoriesResult = await client.query('SELECT * FROM education_categories LIMIT 5');
      if (categoriesResult.rows.length > 0) {
        console.log('📚 Education Categories:');
        categoriesResult.rows.forEach(cat => {
          console.log(`   • ${cat.name || cat.category_name}: ${cat.display_name || cat.description || 'No description'}`);
        });
      }
    } catch (error) {
      console.log('📚 Education Categories: No data or table structure different');
    }

    // Test sets sample
    try {
      const testSetsResult = await client.query('SELECT id, name, category_id FROM test_sets LIMIT 5');
      if (testSetsResult.rows.length > 0) {
        console.log('📝 Test Sets:');
        testSetsResult.rows.forEach(test => {
          console.log(`   • ID: ${test.id}, Name: ${test.name}, Category: ${test.category_id || 'N/A'}`);
        });
      }
    } catch (error) {
      console.log('📝 Test Sets: No data or table structure different');
    }

    console.log('');
    console.log('🎯 Analysis Complete!');
    console.log('');
    console.log('💡 Recommendations:');
    console.log('   1. Your database already has a good structure');
    console.log('   2. Check if the existing tables match your Flutter app models');
    console.log('   3. You may need to update your Flutter app to use existing table structure');
    console.log('   4. Or modify existing tables to match your new requirements');

  } catch (error) {
    console.error('❌ Analysis failed:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Connection closed');
  }
}

analyzeDatabase();
