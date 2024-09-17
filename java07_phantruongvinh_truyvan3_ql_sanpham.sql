CREATE DATABASE ql_sanpham;
USE ql_sanpham;

CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    ContactName VARCHAR(100),
    Country VARCHAR(50)
);

CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(100),
    ContactName VARCHAR(100),
    Country VARCHAR(50)
);

CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100)
);

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    SupplierID INT,
    CategoryID INT,
    Unit VARCHAR(50),
    Price DECIMAL(10, 2),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    ShipperID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


CREATE TABLE OrderDetails (
    OrderDetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);



INSERT INTO Customers (CustomerName, ContactName, Country)
VALUES
('Around the Horn', 'Thomas Hardy', 'UK'),
('Berglunds snabbköp', 'Christina Berglund', 'Sweden'),
('Blauer See Delikatessen', 'Hanna Moos', 'Germany'),
('Blondel père et fils', 'Frédérique Citeaux', 'France'),
('Bólido Comidas preparadas', 'Martín Sommer', 'Spain'),
('Bon app''', 'Laurence Lebihan', 'France'),
('Bottom-Dollar Markets', 'Elizabeth Lincoln', 'Canada'),
('Cactus Comidas para llevar', 'Patricio Simpson', 'Argentina'),
('Centro comercial Moctezuma', 'Francisco Chang', 'Mexico'),
('Chop-suey Chinese', 'Yang Wang', 'Switzerland');

INSERT INTO Suppliers (SupplierName, ContactName, Country)
VALUES
('Grandma Kelly''s Homestead', 'Regina Murphy', 'USA'),
('Tokyo Traders', 'Yoshi Nagase', 'Japan'),
('Cooperativa de Quesos ''Las Cabras''', 'Antonio del Valle Saavedra', 'Spain'),
('Mayumi''s', 'Mayumi Ohno', 'Japan'),
('Pavlova, Ltd.', 'Ian Devling', 'Australia'),
('Specialty Biscuits, Ltd.', 'Peter Wilson', 'UK'),
('PB Knäckebröd AB', 'Lars Peterson', 'Sweden'),
('Refrescos Americanas LTDA', 'Carlos Diaz', 'Brazil'),
('Heli Süßwaren GmbH & Co. KG', 'Petra Winkler', 'Germany'),
('Plutzer Lebensmittelgroßmärkte AG', 'Martin Bein', 'Germany');



INSERT INTO Products (ProductName, SupplierID, CategoryID, Unit, Price)
VALUES
('Chef Anton''s Cajun Seasoning', 2, 2, '48 - 6 oz jars', 22.00),
('Chef Anton''s Gumbo Mix', 2, 2, '36 boxes', 21.35),
('Grandma''s Boysenberry Spread', 3, 2, '12 - 8 oz jars', 25.00),
('Uncle Bob''s Organic Dried Pears', 3, 7, '12 - 1 lb pkgs.', 30.00),
('Northwoods Cranberry Sauce', 3, 2, '12 - 12 oz jars', 40.00),
('Mishi Kobe Niku', 4, 6, '18 - 500 g pkgs.', 97.00),
('Ikura', 4, 8, '12 - 200 ml jars', 31.00),
('Queso Cabrales', 5, 4, '1 kg pkg.', 21.00),
('Queso Manchego La Pastora', 5, 4, '10 - 500 g pkgs.', 38.00),
('Konbu', 6, 8, '2 kg box', 6.00);

INSERT INTO Products (ProductName, SupplierID, CategoryID, Unit, Price)
VALUES
('Chang', 6, 8, '2 kg box', 25.00);


INSERT INTO Orders (CustomerID, OrderDate, ShipperID)
VALUES
(4, '2024-05-20', 3),
(5, '2024-05-21', 2),
(6, '2024-05-22', 1),
(7, '2024-05-23', 2),
(8, '2024-05-24', 3),
(9, '2024-05-25', 1),
(10, '2024-05-26', 2),
(1, '2024-05-27', 3),
(2, '2024-05-28', 1),
(3, '2024-05-29', 2);

INSERT INTO Orders (CustomerID, OrderDate, ShipperID)
VALUES
(4, '2024-05-21', 3);


INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES
(1, 1, 10),
(1, 2, 5),
(2, 3, 20),
(3, 4, 15),
(4, 5, 12),
(5, 6, 8),
(6, 7, 30),
(7, 8, 25),
(8, 9, 18),
(9, 10, 7);

INSERT INTO Categories (CategoryName)
VALUES
('Grains/Cereals'),
('Condiments'),
('Confections'),
('Dairy Products'),
('Seafood'),
('Beverages'),
('Produce'),
('Meat/Poultry');


-- 1)
SELECT p.ProductName, s.SupplierName, p.Price 
FROM Products p 
JOIN Suppliers s ON p.SupplierID = s.SupplierID 
WHERE p.Price > 15;

-- 2)
SELECT *
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID 
WHERE c.Country IN ("Mexico");

-- 3) 
SELECT c.Country, COUNT(o.OrderID) 
FROM Customers c 
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID 
GROUP BY c.Country;

-- 4)
SELECT s.SupplierName, COUNT(p.ProductID) Quantity
FROM Suppliers s 
LEFT JOIN Products p ON p.SupplierID = s.SupplierID 
GROUP BY s.SupplierName;

-- 5)
SELECT p.ProductName, p.Price 
FROM Products p 
WHERE p.Price > (
	SELECT p2.Price 
	FROM Products p2 
	WHERE p2.ProductName = "Chang"
)

-- 6)
SELECT SUM(od.Quantity) as total_quantity
FROM Orders o 
JOIN OrderDetails od ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 2024 AND MONTH(o.OrderDate) = 5;

-- 7)
SELECT c.CustomerName 
FROM Customers c
LEFT JOIN Orders o ON o.CustomerID = c.CustomerID
WHERE o.OrderID IS NULL;

-- 8)
SELECT o.OrderID , od.Quantity * p.Price as total_bill
FROM Orders o 
JOIN OrderDetails od ON o.OrderID = od.OrderID 
JOIN Products p ON p.ProductID = od.ProductID
HAVING total_bill > 200;

-- 9)
SELECT 
    p.ProductID,
    p.ProductName,
    AVG(od.Quantity) AS AverageQuantityPerOrder
FROM 
    Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    AverageQuantityPerOrder DESC;

-- 10)
SELECT 
    c.CustomerID,
    c.CustomerName,
    SUM(od.Quantity * p.Price) AS TotalOrderValue
FROM 
    Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    c.CustomerID, c.CustomerName
ORDER BY 
    TotalOrderValue DESC
LIMIT 1;

-- 11)
SELECT 
    o.OrderID,
    o.OrderDate,
    o.CustomerID,
    SUM(od.Quantity * p.Price) AS TotalOrderValue
FROM 
    Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    JOIN Products p ON od.ProductID = p.ProductID
GROUP BY 
    o.OrderID, o.OrderDate, o.CustomerID
ORDER BY 
    TotalOrderValue DESC
LIMIT 10;

-- 12)
SELECT 
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID) AS OrderCount
FROM 
    Customers c
    JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY 
    c.CustomerID, c.CustomerName
HAVING 
    COUNT(o.OrderID) > (
        SELECT AVG(OrderCount)
        FROM (
            SELECT COUNT(*) AS OrderCount
            FROM Orders
            GROUP BY CustomerID
        ) AS AvgOrders
    )
ORDER BY 
    OrderCount DESC;

-- 13)
SELECT 
    p.ProductID,
    p.ProductName,
    AVG(od.Quantity * p.Price) AS AverageOrderValue
FROM 
    Products p
    JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductID, p.ProductName
ORDER BY 
    AverageOrderValue DESC
LIMIT 1;

-- 14)
SELECT 
    p.ProductID,
    p.ProductName
FROM 
    Products p
WHERE 
    p.ProductID NOT IN (
        SELECT DISTINCT od.ProductID
        FROM OrderDetails od
        JOIN Orders o ON od.OrderID = o.OrderID
        JOIN Customers c ON o.CustomerID = c.CustomerID
        WHERE c.Country = 'USA'
    )
ORDER BY 
    p.ProductID;


-- 15)
SELECT 
    s.SupplierID,
    s.SupplierName ,
    COUNT(p.ProductID) AS ProductCount
FROM 
    Suppliers s
    JOIN Products p ON s.SupplierID = p.SupplierID
GROUP BY 
    s.SupplierID, s.SupplierName
HAVING 
    COUNT(p.ProductID) = (
        SELECT MAX(ProductCount)
        FROM (
            SELECT COUNT(ProductID) AS ProductCount
            FROM Products
            GROUP BY SupplierID
        ) AS SupplierProductCounts
    )
ORDER BY 
    s.SupplierID;
