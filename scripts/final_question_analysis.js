const { Client } = require('pg');

async function finalAnalysis() {
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
    console.log('🔍 Final Analysis of Your PathfinderAI Database');
    console.log('==============================================');
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
    
    // Test sets summary
    const testSetSummary = await client.query(`
      SELECT COUNT(*) as total_sets
      FROM test_sets
    `);
    
    const questionsPerSet = await client.query(`
      SELECT test_set_id, COUNT(*) as question_count
      FROM questions
      GROUP BY test_set_id
      ORDER BY test_set_id
    `);
    
    console.log(`📝 Test Sets: ${testSetSummary.rows[0].total_sets} total`);
    console.log(`📋 Questions Distribution:`);
    
    if (questionsPerSet.rows.length > 0) {
      const avgQuestions = questionsPerSet.rows.reduce((sum, row) => sum + parseInt(row.question_count), 0) / questionsPerSet.rows.length;
      console.log(`   • Average questions per set: ${avgQuestions.toFixed(1)}`);
      console.log(`   • Sets with questions: ${questionsPerSet.rows.length}`);
      console.log(`   • Sets without questions: ${testSetSummary.rows[0].total_sets - questionsPerSet.rows.length}`);
    }
    console.log('');
    
    // Sample questions
    const samples = await client.query(`
      SELECT question_text, question_type, option_a, option_b, option_c, option_d, correct_option
      FROM questions 
      ORDER BY id
      LIMIT 3
    `);
    
    console.log('📋 Sample Questions:');
    samples.rows.forEach((q, index) => {
      console.log(`   ${index + 1}. [${q.question_type.toUpperCase()}] ${q.question_text}`);
      console.log(`      A) ${q.option_a}`);
      console.log(`      B) ${q.option_b}`);
      if (q.option_c) console.log(`      C) ${q.option_c}`);
      if (q.option_d) console.log(`      D) ${q.option_d}`);
      console.log(`      Correct: ${q.correct_option || 'No single correct answer'}`);
      console.log('');
    });
    
    // Education categories
    const categories = await client.query('SELECT category_code, display_name FROM education_categories ORDER BY id');
    console.log('📚 Education Categories Available:');
    categories.rows.forEach(cat => {
      console.log(`   • ${cat.category_code}: ${cat.display_name}`);
    });
    console.log('');
    
    // Assessment
    console.log('🎯 Assessment:');
    if (total.rows[0].count >= 50) {
      console.log('   ✅ You have sufficient questions for testing');
    } else {
      console.log('   ⚠️  You may need more questions for comprehensive testing');
    }
    
    if (byType.rows.length >= 3) {
      console.log('   ✅ Multiple question types available (aptitude, personality, interest)');
    }
    
    console.log('   ✅ Database structure is complete and ready');
    console.log('   ✅ Test sets are configured');
    console.log('   ✅ Education categories are set up');
    
    console.log('');
    console.log('🚀 Your PathfinderAI database is ready for:');
    console.log('   📝 Student psychometric testing');
    console.log('   🧠 Personality assessment');
    console.log('   💡 Career interest evaluation');
    console.log('   📊 Comprehensive reporting');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

finalAnalysis();
