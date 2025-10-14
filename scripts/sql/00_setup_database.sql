-- Database Setup Script
-- Run this first to prepare the database

-- Enable UUID extension (required for gen_random_uuid())
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Optional: Create a schema (uncomment if you want to use a specific schema)
-- CREATE SCHEMA IF NOT EXISTS "humana";
-- SET search_path TO "humana", public;

-- Comments
COMMENT ON EXTENSION "pgcrypto" IS 'Cryptographic functions including UUID generation';

