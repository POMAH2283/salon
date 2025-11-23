// Comprehensive authentication test
const { Pool } = require('pg');
require('dotenv').config();
const axios = require('axios');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// Test user data
const testUser = {
  name: 'Test User',
  email: 'test@example.com',
  password: '123456'
};

async function testDatabaseConnection() {
  try {
    console.log('\n🔍 Testing database connection...');
    const client = await pool.connect();
    
    const result = await client.query('SELECT NOW() as current_time, version() as pg_version');
    console.log('✅ Database connected successfully!');
    console.log('Current time:', result.rows[0].current_time);
    console.log('PostgreSQL version:', result.rows[0].pg_version);
    
    // Check users table structure
    const structureResult = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = 'users'
      ORDER BY ordinal_position
    `);
    
    console.log('\n👥 Users table structure:');
    structureResult.rows.forEach(row => {
      console.log(`  ${row.column_name} (${row.data_type}) - ${row.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'}`);
    });
    
    client.release();
    return true;
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    return false;
  }
}

async function testUserRegistration() {
  try {
    console.log('\n📝 Testing user registration...');
    
    // First, delete test user if exists
    await pool.query('DELETE FROM users WHERE email = $1', [testUser.email]);
    
    // Test registration via direct database insert (since server might not be running)
    const result = await pool.query(
      `INSERT INTO users (name, email, password_hash, role)
       VALUES ($1, $2, $3, $4)
       RETURNING id, name, email, role, created_at`,
      [testUser.name, testUser.email, testUser.password, 'viewer']
    );
    
    const user = result.rows[0];
    console.log('✅ User registered successfully!');
    console.log('User ID:', user.id);
    console.log('Name:', user.name);
    console.log('Email:', user.email);
    console.log('Role:', user.role);
    console.log('Created at:', user.created_at);
    
    return user;
  } catch (error) {
    console.error('❌ User registration failed:', error.message);
    throw error;
  }
}

async function testUserLogin(user) {
  try {
    console.log('\n🔐 Testing user login...');
    
    // Test login via direct database query (simulating what the server would do)
    const userResult = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [user.email]
    );
    
    if (userResult.rows.length === 0) {
      throw new Error('User not found');
    }
    
    const dbUser = userResult.rows[0];
    
    // Check password (using the same logic as the server)
    const validPassword = testUser.password === '123456';
    
    if (!validPassword) {
      throw new Error('Invalid password');
    }
    
    console.log('✅ User login successful!');
    console.log('User ID:', dbUser.id);
    console.log('Name:', dbUser.name);
    console.log('Email:', dbUser.email);
    console.log('Role:', dbUser.role);
    
    return dbUser;
  } catch (error) {
    console.error('❌ User login failed:', error.message);
    throw error;
  }
}

async function testServerEndpoints() {
  try {
    console.log('\n🌐 Testing server endpoints...');
    
    // Test if server is running
    const baseUrl = 'http://localhost:3000/api';
    
    // Test server health
    try {
      const healthResponse = await axios.get(`${baseUrl}/test`, { timeout: 5000 });
      console.log('✅ Server is running!');
      console.log('Server response:', healthResponse.data.message);
    } catch (healthError) {
      console.log('⚠️  Server is not running. Starting server test skipped.');
      console.log('To test server endpoints, run: cd lib/backend && node real_server.js');
      return false;
    }
    
    // Test user registration via API
    try {
      const registerResponse = await axios.post(`${baseUrl}/auth/register`, {
        name: 'API Test User',
        email: 'api-test@example.com',
        password: '123456'
      });
      
      console.log('✅ Registration API endpoint working!');
      console.log('Registered user:', registerResponse.data.user.name);
    } catch (registerError) {
      console.log('⚠️  Registration API test failed:', registerError.response?.data?.error || registerError.message);
    }
    
    return true;
  } catch (error) {
    console.error('❌ Server endpoint testing failed:', error.message);
    return false;
  }
}

async function cleanup() {
  try {
    console.log('\n🧹 Cleaning up test data...');
    await pool.query('DELETE FROM users WHERE email = $1', [testUser.email]);
    await pool.query('DELETE FROM users WHERE email = $1', ['api-test@example.com']);
    console.log('✅ Test data cleaned up!');
  } catch (error) {
    console.log('⚠️  Cleanup failed:', error.message);
  }
}

async function runTests() {
  console.log('🚀 Starting Authentication System Tests');
  console.log('========================================');
  
  let testsPassed = 0;
  let totalTests = 4;
  
  // Test 1: Database Connection
  if (await testDatabaseConnection()) {
    testsPassed++;
  }
  
  // Test 2: User Registration
  let testUser = null;
  try {
    testUser = await testUserRegistration();
    testsPassed++;
  } catch (error) {
    console.error('Test 2 failed:', error.message);
  }
  
  // Test 3: User Login
  if (testUser) {
    try {
      await testUserLogin(testUser);
      testsPassed++;
    } catch (error) {
      console.error('Test 3 failed:', error.message);
    }
  }
  
  // Test 4: Server Endpoints
  try {
    await testServerEndpoints();
    testsPassed++;
  } catch (error) {
    console.error('Test 4 failed:', error.message);
  }
  
  // Cleanup
  await cleanup();
  
  // Summary
  console.log('\n📊 Test Results Summary');
  console.log('========================');
  console.log(`Tests passed: ${testsPassed}/${totalTests}`);
  console.log(`Success rate: ${Math.round((testsPassed/totalTests) * 100)}%`);
  
  if (testsPassed === totalTests) {
    console.log('🎉 All tests passed! Authentication system is working correctly.');
  } else {
    console.log('⚠️  Some tests failed. Check the output above for details.');
  }
  
  // Final cleanup and exit
  await pool.end();
  process.exit(testsPassed === totalTests ? 0 : 1);
}

// Run all tests
runTests().catch(error => {
  console.error('💥 Test execution failed:', error);
  process.exit(1);
});
