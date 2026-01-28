-- Phase 1: Supabase Schema (No Authentication, No RLS)
-- 
-- This schema mirrors the local SQLite structure for cloud backup.
-- NO AUTHENTICATION: All tables are publicly accessible in Phase 1.
-- NO RLS: Row Level Security is deferred to Phase 2.
--
-- WARNING: This is for development/testing only. Production deployment
-- should wait until Phase 2 when authentication is implemented.

-- Children table
CREATE TABLE IF NOT EXISTS children (
  id UUID PRIMARY KEY,
  nickname TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Handwriting attempts table
CREATE TABLE IF NOT EXISTS handwriting_attempts (
  id UUID PRIMARY KEY,
  child_id UUID NOT NULL REFERENCES children(id) ON DELETE CASCADE,
  target_character TEXT NOT NULL,
  shape_similarity TEXT NOT NULL CHECK (shape_similarity IN ('high', 'medium', 'low')),
  confidence_score REAL NOT NULL CHECK (confidence_score >= 0 AND confidence_score <= 1),
  feedback_text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_attempts_child 
  ON handwriting_attempts(child_id);

CREATE INDEX IF NOT EXISTS idx_attempts_created 
  ON handwriting_attempts(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_children_created 
  ON children(created_at DESC);

-- Phase 1 Note: No RLS policies, no auth.users references
-- This will be added in Phase 2 when parent login is implemented
