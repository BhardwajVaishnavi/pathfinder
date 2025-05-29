#!/usr/bin/env node

const { Client } = require('pg');

const client = new Client({
  host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
  database: 'neondb',
  user: 'neondb_owner',
  password: 'npg_hPHsRAyS2XV5',
  port: 5432,
  ssl: { rejectUnauthorized: false }
});

async function checkQuestions() {
  try {
    await client.connect();
    console.log('✅ Connected to NeonDB');
    console.log('');
    
    console.log('🔍 Checking Questions and Test Data...');
    console.log('=====================================');
    
    // Check education categories
    const categories = await client.query('SELECT * FROM education_categories ORDER BY id');
    console.log(`📚 Education Categories (${categories.rows.length}):`);
    categories.rows.forEach(cat => {
      console.log(`   • ${cat.category_code}: ${cat.display_name}`);
    });
    console.log('');
    
    // Check test sets
    const testSets = await client.query(`
      SELECT ts.*, ec.display_name as category_name 
      FROM test_sets ts 
      LEFT JOIN education_categories ec ON ts.category_id = ec.id 
      ORDER BY ts.category_id, ts.set_number
    `);
    console.log(`📝 Test Sets (${testSets.rows.length}):`);
    testSets.rows.forEach(ts => {
      console.log(`   • Set ${ts.set_number} for ${ts.category_name || 'Unknown'} (ID: ${ts.id})`);
    });
    console.log('');
    
    // Check questions
    const questionCount = await client.query('SELECT COUNT(*) as count FROM questions');
    console.log(`❓ Questions: ${questionCount.rows[0].count} total`);
    
    if (parseInt(questionCount.rows[0].count) > 0) {
      const sampleQuestions = await client.query('SELECT * FROM questions LIMIT 5');
      console.log('📋 Sample Questions:');
      sampleQuestions.rows.forEach(q => {
        console.log(`   • Q${q.id}: ${q.question_text.substring(0, 50)}...`);
        console.log(`     Type: ${q.question_type}, Options: A) ${q.option_a} B) ${q.option_b}`);
      });
    } else {
      console.log('❌ No questions found in database!');
      console.log('');
      console.log('💡 Your database structure is ready but needs questions populated.');
      console.log('   I can generate psychometric test questions for all categories.');
    }
    
    // Check question banks
    const questionBanks = await client.query('SELECT COUNT(*) as count FROM question_banks');
    console.log(`🏦 Question Banks: ${questionBanks.rows[0].count} total`);
    
    console.log('');
    console.log('📊 Summary:');
    console.log(`   ✅ ${categories.rows.length} Education Categories`);
    console.log(`   ✅ ${testSets.rows.length} Test Sets`);
    console.log(`   ✅ ${questionBanks.rows[0].count} Question Banks`);
    console.log(`   ${parseInt(questionCount.rows[0].count) > 0 ? '✅' : '❌'} ${questionCount.rows[0].count} Questions`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

checkQuestions();
