[README.md](https://github.com/user-attachments/files/22102027/README.md)
# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.


## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;

CREATE TABLE branch
	(branch_id VARCHAR(10) PRIMARY KEY, 
    manager_id VARCHAR(10), 
    branch_address VARCHAR(55), 
    contact_no VARCHAR(10));

ALTER TABLE branch
MODIFY COLUMN contact_no VARCHAR(20);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
	(emp_id VARCHAR(10) PRIMARY KEY, 
    emp_name VARCHAR(25), 
    position VARCHAR(15), 
    salary INT, 
    branch_id VARCHAR(10) -- FK
	);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
	(member_id VARCHAR(10) PRIMARY KEY, 
    member_name VARCHAR(25), 
    member_address VARCHAR(75), 
    reg_date DATE);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
	(isbn VARCHAR(20) PRIMARY KEY, 
    book_title VARCHAR(75), 
    category VARCHAR(20), 
    rental_price FLOAT, 
    status VARCHAR(15), 
    author VARCHAR(30), 
    publisher VARCHAR(30));



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
	(issued_id VARCHAR(10) PRIMARY KEY, 
    issued_member_id VARCHAR(10), -- FK
    issued_book_name VARCHAR(75), 
    issued_date DATE, 
    issued_book_isbn VARCHAR(25), -- FK
    issued_emp_id VARCHAR(10) -- FK
    ); 



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
	(return_id VARCHAR(10), 
    issued_id VARCHAR(10), 
    return_book_name VARCHAR(75), 
    return_date DATE, 
    return_book_isbn VARCHAR(20));

-- Setting up the Foreign Keys
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT issued_emp_id, COUNT(issued_id) AS total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING total_books_issued > 1;
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_issued_cnt AS
(SELECT b.book_title, COUNT(i.issued_id) AS issued_count FROM books b
LEFT JOIN issued_status i ON 
b.isbn = i.issued_book_isbn
GROUP BY b.book_title);
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT *
FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
	b.category, 
    SUM(b. rental_price),
    COUNT(*)
FROM books b
JOIN issued_status i ON 
b.isbn = i.issued_book_isbn
GROUP BY 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT *
FROM members
WHERE reg_date >= CURRENT_date - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
	e1.*,
    e2.emp_name AS Manager,
    b.manager_id
FROM employees e1
JOIN branch b 
ON e1.branch_id = b.branch_id
JOIN employees e2
ON b.manager_id = e2.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT *
FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT *
FROM issued_status i
LEFT JOIN return_status r 
ON i.issued_id = r.issued_id
WHERE return_date IS NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
	m.member_id, 
    m.member_name, 
    i.issued_book_name, 
    i.issued_date,
    current_date - i.issued_date AS over_dues_days
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
JOIN members m ON i.issued_member_id = m.member_id
WHERE r.return_id is NULL AND (current_date - i.issued_date) > 30
ORDER BY 1;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

DELIMITER $$

CREATE PROCEDURE add_return_records (
	IN p_return_id INT, 
    IN p_issued_id INT,
    IN p_book_quality VARCHAR(15))
    

BEGIN

	DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);
    
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);
    
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id
    LIMIT 1;
    
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;
    
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
	END$$
DELIMITER ;


```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_reports
AS
SELECT 
	b.branch_id,
    b.manager_id,
    COUNT(i.issued_id) AS number_book_issued,
    COUNT(r.return_id) AS number_of_books_returned,
    SUM(bk.rental_price) AS total_revenue
FROM issued_status i
JOIN employees e ON i.issued_emp_id = e.emp_id
JOIN branch b ON e.branch_id = b.branch_id
LEFT JOIN return_status r ON r.issued_id = i.issued_id
JOIN books bk ON i.issued_book_isbn = bk.isbn
GROUP BY 1, 2;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN
(SELECT DISTINCT issued_member_id
FROM members m
JOIN issued_status i
ON m.member_id = i.issued_member_id
WHERE issued_date >= CURRENT_DATE - INTERVAL 2 MONTH);

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT e.emp_id, e.emp_name, e.branch_id, COUNT(issued_id) AS Total_books_issued
FROM employees e
JOIN issued_status i ON e.emp_id = i.issued_emp_id
group by 1
ORDER BY Total_books_issued DESC
LIMIT 3;
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
SELECT 
	m.member_name, 
    i.issued_book_name, 
    COUNT(*) AS No_book_damaged
FROM issued_status i
JOIN members m ON i.issued_member_id = m.member_id
JOIN return_status r on i.issued_id = r.issued_id
WHERE r.book_quality = 'Damaged'
GROUP BY 1, 2
HAVING COUNT(*) > 2;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

DELIMITER $$
CREATE PROCEDURE issue_book (
	IN p_issued_id VARCHAR(10), 
    IN p_issued_member_id VARCHAR(30), 
    IN p_issued_book_isbn VARCHAR(30), 
    IN p_issued_emp_id VARCHAR(30))
    
BEGIN
DECLARE v_status VARCHAR(10);

SELECT status INTO v_status
FROM books
WHERE isbn =  p_issued_book_isbn;

IF v_status = 'yes' THEN
INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

UPDATE books
SET status = 'no'
WHERE isbn = issued_book_isbn;

SELECT CONCAT('Book records added successfully for book isbn: ', p_issued_book_isbn) AS message;

ELSE
SELECT CONCAT('Sorry to inform you, the book you have requested is unavailable, book isbn: ', p_issued_book_isbn) AS message;

END IF;
END$$

DELIMITER ;

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
CREATE TABLE Overdue_books AS 
(SELECT 
	m.member_name,
    SUM(
        CASE 
            WHEN r.return_id IS NULL 
                 AND CURRENT_DATE - i.issued_date > 30 
            THEN ((CURRENT_DATE - i.issued_date) - 30) * 0.5
            ELSE 0
        END
    ) AS total_fines,
    COUNT(i.issued_id) AS Overdue_books
FROM issued_status i
JOIN members m ON i.issued_member_id = m.member_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE CURRENT_DATE - i.issued_date > 30 AND r.return_id IS NULL
GROUP BY 1);
```



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.


## Author - Bruck Melaku

## Author's Note - I would like to thank ZeroAnalyst for the source of the data as well as for guidance.

Thank you for your interest in this project!
