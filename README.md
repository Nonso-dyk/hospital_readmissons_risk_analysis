# Hospital Readmissions Risk Analysis
### Author: Dike Chinonso

## About the Project

Hospital readmissions are an important issue in healthcare, both for patient outcomes and the cost of care. Understanding which patients are more likely to return to the hospital shortly after discharge can help identify areas that may need closer attention.

In this project, I used SQL to explore hospital readmissions among patients with diabetes, using data from 130 US hospitals collected between 1999 and 2008. I focused on readmissions within 30 days of discharge and explored how factors such as age, diagnoses, medication use, and previous hospital visits relate to readmission rates.

## Business Problem

Hospitals need to understand which patient and encounter characteristics are associated with early readmission to help identify opportunities for better discharge planning and follow-up care. This project investigates patterns in 30-day readmissions among patients with diabetes, focusing on demographic characteristics, clinical factors, previous hospital utilisation, and discharge destinations.

The aim is to identify meaningful differences in readmission rates that may warrant further investigation by healthcare teams.

## Dataset and Tools

### Dataset

- Name: Diabetes 130-US Hospitals for Years 1999–2008
- Source: [UCI Machine Learning Repository](https://doi.org/10.24432/C5230J)
- Description: Hospital encounter records from 130 US hospitals, including patient demographics, diagnoses, medications, laboratory procedures, hospital stays, and readmission status.

### Tools

- MySQL 8.0: Data cleaning, cohort preparation, and analysis.
- MySQL Workbench: Writing and executing SQL queries.

## Methodology

1. Data Cleaning: Replaced placeholder values such as `?` with `NULL` and reviewed missing data.
2. Missing Data: Excluded the weight variable because approximately 97% of its values were missing, making it unsuitable for reliable analysis.
3. Cohort Preparation: Retained the first recorded encounter per patient to establish a consistent cohort and avoid counting patients multiple times.
4. Discharge Exclusions: Excluded selected discharge dispositions associated with death or hospice care because these encounters were not appropriate for the intended analysis of early readmission following discharge.
5. Feature Engineering: Created age midpoints and grouped selected variables to support comparisons across patient and encounter characteristics.
6. Exploratory Data Analysis: Examined readmission rates across demographics, admission types, discharge destinations, diagnosis categories, medication-related variables, and previous hospital utilisation.
7. Readmission Analysis: Used a common analysis cohort to investigate patterns associated with readmission within 30 days.

## Key SQL Techniques Used

- Common Table Expressions (CTEs): Organised the analysis into reusable query steps and created a common cohort for subsequent analysis.
- Window Functions: Used functions such as `RANK()` and `NTILE()` to rank records and group observations.
- CASE Statements: Created categories from continuous or coded variables for easier comparison.
- Aggregate Functions and Subqueries: Calculated readmission rates and compared results across groups.
- Joins: Connected reference tables to translate coded values into readable categories.

## Scope of Analysis

This project uses exploratory data analysis to examine patterns in 30-day hospital readmissions. The analysis focuses on differences in readmission rates across selected patient demographics, clinical characteristics, previous hospital utilisation, and discharge destinations.

The findings show associations in the data and should not be interpreted as evidence of causation. The analysis is intended to identify patterns for further investigation rather than establish independent predictors of readmission.

## Key Findings

- Overall Readmission: Of the 69,198 encounters analysed, 9.0% involved readmission within 30 days, while 31.7% involved readmission after 30 days.
- Previous Hospital Utilisation: Early readmission rates were higher among encounters with previous inpatient visits. The rate was 8.1% among encounters with no previous inpatient visits, compared with 18.9% among those with two previous visits and 23.1% among those with three.
- Age: Early readmission rates were generally higher among older patients, reaching 10.8% among those aged 80–89, compared with 7.1% among those aged 50–59.
- Discharge Destination: Early readmission rates varied by destination: 6.9% for patients discharged home, 13.5% for transfers to skilled nursing facilities, and 27.7% for transfers to rehabilitation facilities.
- Primary Diagnosis: Encounters with a primary diagnosis in the circulatory disease category had an early readmission rate of 9.7%, compared with 9.2% for diabetes, 8.3% for respiratory diseases, and 8.0% for digestive diseases.

## Recommendations

- Consider previous inpatient utilisation when identifying patients who may benefit from closer follow-up after discharge.
- Investigate whether differences in patient needs, discharge planning, and post-discharge support help explain variation in readmission rates across discharge destinations.
- Further examine readmission patterns among patients with circulatory diagnoses and diabetes to identify areas for more detailed clinical analysis.

These are potential areas for further investigation, not interventions proven effective by this analysis.

## Limitations

- Exploratory Analysis: The findings describe observed patterns and associations. They do not establish cause-and-effect relationships or demonstrate that any factor independently predicts readmission.
- Cohort Selection: The analysis retains the first recorded encounter per patient. This affects the population being studied and limits how the findings can be generalised to all hospital encounters.
- Group Sizes: Some categories contain relatively few encounters, making their readmission rates less stable and less suitable for direct comparison with larger groups.
- Missing Data: Some variables contain substantial missing or unrecorded information, which may limit the analysis of certain clinical factors.
- Diagnostic Grouping: Primary diagnoses were grouped into broad categories, which may conceal differences between individual conditions. The diagnostic category totals also require reconciliation with the overall analysis cohort.
- Confounding Factors: The analysis does not establish whether the observed associations persist after accounting for other patient, clinical, or hospital-level factors.

