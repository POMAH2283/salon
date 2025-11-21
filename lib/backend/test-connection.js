import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool({
  connectionString: "postgresql://autosalon_user:TY41Q40Y4OTclJA5sXfTnGPiiMbSNdhA@dpg-d4fooj5rnu6s73e8s6a0-a.oregon-postgres.render.com:5432/autosalon_tfiu",
  ssl: { rejectUnauthorized: false }
});

async function test() {
  try {
    const client = await pool.connect();
    console.log('✅ Connection successful!');
    const result = await client.query('SELECT NOW()');
    console.log('Database time:', result.rows[0].now);
    client.release();
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
  }
  process.exit();
}

test();