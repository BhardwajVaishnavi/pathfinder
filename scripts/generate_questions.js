#!/usr/bin/env node

/**
 * Generate Psychometric Test Questions for PathfinderAI
 * Creates questions for all education categories and test sets
 */

const { Client } = require('pg');

const client = new Client({
  host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
  database: 'neondb',
  user: 'neondb_owner',
  password: 'npg_hPHsRAyS2XV5',
  port: 5432,
  ssl: { rejectUnauthorized: false }
});

// Psychometric test questions for different categories
const questionTemplates = {
  aptitude: [
    {
      question: "If 5 books cost ₹125, what is the cost of 8 books?",
      options: ["₹200", "₹180", "₹220", "₹250"],
      correct: "A",
      category: "quantitative",
      difficulty: "easy"
    },
    {
      question: "Complete the series: 2, 6, 12, 20, 30, ?",
      options: ["42", "40", "38", "44"],
      correct: "A",
      category: "logical",
      difficulty: "medium"
    },
    {
      question: "Choose the word that is most similar to 'HAPPY':",
      options: ["Joyful", "Angry", "Sad", "Worried"],
      correct: "A",
      category: "verbal",
      difficulty: "easy"
    },
    {
      question: "If CODING is written as DPEJOH, how is FLOWER written?",
      options: ["GMPXFS", "GMPWER", "FMPXFS", "GKPXFS"],
      correct: "A",
      category: "logical",
      difficulty: "medium"
    },
    {
      question: "A train travels 60 km in 45 minutes. What is its speed in km/hr?",
      options: ["80 km/hr", "75 km/hr", "90 km/hr", "85 km/hr"],
      correct: "A",
      category: "quantitative",
      difficulty: "medium"
    }
  ],
  
  personality: [
    {
      question: "I enjoy working in teams rather than alone",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null, // No correct answer for personality
      category: "teamwork",
      difficulty: "easy"
    },
    {
      question: "I prefer to plan things in advance rather than be spontaneous",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null,
      category: "planning",
      difficulty: "easy"
    },
    {
      question: "I feel comfortable speaking in front of large groups",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null,
      category: "communication",
      difficulty: "easy"
    },
    {
      question: "I enjoy solving complex problems that require deep thinking",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null,
      category: "analytical",
      difficulty: "easy"
    },
    {
      question: "I prefer jobs that involve helping other people",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null,
      category: "social",
      difficulty: "easy"
    }
  ],
  
  interest: [
    {
      question: "Which activity interests you most?",
      options: ["Building/Creating things", "Analyzing data", "Teaching others", "Organizing events"],
      correct: null,
      category: "career_interest",
      difficulty: "easy"
    },
    {
      question: "In your free time, you prefer:",
      options: ["Reading books", "Playing sports", "Watching movies", "Learning new skills"],
      correct: null,
      category: "leisure_interest",
      difficulty: "easy"
    },
    {
      question: "Which subject did you enjoy most in school?",
      options: ["Mathematics", "Science", "Languages", "Arts"],
      correct: null,
      category: "academic_interest",
      difficulty: "easy"
    },
    {
      question: "What type of work environment appeals to you?",
      options: ["Office setting", "Outdoor work", "Laboratory", "Creative studio"],
      correct: null,
      category: "work_environment",
      difficulty: "easy"
    },
    {
      question: "Which career field interests you most?",
      options: ["Technology", "Healthcare", "Business", "Education"],
      correct: null,
      category: "career_field",
      difficulty: "easy"
    }
  ]
};

async function generateQuestions() {
  try {
    await client.connect();
    console.log('✅ Connected to NeonDB');
    console.log('');
    
    console.log('🔍 Generating Psychometric Test Questions...');
    console.log('============================================');
    
    // Get all test sets
    const testSets = await client.query(`
      SELECT ts.*, ec.category_code, ec.display_name as category_name 
      FROM test_sets ts 
      JOIN education_categories ec ON ts.category_id = ec.id 
      ORDER BY ts.category_id, ts.set_number
    `);
    
    console.log(`📝 Found ${testSets.rows.length} test sets to populate`);
    console.log('');
    
    let totalQuestions = 0;
    
    for (const testSet of testSets.rows) {
      console.log(`📋 Generating questions for: ${testSet.category_name} - Set ${testSet.set_number}`);
      
      // Generate 50 questions per test set (as per your requirement)
      const questionsPerSet = 50;
      const questionsPerType = Math.floor(questionsPerSet / 3); // Divide among aptitude, personality, interest
      
      let questionNumber = 1;
      
      // Generate aptitude questions
      for (let i = 0; i < questionsPerType; i++) {
        const template = questionTemplates.aptitude[i % questionTemplates.aptitude.length];
        await insertQuestion(testSet.id, questionNumber++, template, 'aptitude');
      }
      
      // Generate personality questions
      for (let i = 0; i < questionsPerType; i++) {
        const template = questionTemplates.personality[i % questionTemplates.personality.length];
        await insertQuestion(testSet.id, questionNumber++, template, 'personality');
      }
      
      // Generate interest questions
      for (let i = 0; i < questionsPerType; i++) {
        const template = questionTemplates.interest[i % questionTemplates.interest.length];
        await insertQuestion(testSet.id, questionNumber++, template, 'interest');
      }
      
      // Fill remaining slots with mixed questions
      while (questionNumber <= questionsPerSet) {
        const types = ['aptitude', 'personality', 'interest'];
        const randomType = types[Math.floor(Math.random() * types.length)];
        const template = questionTemplates[randomType][Math.floor(Math.random() * questionTemplates[randomType].length)];
        await insertQuestion(testSet.id, questionNumber++, template, randomType);
      }
      
      totalQuestions += questionsPerSet;
      console.log(`   ✅ Generated ${questionsPerSet} questions`);
    }
    
    console.log('');
    console.log('🎉 Question Generation Complete!');
    console.log(`📊 Total Questions Generated: ${totalQuestions}`);
    console.log(`📝 Questions per Test Set: 50`);
    console.log(`🎯 Question Types: Aptitude, Personality, Interest`);
    
    // Verify the results
    const finalCount = await client.query('SELECT COUNT(*) as count FROM questions');
    console.log(`✅ Verification: ${finalCount.rows[0].count} questions in database`);
    
  } catch (error) {
    console.error('❌ Error generating questions:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Database connection closed');
  }
}

async function insertQuestion(testSetId, questionNumber, template, questionType) {
  const sql = `
    INSERT INTO questions (
      test_set_id, question_type, question_text, option_a, option_b, 
      option_c, option_d, correct_option, difficulty_level, skill_category, points
    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
  `;
  
  const values = [
    testSetId,
    questionType,
    `${questionNumber}. ${template.question}`,
    template.options[0],
    template.options[1],
    template.options[2] || null,
    template.options[3] || null,
    template.correct,
    template.difficulty,
    template.category,
    questionType === 'aptitude' ? 2 : 1 // Aptitude questions worth more points
  ];
  
  await client.query(sql, values);
}

// Run the generator
console.log('🚀 PathfinderAI Question Generator');
console.log('==================================');
console.log('');
console.log('This will generate psychometric test questions for:');
console.log('📊 Aptitude Tests (Quantitative, Logical, Verbal)');
console.log('🧠 Personality Assessment');
console.log('💡 Interest & Career Preference');
console.log('');
console.log('Starting generation...');
console.log('');

generateQuestions();
