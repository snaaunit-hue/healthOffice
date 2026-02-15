-- Add missing columns to facilities table
ALTER TABLE facilities ADD COLUMN IF NOT EXISTS specialty VARCHAR(255);
ALTER TABLE facilities ADD COLUMN IF NOT EXISTS sector VARCHAR(50);
ALTER TABLE facilities ADD COLUMN IF NOT EXISTS governorate VARCHAR(100);
ALTER TABLE facilities ADD COLUMN IF NOT EXISTS operational_status VARCHAR(30) DEFAULT 'ACTIVE' NOT NULL;
