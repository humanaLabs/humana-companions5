-- Create Message tables
-- Message (deprecated) and Message_v2 (current)

-- DEPRECATED: Message table (kept for backward compatibility)
CREATE TABLE IF NOT EXISTS "Message" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "chatId" UUID NOT NULL REFERENCES "Chat"("id") ON DELETE CASCADE,
    "role" VARCHAR(20) NOT NULL,
    "content" JSON NOT NULL,
    "createdAt" TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS "idx_message_chatId" ON "Message"("chatId");
CREATE INDEX IF NOT EXISTS "idx_message_createdAt" ON "Message"("createdAt");

COMMENT ON TABLE "Message" IS 'DEPRECATED: Old message format (will be removed in future)';


-- CURRENT: Message_v2 table (with message parts support)
CREATE TABLE IF NOT EXISTS "Message_v2" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "chatId" UUID NOT NULL REFERENCES "Chat"("id") ON DELETE CASCADE,
    "role" VARCHAR(20) NOT NULL,
    "parts" JSON NOT NULL,
    "attachments" JSON NOT NULL,
    "createdAt" TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS "idx_message_v2_chatId" ON "Message_v2"("chatId");
CREATE INDEX IF NOT EXISTS "idx_message_v2_createdAt" ON "Message_v2"("createdAt");

-- Comments for documentation
COMMENT ON TABLE "Message_v2" IS 'Chat messages with support for multiple parts and attachments';
COMMENT ON COLUMN "Message_v2"."id" IS 'Unique identifier for the message';
COMMENT ON COLUMN "Message_v2"."chatId" IS 'Reference to the parent chat';
COMMENT ON COLUMN "Message_v2"."role" IS 'Message role (user, assistant, system)';
COMMENT ON COLUMN "Message_v2"."parts" IS 'Message content parts (JSON array)';
COMMENT ON COLUMN "Message_v2"."attachments" IS 'Message attachments (JSON array)';
COMMENT ON COLUMN "Message_v2"."createdAt" IS 'Timestamp when the message was created';

