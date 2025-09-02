-- Create a New Book Record 
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Update an Existing Member's Address
UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

-- Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Select all books issued by the employee with emp_id = 'E101'.
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';

-- List Members Who Have Issued More Than One Book
SELECT issued_emp_id, COUNT(issued_id) AS total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING total_books_issued > 1;

-- Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_issued_cnt AS
(SELECT b.book_title, COUNT(i.issued_id) AS issued_count FROM books b
LEFT JOIN issued_status i ON 
b.isbn = i.issued_book_isbn
GROUP BY b.book_title);

-- Retrieve All Books in a Specific Category(Classic)
SELECT *
FROM books
WHERE category = 'Classic';

-- Find Total Rental Income by Category
SELECT 
	b.category, 
    SUM(b. rental_price),
    COUNT(*)
FROM books b
JOIN issued_status i ON 
b.isbn = i.issued_book_isbn
GROUP BY 1;

-- List Members Who Registered in the Last 180 Days
SELECT *
FROM members
WHERE reg_date >= CURRENT_date - INTERVAL '180 days';

-- List Employees with Their Branch Manager's Name and their branch details
SELECT 
	e1.*,
    e2.emp_name AS Manager,
    b.manager_id
FROM employees e1
JOIN branch b 
ON e1.branch_id = b.branch_id
JOIN employees e2
ON b.manager_id = e2.emp_id;

-- Create a Table of Books with Rental Price Above a Certain Threshold(7)
CREATE TABLE expensive_books AS
SELECT *
FROM books
WHERE rental_price > 7.00;

-- Retrieve the List of Books Not Yet Returned
SELECT *
FROM issued_status i
LEFT JOIN return_status r 
ON i.issued_id = r.issued_id
WHERE return_date IS NULL






