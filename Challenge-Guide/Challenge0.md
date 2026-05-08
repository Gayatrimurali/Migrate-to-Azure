# Challenge 0 : Deploy and Provision Required Azure Resources

### Estimated Duration : 60 Minutes

## Overview

This exercise provisions all required Azure resources and sets up the web application running on your local machine (simulating an on-premises environment). By the end of this exercise, you will have:

- Azure infrastructure ready (Resource Group, VNet, Azure SQL Database)
- The Contoso Retail web application running locally on `http://localhost:8080`
- The application connecting to Azure SQL Database and displaying product data

This local setup simulates your on-premises data center. In Exercise 2, you will migrate this locally running application to Azure App Service.

## Objectives

In this Exercise, you will complete the following task:

   - Task 1: Deploy the Virtual Network and Subnets
   - Task 2: Deploy Azure SQL Server and Database
   - Task 3: Set Up and Run the Web Application Locally (On-Premises Simulation)

## Task 1: Deploy the Virtual Network and Subnets

1. In the Azure portal, create a **Virtual networks**.

2. On the **Basics** tab, provide the following details:

   - **Subscription**: keep default Azure subscription
   - **Resource group**: `rg-migration-lab` **(1)**
   - **Virtual network name**: `vnet-migration-lab` **(2)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(3)**

3. On the **IP Addresses** tab, add below subnets configure the following and select **Review + Create**.

    - snet-default
    - snet-appservice 
    - snet-private 

4. Open **vnet-migration-lab** → go to **Subnets** → select **snet-appservice** → under **Subnet delegation** choose **Microsoft.Web/serverFarms** → click **Save**.

## Task 2: Deploy Azure SQL Server and Database

1. In the **SQL databases**, select **+ Create** a **SQL database**.

2. On the **Basics** tab, provide the following details:

   - **Subscription**: keep your default Azure subscription
   - **Resource group**: `rg-migration-lab` **(1)**
   - **Database name**: `contosodb` **(2)**
   - **Server**: select **Create new** **(3)**

4. In the **Create SQL Database Server** panel:

   - **Server name**: `sql-contoso-<inject key="Deployment ID" enableCopy="false"></inject>` **(1)**
   - **Location**: <inject key="Region" enableCopy="false"></inject> **(2)**
   - **Authentication method**: select **Use SQL authentication** **(3)**
   - **Server admin login**: `sqladmin` **(4)**
   - **Password**: `P@ssw0rd2026!` **(5)**
   - **Confirm password**: `P@ssw0rd2026!` **(6)**
   - Select **OK** **(7)**

17. In Query editor paste and **Run** the following SQL to create the tables and insert sample data:

      ```sql
      -- Create Products table
      CREATE TABLE Products (
         ProductId INT PRIMARY KEY IDENTITY(1,1),
         ProductName NVARCHAR(200) NOT NULL,
         Category NVARCHAR(100) NOT NULL,
         Price DECIMAL(10,2) NOT NULL,
         StockQuantity INT NOT NULL,
         CreatedAt DATETIME2 DEFAULT GETUTCDATE()
      );

      -- Create Orders table
      CREATE TABLE Orders (
         OrderId INT PRIMARY KEY IDENTITY(1,1),
         CustomerName NVARCHAR(200) NOT NULL,
         CustomerEmail NVARCHAR(200) NOT NULL,
         ProductId INT FOREIGN KEY REFERENCES Products(ProductId),
         Quantity INT NOT NULL,
         TotalAmount DECIMAL(10,2) NOT NULL,
         OrderDate DATETIME2 DEFAULT GETUTCDATE()
      );

      -- Insert sample products
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

      -- Insert sample orders
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
      ```

18. Verify the data was inserted correctly by running:

      ```sql
      SELECT COUNT(*) AS product_count FROM Products;
      SELECT COUNT(*) AS order_count FROM Orders;
      ```

      Both queries should return **10** rows.

## Task 3: Set Up and Run the Web Application Locally (On-Premises Simulation)

1. Open a VS Code 

2. open a folder > lab files > contoso-retail-webapp > contoso-retail-webapp.

3. Open termainal 

   ```
   cd C:\LabFiles\contoso-retail-webapp\contoso-retail-webapp
   ```

4. Initialize the Node.js project:

   ```bash
   npm init -y
   ```
5. Install dependencies:

   ```bash
   npm install express ejs mssql dotenv
   ```
6. run the command 

   ```
   npm fund
   ```
7. Run the command 

   ```
   npm audit fix --force
   ```

5. Go to `.env` file and update the **<DeploymentID>** for local testing (do not commit to source control):

   ```
   DB_SERVER=sql-contoso-<DeploymentID>.database.windows.net
   DB_NAME=contosodb
   DB_USER=sqladmin
   DB_PASSWORD=P@ssw0rd2026!
   PORT=8080
   ```

6. Test the application locally to simulate the on-premises environment:

   ```bash
   npm start
   ```

7. Open a browser and navigate to `http://localhost:8080`. Verify the following:


   | Validation | Expected Result |
   | --- | --- |
   | Home page loads | `http://localhost:8080` shows "Welcome to Contoso Retail" |
   | Products page loads | `http://localhost:8080/products` shows 10 products in a table |
   | Database connectivity | Product data (names, categories, prices) comes from Azure SQL |


## Success Criteria

In this exercise you will discover and document the existing Contoso Retail environment, define a migration strategy using the Microsoft Cloud Adoption Framework (CAF), and provision a secure Azure Landing Zone for migration readiness. You will also configure networking components such as VNets, subnets, and NSGs, validate Azure infrastructure readiness, and map application dependencies including SQL connectivity and App Service settings. Finally, you will verify the complete migration preparation by generating discovery reports, strategy documents, and readiness validation outputs required for the upcoming migration challenges.

Now, click on **Next** from the lower right corner to move on to the next page.

   ![](../media/ggs2.png)
