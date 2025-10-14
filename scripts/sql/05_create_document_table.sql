-- Create Document table
-- Stores documents created by users (text, code, images, sheets)

CREATE TABLE IF NOT EXISTS "Document" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "createdAt" TIMESTAMP NOT NULL,
    "title" TEXT NOT NULL,
    "content" TEXT,
    "kind" VARCHAR(10) NOT NULL DEFAULT 'text' CHECK ("kind" IN ('text', 'code', 'image', 'sheet')),
    "userId" UUID NOT NULL REFERENCES "User"("id") ON DELETE CASCADE,
    PRIMARY KEY ("id", "createdAt")
);

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS "idx_document_userId" ON "Document"("userId");
CREATE INDEX IF NOT EXISTS "idx_document_createdAt" ON "Document"("createdAt");
CREATE INDEX IF NOT EXISTS "idx_document_kind" ON "Document"("kind");

-- Comments for documentation
COMMENT ON TABLE "Document" IS 'User-created documents (artifacts)';
COMMENT ON COLUMN "Document"."id" IS 'Unique identifier for the document';
COMMENT ON COLUMN "Document"."createdAt" IS 'Timestamp when the document was created';
COMMENT ON COLUMN "Document"."title" IS 'Document title';
COMMENT ON COLUMN "Document"."content" IS 'Document content (text/code/etc)';
COMMENT ON COLUMN "Document"."kind" IS 'Document type: text, code, image, or sheet';
COMMENT ON COLUMN "Document"."userId" IS 'Reference to the user who created the document';

