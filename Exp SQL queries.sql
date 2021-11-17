#first, query results
SELECT
  experiment_cohort AS cohort,
  COUNT(*) AS n_cust,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (),4) AS prop_cust,
  AVG(minutes_listening_during_experiment) AS avg_min
FROM assessment_01.experiment
GROUP BY cohort

#assign age groups, calculate number of users, proportion of sample, and average minutes listened by age group,
SELECT
  experiment_cohort as cohort,
  (CASE
      WHEN age < 18 THEN '<18'
      WHEN age >= 18 AND age <25 THEN '18-24'
      WHEN age >= 25 AND age <35 THEN '25-34'
      WHEN age >= 35 AND age <45 THEN '35-44'
      WHEN age >= 45 AND age <55 THEN '45-54'
      WHEN age >= 55 AND age <65 THEN '55-64'
      WHEN age >= 65 THEN '65+'
   END) as age_group,
   COUNT(*) as n_cust_by_age,
   SUM(COUNT(*)) OVER () AS Total_n_customers,
   ROUND(COUNT(*) / SUM(COUNT(*)) OVER (),4) as Percentage_of_customers,
   AVG(minutes_listening_during_experiment) as avg_min_by_age
FROM assessment_01.experiment
GROUP BY cohort, age_group
ORDER BY age_group, cohort

#group day of experiment by week,calculate number of users, proportion of sample, and average minutes listened by week,
SELECT
  experiment_cohort as cohort,
  (CASE
      WHEN day_of_experiment < 8 THEN 'Week 1'
      WHEN day_of_experiment > 7 AND day_of_experiment <15 THEN 'Week 2'
      WHEN day_of_experiment > 14 AND day_of_experiment <22 THEN 'Week 3'
      WHEN day_of_experiment >21 THEN 'Week 4'
   END) as week,
   COUNT(*) as n_cust_by_week,
   SUM(COUNT(*)) OVER () AS Total_n_customers,
   ROUND(COUNT(*) / SUM(COUNT(*)) OVER (),4) as Percentage_of_customers,
   AVG(minutes_listening_during_experiment) as avg_min_by_week
FROM assessment_01.experiment
GROUP BY cohort, week
ORDER BY week, cohort

#calculate number of users, proportion of sample, and average minutes listened by device type,
SELECT
  experiment_cohort AS cohort,
  device_type,
  COUNT(*) AS n_cust_by_device,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (),4) AS prop_cust_by_device,
  AVG(minutes_listening_during_experiment) AS avg_min_by_device
FROM
  assessment_01.experiment
GROUP BY
  device_type,
  cohort
ORDER BY
  device_type,
  cohort

#calculate number of users, proportion of sample, and average minutes listened by gender,
SELECT
  experiment_cohort as cohort,
  gender,
  COUNT(*) as n_cust_by_gender,
  ROUND(COUNT(*) / SUM(COUNT(*)) OVER (),4) as proportion_cust_bygender,
  AVG(minutes_listening_during_experiment) as avg_min_bygender
FROM assessment_01.experiment
WHERE age IS NOT NULL
GROUP BY cohort, gender
ORDER BY gender, cohort

#used in combination with query above to remove data points where gender = 'X'
SELECT * 
FROM assessment_01.avg_min_bygender
WHERE gender != 'X'
ORDER BY gender, cohort

