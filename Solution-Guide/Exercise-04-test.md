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

**Azure Policy** enforces organizational standards and assesses compliance at scale. In this task, you assign built-in policies to ensure your App Service always meets security and compliance requirements — such as enforcing HTTPS and requiring the latest TLS version.

All steps are performed in the **Azure portal**.

1. In the **Azure portal**, type **Policy (1)** in the search bar and select **Policy (2)** under Services.

   ![](../media/policy-search.png)

2. In the Policy left navigation, select **Authoring** → **Assignments**.

   ![](../media/policy-assignments.png)

3. Select **+ Assign policy**.

   ![](../media/policy-assign.png)

**Assign Policy 1 — Enforce HTTPS on App Service**

4. On the **Basics** tab, configure the following:

   - **Scope**: select your subscription **(1)** → then select the resource group `rg-migration-lab-app` **(2)** → select **Select**
   - **Policy definition**: select the browse button **(3)** → search for `App Service apps should only be accessible over HTTPS` → select it → select **Add**
   - **Assignment name**: auto-fills — leave as default **(4)**

   ![](../media/policy-https-basics.png)

5. Select **Next** through the **Parameters** and **Remediation** tabs leaving all defaults.

6. On the **Non-compliance messages** tab, enter:

   ```
   App Service must be accessible over HTTPS only. HTTP access is not permitted.
   ```

7. Select **Review + create**, then select **Create**.

   ![](../media/policy-https-create.png)

**Assign Policy 2 — Require Latest TLS Version**

8. Select **+ Assign policy** again.

9. On the **Basics** tab, configure the following:

   - **Scope**: same as above — `rg-migration-lab-app` **(1)**
   - **Policy definition**: search for `App Service apps should use the latest TLS version` → select it → select **Add** **(2)**

   ![](../media/policy-tls-basics.png)

10. Select **Next** through all tabs leaving defaults, then select **Review + create** → **Create**.

**Assign Policy 3 — Enforce Resource Tagging**

11. Select **+ Assign policy** again.

12. On the **Basics** tab, set the scope to your **subscription** (not the resource group — this applies broadly):

    - **Scope**: select your subscription **(1)**
    - **Policy definition**: search for `Require a tag on resources` → select it → **Add** **(2)**

13. On the **Parameters** tab, set:

    - **Tag Name**: `Environment`

    ![](../media/policy-tag-param.png)

14. Select **Review + create** → **Create**.

**Review compliance state**

15. In the Policy left navigation, select **Compliance**.

16. Locate your three assigned policies. Note that compliance evaluation can take up to **10–15 minutes** to reflect. Select **Refresh** periodically.

    ![](../media/policy-compliance.png)

    > **Note**: Resources that already meet the policy conditions will show as **Compliant**. Resources that do not meet conditions will show as **Non-compliant** and can be remediated.

Azure Policy assignments are in place.

---

## Task 2: Configure RBAC for Application Access

**Role-Based Access Control (RBAC)** restricts who can view, manage, and deploy to your Azure resources. In this task, you assign roles at the resource group level to follow the principle of least privilege.

All steps are performed in the **Azure portal**.

**Assign the Contributor role for app management**

4. Select **+ Add (1)** → **Add role assignment (2)**.

   ![](../media/rbac-add-assignment.png)

5. On the **Role** tab, search for `Contributor` **(1)**, select it **(2)**, and select **Next (3)**.

   ![](../media/rbac-contributor.png)

6. On the **Members** tab:

   - **Assign access to**: **User, group, or service principal** **(1)**
   - Select **+ Select members (2)** → search for your own account or a lab user account → **Select** **(3)**

   ![](../media/rbac-members.png)

7. Select **Review + assign** twice to confirm.

**Assign the Reader role for read-only access**

8. Select **+ Add** → **Add role assignment** again.

9. On the **Role** tab, search for `Reader`, select it, and select **Next**.

10. On the **Members** tab, assign it to a second user account if available, or note the steps for reference.

11. Select **Review + assign** twice.

**Assign the Website Contributor role for deployment access**

12. Select **+ Add** → **Add role assignment** again.

13. On the **Role** tab, search for `Website Contributor` **(1)**, select it **(2)**, and select **Next**.

    > **Note**: The **Website Contributor** role allows managing App Service resources but does not grant access to networking or other resource types. This follows least-privilege for a developer who only needs to deploy applications.

14. Assign it to your account or a lab user and select **Review + assign** twice.

15. Back on the **Role assignments** tab, confirm all three role assignments are visible.

   ![](../media/rbac-assignments-verify.png)

RBAC is configured for the application resource group.

## Task 3: Enable Microsoft Defender for Cloud

**Microsoft Defender for Cloud** provides unified security management and threat protection across your Azure workloads. In this task, you enable Defender for Cloud and review the security recommendations for your App Service and SQL Database.

All steps are performed in the **Azure portal**.

1. In the **Azure portal**, type **Microsoft Defender for Cloud (1)** in the search bar and select **Microsoft Defender for Cloud (2)**.

   ![](../media/defender-search.png)

2. In the Defender for Cloud overview page, review the **Secure Score** and the number of active recommendations.

   ![](../media/defender-overview.png)

3. In the left navigation, select **Management** → **Environment settings**.

   ![](../media/defender-env-settings.png)

4. Expand your subscription and select it to open the Defender plans.

5. On the **Defender plans** page, enable the following plans by toggling them **On**:

   - **Servers** — protects the Arc-enabled VM **(1)**
   - **App Service** — protects the App Service workload **(2)**
   - **Azure SQL Databases** — protects `contosodb` **(3)**

   ![](../media/defender-plans.png)

6. Select **Save**.

   > **Note**: Defender for Cloud plans have a cost per resource. For this lab, enabling them briefly to review recommendations is sufficient. You can disable them after the lab to avoid charges.

   >**Note: Recommendations takes aroun 24- 48 hrs to visible so we havent included in this lab to showcase those things**

## Task 4: Configure Azure Monitor Alerts

In this task, you configure **Azure Monitor alerts** to notify you when the application encounters issues — such as high response times, HTTP 5xx errors, or the App Service going down entirely. This ensures the operations team is proactively informed before users are impacted.

All steps are performed in the **Azure portal**.

**Create an alert for HTTP 4xx errors**

1. In the **Azure portal**, navigate to your App Service `app-contoso-<inject key="DeploymentID" enableCopy="false"></inject>`.

2. In the left navigation, select **Monitoring** → **Alerts**.

   ![](../media/monitor-alerts.png)

3. Select **+ Create (1)** → **Alert rule (2)**.

   ![](../media/monitor-alert-create.png)

4. On the **Condition** tab, select **+ Add condition**.

   ![](../media/monitor-condition-add.png)

5. In the **Select a signal** panel, search for `Http 5xx` **(1)** and select **Http 4xx (2)**.

   ![](../media/monitor-signal-5xx.png)

6. Configure the alert logic:

   - **Threshold**: **Static** **(1)**
   - **Aggregation type**: **Total** **(2)**
   - **Value is**: **Greater than** **(3)**
   - **Threshold value**: `5` **(4)**
   - **Check every**: **1 minute** **(5)**
   - **Lookback period**: **5 minutes** **(6)**

   ![](../media/monitor-alert-logic.png)

7. Select **Next: Actions**.

**Create an Action Group**

8. Select **+ Create action group**.

   ![](../media/monitor-action-group-create.png)

9. On the **Basics** tab:

   - **Subscription**: select your subscription **(1)**
   - **Resource group**: `rg-migration-lab-app` **(2)**
   - **Action group name**: `ag-contoso-ops` **(3)**
   - **Display name**: `ContosoOps` **(4)**

   ![](../media/monitor-action-group-basics.png)

10. Select **Next: Notifications**.

11. On the **Notifications** tab, add the following:

    - **Notification type**: **Email/SMS message/Push/Voice** **(1)**
    - **Name**: `email-alert` **(2)**
    - Select the edit icon and enter your email address → **OK** **(3)**

    ![](../media/monitor-notification.png)

12. Select **Review + create** → **Create**.

13. Back on the alert rule, select **Next: Details**.

14. On the **Details** tab:

    - **Alert rule name**: `alert-4xx-errors` **(1)**
    - **Severity**: **2 - Warning** **(2)**
    - **Enable upon creation**: **Yes** **(3)**

    ![](../media/monitor-alert-details.png)

15. Select **Review + create** → **Create**.

**Create an alert for App Service availability**

16. Select **+ Create** → **Alert rule** again.

17. On the **Condition** tab, select **+ Add condition** → search for `HTTP Response Time` → select it.

18. Configure the logic:

    - **Threshold value**: `3` (seconds)
    - **Aggregation type**: **Average**
    - **Operator**: **Greater than**
    - **Check every**: **1 minute**

19. On the **Actions** tab, select the existing action group `ag-contoso-ops`.

20. On the **Details** tab, name the rule `alert-high-response-time`, set severity to **2 - Warning**, and select **Review + create** → **Create**.

21. Back on the **Alerts** page, confirm both alert rules are listed as **Enabled**.

    ![](../media/monitor-alerts-verify.png)

Azure Monitor alerts are configured.

---

## Task 5: Secure Application Endpoints with Key Vault

In this task, you remove the hardcoded database credentials from App Service Application Settings and replace them with **Azure Key Vault references**. This is the final step in the Phase 2 replatform — secrets are now managed centrally, rotated independently, and never exposed in plain text.

**Architecture after this task:**

```
App Service
  |
  +-- App Setting: DB_PASSWORD = @Microsoft.KeyVault(SecretUri=https://kv-contoso-<ID>.vault.azure.net/secrets/db-password/)
                                                    |
                                                    v
                                            Azure Key Vault
                                              kv-contoso-<ID>
                                                Secret: db-password = P@ssw0rd2026!
```

All steps use a mix of **Azure CLI on the VM** and the **Azure portal**.

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
   ```

   > **Note**: Key Vault names must be globally unique and between 3–24 characters. If creation fails with a name conflict, add a suffix such as `kv-contoso-$DEPLOYMENT_ID-lab`.

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

   ![](../media/kv-secrets-verify.png)

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

    ![](../media/governance-summary.png)

The application is fully secured and governed.

---

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

---

## Learning Outcomes

- Assign and evaluate Azure Policy for App Service compliance enforcement.
- Configure RBAC role assignments following the principle of least privilege.
- Enable and navigate Microsoft Defender for Cloud to review and remediate security recommendations.
- Create Azure Monitor alert rules with action groups for proactive application monitoring.
- Implement Azure Key Vault with Managed Identity to eliminate hardcoded credentials from application configuration.
- Validate end-to-end application security using CLI and the Azure portal.

---

## References

- Azure Policy overview: https://learn.microsoft.com/azure/governance/policy/overview
- Azure RBAC overview: https://learn.microsoft.com/azure/role-based-access-control/overview
- Microsoft Defender for Cloud: https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction
- Azure Monitor alerts: https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-overview
- Azure Key Vault overview: https://learn.microsoft.com/azure/key-vault/general/overview
- App Service Key Vault references: https://learn.microsoft.com/azure/app-service/app-service-key-vault-references
- Managed Identity overview: https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview