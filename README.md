# Indian Tech Job Market Analytics: Workforce Intelligence & Compensation Benchmarking

An end-to-end data analytics and business intelligence solution analyzing **~94,000 tech job postings** from Naukri.com. This project extracts actionable labour market intelligence on compensation bands, skill premiums, experience bottlenecks, and regional hiring concentrations across India.

---

## 🎯 Executive Business Summary

1. **The Core Skill Trinity**: **SQL (64%)** and **Python (58%)** are the baseline prerequisites for data analytics roles, while **Power BI** is demanded in 42% of reporting roles.
2. **Cloud & Big Data Salary Premium**: Postings requiring Cloud/Big Data technologies (**AWS, Azure, Snowflake, PySpark**) average **₹16.8 LPA**, commanding a **+31.2% salary premium** over traditional SQL-only reporting roles (**₹12.8 LPA**).
3. **Regional Hiring Density**: **Bengaluru (32%)**, **Hyderabad (14%)**, and **Pune (12%)** account for nearly 60% of all data job openings in India.
4. **Experience Distribution Bottleneck**: **62% of hiring demand** concentrates on Mid-Level professionals (**3–5 years**), while entry-level positions (<2 years) represent only 14% of postings.

> *Note on Causality: Reported salary differentials reflect observed statistical associations within posted compensation packages on Naukri.com (where Cloud/Big Data skills frequently co-occur in specialized and senior roles), rather than standalone causal salary uplifts.*

---

## 🏗️ Architecture & Data Pipeline

```mermaid
flowchart LR
    A["Raw Naukri CSV (~94k rows)"] --> B["MySQL Staging (01_setup.sql / 02_data_load.sql)"]
    B --> C["Single-Pass Cleaning (03_transform_clean.sql)"]
    C --> D["Star Schema (04_star_schema.sql)"]
    D --> E["Power BI Model and DAX Engine"]
    E --> F["Interactive Executive Dashboard"]
```

---

## 🔍 Data Validation & Pipeline Lineage

The data pipeline reconciles raw scraped postings into domain-specific analytical fact and dimension tables through documented transformation rules:

| Pipeline Stage / Table | Row Count | Specific SQL Rule & Transformation Logic |
| :--- | :---: | :--- |
| **Raw Scraped Ingest (`jobs_raw`)** | `94,511` | Ingested via `02_data_load.sql` across all tech sectors on Naukri.com (March 2023). |
| **Data Domain Fact Table (`fact_jobs`)** | `22,307` | Filtered in `03_transform_clean.sql` using domain title patterns: `WHERE Title LIKE '%Data%' OR Title LIKE '%Analyst%' OR Title LIKE '%Analytics%' OR Title LIKE '%BI%' OR Title LIKE '%Scientist%' OR Title LIKE '%Engineer%'`. |
| **Salary-Disclosed Sub-cohort** | `4,850` | Records within `fact_jobs` with non-null `salary_min_lpa` and `salary_max_lpa` (used for compensation benchmarking, while all 22,307 rows power role, location, and skill volume). |
| **Bridge Table (`bridge_job_skills`)** | `~68,000` | Normalized many-to-many skill pairs extracted from `skill_1` through `skill_8` in `04_star_schema.sql`. |
| **Skill Dimension (`dim_skills`)** | `15` | Canonical technical skills mapped into domains (*Programming, BI, Cloud, Data Engineering*). |

---

## 🗃️ Dimensional Data Model (Star Schema)

The database schema is modeled as a **Star Schema** in Power BI with a Bridge Table pattern to handle many-to-many job-skill relationships:

![Star Schema Data Model](Data%20Model.png)

### Relationship Architecture
* **`dim_skills` (1) $ightarrow$ `bridge_job_skills` (*)**: Single-direction filter (1:Many) from standardized skill catalog to job-skill pairs.
* **`fact_jobs` (1) $\leftrightarrow$ `bridge_job_skills` (*)**: Bi-directional cross-filtering (1:Many) enabling visual slicers on `dim_skills` to propagate filter context down to `fact_jobs` for accurate job counts, penetration rates, and salary metrics.

---

## 🛠️ Tech Stack & Implementation

* **Database & Data Engineering**: **MySQL 8.0**
  * Staging table definition and portable CSV data ingestion (supports bundled sample and full dataset)
  * Data cleaning & parsing of salary (LPA) and experience (Years)
  * Skill unpivoting and canonical standardization (`power bi` / `powerbi` -> `Power BI`)
  * Star schema modeling (`fact_jobs`, `bridge_job_skills`, `dim_skills`)
* **Business Intelligence & Analytics**: **Microsoft Power BI Desktop**
  * Interactive 2-page executive report
  * Star Schema dimensional modeling with bi-directional bridge filtering
  * Statistical DAX measures (Medians, 25th/75th Percentiles, IQR, Skill Penetration)

---

## 📐 Key DAX Measures & Logic

<details>
<summary><b>👉 Click to expand Key DAX Formulas</b></summary>

```dax
// 1. Median Salary (Mitigates outlier distortion)
Median Salary (LPA) = 
MEDIAN('fact_jobs'[salary_mid_lpa])

// 2. Skill Market Penetration Rate (%)
Skill Penetration % = 
VAR TotalFilteredJobs = 
    CALCULATE(
        DISTINCTCOUNT('fact_jobs'[job_id]), 
        REMOVEFILTERS('bridge_job_skills')
    )
VAR JobsWithSkill = 
    DISTINCTCOUNT('bridge_job_skills'[job_id])
RETURN
    DIVIDE(JobsWithSkill, TotalFilteredJobs, 0)

// 3. Skill Salary Premium (Financial uplift over baseline market average)
Skill Salary Premium LPA = 
VAR CurrentSkillAvg = AVERAGE('fact_jobs'[salary_mid_lpa])
VAR BaselineMarketAvg = 
    CALCULATE(
        AVERAGE('fact_jobs'[salary_mid_lpa]), 
        ALLSELECTED('fact_jobs'),
        REMOVEFILTERS('dim_skills', 'bridge_job_skills')
    )
RETURN
    IF(NOT(ISBLANK(CurrentSkillAvg)), CurrentSkillAvg - BaselineMarketAvg, BLANK())

// 4. Interquartile Range (IQR - Salary Spread)
Salary IQR LPA = 
PERCENTILEX.INC(FILTER('fact_jobs', NOT(ISBLANK('fact_jobs'[salary_mid_lpa]))), 'fact_jobs'[salary_mid_lpa], 0.75) -
PERCENTILEX.INC(FILTER('fact_jobs', NOT(ISBLANK('fact_jobs'[salary_mid_lpa]))), 'fact_jobs'[salary_mid_lpa], 0.25)
```

</details>

---

## 📊 Dashboard Preview

### Page 1: Market Analysis
![Market Overview](Market%20Overview.png)

### Page 2: Salary Insights
![Salary Insights](Salary%20Insights.png)

---

## 🔬 SQL Validation Queries for Headline Metrics

To independently audit the headline metrics reported in this project, execute the queries below in MySQL:

<details>
<summary><b>👉 Click to expand SQL Validation Queries</b></summary>

```sql
USE job_market_analysis;

-- 1. Skill Penetration Rate (% of Jobs Demanding Skill)
SELECT 
    b.skill_name,
    COUNT(DISTINCT b.job_id) AS jobs_requiring_skill,
    (SELECT COUNT(DISTINCT job_id) FROM fact_jobs) AS total_data_jobs,
    ROUND(COUNT(DISTINCT b.job_id) * 100.0 / (SELECT COUNT(DISTINCT job_id) FROM fact_jobs), 1) AS penetration_pct
FROM bridge_job_skills b
GROUP BY b.skill_name
ORDER BY penetration_pct DESC;

-- 2. Cloud & Big Data Stack vs SQL-Only Reporting Roles Salary Comparison
WITH cloud_bigdata_jobs AS (
    SELECT DISTINCT job_id
    FROM bridge_job_skills
    WHERE skill_name IN ('AWS', 'Azure', 'Snowflake', 'PySpark', 'Spark')
),
sql_only_jobs AS (
    SELECT DISTINCT job_id
    FROM bridge_job_skills
    WHERE skill_name IN ('SQL', 'Excel', 'Power BI')
      AND job_id NOT IN (SELECT job_id FROM cloud_bigdata_jobs)
),
cohort_salaries AS (
    SELECT 
        'Cloud / Big Data Roles' AS cohort_name,
        AVG(f.salary_mid_lpa) AS avg_salary_lpa,
        COUNT(f.job_id) AS sample_size
    FROM fact_jobs f
    JOIN cloud_bigdata_jobs c ON f.job_id = c.job_id
    WHERE f.salary_mid_lpa IS NOT NULL

    UNION ALL

    SELECT 
        'SQL-Only / Reporting Roles' AS cohort_name,
        AVG(f.salary_mid_lpa) AS avg_salary_lpa,
        COUNT(f.job_id) AS sample_size
    FROM fact_jobs f
    JOIN sql_only_jobs s ON f.job_id = s.job_id
    WHERE f.salary_mid_lpa IS NOT NULL
)
SELECT 
    cohort_name,
    ROUND(avg_salary_lpa, 2) AS avg_salary_lpa,
    sample_size
FROM cohort_salaries;

-- 3. Experience Tier Distribution
SELECT 
    experience_tier,
    COUNT(*) AS total_postings,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fact_jobs), 1) AS pct_of_market
FROM fact_jobs
GROUP BY experience_tier
ORDER BY total_postings DESC;
```

</details>

---

## 📌 Dataset Scope & Limitations

* **Collection Period**: Snapshot dataset scraped from **Naukri.com** in **March 2023** (~94,500 tech job postings across India).
* **Domain Focus**: Out of 94,511 raw tech postings, **22,307 records** belong to Data & Analytics roles (Data Analyst, BI, Data Engineer, Data Scientist).
* **Salary Disclosure Bias**: Only ~21.7% of data postings disclose numeric compensation ranges. Salary analyses are computed on the **4,850 postings** with explicit LPA compensation bands.
* **Platform Scope**: Data captures posted employer demand on Naukri.com rather than total economic employment volume.

---

## 🚀 How to Reproduce & Run Locally

### Prerequisites
* MySQL Server 8.0+ / MySQL Workbench
* Power BI Desktop

### 1. Data Ingestion Options
* **Option A (Quick Sample)**: Use the bundled sample dataset [`data/sample_naukri_1000.csv`](data/sample_naukri_1000.csv) included in this repository.
* **Option B (Full ~94k Dataset)**: Download the full Naukri.com March 2023 dataset from [Kaggle](https://www.kaggle.com/) and place it in the project root.

### 2. Database Ingestion & Star Schema Build
1. Open **MySQL Workbench**.
2. Run the SQL scripts in numerical sequence:
   * `sql/01_setup.sql`: Creates `job_market_analysis` database and landing table.
   * `sql/02_data_load.sql`: Ingests the CSV file (defaults to `data/sample_naukri_1000.csv`).
   * `sql/03_transform_clean.sql`: Executes single-pass cleaning & feature extraction.
   * `sql/04_star_schema.sql`: Builds `fact_jobs`, `bridge_job_skills`, and `dim_skills`.

### 3. Power BI Reporting
1. Open `Job Market Analysis.pbix` in **Power BI Desktop**.
2. Refresh data source connection pointing to your local MySQL database.
3. Review the interactive visuals, slicers, and DAX measures.

---

## 📄 License
This project is licensed under the **MIT License**.
