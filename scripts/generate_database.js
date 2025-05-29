#!/usr/bin/env node

/**
 * PathfinderAI Database Generator
 * Connects to your NeonDB PostgreSQL instance and creates all necessary tables
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// Your actual NeonDB connection details
const connectionConfig = {
  // Use pooled connection for better performance
  host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
  database: 'neondb',
  user: 'neondb_owner',
  password: 'npg_hPHsRAyS2XV5',
  port: 5432,
  ssl: {
    rejectUnauthorized: false
  }
};

// Alternative unpooled connection (if needed)
const unpooledConfig = {
  host: 'ep-soft-sky-a4h1bku6.us-east-1.aws.neon.tech',
  database: 'neondb',
  user: 'neondb_owner',
  password: 'npg_hPHsRAyS2XV5',
  port: 5432,
  ssl: {
    rejectUnauthorized: false
  }
};

async function generateDatabase() {
  console.log('🚀 PathfinderAI Database Generator');
  console.log('=====================================');
  console.log('🔗 Connecting to your NeonDB PostgreSQL instance...');
  console.log(`🏠 Host: ${connectionConfig.host}`);
  console.log(`🗄️ Database: ${connectionConfig.database}`);
  console.log(`👤 User: ${connectionConfig.user}`);
  console.log('🔐 SSL: Enabled');
  console.log('');

  const client = new Client(connectionConfig);

  try {
    // Connect to database
    await client.connect();
    console.log('✅ Successfully connected to NeonDB!');
    console.log('');

    // Read SQL setup script
    const sqlFilePath = path.join(__dirname, 'setup_database.sql');
    const sqlScript = fs.readFileSync(sqlFilePath, 'utf8');

    console.log('📋 Executing database setup script...');
    console.log('');

    // Split SQL script into individual statements
    const statements = sqlScript
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'));

    let successCount = 0;
    let errorCount = 0;

    // Execute each statement
    for (let i = 0; i < statements.length; i++) {
      const statement = statements[i];
      
      if (statement.length === 0) continue;

      try {
        console.log(`⏳ Executing statement ${i + 1}/${statements.length}...`);
        
        const result = await client.query(statement);
        
        // Log specific results for certain operations
        if (statement.toLowerCase().includes('create table')) {
          const tableName = extractTableName(statement);
          console.log(`✅ Created table: ${tableName}`);
        } else if (statement.toLowerCase().includes('create index')) {
          const indexName = extractIndexName(statement);
          console.log(`✅ Created index: ${indexName}`);
        } else if (statement.toLowerCase().includes('insert into')) {
          console.log(`✅ Inserted data: ${result.rowCount} rows affected`);
        } else if (statement.toLowerCase().includes('select')) {
          if (result.rows && result.rows.length > 0) {
            console.log(`✅ Query result: ${result.rows.length} rows returned`);
            // Display first few rows for verification queries
            if (result.rows.length <= 10) {
              result.rows.forEach(row => {
                console.log(`   📊 ${JSON.stringify(row)}`);
              });
            }
          }
        } else {
          console.log(`✅ Statement executed successfully`);
        }
        
        successCount++;
        
      } catch (error) {
        console.error(`❌ Error executing statement ${i + 1}:`);
        console.error(`   SQL: ${statement.substring(0, 100)}...`);
        console.error(`   Error: ${error.message}`);
        errorCount++;
        
        // Continue with other statements unless it's a critical error
        if (error.message.includes('already exists')) {
          console.log(`   ℹ️  Object already exists, continuing...`);
        }
      }
    }

    console.log('');
    console.log('📊 Database Generation Summary:');
    console.log('===============================');
    console.log(`✅ Successful operations: ${successCount}`);
    console.log(`❌ Failed operations: ${errorCount}`);
    console.log('');

    // Verify database structure
    console.log('🔍 Verifying database structure...');
    await verifyDatabaseStructure(client);

    console.log('');
    console.log('🎉 Database generation completed!');
    console.log('');
    console.log('📋 Your PathfinderAI database now includes:');
    console.log('   👥 User management (students, parents, teachers)');
    console.log('   📝 Psychometric test system');
    console.log('   🤖 AI counseling and reports');
    console.log('   📊 Analytics and performance tracking');
    console.log('   🔍 Optimized indexes for performance');
    console.log('');
    console.log('🚀 Your Flutter app can now connect to the real database!');

  } catch (error) {
    console.error('❌ Database generation failed:');
    console.error(error.message);
    process.exit(1);
  } finally {
    await client.end();
    console.log('🔌 Database connection closed');
  }
}

async function verifyDatabaseStructure(client) {
  try {
    // Get list of tables
    const tablesResult = await client.query(`
      SELECT tablename 
      FROM pg_tables 
      WHERE schemaname = 'public' 
      ORDER BY tablename
    `);

    console.log(`📋 Created ${tablesResult.rows.length} tables:`);
    tablesResult.rows.forEach(row => {
      console.log(`   📄 ${row.tablename}`);
    });

    // Get list of indexes
    const indexesResult = await client.query(`
      SELECT indexname 
      FROM pg_indexes 
      WHERE schemaname = 'public' 
      AND indexname NOT LIKE '%_pkey'
      ORDER BY indexname
    `);

    console.log(`🔍 Created ${indexesResult.rows.length} indexes:`);
    indexesResult.rows.forEach(row => {
      console.log(`   🔍 ${row.indexname}`);
    });

    // Check categories data
    const categoriesResult = await client.query('SELECT COUNT(*) as count FROM categories');
    console.log(`📚 Education categories: ${categoriesResult.rows[0].count}`);

    // Check test sets data
    const testSetsResult = await client.query('SELECT COUNT(*) as count FROM test_sets');
    console.log(`📝 Test sets: ${testSetsResult.rows[0].count}`);

  } catch (error) {
    console.error('❌ Error verifying database structure:', error.message);
  }
}

function extractTableName(statement) {
  const match = statement.match(/CREATE TABLE\s+(\w+)/i);
  return match ? match[1] : 'unknown';
}

function extractIndexName(statement) {
  const match = statement.match(/CREATE INDEX\s+(\w+)/i);
  return match ? match[1] : 'unknown';
}

// Handle command line arguments
if (process.argv.includes('--help') || process.argv.includes('-h')) {
  console.log('PathfinderAI Database Generator');
  console.log('');
  console.log('Usage: node generate_database.js [options]');
  console.log('');
  console.log('Options:');
  console.log('  --help, -h     Show this help message');
  console.log('  --unpooled     Use unpooled connection instead of pooled');
  console.log('');
  console.log('This script will connect to your NeonDB PostgreSQL instance and');
  console.log('create all necessary tables for the PathfinderAI application.');
  process.exit(0);
}

if (process.argv.includes('--unpooled')) {
  console.log('🔄 Using unpooled connection...');
  Object.assign(connectionConfig, unpooledConfig);
}

// Run the database generation
generateDatabase().catch(error => {
  console.error('💥 Unexpected error:', error);
  process.exit(1);
});
