# Challenge 2: Migration Execution (Web App Modernization)

## Overview

In this challenge, you execute the migration. You will take the Contoso Retail application running on the Windows Server VM and deploy it to **Azure App Service** - converting it from a locally hosted Node.js process to a fully managed PaaS web application.

By the end of this challenge, you will have:

- A running Azure App Service hosting the Contoso Retail application
- Application settings migrated from the `.env` file to App Service configuration
- HTTPS enforced with an Azure-managed TLS certificate
- VNet integration configured for private outbound connectivity
- Application Insights connected and receiving live telemetry

> **Note**: This challenge uses a mix of the **Azure portal** and **Azure CLI on the VM**. Each task clearly states which method to use.

**Estimated Duration**: 75 minutes

**Prerequisites**:
- Challenge 1 completed - Landing Zone provisioned, `C:\apps\migration-strategy.txt` saved
- PowerShell session variables from Challenge 1 still set (`$APP_NAME`, `$RG_APP`, etc.)
- Contoso Retail app files at `C:\apps\contoso-retail`

> **If you opened a new PowerShell window**, re-run the variables block from Challenge 1, Task 3, Step 2 before continuing.

## Task 1: Create Monitoring Resources
 
In this task, you provision the Log Analytics Workspace and Application Insights using the **Azure portal**. Monitoring is created first so it is ready to receive telemetry the moment the application deploys.
 
**Create the Log Analytics Workspace**
 
1. In the **Azure portal**, type **Log Analytics workspaces (1)** in the search bar and select **Log Analytics workspaces (2)** under Services.

   ![](../media/130.png)

2. Select **+ Create**.

   ![](../media/131.png)

3. On the **Basics** tab, fill in the following details and select **Review + create**:
   - **Subscription**: select your Azure subscription **(1)**
   - **Resource group**: `rg-migration-lab-app` **(2)**
   - **Name**: `law-contoso-<inject key="DeploymentID" enableCopy="false"></inject>` **(3)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(4)**

     ![](../media/132.png)

4. Select **Create** and wait approximately 1 minute for deployment to complete.

   ![](../media/133.png)

**Create Application Insights**
 
5. In the Azure portal search bar, type **Application Insights (1)** and select **Application Insights (2)** under Services.

   ![](../media/135.png)

6. Select **+ Create**.

   ![](../media/136.png)

7. On the **Basics** tab, fill in the following details and select **Review + create (5)**:
   - **Subscription**: select your Azure subscription ****
   - **Resource group**: `rg-migration-lab-app` **(1)**
   - **Name**: `ai-contoso-<inject key="DeploymentID" enableCopy="false"/>` **(2)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(3)**
   - **Log Analytics Workspace**: `law-contoso-<inject key="DeploymentID" enableCopy="false"></inject>` **(4)**

     ![](../media/137.png)

8. Select **Create** and wait approximately 1 minute for deployment to complete. Then select **Go to resource**.

   ![](../media/138.png)

**Copy the Instrumentation Key**
 
9. On the Application Insights overview page, locate the **Instrumentation Key** field and select the copy icon next to it.
   ![](../media/ai-instrumentation-key.png)
10. Open **Notepad** on your VM and paste the key. You will need it in Task 3 when configuring App Service Application Settings.
    > **Important**: Do not close Notepad. The instrumentation key is required in Task 3, Step 2.
Monitoring resources are provisioned.

## Task 2: Create the App Service Plan and App Service

In this task, you provision the App Service Plan and the Web App using the **Azure portal**.

1. In the **Azure portal**, type **App Services (1)** in the search bar and select **App Services (2)** under Services.

   ![](../media/139.png)

2. Select **+ Create** **(1)** - **Web App** **(2)**.

   ![](../media/140.png)

3. On the **Basics** tab, fill in the following details:

   - **Subscription**: select your Azure subscription **(1)**
   - **Resource group**: `rg-migration-lab-app` **(2)**
   - **Name**: `app-contoso-<inject key="DeploymentID" enableCopy="false"></inject>` **(3)**
   - **Publish**: **Code** **(4)**
   - **Runtime stack**: **Node 22 LTS** **(5)**
   - **Operating System**: **Linux** **(6)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(7)**

     ![](../media/141.png)

4. Under **Pricing plans**, select **Create new** and name it `asp-contoso-<inject key="DeploymentID" enableCopy="false"></inject>`. 

    ![](../media/142.png)

1. Select **Standard S1** from the plan size options.

   > **Note**: Standard S1 is the minimum tier that supports VNet integration and custom domains. Do not select Free or Basic.

5. Select **Next: Database** and leave all defaults. Select **Next: Networking**.

6. On the **Networking** tab, set **Enable public access** to **On**. Leave all other settings as default and select **Next: Monitoring**.

    ![](../media/144.png)

7. On the **Monitoring** tab:

   - **Enable Application Insights**: **Yes** **(1)**
   - **Application Insights**: select **Select existing (2)** - choose `ai-contoso-<inject key="DeploymentID" enableCopy="false"></inject>` **(3)**

     ![](../media/145.png)

8. Select **Review + create**, review the summary, then select **Create**.

9. Wait approximately 2-3 minutes for deployment to complete, then select **Go to resource**.

10. On the App Service overview page, note the **Default domain** value - this is your application URL. It follows the format `app-contoso-<DeploymentID>.azurewebsites.net`.

The App Service Plan and App Service are created.

---

## Task 3: Configure Application Settings and HTTPS

In this task, you migrate the application configuration from the `.env` file on the VM to **App Service Application Settings** using the **Azure portal**. You will also enforce HTTPS.

All steps are performed in the **Azure portal** on the App Service you just created.

**Add Application Settings**

1. In the App Service left navigation, select **Environment variables**. Under the **App settings** tab, select **+ Add** for each of the following settings. Enter the **Name** and **Value** for each and select **Apply** after each one:

   | Name | Value |
   | --- | --- |
   | `DB_SERVER` | `sql-contoso-<inject key="DeploymentID" enableCopy="false"></inject>.database.windows.net` |
   | `DB_NAME` | `contosodb` |
   | `DB_USER` | `sqladmin` |
   | `DB_PASSWORD` | `P@ssw0rd2026!` |
   | `PORT` | `8080` |
   | `APPINSIGHTS_INSTRUMENTATIONKEY` | paste the value from `$AI_KEY` (saved in Task 1, Step 9) |
   | `WEBSITE_NODE_DEFAULT_VERSION` | `~22` |

   ![](../media/146.png)

   ![](../media/147.png)

   > **Note**: App Service Application Settings are injected as environment variables at runtime. The `process.env.DB_SERVER` calls in the application code read these values automatically - no code changes are needed.

3. Once all seven settings are added, select **Apply** **(1)** then **Confirm** **(2)** to save all settings.

   ![](../media/148.png)

<!---
**Set the startup command**

4. In the left navigation, select **Configuration** - **General settings** tab.

5. Under **Stack settings**, set **Startup Command** to:

   ```
   node src/app.js
   ```

6. Select **Save** **(1)** then **Continue** **(2)** when prompted.

   ![](../media/appservice-startup-command.png)

--->

**Enforce HTTPS**

7. In the left navigation, select **Settings** - **Configuration** - **General settings** tab (if not already there).

8. Scroll to **Platform settings** and set **HTTPS Only** to **On**.

   ![](../media/149.png)

9. Select **Save** and **Continue** when prompted.

Application settings are configured and HTTPS is enforced.

---

## Task 4: Package and Deploy the Application

In this task, you create a deployment zip from the application files on the VM and push it to App Service using zip deploy. The `.env` file is explicitly excluded from the package.

All steps use **PowerShell on the VM**.

1. Restart your web app

   ![](../media/res.png)

1. Go to your Visual studio and install the **Azure App Service Extension**

    ![](../media/154.png)

3. now right click on the **Contoso-retail folder...** folder and click on the **Deploy to Web App**

    ![](../media/155.png)

4. follow the sign in process.

    ![](../media/156.png)

1. Click Allow in The extension Azure Resources wants to sign in using Microsoft.

    ![](../media/157.png)

2. You'll see the **Sign into Microsoft Azure** tab. Here, enter your **credentials (1)** and select **Next (2)**:

   - **Email/Username:** <inject key="AzureAdUserEmail"></inject>

     ![Enter Your Username](../media/158.png)

3. Next, provide your **Temporary Access Pass(1)** and select **Sign In (2)**:

      - Enter **Temporary Access Pass:** <inject key="AzureAdUserPassword"></inject> **(1)**

      ![](../media/159.png)

1. Click **No, this app only.**

     ![](../media/160.png)

1. Select web app service and click on Deploy.

    ![](../media/161.png)

    ![](../media/162.png)

    ![](../media/163.png)

5. Now you will see the succeed message 

<!--

1. Navigate to the application directory:

   ```powershell
   Set-Location "C:\LabFiles\contoso-retail-webapp\contoso-retail"
   ```

2. Create the deployment package, excluding `.env` and `node_modules`:

   ```powershell
   # Remove any previous zip
   Remove-Item "C:\LabFiles\contoso-retail-webapp\contoso-retail-deploy.zip" -ErrorAction SilentlyContinue

   # Collect files excluding .env and node_modules
   $files = Get-ChildItem -Path "C:\LabFiles\contoso-retail-webapp\contoso-retail-webapp" -Recurse |
   Where-Object {
      $_.FullName -notmatch "node_modules" -and
      $_.FullName -notmatch "\.env$" -and
      -not $_.PSIsContainer
   }

   # Create the zip
   Compress-Archive -Path $files.FullName `
   -DestinationPath "C:\LabFiles\contoso-retail-webapp\contoso-retail-webapp\contoso-retail-deploy.zip" `
   -Force

   Write-Host "Package created:" -ForegroundColor Green
   Get-Item "C:\LabFiles\contoso-retail-webapp\contoso-retail-webapp\contoso-retail-deploy.zip" | Select-Object Name, Length
   ```


   > **Important**: Confirm `Length` is greater than 0 before proceeding. If it shows 0, re-run the compress command.

3. Deploy the zip package to App Service:

   ```powershell
   az webapp deploy `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --src-path "C:\LabFiles\contoso-retail-webapp\contoso-retail-webapp\contoso-retail-deploy.zip" `
     --type zip
   ```

   Deployment takes approximately 1-2 minutes. You will see a progress indicator in the terminal.

   ![](../media/zip-deploy-complete.png)

   > **Note**: App Service automatically runs `npm install` on the server after receiving the zip - your `node_modules` folder is built in the cloud, not deployed from the VM.

--->

The application is deployed to Azure App Service.

---

## Task 5: Configure App Service Networking

In this task, you configure VNet integration and access restrictions using the **Azure portal**.

**Enable VNet Integration**

1. In the App Service left navigation, select **Settings** - **Networking**.

2. Under **Outbound traffic configuration**, select **VNet integration**.

3. Select **Add VNet integration**.

   ![](../media/150.png)

4. In the **Add VNet Integration** panel, fill in the following and select **Connect**:

   - **Virtual Network**: `vnet-migration-lab` **(1)**
   - **Subnet**: `snet-appservice` **(2)**

     ![](../media/151.png)

5. Wait approximately 1 minute. Confirm the VNet integration shows as **Connected** with subnet `snet-appservice`.

   ![](../media/152.png)

   > **Note**: VNet integration enables the App Service to make **outbound** calls to private resources inside the VNet (such as a future Private Endpoint on Azure SQL in Phase 2). It does not affect inbound access to the App Service.


<!---
**Configure Access Restrictions**

6. In the **Networking** page, under **Inbound traffic configuration**, select **Access restriction**.

   ![](../media/appservice-access-restriction.png)

7. Select **+ Add** to add a new rule with the following values:

   - **Name**: `Allow-AzureFrontDoor` **(1)**
   - **Action**: **Allow** **(2)**
   - **Priority**: `100` **(3)**
   - **Type**: **Service Tag** **(4)**
   - **Service Tag**: **AzureFrontDoor.Backend** **(5)**

   ![](../media/access-restriction-rule.png)

8. Select **Add rule**.

   > **Note**: This rule demonstrates the pattern used in production to restrict inbound access to only trusted Azure services. For this lab, public access remains enabled so you can test the app directly from a browser.

Networking is configured.

--->

## Task 6: Validate the Migrated Application

In this task, you confirm the application is running correctly on Azure App Service, the database is connected, and Application Insights is receiving telemetry. All validation steps are done in the **Azure portal** and browser.

**Verify the application**

1. In the App Service overview page, select the **Default domain** link to open the application in a new browser tab.

   ![](../media/153.png)

1. Once you open the URL you will be getting as below screenshots.

    ![](../media/apppp.png)

2. Select **Investigate** - **Transaction search**. Confirm request events are appearing for `/` and `/products`.

   > **If the products page returns an error**:
   > - In the App Service, go to **Environment variables** and confirm all 7 settings are present
   > - In the Azure portal, navigate to the SQL Server - **Networking** - enable **Allow Azure services and resources to access this server** - **Save**
   > - Wait 1-2 minutes and refresh the page

## Success Criteria

- Log Analytics Workspace `law-contoso-<DeploymentID>` deployed in `rg-migration-lab-app`.
- Application Insights `ai-contoso-<DeploymentID>` deployed and linked to the workspace.
- App Service Plan `asp-contoso-<DeploymentID>` created at Standard S1 tier with Linux OS.
- App Service `app-contoso-<DeploymentID>` created with Node.js 20 LTS runtime.
- All 7 application settings configured in App Service Environment variables.
- HTTPS-only enforced - HTTP requests redirect to HTTPS automatically.
- Startup command set to `node src/app.js`.
- Deployment zip created without `.env` and `node_modules` and deployed via zip deploy.
- Home page and products page load correctly at the `azurewebsites.net` URL.
- VNet integration active and showing `Connected` on `snet-appservice`.
- Application Insights Live Metrics showing incoming request telemetry.

## Learning Outcomes

- Provision Azure App Service Plan and Web App using the Azure portal.
- Migrate application configuration from a `.env` file to App Service Application Settings.
- Package a Node.js application and deploy it using zip deploy from Azure CLI.
- Configure App Service VNet integration for private outbound connectivity via the portal.
- Validate a migrated web application end-to-end including database connectivity and live monitoring.

---

## References

- Azure App Service overview: https://learn.microsoft.com/azure/app-service/overview
- App Service VNet integration: https://learn.microsoft.com/azure/app-service/overview-vnet-integration
- Deploy a zip file to App Service: https://learn.microsoft.com/azure/app-service/deploy-zip
- App Service Application Settings: https://learn.microsoft.com/azure/app-service/configure-common
- Application Insights for Node.js: https://learn.microsoft.com/azure/azure-monitor/app/nodejs
- App Service access restrictions: https://learn.microsoft.com/azure/app-service/app-service-ip-restrictions
