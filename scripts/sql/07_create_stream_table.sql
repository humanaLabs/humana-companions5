-- Create Stream table
-- Stores streaming sessions for chat responses

CREATE TABLE IF NOT EXISTS "Stream" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "chatId" UUID NOT NULL REFERENCES "Chat"("id") ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS "idx_stream_chatId" ON "Stream"("chatId");
CREATE INDEX IF NOT EXISTS "idx_stream_createdAt" ON "Stream"("createdAt");

-- Comments for documentation
COMMENT ON TABLE "Stream" IS 'Streaming sessions for chat responses';
COMMENT ON COLUMN "Stream"."id" IS 'Unique identifier for the stream session';
COMMENT ON COLUMN "Stream"."chatId" IS 'Reference to the parent chat';
COMMENT ON COLUMN "Stream"."createdAt" IS 'Timestamp when the stream session was created';

