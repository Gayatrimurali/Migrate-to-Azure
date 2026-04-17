# Exercise 0: Deploy and Provision Required Azure Resources

## Overview

This exercise provisions all required Azure resources and sets up the web application running on your local machine (simulating an on-premises environment). By the end of this exercise, you will have:

- Azure infrastructure ready (Resource Group, VNet, Azure SQL Database)
- The Contoso Retail web application running locally on `http://localhost:8080`
- The application connecting to Azure SQL Database and displaying product data

This local setup simulates your on-premises data center. In Exercise 2, you will migrate this locally running application to Azure App Service.

## Task 1: Create the Azure Resource Group for Lab Resources

1. In the **Azure portal**, select **Resource groups**.

   ![](../media/rg-select.png)

2. In the **Resource groups** page, select **+ Create**.

   ![](../media/rg-create.png)

3. In the **Basics** tab, provide the following details and select **Review + create** **(4)**:

   - **Subscription**: select your Azure subscription **(1)**
   - **Resource group name**: `rg-migration-lab` **(2)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(3)**

     ![](../media/rg-basic.png)

4. In the **Review + create** tab, select **Create**.

   ![](../media/rg-review-create.png)

Resource group `rg-migration-lab` is ready.

## Task 2: Deploy the Virtual Network and Subnets

1. In the Azure portal search bar, type **Virtual networks** **(1)** and select **Virtual networks** **(2)** under Services.

   ![](../media/vnet-search.png)

2. In the **Virtual networks** page, select **+ Create**.

   ![](../media/vnet-create.png)

3. On the **Basics** tab, provide the following details:

   - **Subscription**: select your Azure subscription **(1)**
   - **Resource group**: `rg-migration-lab` **(2)**
   - **Virtual network name**: `vnet-migration-lab` **(3)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(4)**

4. Select **Next** to proceed to the **Security** tab. Leave defaults and select **Next**.

5. On the **IP Addresses** tab, configure the following:

   - **Address space**: `10.0.0.0/16` **(1)**

   Remove any default subnets and add the following subnets:

   | Subnet name | Address range | Purpose |
   | --- | --- | --- |
   | `snet-appservice` | `10.0.1.0/24` | App Service VNet integration (delegated) |
   | `snet-private` | `10.0.2.0/24` | Private endpoints for SQL and other services |
   | `snet-default` | `10.0.0.0/24` | General-purpose subnet |

   ![](../media/vnet-subnets.png)

6. Select **Review + create**, then select **Create**.

   ![](../media/vnet-review-create.png)

7. Wait for the deployment to complete (approximately 1 to 2 minutes).

**Delegate the App Service subnet**

1. Open **vnet-migration-lab** and select **Subnets** in the left navigation.
2. Select the **snet-appservice** subnet.
3. Under **Subnet delegation**, select **Microsoft.Web/serverFarms**.
4. Select **Save**.

Virtual network and subnets are configured.

## Task 3: Deploy Azure SQL Server and Database

1. In the Azure portal search bar, type **SQL databases** **(1)** and select **SQL databases** **(2)** under Services.

   ![](../media/sql-search.png)

2. In the **SQL databases** page, select **+ Create**.

   ![](../media/sql-create.png)

3. On the **Basics** tab, provide the following details:

   - **Subscription**: select your Azure subscription **(1)**
   - **Resource group**: `rg-migration-lab` **(2)**
   - **Database name**: `contosodb` **(3)**
   - **Server**: select **Create new** **(4)**

4. In the **Create SQL Database Server** panel:

   - **Server name**: `sql-contoso-<inject key="Deployment ID" enableCopy="false"></inject>` **(1)**
   - **Location**: <inject key="Region" enableCopy="false"></inject> **(2)**
   - **Authentication method**: select **Use SQL authentication** **(3)**
   - **Server admin login**: `sqladmin` **(4)**
   - **Password**: `P@ssw0rd2026!` **(5)**
   - **Confirm password**: `P@ssw0rd2026!` **(6)**
   - Select **OK** **(7)**

     ![](../media/sql-server-create.png)

5. Back on the Basics tab:

   - **Want to use SQL elastic pool?**: No
   - **Workload environment**: Development
   - **Compute + storage**: select **Configure database** and choose **Basic** tier (5 DTUs)

6. Select **Review + create**, then select **Create**.

   ![](../media/sql-review-create.png)

7. Wait for the deployment to complete (approximately 3 to 5 minutes) and select **Go to resource**.

**Seed sample data into the database**

1. In the Azure portal, open the **contosodb** database.
2. In the left navigation, select **Query editor (preview)**.
3. Sign in using SQL authentication with the credentials created above.
4. Run the following SQL to create sample tables and data:

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

5. Verify the data:

```sql
SELECT COUNT(*) AS product_count FROM Products;
SELECT COUNT(*) AS order_count FROM Orders;
```

Both queries should return 10 rows.

**Configure SQL Server firewall**

1. Navigate to the SQL server `sql-contoso-<inject key="Deployment ID" enableCopy="false"></inject>`.
2. In the left navigation, select **Networking**.
3. Under **Public network access**, select **Selected networks**.
4. Under **Firewall rules**, select **+ Add your client IPv4 address**.
5. Under **Exceptions**, enable **Allow Azure services and resources to access this server**.
6. Select **Save**.

Azure SQL Database is provisioned with sample data.

## Task 4: Set Up and Run the Web Application Locally (On-Premises Simulation)

In this task, you will create the Contoso Retail web application on your local machine. This simulates the on-premises environment that you will migrate to Azure in Exercise 2.

1. Open a **terminal on your local machine** (Command Prompt, PowerShell, or Bash). Do not use Azure Cloud Shell for this task — the app must run on your local machine to simulate on-premises.

2. Clone the sample web application repository:

```bash
git clone https://github.com/contoso/contoso-retail-webapp.git
cd contoso-retail-webapp
```

> Note: If the repository URL above is not available, create the sample application manually using the steps below.

**Create the sample Node.js application manually**

1. Create a new directory:

```bash
mkdir contoso-retail-webapp
cd contoso-retail-webapp
```

2. Initialize the Node.js project:

```bash
npm init -y
```

3. Install dependencies:

```bash
npm install express ejs mssql dotenv
```

4. Create the application files:

**package.json** — update the `scripts` section:

```json
{
  "name": "contoso-retail-webapp",
  "version": "1.0.0",
  "description": "Contoso Retail Web Application",
  "main": "src/app.js",
  "scripts": {
    "start": "node src/app.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "ejs": "^3.1.9",
    "mssql": "^10.0.1",
    "dotenv": "^16.3.1"
  }
}
```

**src/app.js**:

```javascript
const express = require('express');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 8080;

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

const indexRouter = require('./routes/index');
const productsRouter = require('./routes/products');

app.use('/', indexRouter);
app.use('/products', productsRouter);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

**src/config/database.js**:

```javascript
const sql = require('mssql');

const config = {
  server: process.env.DB_SERVER,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    encrypt: true,
    trustServerCertificate: false
  }
};

module.exports = { sql, config };
```

**src/routes/index.js**:

```javascript
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.render('index', { title: 'Contoso Retail' });
});

module.exports = router;
```

**src/routes/products.js**:

```javascript
const express = require('express');
const router = express.Router();
const { sql, config } = require('../config/database');

router.get('/', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query('SELECT * FROM Products');
    res.render('products', { title: 'Products', products: result.recordset });
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).send('Error loading products');
  }
});

module.exports = router;
```

**src/views/index.ejs**:

```html
<!DOCTYPE html>
<html>
<head><title><%= title %></title></head>
<body>
  <h1>Welcome to <%= title %></h1>
  <p>Your one-stop shop for office essentials.</p>
  <a href="/products">View Products</a>
</body>
</html>
```

**src/views/products.ejs**:

```html
<!DOCTYPE html>
<html>
<head><title><%= title %></title></head>
<body>
  <h1><%= title %></h1>
  <a href="/">Home</a>
  <table border="1">
    <tr><th>Name</th><th>Category</th><th>Price</th><th>Stock</th></tr>
    <% products.forEach(p => { %>
    <tr>
      <td><%= p.ProductName %></td>
      <td><%= p.Category %></td>
      <td>$<%= p.Price.toFixed(2) %></td>
      <td><%= p.StockQuantity %></td>
    </tr>
    <% }); %>
  </table>
</body>
</html>
```

5. Create a `.env` file for local testing (do not commit to source control):

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

   > **Important**: If the products page shows an error, verify:
   > - The `.env` file has the correct SQL Server name, database name, and credentials.
   > - Your local machine's IP address is allowed in the SQL Server firewall rules.
   > - Node.js and npm are installed on your machine (`node --version` and `npm --version`).

8. Keep the application running. You now have a web application running on your local machine at `http://localhost:8080` — this is your **on-premises environment** that will be migrated to Azure in Exercise 2.

   > **Migration Preview**: In Exercise 2, you will take this exact application and push it to Azure App Service. The app will then be accessible at `https://contoso-web-<DeploymentID>.azurewebsites.net` instead of `http://localhost:8080`.

The sample web application is running locally and ready for migration.

## Success Criteria

- Resource group `rg-migration-lab` created in the target region.
- Virtual network `vnet-migration-lab` deployed with three subnets (`snet-appservice`, `snet-private`, `snet-default`).
- `snet-appservice` subnet delegated to `Microsoft.Web/serverFarms`.
- Azure SQL Server and Database deployed with sample data (10 products, 10 orders).
- SQL Server firewall configured to allow Azure services and your local IP.
- **Sample web application running locally on `http://localhost:8080`** (on-premises simulation).
- Home page displays "Welcome to Contoso Retail" and Products page shows 10 products from the database.

## Learning Outcomes

- Provision foundational Azure infrastructure including resource groups, virtual networks, and subnets.
- Deploy and configure Azure SQL Database with firewall rules and sample data.
- Understand subnet delegation requirements for Azure App Service VNet integration.
- Prepare a sample Node.js web application for cloud migration.

## References

- Create a resource group: https://learn.microsoft.com/azure/azure-resource-manager/management/manage-resource-groups-portal
- Create a virtual network: https://learn.microsoft.com/azure/virtual-network/quick-create-portal
- Azure SQL Database quickstart: https://learn.microsoft.com/azure/azure-sql/database/single-database-create-quickstart
- App Service VNet integration: https://learn.microsoft.com/azure/app-service/overview-vnet-integration
