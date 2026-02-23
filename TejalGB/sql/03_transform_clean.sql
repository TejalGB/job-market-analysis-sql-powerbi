USE job_market_analysis;

-- Create filtered table
DROP TABLE IF EXISTS jobs_filtered;

CREATE TABLE jobs_filtered AS
SELECT *
FROM jobs_raw
WHERE Title LIKE '%Data%'
   OR Title LIKE '%Analyst%';

-- Add job_id first (important)
ALTER TABLE jobs_filtered
ADD COLUMN job_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

-- Add salary columns
ALTER TABLE jobs_filtered
ADD COLUMN salary_min DECIMAL(6,2),
ADD COLUMN salary_max DECIMAL(6,2),
ADD COLUMN salary_mid DECIMAL(6,2);

SET SQL_SAFE_UPDATES = 0;

-- Extract salary_min
UPDATE jobs_filtered
SET salary_min = CAST(TRIM(SUBSTRING_INDEX(salary, '-', 1)) AS DECIMAL(6,2))
WHERE salary LIKE '%Lacs%';

-- Extract salary_max
UPDATE jobs_filtered
SET salary_max = CAST(
  TRIM(
    SUBSTRING_INDEX(
      SUBSTRING_INDEX(salary, 'Lacs', 1),
      '-', -1
    )
  ) AS DECIMAL(6,2)
)
WHERE salary LIKE '%Lacs%';

-- Compute salary_mid
UPDATE jobs_filtered
SET salary_mid = (salary_min + salary_max) / 2
WHERE salary_min IS NOT NULL
  AND salary_max IS NOT NULL;

-- Add experience columns
ALTER TABLE jobs_filtered
ADD COLUMN exp_min INT,
ADD COLUMN exp_max INT;

-- Extract exp_min
UPDATE jobs_filtered
SET exp_min = CAST(SUBSTRING_INDEX(experience, '-', 1) AS UNSIGNED)
WHERE experience LIKE '%-%';

-- Extract exp_max
UPDATE jobs_filtered
SET exp_max = CAST(
  SUBSTRING_INDEX(
    SUBSTRING_INDEX(experience, ' Yrs', 1),
    '-', -1
  ) AS UNSIGNED
)
WHERE experience LIKE '%-%';
