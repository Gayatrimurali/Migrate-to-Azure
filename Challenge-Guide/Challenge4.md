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

2. **Assign Policy 1 — App Service apps should only be accessible over HTTPS**

3. On the **Basics** tab, configure the following:

   - **Scope**: select your subscription **(1)** → then select the resource group `rg-migration-lab-app` **(2)** → select **Select**

1. Assign **Policy 2 — App Service apps should use the latest TLS version**


1. Assign **Policy 3 — App Service apps should have remote debugging turned off**


1. Assign **Policy 4: App Service app slots should have resource logs enabled**
   
## Task 2: Configure RBAC for Application Access (Read Only)

1. Assign **Role assignments** has **Owner** or **Contributor** to the Resource group `rg-migration-lab-app`, your current account  access.

2. **Assign the Contributor role for app management**

3. On the **Members** tab:

   - **Assign access to**: **User, group, or service principal** **(1)**
   - Select **+ Select members (2)** → search for your own account or a lab user account → **Select** **(3)**
  
1. **Assign the Reader role for read-only access** On the **Members** tab, assign it to a second user account if available, or note the steps for reference.

2. **Assign the Website Contributor role for deployment access**

## Task 3: Enable Microsoft Defender for Cloud

1. Open Microsoft Defender for Cloud, go to Environment settings, select your subscription, enable Defender plans for App Service, Azure SQL, and Resource Manager, then save and review the security posture.

2. Go to your App Service, open Alerts, create a new alert rule for HTTP 4xx errors (greater than 5), configure an action group with email notifications, and create the alert.

3. Open Application Insights, review performance metrics like response time and failed requests, and use Live Metrics and Application Map to monitor application health.

## Task 4: Secure Application Endpoints

1. Navigate to app service and click on default domain.

    ![](../media/330.png)

1. In the URL make it as http instead of https and hit enter.

    ![](../media/331.png)

**Final security validation**

Run the following checks to confirm all security controls are in place:

| Check | Expected Status | How to Verify |
| --- | --- | --- |
| HTTPS Only | On | Configuration > General settings |
| Minimum TLS Version | 1.2 | Configuration > General settings |
| Remote debugging | Off | Configuration > General settings |
| VNet integration | Connected | Networking > VNet integration |
| Defender for App Service | On | Defender for Cloud > Environment settings |
| Application Insights | Connected | App Service > Application Insights |
| Alert rule | Active | Monitoring > Alerts |
| Azure Policy | Assigned (4 policies) | Policy > Assignments |

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
