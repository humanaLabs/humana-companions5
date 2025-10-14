-- Drop all tables in reverse order
-- WARNING: This will delete all data!

\echo 'WARNING: This will DROP all tables and DELETE all data!'
\echo 'Press Ctrl+C to cancel...'

-- Drop tables in reverse order (respecting foreign keys)
DROP TABLE IF EXISTS "Stream" CASCADE;
DROP TABLE IF EXISTS "Suggestion" CASCADE;
DROP TABLE IF EXISTS "Document" CASCADE;
DROP TABLE IF EXISTS "Vote_v2" CASCADE;
DROP TABLE IF EXISTS "Vote" CASCADE;
DROP TABLE IF EXISTS "Message_v2" CASCADE;
DROP TABLE IF EXISTS "Message" CASCADE;
DROP TABLE IF EXISTS "Chat" CASCADE;
DROP TABLE IF EXISTS "User" CASCADE;

\echo 'All tables dropped successfully!'

