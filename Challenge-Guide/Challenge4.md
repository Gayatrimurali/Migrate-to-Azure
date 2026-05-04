# Challenge 4: Governance & Security

## Overview

In this challenge, you harden and govern the migrated Contoso Retail workload. A running application in Azure is not complete until it is secured, monitored, and governed. You will apply Azure policies, configure role-based access control, enable Microsoft Defender for Cloud, set up alerting, and secure the application endpoints — including removing hardcoded credentials by moving secrets to Azure Key Vault.

By the end of this challenge, you will have:

- Azure Policy applied to enforce App Service compliance rules
- RBAC configured to control who can access and manage the application
- Microsoft Defender for Cloud enabled and recommendations reviewed
- Azure Monitor alerts configured for application health
- Application endpoints secured with HTTPS enforcement and access restrictions
- Database credentials moved from App Settings to Azure Key Vault

> **Note**: This challenge uses a mix of the **Azure portal** and **Azure CLI on the VM**. Each task clearly states which method to use.

**Estimated Duration**: 75 minutes

**Prerequisites**:
- Challenge 3 completed — Traffic Manager and DR App Service in place
- PowerShell session variables still set (`$APP_NAME`, `$RG_APP`, etc.)
- VM connected via RDP

> **If you opened a new PowerShell window**, re-run the variables block from Challenge 1, Task 3, Step 2 before continuing.

---

## Task 1: Apply Azure Policy for App Service Compliance

1. Assign policies from Azure portal.

2. **Assign Policy 1 — Enforce HTTPS on App Service**

3. On the **Basics** tab, configure the following:

   - **Scope**: select your subscription **(1)** → then select the resource group `rg-migration-lab-app` **(2)** → select **Select**
   - **Policy definition**: select the browse button **(3)** → search for `App Service apps should only be accessible over HTTPS` → select it → select **Add**
   - **Assignment name**: auto-fills — leave as default **(4)**

6. On the **Non-compliance messages** tab, enter:

   ```
   App Service must be accessible over HTTPS only. HTTP access is not permitted.
   ```

1. **Assign Policy 2 — Require Latest TLS Version**

8. Select **+ Assign policy** again.

9. On the **Basics** tab, configure the following:

   - **Scope**: same as above — `rg-migration-lab-app` **(1)**
   - **Policy definition**: search for `App Service apps should use the latest TLS version` → select it → select **Add** **(2)**

   ![](../media/policy-tls-basics.png)

10. select **Review + create** → **Create**.

**Assign Policy 3 — Enforce Resource Tagging**

11. Select **+ Assign policy** again.

12. On the **Basics** tab, set the scope to your **subscription** (not the resource group — this applies broadly):

    - **Scope**: select your subscription **(1)**
    - **Policy definition**: search for `Require a tag on resources` → select it → **Add** **(2)**

13. On the **Parameters** tab, set:

    - **Tag Name**: `Environment`
   
## Task 2: Configure RBAC for Application Access

1. Assign **Role assignments** has **Owner** or **Contributor** to the Resource group `rg-migration-lab-app`, your current account  access.

2. **Assign the Contributor role for app management**

3. On the **Members** tab:

   - **Assign access to**: **User, group, or service principal** **(1)**
   - Select **+ Select members (2)** → search for your own account or a lab user account → **Select** **(3)**
  
1. **Assign the Reader role for read-only access** On the **Members** tab, assign it to a second user account if available, or note the steps for reference.

2. **Assign the Website Contributor role for deployment access**

## Task 3: Enable Microsoft Defender for Cloud

1. In the Azure portal, open **Microsoft Defender for Cloud**, go to **Environment settings**, select your subscription, enable **Servers**, **App Service**, and **Azure SQL Databases**, then click **Save**.

2. Go to **Recommendations**, filter by **App Service**, review items, and fix key issues like disabling **remote debugging**.

3. Go to **Overview** and review the **Secure Score** to understand your security posture.

## Task 4: Configure Azure Monitor Alerts (Simplified)

1. Go to your **App Service → Alerts**, create a new alert rule, choose **Http 5xx**, set threshold (greater than 5), and proceed.

2. Create an **Action Group** with your email notification (e.g., `ag-contoso-ops`).

3. Name the alert (e.g., `alert-5xx-errors`), set severity, and create it.

4. Create another alert rule for **HTTP Response Time > 3 seconds**, use the same action group, and create it.

5. Ensure both alert rules are **Enabled** in the Alerts page.

## Task 5: Secure Application Endpoints with Key Vault

**Create the Key Vault**

1. Open **PowerShell as Administrator** on the VM.

2. Create the Key Vault:

   ```powershell
   $KV_NAME = "kv-contoso-$DEPLOYMENT_ID"

   az keyvault create `
     --name $KV_NAME `
     --resource-group $RG_APP `
     --location $LOCATION `
     --sku standard `
     --tags Environment=Lab Project=ContosoMigration

**Enable Managed Identity on the App Service**

3. Enable system-assigned Managed Identity on the App Service. This gives the App Service a secure Azure AD identity without any credentials:

   ```powershell
   az webapp identity assign `
     --name $APP_NAME `
     --resource-group $RG_APP
   ```

4. Retrieve the Managed Identity principal ID:

   ```powershell
   $IDENTITY_ID = az webapp identity show `
     --name $APP_NAME `
     --resource-group $RG_APP `
     --query principalId `
     --output tsv

   Write-Host "Managed Identity ID: $IDENTITY_ID" -ForegroundColor Cyan
   ```

**Grant the App Service access to Key Vault**

5. Assign the **Key Vault Secrets User** role to the App Service Managed Identity:

   ```powershell
   $KV_ID = az keyvault show `
     --name $KV_NAME `
     --resource-group $RG_APP `
     --query id `
     --output tsv

   az role assignment create `
     --role "Key Vault Secrets User" `
     --assignee $IDENTITY_ID `
     --scope $KV_ID
   ```

**Store secrets in Key Vault**

6. Add the database password as a Key Vault secret:

   ```powershell
   az keyvault secret set `
     --vault-name $KV_NAME `
     --name "db-password" `
     --value "P@ssw0rd2026!"
   ```

7. Add the database username as a secret:

   ```powershell
   az keyvault secret set `
     --vault-name $KV_NAME `
     --name "db-user" `
     --value "sqladmin"
   ```

8. Verify both secrets are stored:

   ```powershell
   az keyvault secret list `
     --vault-name $KV_NAME `
     --output table
   ```

   Confirm `db-password` and `db-user` are listed.

**Update App Service to use Key Vault references**

9. Retrieve the secret URIs:

   ```powershell
   $DB_PWD_URI = az keyvault secret show `
     --vault-name $KV_NAME `
     --name "db-password" `
     --query id `
     --output tsv

   $DB_USER_URI = az keyvault secret show `
     --vault-name $KV_NAME `
     --name "db-user" `
     --query id `
     --output tsv

   Write-Host "Password URI: $DB_PWD_URI" -ForegroundColor Cyan
   Write-Host "User URI:     $DB_USER_URI" -ForegroundColor Cyan
   ```

10. Update the App Service settings to use Key Vault references instead of plain text values:

    ```powershell
    az webapp config appsettings set `
      --name $APP_NAME `
      --resource-group $RG_APP `
      --settings `
        DB_USER="@Microsoft.KeyVault(SecretUri=$DB_USER_URI)" `
        DB_PASSWORD="@Microsoft.KeyVault(SecretUri=$DB_PWD_URI)"
    ```

11. Restart the App Service to apply the new settings:

    ```powershell
    az webapp restart `
      --name $APP_NAME `
      --resource-group $RG_APP

    Write-Host "App Service restarted." -ForegroundColor Green
    ```

**Verify Key Vault references are resolving**

12. In the **Azure portal**, navigate to your App Service → **Settings** → **Environment variables**.

13. Locate the `DB_USER` and `DB_PASSWORD` settings. They should now show a green **Key Vault reference** icon next to them indicating successful resolution.

    ![](../media/kv-reference-resolved.png)

    > **If the icon shows a red warning**: The Managed Identity may not have propagated yet. Wait 2–3 minutes and refresh the page.

14. Open the application URL in the browser: `https://app-contoso-<DeploymentID>.azurewebsites.net/products`.

    Confirm the products page still loads 10 products — the app is now reading credentials from Key Vault transparently.

    ![](../media/app-kv-verify.png)

**Run the final governance and security check**

15. Run the following from **PowerShell on the VM** to produce a final summary of all security controls applied:

    ```powershell
    Write-Host "=== GOVERNANCE & SECURITY SUMMARY ===" -ForegroundColor Cyan

    Write-Host "`n-- HTTPS Enforcement --" -ForegroundColor Yellow
    az webapp show `
      --name $APP_NAME `
      --resource-group $RG_APP `
      --query "{Name:name, HTTPSOnly:httpsOnly}" `
      --output table

    Write-Host "`n-- Managed Identity --" -ForegroundColor Yellow
    az webapp identity show `
      --name $APP_NAME `
      --resource-group $RG_APP `
      --query "{Type:type, PrincipalId:principalId}" `
      --output table

    Write-Host "`n-- Key Vault Secrets --" -ForegroundColor Yellow
    az keyvault secret list `
      --vault-name $KV_NAME `
      --output table

    Write-Host "`n-- Azure Policy Assignments --" -ForegroundColor Yellow
    az policy assignment list `
      --resource-group $RG_APP `
      --output table

    Write-Host "`n-- RBAC Assignments on rg-migration-lab-app --" -ForegroundColor Yellow
    az role assignment list `
      --resource-group $RG_APP `
      --output table

    Write-Host "`n=== SUMMARY COMPLETE ===" -ForegroundColor Green
    ```

## Success Criteria

- Azure Policy assigned for HTTPS enforcement, latest TLS version, and resource tagging on `rg-migration-lab-app`.
- Policy compliance state visible in the Azure portal (evaluation may take up to 15 minutes).
- RBAC role assignments configured on `rg-migration-lab-app` — Contributor, Reader, and Website Contributor roles assigned.
- Microsoft Defender for Cloud enabled for Servers, App Service, and Azure SQL Databases plans.
- Remote debugging recommendation remediated via Defender for Cloud **Fix** action.
- Azure Monitor alert `alert-5xx-errors` created — triggers on more than 5 HTTP 5xx errors in 5 minutes.
- Azure Monitor alert `alert-high-response-time` created — triggers when average response time exceeds 3 seconds.
- Action group `ag-contoso-ops` created with email notification.
- Key Vault `kv-contoso-<DeploymentID>` created in `rg-migration-lab-app`.
- Managed Identity enabled on App Service and granted **Key Vault Secrets User** role.
- Secrets `db-password` and `db-user` stored in Key Vault.
- App Service `DB_USER` and `DB_PASSWORD` settings updated to Key Vault references.
- Key Vault references show green **resolved** status in App Service Environment variables.
- Products page loads correctly after Key Vault references are applied.
- Final governance summary script executed with all controls verified.
