CREATE DATABASE job_market_analysis;
USE job_market_analysis;

DROP TABLE IF EXISTS jobs_raw;

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
