-- display postgresql version
SELECT version();

-- create database
CREATE DATABASE test_db WITH OWNER postgres;

-- list of existing databases
SELECT datname FROM pg_database;

-- change owner of database 
ALTER DATABASE test_db OWNER TO demouser;

-- drop the database
DROP DATABASE test_db;

-- create new user
CREATE USER sampleuser WITH PASSWORD 'sample';

-- create new user with superuser privileges
CREATE USER sampleusertwo WITH PASSWORD 'sample' SUPERUSER;

-- rename user
ALTER USER sampleuser RENAME TO sampleuserone;

-- provide user with superuser privileges
ALTER USER sampleuserone SUPERUSER;

-- revoke user with superuser privileges
ALTER USER sampleuserone NOSUPERUSER;

-- drop user
DROP USER sampleusertwo;

-- display list of users
SELECT * FROM pg_user;

-- switch user
SET ROLE sampleuserone;

-- create table
CREATE TABLE person (
    id INT,
    name VARCHAR(100),
    city VARCHAR(100)
  );

-- check constraint
CREATE TABLE demoone (
      mob VARCHAR(10) NOT NULL,
      CONSTRAINT mob_less_than_10digits CHECK (LENGTH(mob) >= 10)
    );

-- add column
ALTER TABLE person ADD COLUMN age INT DEFAULT 0;

-- drop column
ALTER TABLE person DROP COLUMN age;

-- rename column
ALTER TABLE person RENAME COLUMN name TO fname;

-- rename table
ALTER TABLE persons RENAME TO person;

-- modify datatype
ALTER TABLE person ALTER COLUMN fname SET DATA TYPE VARCHAR(150);

-- modify constraint to not null
ALTER TABLE person ALTER COLUMN fname SET NOT NULL; 

-- remove constraint of column
ALTER TABLE person ALTER COLUMN fname DROP NOT NULL;

-- add constraint of column to table
ALTER TABLE person ADD CONSTRAINT person_mob_condition CHECK (LENGTH(mob) > 3);

-- remove constraint of column in table
ALTER TABLE person DROP CONSTRAINT person_mob_condition;

-- remove all records of table and retain only table structure
TRUNCATE demoone;

-- drop entire table including table structure
DROP TABLE demoone; 

-- record insertion
INSERT INTO person(id, name, city) VALUES (101, 'sam', 'cityone');

-- update record in table 
UPDATE person SET city = 'updatecity' WHERE name = 'sam';

-- delete record in table
DELETE FROM person WHERE id = 101;

-- display all records in table 
SELECT * FROM person;

-- display specific column records in table
SELECT name, city FROM person;

-- fetch records of table based on condition
SELECT * FROM employees WHERE emp_id = 12; 

-- fetch records which matches either of conditions
SELECT * from employees WHERE dept = 'HR' OR dept = 'Finance';

-- fetch records which both conditions match
SELECT * from employees WHERE dept = 'IT' AND salary > 40000;

-- fetch records which salary greater than 40000
SELECT * from employees WHERE salary > 40000;

-- fetch records which dept matches either HR or Finance
SELECT * FROM employees WHERE dept IN ('HR','Finance');

-- fetch records which dept donot match HR and Finance
SELECT * FROM employees WHERE dept NOT IN ('HR','Finance');

-- fetch records which salary >= 50000 and <= 60000
SELECT * FROM employees WHERE salary BETWEEN 50000 AND 60000;

-- fetch records with unique column values
SELECT DISTINCT dept FROM employees;

-- displays records with specified column value ascending
SELECT * FROM employees ORDER BY fname;

-- displays records with specified column value descending
SELECT * FROM employees ORDER BY fname DESC;

-- displays only no of records specified by limit
SELECT * FROM employees LIMIT 5;

-- fetch records fname start with a
SELECT * FROM employees WHERE fname LIKE 'a%'; 

-- fetch records fname ends with a
SELECT * FROM employees WHERE fname LIKE '%a'; 

 -- fetch records fname contains a
SELECT * FROM employees WHERE fname LIKE '%a%'; 

-- fetch records fname second character a
SELECT * FROM employees WHERE fname LIKE '_a%';  

 -- fetch records fname start with a case insensitive
SELECT * FROM employees WHERE fname ILIKE 'a%'; 

-- displays the total records count of table
SELECT COUNT(emp_id) FROM employees;

-- displays the sum of all values in specified column
SELECT SUM(salary) FROM employees;

-- displays the average value of all values in specified column
SELECT AVG(salary) FROM employees;

-- displays the minimum value of all values in specified column
SELECT MIN(salary) FROM employees;

-- displays the maximum value of all values in specified column
SELECT MAX(salary) FROM employees;

-- case expression
SELECT fname, salary,
  CASE 
	  WHEN salary > 55000 THEN 'HIGH'
	  WHEN salary BETWEEN 48000 AND 55000 THEN 'MID'
	  ELSE 'LOW'
  END AS sal_cat FROM employees;

-- grant select privileges
GRANT SELECT ON TABLE people TO demoone;

-- revoke select privileges
REVOKE SELECT ON TABLE people FROM demoone;

-- grant insert privileges
GRANT INSERT ON TABLE people TO demoone;

-- revoke insert privileges
REVOKE INSERT ON TABLE people FROM demoone;

-- grant update privileges
GRANT UPDATE ON TABLE people TO demoone;

-- revoke update privileges
REVOKE UPDATE ON TABLE people FROM demoone;

-- grant delete privileges
GRANT DELETE ON TABLE people TO demoone;

-- revoke delete privileges
REVOKE DELETE ON TABLE people FROM demoone;

-- grant truncate privileges
GRANT TRUNCATE ON TABLE people_copy TO demoone;

-- revoke truncate privileges
REVOKE TRUNCATE ON TABLE person_copy FROM demoone;

-- grant references privileges
GRANT REFERENCES ON TABLE person_copy TO demoone;

-- revoke references privileges
REVOKE REFERENCES ON TABLE person_copy FROM demoone;

-- grant create privileges
GRANT CREATE ON SCHEMA public TO demotwo;

-- revoke create privileges
REVOKE CREATE ON SCHEMA public FROM demotwo;

-- cross join
SELECT * FROM customers CROSS JOIN orders;

-- inner join
SELECT * FROM customers INNER JOIN orders ON customers.cust_id = orders.cust_id;

-- left join
SELECT * FROM customers LEFT JOIN orders ON customers.cust_id = orders.cust_id;

-- right join
SELECT * FROM customers RIGHT JOIN orders ON customers.cust_id = orders.cust_id;

-- subquery
SELECT * FROM employees WHERE hire_date = (SELECT MAX(hire_date) FROM employees); 

-- subquery in where clause
 SELECT first_name, salary FROM employees WHERE salary < (SELECT MAX(salary) FROM employees);

-- subquery in from & join clause
SELECT e1.first_name, e1.last_name, e1.department FROM employees AS e1 INNER JOIN ( SELECT department FROM employees WHERE first_name = 'John' AND last_name = 'Doe') AS e2 ON e1.department = e2.department;

-- subquery in select clause
SELECT e.department, COUNT(*) AS total_employees,(SELECT AVG(salary) FROM employees e2 WHERE e2.department = e.department) AS average_salary FROM employees e GROUP BY e.department;

-- stored procedure 
CREATE OR REPLACE PROCEDURE update_emp_salary(p_employee_id INT, p_new_salary NUMERIC) 
  LANGUAGE plpgsql 
  AS $$
  BEGIN 
  UPDATE employees 
  SET salary = p_new_salary
  WHERE emp_id = p_employee_id;
  END;
$$;

CALL update_emp_salary(3,71000);

-- function
CREATE OR REPLACE FUNCTION dept_max_sal_emp(dept_name VARCHAR)
  RETURNS TABLE(emp_id INT, fname VARCHAR,  salary NUMERIC )
  LANGUAGE plpgsql
  AS $$
  	BEGIN
		SELECT 
		e.emp_id, e.fname, e.salary
		FROM
		employees e
		WHERE 
		e.dept = dept_name
		AND 
		e.salary = (SELECT MAX(emp.salary) FROM employees emp WHERE emp.dept = dept_name);
		RETURN QUERY 
  	END;
  $$;

SELECT * FROM dept_max_sal_emp('Marketing');

-- view
CREATE VIEW billing_info AS
  SELECT
	  c.cust_name,
	  o.ord_date,
	  p.p_name,
	  p.price,
	  i.quantity,
	  (i.quantity * p.price) as total

  FROM items i
	  JOIN
	  	products p ON p.p_id = i.p_id
	  JOIN
	  	orders o ON o.ord_id = i.ord_id
	  JOIN
		  customers c ON c.cust_id = o.cust_id ;

SELECT * FROM billing_info;

-- cursor
BEGIN ;
 DECLARE list_emps CURSOR FOR SELECT * FROM employees;
 FETCH NEXT FROM list_emps;
 CLOSE list_emps;

-- trigger
CREATE OR REPLACE FUNCTION check_salary() 
  RETURNS TRIGGER AS $$
  BEGIN 
   	IF NEW.salary < 0 THEN 
  		NEW.salary = 0;
   	END IF;
  	RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_update_salary
AFTER UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION check_salary();

-- index
CREATE INDEX employees_name on employees(fname);