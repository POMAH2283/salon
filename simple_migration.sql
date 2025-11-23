-- Simple migration to add car characteristics columns
-- Run this in your PostgreSQL database

-- Add new columns to cars table (only if they don't exist)
ALTER TABLE cars 
ADD COLUMN IF NOT EXISTS engine_volume DECIMAL(3,1);

ALTER TABLE cars 
ADD COLUMN IF NOT EXISTS fuel_type VARCHAR(50);

ALTER TABLE cars 
ADD COLUMN IF NOT EXISTS power INTEGER;

ALTER TABLE cars 
ADD COLUMN IF NOT EXISTS transmission_type VARCHAR(50);

ALTER TABLE cars 
ADD COLUMN IF NOT EXISTS drive_type VARCHAR(50);

-- Verify the columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'cars' 
AND column_name IN ('engine_volume', 'fuel_type', 'power', 'transmission_type', 'drive_type');