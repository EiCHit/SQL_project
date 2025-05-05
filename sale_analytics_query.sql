USE sales_analytics;

-- Create tables
  
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(15)
);

CREATE TABLE Products (
	ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2)
);

CREATE TABLE Employees (
	EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FristName VARCHAR(50),
    LastName VARCHAR(50),
    Position VARCHAR(50),
    Salary DECIMAL(10, 2)
);

CREATE TABLE Sales (
	SaleID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    EmployeeID INT,
    SaleDate DATE,
    Quantity INT,
    TotalAmount DECIMAL(10, 2),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

INSERT INTO Customers (FirstName, LastName, Email, Phone)
VALUES 
('John', 'Doe', 'john.doe@example.com', '555-1234'),
('Jane', 'Smith', 'jane.smith@example.com', '555-5678'),
('Alice', 'Johnson', 'alice.johnson@example.com', '555-8765');

INSERT INTO Products (ProductName, Category, Price)
VALUES 
('Laptop', 'Electronics', 1200.00),
('Smartphone', 'Electronics', 800.00),
('Tablet', 'Electronics', 400.00),
('Chair', 'Furniture', 150.00),
('Desk', 'Furniture', 250.00);

INSERT INTO Employees (FristName, LastName, Position, Salary)
VALUES 
('Michael', 'Brown', 'Salesperson', 50000.00),
('Emily', 'Davis', 'Sales Manager', 70000.00),
('David', 'Wilson', 'Salesperson', 45000.00);

INSERT INTO Sales (ProductID, CustomerID, EmployeeID, SaleDate, Quantity, TotalAmount)
VALUES 
(1, 1, 1, '2023-01-01', 1, 1200.00),
(2, 2, 2, '2023-01-15', 2, 1600.00),
(3, 3, 1, '2023-02-01', 1, 400.00),
(4, 1, 3, '2023-03-10', 3, 450.00),
(5, 2, 2, '2023-03-15', 1, 250.00);

-- total sales by product category

SELECT p.Category, SUM(s.TotalAmount) AS TotalSales
FROM Sales s
JOIN Products p ON p.ProductID = s.ProductID
Group BY p.Category;

-- Top 5 Best Selling Products

SELECT p.ProductName, SUM(s.Quantity) AS TotalSold
FROM Sales s
JOIN Products p ON p.ProductID = s.ProductID
GROUP BY p.ProductName
ORDER BY TotalSold DESC
LIMIT 5;

-- Monthly sales report for 2023

SELECT YEAR(s.SaleDate) AS Year, MONTH(s.SaleDate) AS Month, SUM(s.TotalAmount) AS TotalSales
FROM Sales s
WHERE YEAR(s.saleDate) = 2023
GROUP BY YEAR(s.SaleDate), MONTH(s.SaleDate)
ORDER BY Month;

-- AVG sales per employee

SELECT e.FristName, e.LastName, AVG(s.TotalAmount) AS AvgSales
FROM Sales s
JOIN Employees e ON s.EmployeeID = e.EmployeeID
GROUP BY e.EmployeeID; 

-- customer spending trend

SELECT c.FirstName, c.LastName, SUM(s.TotalAmount) AS TotalSpend
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerID
ORDER BY TotalSpend DESC; 

-- highest sales per product category

SELECT p.Category, MAX(s.TotalAmount) AS MaxSales
FROM Sales s
JOIN Products p ON s.ProductID = s.ProductID
GROUP BY p.Category;

--   Running total of sales

SELECT SaleID, SaleDate, TotalAmount,
	SUM(TotalAmount) OVER (ORDER BY SaleDate) AS RunningSales
FROM Sales;

-- Customers who spent above avg  

SELECT c.FirstName, c.LastName
FROM Customers c 
WHERE (
	SELECT SUM(s.TotalAmount)
    FROM Sales s
    WHERE s.CustomerID = c.CustomerID
) > (
	SELECT AVG(TotalAmount) FROM Sales
);

-- tagging high and low sales

SELECT s.SaleID, s.TotalAmount,
	CASE 
		WHEN s.TotalAmount >= 1000 THEN 'HIGH'
		WHEN s.TotalAmount >= 500 THEN 'Medium'
		ELSE 'LOW'
    END AS SaleCategory
FROM Sales s;

-- total sale per customer(Create a view)

CREATE VIEW CustomerSaleSummary AS
SELECT c.CustomerID, c.FirstName, c.LastName, SUM(s.TotalAmount) AS TotalSpent
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;

SELECT * FROM CustomerSaleSummary;

-- update LatePurchaseDate after sales(Create a trigger)

DELIMITER $$

CREATE TRIGGER UpdateLastPurchase
AFTER INSERT ON Sales
FOR EACH ROW
BEGIN
    UPDATE Customers
    SET LastPurchaseDate = NEW.SaleDate
    WHERE CustomerID = NEW.CustomerID;
END $$

DELIMITER ;

ALTER TABLE Customers ADD COLUMN LastPurchaseDate DATE;

