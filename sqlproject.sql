-- Create Database
CREATE DATABASE OnlineBookstore;

-- Switch to the database
\c OnlineBookstore;

-- Create Tables
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);

SELECT * FROM Books;
SELECT * FROM Customers;
SELECT * FROM Orders;

--Import Data into the Books Table
COPY Books (Book_id, Title,Author,Genre,Published_year,Price,Stock)
FROM 'C:\Users\agarw\Downloads\Books.csv'
DELIMITER ','
CSV HEADER;
--Import Data into the Customers Table
COPY Customers (Customer_id,Name,Email,Phone,City,Country)
FROM 'C:\Users\agarw\Downloads\Customer.csv'
DELIMITER ','
CSV HEADER;
--Import Data into the Orders Table
COPY Orders (Order_id,Customer_id,Book_id,Order_Date,Quantity,Total_Amount)
FROM 'C:\Users\agarw\Downloads\Orders.csv'
DELIMITER ','
CSV HEADER;

--Retrieve all the books in the "Fiction" genre
SELECT * FROM Books
WHERE genre='Fiction'
--Find the books published after the year 1950
SELECT * FROM Books
WHERE published_year>1950
--List all the customers From the Canada
SELECT * FROM Customers
WHERE country='Canada'
--Show Orders placed in November 2023
SELECT * FROM Orders
WHERE order_date BETWEEN '2023-11-01' AND '2023-11-30'
--Retrieve the total stocks of the books available
SELECT SUM(stock) AS total_stocks FROM Books
--Find the details of the most expensive book
SELECT * FROM Books
Order by Price DESC
LIMIT 1
--Show all customers who ordered more than 1 quantity of a book
SELECT * FROM Orders
WHERE quantity>1
--retrieve all the orders where total amount exceeds $20
SELECT * FROM Orders
WHERE total_amount>20
--List all the genres available in the Books Table
SELECT DISTINCT genre from books
--Find the book with the lowest stock
SELECT * FROM Books
ORDER BY stock LIMIT 5
--Calculate the total revenue generated from all orders
SELECT SUM(total_amount) AS total_revenue 
FROM orders

--Advance Queries
--Retrieve the total number of books sold for each genre
SELECT  b.genre,SUM(o.quantity) as total_books_sold FROM Orders o
JOIN Books b
ON o.book_id=b.book_id
GROUP BY b.genre
--Find the Average price of books in the "fantasy " genre
SELECT AVG(price) AS average_price
FROM Books
WHERE genre='Fantasy'
--List customers who have placed atleast 2 orders
SELECT o.customer_id,c.name,count(o.order_id) as order_count
FROM orders o JOIN customers c
ON o.customer_id=c.customer_id
group by o.customer_id,c.name
having count(o.quantity)>=2
--find the most frequently ordered book
SELECT o.book_id,b.title,Count(o.order_id) as frequently_ordered
FROM orders o JOIN books b ON o.book_id=b.book_id
GROUP BY o.book_id,b.title  
order by frequently_ordered DESC
limit 1
--show the top 3 most expensive books of fantasy genre
SELECT book_id,title,genre,price FROM Books
WHERE genre='Fantasy'
ORDER BY price DESC
LIMIT 3
--Retrieve the total quantity of books sold by each author
SELECT b.author,sum(o.quantity) as total_quantity
FROM orders o join books b on
o.book_id=b.book_id
group by b.author
--list the cities where customers who spent over $20 are located
select DISTINCT c.city,total_amount  from customers c
join orders o on c.customer_id=o.customer_id
where total_amount>20
--calculate the stock remaining after fulfilling all the orders
select b.book_id,b.title,b.stock,coalesce(sum(quantity),0) as order_quantity,(b.stock-coalesce(sum(quantity),0)) as remaining_stock
FROM books b LEFT JOIN orders o
ON b.book_id=o.book_id
GROUP BY b.book_id
order by b.book_id