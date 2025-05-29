#!/usr/bin/env node

/**
 * Seed Login Data for PathfinderAI
 * Creates test users for Students, Parents, and Teachers
 */

const { Client } = require('pg');
const bcrypt = require('bcrypt');

const client = new Client({
  host: 'ep-soft-sky-a4h1bku6-pooler.us-east-1.aws.neon.tech',
  database: 'neondb',
  user: 'neondb_owner',
  password: 'npg_hPHsRAyS2XV5',
  port: 5432,
  ssl: { rejectUnauthorized: false }
});

// Test user data
const testUsers = {
  students: [
    {
      full_name: 'Rahul Sharma',
      email: 'rahul.student@pathfinder.ai',
      password: 'student123',
      phone: '9876543210',
      date_of_birth: '2005-03-15',
      gender: 'male',
      education_category: 'twelfth_pass',
      current_institution: 'Delhi Public School',
      academic_year: '2023-24',
      parent_guardian_contact: '9876543211',
      preferred_language: 'english',
      address: '123 Student Street, New Delhi',
      state: 'Delhi',
      district: 'Central Delhi',
      city: 'New Delhi',
      pincode: '110001',
      identity_proof_type: 'Aadhaar Card',
      identity_proof_number: '1234-5678-9012'
    },
    {
      full_name: 'Priya Patel',
      email: 'priya.student@pathfinder.ai',
      password: 'student123',
      phone: '9876543212',
      date_of_birth: '2004-07-22',
      gender: 'female',
      education_category: 'undergraduate',
      current_institution: 'Mumbai University',
      academic_year: '2023-24',
      parent_guardian_contact: '9876543213',
      preferred_language: 'english',
      address: '456 College Road, Mumbai',
      state: 'Maharashtra',
      district: 'Mumbai',
      city: 'Mumbai',
      pincode: '400001',
      identity_proof_type: 'Aadhaar Card',
      identity_proof_number: '2345-6789-0123'
    },
    {
      full_name: 'Arjun Singh',
      email: 'arjun.student@pathfinder.ai',
      password: 'student123',
      phone: '9876543214',
      date_of_birth: '2003-11-08',
      gender: 'male',
      education_category: 'engineering_cse',
      current_institution: 'IIT Delhi',
      academic_year: '2023-24',
      parent_guardian_contact: '9876543215',
      preferred_language: 'english',
      address: '789 Tech Campus, Delhi',
      state: 'Delhi',
      district: 'South Delhi',
      city: 'New Delhi',
      pincode: '110016',
      identity_proof_type: 'Aadhaar Card',
      identity_proof_number: '3456-7890-1234'
    }
  ],

  parents: [
    {
      full_name: 'Suresh Sharma',
      email: 'suresh.parent@pathfinder.ai',
      password: 'parent123',
      phone: '9876543211',
      occupation: 'Software Engineer',
      relationship_to_student: 'father',
      address: '123 Student Street, New Delhi',
      state: 'Delhi',
      district: 'Central Delhi',
      city: 'New Delhi',
      pincode: '110001',
      preferred_language: 'english'
    },
    {
      full_name: 'Meera Patel',
      email: 'meera.parent@pathfinder.ai',
      password: 'parent123',
      phone: '9876543213',
      occupation: 'Doctor',
      relationship_to_student: 'mother',
      address: '456 College Road, Mumbai',
      state: 'Maharashtra',
      district: 'Mumbai',
      city: 'Mumbai',
      pincode: '400001',
      preferred_language: 'english'
    },
    {
      full_name: 'Rajesh Singh',
      email: 'rajesh.parent@pathfinder.ai',
      password: 'parent123',
      phone: '9876543215',
      occupation: 'Business Owner',
      relationship_to_student: 'father',
      address: '789 Tech Campus, Delhi',
      state: 'Delhi',
      district: 'South Delhi',
      city: 'New Delhi',
      pincode: '110016',
      preferred_language: 'english'
    }
  ],

  teachers: [
    {
      full_name: 'Dr. Anjali Verma',
      email: 'anjali.teacher@pathfinder.ai',
      password: 'teacher123',
      employee_id: 'TCH001',
      phone: '9876543220',
      institution_name: 'Delhi Public School',
      designation: 'Senior Mathematics Teacher',
      subject_expertise: 'Mathematics,Physics,Computer Science',
      years_of_experience: 12,
      institution_address: '123 School Street, New Delhi',
      state: 'Delhi',
      district: 'Central Delhi',
      city: 'New Delhi',
      pincode: '110001',
      access_level: 'advanced',
      preferred_language: 'english'
    },
    {
      full_name: 'Prof. Vikram Kumar',
      email: 'vikram.teacher@pathfinder.ai',
      password: 'teacher123',
      employee_id: 'TCH002',
      phone: '9876543221',
      institution_name: 'Mumbai University',
      designation: 'Associate Professor',
      subject_expertise: 'Psychology,Career Counseling,Education',
      years_of_experience: 15,
      institution_address: '456 University Road, Mumbai',
      state: 'Maharashtra',
      district: 'Mumbai',
      city: 'Mumbai',
      pincode: '400001',
      access_level: 'advanced',
      preferred_language: 'english'
    },
    {
      full_name: 'Dr. Ravi Gupta',
      email: 'ravi.teacher@pathfinder.ai',
      password: 'teacher123',
      employee_id: 'TCH003',
      phone: '9876543222',
      institution_name: 'IIT Delhi',
      designation: 'Assistant Professor',
      subject_expertise: 'Computer Science,Engineering,Technology',
      years_of_experience: 8,
      institution_address: '789 IIT Campus, Delhi',
      state: 'Delhi',
      district: 'South Delhi',
      city: 'New Delhi',
      pincode: '110016',
      access_level: 'intermediate',
      preferred_language: 'english'
    }
  ]
};

async function seedLoginData() {
  try {
    await client.connect();
    console.log('✅ Connected to NeonDB');
    console.log('');

    console.log('🌱 Seeding PathfinderAI Login Data');
    console.log('==================================');
    console.log('');

    // Clear existing test data
    console.log('🗑️ Clearing existing test data...');
    await client.query("DELETE FROM students WHERE email LIKE '%@pathfinder.ai'");
    await client.query("DELETE FROM parents WHERE email LIKE '%@pathfinder.ai'");
    await client.query("DELETE FROM teachers WHERE email LIKE '%@pathfinder.ai'");
    console.log('✅ Cleared existing test data');
    console.log('');

    // Seed students
    console.log('👥 Creating test students...');
    for (const student of testUsers.students) {
      const hashedPassword = await bcrypt.hash(student.password, 10);

      await client.query(`
        INSERT INTO students (
          full_name, email, phone, date_of_birth, gender, education_category,
          current_institution, academic_year, parent_guardian_contact, preferred_language,
          address, state, district, city, pincode, identity_proof_type,
          identity_proof_number, password_hash, is_profile_complete, is_verified
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20)
      `, [
        student.full_name, student.email, student.phone, student.date_of_birth,
        student.gender, student.education_category, student.current_institution,
        student.academic_year, student.parent_guardian_contact, student.preferred_language,
        student.address, student.state, student.district, student.city, student.pincode,
        student.identity_proof_type, student.identity_proof_number, hashedPassword, true, true
      ]);

      console.log(`   ✅ Created student: ${student.full_name} (${student.email})`);
    }
    console.log('');

    // Seed parents
    console.log('👨‍👩‍👧‍👦 Creating test parents...');
    for (const parent of testUsers.parents) {
      const hashedPassword = await bcrypt.hash(parent.password, 10);

      await client.query(`
        INSERT INTO parents (
          full_name, email, phone, occupation, relationship_to_student,
          address, state, district, city, pincode, preferred_language,
          password_hash, is_verified
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      `, [
        parent.full_name, parent.email, parent.phone, parent.occupation,
        parent.relationship_to_student, parent.address, parent.state,
        parent.district, parent.city, parent.pincode, parent.preferred_language,
        hashedPassword, true
      ]);

      console.log(`   ✅ Created parent: ${parent.full_name} (${parent.email})`);
    }
    console.log('');

    // Seed teachers
    console.log('👨‍🏫 Creating test teachers...');
    for (const teacher of testUsers.teachers) {
      const hashedPassword = await bcrypt.hash(teacher.password, 10);

      await client.query(`
        INSERT INTO teachers (
          full_name, employee_id, institution_name, designation, subject_expertise,
          email, phone, years_of_experience, institution_address, state, district,
          city, pincode, access_level, preferred_language, password_hash,
          is_verified, is_active
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
      `, [
        teacher.full_name, teacher.employee_id, teacher.institution_name,
        teacher.designation, teacher.subject_expertise, teacher.email, teacher.phone,
        teacher.years_of_experience, teacher.institution_address, teacher.state,
        teacher.district, teacher.city, teacher.pincode, teacher.access_level,
        teacher.preferred_language, hashedPassword, true, true
      ]);

      console.log(`   ✅ Created teacher: ${teacher.full_name} (${teacher.email})`);
    }
    console.log('');

    // Display login credentials
    console.log('🔑 Test Login Credentials');
    console.log('=========================');
    console.log('');

    console.log('👥 STUDENTS:');
    testUsers.students.forEach(student => {
      console.log(`   📧 Email: ${student.email}`);
      console.log(`   🔒 Password: ${student.password}`);
      console.log(`   🎓 Category: ${student.education_category}`);
      console.log(`   🏫 Institution: ${student.current_institution}`);
      console.log('');
    });

    console.log('👨‍👩‍👧‍👦 PARENTS:');
    testUsers.parents.forEach(parent => {
      console.log(`   📧 Email: ${parent.email}`);
      console.log(`   🔒 Password: ${parent.password}`);
      console.log(`   👔 Occupation: ${parent.occupation}`);
      console.log(`   👨‍👧‍👦 Relationship: ${parent.relationship_to_student}`);
      console.log('');
    });

    console.log('👨‍🏫 TEACHERS:');
    testUsers.teachers.forEach(teacher => {
      console.log(`   📧 Email: ${teacher.email}`);
      console.log(`   🔒 Password: ${teacher.password}`);
      console.log(`   🆔 Employee ID: ${teacher.employee_id}`);
      console.log(`   🏫 Institution: ${teacher.institution_name}`);
      console.log(`   📚 Subjects: ${teacher.subject_expertise}`);
      console.log('');
    });

    console.log('🎉 Login data seeding completed successfully!');
    console.log('');
    console.log('🚀 You can now test login with any of the above credentials');
    console.log('📱 Open the PathfinderAI app and try logging in as different user types');

  } catch (error) {
    console.error('❌ Error seeding login data:', error.message);
  } finally {
    await client.end();
  }
}

// Check if bcrypt is available
try {
  require.resolve('bcrypt');
} catch (e) {
  console.log('Installing bcrypt for password hashing...');
  require('child_process').execSync('npm install bcrypt', { stdio: 'inherit' });
}

console.log('🌱 PathfinderAI Login Data Seeder');
console.log('=================================');
console.log('');
console.log('This will create test login accounts for:');
console.log('👥 3 Students (different education levels)');
console.log('👨‍👩‍👧‍👦 3 Parents (linked to students)');
console.log('👨‍🏫 3 Teachers (different institutions)');
console.log('');
console.log('All passwords are simple for testing:');
console.log('🔒 Students: student123');
console.log('🔒 Parents: parent123');
console.log('🔒 Teachers: teacher123');
console.log('');

seedLoginData();
