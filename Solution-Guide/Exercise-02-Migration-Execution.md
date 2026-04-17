# Exercise 2: Migration Execution (Push Local App to Azure)

## Overview

In this exercise, you will migrate the Contoso Retail web application that is currently running on your local machine (`http://localhost:8080`) to Azure App Service. You will create the App Service infrastructure, push your local application code to Azure, configure networking, and validate that the same application now runs in the cloud at `https://contoso-web-<DeploymentID>.azurewebsites.net`.

> **Before you begin**: Confirm the application is still running locally by opening `http://localhost:8080/products` in your browser. You should see 10 products. If not, go back to Exercise 0, Task 4 and start the application.

## Task 1: Create Azure App Service and App Service Plan

1. In the **Azure portal**, search for **App Services** **(1)** and select **App Services** **(2)** under Services.

   ![](../media/appservice-search.png)

2. In the **App Services** page, select **+ Create** **(1)** and then **Web App** **(2)**.

   ![](../media/appservice-create.png)

3. On the **Basics** tab, provide the following details:

   - **Subscription**: select your Azure subscription **(1)**
   - **Resource group**: `rg-migration-lab` **(2)**
   - **Name**: `contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>` **(3)**
   - **Publish**: Code **(4)**
   - **Runtime stack**: Node 20 LTS **(5)**
   - **Operating system**: Linux **(6)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(7)**

     ![](../media/appservice-basic-1.png)

4. Under **App Service Plan**:

   - Select **Create new** **(1)**
   - **Name**: `asp-contoso-<inject key="Deployment ID" enableCopy="false"></inject>` **(2)**
   - **Pricing plan**: Standard S1 **(3)** (100 total ACU, 1.75 GB memory — supports VNet integration, custom domains, auto-scale, and backups)

     ![](../media/appservice-plan.png)

5. Select **Review + create**, then select **Create**.

   ![](../media/appservice-review-create.png)

6. Wait for the deployment to complete (approximately 2 to 3 minutes) and select **Go to resource**.

   ![](../media/appservice-goto-resource.png)

App Service and App Service Plan are created.

## Task 2: Configure Deployment Strategy

Configure the deployment method for the web application. This lab uses **ZIP deploy via Azure CLI** as the primary method and provides GitHub Actions as an alternative.

**Option A: Configure ZIP Deploy (Primary)**

1. Open **Azure Cloud Shell** (Bash) or a local terminal with Azure CLI installed.

2. Verify Azure CLI is logged in:

```bash
az account show
```

3. Set the subscription context if needed:

```bash
az account set --subscription "<your-subscription-id>"
```

4. Configure the App Service for ZIP deploy:

```bash
az webapp config set \
  --resource-group rg-migration-lab \
  --name contoso-web-<DeploymentID> \
  --startup-file "npm start"
```

**Option B: Configure GitHub Actions CI/CD (Alternative)**

1. In the Azure portal, open **contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>**.
2. In the left navigation, select **Deployment Center**.
3. Under **Source**, select **GitHub**.
4. Authorize Azure to access your GitHub account.
5. Select:
   - **Organization**: your GitHub account
   - **Repository**: `contoso-retail-webapp`
   - **Branch**: `main`
6. Select **Save**.

Azure creates a GitHub Actions workflow file (`.github/workflows/main_contoso-web.yml`) in the repository and triggers the first deployment automatically.

Deployment strategy is configured.

## Task 3: Push Local Application Code to Azure App Service

Now you will take the application running on your local machine and push it to Azure App Service.

**Step 1: Configure Application Settings (Replace the local .env file)**

On your local machine, the application reads database credentials from the `.env` file. On Azure App Service, environment variables replace the `.env` file.

1. In the Azure portal, open **contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>**.
2. In the left navigation, select **Environment variables** (or **Configuration** > **Application settings**).
3. Select **+ Add** for each of the following application settings:

   | Name | Value |
   | --- | --- |
   | `DB_SERVER` | `sql-contoso-<inject key="Deployment ID" enableCopy="false"></inject>.database.windows.net` |
   | `DB_NAME` | `contosodb` |
   | `DB_USER` | `sqladmin` |
   | `DB_PASSWORD` | `P@ssw0rd2026!` |
   | `WEBSITE_NODE_DEFAULT_VERSION` | `~20` |

4. Select **Apply**, then confirm by selecting **Confirm**.

   ![](../media/appservice-app-settings.png)

> Important: In production, use **Azure Key Vault references** instead of storing secrets directly in Application Settings. For this lab, direct settings are used for simplicity. These settings replace the `.env` file that the app used on your local machine.

**Step 2: Package and push the local application to Azure**

1. **Stop the local application** on your machine (press `Ctrl+C` in the terminal where `npm start` is running).

2. In your local terminal, navigate to the application root directory:

```bash
cd contoso-retail-webapp
```

3. Create a ZIP file of your local application (excluding local-only files):

```bash
zip -r contoso-retail-webapp.zip . -x ".env" -x "node_modules/*" -x ".git/*"
```

On Windows PowerShell:

```powershell
Compress-Archive -Path .\* -DestinationPath contoso-retail-webapp.zip -Force
```

> **Note**: The `.env` file is excluded because Azure App Service uses Application Settings instead. The `node_modules` folder is excluded because Azure will run `npm install` during deployment.

4. **Push the ZIP to Azure App Service** using Azure CLI:

```bash
az webapp deploy \
  --resource-group rg-migration-lab \
  --name contoso-web-<DeploymentID> \
  --src-path contoso-retail-webapp.zip \
  --type zip
```

4. Wait for the deployment to complete. The CLI returns a JSON response with `"complete": true` on success.

   ![](../media/appservice-deploy-success.png)

> **What just happened**: Your local application code has been pushed from your machine to Azure App Service. The app that was running on `http://localhost:8080` will now run on `https://contoso-web-<DeploymentID>.azurewebsites.net`.

**Step 3: Enable Always On**

1. In the Azure portal, open the App Service.
2. Select **Configuration** > **General settings**.
3. Set **Always On** to **On**.
4. Select **Save**.

Your local application is now deployed and running on Azure App Service.

## Task 4: Configure App Service Networking

Configure VNet integration and access restrictions to secure the App Service.

**Step 1: Configure VNet integration**

1. In the Azure portal, open **contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>**.
2. In the left navigation, select **Networking**.
3. Under **Outbound traffic**, select **VNet integration**.
4. Select **+ Add VNet integration**.
5. Configure:
   - **Virtual network**: `vnet-migration-lab`
   - **Subnet**: `snet-appservice`
6. Select **Connect**.

   ![](../media/appservice-vnet-integration.png)

7. Verify the status shows **Connected**.

**Step 2: Configure access restrictions**

1. In the **Networking** page, under **Inbound traffic**, select **Access restriction**.
2. Select **+ Add** to create a new rule:

   | Setting | Value |
   | --- | --- |
   | **Name** | `AllowMyIP` |
   | **Action** | Allow |
   | **Priority** | 100 |
   | **Type** | IPv4 |
   | **IP Address Block** | Your current public IP address (find at https://ifconfig.me) |

3. Verify **Unmatched rule action** is set to **Deny** to block all other traffic.
4. Select **Add rule**, then **Save**.

   ![](../media/appservice-access-restrictions.png)

> Note: For production, configure a more comprehensive set of rules including Azure Front Door service tags, corporate VPN ranges, and Azure DevOps build agent IPs.

VNet integration and access restrictions are configured.

## Task 5: Validate the Migration — Compare Local vs Azure

Verify that the application running on Azure App Service behaves exactly the same as it did on your local machine.

1. In the Azure portal, open **contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>**.
2. In the **Overview** page, copy the **Default domain** URL (format: `https://contoso-web-<DeploymentID>.azurewebsites.net`).
3. Open the URL in a browser.
4. Verify the following — each should match what you saw on `http://localhost:8080`:

   | Validation | Local (Before) | Azure (After) |
   | --- | --- | --- |
   | Home page | `http://localhost:8080` showed "Welcome to Contoso Retail" | `https://contoso-web-<DeploymentID>.azurewebsites.net` shows the same |
   | Products page | `http://localhost:8080/products` showed 10 products | `/products` on Azure shows the same 10 products |
   | Database connectivity | Connected via `.env` file | Connected via App Service Application Settings |
   | Protocol | HTTP on port 8080 | HTTPS with automatic TLS certificate |

5. If the application does not load:
   - Check **Diagnose and solve problems** in the App Service left navigation.
   - Review **Log stream** for runtime errors.
   - Verify Application Settings match the values from your local `.env` file.
   - Confirm the SQL Server firewall allows Azure services.

   ![](../media/appservice-running.png)

> **Migration complete**: The Contoso Retail web application has been successfully migrated from your local machine to Azure App Service. The app no longer depends on your local machine — it runs entirely in the cloud.

Application is fully functional on Azure App Service.

Evidence to capture:

- Screenshot of the App Service Overview page showing the running web app.
- Screenshot of the Products page loaded in a browser showing data from Azure SQL.
- Screenshot of VNet integration status showing Connected.

![App Service Overview page showing running status and default domain](../media/ex2-appservice-overview.png)
> Save your screenshot as `media/ex2-appservice-overview.png`

![Products page showing 10 products loaded from Azure SQL Database](../media/ex2-products-page.png)
> Save your screenshot as `media/ex2-products-page.png`

![VNet integration showing Connected status with snet-appservice subnet](../media/ex2-vnet-connected.png)
> Save your screenshot as `media/ex2-vnet-connected.png`

## Success Criteria

- App Service Plan `asp-contoso-<DeploymentID>` created with Standard S1 pricing tier.
- Web App `contoso-web-<DeploymentID>` created with Node.js 20 LTS runtime on Linux.
- Application settings configured with database connection details (replacing the local `.env` file).
- **Local application code packaged and pushed to Azure App Service via ZIP deploy** (or GitHub Actions).
- Always On enabled in General settings.
- VNet integration connected to `snet-appservice` subnet.
- Access restrictions configured with at least one allow rule and default deny.
- **Application on Azure shows the same home page and products data as it did on `http://localhost:8080`**.

## Learning Outcomes

- Create and configure Azure App Service with an appropriate pricing tier and runtime.
- Deploy a Node.js web application using ZIP deploy via Azure CLI.
- Configure Application Settings as a secure alternative to local `.env` files.
- Set up VNet integration for outbound private connectivity.
- Configure inbound access restrictions for defense-in-depth.
- Validate application functionality and troubleshoot common deployment issues.

## References

- Azure App Service overview: https://learn.microsoft.com/azure/app-service/overview
- Deploy to App Service using ZIP: https://learn.microsoft.com/azure/app-service/deploy-zip
- Configure App Service application settings: https://learn.microsoft.com/azure/app-service/configure-common
- App Service VNet integration: https://learn.microsoft.com/azure/app-service/overview-vnet-integration
- App Service access restrictions: https://learn.microsoft.com/azure/app-service/app-service-ip-restrictions
- App Service deployment best practices: https://learn.microsoft.com/azure/app-service/deploy-best-practices
