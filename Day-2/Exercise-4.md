# HOL 1: Exercise 3: Migrating your applications and data by utilizing Microsoft services and tools, such as Azure Migrate: Server Migration

### Estimated duration: 60 Minutes

## Overview

In this exercise, you will learn about Azure migration and how all pre-migration steps, such as discovery, assessments, and right-sizing of on-premises resources, are included for infrastructure, data, and applications. Azure Migrate provides a simplified migration, modernization, and optimization service for Azure.

## Objectives

In this exercise, you will complete the following tasks:

- Task 1: Create a Storage Account
- Task 2: Register the Hyper-V Host with Migration and modernization
- Task 3: Enable Replication from Hyper-V to Azure Migrate
- Task 4: Configure Networking
- Task 5: Server migration

## Task 1: Create a Storage Account

In this task, you will create a new Azure Storage Account that will be used by Migration and for the storage of your virtual machine data during migration.

> **Note:** This lab focuses on the technical tools for workload migration, but in real-world scenarios, a comprehensive long-term plan is needed. Considerations for the landing zone should include network traffic, access control, resource organization, and governance. The CAF Migration and Foundation Blueprints can help deploy a pre-defined landing zone using Infrastructure as Code (IaC) for resource management. For more details, refer to [Azure Landing Zones](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/) and the [Cloud Adoption Framework Azure Migration landing zone Blueprint sample](https://docs.microsoft.com/azure/governance/blueprints/samples/caf-migrate-landing-zone/).

1. In the Azure portal, in the search bar at the top, type **Storage account** **(1)** and select **Storage accounts** **(2)** from the Services list.

   ![](./15-7-25-l3-1.png)
 
1. On the **Storage center | Storage accounts (Blobs)** page, click **Create** to start creating a new storage account.

    ![](Images/lab3-new.png)

1. In the **Create a storage account** page , on the **Basics** tab, enter the following values:

   - Subscription: **Select your Azure subscription (1)**.
  
   - Resource group: **AzureMigrateRG (2)**
  
   - Storage account name: **migrationstorage<inject key="DeploymentID" enableCopy="false" /> (3)**

   - Region: Select **<inject key="Region" enableCopy="false" /> (4)** from the dropdown.

   - Preferred storage type: **Azure Blob Storage or Azure Data Lake Storage Gen 2 (5)**

   - Performance: **Standard (6)**
  
   - Redundancy: **Locally-redundant storage (LRS) (7)**

   - Click **Review + create** to continue **(8)**

     ![Screenshot of the Azure portal showing the create storage account blade.](Images/create-storage-3012.png "Storage account settings")

1. On the **Review + create** tab, verify the entered details. Click **Create** to deploy the storage account.

    ![](15-7-25-l3-4.png)

1. Once the storage account is successfully deployed, select **Go to resource** to open the newly created storage account.

    ![](15-7-25-l3-5.png)

1. On the **Storage account** page, under **Data management (1)**, select **Data protection (2)** from the left-hand menu and then under the **Recovery** section, **uncheck** the boxes for **Enable soft delete for blobs (3)** and **Enable soft delete for containers (4)**, then click on **Save (5)**.
   
   ![](15-7-25-l3-6.png)

## Task 2: Register the Hyper-V Host with Migration and modernization

In this task, you will register the Hyper-V host (LabVM) with the Azure Migrate: Server Migration service using Azure Site Recovery for migration.

1. Navigate to the **Azure Migrate** page in the Azure portal. From the left navigation pane, select **All projects**, and then choose **SmartHotelMigration<inject key="DeploymentID" enableCopy="false" />** and scroll down. Then click on **Click here** to view details in the old experience.

     ![](Images/AIM-image40.png)

1. On the  **Azure Migrate | Servers, databases and web apps** page, expand **Migration goals (1)** from the left menu, then select **Servers, databases and web apps (2)**. Scroll down, under **Migration tools**, click **Discover (3)**.
   
     ![](./15-7-25-l3-7.png)

1. On the **Discover** pane, provide the following configuration:

   - For **Where do you want to migrate to?**, select **Azure VM (1)**.
   - For **Are your machines virtualized?**, select **Yes, with Hyper-V (2)**.
   - For **Target region**, select **<inject key="Region"></inject>** **(3)** (make sure this matches the region of your Resource Group).
   - Check the box to **Confirm the target region for migration is **<inject key="Region"></inject>** (4)**.
   - Click **Create resources (5)** to deploy the necessary Azure Site Recovery resources.

     ![Screenshot of the Azure portal showing the 'Discover machines' panel from Azure Migrate.](./15-7-25-l3-8.png "Discover machines - source hypervisor and target region")

     > **Note:** Once deployment is complete, the 'Discover machines' panel should be updated with additional instructions.
  
1. On the **Discover** pane, under **Prepare Hyper-V host servers**, click the **Download** link to download the **Azure Site Recovery Provider** installer.

     ![Screenshot of the Discover machines' panel from Azure Migrate, highlighting the download link for the Hyper-V replication provider software installer.](./15-7-25-l3-9.png "Replication provider download link")

1. Return to the **Discover** page and click the blue **Download** button to download the **registration key file**.

     ![Screenshot of the Discover machines' panel from Azure Migrate, highlighting the download link Hyper-V registration key file.](./15-7-25-l3-10.png "Download registration key file")

1. Open the **AzureSiteRecoveryProvider.exe** installer you downloaded a moment ago. On the **Microsoft Update** tab, select **Off (1)** and click on **Next (2)**. On the **Installation** screen, accept the default installation location and click **Install** to begin installation.

    ![](./15-7-25-l3-11.png)

    ![](15-7-25-l3-12.png)

    > **Note:** If you are prompted with a pop-up, like the latest version of the Provider is installed on this server. Would you like to proceed to registration? select **Yes**. (You can directly jump to the next step in that case.)

1. When the installation has completed, on the **Installation** pane, click on **Register**.

   ![](15-7-25-l3-13.png)
   
1. On the **Vault Settings** page, click **Browse (1)** to locate the registration key file you downloaded earlier. In the **Open** dialog, select the downloaded registration key file **(2)**, then click **Open (3)**. Once the key file is loaded, click **Next (4)** to proceed with the registration process.

   ![](15-7-25-l3-15.png)

   ![](15-7-25-l3-14.png)

1. On the **Proxy Settings** pane, select **Connect directly to Azure Site Recovery without a proxy server (1)**, then click **Next (2)** to proceed. This will initiate the registration of the Hyper-V host with Azure Site Recovery.

     ![Screenshot of the ASR provider registration settings.](15-7-25-l3-16.png)

1.  On the **Registration** pane, wait for the message **The server was registered in the Azure Site Recovery vault** to appear. Once registration is complete, select **Finish** to close the wizard.

     ![Screenshot of the ASR provider showing successful registration.](15-7-25-l3-17.png "Registration complete")

    >**Note:** The registration may take about 2-3 minutes to complete.

1. Return to the **Azure Migrate** browser window. Refresh the page, then under **Migration and modernization**, select **Discover** to reopen the panel.
    
      - Set **Where do you want to migrate to?** to **Azure VM (1)**
      - Set **Are your machines virtualized?** to **Yes, with Hyper-V (2)**
      - Select **Finalize registration (3)**

        ![Screenshot of the Discover machines' panel from Azure Migrate, highlighting the download link Hyper-V registration key file.](Images/infra-l3-1.png "Finalize registration")

1. Azure Migrate will now complete the registration with the Hyper-V host. **Wait** for the registration to complete. This may take 10-15 minutes.

     ![Screenshot of the 'Discover machines' panel from Azure Migrate, showing the 'Finalizing registration...' message.](Images/upd-discover-6.png "Finalizing registration...")

1. Once registration is complete, confirm the status shows **Registration finalized (1)** under **Registered Hyper-V hosts**. Select **Close (2)** to exit the **Discover machines** panel.

     ![Screenshot of the 'Discover machines' panel from Azure Migrate, showing the 'Registration finalized' message.](15-7-25-l3-18.png "Registration finalized")

1. On the  **Azure Migrate | Servers, databases and web apps** page, In the left-hand navigation pane, expand **Migration goals (1)**, then select **Servers, databases and web apps (2)**. In the **Migration tools** section under **Migration and modernization**, verify that the **Discovered servers** count displays **7** **(3)**.

     ![Screenshot of the 'Azure Migrate - Servers' blade showing 6 discovered servers under 'Azure Migrate: Server Migration'.](15-7-25-l3-19.png "Discovered servers")

     > **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
     > - Hit the Inline Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
     > - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
     > - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help.

     <validation step="2eb6b36f-a031-40f0-8bad-a1748a3c532a" />

### Task 3: Enable Replication from Hyper-V to Azure Migrate

In this task, you will configure and enable the replication of your on-premises virtual machines from Hyper-V to the Azure Migrate Server Migration service.

1. On the  **Azure Migrate | Servers, databases and web apps** page, In the left-hand navigation pane, expand **Migration goals (1)**, then select **Servers, databases and web apps (2)**. In the **Migration tools** section under **Migration and modernization**, select **Replicate** **(3)**.

     ![Screenshot highlighting the 'Replicate' button in the 'Azure Migrate: Server Migration' panel of the Azure Migrate - Servers blade.](15-7-25-l3-20.png "Replicate link")
   
1. On the **Specific Intent** page, select the following details:

    -  What do you want to migrate? : Select **Servers or Virtual machines (VM)** **(1)**
    -  Where do you want to migrate to? : Select **Azure VM** **(2)**
    -  Are your machines virtualized? : Select **Yes, with Hyper-V (3)**
    -  Click on **Continue (4)**

       ![](15-7-25-l3-21.png)

1. On the **Replicate** page, in the **Virtual machines** tab, select **Standard or trusted launch Virtual Machine (1)** under **Target VM security type** section, then under **Import migration settings from an assessment** section, select **Yes, apply migration settings from an Azure Migrate assessment (2)** and select the **SmartHotelAssessment (3)** migration assessment.

     ![Screenshot of the 'Virtual machines' tab of the 'Replicate' wizard in Azure Migrate Server Migration. The Azure Migrate assessment created earlier is selected.](15-7-25-l3-22.png "Replicate - Virtual machines")

1. The **Virtual machines** tab should now show the virtual machines included in the assessment. Select the **UbuntuWAF**, **smarthotelweb1**, and **smarthotelweb2** virtual machines **(1)**, then select **Next (2)**.

     ![Screenshot of the 'Virtual machines' tab of the 'Replicate' wizard in Azure Migrate Server Migration. The UbuntuWAF, smarthotelweb1, and smarthotelweb2 machines are selected.](15-7-25-l3-23.png "Replicate - Virtual machines")

1. On the **Target settings** tab, select the information below,

   - **Subscription**: Select your subscription **(1)**
   - **Resource group**: Select the existing **SmartHotelHostRG (2)**
   - **Cache storage account**: Choose the storage account here from the drop-down that you created in task 1 **(3)**. 
   - **Virtual network**: Select **SmartHotelVNet (4)**. 
   - **Subnet**: Select **SmartHotel (5)**. 
   - **Availability option:** Select **No infrastructure redundancy required (6)**
   - Leave other values as default and select **Next (7)**.

        >**Note:** If the **Cache storage account** option is not visible, please wait for 5 minutes, refresh the browser, and then check again.
   
     ![Screenshot of the 'Target settings' tab of the 'Replicate' wizard in Azure Migrate Server Migration. The resource group, storage account and virtual network created earlier in this exercise are selected.](Images/infra-l3-2.png)

     > **Note:** For simplicity, in this lab, you will not configure the migrated VMs for high availability, since each application tier is implemented using a single VM.
     
     > **Note:** If you encounter any errors while selecting the storage account, please follow these steps:

        - Select the storage account **migrationstorage<inject key="DeploymentID" enableCopy="false" />**
          
        - click **Data Management(1)** and, choose **Object replication (2)**
          
        - In the **Advanced Settings (3)** section , enable **Allow cross-tenant replication (4)** and click **OK (5)**
          
          ![](Images/ms-1.png)

1. On the **Compute** tab, configure the following settings for each virtual machine:

   - Select the **Azure VM Size** to **Standard_F2s_v2** for all VMs **(1)**. 
   - Select **OS Type** `Windows` and **Operating System** `Windows Server 2019` for the **smarthotelweb1**, **smarthotelweb2** virtual machines.
   - Select the **Linux** operating system for the **UbuntuWAF** virtual machine. 
   - Click **Next (2)** to proceed. 

     ![](15-7-25-l3-25.png "Replicate - Compute")
    
1. In the **Disks** tab, review the settings but do not make any changes. Select **Next** ,then select **Next** in the **Tags** tab, and verify the configuration details, then select **Replicate** to start the server replication.

    ![](15-7-25-l3-26.png)
    ![](15-7-25-l3-27.png)

1. On the **Migration tools**, under **Migration and modernization**, select the **Overview** button.

    ![](15-7-25-l3-28.png)
    
1. On the **Azure Migrate: Server Migration** page, confirm that the number next to Azure VM under the **Replicate** section shows 3, indicating three machines are replicating.

     ![Screenshot of the 'Azure Migrate: Server Migration' overview blade showing the replication state as 'Healthy' for 3 servers.](Images/infra-l3-3.png "Replication summary")

1. In the **Azure Migrate: Server Migration** page, expand the **Migration (1)** section in the left-hand menu and select **Replications (2)**. Select **Refresh (3)** occasionally and wait until all three machines have a **Protected (4)** status, which shows the initial replication is complete. This will take **15 - 20** minutes.

     ![Screenshot of the 'Azure Migrate: Server Migration - Replicating machines' blade showing the replication status as 'Protected' for all 3 servers.](Images/infra-l3-4.png "Replication status")

    > **Note**: Please make sure you run the **validation steps** for this task before moving to the next tasks, as there are a few dependencies. **Not** running the validation after performing this task will result in **validation failure** as the status of the Virtual Machine will be changed from **Protected** to **Planned failover** when you migrate the servers in Task 5.

     > **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
     > - Hit the Inline Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
     > - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
     > - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help.

     <validation step="b38db9a2-1678-47a6-a053-c863b83f8ada" />

### Task 4: Configure Networking

In this task, you will modify the settings for each replicated VM to use a static private IP address that matches the on-premises IP addresses for that machine.

1. In the **Azure Migrate: Server Migration** page, select the **smarthotelweb1** virtual machine. This opens a detailed migration and replication blade for this machine. Take a moment to study this information.

    ![Screenshot from the 'Azure Migrate: Server Migration - Replicating machines' blade with the smarthotelweb1 machine highlighted.](Images/15-7-25-l2-31.png "Replicating machines")

1. On the left menu, expand **General (1)** and select **Compute and Network (2)**. Under the **Microsoft Azure** column, verify the **Size** is set to **F2s_v2** **(3)**.

    ![Screenshot of the smarthotelweb1 blade with the 'Compute and Network' and 'Edit' links highlighted.](Images/15-7-25-l2-32.png "Edit Compute and Network settings")

1. In the **Compute and Network** section, scroll down to the **Network interfaces**. Select the **pencil icon** (✏️) next to the NIC name.
    
    ![Screenshot showing the link to edit the network interface settings for a replicated VM.](Images/15-7-25-l2-33.png "Network Interface settings link")

1. In the **Network interface** settings:

    - Under **IP address type**, select **Static** **(1)**.
    - In the **Private IP address** field, enter: `192.168.0.4` **(2)**.
    - Select **Apply** **(3)** to save the changes.

       ![Screenshot showing a private IP address being configured for a replicated VM in ASR.](Images/15-7-25-l2-34.png "Network interface - static private IP address")

1. Select **Save** to apply the changes to the VM's configuration.

    ![](Images/15-7-25-l2-35.png)

1. Repeat these steps to configure the private IP address for the other VMs.
 
   - For **smarthotelweb2** use private IP address **192.168.0.5**
  
   - For **UbuntuWAF** use private IP address **192.168.0.8**

> **Note**: Azure Migrate makes a "best guess" at the VM settings, but you have full control over the settings of migrated items. In this case, setting a static private IP address ensures the virtual machines in Azure retain the same IPs they had on-premises, which avoids having to reconfigure the VMs during migration (for example, by editing web.config files).

### Task 5: Server migration

In this task, you will perform a migration of the UbuntuWAF, smarthotelweb1, and smarthotelweb2 machines to Azure.

> **Note**: In a real-world scenario, you would perform a test migration before the final migration. To save time, you will skip the test migration in this lab. The test migration process is very similar to the final migration.

1. On the **Azure Migrate: Server Migration** page, click on **Overview (1) section** and under **Migrate to Azure**, select **Migrate (2)**.

    ![](Images/15-7-25-l2-36.png)

1. On the **Specify Intent** page, select **Azure VM (1)** for **Where do you want to migrate to?** and click on **Continue (2)**

    ![](Images/15-7-25-l2-37.png)
   
1. On the **Migrate** page, select the 3 VMs **(1)**, choose **Yes, Shutdown virtual machines (Ensure no data loss) (2)** under the **Shutdown virtual machines** section, and click **Migrate (3)** to start the migration.

    ![Screenshot of the 'Migrate' blade, with 3 machines selected and the 'Migrate' button highlighted.](Images/15-7-25-l2-38.png)

   > **Note**: You can optionally choose whether the on-premises virtual machines should be automatically shut down before migration to minimize data loss. Either setting will work for this lab.

1. On the **Azure Migrate: Server Migration** page, to monitor progress, expand **Migration (1)** on the left menu and select **Jobs (2)** and review the status of the three **Planned failover (3)** jobs.

    ![Screenshot showing the **Jobs* link and a jobs list with 3 in-progress 'Planned failover' jobs.](Images/15-7-25-l2-39.png "Migration jobs")

1. **Wait** until all three **Planned failover** jobs show a **Status** of **Successful**. You should not need to refresh your browser. This could take up to **15 minutes**.

    ![Screenshot showing the **Jobs* link and a jobs list with all 'Planned failover' jobs successful.](Images/15-7-25-l2-40.png "Migration status")

1. Navigate to the resource group, on the **Resource group** page, select the **SmartHotelHostRG** resource group. and check that the VM, network interface, and disk resources have been created for each of the virtual machines being migrated.

    ![](Images/infra-l3-5.png)
   
1. On the **SmartHotelHostRG** resource group, verify that the VM, network interface, and disk resources have been created for each migrated virtual machine.

   ![](Images/infra-l3-6.png)

     > **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
     > - Hit the Inline Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
     > - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
     > - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help.

     <validation step="db5d197a-151d-4987-8011-9568dc93e642" />

## Summary 

In this exercise, you created a new Azure Storage Account that was used for Migration and modernization. You registered your Hyper-V host with the Azure Migrate Server Migration service. You enabled replication of your on-premises virtual machines from Hyper-V to the Azure Migrate Server Migration service. You configured networking for the replicated VMs to use static private IP addresses. Finally, you performed the migration of the virtual machines to Azure.

Click on **Next** from the lower right corner to move on to the next page.

![](Images/infra-s7.png)
