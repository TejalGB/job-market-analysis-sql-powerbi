# TejalGB-job-market-analysis-sql-powerbi
End-to-end job market analytics project using MySQL and Power BI

## Overview

This project analyzes large-scale job posting data (~94,000 records) to identify hiring trends, salary patterns, and skill demand in the Indian job market. It combines **MySQL-based data engineering** with an interactive **Power BI dashboard** to deliver actionable labor market insights. The project demonstrates end-to-end analytics workflow from raw data ingestion to business intelligence reporting.

---

## Tech Stack

* **MySQL** (Data ingestion, cleaning, transformation , Normalization)
* **Power BI** (Star schema modeling, DAX, Interactive Visuals)
  
---

## Project Workflow

### 1. Data Pipeline
1. Create schema + raw table (`sql/01_setup.sql`)
2. Load CSV into MySQL (`sql/02_data_load.sql`)
3. Clean and transform salary + experience (`sql/03_transform_clean.sql`)
4. Normalize skills + create fact tables for Power BI (`sql/04_normalization_and_facts.sql`)

---

### 2. Business Intelligence Dashboard (Power BI)
Designed interactive dashboard with:

#### Page 1 — Market Overview
* Total jobs, Avg experience, Avg salary
* Top in-demand skills (technical)
* Jobs by department & location

#### Page 2 — Salary Insights
* Salary Trend by Experience
* Salary Distribution Bands
* Average Salary by Department
  
---

## Key Capabilities Demonstrated

* End-to-end data pipeline development
* Relational data modeling (Star Schema)
* Business intelligence reporting & dashboard design
* Business insight extraction from raw job data

Showcased practical SQL transformation, relational modeling, and business intelligence reporting applied to real-world job market data.

