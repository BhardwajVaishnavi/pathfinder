#!/usr/bin/env node

/**
 * NeonDB Connection Test
 * Tests connection to your PostgreSQL database
 */

const { Client } = require('pg');

// Your actual NeonDB connection details
const pooledConfig = {
  host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
  database: 'neondb',
  user: 'neondb_owner',
  password: 'npg_hPHsRAyS2XV5',
  port: 5432,
  ssl: {
    rejectUnauthorized: false
  }
};

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

async function testConnection(config, connectionType) {
  console.log(`🔗 Testing ${connectionType} connection...`);
  console.log(`🏠 Host: ${config.host}`);
  console.log(`🗄️ Database: ${config.database}`);
  console.log(`👤 User: ${config.user}`);
  console.log('');

  const client = new Client(config);

  try {
    // Connect to database
    const startTime = Date.now();
    await client.connect();
    const connectTime = Date.now() - startTime;
    
    console.log(`✅ ${connectionType} connection successful! (${connectTime}ms)`);

    // Test basic query
    const queryStart = Date.now();
    const result = await client.query('SELECT version(), current_database(), current_user, now()');
    const queryTime = Date.now() - queryStart;

    console.log(`✅ Database query successful! (${queryTime}ms)`);
    console.log('');
    console.log('📊 Database Information:');
    console.log(`   Version: ${result.rows[0].version.split(' ').slice(0, 2).join(' ')}`);
    console.log(`   Database: ${result.rows[0].current_database}`);
    console.log(`   User: ${result.rows[0].current_user}`);
    console.log(`   Server Time: ${result.rows[0].now}`);
    console.log('');

    // Test table existence
    const tablesResult = await client.query(`
      SELECT COUNT(*) as table_count 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `);

    console.log(`📋 Existing tables: ${tablesResult.rows[0].table_count}`);

    // If tables exist, show them
    if (parseInt(tablesResult.rows[0].table_count) > 0) {
      const tableListResult = await client.query(`
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public' 
        ORDER BY tablename
      `);

      console.log('📄 Table list:');
      tableListResult.rows.forEach(row => {
        console.log(`   • ${row.tablename}`);
      });
    }

    return true;

  } catch (error) {
    console.error(`❌ ${connectionType} connection failed:`);
    console.error(`   Error: ${error.message}`);
    console.error(`   Code: ${error.code}`);
    return false;
  } finally {
    await client.end();
    console.log(`🔌 ${connectionType} connection closed`);
    console.log('');
  }
}

async function runTests() {
  console.log('🧪 NeonDB Connection Test');
  console.log('=========================');
  console.log('');

  let pooledSuccess = false;
  let unpooledSuccess = false;

  try {
    // Test pooled connection
    pooledSuccess = await testConnection(pooledConfig, 'Pooled');
    
    // Test unpooled connection
    unpooledSuccess = await testConnection(unpooledConfig, 'Unpooled');

    // Summary
    console.log('📊 Connection Test Summary:');
    console.log('===========================');
    console.log(`🔗 Pooled Connection: ${pooledSuccess ? '✅ Success' : '❌ Failed'}`);
    console.log(`🔗 Unpooled Connection: ${unpooledSuccess ? '✅ Success' : '❌ Failed'}`);
    console.log('');

    if (pooledSuccess || unpooledSuccess) {
      console.log('🎉 Your NeonDB connection is working!');
      console.log('');
      console.log('🚀 Next steps:');
      console.log('   1. Run: npm run generate');
      console.log('   2. This will create all PathfinderAI tables');
      console.log('   3. Your Flutter app can then connect to the real database');
    } else {
      console.log('❌ Both connections failed. Please check:');
      console.log('   1. Your internet connection');
      console.log('   2. NeonDB credentials');
      console.log('   3. Database availability');
    }

  } catch (error) {
    console.error('💥 Unexpected error during testing:', error);
    process.exit(1);
  }
}

// Run the tests
runTests();
