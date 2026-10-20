
CREATE DATABASE IF NOT EXISTS hospital_readmissions;
USE hospital_readmissions;

-- ===============================================
-- 1. INITIAL LOOK AT DATA
-- ===============================================
SELECT COUNT(*) AS num_of_rows
FROM diabetic_data_raw;

SELECT COUNT(DISTINCT(encounter_id)) AS unique_encounter,
		COUNT(DISTINCT(patient_nbr)) AS unique_patient
FROM diabetic_data_raw;

SELECT *
FROM diabetic_data_raw
LIMIT 50;

-- ------------------------------------------------------------
-- 1.1 CREATE A WORKING COPY
--    (keeps the original table untouched)
-- ------------------------------------------------------------
CREATE TABLE diabetic_data_clean
LIKE diabetic_data_raw;

INSERT INTO diabetic_data_clean
SELECT *
FROM diabetic_data_raw;

SELECT * 
FROM diabetic_data_clean;

-- ============================================================
-- 2. DATA QUALITY ASSESSMENT & CLEANING
-- ============================================================

-- ------------------------------------------------------------
-- 2.1 Checking for missing values
-- ------------------------------------------------------------
-- Variable  diag_1 noted to be in different format (double) from other diagnosis variables
ALTER TABLE diabetic_data_clean
MODIFY diag_1 VARCHAR(10);

-- '?' appears to be  used to signify Null values in this data set

UPDATE diabetic_data_clean
SET
    race = NULLIF(race, '?'),
    gender = NULLIF(gender, '?'),
    age = NULLIF(age, '?'),
    weight = NULLIF(weight, '?'),
    payer_code = NULLIF(payer_code, '?'),
    medical_specialty = NULLIF(medical_specialty, '?'),
    diag_1 = NULLIF(diag_1, '?'),
    diag_2 = NULLIF(diag_2, '?'),
    diag_3 = NULLIF(diag_3, '?'),
    max_glu_serum = NULLIF(max_glu_serum, '?'),
    A1Cresult = NULLIF(A1Cresult, '?'),
    metformin = NULLIF(metformin, '?'),
    repaglinide = NULLIF(repaglinide, '?'),
    nateglinide = NULLIF(nateglinide, '?'),
    chlorpropamide = NULLIF(chlorpropamide, '?'),
    glimepiride = NULLIF(glimepiride, '?'),
    acetohexamide = NULLIF(acetohexamide, '?'),
    glipizide = NULLIF(glipizide, '?'),
    glyburide = NULLIF(glyburide, '?'),
    tolbutamide = NULLIF(tolbutamide, '?'),
    pioglitazone = NULLIF(pioglitazone, '?'),
    rosiglitazone = NULLIF(rosiglitazone, '?'),
    acarbose = NULLIF(acarbose, '?'),
    miglitol = NULLIF(miglitol, '?'),
    troglitazone = NULLIF(troglitazone, '?'),
    tolazamide = NULLIF(tolazamide, '?'),
    examide = NULLIF(examide, '?'),
    citoglipton = NULLIF(citoglipton, '?'),
    insulin = NULLIF(insulin, '?'),
    `glyburide-metformin` = NULLIF(`glyburide-metformin`, '?'),
    `glipizide-metformin` = NULLIF(`glipizide-metformin`, '?'),
    `glimepiride-pioglitazone` = NULLIF(`glimepiride-pioglitazone`, '?'),
    `metformin-rosiglitazone` = NULLIF(`metformin-rosiglitazone`, '?'),
    `metformin-pioglitazone` = NULLIF(`metformin-pioglitazone`, '?'),
    `change` = NULLIF(`change`, '?'),
    diabetesMed = NULLIF(diabetesMed, '?'),
    readmitted = NULLIF(readmitted, '?');
    
   
-- examine the level of "missingness" of the various variables    
    SELECT
    ROUND(SUM(encounter_id IS NULL) / COUNT(*) * 100, 1) AS pct_missing_encounter_id,
    ROUND(SUM(patient_nbr IS NULL) / COUNT(*) * 100, 1) AS pct_missing_patient_nbr,
    ROUND(SUM(race IS NULL) / COUNT(*) * 100, 1) AS pct_missing_race,
    ROUND(SUM(gender IS NULL) / COUNT(*) * 100, 1) AS pct_missing_gender,
    ROUND(SUM(age IS NULL) / COUNT(*) * 100, 1) AS pct_missing_age,
    ROUND(SUM(weight IS NULL) / COUNT(*) * 100, 1) AS pct_missing_weight,
    ROUND(SUM(admission_type_id IS NULL) / COUNT(*) * 100, 1) AS pct_missing_admission_type_id,
    ROUND(SUM(discharge_disposition_id IS NULL) / COUNT(*) * 100, 1) AS pct_missing_discharge_disposition_id,
    ROUND(SUM(admission_source_id IS NULL) / COUNT(*) * 100, 1) AS pct_missing_admission_source_id,
    ROUND(SUM(time_in_hospital IS NULL) / COUNT(*) * 100, 1) AS pct_missing_time_in_hospital,
    ROUND(SUM(number_outpatient IS NULL) / COUNT(*) * 100, 1) AS pct_missing_number_outpatient,
    ROUND(SUM(number_emergency IS NULL) / COUNT(*) * 100, 1) AS pct_missing_number_emergency,
    ROUND(SUM(number_inpatient IS NULL) / COUNT(*) * 100, 1) AS pct_missing_number_inpatient,
    ROUND(SUM(medical_specialty IS NULL) / COUNT(*) * 100, 1) AS pct_missing_medical_specialty,
    ROUND(SUM(diag_1 IS NULL) / COUNT(*) * 100, 1) AS pct_missing_diag_1,
    ROUND(SUM(diag_2 IS NULL) / COUNT(*) * 100, 1) AS pct_missing_diag_2,
    ROUND(SUM(diag_3 IS NULL) / COUNT(*) * 100, 1) AS pct_missing_diag_3,
    ROUND(SUM(number_diagnoses IS NULL) / COUNT(*) * 100, 1) AS pct_missing_number_diagnoses,
    ROUND(SUM(max_glu_serum IS NULL) / COUNT(*) * 100, 1) AS pct_missing_max_glu_serum,
    ROUND(SUM(A1Cresult IS NULL) / COUNT(*) * 100, 1) AS pct_missing_A1Cresult,
    ROUND(SUM(readmitted IS NULL) / COUNT(*) * 100, 1) AS pct_missing_readmitted
FROM diabetic_data_clean;
    -- wieght has up to 96% missing values. Thus may not be statistical accurate if used in any analysis

-- ------------------------------------------------------------
-- 2.2 Creating a New Table selecting one encounter(first encounter) for each patient
-- ------------------------------------------------------------
-- First identify whether there are patients with multiple encounters
SELECT
	patient_nbr,
    COUNT(*) encounter_count
FROM diabetic_data_clean
GROUP BY patient_nbr
HAVING encounter_count >1
ORDER BY encounter_count DESC
LIMIT 20;

-- Now create a deduplicated table consisting of only patient's first encounters
CREATE TABLE diabetic_data_dedup AS
SELECT d.*
FROM diabetic_data_clean AS d
JOIN
(SELECT
	patient_nbr,
    MIN(encounter_id) AS first_encounter
FROM diabetic_data_clean 
GROUP BY patient_nbr) first_enctr
ON d.patient_nbr = first_enctr.patient_nbr
AND d.encounter_id =first_enctr.first_encounter;

SELECT
	(SELECT COUNT(DISTINCT patient_nbr) FROM diabetic_data_clean) AS unique_patient_nbr,
	(SELECT COUNT(*) FROM diabetic_data_dedup) AS dedup_patient_count;
    
   -- ------------------------------------------------------------
-- 2.3 Identifying Discharge Dispositions Related to Death or Hospice
-- ------------------------------------------------------------

SELECT * 
FROM discharge_disposition_map
WHERE description  LIKE '%hospice%' OR description LIKE '%expired%' OR description LIKE '%deceased%';
-- 11,13,14,19,20,21

SELECT COUNT(*) AS death_hospice_count
FROM diabetic_data_dedup
WHERE discharge_disposition_id IN (11,13,14,19,20,21);


DELETE FROM diabetic_data_dedup
WHERE discharge_disposition_id IN (11,13,14,19,20,21);

SELECT *
FROM diabetic_data_dedup
LIMIT 20;

 -- ------------------------------------------------------------
-- 2.4 Adding an Age_midpoint Column to make the age_groups more useful for analysis
-- ------------------------------------------------------------

ALTER TABLE diabetic_data_dedup ADD COLUMN age_midpoint INT AFTER age;

UPDATE diabetic_data_dedup
SET age_midpoint = CASE
    WHEN age = '[0-10)'   THEN 5
    WHEN age = '[10-20)'  THEN 15
    WHEN age = '[20-30)'  THEN 25
    WHEN age = '[30-40)'  THEN 35
    WHEN age = '[40-50)'  THEN 45
    WHEN age = '[50-60)'  THEN 55
    WHEN age = '[60-70)'  THEN 65
    WHEN age = '[70-80)'  THEN 75
    WHEN age = '[80-90)'  THEN 85
    WHEN age = '[90-100)' THEN 95
    END;

-- ============================================================
-- 3. Exploratory Data Analysis
-- ============================================================

 -- ------------------------------------------------------------
-- 3.1 distribution of the different categories under the readmitted column
-- ------------------------------------------------------------
SELECT 
	readmitted,
    COUNT(*) AS encounter_count,
 ROUND (COUNT(*)/(SELECT COUNT(*) FROM diabetic_data_dedup) *100,1) AS readmission_pct
FROM diabetic_data_dedup
GROUP BY readmitted
ORDER BY encounter_count DESC;

 -- ------------------------------------------------------------
-- 3.2 Exploring the relationship of demographic variables to readmission rate
-- ------------------------------------------------------------
-- relationship of age to readmission rate
SELECT
	age,
    age_midpoint,
    COUNT(*) AS total_encounters,
    SUM(readmitted = '<30') AS early_readmissions,
    ROUND(SUM(readmitted = '<30') / COUNT(*) * 100,1) AS early_readmission_rate
FROM diabetic_data_dedup
GROUP BY age, age_midpoint
ORDER BY age_midpoint ;

-- examining relationship of gender with readmission
SELECT gender,
		COUNT(*) AS total_encounters,
		SUM(readmitted = '<30') AS early_readmissions,
		ROUND(SUM(readmitted = '<30') / COUNT(*) * 100,1) AS early_readmission_rate
FROM diabetic_data_dedup
GROUP BY gender
ORDER BY early_readmission_rate DESC;
 
-- examining the relationship of race and readmission rate
SELECT 
	race,
    COUNT(*) AS total_encounters,
    SUM(readmitted = '<30') AS early_readmissions,
	ROUND(SUM(readmitted = '<30') / COUNT(*) * 100,1) AS early_readmission_rate
FROM diabetic_data_dedup
GROUP BY race
ORDER BY early_readmission_rate DESC;

 -- ------------------------------------------------------------
 -- 3.3 Exploring the relationship of healthcare-utilization variables
-- ------------------------------------------------------------
-- relationship of admission type to readmission rate
SELECT 
	a.`description` AS admission_type,
    COUNT(*) AS total_encounters,
    SUM(d.readmitted = '<30') AS early_readmissions,
    ROUND(SUM(d.readmitted = '<30') / COUNT(*) * 100,1) AS readmission_rate_percent
FROM diabetic_data_dedup d
JOIN admission_type_map a
ON
 d.admission_type_id = a.admission_type_id
 GROUP BY `description`
 ORDER BY readmission_rate_percent DESC;
 
 -- Relationship of discharge disposition and readmissoin rate
  SELECT 
			ddm.`description` AS discharge_disposition,
            COUNT(*) AS total_encounters,
                SUM(ddd.readmitted = '<30') AS early_readmissions,
            ROUND(SUM(ddd.readmitted = '<30')/COUNT(*) *100,1) AS readmission_rate_pct
		FROM diabetic_data_dedup ddd
        JOIN discharge_disposition_map ddm
        ON ddd.discharge_disposition_id = ddm.discharge_disposition_id
		GROUP BY `description`
        ORDER BY readmission_rate_pct DESC;
        
 -- relationship of number of inpatient visits to early readmission rate
 SELECT
    number_inpatient,
    COUNT(*) AS total_encounters,
    SUM(readmitted = '<30') AS early_readmissions,
    ROUND(SUM(readmitted = '<30') / COUNT(*) * 100,1) AS early_readmission_rate
FROM diabetic_data_dedup
GROUP BY number_inpatient
ORDER BY number_inpatient ;

-- Grouping number of inpatient visits and comparing the readmission rates
 SELECT
    CASE
        WHEN number_inpatient = 0 THEN '0 visits'
        WHEN number_inpatient BETWEEN 1 AND 3 THEN '1-3 visits'
        ELSE '>3 visits'
    END AS inpatient_visit_group,
    COUNT(*) AS total_encounters,
    SUM(readmitted = '<30') AS early_readmissions,
    ROUND(SUM(readmitted = '<30') / COUNT(*) * 100,1) AS early_readmission_rate
FROM diabetic_data_dedup
GROUP BY inpatient_visit_group
ORDER BY inpatient_visit_group ;


 -- ------------------------------------------------------------
 -- 3.4 Exploring the relationship of clinical characteristic variables
-- ------------------------------------------------------------
-- Relationship of Diagnostic category with readmission rates
  WITH diag_recategorized AS (
    SELECT 
        encounter_id,
        readmitted,
        CASE 
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN CAST(LEFT(diag_1,3) AS UNSIGNED) BETWEEN 390 AND 459 THEN 'Circulatory'
            WHEN CAST(LEFT(diag_1,3) AS UNSIGNED) BETWEEN 460 AND 519 THEN 'Respiratory'
            WHEN CAST(LEFT(diag_1,3) AS UNSIGNED) BETWEEN 520 AND 579 THEN 'Digestive'
            WHEN CAST(LEFT(diag_1,3) AS UNSIGNED) BETWEEN 580 AND 629 THEN 'Genitourinary'
            WHEN CAST(LEFT(diag_1,3) AS UNSIGNED) BETWEEN 800 AND 999 THEN 'Injury and Poisoning'
            ELSE 'Other'
        END AS diagnostic_categories,
        CASE WHEN
        readmitted ='<30' THEN 1 ELSE 0
				END AS early_readmissions
    FROM diabetic_data_dedup
    WHERE diag_1 IS NOT NULL
)
SELECT 
	diagnostic_categories,
    COUNT(*) AS total_encounters,
        SUM(early_readmissions) AS early_readmission_count,
    ROUND(AVG(early_readmissions)*100,1) AS readmission_rate_pct
FROM diag_recategorized
GROUP BY diagnostic_categories
ORDER BY readmission_rate_pct DESC;

-- Relationship of number of diagnosis with readmission rate
  SELECT
  CASE 
         WHEN number_diagnoses <=5 THEN 'Low'
         WHEN number_diagnoses BETWEEN 6 AND 9 THEN 'Moderate'
         WHEN number_diagnoses >=10 THEN 'High'
         END AS diagnosis_count_categories,
         COUNT(*) AS Frequency,
         SUM(readmitted = '<30') AS early_readmissions,
		ROUND(SUM(readmitted = '<30') / COUNT(*) * 100,1) AS early_readmission_rate
FROM diabetic_data_dedup
GROUP BY diagnosis_count_categories
ORDER BY early_readmission_rate DESC;

-- relationship of a change in medication with  readmission rate
SELECT
	 `change`,
	 COUNT(*) AS total_encounter,
	ROUND(SUM(readmitted = '<30')/COUNT(*) *100,1) AS readmission_rate_pct
FROM diabetic_data_dedup
GROUP BY `change`
ORDER BY readmission_rate_pct;

SELECT 
		A1Cresult,
        COUNT(*) AS total_encounters,
        SUM(readmitted = '<30') AS early_readmissions,
    ROUND(SUM(readmitted = '<30') / COUNT(*) * 100,1) AS early_readmission_rate
FROM diabetic_data_dedup
GROUP BY A1Cresult
ORDER BY  A1Cresult;


-- ============================================================
-- 4. Some Bonus(more advanced queries)
-- ============================================================
-- ------------------------------------------------------------
-- 4.1 medication load vs readmission rates
-- ------------------------------------------------------------

   
        WITH patient_risk_base AS (
    SELECT encounter_id, age_midpoint, num_medications, early_readmission
    FROM (
        SELECT *, CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END AS early_readmission
        FROM diabetic_data_dedup
    ) t
),
ranked AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY age_midpoint ORDER BY num_medications DESC) AS med_rank_in_age_group
    FROM patient_risk_base
),
top_decile_flagged AS (
    SELECT *,
        CASE WHEN med_rank_in_age_group <= 10 THEN 'Top 10 heaviest' ELSE 'Rest of age group' END AS med_load_group
    FROM ranked
)
SELECT
    med_load_group,
    COUNT(*) AS total_encounters,
    SUM(early_readmission) AS early_readmissions,
    ROUND(AVG(early_readmission) * 100, 1) AS readmission_rate_pct
FROM top_decile_flagged
GROUP BY med_load_group
ORDER BY readmission_rate_pct DESC;

-- ------------------------------------------------------------
-- 4.2 Inpatient utilization quartiles vs. readmission rate
-- ------------------------------------------------------------
WITH base AS (
    SELECT 
        encounter_id, 
        number_inpatient, 
        CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END AS early_readmission
    FROM diabetic_data_dedup
),
quartiled AS (
    SELECT 
        encounter_id,
        number_inpatient,
        early_readmission,
        NTILE(4) OVER (ORDER BY number_inpatient DESC) AS utilization_quartile
    FROM base
)
SELECT
    utilization_quartile,
    COUNT(*) AS total_encounters,
    MIN(number_inpatient) AS min_prior_inpatient_visits,
    MAX(number_inpatient) AS max_prior_inpatient_visits,
    SUM(early_readmission) AS early_readmissions,
    ROUND(AVG(early_readmission) * 100, 1) AS readmission_rate_pct
FROM quartiled
GROUP BY utilization_quartile
ORDER BY utilization_quartile;
                
