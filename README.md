# Subscription Revenue Modeling with dbt & Snowflake

This project models Annual Recurring Revenue (ARR) for a subscription-based business using dbt for data transformation and Snowflake as the data warehouse.

The goal is to transform raw subscription data into a structured analytical dataset that allows tracking ARR changes over time, identifying lifecycle events such as new revenue, upgrades, downgrades, churn, and reactivations.

The project was developed as part of a Data Engineering challenge focused on subscription revenue modeling and follows modern analytics engineering best practices.

# Project Overview

Subscription businesses generate revenue continuously rather than through one-time purchases. As a result, revenue evolves over time due to events such as:

  -new subscriptions

  -renewals

  -upgrades

  -downgrades

  -churn

  -reactivations

This project models those dynamics by:

Expanding subscriptions into a monthly timeline

Calculating Monthly Recurring Revenue (MRR)

Aggregating to Annual Recurring Revenue (ARR)

Classifying month-over-month ARR changes

The final output is an analytics-ready dataset that captures revenue evolution at a monthly grain.

# Tech Stack

| Tool                         | Purpose                                   |
| ---------------------------- | ----------------------------------------- |
| **dbt Core**                 | Data transformation and modeling          |
| **Snowflake**                | Cloud data warehouse                      |
| **Python (Pandas + Plotly)** | ARR visualization                         |
| **dbt-utils**                | Utility macros (date spine generation)    |
| **Git / GitHub**             | Version control and project documentation |


# Data Pipeline Architecture

The pipeline transforms raw subscription data into a structured ARR analytics dataset.
```
Raw Seed Data
      │
      ▼
Staging Layer
(cleaning & normalization)
      │
      ▼
Date Spine Generation
(month timeline)
      │
      ▼
Subscription Expansion
(monthly subscription activity)
      │
      ▼
ARR Aggregation
(account-level revenue)
      │
      ▼
ARR Change Classification
(revenue lifecycle events)
```

# dbt Model Layers
1. Staging Layer

stg_subscriptions.sql

Cleans and standardizes raw subscription data loaded from seeds.

Ensures correct data types and field naming.

2. Time Spine Layer

date_spine.sql

Generates a continuous sequence of months using:

dbt_utils.date_spine

This ensures revenue can be tracked even in months without explicit subscription events.

3. Transformation Layer
subscription_months.sql

Expands each subscription across all months during which it is active.

Each subscription is converted to monthly granularity.

Monthly recurring revenue is calculated as:

MRR = subscription_arr_usd / 12
monthly_arr.sql

Aggregates subscription MRR to the account-month level, producing total monthly ARR.

# 4. Metrics & Analysis Layer
arr_change_classification.sql

This is the core analytical model.

It calculates:

previous month's ARR (LAG)

ARR change value

ARR change category

ARR changes are classified into lifecycle categories.

# ARR Change Categories

| Category         | Definition                         |
| ---------------- | ---------------------------------- |
| **New**          | Revenue appears for the first time |
| **No Change**    | ARR remains unchanged              |
| **Expansion**    | ARR increases month-over-month     |
| **Contraction**  | ARR decreases month-over-month     |
| **Churn**        | ARR drops from positive to zero    |
| **Reactivation** | ARR returns after being zero       |

These classifications help identify customer lifecycle behavior and revenue trends.

# Key Analytical Insights

Using the final ARR dataset, we can answer important business questions about subscription revenue behavior.

These results are derived from the model: arr_change_classification

January 2024

For January ARR change category was “no changes”.
The value for January was 0 USD.

December 2025

In December 2025 there are 7 new subscriptions and 5 churned subscriptions.
Since the ARR gained from new subscriptions exceeds the ARR lost from churned subscriptions, the net ARR change is positive, which corresponds to an expansion event.

September 2023

In September 2023 there were 5 new subscriptions and 37 subscriptions with no change, with no churn events. Since new subscriptions increase ARR and there are no subscriptions reducing ARR, the net ARR change is positive. The total ARR added by the 5 new subscriptions is 18,900 USD, so the ARR change category is Expansion with a change value of 18,900 USD.

This represents the total ARR associated with subscriptions active on the final day of December 2025.

December 2025

The customer’s ARR in December 2025 is 18,900 USD.

# Data Visualization

To help interpret revenue trends, a Python script generates an ARR visualization.

arr_chart.py

The chart highlights:

revenue growth

churn events

reactivation periods

ARR stability over time

Example output:

arr_chart_improved.png

The visualization helps identify key revenue changes across the subscription lifecycle.

# Running the Project
Follow the steps below to reproduce the project.

1. Install dependencies

Install the required Python packages:
```
pip install -r requirements.txt
```

2. Configure Snowflake connection

Create the dbt profile configuration file:
```
~/.dbt/profiles.yml
```
Example configuration:
```
arr_project:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <account>
      user: <user>
      password: <password>
      role: <role>
      database: <database>
      warehouse: <warehouse>
      schema: <schema>
      threads: 4
```
3. Install dbt packages

Install dbt package dependencies (e.g., dbt-utils):
```
cd arr_project
dbt deps
```
4. Load seed data

Load the raw subscription dataset into Snowflake:
```
dbt seed
```
This step ingests the provided subscription dataset as the raw input for the transformation pipeline.

5. Build the project

Run the full dbt pipeline:
```
dbt build
```
This command will:

load seed data

execute all dbt models

run data quality tests

materialize the final ARR analytical dataset

6. Generate the ARR visualization

From the repository root:
```
python arr_chart.py
```
This script generates a visualization illustrating the evolution of Annual Recurring Revenue (ARR) over time.

# Generating Documentation

dbt automatically generates interactive documentation.

dbt docs generate
dbt docs serve

This allows exploration of:

model lineage

column descriptions

data tests

dependency graph

## Repository Structure

```
dbt-challenge
│
├── arr_project
│   ├── analyses
│   ├── macros
│   ├── models
│   │   ├── staging
│   │   │   └── stg_subscriptions.sql
│   │   │
│   │   ├── date_spine.sql
│   │   ├── subscription_months.sql
│   │   ├── monthly_arr.sql
│   │   └── arr_change_classification.sql
│   │
│   ├── seeds
│   │   └── subscriptions.csv
│   │
│   ├── snapshots
│   ├── tests
│   ├── dbt_project.yml
│   ├── packages.yml
│   └── package-lock.yml
│
├── analysis
│   ├── arr_chart.py
│   ├── arr_data.csv
│   ├── arr_chart.png
│   └── arr_chart_improved.png
│
└── README.md
```
