-- Execute all SQL scripts in order
-- This script creates the entire database schema

-- 0. Setup database (extensions)
\echo 'Setting up database...'
\i 00_setup_database.sql

-- 1. Create User table
\echo 'Creating User table...'
\i 01_create_user_table.sql

-- 2. Create Chat table
\echo 'Creating Chat table...'
\i 02_create_chat_table.sql

-- 3. Create Message tables
\echo 'Creating Message tables...'
\i 03_create_message_tables.sql

-- 4. Create Vote tables
\echo 'Creating Vote tables...'
\i 04_create_vote_tables.sql

-- 5. Create Document table
\echo 'Creating Document table...'
\i 05_create_document_table.sql

-- 6. Create Suggestion table
\echo 'Creating Suggestion table...'
\i 06_create_suggestion_table.sql

-- 7. Create Stream table
\echo 'Creating Stream table...'
\i 07_create_stream_table.sql

\echo 'Database schema created successfully!'

