# Exercise 4: Governance & Security

## Overview

This exercise applies governance controls and security hardening to the migrated web application. You will assign Azure Policies for App Service compliance, configure RBAC for application access, enable Microsoft Defender for Cloud and Azure Monitor with Application Insights, and secure application endpoints with HTTPS enforcement and access restrictions.

## Task 1: Apply Azure Policies for App Service Compliance

**Step 1: Assign built-in App Service policies**

1. In the Azure portal, search for **Policy** **(1)** and select **Policy** **(2)**.

   ![](../media/policy-search.png)

2. In the left navigation, select **Assignments**, then **Assign policy**.

   ![](../media/policy-assign.png)

3. For each policy below, follow the assignment wizard:

**Policy 1: App Service apps should use HTTPS**

1. On the **Basics** tab:
   - **Scope**: select the `rg-migration-lab` resource group **(1)**
   - **Policy definition**: search for and select `App Service apps should use HTTPS` **(2)**
   - **Assignment name**: `Enforce HTTPS on App Services` **(3)**

     ![](../media/policy-https.png)

2. Select **Next** through **Parameters** and **Remediation** tabs.
3. On the **Non-compliance messages** tab, enter: `App Service must use HTTPS for all inbound traffic`.
4. Select **Review + create**, then **Create**.

**Policy 2: App Service apps should use the latest TLS version**

1. Select **Assign policy** again.
2. On the **Basics** tab:
   - **Scope**: `rg-migration-lab`
   - **Policy definition**: search for `App Service apps should use the latest TLS version`
   - **Assignment name**: `Enforce latest TLS version`
3. Select **Review + create**, then **Create**.

**Policy 3: App Service apps should have remote debugging turned off**

1. Select **Assign policy** again.
2. On the **Basics** tab:
   - **Scope**: `rg-migration-lab`
   - **Policy definition**: search for `App Service apps should have remote debugging turned off`
   - **Assignment name**: `Disable remote debugging`
3. Select **Review + create**, then **Create**.

**Policy 4: App Service app slots should have resource logs enabled**

1. Select **Assign policy** again.
2. On the **Basics** tab:
   - **Scope**: `rg-migration-lab`
   - **Policy definition**: search for `App Service app slots should have resource logs enabled`
   - **Assignment name**: `Enable resource logging`
3. Select **Review + create**, then **Create**.

**Step 2: Verify policy compliance**

1. In **Policy**, select **Compliance** in the left navigation.
2. Filter by scope: `rg-migration-lab`.
3. Review the compliance state for each assigned policy.

> Note: Policy compliance evaluation can take up to 30 minutes for the initial scan. You may see **Not started** initially.

   ![](../media/policy-compliance.png)

4. If any policy shows **Non-compliant**, navigate to the affected resource and remediate:
   - For HTTPS: In App Service > **Configuration** > **General settings**, set **HTTPS Only** to **On**
   - For TLS: Set **Minimum TLS Version** to **1.2**
   - For remote debugging: Set **Remote debugging** to **Off**

Azure Policies are assigned and compliance is being evaluated.

## Task 2: Configure RBAC for Application Access

**Step 1: Create a security group for application operators**

1. In the Azure portal, navigate to **Microsoft Entra ID** > **Groups**.
2. Select **New group**.
3. Configure:
   - **Group type**: Security
   - **Group name**: `AppServiceOperators`
   - **Membership type**: Assigned
4. Add lab user accounts that should have operational access to the App Service.
5. Select **Create**.

**Step 2: Assign RBAC roles at the resource group scope**

1. Open **rg-migration-lab** resource group.
2. Select **Access control (IAM)** in the left navigation.
3. Select **+ Add** > **Add role assignment**.

Assign the following roles:

| Role | Assignee | Purpose |
| --- | --- | --- |
| **Website Contributor** | `AppServiceOperators` group | Manage App Service resources (deploy, configure, restart) |
| **Reader** | All lab participants | View resources without modification rights |
| **SQL DB Contributor** | Database administrator account | Manage Azure SQL Database |
| **Monitoring Contributor** | `AppServiceOperators` group | Configure and manage monitoring settings |

For each role assignment:
1. Select the **Role** tab and search for the role name.
2. Select the role, then select **Next**.
3. On the **Members** tab, select **+ Select members**.
4. Search for and select the appropriate group or user.
5. Select **Review + assign**.

   ![](../media/rbac-role-assignment.png)

**Step 3: Verify RBAC assignments**

1. In **Access control (IAM)**, select **Role assignments** tab.
2. Verify all four role assignments appear in the list.
3. Select **Check access** and enter a user's name to verify their effective permissions.

   ![](../media/rbac-check-access.png)

RBAC is configured with least-privilege access.

## Task 3: Enable Microsoft Defender for Cloud and Azure Monitor

**Step 1: Enable Microsoft Defender for Cloud**

1. In the Azure portal, search for **Microsoft Defender for Cloud** **(1)** and select it **(2)**.

   ![](../media/defender-search.png)

2. In the left navigation, select **Environment settings**.

3. Expand the management group/subscription tree and select your subscription.

4. On the **Defender plans** page, ensure the following plans are **On**:

   | Plan | Status |
   | --- | --- |
   | **Defender for App Service** | On |
   | **Defender for Azure SQL** | On |
   | **Defender for Resource Manager** | On |

5. Select **Save**.

   ![](../media/defender-plans.png)

6. Return to **Defender for Cloud** > **Overview**.
7. Review the **Security posture** score and any recommendations for `rg-migration-lab` resources.

   ![](../media/defender-overview.png)

**Step 2: Create an Application Insights resource**

1. In the Azure portal, search for **Application Insights** **(1)** and select **Application Insights** **(2)**.

   ![](../media/appinsights-search.png)

2. Select **+ Create**.

3. Provide the following details:

   - **Subscription**: select your subscription **(1)**
   - **Resource group**: `rg-migration-lab` **(2)**
   - **Name**: `ai-contoso-<inject key="Deployment ID" enableCopy="false"></inject>` **(3)**
   - **Region**: <inject key="Region" enableCopy="false"></inject> **(4)**
   - **Log Analytics workspace**: Create new or select existing **(5)**

4. Select **Review + create**, then **Create**.

   ![](../media/appinsights-create.png)

5. After creation, copy the **Connection String** from the Overview page.

**Step 3: Connect Application Insights to the App Service**

1. Open **contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>** in the Azure portal.
2. In the left navigation, select **Application Insights**.
3. Select **Turn on Application Insights**.
4. Under **Application Insights resource**, select **Select existing resource** and choose `ai-contoso-<inject key="Deployment ID" enableCopy="false"></inject>`.
5. Select **Apply**, then confirm.

   ![](../media/appinsights-enable.png)

Alternatively, add the connection string as an Application Setting:

| Name | Value |
| --- | --- |
| `APPLICATIONINSIGHTS_CONNECTION_STRING` | (paste the connection string from Application Insights) |

**Step 4: Configure Azure Monitor alerts**

1. In the Azure portal, open **contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>**.
2. In the left navigation, select **Alerts** under **Monitoring**.
3. Select **+ Create** > **Alert rule**.
4. Configure the following alert:

   | Setting | Value |
   | --- | --- |
   | **Signal** | Http Server Errors (5xx) |
   | **Threshold** | Greater than 5 |
   | **Aggregation period** | 5 minutes |
   | **Frequency** | Every 1 minute |

5. Under **Actions**, select **+ Create action group**:
   - **Action group name**: `ag-contoso-alerts`
   - **Notification type**: Email/SMS/Push/Voice
   - **Email**: enter a valid email address for alerts

6. Under **Details**:
   - **Alert rule name**: `High 5xx Error Rate`
   - **Severity**: Sev 2 (Warning)

7. Select **Review + create**, then **Create**.

   ![](../media/monitor-alert-rule.png)

**Step 5: Review the monitoring dashboard**

1. Open **Application Insights** > `ai-contoso-<inject key="Deployment ID" enableCopy="false"></inject>`.
2. Review the **Overview** page for:
   - **Server response time**
   - **Server requests**
   - **Failed requests**
3. Select **Live Metrics** to view real-time telemetry.
4. Select **Application map** to visualize the application topology and dependencies.

   ![](../media/appinsights-dashboard.png)

Microsoft Defender for Cloud and Azure Monitor are fully configured.

## Task 4: Secure Application Endpoints

**Step 1: Enforce HTTPS-only**

1. In the Azure portal, open **contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>**.
2. In the left navigation, select **Configuration** > **General settings**.
3. Set **HTTPS Only** to **On**.
4. Set **Minimum TLS Version** to **1.2**.
5. Select **Save**.

   ![](../media/appservice-https-only.png)

**Step 2: Verify HTTPS enforcement**

1. Open a browser and navigate to `http://contoso-web-<DeploymentID>.azurewebsites.net` (HTTP, not HTTPS).
2. Verify the browser automatically redirects to `https://contoso-web-<DeploymentID>.azurewebsites.net`.

**Step 3: Review and update access restrictions**

1. In the App Service, select **Networking** > **Access restriction** (under Inbound traffic).
2. Review the existing access restrictions created in Exercise 2.
3. Add additional rules as needed:

   | Name | Action | Priority | Type | Source |
   | --- | --- | --- | --- | --- |
   | `AllowAzureFrontDoor` | Allow | 200 | Service Tag | AzureFrontDoor.Backend |
   | `DenyAll` | Deny | 2147483647 | Any | (default unmatched rule) |

4. Select **Save**.

**Step 4: Configure custom domain with managed certificate (optional)**

1. If a custom domain is available, navigate to **Custom domains** in the App Service.
2. Select **+ Add custom domain**.
3. Enter the custom domain name and validate ownership.
4. After validation, select **Add binding** and choose **App Service Managed Certificate** (free).
5. Set binding type to **SNI SSL**.

> Note: Custom domain configuration is optional for this lab. The default `*.azurewebsites.net` domain already has TLS enabled.

**Step 5: Final security validation**

Run the following checks to confirm all security controls are in place:

| Check | Expected Status | How to Verify |
| --- | --- | --- |
| HTTPS Only | On | Configuration > General settings |
| Minimum TLS Version | 1.2 | Configuration > General settings |
| Remote debugging | Off | Configuration > General settings |
| Access restrictions | At least 1 Allow rule + default Deny | Networking > Access restriction |
| VNet integration | Connected | Networking > VNet integration |
| Defender for App Service | On | Defender for Cloud > Environment settings |
| Application Insights | Connected | App Service > Application Insights |
| Alert rule | Active | Monitoring > Alerts |
| Azure Policy | Assigned (4 policies) | Policy > Assignments |
| RBAC | Configured | IAM > Role assignments |

   ![](../media/security-checklist.png)

All security and governance controls are in place.

Evidence to capture:

- Screenshot of Azure Policy compliance page showing all four policies assigned.
- Screenshot of RBAC role assignments on the resource group.
- Screenshot of Defender for Cloud overview with security posture score.
- Screenshot of Application Insights overview dashboard.
- Screenshot of HTTPS Only configuration enabled.

![Azure Policy compliance page showing four assigned policies](../media/ex4-policy-compliance.png)
> Save your screenshot as `media/ex4-policy-compliance.png`

![RBAC role assignments showing Website Contributor, Reader, SQL DB Contributor, and Monitoring Contributor](../media/ex4-rbac-assignments.png)
> Save your screenshot as `media/ex4-rbac-assignments.png`

![Microsoft Defender for Cloud overview with security posture score](../media/ex4-defender-overview.png)
> Save your screenshot as `media/ex4-defender-overview.png`

![Application Insights overview dashboard showing server response time and requests](../media/ex4-appinsights-dashboard.png)
> Save your screenshot as `media/ex4-appinsights-dashboard.png`

## Success Criteria

- Four Azure Policies assigned to `rg-migration-lab`: HTTPS enforcement, latest TLS, remote debugging off, and resource logging.
- Policy compliance evaluation initiated (or fully compliant).
- `AppServiceOperators` security group created with appropriate RBAC roles.
- RBAC roles assigned: Website Contributor, Reader, SQL DB Contributor, and Monitoring Contributor.
- Microsoft Defender for Cloud enabled for App Service, Azure SQL, and Resource Manager.
- Application Insights resource created and connected to the App Service.
- Azure Monitor alert rule created for HTTP 5xx error rate.
- HTTPS Only set to **On** with minimum TLS version **1.2**.
- Remote debugging set to **Off**.
- Access restrictions configured with at least one Allow rule and default Deny.
- Final security validation checklist completed with all checks passing.

## Learning Outcomes

- Assign and evaluate built-in Azure Policies for App Service compliance.
- Configure role-based access control (RBAC) using least-privilege principles.
- Enable Microsoft Defender for Cloud plans for application and data security.
- Create and connect Application Insights for application performance monitoring.
- Configure Azure Monitor alert rules for proactive incident detection.
- Enforce HTTPS and TLS security on App Service endpoints.
- Perform a comprehensive security posture validation.

## References

- Azure Policy built-in definitions for App Service: https://learn.microsoft.com/azure/app-service/policy-reference
- Azure RBAC overview: https://learn.microsoft.com/azure/role-based-access-control/overview
- Azure RBAC built-in roles: https://learn.microsoft.com/azure/role-based-access-control/built-in-roles
- Microsoft Defender for Cloud: https://learn.microsoft.com/azure/defender-for-cloud/defender-for-cloud-introduction
- Defender for App Service: https://learn.microsoft.com/azure/defender-for-cloud/defender-for-app-service-introduction
- Application Insights overview: https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview
- Azure Monitor alerts: https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-overview
- App Service security best practices: https://learn.microsoft.com/azure/app-service/overview-security
- Configure TLS mutual authentication: https://learn.microsoft.com/azure/app-service/app-service-web-configure-tls-mutual-auth
