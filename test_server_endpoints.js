// Quick test script to verify server endpoints
// Run this with: node test_server_endpoints.js

const API_BASE = "https://autosalon1.onrender.com";

async function testServerEndpoints() {
    console.log('🧪 Testing AutoSalon Server Endpoints...\n');

    const tests = [
        { name: 'Server Health Check', url: '/test', method: 'GET' },
        { name: 'Database Connection', url: '/db-test', method: 'GET' },
        { name: 'Statistics', url: '/stats', method: 'GET' },
        { name: 'Cars List', url: '/cars', method: 'GET' },
        { name: 'Brands List', url: '/brands', method: 'GET' },
        { name: 'Login Test', url: '/auth/login', method: 'POST', data: {
            email: 'admin@autosalon.com',
            password: '123456'
        }}
    ];

    for (const test of tests) {
        try {
            console.log(`🔍 Testing: ${test.name}`);
            
            const options = {
                method: test.method,
                headers: {
                    'Content-Type': 'application/json',
                }
            };

            if (test.data) {
                options.body = JSON.stringify(test.data);
            }

            const response = await fetch(`${API_BASE}${test.url}`, options);
            const data = await response.json();
            
            if (response.ok) {
                console.log(`✅ ${test.name}: SUCCESS (${response.status})`);
                if (test.url === '/stats') {
                    console.log(`   Stats: ${JSON.stringify(data, null, 2)}`);
                }
            } else {
                console.log(`❌ ${test.name}: FAILED (${response.status})`);
                console.log(`   Error: ${JSON.stringify(data)}`);
            }
            
        } catch (error) {
            console.log(`❌ ${test.name}: ERROR - ${error.message}`);
        }
        
        console.log('');
    }
    
    console.log('🎯 Quick Image Upload Test');
    console.log('To test image upload manually:');
    console.log('1. Login first to get token');
    console.log('2. Use the token for photo upload:');
    console.log(`curl -X POST ${API_BASE}/api/cars/1/photos \\`);
    console.log('  -H "Authorization: Bearer YOUR_TOKEN" \\');
    console.log('  -F "photo=@test.jpg"');
}

// Run the tests
testServerEndpoints().catch(console.error);