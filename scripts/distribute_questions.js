#!/usr/bin/env node

/**
 * Distribute Questions Across All Test Sets
 * Ensures each test set has 50 questions as per PathfinderAI requirements
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

// Enhanced question templates for different education levels
const questionBank = {
  aptitude: {
    easy: [
      {
        question: "If 3 pens cost ₹45, what is the cost of 7 pens?",
        options: ["₹105", "₹95", "₹115", "₹125"],
        correct: "A"
      },
      {
        question: "Complete the pattern: 1, 4, 9, 16, ?",
        options: ["20", "25", "24", "30"],
        correct: "B"
      },
      {
        question: "Which word means the opposite of 'BRIGHT'?",
        options: ["Dark", "Light", "Shiny", "Clear"],
        correct: "A"
      }
    ],
    medium: [
      {
        question: "A car travels 240 km in 3 hours. What is its average speed?",
        options: ["70 km/h", "80 km/h", "90 km/h", "75 km/h"],
        correct: "B"
      },
      {
        question: "If FRIEND is coded as GSJFOE, how is MOTHER coded?",
        options: ["NPUIFS", "NPUIFS", "OPUIFS", "NPUJFS"],
        correct: "A"
      }
    ],
    hard: [
      {
        question: "In a class of 40 students, 60% are boys. If 25% of boys and 20% of girls passed, how many students passed?",
        options: ["14", "16", "18", "12"],
        correct: "A"
      }
    ]
  },
  
  personality: [
    {
      question: "I enjoy taking leadership roles in group projects",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null
    },
    {
      question: "I prefer detailed planning over spontaneous decisions",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null
    },
    {
      question: "I feel energized when working with people",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null
    },
    {
      question: "I enjoy analyzing complex problems step by step",
      options: ["Strongly Agree", "Agree", "Neutral", "Disagree"],
      correct: null
    }
  ],
  
  interest: [
    {
      question: "Which activity would you choose for a weekend?",
      options: ["Building a model", "Reading a book", "Playing sports", "Organizing an event"],
      correct: null
    },
    {
      question: "What type of TV shows do you prefer?",
      options: ["Documentaries", "Sports", "Drama", "News"],
      correct: null
    },
    {
      question: "In which environment would you like to work?",
      options: ["Laboratory", "Office", "Outdoors", "Workshop"],
      correct: null
    },
    {
      question: "Which subject interests you most?",
      options: ["Mathematics", "Literature", "Science", "History"],
      correct: null
    }
  ]
};

async function distributeQuestions() {
  try {
    await client.connect();
    console.log('✅ Connected to NeonDB');
    console.log('');
    
    console.log('🔄 Distributing Questions Across All Test Sets');
    console.log('==============================================');
    
    // Get all test sets
    const testSets = await client.query(`
      SELECT ts.id, ts.set_number, ec.category_code, ec.display_name
      FROM test_sets ts
      JOIN education_categories ec ON ts.category_id = ec.id
      ORDER BY ec.id, ts.set_number
    `);
    
    console.log(`📝 Found ${testSets.rows.length} test sets to populate`);
    console.log('');
    
    let totalGenerated = 0;
    
    for (const testSet of testSets.rows) {
      console.log(`📋 Processing: ${testSet.display_name} - Set ${testSet.set_number}`);
      
      // Check current question count
      const currentCount = await client.query(
        'SELECT COUNT(*) as count FROM questions WHERE test_set_id = $1',
        [testSet.id]
      );
      
      const existing = parseInt(currentCount.rows[0].count);
      const needed = 50 - existing;
      
      if (needed > 0) {
        console.log(`   Current: ${existing} questions, Need: ${needed} more`);
        
        // Generate questions based on education level
        const difficulty = getDifficultyForCategory(testSet.category_code);
        await generateQuestionsForTestSet(testSet.id, needed, difficulty);
        
        totalGenerated += needed;
        console.log(`   ✅ Generated ${needed} questions`);
      } else {
        console.log(`   ✅ Already has ${existing} questions`);
      }
    }
    
    console.log('');
    console.log('🎉 Question Distribution Complete!');
    console.log(`📊 Total Questions Generated: ${totalGenerated}`);
    
    // Final verification
    const finalCount = await client.query('SELECT COUNT(*) as count FROM questions');
    const testSetCounts = await client.query(`
      SELECT test_set_id, COUNT(*) as count
      FROM questions
      GROUP BY test_set_id
      HAVING COUNT(*) < 50
    `);
    
    console.log(`✅ Total Questions in Database: ${finalCount.rows[0].count}`);
    console.log(`📝 Test Sets with <50 Questions: ${testSetCounts.rows.length}`);
    
    if (testSetCounts.rows.length === 0) {
      console.log('🎯 SUCCESS: All test sets now have 50+ questions!');
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

function getDifficultyForCategory(categoryCode) {
  if (categoryCode.includes('tenth')) return 'easy';
  if (categoryCode.includes('twelfth')) return 'medium';
  if (categoryCode.includes('graduate') || categoryCode.includes('engineering')) return 'medium';
  if (categoryCode.includes('postgraduate')) return 'hard';
  return 'medium';
}

async function generateQuestionsForTestSet(testSetId, count, difficulty) {
  const questionsPerType = Math.ceil(count / 3);
  let questionNumber = 1;
  
  // Get current max question number for this test set
  const maxResult = await client.query(
    'SELECT COALESCE(MAX(CAST(SUBSTRING(question_text FROM \'^[0-9]+\') AS INTEGER)), 0) as max_num FROM questions WHERE test_set_id = $1',
    [testSetId]
  );
  questionNumber = parseInt(maxResult.rows[0].max_num) + 1;
  
  // Generate aptitude questions
  for (let i = 0; i < questionsPerType && questionNumber <= count + questionNumber - questionsPerType; i++) {
    const questions = questionBank.aptitude[difficulty] || questionBank.aptitude.medium;
    const template = questions[i % questions.length];
    await insertQuestion(testSetId, questionNumber++, template, 'aptitude');
  }
  
  // Generate personality questions
  for (let i = 0; i < questionsPerType && questionNumber <= count + questionNumber - questionsPerType; i++) {
    const template = questionBank.personality[i % questionBank.personality.length];
    await insertQuestion(testSetId, questionNumber++, template, 'personality');
  }
  
  // Generate interest questions
  for (let i = 0; i < questionsPerType && questionNumber <= count + questionNumber - questionsPerType; i++) {
    const template = questionBank.interest[i % questionBank.interest.length];
    await insertQuestion(testSetId, questionNumber++, template, 'interest');
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
    'medium',
    questionType,
    questionType === 'aptitude' ? 2 : 1
  ];
  
  await client.query(sql, values);
}

console.log('🚀 PathfinderAI Question Distribution System');
console.log('===========================================');
console.log('');
console.log('This will ensure all 52 test sets have 50 questions each:');
console.log('📊 Aptitude Questions (Math, Logic, Verbal)');
console.log('🧠 Personality Assessment Questions');
console.log('💡 Career Interest Questions');
console.log('');
console.log('Target: 2,600 total questions (52 sets × 50 questions)');
console.log('');

distributeQuestions();
