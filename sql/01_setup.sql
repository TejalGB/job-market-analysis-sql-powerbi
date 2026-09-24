-- =============================================================================
-- File: 01_setup.sql
-- Description: Creates the job_market_analysis database and the jobs_raw table
-- =============================================================================

CREATE DATABASE IF NOT EXISTS job_market_analysis;
USE job_market_analysis;

-- Drop table if exists to allow clean re-runs
DROP TABLE IF EXISTS jobs_raw;

-- Landing table schema matching raw Naukri job posting CSV headers
CREATE TABLE jobs_raw (
    Title TEXT,
    Company TEXT,
    starRating TEXT,
    reviewsCount TEXT,
    experience TEXT,
    salary TEXT,
    location TEXT,
    job_description TEXT,
    skill_1 TEXT,
    skill_2 TEXT,
    skill_3 TEXT,
    skill_4 TEXT,
    skill_5 TEXT,
    skill_6 TEXT,
    skill_7 TEXT,
    skill_8 TEXT,
    posted_on TEXT,
    Dept TEXT
);
