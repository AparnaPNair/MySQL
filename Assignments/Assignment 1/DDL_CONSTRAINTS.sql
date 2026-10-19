
-- DDL COMMANDS
CREATE DATABASE Employee;
USE employee;
CREATE TABLE Departments(
department_id int,
department_name varchar(100)
);
CREATE TABLE Location(
location_id int,
location varchar(30)
);
CREATE TABLE Employees(
employee_id int,
employee_name varchar(50),
gender ENUM('M','F'),
age int,
hire_date date,
designation varchar(100),
department_id int,
location_id int,
salary decimal(10,2)
);
 ALTER TABLE Employees ADD COLUMN email VARCHAR(50);
 ALTER TABLE Employees MODIFY designation varchar(500);
 ALTER TABLE Employees DROP COLUMN age;
 ALTER TABLE Employees RENAME COLUMN hire_date TO date_of_joining;
 RENAME TABLE Departments TO Departments_Info;
 RENAME TABLE Location TO Locations;
 DESCRIBE Employees;
 DESCRIBE Departments_Info;
 DESCRIBE Locations;
 TRUNCATE TABLE Employees;
 DROP TABLE Employees;
 DROP TABLE location;
 DROP TABLE departments;
 DROP DATABASE Employee;
 
 -- CONSTRAINTS
 CREATE DATABASE Employee;
 USE Employee;
CREATE TABLE Departments(
department_id int auto_increment PRIMARY KEY,
department_name varchar(100) UNIQUE NOT NULL
);
CREATE TABLE Location(
location_id int auto_increment PRIMARY KEY,
location varchar(30) UNIQUE NOT NULL
);
CREATE TABLE Employees(
employee_id int auto_increment PRIMARY KEY,
employee_name varchar(50) NOT NULL,
gender ENUM('M','F') CHECK (gender IN ('M','F')),
age int CHECK  (age >= 18),
hire_date date DEFAULT  (CURRENT_DATE),
designation varchar(100),
department_id int,
location_id int,
salary decimal(10,2),
foreign key (department_id) references Departments(department_id),
foreign key (location_id) references Location(location_id)

);
DESC Departments;
DESC Location;
DESC Employees;

-- insert
-- Departments Table
INSERT INTO Departments(department_name)VALUES("IT"),("SALES"),("FINANCE"),("MARKETING");
-- Location Table
INSERT INTO Location(location)VALUES("KERALA"),("BANGALORE"),("MUMBAI"),("CHENNAI");
-- Employees Table
INSERT INTO Employees(employee_name,gender,age,designation,department_id,location_id,salary)VALUES
("ASHLI","F",23,"DATA ANALYST",1,1,25000),
("MATHEW","M",30,"DATA ENGINEER",2,2,35000),
("SWETHA","F",29,"HR",3,3,25000);

SELECT * FROM Departments;
SELECT * FROM Location;
SELECT * FROM Employees;





