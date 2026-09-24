# Indian Tech Job Market Analytics: Workforce Intelligence & Compensation Benchmarking

An end-to-end data analytics and business intelligence solution analyzing **~94,000 tech job postings** from Naukri.com. This project extracts actionable labour market intelligence on compensation bands, skill premiums, experience bottlenecks, and regional hiring concentrations across India.

---

## 🎯 Executive Business Summary

1. **The Core Skill Trinity**: **SQL (64%)** and **Python (58%)** are the baseline prerequisites for data analytics roles, while **Power BI** is demanded in 42% of reporting roles.
2. **Cloud & Big Data Salary Premium**: Postings requiring Cloud/Big Data technologies (**AWS, Azure, Snowflake, PySpark**) offer a **+28% to +35% salary premium** over traditional SQL-only reporting roles.
3. **Regional Hiring Density**: **Bengaluru (32%)**, **Hyderabad (14%)**, and **Pune (12%)** account for nearly 60% of all data job openings in India.
4. **Experience Distribution Bottleneck**: **62% of hiring demand** concentrates on Mid-Level professionals (**3–5 years**), while entry-level positions (<2 years) represent only 14% of postings.

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

## 🗃️ Dimensional Data Model (Star Schema)

The database schema is modeled as a **Star Schema** in Power BI to ensure fast analytical querying, slicer filtering, and relationship integrity:

<p align="center">
  <img src="Data%20Model.png" width="600" alt="Star Schema Data Model" />
</p>

---

## 🛠️ Tech Stack & Implementation

* **Database & Data Engineering**: **MySQL 8.0**
  * Staging and schema definition
  * Robust single-pass regex string extraction for salaries (Lacs/PA) and experience (Yrs)
  * Skill unpivoting and canonical standardization (`power bi` / `powerbi` -> `Power BI`)
  * Star schema modeling (`fact_jobs`, `bridge_job_skills`, `dim_skills`)
* **Business Intelligence & Analytics**: **Microsoft Power BI Desktop**
  * Interactive 2-page executive report
  * Star Schema dimensional modeling with bi-directional cross-filtering
  * Statistical DAX measures (Medians, 25th/75th Percentiles, IQR, Skill Penetration)

---

## 📐 Key DAX Measures

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

// 3. Skill Salary Premium (Financial uplift over market average)
Skill Salary Premium LPA = 
VAR CurrentSkillAvg = AVERAGE('fact_jobs'[salary_mid_lpa])
VAR MarketAvg = CALCULATE(AVERAGE('fact_jobs'[salary_mid_lpa]), REMOVEFILTERS('bridge_job_skills'))
RETURN
    IF(NOT(ISBLANK(CurrentSkillAvg)), CurrentSkillAvg - MarketAvg, BLANK())

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

## 🚀 How to Reproduce & Run Locally

### Prerequisites
* MySQL Server 8.0+ / MySQL Workbench
* Power BI Desktop

### 1. Database Ingestion & Star Schema Build
1. Open **MySQL Workbench**.
2. Run the SQL scripts in numerical sequence:
   * `sql/01_setup.sql`: Creates `job_market_analysis` database and landing table.
   * `sql/02_data_load.sql`: Ingests the CSV file (adjust filepath if necessary).
   * `sql/03_transform_clean.sql`: Executes single-pass cleaning & feature extraction.
   * `sql/04_star_schema.sql`: Builds `fact_jobs`, `bridge_job_skills`, and `dim_skills`.

### 2. Power BI Reporting
1. Open `Job Market Analysis.pbix` in **Power BI Desktop**.
2. Refresh data source connection pointing to your local MySQL database.
3. Review the interactive visuals, slicers, and DAX measures.

---

## 📄 License
This project is licensed under the **MIT License**.
