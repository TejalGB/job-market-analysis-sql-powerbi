# Indian Tech Job Market Analytics: Workforce Intelligence & Compensation Benchmarking

An end-to-end data analytics and business intelligence solution analyzing **~94,000 tech job postings** from Naukri.com. This project extracts actionable labour market intelligence on compensation bands, skill premiums, experience bottlenecks, and regional hiring concentrations across India.

---

## 🎯 Executive Business Summary

1. **The Core Skill Trinity**: **SQL (64%)** and **Python (58%)** are the baseline prerequisites for data analytics roles, while **Power BI** is demanded in 42% of reporting roles.
2. **Cloud & Big Data Salary Premium**: Postings requiring Cloud/Big Data technologies (**AWS, Azure, Snowflake, PySpark**) offer a **+28% to +35% salary association** over traditional SQL-only reporting roles.
3. **Regional Hiring Density**: **Bengaluru (32%)**, **Hyderabad (14%)**, and **Pune (12%)** account for nearly 60% of all data job openings in India.
4. **Experience Distribution Bottleneck**: **62% of hiring demand** concentrates on Mid-Level professionals (**3–5 years**), while entry-level positions (<2 years) represent only 14% of postings.

> *Note on Causality: Reported salary premiums reflect observed statistical associations within posted compensation packages on Naukri.com (where Cloud/Big Data skills frequently co-occur in senior and specialized roles), rather than standalone causal salary uplifts.*

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

The data pipeline enforces strict transformation, deduplication, and parsing rules to ensure metric integrity across all reporting layers:

| Stage / Table | Record Count | Description & Filtering Criteria |
| :--- | :---: | :--- |
| **Raw Ingested (`jobs_raw`)** | `94,511` | Total job postings snapshot from Naukri.com (March 2023) |
| **Disclosed Salary & Exp** | `22,307` | Postings with explicit salary ranges (Lacs/PA) and experience (Yrs) |
| **Fact Table (`fact_jobs`)** | `22,307` | Cleaned analytical base with parsed min/max/mid salary and experience |
| **Bridge Table (`bridge_job_skills`)** | `~68,000` | Normalized, unpivoted many-to-many job-to-skill pairs |
| **Dimension (`dim_skills`)** | `15` | Standardized canonical skills mapped to tech domains |

---

## 🗃️ Dimensional Data Model (Star Schema)

The database schema is modeled as a **Star Schema** in Power BI with a Bridge Table pattern to handle many-to-many job-skill relationships:

<img src="Data%20Model.png" width="650" alt="Star Schema Data Model"/>

### Relationship Architecture
* **`dim_skills` (1) $ightarrow$ `bridge_job_skills` (*)**: Single-direction filter (1:Many) from standardized skill catalog to job-skill pairs.
* **`fact_jobs` (1) $\leftrightarrow$ `bridge_job_skills` (*)**: Bi-directional cross-filtering (1:Many) enabling visual slicers on `dim_skills` to propagate filter context down to `fact_jobs` for accurate job counts, penetration rates, and salary metrics.

---

## 🛠️ Tech Stack & Implementation

* **Database & Data Engineering**: **MySQL 8.0**
  * Staging table definition and batch CSV data ingestion
  * Cleaned and parsed salary (LPA) and experience (Years)
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

| Page 1: Market Analysis | Page 2: Salary Insights |
| :---: | :---: |
| <img src="Market%20Overview.png" width="400"/> | <img src="Salary%20Insights.png" width="400"/> |

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
    (SELECT COUNT(DISTINCT job_id) FROM fact_jobs) AS total_jobs_universe,
    ROUND(COUNT(DISTINCT b.job_id) * 100.0 / (SELECT COUNT(DISTINCT job_id) FROM fact_jobs), 1) AS penetration_pct
FROM bridge_job_skills b
GROUP BY b.skill_name
ORDER BY penetration_pct DESC;

-- 2. Cloud & Big Data Salary Association vs Market Baseline
WITH market_baseline AS (
    SELECT AVG(salary_mid_lpa) AS avg_market_lpa FROM fact_jobs WHERE salary_mid_lpa IS NOT NULL
),
skill_stats AS (
    SELECT 
        b.skill_name,
        AVG(f.salary_mid_lpa) AS avg_skill_lpa,
        COUNT(f.job_id) AS sample_size
    FROM bridge_job_skills b
    JOIN fact_jobs f ON b.job_id = f.job_id
    WHERE f.salary_mid_lpa IS NOT NULL
    GROUP BY b.skill_name
)
SELECT 
    s.skill_name,
    ROUND(s.avg_skill_lpa, 2) AS avg_skill_lpa,
    ROUND(m.avg_market_lpa, 2) AS avg_market_lpa,
    ROUND(((s.avg_skill_lpa - m.avg_market_lpa) / m.avg_market_lpa) * 100, 1) AS salary_premium_pct,
    s.sample_size
FROM skill_stats s
CROSS JOIN market_baseline m
ORDER BY salary_premium_pct DESC;

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
* **Salary Disclosure Bias**: In the raw dataset, ~76.4% of postings did not disclose numeric compensation (marked as *"Not Disclosed"*). Salary analyses reflect the **22,307 postings** with explicit LPA compensation bands.
* **Platform Scope**: Data reflects postings on a single dominant job portal (Naukri.com) and captures market hiring intent rather than census-level workforce volume.

---

## 🚀 How to Reproduce & Run Locally

### Prerequisites
* MySQL Server 8.0+ / MySQL Workbench
* Power BI Desktop

### 1. Data Ingestion Options
* **Option A (Quick Sample)**: Use the bundled sample dataset (`data/sample_naukri_1000.csv`) included in this repository.
* **Option B (Full ~94k Dataset)**: Download the full Naukri.com March 2023 dataset from [Kaggle](https://www.kaggle.com/) and place it in the project root.

### 2. Database Ingestion & Star Schema Build
1. Open **MySQL Workbench**.
2. Run the SQL scripts in numerical sequence:
   * `sql/01_setup.sql`: Creates `job_market_analysis` database and landing table.
   * `sql/02_data_load.sql`: Ingests the CSV file (adjust path to full CSV or sample CSV).
   * `sql/03_transform_clean.sql`: Executes single-pass cleaning & feature extraction.
   * `sql/04_star_schema.sql`: Builds `fact_jobs`, `bridge_job_skills`, and `dim_skills`.

### 3. Power BI Reporting
1. Open `Job Market Analysis.pbix` in **Power BI Desktop**.
2. Refresh data source connection pointing to your local MySQL database.
3. Review the interactive visuals, slicers, and DAX measures.

---

## 📄 License
This project is licensed under the **MIT License**.
