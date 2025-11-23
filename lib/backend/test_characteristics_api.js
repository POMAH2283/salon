// Test script to verify the new API endpoints for car characteristics
const API_BASE = 'http://localhost:3000/api';

async function testAPIEndpoints() {
  const endpoints = [
    '/fuel-types',
    '/transmission-types', 
    '/drive-types',
    '/body-types'
  ];

  console.log('🧪 Testing API endpoints for car characteristics...\n');

  for (const endpoint of endpoints) {
    try {
      const response = await fetch(`${API_BASE}${endpoint}`);
      const data = await response.json();
      
      console.log(`✅ ${endpoint}:`);
      console.log(`   Status: ${response.status}`);
      console.log(`   Records: ${data.length}`);
      console.log(`   Data:`, data.map(item => item.name).join(', '));
      console.log();
      
    } catch (error) {
      console.log(`❌ ${endpoint}:`, error.message);
      console.log();
    }
  }
}

// Run the test
testAPIEndpoints().catch(console.error);