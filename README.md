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
- Microsoft Excel 2021

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
- Previous Hospital Utilisation: Early readmission rates increased with the number of previous inpatient visits. The rate was 8.1% among encounters with no previous inpatient visits, rising to 18.9% among those with two previous visits and 23.1% among those with three. When grouped, the rate was 8.1% for encounters with no previous visits, 14.8% for those with 1–3 previous visits, and 28.3% for those with more than three previous visits. The last group contained only 424 encounters, so its rate should be interpreted with some caution.
- Age: Early readmission rates were generally higher among older patients, reaching 10.8% among those aged 80–89, compared with 7.1% among those aged 50–59.
- Discharge Destination: Early readmission rates varied by discharge destination. The highest rate was observed among encounters discharged or transferred to another rehabilitation facility (27.7%; 393 of 1,418 encounters), followed by transfers to other inpatient care institutions (20.7%; 188 of 910) and skilled nursing facilities (13.5%; 1,180 of 8,744). Encounters discharged home had a lower rate of 6.9% (3,039 of 43,986). Only destinations with at least 100 encounters were included in this comparison. These findings are descriptive and may reflect differences in patients' clinical needs and severity of illness.
- Primary Diagnosis: Early readmission rates varied across primary diagnosis categories. Injury and Poisoning had the highest rate at 11.0% (518 of 4,713 encounters), followed by circulatory diseases at 9.7% (2,079 of 21,365) and diabetes at 9.2% (527 of 5,756). Respiratory and digestive diseases had lower rates of 8.3% and 8.0%, respectively.

## Recommendations

- - Consider previous inpatient utilisation when identifying patients who may benefit from closer follow-up after discharge, particularly those with multiple prior inpatient visits.
- Investigate whether differences in patient needs, illness severity, discharge planning, and post-discharge support contribute to the higher readmission rates observed among patients transferred to rehabilitation and other inpatient care facilities.
- Further examine early readmission patterns among patients with Injury and Poisoning diagnoses, followed by circulatory diseases and diabetes, to identify potential areas for more detailed clinical analysis.

These are potential areas for further investigation, not interventions proven effective by this analysis.

## Limitations

- Exploratory Analysis: The findings describe observed patterns and associations. They do not establish cause-and-effect relationships or demonstrate that any factor independently predicts readmission.
- Cohort Selection: The analysis retains the first recorded encounter per patient. This affects the population being studied and limits how the findings can be generalised to all hospital encounters.
- Group Sizes: Some categories contain relatively few encounters, making their readmission rates less stable and less suitable for direct comparison with larger groups.
- Missing Data: Some variables contain substantial missing or unrecorded information, which may limit the analysis of certain clinical factors.
- Diagnostic Grouping: Primary diagnoses were grouped into broad categories, which may conceal differences between individual conditions. 
- Confounding Factors: The analysis does not establish whether the observed associations persist after accounting for other patient, clinical, or hospital-level factors.

