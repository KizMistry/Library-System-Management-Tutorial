select * from books;
select * from branch;
select * from employees;
select * from issued_status;
select * from return_status;
select * from members;

-- Project Tasks

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird',
-- 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird',
'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Main St'
WHERE member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121'


-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
	issued_emp_id
--	COUNT(issued_id) as total_book_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1

-- CTAS (Create Table As Select) This will create a new table based on results of the SELECT query that is run.
-- You can then load this new table without having to run the query again

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results 
-- each book and total book_issued_cnt**

CREATE TABLE book_cnts
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2

SELECT * FROM book_cnts

-- Task 7. Retrieve All Books in a Specific Category:
SELECT * FROM books
WHERE category = 'Classic'

--Task 8: Find Total Rental Income by Category:

SELECT
	b.category,
	SUM(b.rental_price),
	COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY 1

-- List Members Who Registered in the Last 180 Days:

-- First we'll add records of members with recent registered dates
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C120', 'Jordan', '386 Grove St', '2025-01-26'),
('C121', 'Billy', '954 Grove St', '2025-03-22');

-- We can also update current members (for the purpose of this task) with:
UPDATE members
SET reg_date = '2025-02-15'
WHERE member_id = 'C102';

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days'

-- List Employees with Their Branch Manager's Name and their branch details:
-- First we select everything from the branch table.
SELECT * FROM branch

-- Here we have limited info, but we have the manager_id, so we can open the employees table
SELECT * FROM employees

-- We will need to join these tables to return both the branch details and manager names

SELECT *  						--get everything
FROM employees as e1			--from employees table, refer to this table as e1
JOIN							--join branch table
branch as b						--refer to this table as b
ON b.branch_id = e1.branch_id	--Get all rows where the branch_id values match in both the employees (aliased as e1) 
								--and branch (aliased as b) tables, and return all columns from both.

--we now have both tables side by side and can see the manager_id next to each employee
--but we need the managers name next to the employees name and branch details, so we can add on:

SELECT *  					
FROM employees as e1			
JOIN							
branch as b						
ON b.branch_id = e1.branch_id
JOIN
employees as e2					--join another copy of employees table and refer as e2
ON b.manager_id = e2.emp_id		--get all rows where manager_id in branch table matches emp_id in e2

--We can then just select the columns that we want returning
SELECT 
	e1.*, --everything from e1
	b.manager_id, --employee/manager id
	e2.emp_name as manager,--managers name
	b.branch_address --branch address
FROM employees as e1			
JOIN							
branch as b						
ON b.branch_id = e1.branch_id
JOIN
employees as e2					
ON b.manager_id = e2.emp_id	

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold (7usd):

SELECT * FROM books; --retrive table to see data

SELECT * FROM books
WHERE rental_price > 7; --add a condition to the query

CREATE TABLE expensive_books	--creates a table called exspensive_books
AS								--using the below conditions
SELECT * FROM books
WHERE rental_price > 7;

SELECT * FROM expensive_books; --returns our new table

--Task 12: Retrieve the List of Books Not Yet Returned

SELECT * FROM issued_status
SELECT * FROM return_status

-- the common column is issued_id, so we can join these tables on that condition
--The LEFT JOIN keyword returns all records from the left table (table1), 
--and the matching records from the right table (table2).
SELECT *
FROM issued_status as is_stat
LEFT JOIN 
return_status as re_stat
ON
is_stat.issued_id = re_stat.issued_id

--we can then add the WHERE condition to return rows where ther are no return_ids in the return table
--we could use return_date as this would also be a null value if it hasn't been returned
SELECT *
FROM issued_status as is_stat
LEFT JOIN
return_status as re_stat
ON
is_stat.issued_id = re_stat.issued_id
WHERE re_stat.return_id IS NULL


