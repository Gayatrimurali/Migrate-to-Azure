## Web Application Migration to Azure

### Estimated Time: 360 Minutes

## Introduction

Welcome to the capstone challenge. In this lab, you will execute a full migration lifecycle for a web application that is currently running on your local machine (simulating an on-premises environment) and migrate it to Azure App Service, following the Microsoft Cloud Adoption Framework (CAF).

You will first set up and run the web application locally on your machine, verify it works end-to-end with a database, and then plan and execute the migration to push it into Azure. After migration, you will configure hybrid connectivity, implement disaster recovery, and apply governance and security controls.

Modern enterprises are accelerating their cloud journeys by migrating on-premises workloads to Azure. However, successful migration requires more than lifting and shifting — it demands structured planning using the Cloud Adoption Framework, proper landing zone design, application modernization, hybrid connectivity for remaining on-premises components, disaster recovery planning, and robust governance and security enforcement.

In this capstone, your local machine acts as the on-premises server. You will build the application, run it locally on `http://localhost:8080`, confirm it connects to the database and serves data, and then migrate it to Azure App Service — just like a real-world migration from an on-premises data center to the cloud.

## Migration Architecture

The migration architecture for this capstone includes the following capabilities:

| Migration Capability | Purpose |
| --- | --- |
| Migration Design (CAF) | Assess workloads and define a PaaS-first migration strategy |
| Migration Execution | Migrate the web application to Azure App Service |
| Hybrid & Disaster Recovery | Establish hybrid connectivity and failover readiness |
| Governance & Security | Enforce compliance, RBAC, monitoring, and endpoint security |

## Challenge Objectives

By completing this challenge, you will:

- Analyze the existing on-premises web application and its dependencies.
- Define a Rehost / PaaS-first migration strategy using CAF.
- Design and deploy an Azure Landing Zone architecture.
- Migrate the web application to Azure App Service.
- Configure networking, deployment, and application settings.
- Implement hybrid connectivity using Azure Arc (if applicable).
- Configure backup, recovery, and regional failover strategies.
- Apply Azure Policies, RBAC, Microsoft Defender for Cloud, and Azure Monitor.
- Secure application endpoints with HTTPS and access restrictions.

## Sandbox Environment

Participants should have access to:

- An Azure subscription with Owner or Contributor access
- A simulated on-premises web application (Node.js — provided as a sample repository)
- Azure CLI and Azure PowerShell installed locally or in Azure Cloud Shell
- Visual Studio Code with Azure App Service extension

Resource placement used in this challenge:

| Resource | Platform | Status |
| --- | --- | --- |
| Contoso Retail Web App (Node.js) | Local machine (simulating on-premises) | Running on `http://localhost:8080` before migration |
| Azure SQL Database (contosodb) | Azure (pre-provisioned) | Database is already in Azure — app connects to it locally |
| Virtual Network (vnet-migration-lab) | Azure (pre-provisioned) | Ready for App Service VNet integration after migration |

> **Migration Flow**: Local machine (localhost:8080) → Azure App Service (*.azurewebsites.net)

## Pre-Provisioned Resources

The following resources are pre-provisioned in your lab environment:

| Resource | Name | Purpose |
| --- | --- | --- |
| Resource Group | `rg-migration-lab` | Contains all lab resources |
| Azure SQL Server | `sql-contoso-<DeploymentID>` | Database server for the web app |
| Azure SQL Database | `contosodb` | Application database with sample data |
| Virtual Network | `vnet-migration-lab` | Network for VNet integration |
| Subnet (App Service) | `snet-appservice` | Delegated subnet for App Service VNet integration |
| Subnet (Private Endpoints) | `snet-private` | Subnet for private endpoints |

## Sample Application Source Code

Use the following source files to create the on-premises web application for migration.

### Where to Create the Application

Create the application on your **local machine** to simulate the on-premises environment:

1. Open a terminal (Command Prompt, PowerShell, or Bash) on your local machine.
2. Create a new directory: `mkdir contoso-retail-webapp && cd contoso-retail-webapp`.
3. Initialize the Node.js project: `npm init -y`.
4. Install dependencies: `npm install express ejs mssql dotenv`.
5. Create the file structure using the source code below.
6. After creating all files, run `npm start` to start the application.
7. Open a browser and go to `http://localhost:8080` — verify the home page loads.
8. Navigate to `http://localhost:8080/products` — verify 10 products appear from the database.

> **Important**: The application **must** be running and verified on your local machine before you proceed to any migration exercise. This local setup simulates your on-premises environment. The migration in Exercise 2 will take this locally running app and push it to Azure App Service.

### Application Entry Point (src/app.js)

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

### Database Configuration (src/config/database.js)

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

### Routes (src/routes/index.js)

```javascript
const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.render('index', { title: 'Contoso Retail' });
});

module.exports = router;
```

### Routes (src/routes/products.js)

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

### Views (src/views/index.ejs)

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

### Views (src/views/products.ejs)

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

### Environment File (.env — do not commit to source control)

```
DB_SERVER=sql-contoso-<DeploymentID>.database.windows.net
DB_NAME=contosodb
DB_USER=sqladmin
DB_PASSWORD=P@ssw0rd2026!
PORT=8080
```

### Package Configuration (package.json)

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

## Sample Database Seed Data

Run the following script in the Azure portal **Query editor** for the `contosodb` database to populate sample data.

### Where to Run the Database Script

1. Open the **Azure portal**.
2. Navigate to **SQL databases** and select `contosodb`.
3. Select **Query editor (preview)** in the left navigation.
4. Sign in with SQL authentication (`sqladmin` / `P@ssw0rd2026!`).
5. Paste and run the script below.

### Database Seed Script (Azure SQL)

```sql
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
```

### Quick Validation Queries

Run in the Azure SQL Query editor:

```sql
SELECT COUNT(*) AS product_count FROM Products;
SELECT COUNT(*) AS order_count FROM Orders;
```

Each table returns 10 rows and the database is ready for the web application.

### Run and Verify the Application Locally (On-Premises Simulation)

This is a critical step. The application must be running on your local machine before migration.

1. Open a terminal in the `contoso-retail-webapp` directory.
2. Start the application:
   ```bash
   npm start
   ```
3. You should see: `Server running on port 8080`.
4. Open a browser and navigate to `http://localhost:8080`.
5. Verify the home page displays **"Welcome to Contoso Retail"**.
6. Click **"View Products"** or navigate to `http://localhost:8080/products`.
7. Verify **10 products** appear in a table with Name, Category, Price, and Stock columns.
8. Keep the application running — this confirms your on-premises environment is ready.

> **Tip**: If the products page shows an error, verify your `.env` file has the correct Azure SQL connection details and that your IP address is allowed in the SQL Server firewall rules.

> **What happens next**: In Exercise 2, you will take this exact application — currently running on `localhost:8080` — and push it to Azure App Service so it runs on `https://contoso-web-<DeploymentID>.azurewebsites.net` instead.

---

# Exercise 1: Migration Design (CAF)

Now that the Contoso Retail web application is running locally on `http://localhost:8080`, you will assess it and plan the migration to Azure.

## Task 1: Analyze Existing Application Environment

1. Open the application source code that is running on your local machine.
2. Review `src/app.js` to identify the application runtime and framework (Express.js on Node.js, listening on port 8080).
3. Review `src/config/database.js` to identify the database dependency (Azure SQL via mssql package, connection configured through environment variables).
4. Review `src/routes/products.js` to identify the data access pattern (direct SQL query to Products table).
5. Document the application inventory:
   - Application name, runtime, framework version
   - Database type and connection method
   - External dependencies
   - Current hosting platform (on-prem IIS / PM2)
   - Availability and performance requirements
6. Assess migration readiness factors: cloud compatibility, statefulness, dependency complexity, and configuration management.

Application assessment is documented.

## Task 2: Define Migration Strategy

1. Evaluate the Cloud Adoption Framework 5 Rs (Rehost, Refactor, Rearchitect, Rebuild, Replace) against the application profile.
2. For each strategy, document whether it is a good fit and why.
3. Select the most appropriate strategy.
   - Hint: The application is stateless, uses a standard runtime, and requires minimal changes — a PaaS-first approach is the best fit.
4. Document the selected strategy including:
   - Target platform (Azure App Service — Linux, Node.js 20 LTS)
   - App Service Plan SKU (Standard S1 for production features)
   - Deployment method (ZIP deploy or GitHub Actions)
   - Estimated migration effort

Migration strategy is defined.

## Task 3: Design Azure Landing Zone Architecture

1. Identify the target architecture components:
   - Compute: Azure App Service
   - Data: Azure SQL Database
   - Networking: VNet with delegated subnets
   - Monitoring: Azure Monitor + Application Insights
   - Security: Microsoft Defender for Cloud + Azure Policy
   - Identity: Managed Identity + Microsoft Entra ID
2. Design the resource organization: subscription, resource group, naming conventions.
3. Design the network topology: VNet address space, subnet delegation for App Service, private endpoint subnet.
4. Design the identity model: Managed Identity for Azure SQL access, RBAC for team access.
5. Create an architecture diagram showing all components and their relationships.

Landing zone architecture is designed.

## Task 4: Identify Dependencies

1. Map all application dependencies:
   - Azure SQL Database connection string
   - Node.js 20 LTS runtime
   - npm packages (express, ejs, mssql, dotenv)
   - Port configuration (8080 → 80/443)
   - DNS resolution (on-prem hostname → `*.azurewebsites.net`)
2. Document migration actions for each dependency:
   - Connection strings → App Service Application Settings
   - Runtime → Built-in App Service Node.js stack
   - Port → App Service handles port binding automatically
3. Identify risks and mitigations:
   - Database connectivity failure → VNet integration
   - Cold start latency → Always On setting
   - Data loss → Automated backups + geo-restore

Dependency matrix is complete.

---

# Exercise 2: Migration Execution (Push Local App to Azure)

In this exercise, you will take the Contoso Retail web application that is currently running on your local machine (`http://localhost:8080`) and migrate it to Azure App Service. After this exercise, the same application will be accessible at `https://contoso-web-<DeploymentID>.azurewebsites.net`.

> **Before you begin**: Confirm the application is still running locally by opening `http://localhost:8080/products` in your browser. You should see 10 products.

## Task 1: Create Azure App Service and App Service Plan

1. Open the Azure portal.
2. Search for **App Services** and select it.
3. Select **+ Create** > **Web App**.
4. Enter the configuration details:
   - Resource group: `rg-migration-lab`
   - Name: `contoso-web-<DeploymentID>`
   - Publish: Code
   - Runtime stack: Node 20 LTS
   - Operating system: Linux
   - Region: your lab region
5. Create a new App Service Plan:
   - Name: `asp-contoso-<DeploymentID>`
   - Pricing plan: Standard S1
6. Select **Review + create**, then **Create**.

App Service and App Service Plan are provisioned.

## Task 2: Configure Deployment Strategy

1. Open **Azure Cloud Shell** (Bash) or a local terminal with Azure CLI.
2. Verify Azure CLI is logged in: `az account show`.
3. Configure the App Service startup command:
   ```bash
   az webapp config set \
     --resource-group rg-migration-lab \
     --name contoso-web-<DeploymentID> \
     --startup-file "npm start"
   ```
4. Alternatively, configure GitHub Actions CI/CD via **Deployment Center** in the Azure portal:
   - Source: GitHub
   - Repository: your application repository
   - Branch: main

Deployment strategy is configured.

## Task 3: Push Local Application Code to Azure App Service

Now you will package the application from your local machine and push it to Azure App Service.

1. **Stop the local application** (press `Ctrl+C` in the terminal where `npm start` is running).

2. Configure Application Settings in the Azure portal so the app connects to the same database:
   - Open the App Service > **Environment variables**.
   - Add the following settings (these replace the `.env` file your app used locally):

   | Name | Value |
   | --- | --- |
   | `DB_SERVER` | `sql-contoso-<DeploymentID>.database.windows.net` |
   | `DB_NAME` | `contosodb` |
   | `DB_USER` | `sqladmin` |
   | `DB_PASSWORD` | `P@ssw0rd2026!` |
   | `WEBSITE_NODE_DEFAULT_VERSION` | `~20` |

   - Select **Apply**.

   > **Note**: On your local machine, the app read these values from the `.env` file. On Azure App Service, environment variables replace the `.env` file. In production, use Azure Key Vault references instead of storing secrets directly.

3. **Package the local application** for deployment. Open a terminal in the `contoso-retail-webapp` directory:

   On Linux/Mac/Cloud Shell:
   ```bash
   zip -r contoso-retail-webapp.zip . -x ".env" -x "node_modules/*" -x ".git/*"
   ```

   On Windows PowerShell:
   ```powershell
   Compress-Archive -Path .\* -DestinationPath contoso-retail-webapp.zip -Force
   ```

   > **Important**: Exclude the `.env` file (secrets are now in App Service settings) and `node_modules` (Azure will run `npm install` during deployment).

4. **Push the ZIP to Azure App Service** using Azure CLI:
   ```bash
   az webapp deploy \
     --resource-group rg-migration-lab \
     --name contoso-web-<DeploymentID> \
     --src-path contoso-retail-webapp.zip \
     --type zip
   ```

5. Enable **Always On** in App Service > **Configuration** > **General settings** (prevents the app from going idle).

Your local application code is now deployed to Azure App Service.

## Task 4: Configure App Service Networking

1. In the Azure portal, open the App Service.
2. Select **Networking** in the left navigation.
3. Under **Outbound traffic**, select **VNet integration**.
4. Select **+ Add VNet integration**:
   - Virtual network: `vnet-migration-lab`
   - Subnet: `snet-appservice`
5. Verify the status shows **Connected**.
6. Under **Inbound traffic**, select **Access restriction**.
7. Add a rule to allow your IP address:
   - Name: `AllowMyIP`
   - Action: Allow
   - Priority: 100
   - IP Address Block: your public IP (find at https://ifconfig.me)
8. Set **Unmatched rule action** to **Deny**.

VNet integration and access restrictions are configured.

## Task 5: Validate the Migration — Compare Local vs Azure

1. Copy the App Service **Default domain** URL from the Overview page (format: `https://contoso-web-<DeploymentID>.azurewebsites.net`).
2. Open the URL in a browser.
3. Verify the home page loads with **"Welcome to Contoso Retail"** — the same page you saw on `localhost:8080`.
4. Navigate to `/products` and verify **10 products** appear in a table — the same data you saw locally.
5. Confirm HTTPS is active in the browser address bar (Azure App Service provides HTTPS automatically).
6. **Compare**: The application that was running on `http://localhost:8080` is now running on `https://contoso-web-<DeploymentID>.azurewebsites.net` with the same functionality.
7. If the application does not load:
   - Check **Log stream** for runtime errors.
   - Verify Application Settings match the values from your local `.env` file.
   - Confirm the SQL Server firewall allows Azure services.

> **Migration complete**: The Contoso Retail web application has been successfully migrated from your local machine to Azure App Service. The app is no longer dependent on your local machine — it runs entirely in the cloud.

Application is fully functional on Azure App Service.

---

# Exercise 3: Hybrid & Disaster Recovery

## Task 1: Configure Hybrid Connectivity (Azure Arc)

1. Open Azure Cloud Shell or a local terminal.
2. Register the required resource providers:
   ```bash
   az provider register --namespace Microsoft.HybridCompute
   az provider register --namespace Microsoft.GuestConfiguration
   az provider register --namespace Microsoft.HybridConnectivity
   ```
3. Verify registration: `az provider show --namespace Microsoft.HybridCompute --query "registrationState" -o tsv`.
4. In the Azure portal, search for **Azure Arc**.
5. Select **Machines** > **+ Add/Create** > **Add a machine**.
6. Select **Generate script** for a single server.
7. Configure:
   - Resource group: `rg-migration-lab`
   - Region: your lab region
   - Operating system: Linux or Windows
8. Download and run the onboarding script on the target server.
9. Verify the server appears in Azure Arc > Machines with status **Connected**.

Note:
If no on-premises server is available, document the Arc onboarding process as part of the migration design and proceed to Task 2. Azure Arc registration is conceptual in this scenario.

Hybrid connectivity is configured.

## Task 2: Configure Backup and Recovery Strategy

1. Create a storage account for App Service backups:
   ```bash
   az storage account create \
     --name stgbackup<DeploymentID> \
     --resource-group rg-migration-lab \
     --location <Region> \
     --sku Standard_LRS
   ```
2. Create a blob container: `appservice-backups`.
3. Generate a SAS URL for the backup container with read/write/delete/list permissions.
4. In the Azure portal, open the App Service.
5. Select **Backups** in the left navigation.
6. Select **Configure** and set up:
   - Backup storage: the storage account and container created above
   - Scheduled backup: On
   - Frequency: Every 1 day
   - Retention: 30 days
   - Include database: Yes (add the Azure SQL connection string)
7. Select **Save**.
8. Select **Backup now** to run a manual backup and verify it shows **Succeeded**.

Tip:
Azure SQL Database performs automated backups by default. For the Basic tier, point-in-time restore is available for the last 7 days.

App Service backup and Azure SQL backup are configured.

## Task 3: Implement Regional Failover Strategy

1. Create a secondary App Service in a paired Azure region:
   - Create a new resource group in the secondary region.
   - Create a secondary App Service Plan (S1, Linux).
   - Create a secondary Web App with Node 20 LTS.
   - Deploy the same application code and settings.
2. In the Azure portal, search for **Traffic Manager profiles**.
3. Select **+ Create** and configure:
   - Name: `tm-contoso-<DeploymentID>`
   - Routing method: **Priority** (primary/secondary failover)
   - Resource group: `rg-migration-lab`
4. Add the **primary endpoint**:
   - Type: Azure endpoint
   - Target: `contoso-web-<DeploymentID>`
   - Priority: 1
5. Add the **secondary endpoint**:
   - Type: Azure endpoint
   - Target: `contoso-web-secondary-<DeploymentID>`
   - Priority: 2
6. Configure health monitoring:
   - Protocol: HTTPS
   - Port: 443
   - Path: `/`
   - Probing interval: 10 seconds

Traffic Manager is configured with priority-based failover.

## Task 4: Validate Failover Readiness

1. Open the Traffic Manager DNS name in a browser: `http://tm-contoso-<DeploymentID>.trafficmanager.net`.
2. Verify the application loads (routed to primary endpoint).
3. Check both endpoints show **Online** in the Traffic Manager profile.
4. Optionally simulate failover:
   - Stop the primary App Service: `az webapp stop --resource-group rg-migration-lab --name contoso-web-<DeploymentID>`.
   - Wait 30 to 60 seconds for Traffic Manager to detect the failure.
   - Refresh the Traffic Manager URL — traffic routes to secondary.
   - Restart the primary: `az webapp start --resource-group rg-migration-lab --name contoso-web-<DeploymentID>`.
5. Document the failover test results.

Failover readiness is validated.

---

# Exercise 4: Governance & Security

## Task 1: Apply Azure Policies for App Service Compliance

1. In the Azure portal, search for **Policy**.
2. Select **Assignments** > **Assign policy**.
3. Assign the following built-in policies scoped to `rg-migration-lab`:

| Policy Definition | Assignment Name |
| --- | --- |
| App Service apps should use HTTPS | Enforce HTTPS on App Services |
| App Service apps should use the latest TLS version | Enforce latest TLS version |
| App Service apps should have remote debugging turned off | Disable remote debugging |
| App Service app slots should have resource logs enabled | Enable resource logging |

4. For each policy, set the scope to `rg-migration-lab`.
5. Add a non-compliance message for each.
6. Select **Review + create**, then **Create**.
7. Navigate to **Policy** > **Compliance** and review the compliance state.

Note:
Policy compliance evaluation can take up to 30 minutes for the initial scan.

Azure Policies are assigned and compliance is being evaluated.

## Task 2: Configure RBAC for Application Access

1. In Microsoft Entra ID, create a security group named `AppServiceOperators`.
2. Add lab user accounts that should have operational access.
3. Open `rg-migration-lab` > **Access control (IAM)**.
4. Assign the following RBAC roles:

| Role | Assignee | Purpose |
| --- | --- | --- |
| Website Contributor | `AppServiceOperators` group | Manage App Service resources |
| Reader | All lab participants | View resources |
| SQL DB Contributor | Database administrator | Manage Azure SQL |
| Monitoring Contributor | `AppServiceOperators` group | Configure monitoring |

5. For each role: select **+ Add** > **Add role assignment** > select the role > assign to the group/user > **Review + assign**.
6. Verify all role assignments appear in the **Role assignments** tab.

RBAC is configured with least-privilege access.

## Task 3: Enable Microsoft Defender for Cloud and Azure Monitor

1. In the Azure portal, search for **Microsoft Defender for Cloud**.
2. Select **Environment settings** and select your subscription.
3. Enable the following Defender plans:
   - Defender for App Service: On
   - Defender for Azure SQL: On
   - Defender for Resource Manager: On
4. Select **Save**.
5. Search for **Application Insights** and create a new resource:
   - Name: `ai-contoso-<DeploymentID>`
   - Resource group: `rg-migration-lab`
   - Region: your lab region
6. Copy the **Connection String** from the Application Insights Overview page.
7. Open the App Service > **Application Insights** > **Turn on Application Insights**.
8. Select the Application Insights resource created above.
9. Select **Apply**.
10. Create an alert rule in the App Service > **Alerts** > **+ Create** > **Alert rule**:
    - Signal: Http Server Errors (5xx)
    - Threshold: Greater than 5
    - Action group: create with email notification
    - Alert name: `High 5xx Error Rate`

Defender for Cloud and Azure Monitor are configured.

## Task 4: Secure Application Endpoints

1. Open the App Service > **Configuration** > **General settings**.
2. Set **HTTPS Only** to **On**.
3. Set **Minimum TLS Version** to **1.2**.
4. Set **Remote debugging** to **Off**.
5. Select **Save**.
6. Verify HTTPS enforcement: navigate to `http://contoso-web-<DeploymentID>.azurewebsites.net` and confirm it redirects to HTTPS.
7. Review **Networking** > **Access restriction** and verify:
   - At least one Allow rule exists.
   - Default unmatched rule action is **Deny**.
8. Run a final security validation:

| Check | Expected |
| --- | --- |
| HTTPS Only | On |
| Minimum TLS | 1.2 |
| Remote debugging | Off |
| Access restrictions | Allow rule + default Deny |
| VNet integration | Connected |
| Defender for App Service | On |
| Application Insights | Connected |
| Alert rule | Active |
| Azure Policies | 4 assigned |
| RBAC | 4 roles assigned |

All security and governance controls are in place.

## Quick Final Validation

After completing all exercises, your environment should include:

- A fully functional Contoso Retail web application running on Azure App Service
- App Service Plan configured with Standard S1 SKU
- VNet integration connected to `snet-appservice`
- Access restrictions with at least one allow rule and default deny
- Automated App Service backups configured (daily, 30-day retention)
- Traffic Manager with primary and secondary endpoints in priority failover mode
- Four Azure Policies assigned and compliance evaluated
- RBAC roles assigned for least-privilege access
- Microsoft Defender for Cloud enabled for App Service, SQL, and Resource Manager
- Application Insights connected with an alert rule for 5xx errors
- HTTPS enforced with TLS 1.2 minimum
