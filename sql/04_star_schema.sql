USE job_market_analysis;

DROP TABLE IF EXISTS bridge_job_skills;
CREATE TABLE bridge_job_skills (
    job_id INT NOT NULL,
    skill_name VARCHAR(500) NOT NULL,
    skill_category VARCHAR(150) NOT NULL
);

INSERT INTO bridge_job_skills (job_id, skill_name, skill_category)
SELECT 
    job_id,
    LEFT(
        CASE 
            WHEN skill IN ('power bi', 'powerbi', 'power-bi', 'dax') THEN 'Power BI'
            WHEN skill IN ('sql', 'mysql', 'plsql', 't-sql', 'postgresql', 'sql server') THEN 'SQL'
            WHEN skill IN ('python', 'pandas', 'numpy', 'scipy') THEN 'Python'
            WHEN skill IN ('tableau') THEN 'Tableau'
            WHEN skill IN ('excel', 'advanced excel', 'vba', 'ms excel') THEN 'Excel'
            WHEN skill IN ('aws', 'amazon web services') THEN 'AWS'
            WHEN skill IN ('azure', 'microsoft azure') THEN 'Azure'
            WHEN skill IN ('gcp', 'google cloud platform', 'google cloud') THEN 'GCP'
            WHEN skill IN ('snowflake') THEN 'Snowflake'
            WHEN skill IN ('databricks') THEN 'Databricks'
            WHEN skill IN ('spark', 'pyspark', 'apache spark') THEN 'Apache Spark'
            WHEN skill IN ('machine learning', 'ml', 'deep learning', 'nlp') THEN 'Machine Learning'
            WHEN skill IN ('r') THEN 'R'
            WHEN skill IN ('sas') THEN 'SAS'
            WHEN skill IN ('hadoop', 'hive', 'kafka') THEN 'Big Data Tools'
            WHEN skill IN ('git', 'github', 'ci/cd') THEN 'Git / Version Control'
            ELSE CONCAT(UPPER(SUBSTRING(skill, 1, 1)), SUBSTRING(skill, 2))
        END, 
        255
    ) AS skill_name,
    
    CASE 
        WHEN skill IN ('sql', 'mysql', 'plsql', 't-sql', 'postgresql', 'sql server', 'python', 'pandas', 'numpy', 'r', 'java', 'scala', 'c++', 'vba') 
            THEN 'Programming & Querying'
        WHEN skill IN ('power bi', 'powerbi', 'power-bi', 'dax', 'tableau', 'excel', 'advanced excel', 'ms excel', 'looker', 'qlik', 'qlikview', 'ssrs') 
            THEN 'BI & Visualization'
        WHEN skill IN ('aws', 'amazon web services', 'azure', 'microsoft azure', 'gcp', 'google cloud', 'snowflake', 'databricks', 'spark', 'pyspark', 'apache spark', 'hadoop', 'hive', 'kafka') 
            THEN 'Cloud & Big Data'
        WHEN skill IN ('machine learning', 'ml', 'deep learning', 'nlp', 'statistics', 'statistical modeling', 'tensorflow', 'pytorch') 
            THEN 'Data Science & ML'
        ELSE 'Other Technical Skills'
    END AS skill_category
FROM (
    SELECT job_id, LOWER(TRIM(skill_1)) AS skill FROM jobs_cleaned WHERE skill_1 IS NOT NULL AND TRIM(skill_1) <> ''
    UNION ALL SELECT job_id, LOWER(TRIM(skill_2)) FROM jobs_cleaned WHERE skill_2 IS NOT NULL AND TRIM(skill_2) <> ''
    UNION ALL SELECT job_id, LOWER(TRIM(skill_3)) FROM jobs_cleaned WHERE skill_3 IS NOT NULL AND TRIM(skill_3) <> ''
    UNION ALL SELECT job_id, LOWER(TRIM(skill_4)) FROM jobs_cleaned WHERE skill_4 IS NOT NULL AND TRIM(skill_4) <> ''
    UNION ALL SELECT job_id, LOWER(TRIM(skill_5)) FROM jobs_cleaned WHERE skill_5 IS NOT NULL AND TRIM(skill_5) <> ''
    UNION ALL SELECT job_id, LOWER(TRIM(skill_6)) FROM jobs_cleaned WHERE skill_6 IS NOT NULL AND TRIM(skill_6) <> ''
    UNION ALL SELECT job_id, LOWER(TRIM(skill_7)) FROM jobs_cleaned WHERE skill_7 IS NOT NULL AND TRIM(skill_7) <> ''
    UNION ALL SELECT job_id, LOWER(TRIM(skill_8)) FROM jobs_cleaned WHERE skill_8 IS NOT NULL AND TRIM(skill_8) <> ''
) AS raw_skills
WHERE skill NOT IN ('data', 'management', 'senior', 'analysis', 'analytics', 'analytical', 'lead', 'associate', 'developer');

DROP TABLE IF EXISTS dim_skills;
CREATE TABLE dim_skills AS
SELECT DISTINCT 
    skill_name,
    skill_category
FROM bridge_job_skills;

DROP TABLE IF EXISTS fact_jobs;
CREATE TABLE fact_jobs AS
SELECT 
    job_id,
    title,
    company,
    role_category,
    location_raw,
    department,
    experience_tier,
    exp_min_yrs,
    exp_max_yrs,
    exp_mid_yrs,
    star_rating,
    reviews_count,
    salary_min_lpa,
    salary_max_lpa,
    salary_mid_lpa
FROM jobs_cleaned;