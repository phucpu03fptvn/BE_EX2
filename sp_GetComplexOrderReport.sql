CREATE DATABASE ECommerceDB;

USE ECommerceDB;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Address VARCHAR(255)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    Status VARCHAR(20),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10, 2),
    Stock INT
);

CREATE TABLE Shipments (
    ShipmentID INT PRIMARY KEY,
    OrderID INT,
    ShipmentDate DATE,
    DeliveryStatus VARCHAR(20),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

INSERT INTO Customers (CustomerID, CustomerName, Email, Phone, Address) VALUES
(1, 'Nguyen Thi Mai', 'mai.nguyen@email.com', '0901234567', '123 Đường ABC, Quận 1, TP.HCM'),
(2, 'Tran Minh Tu', 'tu.tran@email.com', '0902345678', '456 Đường XYZ, Quận 2, TP.HCM'),
(3, 'Le Quang Hieu', 'hieu.le@email.com', '0903456789', '789 Đường DEF, Quận 3, TP.HCM'),
(4, 'Phan Thi Lan', 'lan.phan@email.com', '0904567890', '101 Đường GHI, Quận 4, TP.HCM'),
(5, 'Pham Anh Khoa', 'khoa.pham@email.com', '0905678901', '202 Đường JKL, Quận 5, TP.HCM');

INSERT INTO Products (ProductID, ProductName, Category, Price, Stock) VALUES
(1, 'Điện thoại Samsung Galaxy', 'Điện thoại', 10000.00, 50),
(2, 'Laptop Dell XPS', 'Máy tính', 20000.00, 30),
(3, 'Tai nghe Sony WH-1000XM4', 'Tai nghe', 5000.00, 100),
(4, 'Máy tính bảng iPad Pro', 'Máy tính bảng', 15000.00, 40),
(5, 'Smartwatch Apple Watch', 'Đồng hồ thông minh', 8000.00, 60);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, Status) VALUES
(1, 1, '2024-12-01', 'Đang xử lý'),
(2, 2, '2024-12-02', 'Đã giao'),
(3, 3, '2024-12-03', 'Đang xử lý'),
(4, 4, '2024-12-04', 'Đã giao'),
(5, 5, '2024-12-05', 'Đang xử lý');

INSERT INTO OrderItems (OrderItemID, OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 1, 2, 10000.00),
(2, 2, 2, 1, 20000.00),
(3, 3, 3, 3, 5000.00),
(4, 4, 4, 1, 15000.00),
(5, 5, 5, 2, 8000.00);

INSERT INTO Shipments (ShipmentID, OrderID, ShipmentDate, DeliveryStatus) VALUES
(1, 1, '2024-12-02', 'Đang giao'),
(2, 2, '2024-12-03', 'Đã giao'),
(3, 3, '2024-12-04', 'Đang giao'),
(4, 4, '2024-12-05', 'Đã giao'),
(5, 5, '2024-12-06', 'Đang giao');

CREATE PROCEDURE sp_GetComplexOrderReport
	@StartDate DATE,
	@EndDate DATE,
	@CustomerId INT = NULL,
	@MinAmount DECIMAL(18,2) = NULL,
	@MaxAmount DECIMAL(18,2) = NULL,
	@OrderStatus VARCHAR(50) = NULL,
	@ShipmentStatus VARCHAR(50) = NULL
AS
BEGIN
	SELECT O.OrderID, O.OrderDate, C.CustomerName,
	SUM(OI.Quantity * P.Price) AS TotalAmount,
	SUM(OI.Quantity) AS TotalQuantity,
	S.ShipmentDate,
	S.DeliveryStatus,
	O.Status AS OrderStatus
	FROM Orders O 
	INNER JOIN  Customers C ON O.CustomerID = C.CustomerID
	INNER JOIN OrderItems OI ON OI.OrderID = O.OrderID
	INNER JOIN Products P ON P.ProductID = OI.ProductID
	LEFT JOIN Shipments S ON S.OrderID = O.OrderID
	WHERE O.OrderDate BETWEEN @StartDate And @EndDate
	AND(@CustomerId IS NULL OR O.CustomerID = @CustomerId)
    AND (@OrderStatus IS NULL OR O.Status = @OrderStatus)
    AND (@ShipmentStatus IS NULL OR S.DeliveryStatus = @ShipmentStatus)
	GROUP BY 
        O.OrderID, O.OrderDate, C.CustomerName, S.ShipmentDate, S.DeliveryStatus, O.Status
	 HAVING 
        (@MinAmount IS NULL OR SUM(OI.Quantity * P.Price) >= @MinAmount)
        AND (@MaxAmount IS NULL OR SUM(OI.Quantity * P.Price) <= @MaxAmount)
    ORDER BY 
        O.OrderDate;
END


EXEC sp_GetComplexOrderReport 
    @StartDate = '2024-12-01', 
    @EndDate = '2024-12-05', 
    @CustomerId = 1, 
    @MinAmount = 20000, 
    @MaxAmount = NULL, 
    @OrderStatus = 'Đang xử lý', 
    @ShipmentStatus = NULL;


