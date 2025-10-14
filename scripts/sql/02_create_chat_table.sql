-- Create Chat table
-- Stores chat conversations and metadata

CREATE TABLE IF NOT EXISTS "Chat" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "createdAt" TIMESTAMP NOT NULL,
    "title" TEXT NOT NULL,
    "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    "visibility" VARCHAR(10) NOT NULL DEFAULT 'private' CHECK ("visibility" IN ('public', 'private')),
    "lastContext" JSONB
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS "idx_chat_userId" ON "Chat"("userId");
CREATE INDEX IF NOT EXISTS "idx_chat_createdAt" ON "Chat"("createdAt");
CREATE INDEX IF NOT EXISTS "idx_chat_visibility" ON "Chat"("visibility");

-- Comments for documentation
COMMENT ON TABLE "Chat" IS 'Chat conversations and metadata';
COMMENT ON COLUMN "Chat"."id" IS 'Unique identifier for the chat';
COMMENT ON COLUMN "Chat"."createdAt" IS 'Timestamp when the chat was created';
COMMENT ON COLUMN "Chat"."title" IS 'Chat title or summary';
COMMENT ON COLUMN "Chat"."userId" IS 'Reference to the user who owns this chat';
COMMENT ON COLUMN "Chat"."visibility" IS 'Chat visibility: public or private';
COMMENT ON COLUMN "Chat"."lastContext" IS 'Last application usage context (JSON)';

