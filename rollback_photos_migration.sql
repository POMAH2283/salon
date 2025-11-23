-- Rollback script for migration_add_car_photos.sql
-- Run this if you need to revert the photos column addition

-- Drop the index first
DROP INDEX IF EXISTS idx_cars_photos;

-- Drop the column
ALTER TABLE cars DROP COLUMN IF EXISTS photos;

-- Verify rollback
SELECT 'Rollback completed. Photos column and index removed.' as status;