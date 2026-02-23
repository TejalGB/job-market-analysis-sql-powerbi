USE job_market_analysis;

-- Optional: Clear table before reloading
TRUNCATE TABLE jobs_raw;

LOAD DATA LOCAL INFILE 'C:/Users/gowin/OneDrive/Desktop/SQL Project/Naukri Jobs Data - Mar 2023.csv'
INTO TABLE jobs_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Verify load
SELECT COUNT(*) AS total_rows FROM jobs_raw;
