-- V2: Normalize facility data + support operational status & profile fields
-- Safe migration: add columns with defaults, no data loss.

-- Add columns to facilities (backward compatible; run once)
ALTER TABLE facilities ADD COLUMN governorate VARCHAR(100);
ALTER TABLE facilities ADD COLUMN sector VARCHAR(50) DEFAULT 'خاص';
ALTER TABLE facilities ADD COLUMN specialty VARCHAR(255);
ALTER TABLE facilities ADD COLUMN operational_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE';

-- Backfill operational_status from is_active
UPDATE facilities
SET operational_status = CASE
  WHEN is_active = TRUE THEN 'ACTIVE'
  ELSE 'SUSPENDED'
END;

-- Constraint: allowed values for operational_status
ALTER TABLE facilities
  DROP CONSTRAINT IF EXISTS chk_facility_operational_status;
ALTER TABLE facilities
  ADD CONSTRAINT chk_facility_operational_status
  CHECK (operational_status IN ('ACTIVE', 'CLOSED', 'SUSPENDED', 'UNDER_REVIEW'));

-- Ensure facility_code is present and unique (already in schema)
-- Ensure every facility has a stable "display" id (we use id + facility_code)

-- Audit: extend audit_logs if needed (already has entity_type, entity_id, action, details)
COMMENT ON COLUMN facilities.operational_status IS 'ACTIVE, CLOSED, SUSPENDED, UNDER_REVIEW - editable by authorized staff only';
