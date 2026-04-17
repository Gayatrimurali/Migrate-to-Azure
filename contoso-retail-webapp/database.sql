CREATE TABLE Products (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductName NVARCHAR(200) NOT NULL,
    Category NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETUTCDATE()
);

CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY(1,1),
    CustomerName NVARCHAR(200) NOT NULL,
    CustomerEmail NVARCHAR(200) NOT NULL,
    ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
    Quantity INT NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    OrderDate DATETIME2 DEFAULT GETUTCDATE()
);

INSERT INTO Products (ProductName, Category, Price, StockQuantity) VALUES
('Laptop Pro 14', 'Electronics', 1499.99, 50),
('Wireless Mouse', 'Electronics', 39.99, 200),
('Office Chair', 'Furniture', 249.00, 75),
('Standing Desk', 'Furniture', 499.00, 30),
('Notebook Pack', 'Stationery', 12.50, 500),
('Noise Cancelling Headphones', 'Electronics', 199.00, 100),
('Water Bottle', 'Lifestyle', 18.00, 300),
('Desk Lamp', 'Furniture', 45.00, 150),
('USB-C Hub', 'Electronics', 69.00, 250),
('Backpack', 'Lifestyle', 79.99, 120);

INSERT INTO Orders (CustomerName, CustomerEmail, ProductId, Quantity, TotalAmount, OrderDate) VALUES
('Ava Patel', 'ava.patel@contoso.com', 1, 1, 1499.99, '2026-03-01'),
('Liam Nguyen', 'liam.nguyen@contoso.com', 2, 2, 79.98, '2026-03-02'),
('Noah Kim', 'noah.kim@contoso.com', 3, 1, 249.00, '2026-03-03'),
('Mia Garcia', 'mia.garcia@contoso.com', 4, 1, 499.00, '2026-03-04'),
('Ethan Singh', 'ethan.singh@contoso.com', 5, 10, 125.00, '2026-03-05'),
('Zoe Brown', 'zoe.brown@contoso.com', 6, 1, 199.00, '2026-03-06'),
('Lucas Lee', 'lucas.lee@contoso.com', 7, 3, 54.00, '2026-03-07'),
('Emma Davis', 'emma.davis@contoso.com', 8, 2, 90.00, '2026-03-08'),
('Ryan Martinez', 'ryan.martinez@contoso.com', 9, 1, 69.00, '2026-03-09'),
('Nora Wilson', 'nora.wilson@contoso.com', 10, 1, 79.99, '2026-03-10');