USE job_market_analysis;

DROP TABLE IF EXISTS jobs_cleaned;

CREATE TABLE jobs_cleaned AS
SELECT 
    job_id,
    title,
    company,
    star_rating,
    reviews_count,
    location_raw,
    department,
    role_category,
    exp_min_yrs,
    exp_max_yrs,
    ROUND((exp_min_yrs + exp_max_yrs) / 2.0, 1) AS exp_mid_yrs,
    
    CASE 
        WHEN exp_max_yrs <= 2 THEN 'Entry Level (0-2 yrs)'
        WHEN exp_max_yrs BETWEEN 3 AND 5 THEN 'Mid Level (3-5 yrs)'
        WHEN exp_max_yrs BETWEEN 6 AND 9 THEN 'Senior (6-9 yrs)'
        WHEN exp_max_yrs >= 10 THEN 'Lead / Principal (10+ yrs)'
        ELSE 'Unspecified'
    END AS experience_tier,
    
    salary_min_lpa,
    salary_max_lpa,
    ROUND((salary_min_lpa + salary_max_lpa) / 2.0, 2) AS salary_mid_lpa,
    
    skill_1, skill_2, skill_3, skill_4, skill_5, skill_6, skill_7, skill_8
FROM (
    SELECT 
        ROW_NUMBER() OVER () AS job_id,
        TRIM(Title) AS title,
        TRIM(Company) AS company,
        TRIM(starRating) AS star_rating,
        TRIM(reviewsCount) AS reviews_count,
        TRIM(location) AS location_raw,
        TRIM(Dept) AS department,
        
        CASE 
            WHEN LOWER(Title) LIKE '%data scientist%' OR LOWER(Title) LIKE '%machine learning%' OR LOWER(Title) LIKE '%deep learning%' THEN 'Data Scientist / ML'
            WHEN LOWER(Title) LIKE '%data engineer%' OR LOWER(Title) LIKE '%etl%' OR LOWER(Title) LIKE '%big data%' OR LOWER(Title) LIKE '%pipeline%' THEN 'Data Engineer'
            WHEN LOWER(Title) LIKE '%power bi%' OR LOWER(Title) LIKE '%tableau%' OR LOWER(Title) LIKE '%business intelligence%' OR LOWER(Title) LIKE '%looker%' OR LOWER(Title) LIKE '%qlik%' THEN 'BI & Visualization'
            WHEN LOWER(Title) LIKE '%data analyst%' OR LOWER(Title) LIKE '%business analyst%' OR LOWER(Title) LIKE '%analytics%' OR LOWER(Title) LIKE '%reporting%' THEN 'Data Analyst'
            ELSE 'Other Analytics'
        END AS role_category,
        
        CASE 
            WHEN salary LIKE '%-%' AND salary LIKE '%Lacs%' AND salary NOT LIKE '%,%' AND salary NOT LIKE '%Cr%' THEN 
                CAST(TRIM(SUBSTRING_INDEX(salary, '-', 1)) AS DECIMAL(6,2))
            ELSE NULL 
        END AS salary_min_lpa,
        
        CASE 
            WHEN salary LIKE '%-%' AND salary LIKE '%Lacs%' AND salary NOT LIKE '%,%' AND salary NOT LIKE '%Cr%' THEN 
                CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(salary, 'Lacs', 1), '-', -1)) AS DECIMAL(6,2))
            ELSE NULL 
        END AS salary_max_lpa,

        CASE 
            WHEN experience LIKE '%-%' THEN 
                CAST(TRIM(SUBSTRING_INDEX(experience, '-', 1)) AS UNSIGNED)
            ELSE NULL 
        END AS exp_min_yrs,
        
        CASE 
            WHEN experience LIKE '%-%' THEN 
                CAST(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(experience, 'Yrs', 1), '-', -1)) AS UNSIGNED)
            ELSE NULL 
        END AS exp_max_yrs,

        skill_1, skill_2, skill_3, skill_4, skill_5, skill_6, skill_7, skill_8
    FROM jobs_raw
    WHERE Title LIKE '%Data%'
       OR Title LIKE '%Analyst%'
       OR Title LIKE '%Analytics%'
       OR Title LIKE '%BI%'
       OR Title LIKE '%Scientist%'
       OR Title LIKE '%Engineer%'
) AS parsed_jobs;