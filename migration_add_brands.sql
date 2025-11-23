-- Migration: Add brands table
-- Date: 2025-11-23
-- Description: Adds brands table for centralized car brand management

-- Create brands table
CREATE TABLE IF NOT EXISTS brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_brands_name ON brands(name);

-- Insert popular car brands
INSERT INTO brands (name) VALUES 
('BMW'),
('Mercedes-Benz'),
('Audi'),
('Toyota'),
('Honda'),
('Nissan'),
('Hyundai'),
('Kia'),
('Volkswagen'),
('Ford'),
('Chevrolet'),
('Mazda'),
('Lexus'),
('Porsche'),
('Volvo'),
('Subaru'),
('Mitsubishi'),
('Renault'),
('Peugeot'),
('Skoda')
ON CONFLICT (name) DO NOTHING;

-- Add comment to table
COMMENT ON TABLE brands IS 'Справочник марок автомобилей';
COMMENT ON COLUMN brands.name IS 'Название марки автомобиля';

-- Verify migration
SELECT 'Migration completed successfully. Brands table created with ' || COUNT(*) || ' brands.' as status
FROM brands;
