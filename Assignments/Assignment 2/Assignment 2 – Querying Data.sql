use employee; 

select * FROM employees;
select * FROM location;
select * FROM departments;

-- a query to retrieve distinct salaries from the Employees table.
SELECT DISTINCT salary 
FROM employees;

-- Provide aliases for the "age" and "salary" columns as "Employee_Age" and "Employee_Salary", respectively.
SELECT age AS Employee_Age,salary AS Employee_Salary 
FROM employees;

-- Retrieve employees with a salary greater than ₹50000 and hired before 2016-01-01.
SELECT * FROM employees 
WHERE salary>50000 AND hire_date<'2016-01-01';

-- Find the employee whose designation is missing and fill it with "Data Scientist".
SELECT employee_id,employee_name,'Data Scientist' AS designation 
FROM employees 
WHERE designation IS NULL;

 -- Find employees sorted by department ID in ascending order and salary in descending order.
SELECT * FROM employees 
order by department_id ASC , salary DESC;

-- Display the first 5 employees hired in the year 2018.
SELECT * FROM employees
WHERE YEAR(hire_date)=2018 LIMIT 5 ;

-- Calculate the sum of all salaries in the Finance department.
-- SELECT SUM(salary) AS Total_Salary FROM employees WHERE department_id=7;
-- SELECT SUM(salary) AS Total_Salary FROM employees WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Finance');
SELECT SUM(salary) AS Total_Salary 
FROM employees 
inner join departments on 
employees.department_id=departments.department_id
where departments.department_name = 'Finance';

-- Find the minimum age among all employees.
SELECT MIN(age)AS Minimum_Age 
FROM employees;

-- List the maximum salary for each location.
SELECT location_id,MAX(salary)AS Max_Salary 
FROM employees 
GROUP BY location_id;

-- Calculate the average salary for each designation containing the word 'Analyst'.
SELECT designation,AVG(salary)AS AVG_Salary 
FROM employees 
WHERE designation LIKE '%Analyst%'  GROUP BY designation;

-- Find departments with less than 3 employees.
SELECT COUNT(*) AS Employee_Count,department_id 
from employees 
group by  department_id 
having Employee_Count < 3;

-- Find locations with female employees whose average age is below 30.
SELECT  AVG(age) AS Average_Age,location_id  
from employees 
where gender='F' 
GROUP BY location_id  
having Average_Age <30;

-- List employee names, their designations, and department names where employees are assigned to a department.
SELECT emp.employee_name,emp.designation,dep.department_name 
FROM employees emp
INNER JOIN departments dep ON
emp.department_id=dep.department_id;

-- List all departments along with the total number of employees in each department, including departments with no employees.
SELECT dep.department_id,dep.department_name,COUNT(employee_id) AS Total_Employees 
FROM employees emp
LEFT JOIN departments dep ON
emp.department_id=dep.department_id
GROUP BY dep.department_id; 

-- Display all locations along with the names of employees assigned to each location. If no employees are assigned to a location, display NULL for employee name.
SELECT  loc.location_id,loc.location,emp.employee_name  
FROM employees emp
RIGHT JOIN location loc ON
emp.location_id=loc.location_id;

