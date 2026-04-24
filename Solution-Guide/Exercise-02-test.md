# Challenge 2: Migration Execution (Web App Modernization)

## Overview

In this challenge, you execute the migration. You will take the Contoso Retail application running on the Windows Server VM and deploy it to **Azure App Service** — converting it from a locally hosted Node.js process to a fully managed PaaS web application.

By the end of this challenge, you will have:

- A running Azure App Service hosting the Contoso Retail application
- Application settings migrated from the `.env` file to App Service configuration
- HTTPS enforced with an Azure-managed TLS certificate
- VNet integration configured for private outbound connectivity
- Application Insights connected and receiving live telemetry

> **Note**: All steps are performed in **PowerShell on your Windows Server VM** via RDP, or in the **Azure portal**. Keep the same PowerShell window open from Challenge 1 — your session variables are still needed.

**Estimated Duration**: 75 minutes

**Prerequisites**:
- Challenge 1 completed — Landing Zone provisioned, `C:\apps\migration-strategy.txt` saved
- PowerShell session variables from Challenge 1 still set (`$APP_NAME`, `$RG_APP`, etc.)
- Contoso Retail app files at `C:\apps\contoso-retail`

> **If you opened a new PowerShell window**, re-run the variables block from Challenge 1, Task 3, Step 2 before continuing.

---

## Task 1: Create Monitoring and App Service Resources

In this task, you provision the Application Insights workspace and the App Service infrastructure. Monitoring is created first so it is ready to receive telemetry the moment the application is deployed.

All steps use **Azure CLI from PowerShell on the VM**.

**Create Application Insights**

1. Install the Application Insights CLI extension if not already present:

   ```powershell
   az extension add --name application-insights --only-show-errors
   ```

2. Create the Log Analytics Workspace:

   ```powershell
   az monitor log-analytics workspace create `
     --resource-group $RG_APP `
     --workspace-name $LAW_NAME `
     --location $LOCATION `
     --tags Environment=Lab Project=ContosoMigration
   ```

3. Retrieve the workspace resource ID:

   ```powershell
   $LAW_ID = az monitor log-analytics workspace show `
     --resource-group $RG_APP `
     --workspace-name $LAW_NAME `
     --query id `
     --output tsv

   Write-Host "Workspace ID: $LAW_ID" -ForegroundColor Cyan
   ```

4. Create Application Insights linked to the workspace:

   ```powershell
   az monitor app-insights component create `
     --app $AI_NAME `
     --resource-group $RG_APP `
     --location $LOCATION `
     --kind web `
     --workspace $LAW_ID `
     --tags Environment=Lab Project=ContosoMigration
   ```

5. Retrieve and save the instrumentation key:

   ```powershell
   $AI_KEY = az monitor app-insights component show `
     --app $AI_NAME `
     --resource-group $RG_APP `
     --query instrumentationKey `
     --output tsv

   Write-Host "Instrumentation Key: $AI_KEY" -ForegroundColor Yellow
   ```

**Create the App Service Plan**

6. Create the App Service Plan (Standard S1 — supports VNet integration and custom domains):

   ```powershell
   az appservice plan create `
     --name $APP_PLAN_NAME `
     --resource-group $RG_APP `
     --location $LOCATION `
     --sku S1 `
     --is-linux `
     --tags Environment=Lab Project=ContosoMigration
   ```

   > **Note**: `--is-linux` is required for the Node.js runtime on App Service. Standard S1 is the minimum tier that supports VNet integration.

**Create the App Service**

7. Create the App Service with Node.js 20 runtime:

   ```powershell
   az webapp create `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --plan $APP_PLAN_NAME `
     --runtime "NODE:20-lts" `
     --tags Environment=Lab Project=ContosoMigration
   ```

8. Confirm the App Service was created and note the default hostname:

   ```powershell
   az webapp show `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --query "{Name:name, State:state, URL:defaultHostName}" `
     --output table
   ```

   Expected output: State = `Running`, URL = `app-contoso-<DeploymentID>.azurewebsites.net`.

   ![](../media/webapp-created-verify.png)

All App Service resources are provisioned.

---

## Task 2: Configure Application Settings

In this task, you migrate the application's configuration from the `.env` file on the VM to **App Service Application Settings**. This is a critical security step — the `.env` file must never be deployed to App Service.

All steps use **Azure CLI from PowerShell on the VM**.

1. Set all application settings in a single command:

   ```powershell
   az webapp config appsettings set `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --settings `
       DB_SERVER="$SQL_SERVER.database.windows.net" `
       DB_NAME="contosodb" `
       DB_USER="sqladmin" `
       DB_PASSWORD="P@ssw0rd2026!" `
       PORT="8080" `
       APPINSIGHTS_INSTRUMENTATIONKEY="$AI_KEY" `
       WEBSITE_NODE_DEFAULT_VERSION="~20"
   ```

2. Verify all settings are saved correctly:

   ```powershell
   az webapp config appsettings list `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --output table
   ```

   Confirm all seven settings are listed — `DB_SERVER`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `PORT`, `APPINSIGHTS_INSTRUMENTATIONKEY`, and `WEBSITE_NODE_DEFAULT_VERSION`.

   ![](../media/appsettings-verify.png)

   > **Note**: App Service Application Settings are injected as environment variables at runtime. The `process.env.DB_SERVER` calls in the application code will read these values automatically — no code changes needed.

3. Enforce HTTPS-only so all HTTP traffic is redirected to HTTPS:

   ```powershell
   az webapp update `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --https-only true
   ```

4. Set the startup command so App Service knows how to start the Node.js application:

   ```powershell
   az webapp config set `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --startup-file "node src/app.js"
   ```

Application settings are configured and HTTPS is enforced.

---

## Task 3: Package and Deploy the Application

In this task, you create a deployment zip from the application files on the VM and push it to App Service using zip deploy. The `.env` file is explicitly excluded from the package.

All steps use **PowerShell on the VM**.

1. Navigate to the application directory:

   ```powershell
   Set-Location "C:\apps\contoso-retail"
   ```

2. Create the deployment package. This zips all application files and explicitly excludes `.env` and `node_modules`:

   ```powershell
   # Remove any previous deployment zip
   Remove-Item "C:\apps\contoso-retail-deploy.zip" -ErrorAction SilentlyContinue

   # Get all files excluding .env and node_modules
   $files = Get-ChildItem -Path "C:\apps\contoso-retail" -Recurse |
     Where-Object {
       $_.FullName -notmatch "node_modules" -and
       $_.FullName -notmatch "\.env$" -and
       -not $_.PSIsContainer
     }

   # Create the zip
   Compress-Archive -Path $files.FullName -DestinationPath "C:\apps\contoso-retail-deploy.zip" -Force

   Write-Host "Deployment package created: C:\apps\contoso-retail-deploy.zip" -ForegroundColor Green
   Get-Item "C:\apps\contoso-retail-deploy.zip" | Select-Object Name, Length
   ```

   > **Important**: Confirm the zip size is greater than 0 bytes before proceeding. If `Length` shows 0, re-run the compress command.

3. Deploy the zip package to App Service:

   ```powershell
   az webapp deploy `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --src-path "C:\apps\contoso-retail-deploy.zip" `
     --type zip
   ```

   This command uploads the package and triggers a deployment. It takes approximately 1–2 minutes.

   ![](../media/zip-deploy-complete.png)

4. Check the deployment status:

   ```powershell
   az webapp deployment list-publishing-credentials `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --query "{Name:name, ScmUri:scmUri}" `
     --output table
   ```

   > **Note**: App Service automatically runs `npm install` on the server after receiving the zip — your `node_modules` folder is built in the cloud, not deployed from the VM.

The application is deployed to Azure App Service.

---

## Task 4: Configure App Service Networking

In this task, you configure VNet integration so the App Service can communicate privately with resources inside the virtual network, and add access restrictions to control inbound traffic.

All steps use **Azure CLI from PowerShell on the VM**.

**Enable VNet Integration**

1. Enable regional VNet integration using the `snet-appservice` subnet created in Exercise 0:

   ```powershell
   $SUBNET_ID = az network vnet subnet show `
     --resource-group $RG_CORE `
     --vnet-name $VNET_NAME `
     --name snet-appservice `
     --query id `
     --output tsv

   az webapp vnet-integration add `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --vnet $VNET_NAME `
     --subnet $SUBNET_ID
   ```

2. Verify the VNet integration is active:

   ```powershell
   az webapp vnet-integration list `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --output table
   ```

   Confirm `snet-appservice` is listed with a `Connected` state.

   ![](../media/vnet-integration-verify.png)

   > **Note**: VNet integration enables the App Service to make **outbound** calls to private resources (such as a future Private Endpoint on Azure SQL). It does not affect inbound access to the App Service.

**Configure Access Restrictions**

3. Add an access restriction to allow traffic only from the Azure Front Door and Application Gateway service tags — this is a best practice for production web apps. For this lab, you will allow all internet traffic but add the rule structure for learning purposes:

   ```powershell
   az webapp config access-restriction add `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --rule-name "Allow-AzureFrontDoor" `
     --action Allow `
     --priority 100 `
     --service-tag AzureFrontDoor.Backend
   ```

4. Verify the access restriction is applied:

   ```powershell
   az webapp config access-restriction show `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --output table
   ```

   ![](../media/access-restriction-verify.png)

App Service networking is configured.

---

## Task 5: Validate the Migrated Application

In this task, you confirm the application is running correctly on Azure App Service, the database connection is working, and Application Insights is receiving telemetry.

**Verify the application URL**

1. Retrieve the application URL:

   ```powershell
   $APP_URL = az webapp show `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --query defaultHostName `
     --output tsv

   Write-Host "Application URL: https://$APP_URL" -ForegroundColor Cyan
   ```

2. Open **Microsoft Edge** on the VM and navigate to `https://<APP_URL>` using the URL from step 1.

   Verify the following:

   | Page | URL | Expected Result |
   | --- | --- | --- |
   | Home page | `https://app-contoso-<ID>.azurewebsites.net` | Shows "Welcome to Contoso Retail" |
   | Products page | `https://app-contoso-<ID>.azurewebsites.net/products` | Shows 10 products from Azure SQL |
   | HTTPS redirect | `http://app-contoso-<ID>.azurewebsites.net` | Automatically redirects to HTTPS |

   ![](../media/app-azure-home.png)

   ![](../media/app-azure-products.png)

   > **If the products page returns an error**:
   > - In the Azure portal, navigate to your App Service → **Configuration** → confirm all six App Settings are present
   > - Navigate to the SQL Server → **Networking** → enable **Allow Azure services and resources to access this server** and select **Save**
   > - Wait 1–2 minutes and refresh the page

**Verify Application Insights telemetry**

3. Generate some traffic by refreshing the home and products pages 3–4 times.

4. In the **Azure portal**, navigate to **Resource groups** → `rg-migration-lab-app` → select `ai-contoso-<DeploymentID>`.

5. In the Application Insights overview, select **Live Metrics** from the left navigation.

   Confirm incoming requests are visible in the live stream.

   ![](../media/app-insights-live.png)

6. Select **Transaction search** from the left navigation and confirm page request events are appearing for `/` and `/products`.

   ![](../media/app-insights-transactions.png)

**Run a final post-migration comparison**

7. Run the following from PowerShell to summarise the before and after state:

   ```powershell
   Write-Host "=== MIGRATION SUMMARY ===" -ForegroundColor Cyan
   Write-Host ""
   Write-Host "BEFORE (On-Premises VM):" -ForegroundColor Yellow
   Write-Host "  URL      : http://localhost:8080"
   Write-Host "  Protocol : HTTP (no TLS)"
   Write-Host "  Runtime  : Node.js on Windows Server VM"
   Write-Host "  Config   : .env file on disk"
   Write-Host "  Monitoring: None"
   Write-Host ""
   Write-Host "AFTER (Azure App Service):" -ForegroundColor Green
   $APP_URL = az webapp show --name $APP_NAME --resource-group $RG_APP --query defaultHostName --output tsv
   Write-Host "  URL      : https://$APP_URL"
   Write-Host "  Protocol : HTTPS (Azure-managed TLS)"
   Write-Host "  Runtime  : Node.js on Azure App Service (PaaS)"
   Write-Host "  Config   : App Service Application Settings"
   Write-Host "  Monitoring: Application Insights ($AI_NAME)"
   Write-Host ""
   Write-Host "Migration Status: COMPLETE" -ForegroundColor Green
   ```

   ![](../media/migration-summary.png)

The application is fully migrated and running on Azure App Service.

---

## Success Criteria

- Log Analytics Workspace `law-contoso-<DeploymentID>` deployed in `rg-migration-lab-app`.
- Application Insights `ai-contoso-<DeploymentID>` deployed and linked to the workspace.
- App Service Plan `asp-contoso-<DeploymentID>` created at Standard S1 tier.
- App Service `app-contoso-<DeploymentID>` created with Node.js 20 LTS runtime.
- All application settings configured — `DB_SERVER`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `PORT`, `APPINSIGHTS_INSTRUMENTATIONKEY`.
- HTTPS-only enforced — HTTP requests redirect to HTTPS.
- Startup command set to `node src/app.js`.
- Deployment zip created without `.env` and `node_modules`.
- Application deployed via zip deploy — home page and products page load correctly at the `azurewebsites.net` URL.
- VNet integration active on `snet-appservice`.
- Application Insights receiving live request telemetry.

---

## Learning Outcomes

- Provision Azure App Service Plan and Web App via Azure CLI.
- Migrate application configuration from a `.env` file to App Service Application Settings.
- Package a Node.js application and deploy it using zip deploy.
- Configure App Service VNet integration for private outbound connectivity.
- Validate a migrated web application end-to-end including database connectivity and live monitoring.

---

## References

- Azure App Service overview: https://learn.microsoft.com/azure/app-service/overview
- App Service VNet integration: https://learn.microsoft.com/azure/app-service/overview-vnet-integration
- Deploy a zip file to App Service: https://learn.microsoft.com/azure/app-service/deploy-zip
- App Service Application Settings: https://learn.microsoft.com/azure/app-service/configure-common
- Application Insights for Node.js: https://learn.microsoft.com/azure/azure-monitor/app/nodejs
- App Service access restrictions: https://learn.microsoft.com/azure/app-service/app-service-ip-restrictions