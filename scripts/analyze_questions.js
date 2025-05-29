const { Client } = require('pg');

async function analyzeQuestions() {
  const client = new Client({
    host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
    database: 'neondb',
    user: 'neondb_owner',
    password: 'npg_hPHsRAyS2XV5',
    port: 5432,
    ssl: { rejectUnauthorized: false }
  });

  try {
    await client.connect();
    console.log('🔍 Analyzing Your Existing Questions');
    console.log('===================================');
    console.log('');
    
    // Total questions
    const total = await client.query('SELECT COUNT(*) as count FROM questions');
    console.log(`📊 Total Questions: ${total.rows[0].count}`);
    console.log('');
    
    // Questions by type
    const byType = await client.query(`
      SELECT question_type, COUNT(*) as count 
      FROM questions 
      GROUP BY question_type 
      ORDER BY count DESC
    `);
    
    console.log('📋 Questions by Type:');
    byType.rows.forEach(row => {
      console.log(`   • ${row.question_type}: ${row.count} questions`);
    });
    console.log('');
    
    // Questions by test set
    const byTestSet = await client.query(`
      SELECT ts.id, ts.title, ts.set_number, ec.display_name as category, COUNT(q.id) as question_count
      FROM test_sets ts
      LEFT JOIN questions q ON ts.id = q.test_set_id
      LEFT JOIN education_categories ec ON ts.category_id = ec.id
      GROUP BY ts.id, ts.title, ts.set_number, ec.display_name
      ORDER BY ec.id, ts.set_number
    `);
    
    console.log('📝 Questions per Test Set:');
    byTestSet.rows.forEach(row => {
      const status = row.question_count >= 50 ? '✅' : '⚠️';
      console.log(`   ${status} ${row.category} - Set ${row.set_number}: ${row.question_count} questions`);
    });
    console.log('');
    
    // Sample questions
    const samples = await client.query(`
      SELECT question_text, question_type, option_a, option_b, correct_option
      FROM questions 
      LIMIT 5
    `);
    
    console.log('📋 Sample Questions:');
    samples.rows.forEach((q, index) => {
      console.log(`   ${index + 1}. [${q.question_type}] ${q.question_text}`);
      console.log(`      A) ${q.option_a}  B) ${q.option_b}`);
      console.log(`      Correct: ${q.correct_option || 'No correct answer'}`);
      console.log('');
    });
    
    // Check if we need more questions
    const setsNeedingQuestions = byTestSet.rows.filter(row => row.question_count < 50);
    
    if (setsNeedingQuestions.length > 0) {
      console.log('⚠️  Test Sets Needing More Questions:');
      setsNeedingQuestions.forEach(row => {
        const needed = 50 - row.question_count;
        console.log(`   • ${row.category} - Set ${row.set_number}: needs ${needed} more questions`);
      });
      console.log('');
      console.log('💡 Recommendation: Generate more questions to reach 50 per test set');
    } else {
      console.log('✅ All test sets have sufficient questions (50+ each)');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

analyzeQuestions();
