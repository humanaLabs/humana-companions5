-- Create Suggestion table
-- Stores AI-generated suggestions for document edits

CREATE TABLE IF NOT EXISTS "Suggestion" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
    "documentId" UUID NOT NULL,
    "documentCreatedAt" TIMESTAMP NOT NULL,
    "originalText" TEXT NOT NULL,
    "suggestedText" TEXT NOT NULL,
    "description" TEXT,
    "isResolved" BOOLEAN NOT NULL DEFAULT false,
    "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    "createdAt" TIMESTAMP NOT NULL,
    FOREIGN KEY ("documentId", "documentCreatedAt") REFERENCES "Document"("id", "createdAt") ON DELETE CASCADE
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS "idx_suggestion_documentId" ON "Suggestion"("documentId");
CREATE INDEX IF NOT EXISTS "idx_suggestion_userId" ON "Suggestion"("userId");
CREATE INDEX IF NOT EXISTS "idx_suggestion_isResolved" ON "Suggestion"("isResolved");
CREATE INDEX IF NOT EXISTS "idx_suggestion_createdAt" ON "Suggestion"("createdAt");

-- Comments for documentation
COMMENT ON TABLE "Suggestion" IS 'AI-generated suggestions for document edits';
COMMENT ON COLUMN "Suggestion"."id" IS 'Unique identifier for the suggestion';
COMMENT ON COLUMN "Suggestion"."documentId" IS 'Reference to the document being edited';
COMMENT ON COLUMN "Suggestion"."documentCreatedAt" IS 'Creation timestamp of the document (part of composite FK)';
COMMENT ON COLUMN "Suggestion"."originalText" IS 'Original text that the suggestion is replacing';
COMMENT ON COLUMN "Suggestion"."suggestedText" IS 'AI-suggested replacement text';
COMMENT ON COLUMN "Suggestion"."description" IS 'Description or reason for the suggestion';
COMMENT ON COLUMN "Suggestion"."isResolved" IS 'Whether the suggestion has been accepted or rejected';
COMMENT ON COLUMN "Suggestion"."userId" IS 'Reference to the user who requested the suggestion';
COMMENT ON COLUMN "Suggestion"."createdAt" IS 'Timestamp when the suggestion was created';

