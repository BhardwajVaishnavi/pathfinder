const { Client } = require('pg');

async function quickCheck() {
  const client = new Client({
    host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
    database: 'neondb',
    user: 'neondb_owner',
    password: 'npg_hPHsRAyS2XV5',
    port: 5432,
    ssl: { rejectUnauthorized: false }
  });

  try {
    console.log('Connecting...');
    await client.connect();
    console.log('✅ Connected');
    
    const result = await client.query('SELECT COUNT(*) as count FROM questions');
    console.log(`Questions in database: ${result.rows[0].count}`);
    
    const testSets = await client.query('SELECT COUNT(*) as count FROM test_sets');
    console.log(`Test sets: ${testSets.rows[0].count}`);
    
    const categories = await client.query('SELECT COUNT(*) as count FROM education_categories');
    console.log(`Categories: ${categories.rows[0].count}`);
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await client.end();
  }
}

quickCheck();
