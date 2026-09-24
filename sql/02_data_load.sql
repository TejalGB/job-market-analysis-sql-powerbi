-- =============================================================================
-- File: 02_data_load.sql
-- Description: Loads raw Naukri jobs CSV dataset into MySQL jobs_raw table
-- =============================================================================

USE job_market_analysis;

-- Optional: Clear table before reloading
TRUNCATE TABLE jobs_raw;

-- INSTRUCTIONS:
-- 1. Ensure MySQL local_infile is enabled: SET GLOBAL local_infile = 1;
-- 2. Adjust the relative path below or provide the absolute path to your CSV file.
LOAD DATA LOCAL INFILE 'C:/Users/gowin/OneDrive/Desktop/SQL Project/Naukri Jobs Data - Mar 2023.csv'
INTO TABLE jobs_raw
FIELDS TERMINATED BY ','
ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify successful ingestion
SELECT 
 COUNT(*) AS total_raw_records,
 COUNT(DISTINCT Company) AS unique_companies
FROM jobs_raw;
