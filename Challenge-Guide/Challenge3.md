# Challenge 3: Hybrid & Disaster Recovery

## Estimated Duration : 60 Minutes

## Overview

In this challenge, you extend the migration with **hybrid connectivity** and **disaster recovery** capabilities. The Windows Server VM — still running the original on-premises application — will be connected to Azure using **Azure Arc**, making it a managed hybrid resource. You will then build a full DR strategy for the migrated App Service workload including backup and regional failover.

By the end of this challenge, you will have:

- The Windows Server VM onboarded as an Azure Arc-enabled server
- A backup policy configured for the App Service application
- A Traffic Manager profile routing traffic across two regions for failover
- Validated failover readiness for the web workload

> **Note**: This challenge uses a mix of the **Azure portal** and **Azure CLI on the VM**. Each task clearly states which method to use.

**Estimated Duration**: 75 minutes

**Prerequisites**:
- Challenge 2 completed — App Service running at `https://app-contoso-<DeploymentID>.azurewebsites.net`
- PowerShell session variables still set (`$APP_NAME`, `$RG_APP`, `$RG_CORE`, etc.)
- VM connected via RDP

> **If you opened a new PowerShell window**, re-run the variables block from Challenge 1, Task 3, Step 2 before continuing.

---

## Task 1: Connect the VM to Azure Arc

1. In the Azure portal, search **Azure Arc**, select it, then navigate to **Infrastructure** and select **Machines**.

2. Select **+ Add/Create**, choose **Add a machine**, then under **Add a single server**, select **Generate script**.

3. On the **Resource details** tab, fill in the following and select **Next**:

   - **Subscription**: select your Azure subscription **(1)**
   - **Resource group**: `rg-migration-lab` **(2)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(3)**
   - **Operating system**: **Windows** **(4)**
   - **Connectivity method**: **Public endpoint** **(5)**

10. On the **Windows Server VM**, open **PowerShell as Administrator** and run the onboarding script:

    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
    .\OnboardingScript.ps1
    ```

## Task 2: Configure Backup for the App Service

1. Create a **Storage account**.

2. On the **Basics** tab, fill in the following and select **Review + create**:

   - **Subscription**: select your Azure subscription **(1)**
   - **Resource group**: `rg-migration-lab-app` **(2)**
   - **Storage account name**: `stcontoso<inject key="DeploymentID" enableCopy="false"></inject>` **(3)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(4)**
   - **Performance**: **Standard** **(5)**
   - **Redundancy**: **Locally-redundant storage (LRS)** **(6)**

1. **Create a Blob Container for backup files** set **Anonymous access level** to **Private**, and select **Create**.

## Task 3: Implement Regional Failover with Traffic Manager

1. **Create a secondary App Service for DR**

1. Open **PowerShell as Administrator** on the VM and set the DR region variable:

   ```powershell
   $LOCATION_DR    = "westus"
   $RG_DR          = "rg-migration-lab-dr"
   $APP_PLAN_DR    = "asp-contoso-dr-$DEPLOYMENT_ID"
   $APP_NAME_DR    = "app-contoso-dr-$DEPLOYMENT_ID"
   ```

2. Create the DR resource group:

   ```powershell
   az group create `
     --name $RG_DR `
     --location $LOCATION_DR `
     --tags Environment=Lab Project=ContosoMigration Purpose=DisasterRecovery
   ```

3. Create the DR App Service Plan:

   ```powershell
   az appservice plan create `
     --name $APP_PLAN_DR `
     --resource-group $RG_DR `
     --location $LOCATION_DR `
     --sku S1 `
     --is-linux
   ```

4. Create the DR App Service with the same runtime:

   ```powershell
   az webapp create `
     --name $APP_NAME_DR `
     --resource-group $RG_DR `
     --plan $APP_PLAN_DR `
     --runtime "NODE:22-lts"
   ```

5. Copy the same application settings to the DR App Service:

   ```powershell
   az webapp config appsettings set `
     --name $APP_NAME_DR `
     --resource-group $RG_DR `
     --settings `
       DB_SERVER="$SQL_SERVER.database.windows.net" `
       DB_NAME="contosodb" `
       DB_USER="sqladmin" `
       DB_PASSWORD="P@ssw0rd2026!" `
       PORT="8080" `
       APPINSIGHTS_INSTRUMENTATIONKEY="$AI_KEY" `
       WEBSITE_NODE_DEFAULT_VERSION="~22"
   ```

6. Deploy the same application package to the DR App Service:

   ```powershell
   az webapp deploy `
     --name $APP_NAME_DR `
     --resource-group $RG_DR `
     --src-path "C:\apps\contoso-retail-deploy.zip" `
     --type zip `
     --restart true
   ```

7. Enforce HTTPS on the DR App Service:

   ```powershell
   az webapp update `
     --name $APP_NAME_DR `
     --resource-group $RG_DR `
     --https-only true
   ```

8. Set the startup command:

   ```powershell
   az webapp config set `
     --name $APP_NAME_DR `
     --resource-group $RG_DR `
     --startup-file "node src/app.js"
   ```

9. Verify the DR App Service is running:

   ```powershell
   az webapp show `
     --name $APP_NAME_DR `
     --resource-group $RG_DR `
     --query "{Name:name, State:state, URL:defaultHostName}" `
     --output table
   ```

1. **Create the Traffic Manager Profile**

2. **Add the Primary Endpoint**

    - **Type**: **Azure endpoint** **(1)**
    - **Name**: `primary-eastus` **(2)**
    - **Target resource type**: **App Service** **(3)**
    - **Target resource**: `app-contoso-<inject key="DeploymentID" enableCopy="false"></inject>` **(4)**
    - **Priority**: `1` **(5)**
  
1. **Add the Secondary (DR) Endpoint**

    - **Type**: **Azure endpoint** **(1)**
    - **Name**: `secondary-westus` **(2)**
    - **Target resource type**: **App Service** **(3)**
    - **Target resource**: `app-contoso-dr-<inject key="DeploymentID" enableCopy="false"></inject>` **(4)**
    - **Priority**: `2` **(5)**
  
## Task 4: Validate Failover Readiness

1. **Verify Traffic Manager routing** Open **Microsoft Edge** on the VM and navigate to `http://contoso-tm-<DeploymentID>.trafficmanager.net` Confirm the **Contoso Retail** home page loads and the products page shows 10 products.

1. In **PowerShell on the VM**, verify DNS resolution points to the primary endpoint:

   ```powershell
   Resolve-DnsName "contoso-tm-$DEPLOYMENT_ID.trafficmanager.net"
   ```
1. **Simulate a failover**

2. Select the **primary-eastus** endpoint and set **Status** to **Disabled**. Select **Save**.

   > **Note**: Disabling an endpoint simulates the primary region becoming unavailable. In a real DR event, this would happen automatically when Traffic Manager health checks fail.

7. Back in **PowerShell**, run DNS resolution again:

   ```powershell
   Resolve-DnsName "contoso-tm-$DEPLOYMENT_ID.trafficmanager.net"
   ```

1. **Restore the primary endpoint**

9. In the Azure portal, navigate back to the Traffic Manager profile → **Endpoints** → select **primary-eastus** → set **Status** back to **Enabled** → **Save**.

   ![](../media/tm-enable-primary.png)

10. Wait 1–2 minutes, then run the final readiness check from PowerShell:

    ```powershell
    Write-Host "=== DR READINESS CHECK ===" -ForegroundColor Cyan

    Write-Host "`n-- Primary App Service --" -ForegroundColor Yellow
    az webapp show `
      --name $APP_NAME `
      --resource-group $RG_APP `
      --query "{Name:name, State:state, URL:defaultHostName}" `
      --output table

    Write-Host "`n-- DR App Service --" -ForegroundColor Yellow
    az webapp show `
      --name $APP_NAME_DR `
      --resource-group $RG_DR `
      --query "{Name:name, State:state, URL:defaultHostName}" `
      --output table

    Write-Host "`n-- Traffic Manager Endpoints --" -ForegroundColor Yellow
    az network traffic-manager endpoint list `
      --profile-name "contoso-tm-$DEPLOYMENT_ID" `
      --resource-group $RG_APP `
      --output table

    Write-Host "`n=== CHECK COMPLETE ===" -ForegroundColor Green
    ```

11. Confirm all items in the table below match your output:

    | Resource | Expected Result |
    | --- | --- |
    | Primary App Service | `State: Running` |
    | DR App Service | `State: Running` |
    | `primary-eastus` endpoint | `Enabled`, priority `1` |
    | `secondary-westus` endpoint | `Enabled`, priority `2` |
    | App via Traffic Manager URL | Products page loads successfully |
    | DNS resolves back to primary | After re-enabling, resolves to primary App Service |

## Success Criteria

- Windows Server VM onboarded as an Azure Arc-enabled server with **Connected** status in the portal.
- Storage account `stcontoso<DeploymentID>` and container `appbackups` created.
- App Service backup configured with daily schedule and 7-day retention.
- Manual backup completed with **Succeeded** status.
- DR resource group `rg-migration-lab-dr` created in West US.
- DR App Service `app-contoso-dr-<DeploymentID>` deployed in West US with same application and settings.
- Traffic Manager profile `contoso-tm-<DeploymentID>` created with Priority routing.
- Primary endpoint (`primary-eastus`, priority 1) and secondary endpoint (`secondary-westus`, priority 2) both showing **Online**.
- Failover test completed — DNS resolved to DR endpoint when primary was disabled.
- Primary endpoint re-enabled and DNS resolved back to primary.
- DR readiness check script executed with all resources showing expected state.

Now, click on **Next** from the lower right corner to move on to the next page.

   ![](../media/ggs2.png)

