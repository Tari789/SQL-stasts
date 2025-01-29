--- Creating the salary table 

CREATE TABLE employee_sal (
    department VARCHAR (50),
    department_division VARCHAR(100),
    pcn VARCHAR (15) PRIMARY KEY,
    position_title VARCHAR (70),
    flsa_status VARCHAR(15),
    initial_hire_date DATE,
    date_in_title DATE, 
    salary NUMERIC
     )
     
     
ALTER TABLE employee_sal
ALTER COLUMN salary SET DATA TYPE DECIMAL
     
/* Inserting values using the built in feature. */

SELECT * FROM employee_sal
LIMIT 20 

--group by department and get standard deviation and average. 

WITH department_stats AS 
 (SELECT department,
       round(stddev(salary),3)  AS standard_dev,
       round(avg(salary),4) AS avg 
FROM employee_sal
WHERE salary >= 10000
GROUP BY department
) ,
department_outliers AS (
    SELECT 
        emp.department,
        emp.salary,
        dt.standard_dev,
        dt.avg,
        (emp.salary- dt.avg) / dt.standard_dev AS zscore
    FROM employee_sal AS emp 
    JOIN department_stats AS dt ON emp.department = dt.department 
    WHERE emp.salary >= 10000
 )
SELECT 
    dt.department, 
    dt.standard_dev AS standard_deviation,
    dt.avg AS avg_salary,
    round((dt.standard_dev/ dt.avg)*100,0) AS coefficent_of_variation,
    SUM(CASE 
           WHEN (d.zscore >1.96 OR d.zscore <-1.96) THEN 1 
           ELSE 0 
           END) AS outlier_count 
 FROM department_stats AS dt 
 LEFT JOIN 
    department_outliers AS d ON dt.department = d.department 
 GROUP BY 1,2,3,4 
 ORDER BY outlier_count DESC 
  
--- FRom this query we can see that PWD has teh higest outlier count . 
 
 