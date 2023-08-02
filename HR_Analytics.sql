use hr_analytics;

select * from hr_analytics.hr;

-- data cleaning --

#renaming column id 
ALTER TABLE hr
change column  ï»¿id  Emp_id varchar(20) null;

set sql_safe_updates=0;

#converting date format 
UPDATE hr
SET birthdate = date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d');

UPDATE hr
SET hire_date = date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d');

UPDATE hr 
SET termdate= date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate!='';


#changing data type of columns
ALTER TABLE hr
MODIFY COLUMN birthdate Date;

ALTER TABLE hr
MODIFY COLUMN hire_date Date;

UPDATE  hr
SET termdate=NULL
WHERE termdate='';


#creating age column
ALTER TABLE hr
ADD COLUMN age INT;

UPDATE hr
set age= timestampdiff(YEAR,birthdate,curdate());


-- ANALYSIS --

## Distribution of employees by gender in the company
SELECT gender, count(*)
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

##Distribution of race in the company
SELECT race,count(*)
FROM hr
WHERE termdate IS NULL
GROUP BY race;

##Distribution of age in the company
SELECT CASE
         WHEN age>=18 AND age<=24 THEN '18-24'
         WHEN age>=25 AND age<=34 THEN '25-34'
         WHEN age>=35 AND age<=44 THEN '35-44'
         WHEN age>=45 AND age<=54 THEN '45-54'
         WHEN age>=55 AND age<=64 THEN '55-64'
         ELSE '65+'
       END AS age_Category,
       count(*) AS Count
       FROM hr
       WHERE termdate IS NULL
       GROUP BY age_category
       ORDER BY age_category;


##Diversity percentage by race
SELECT race, COUNT(*) as count, (COUNT(*) / (SELECT COUNT(*) FROM hr)) * 100 as percentage
FROM hr
WHERE termdate IS NULL
GROUP BY race;

##Diversity percentage by gender
SELECT gender, COUNT(*) as count, (COUNT(*) / (SELECT COUNT(*) FROM hr)) * 100 as percentage
FROM hr
WHERE termdate IS NULL
GROUP BY gender;

##Average tenure of employees 
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date) / 365),0) as average_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate<=curdate();

##Employee turnover rate: Percentage of employees leaving the company.
SELECT (count(termdate) / (SELECT count(*)FROM hr))*100 as turnover_rate
FROM hr
WHERE termdate IS NOT NULL;

##How many employees work at Headquarter vs Remote
SELECT location,count(*) as count
FROM hr
WHERE termdate IS NULL
Group by location;

##Gender Distribution vary across department and job titles
SELECT department,jobtitle,gender,count(*) as count
FROM hr
WHERE termdate is NULL
GROUP BY department,jobtitle,gender
ORDER BY department,jobtitle,gender;


####Gender Distribution vary across department
SELECT department,gender,count(*) as count
FROM hr
WHERE termdate is NULL
GROUP BY department,gender
ORDER BY department,gender;


##Distribution of jobtitle across the company
SELECT jobtitle,count(*) as count
FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle;

##Which Department has the highest turnover rate
SELECT department,
       count(*) AS total_count,
       count(CASE
		    WHEN termdate IS NOT NULL AND termdate <=curdate() THEN 1
           END) AS terminated_count,
       ROUND((COUNT(CASE
              WHEN termdate IS NOT NULL AND termdate <=curdate() THEN 1
           END)/COUNT(*))*100,2) AS termination_rate
   FROM hr
   GROUP BY department 
   ORDER BY termination_rate DESC;


##What is the distribution of employee across states
SELECT location_state,COUNT(*) as count
FROM hr
WHERE termdate IS NULL
group by location_state;

##What is the distribution of employee across cities
SELECT location_city,COUNT(*) as count
FROM hr
WHERE termdate IS NULL
group by location_city;

##How has the company employee count changed over time base on hire and termination date
SELECT year,hires,terminations,hires-terminations as net_change,
(terminations/hires)*100 as net_percentage
FROM(SELECT year(hire_date) as year,
      count(*) as hires,
      SUM(CASE
            WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1
            END) as terminations
FROM hr
GROUP BY YEAR(hire_date)) as t
GROUP BY year
ORDER BY YEAR;

##Average tenure of employess based on dept
SELECT department,ROUND(AVG(DATEDIFF(termdate, hire_date) / 365),0) as average_tenure
FROM hr
WHERE termdate IS NOT NULL AND termdate<=curdate()
GROUP BY department;

##Termination and Hire breakdown genderwise
SELECT gender,total_hires,total_terminations,
Round((total_terminations/total_hires)*100,2) as termination_rate
FROM(
     SELECT gender, count(*) AS total_hires,
     COUNT(CASE
             WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1
             END) AS total_terminations
             FROM hr
             GROUP BY gender) AS t
GROUP BY gender ;            

##Termination and hire breakdown age wise
SELECT age,total_hires,total_terminations,
Round((total_terminations/total_hires)*100,2) as termination_rate
FROM(
     SELECT age, count(*) AS total_hires,
     COUNT(CASE
             WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1
             END) AS total_terminations
             FROM hr
             GROUP BY age) AS t
GROUP BY age ; 

##Termination and hire breakdown department wise  
 SELECT department,total_hires,total_terminations,
Round((total_terminations/total_hires)*100,2) as termination_rate
FROM(
     SELECT department, count(*) AS total_hires,
     COUNT(CASE
             WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1
             END) AS total_terminations
             FROM hr
             GROUP BY department) AS t
GROUP BY department ;         

##Race Termination Rate
SELECT race,total_hires,total_terminations,
Round((total_terminations/total_hires)*100,2) as termination_rate
FROM(
     SELECT race, count(*) AS total_hires,
     COUNT(CASE
             WHEN termdate IS NOT NULL AND termdate<=curdate() THEN 1
             END) AS total_terminations
             FROM hr
             GROUP BY race) AS t
GROUP BY race ;      




