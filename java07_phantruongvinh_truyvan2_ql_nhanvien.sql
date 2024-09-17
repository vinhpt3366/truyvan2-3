CREATE DATABASE ql_nhanvien;
USE ql_nhanvien;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    department_id INT,
    manager_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    department_id INT
);

CREATE TABLE employee_projects (
    employee_id INT,
    project_id INT,
    PRIMARY KEY (employee_id, project_id)
);



INSERT INTO employees (employee_id, name, department_id, manager_id, salary) VALUES
(1, 'Alice', 1, NULL, 60000),
(2, 'Bob', 1, 1, 55000),
(3, 'Charlie', 2, 1, 70000),
(4, 'David', 2, 3, 65000),
(5, 'Eve', 3, 1, 62000),
(6, 'Frank', 3, 5, 58000),
(7, 'Grace', 4, 1, 72000),
(8, 'Heidi', 4, 7, 71000),
(9, 'Ivan', 5, 1, 75000),
(10, 'Judy', 5, 9, 68000);


INSERT INTO departments (department_id, department_name) VALUES
(1, 'HR'),
(2, 'Engineering'),
(3, 'Marketing'),
(4, 'Sales'),
(5, 'Finance');


INSERT INTO projects (project_id, project_name, department_id) VALUES
(1, 'Project A', 1),
(2, 'Project B', 2),
(3, 'Project C', 2),
(4, 'Project D', 3),
(5, 'Project E', 4),
(6, 'Project F', 5),
(7, 'Project G', 1),
(8, 'Project H', 3),
(9, 'Project I', 4),
(10, 'Project J', 5);


INSERT INTO employee_projects (employee_id, project_id) VALUES
(1, 1),
(1, 7),
(2, 1),
(3, 2),
(3, 3),
(4, 2),
(4, 3),
(5, 4),
(5, 8),
(6, 4),
(6, 8),
(7, 5),
(7, 9),
(8, 5),
(8, 9),
(9, 6),
(9, 10),
(10, 6),
(10, 10);



-- 1)
SELECT e.name, d.department_name
FROM employees e 
LEFT JOIN departments d ON e.department_id = d.department_id;

-- 2)
SELECT e.name, p.project_name
FROM employees e 
JOIN employee_projects ep ON e.employee_id = ep.employee_id
JOIN projects p ON p.project_id = ep.project_id;

-- 3)
SELECT d.department_name, p.project_name, e.name 
FROM departments d
JOIN projects p ON d.department_id = p.department_id
JOIN employee_projects ep ON ep.project_id = p.project_id 
JOIN employees e ON e.employee_id = ep.employee_id;

-- 4)
SELECT p.project_name, SUM(e.salary) as total_salary
FROM projects p
JOIN employee_projects ep ON ep.project_id = p.project_id 
JOIN employees e ON e.employee_id = ep.employee_id
GROUP BY ep.project_id;


-- 5)
SELECT e.employee_id, e.name, e2.name as manager, p.project_name 
FROM employees e 
LEFT JOIN employees e2 ON e2.employee_id = e.manager_id
JOIN employee_projects ep ON e.employee_id = ep.employee_id 
JOIN projects p ON p.project_id = ep.project_id;

-- 6)
SELECT d.department_name, COUNT(e.name)
FROM departments d
JOIN employees e ON e.department_id = d.department_id
JOIN employee_projects ep ON e.employee_id = ep.employee_id
GROUP BY e.department_id;

-- 7)
SELECT pt.project_name, e.name, e.salary as max_salary_of_project
FROM employees e
JOIN
(
	SELECT p.project_id, p.project_name, MAX(e.salary) as max_salary
	FROM projects p
	JOIN employees e ON e.department_id = p.department_id
	GROUP BY p.project_id
) pt
ON e.salary = pt.max_salary
ORDER BY pt.project_name;

-- 8)
SELECT p.project_name, COUNT(e.employee_id) as total_employees
FROM employees e
JOIN employee_projects ep ON e.employee_id = ep.employee_id
JOIN projects p ON p.project_id = ep.project_id
GROUP BY p.project_name
ORDER BY total_employees DESC;

-- 9)
SELECT 
    d.department_id,
    d.department_name,
    AVG(e.salary) AS average_salary
FROM 
    departments d
    JOIN employees e ON d.department_id = e.department_id
    JOIN employee_projects ep ON e.employee_id = ep.employee_id
GROUP BY 
    d.department_id, d.department_name
ORDER BY 
    d.department_id;

-- 10)
SELECT DISTINCT 
    e.name AS employee_name,
    p.project_name
FROM 
    employees e
    JOIN employee_projects ep ON e.employee_id = ep.employee_id
    JOIN projects p ON ep.project_id = p.project_id
WHERE 
    e.employee_id IN (
        SELECT e2.employee_id
        FROM employees e2
        JOIN employee_projects ep2 ON e2.employee_id = ep2.employee_id
        JOIN projects p2 ON ep2.project_id = p2.project_id
        GROUP BY e2.employee_id
        HAVING COUNT(DISTINCT p2.department_id) = (SELECT COUNT(*) FROM departments)
    )
ORDER BY 
    e.name, p.project_name;


-- 11)
SELECT 
    e.name AS employee_name,
    COUNT(ep.project_id) AS project_count
FROM 
    employees e
    LEFT JOIN employee_projects ep ON e.employee_id = ep.employee_id
GROUP BY 
    e.employee_id, e.name
HAVING 
    COUNT(ep.project_id) = (
        SELECT COUNT(project_id)
        FROM employee_projects
        GROUP BY employee_id
        ORDER BY COUNT(project_id) DESC
        LIMIT 1
    )
ORDER BY 
    e.name;

-- 12)
SELECT 
    d.department_name,
    COUNT(p.project_id) AS project_count
FROM 
    departments d
    LEFT JOIN projects p ON d.department_id = p.department_id
GROUP BY 
    d.department_id, d.department_name
HAVING 
    COUNT(p.project_id) = (
        SELECT COUNT(project_id)
        FROM projects
        GROUP BY department_id
        ORDER BY COUNT(project_id) DESC
        LIMIT 1
    )
ORDER BY 
    d.department_name;

   
-- 13)
SELECT 
    p.project_id,
    p.project_name,
    e.name AS employee_name,
    e.salary
FROM 
    projects p
    JOIN employee_projects ep ON p.project_id = ep.project_id
    JOIN employees e ON ep.employee_id = e.employee_id
    JOIN (
        SELECT 
            ep.project_id,
            MIN(e.salary) AS min_salary
        FROM 
            employee_projects ep
            JOIN employees e ON ep.employee_id = e.employee_id
        GROUP BY 
            ep.project_id
    ) min_salaries ON p.project_id = min_salaries.project_id AND e.salary = min_salaries.min_salary
ORDER BY 
    p.project_id, e.name;


-- 14)
SELECT 
    p.project_id,
    p.project_name
FROM 
    projects p
    LEFT JOIN employee_projects ep ON p.project_id = ep.project_id
WHERE 
    ep.project_id IS NULL
ORDER BY 
    p.project_id;

-- 15)
SELECT 
    d.department_id,
    d.department_name,
    MAX(CASE WHEN e.salary = dept_salary.max_salary THEN e.name END) AS highest_paid_employee,
    MAX(e.salary) AS highest_salary,
    MIN(CASE WHEN e.salary = dept_salary.min_salary THEN e.name END) AS lowest_paid_employee,
    MIN(e.salary) AS lowest_salary
FROM 
    departments d
    JOIN employees e ON d.department_id = e.department_id
    JOIN (
        SELECT 
            department_id,
            MAX(salary) AS max_salary,
            MIN(salary) AS min_salary
        FROM 
            employees
        GROUP BY 
            department_id
    ) dept_salary ON d.department_id = dept_salary.department_id
GROUP BY 
    d.department_id, d.department_name, dept_salary.max_salary, dept_salary.min_salary
ORDER BY 
    d.department_id;
   
-- 16)
SELECT 
    d.department_id,
    d.department_name,
    p.project_id,
    p.project_name,
    COUNT(DISTINCT e.employee_id) AS employee_count,
    SUM(e.salary) AS total_salary
FROM 
    departments d
    JOIN employees e ON d.department_id = e.department_id
    JOIN employee_projects ep ON e.employee_id = ep.employee_id
    JOIN projects p ON ep.project_id = p.project_id
GROUP BY 
    d.department_id, d.department_name, p.project_id, p.project_name
ORDER BY 
    d.department_id, p.project_id;

-- 17)
SELECT 
    e.employee_id,
    e.name AS employee_name,
    e.department_id
FROM 
    employees e
    LEFT JOIN employee_projects ep ON e.employee_id = ep.employee_id
WHERE 
    ep.employee_id IS NULL
ORDER BY 
    e.employee_id;

-- 18)
SELECT 
    d.department_id,
    d.department_name,
    COUNT(p.project_id) AS project_count
FROM 
    departments d
    LEFT JOIN projects p ON d.department_id = p.department_id
GROUP BY 
    d.department_id, d.department_name
ORDER BY 
    d.department_id;
   
-- 19)
SELECT 
    e.employee_id,
    e.name AS employee_name,
    e.salary,
    p.project_id,
    p.project_name
FROM 
    departments d
    JOIN employees e ON d.department_id = e.department_id
    LEFT JOIN employee_projects ep ON e.employee_id = ep.employee_id
    LEFT JOIN projects p ON ep.project_id = p.project_id
WHERE 
    (d.department_id, e.salary) IN (
        SELECT 
            department_id, 
            MAX(salary) 
        FROM 
            employees 
        GROUP BY 
            department_id
    )
ORDER BY 
    d.department_id, p.project_id;

-- 20)
SELECT 
    SUM(e.salary) AS total_salary
FROM 
    departments d
    CROSS JOIN projects p
    LEFT JOIN employees e ON d.department_id = e.department_id
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM employee_projects ep
        WHERE ep.project_id = p.project_id
    )
GROUP BY 
    d.department_id, d.department_name, p.project_id, p.project_name
ORDER BY 
    d.department_id, p.project_id;






