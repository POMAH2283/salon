import pkg from 'pg';
const { Pool } = pkg;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

async function migrate() {
  try {
    console.log('🔄 Starting database migration...');

    // Создаем типы
    await pool.query(`
      CREATE TYPE user_role AS ENUM ('admin', 'manager', 'viewer');
      CREATE TYPE car_status AS ENUM ('available', 'sold', 'reserved');
      CREATE TYPE deal_type AS ENUM ('sale', 'reservation');
      CREATE TYPE deal_status AS ENUM ('new', 'in_process', 'completed', 'canceled');
    `);
    console.log('✅ Types created');

    // Создаем таблицы
    // Создаем типы с проверкой существования
    await pool.query(`
      DO $$ BEGIN
        CREATE TYPE user_role AS ENUM ('admin', 'manager', 'viewer');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;

      DO $$ BEGIN
        CREATE TYPE car_status AS ENUM ('available', 'sold', 'reserved');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;

      DO $$ BEGIN
        CREATE TYPE deal_type AS ENUM ('sale', 'reservation');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;

      DO $$ BEGIN
        CREATE TYPE deal_status AS ENUM ('new', 'in_process', 'completed', 'canceled');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    `);
    console.log('✅ Tables created');

    console.log('🎉 Database migrated successfully!');

  } catch (error) {
    console.error('❌ Migration error:', error.message);
  } finally {
    await pool.end();
  }
}

migrate();