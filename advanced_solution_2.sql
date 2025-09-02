-- SQL Project Library Management System N2

-- Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

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

-- Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
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

-- Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals

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

-- CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN
(SELECT DISTINCT issued_member_id
FROM members m
JOIN issued_status i
ON m.member_id = i.issued_member_id
WHERE issued_date >= CURRENT_DATE - INTERVAL 2 MONTH);

-- Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
SELECT e.emp_id, e.emp_name, e.branch_id, COUNT(issued_id) AS Total_books_issued
FROM employees e
JOIN issued_status i ON e.emp_id = i.issued_emp_id
group by 1
ORDER BY Total_books_issued DESC
LIMIT 3;

-- Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.
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

/*
Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/


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

/*
Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 
The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. 
The resulting table should show: Member ID Number of overdue books Total fines
*/

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
