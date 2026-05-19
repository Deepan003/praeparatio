-- PRAEPARATIO - Supabase Database Schema
-- Run this in your Supabase SQL Editor to set up all tables.

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ================================================================
-- USERS TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  username TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  student_class TEXT NOT NULL DEFAULT '11',
  batch TEXT NOT NULL DEFAULT '11 NEET',
  prepcoins INTEGER DEFAULT 80,
  is_admin BOOLEAN DEFAULT false,
  is_banned BOOLEAN DEFAULT false,
  earned_badge_ids TEXT[] DEFAULT '{}',
  selected_avatar_id TEXT,
  claimed_avatar_ids TEXT[] DEFAULT '{}',
  monthly_payments JSONB DEFAULT '{}',
  login_streak JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  last_login TIMESTAMPTZ
);

-- ================================================================
-- EXAMS TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS exams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  target_batches TEXT[] DEFAULT '{}',
  duration_minutes INTEGER NOT NULL DEFAULT 60,
  difficulty TEXT DEFAULT 'Medium',
  type TEXT DEFAULT 'manual',
  chapters TEXT[] DEFAULT '{}',
  is_published BOOLEAN DEFAULT false,
  exp_required INTEGER DEFAULT 0,
  exp_gained INTEGER DEFAULT 100,
  tag TEXT DEFAULT 'Practice',
  avatar_id TEXT DEFAULT 'av_01',
  is_new BOOLEAN DEFAULT true,
  ai_prompt TEXT,
  created_by TEXT NOT NULL DEFAULT 'admin',
  selected_class INTEGER,
  visibility_start TIMESTAMPTZ,
  visibility_end TIMESTAMPTZ,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ================================================================
-- QUESTIONS TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  exam_id UUID REFERENCES exams(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  correct_option TEXT NOT NULL CHECK (correct_option IN ('A','B','C','D')),
  image_url TEXT,
  explanation TEXT,
  chapter TEXT,
  difficulty TEXT DEFAULT 'Medium',
  sort_order INTEGER DEFAULT 0
);

-- ================================================================
-- EXAM RESULTS TABLE
-- ================================================================
CREATE TABLE IF NOT EXISTS exam_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  exam_id UUID,
  student_id UUID REFERENCES users(id) ON DELETE CASCADE,
  score INTEGER DEFAULT 0,
  total_questions INTEGER DEFAULT 0,
  answers JSONB DEFAULT '{}',
  time_taken_seconds INTEGER DEFAULT 0,
  submitted_at TIMESTAMPTZ DEFAULT now(),
  is_first_attempt BOOLEAN DEFAULT true,
  correct_count INTEGER DEFAULT 0,
  incorrect_count INTEGER DEFAULT 0,
  unattempted_count INTEGER DEFAULT 0,
  data_retained BOOLEAN DEFAULT true,
  exam_title TEXT DEFAULT '',
  exam_type TEXT DEFAULT 'online',
  is_in_progress BOOLEAN DEFAULT false,
  started_at TIMESTAMPTZ,
  remaining_seconds INTEGER DEFAULT 0
);

-- ================================================================
-- PREVIOUS YEAR QUESTIONS (PYQ)
-- ================================================================
CREATE TABLE IF NOT EXISTS pyq (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  year INTEGER NOT NULL,
  chapter TEXT NOT NULL,
  question TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  correct_option TEXT NOT NULL CHECK (correct_option IN ('A','B','C','D')),
  image_url TEXT,
  explanation TEXT
);

-- ================================================================
-- LESSON PLANS
-- ================================================================
CREATE TABLE IF NOT EXISTS lesson_plans (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  student_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  plan_date DATE NOT NULL,
  notes TEXT,
  is_completed BOOLEAN DEFAULT false,
  color TEXT DEFAULT '#4C3FA0',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS lesson_tasks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  plan_id UUID REFERENCES lesson_plans(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  is_done BOOLEAN DEFAULT false,
  chapter TEXT,
  type TEXT DEFAULT 'study',
  sort_order INTEGER DEFAULT 0
);

-- ================================================================
-- NOTES & EXTERNAL LINKS
-- ================================================================
CREATE TABLE IF NOT EXISTS notes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  link TEXT NOT NULL,
  visibility TEXT DEFAULT 'all',
  section_id TEXT NOT NULL,
  section_name TEXT NOT NULL,
  is_link BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ================================================================
-- OFFLINE TEST MARKS (managed by admin)
-- ================================================================
CREATE TABLE IF NOT EXISTS offline_tests (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  test_date DATE NOT NULL,
  full_marks INTEGER NOT NULL,
  batch TEXT NOT NULL,
  student_marks JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ================================================================
-- SETTINGS
-- ================================================================
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value JSONB
);

-- Default settings
INSERT INTO app_settings (key, value) VALUES
  ('show_payment_status', 'true'),
  ('monthly_prepcoins', '80')
ON CONFLICT (key) DO NOTHING;

-- ================================================================
-- ROW LEVEL SECURITY (RLS) - Basic setup
-- Disable for now; enable when you add proper auth
-- ================================================================
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE exams DISABLE ROW LEVEL SECURITY;
ALTER TABLE questions DISABLE ROW LEVEL SECURITY;
ALTER TABLE exam_results DISABLE ROW LEVEL SECURITY;
ALTER TABLE pyq DISABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_plans DISABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_tasks DISABLE ROW LEVEL SECURITY;
ALTER TABLE notes DISABLE ROW LEVEL SECURITY;
ALTER TABLE offline_tests DISABLE ROW LEVEL SECURITY;
ALTER TABLE app_settings DISABLE ROW LEVEL SECURITY;

-- ================================================================
-- INDEXES for performance
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_exams_published ON exams(is_published);
CREATE INDEX IF NOT EXISTS idx_questions_exam_id ON questions(exam_id);
CREATE INDEX IF NOT EXISTS idx_results_student ON exam_results(student_id);
CREATE INDEX IF NOT EXISTS idx_results_exam ON exam_results(exam_id);
CREATE INDEX IF NOT EXISTS idx_pyq_chapter ON pyq(chapter);
CREATE INDEX IF NOT EXISTS idx_pyq_year ON pyq(year);
CREATE INDEX IF NOT EXISTS idx_lesson_plans_student ON lesson_plans(student_id);
CREATE INDEX IF NOT EXISTS idx_offline_tests_batch ON offline_tests(batch);

-- ================================================================
-- DEFAULT ADMIN ACCOUNT
-- The app hashes passwords with SHA-256 (hex string).
-- pgcrypto's encode(digest(text,'sha256'),'hex') produces the same value.
--
-- Default credentials:  username: admin   password: praeparatio@admin2024
-- CHANGE THE PASSWORD after first login (see helper query below).
-- ================================================================
INSERT INTO users (
  id, name, username, password_hash,
  student_class, batch, is_admin, prepcoins
)
VALUES (
  gen_random_uuid(),
  'Administrator',
  'admin',
  encode(digest('praeparatio@admin2024', 'sha256'), 'hex'),
  'admin',
  'admin',
  true,
  0
)
ON CONFLICT (username) DO NOTHING;

-- ================================================================
-- HOW TO ADD MORE ADMINS (run in Supabase SQL Editor)
-- Replace the name, username, and password values as needed.
-- ================================================================
-- INSERT INTO users (name, username, password_hash, student_class, batch, is_admin, prepcoins)
-- VALUES (
--   'Second Admin',
--   'admin2',
--   encode(digest('YourPasswordHere', 'sha256'), 'hex'),
--   'admin', 'admin', true, 0
-- );

-- ================================================================
-- HOW TO CHANGE AN ADMIN PASSWORD (run in Supabase SQL Editor)
-- ================================================================
-- UPDATE users
-- SET password_hash = encode(digest('NewPasswordHere', 'sha256'), 'hex')
-- WHERE username = 'admin' AND is_admin = true;
