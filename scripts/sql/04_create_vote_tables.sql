-- Create Vote tables
-- Vote (deprecated) and Vote_v2 (current)

-- DEPRECATED: Vote table (kept for backward compatibility)
CREATE TABLE IF NOT EXISTS "Vote" (
    "chatId" UUID NOT NULL REFERENCES "Chat"("id") ON DELETE CASCADE,
    "messageId" UUID NOT NULL REFERENCES "Message"("id") ON DELETE CASCADE,
    "isUpvoted" BOOLEAN NOT NULL,
    PRIMARY KEY ("chatId", "messageId")
);

CREATE INDEX IF NOT EXISTS "idx_vote_messageId" ON "Vote"("messageId");

COMMENT ON TABLE "Vote" IS 'DEPRECATED: Old vote format (will be removed in future)';


-- CURRENT: Vote_v2 table
CREATE TABLE IF NOT EXISTS "Vote_v2" (
    "chatId" UUID NOT NULL REFERENCES "Chat"("id") ON DELETE CASCADE,
    "messageId" UUID NOT NULL REFERENCES "Message_v2"("id") ON DELETE CASCADE,
    "isUpvoted" BOOLEAN NOT NULL,
    PRIMARY KEY ("chatId", "messageId")
);

CREATE INDEX IF NOT EXISTS "idx_vote_v2_messageId" ON "Vote_v2"("messageId");

-- Comments for documentation
COMMENT ON TABLE "Vote_v2" IS 'User votes (upvote/downvote) for messages';
COMMENT ON COLUMN "Vote_v2"."chatId" IS 'Reference to the chat';
COMMENT ON COLUMN "Vote_v2"."messageId" IS 'Reference to the message being voted on';
COMMENT ON COLUMN "Vote_v2"."isUpvoted" IS 'True for upvote, false for downvote';

