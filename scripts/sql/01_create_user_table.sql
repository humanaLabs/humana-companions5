-- Create User table
-- This is the main user authentication table

CREATE TABLE IF NOT EXISTS "User" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "email" VARCHAR(64) NOT NULL,
    "password" VARCHAR(64)
);

-- Add index for email lookups
CREATE INDEX IF NOT EXISTS "idx_user_email" ON "User"("email");

-- Comments for documentation
COMMENT ON TABLE "User" IS 'Main user authentication table';
COMMENT ON COLUMN "User"."id" IS 'Unique identifier for the user';
COMMENT ON COLUMN "User"."email" IS 'User email address (max 64 characters)';
COMMENT ON COLUMN "User"."password" IS 'Hashed password (optional for OAuth users)';

