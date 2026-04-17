# Exercise 3: Hybrid & Disaster Recovery

## Overview

This exercise establishes hybrid connectivity for remaining on-premises components using Azure Arc, configures automated backup and recovery for the Azure App Service, implements a regional failover strategy using Azure Traffic Manager (or Azure Front Door), and validates failover readiness. This ensures business continuity for the migrated web application.

## Task 1: Configure Hybrid Connectivity (Azure Arc)

> Note: Azure Arc is used to manage remaining on-premises or multi-cloud resources from Azure. If no on-premises servers remain after migration, this task demonstrates Arc onboarding for a conceptual hybrid scenario.

**Step 1: Register Azure Arc resource providers**

1. Open **Azure Cloud Shell** (Bash) or a local terminal with Azure CLI.

2. Register the required resource providers:

```bash
az provider register --namespace Microsoft.HybridCompute
az provider register --namespace Microsoft.GuestConfiguration
az provider register --namespace Microsoft.HybridConnectivity
```

3. Verify registration status:

```bash
az provider show --namespace Microsoft.HybridCompute --query "registrationState" -o tsv
```

Wait until the status shows **Registered** (may take 1 to 2 minutes).

**Step 2: Create an Azure Arc-enabled server (conceptual / optional hands-on)**

> If you have a VM or physical server to onboard:

1. In the Azure portal, search for **Azure Arc** **(1)** and select **Azure Arc** **(2)**.

   ![](../media/arc-search.png)

2. In the left navigation, select **Machines** under **Infrastructure**.

3. Select **+ Add/Create** > **Add a machine**.

4. Select **Generate script** for **Add a single server**.

5. On the **Prerequisites** page:
   - **Subscription**: select your subscription
   - **Resource group**: `rg-migration-lab`
   - **Region**: <inject key="Region" enableCopy="false"></inject>
   - **Operating system**: select Linux or Windows as appropriate
   - **Connectivity method**: Public endpoint

6. Select **Next** through all pages, then **Download** the onboarding script.

7. Run the downloaded script on the target server to register it with Azure Arc.

8. After the script completes, verify the server appears in **Azure Arc** > **Machines** with status **Connected**.

   ![](../media/arc-connected-server.png)

> If no on-premises server is available, document the Arc onboarding process as part of the migration design and proceed to Task 2.

**Step 3: Verify hybrid resource visibility**

1. In the Azure portal, navigate to **rg-migration-lab**.
2. Confirm that Arc-enabled resources appear alongside Azure-native resources.
3. Select the Arc-enabled server and review:
   - **Properties**: OS, agent version, last heartbeat
   - **Extensions**: available Azure extensions (e.g., Log Analytics agent, Azure Monitor)
   - **Policies**: Azure Policy compliance status

Hybrid connectivity is configured (or documented for conceptual completion).

## Task 2: Configure Backup and Recovery Strategy

**Step 1: Enable App Service backup**

> Prerequisite: App Service backup requires Standard tier or higher and an Azure Storage Account for storing backup files.

1. Create a storage account for backups:

```bash
az storage account create \
  --name stgbackup<inject key="Deployment ID" enableCopy="false"></inject> \
  --resource-group rg-migration-lab \
  --location <inject key="Region" enableCopy="false"></inject> \
  --sku Standard_LRS
```

2. Create a blob container for App Service backups:

```bash
az storage container create \
  --name appservice-backups \
  --account-name stgbackup<inject key="Deployment ID" enableCopy="false"></inject>
```

3. Generate a SAS URL for the backup container:

```bash
# Set the expiry date to 1 year from now
EXPIRY=$(date -u -d "+1 year" '+%Y-%m-%dT%H:%MZ')

SAS_URL=$(az storage container generate-sas \
  --name appservice-backups \
  --account-name stgbackup<inject key="Deployment ID" enableCopy="false"></inject> \
  --permissions rwdl \
  --expiry $EXPIRY \
  --output tsv)

CONTAINER_URL="https://stgbackup<inject key="Deployment ID" enableCopy="false"></inject>.blob.core.windows.net/appservice-backups?$SAS_URL"

echo $CONTAINER_URL
```

4. Copy the full SAS URL output — needed in the next step.

**Step 2: Configure automated backup schedule**

1. In the Azure portal, open **contoso-web-<inject key="Deployment ID" enableCopy="false"></inject>**.
2. In the left navigation, select **Backups**.
3. Select **Configure**.
4. Provide the following:

   | Setting | Value |
   | --- | --- |
   | **Backup storage** | select the `stgbackup<DeploymentID>` storage account and `appservice-backups` container |
   | **Scheduled backup** | On |
   | **Backup frequency** | Every 1 day |
   | **Start time** | Current date/time |
   | **Retention (days)** | 30 |
   | **Include database** | Yes — add the Azure SQL Database connection string |

5. Select **Save**.

   ![](../media/appservice-backup-config.png)

**Step 3: Run a manual backup and verify**

1. In the **Backups** page, select **Backup now**.
2. Wait for the backup to complete (approximately 2 to 5 minutes).
3. Verify the backup appears in the list with status **Succeeded**.

   ![](../media/appservice-backup-complete.png)

**Step 4: Configure Azure SQL Database geo-restore**

1. In the Azure portal, open **sql-contoso-<inject key="Deployment ID" enableCopy="false"></inject>**.
2. In the left navigation, select **Backups**.
3. Verify automated backups are configured:
   - **Point-in-time restore retention**: 7 days (default for Basic tier)
   - **Long-term retention**: configure if needed for compliance

> Azure SQL Database performs automated backups by default. For Basic tier, point-in-time restore is available for the last 7 days. For Standard/Premium tiers, the retention period is up to 35 days.

Backup and recovery strategy is configured for both App Service and Azure SQL Database.

## Task 3: Implement Regional Failover Strategy

Implement a regional failover strategy using Azure Traffic Manager to route traffic between the primary App Service and a secondary region.

**Step 1: Create a secondary App Service in a paired region**

1. In the Azure portal, create a second App Service in a different region:

```bash
# Create a resource group in the secondary region
az group create \
  --name rg-migration-lab-secondary \
  --location <secondary-region>

# Create the secondary App Service Plan
az appservice plan create \
  --name asp-contoso-secondary \
  --resource-group rg-migration-lab-secondary \
  --location <secondary-region> \
  --sku S1 \
  --is-linux

# Create the secondary Web App
az webapp create \
  --resource-group rg-migration-lab-secondary \
  --plan asp-contoso-secondary \
  --name contoso-web-secondary-<DeploymentID> \
  --runtime "NODE:20-lts"
```

2. Deploy the same application code to the secondary App Service:

```bash
az webapp deploy \
  --resource-group rg-migration-lab-secondary \
  --name contoso-web-secondary-<DeploymentID> \
  --src-path contoso-retail-webapp.zip \
  --type zip
```

3. Configure the same Application Settings on the secondary App Service.

**Step 2: Create an Azure Traffic Manager profile**

1. In the Azure portal, search for **Traffic Manager profiles** **(1)** and select it **(2)**.

   ![](../media/traffic-manager-search.png)

2. Select **+ Create**.

3. Provide the following details:

   - **Name**: `tm-contoso-<inject key="Deployment ID" enableCopy="false"></inject>` **(1)**
   - **Routing method**: Priority **(2)** (primary/secondary failover)
   - **Subscription**: select your subscription **(3)**
   - **Resource group**: `rg-migration-lab` **(4)**

4. Select **Create**.

   ![](../media/traffic-manager-create.png)

**Step 3: Add endpoints to Traffic Manager**

1. Open the Traffic Manager profile `tm-contoso-<inject key="Deployment ID" enableCopy="false"></inject>`.
2. In the left navigation, select **Endpoints**.
3. Select **+ Add** and configure the **primary** endpoint:

   | Setting | Value |
   | --- | --- |
   | **Type** | Azure endpoint |
   | **Name** | `primary-endpoint` |
   | **Target resource type** | App Service |
   | **Target resource** | `contoso-web-<DeploymentID>` |
   | **Priority** | 1 |

4. Select **Add**.

5. Select **+ Add** again and configure the **secondary** endpoint:

   | Setting | Value |
   | --- | --- |
   | **Type** | Azure endpoint |
   | **Name** | `secondary-endpoint` |
   | **Target resource type** | App Service |
   | **Target resource** | `contoso-web-secondary-<DeploymentID>` |
   | **Priority** | 2 |

6. Select **Add**.

   ![](../media/traffic-manager-endpoints.png)

**Step 4: Configure health monitoring**

1. In the Traffic Manager profile, select **Configuration**.
2. Review and configure the health check settings:

   | Setting | Value |
   | --- | --- |
   | **Protocol** | HTTPS |
   | **Port** | 443 |
   | **Path** | `/` |
   | **Probing interval** | 10 seconds |
   | **Tolerated number of failures** | 3 |
   | **Probe timeout** | 5 seconds |

3. Select **Save**.

Traffic Manager is configured for priority-based failover routing.

## Task 4: Validate Failover Readiness

1. Open the Traffic Manager DNS name in a browser: `http://tm-contoso-<DeploymentID>.trafficmanager.net`

2. Verify the application loads successfully (traffic is routed to the primary endpoint).

3. Validate endpoint health:
   - In the Traffic Manager profile, select **Endpoints**.
   - Confirm both endpoints show **Online** health status.

   ![](../media/traffic-manager-online.png)

4. Simulate a failover (optional — test only):

   - Stop the primary App Service:
     ```bash
     az webapp stop \
       --resource-group rg-migration-lab \
       --name contoso-web-<DeploymentID>
     ```
   - Wait 30 to 60 seconds for Traffic Manager to detect the failure.
   - Refresh the Traffic Manager URL — traffic should now route to the secondary endpoint.
   - Restart the primary App Service:
     ```bash
     az webapp start \
       --resource-group rg-migration-lab \
       --name contoso-web-<DeploymentID>
     ```

5. Document the failover test results:

   | Test | Expected Result | Actual Result |
   | --- | --- | --- |
   | Primary online | Traffic routes to primary | |
   | Primary stopped | Traffic fails over to secondary within 60s | |
   | Primary restarted | Traffic returns to primary | |

Failover readiness is validated.

Evidence to capture:

- Screenshot of the Traffic Manager profile with both endpoints showing Online status.
- Screenshot of the App Service Backup page showing a successful backup.
- Screenshot of Azure Arc machines page (if applicable).

![Traffic Manager endpoints showing primary and secondary with Online status](../media/ex3-traffic-manager-endpoints.png)
> Save your screenshot as `media/ex3-traffic-manager-endpoints.png`

![App Service Backup page showing successful scheduled backup](../media/ex3-appservice-backup.png)
> Save your screenshot as `media/ex3-appservice-backup.png`

## Success Criteria

- Azure Arc resource providers registered (and optionally a server onboarded).
- App Service backup configured with daily schedule and 30-day retention using a dedicated storage account.
- Manual backup executed and verified with **Succeeded** status.
- Secondary App Service created in a paired Azure region with the same application deployed.
- Traffic Manager profile created with priority-based routing, primary and secondary endpoints configured.
- Health monitoring configured with HTTPS probes.
- Both Traffic Manager endpoints show **Online** status.
- Failover test completed (optional) with documented results.

## Learning Outcomes

- Register Azure Arc resource providers and understand the hybrid management model.
- Configure automated App Service backups with Azure Storage integration.
- Understand Azure SQL Database automatic backup and geo-restore capabilities.
- Deploy a multi-region failover architecture using Azure Traffic Manager.
- Configure health probes and validate priority-based failover routing.
- Perform and document a failover simulation test.

## References

- Azure Arc-enabled servers: https://learn.microsoft.com/azure/azure-arc/servers/overview
- App Service backup and restore: https://learn.microsoft.com/azure/app-service/manage-backup
- Azure Traffic Manager: https://learn.microsoft.com/azure/traffic-manager/traffic-manager-overview
- Azure Front Door (alternative): https://learn.microsoft.com/azure/frontdoor/front-door-overview
- Azure SQL Database automated backups: https://learn.microsoft.com/azure/azure-sql/database/automated-backups-overview
- Azure region pairs: https://learn.microsoft.com/azure/reliability/cross-region-replication-azure
