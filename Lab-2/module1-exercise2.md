# HOL 1: Exercise 2: Set up your Environment on Azure to Migrate Servers

### Estimated duration: 40 Minutes

## Overview

In this exercise, you will assess the migration readiness of the SmartHotel application using Azure Migrate. First, you will create an assessment for selected VMs, setting up and grouping them to generate a report that shows whether they're ready for migration to Azure.

Next, you will configure dependency visualization by installing monitoring agents on the VMs. This will help you map out and understand the dependencies between different application parts, ensuring everything works properly before migrating to Azure.

## Objectives

In this exercise, you will complete the following tasks:

- Task 1: Create a migration assessment
- Task 2: Configure dependency visualization

### Task 1: Create a migration assessment

In this task, you will create a migration assessment for the SmartHotel application using Azure Migrate. The assessment will help you evaluate the readiness of the on-premises VMs for migration to Azure.

1. On **Assessments tools**, under **Azure Migrate: Discovery and assessment**, click on **Assess** **(1)** and select **Azure VM** **(2)** from the dropdown to start a new migration assessment.

   ![Screenshot of the Azure Migrate portal blade, with the '+Assess' button highlighted.](Images/15-7-25-l2-1.png "Start assessment")

1.  On the **Basics** tab, ensure the **Assessment type** is set to **Azure VM** **(1)** and the **Discovery source** as **Servers discovered from Azure Migrate appliance** **(2)**. Then under **Assessment settings**, click on **Edit** **(3)**.

    ![Screenshot of the Azure Migrate 'Assess servers' blade, showing the assessment name.](Images/15-7-25-l2-2.png "Assess servers - assessment name")

1. On the **Infrastructure settings** page, under **Target settings**, the **Assessment settings** blade allows you to tailor many settings used when making a migration assessment report. Take a few moments to explore the wide range of assessment properties. Hover over the information icons to view more details for each setting. Choose any settings you prefer, then click **Save** to apply them.

   > **Note**: You must make at least one change for the **Save** button to be enabled. If you don’t want to make any changes, simply close the blade.

     ![](Images/15-7-25-l2-3.png)

1. Click on **Next: Select servers to assess >** to proceed to the next tab, and on the **Select servers to assess** tab, enter the following:

     - **Assessment name**: `SmartHotelAssessment` **(1)**
     - Under **Select or create a group**, select **Create new** **(2)**
     - Enter **Group name** as **SmartHotel VMs** **(3)**.
     - From the **Appliance name** dropdown, select **SmartHotelAppl (Hyper-V)** **(4)**.
     - Select the **smarthotelweb1**, **smarthotelweb2**, **UbuntuWAF**, and **redhat** VMs **(5)**
     - Click on **Next: Review + create assessment >** **(6)** to continue.
  
         ![](Images/lab2-new.png) 
       
        > **Note**: There is no need to include the **smarthotelSQL1**, **AzureMigrateAppliance** and other VMs in the assessment, since they will not be migrated to Azure.
        
        > **Note**: Please note that even though we are adding **Redhat** VM to the assessment here, we will not be setting up our environment in Redhat VM in this exercise. Users will review the assessment and perform all the steps for environment setup in HOL2.
    
1. On the **Review + create assessment** tab, verify the configuration details and Click on **Create assessment** to create the assessment.

    ![](Images/15-7-25-l2-6.png)

1. In Azure Migrate, on the **Servers, databases, and web apps** page, Expand **Migration goals** **(1)** from the left navigation menu. Select **Servers, databases and web apps** **(2)**. Click on **Refresh** periodically **(3)** until the number of assessments under **Assessments > Total** updates to **1** (This may take a few minutes). Then click on the nuber **1 (4)**.  

    ![Screenshot from Azure Migrate showing the number of assessments as '1'.](Images/L1E2T1S6-3012.png "Azure Migrate - Assessments (count)")

1. On the **Azure Migrate: Discover and assessment | Assessments** page, click on the **SmartHotelAssessment** assessment to view its details.

    ![](Images/L1E2T1S7-3012.png)    

     > **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
     > - Hit the Inline Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
     > - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
     > - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help.

     <validation step="a562ccd3-36aa-4650-afc6-05e2048bc3f2" />

### Task 2: Configure dependency visualization

When migrating a workload to Azure, it is important to understand all workload dependencies. A broken dependency could mean that the application does not run properly in Azure, perhaps in hard-to-detect ways. Some dependencies, such as those between application tiers, are obvious. Other dependencies, such as DNS lookups, Kerberos ticket validation, or certificate revocation checks, are not.

In this task, you will configure the Azure Migrate dependency visualization feature. This requires you to first create a Log Analytics workspace and then deploy agents on the to-be-migrated VMs.

1. Return to the **Azure Migrate** blade in the Azure portal, Select **Servers, databases and web apps** **(1)** under **Migration goals** section. Under **Discovery and assessment**, click on the number next to **Groups** **(2)** to view the available groups.

   ![](Images/15-7-25-l2-9.png)

1. On the **Azure Migrate: Discovery and assessment** page, expand the **Manage (1)** section and select **Groups** **(2)**. Click on the **SmartHotel VMs** group to view its details **(3)**. 

    ![](Images/15-7-25-l2-10.png)

1. In the **SmartHotel VMs** group details page. Note that each VM shows **Dependencies** status as **Requires agent installation**. Click on **Requires agent installation** for the **smarthotelweb1** VM to proceed with agent setup.

    ![](Images/infra-l1-3.png)

1. On the **Dependencies** tab, click on **Configure Log Analytics workspace**.

    ![Screenshot of the Azure Migrate 'Dependencies' blade, with the 'Configure OMS Workspace' button highlighted.](Images/15-7-25-l2-12.png "Configure OMS Workspace link")

1. On the **Configure Log Analytics workspace** screen, provide the following and Click on **Configure** **(4)** to proceed.

   - **Log Analytics workspace**: Select **Create new** **(1)** and enter the name **AzureMigrateWS<inject key="DeploymentID" enableCopy="false" /> (2)**
   - **Log Analytics workspace location**: Select **East US (3)** from the dropdown. 

        ![Screenshot of the Azure Migrate 'Configure OMS workspace' blade.](Images/15-7-25-l2-13.png "OMS Workspace settings")

1. Once the Log Anlytics workspace is created, on the **Dependencies** page, scroll down and copy the **Workspace ID (1)** and **Primary Key (2)** and store in a Notepad for further use. 

    ![Screenshot of the Azure Migrate 'Configure OMS workspace' blade.](Images/L1E2T2S6-3012.png "OMS Workspace settings")

     > **Note**: If you don't see the workspace ID and key here. You can attempt to close and reopen the Workspace, or you can try refreshing the browser page. This may have been caused by a temporary error in the portal.

1. On the **Dependencies** screen, under **Step 1**, right-click to copy the download links for **Windows 64-bit** and **Linux** versions of the **Microsoft Monitoring Agent (1)**, then under **Step 2**, copy the links for the **Windows 64-bit** and **Linux** versions of the **Dependency Agent (2)**, and save them along with the previously noted **Workspace ID** and **Primary Key** .
   
   ![Screenshot of the Azure Migrate 'Dependencies' blade with the 4 agent download links highlighted.](Images/15-7-25-l2-16.png)

1. In the **Hyper-V Manager** console, from the list of virtual machines, select **smarthotelweb1** **(1)**. In the right-hand **Actions** pane, click **Connect** **(2)** to launch the VM console. 

    ![](Images/15-7-25-l2-17.png)

1. When the **Connect to smarthotelweb1** window appears, click **Connect** to continue. Log in to the **Administrator** account using the password **<inject key="SmartHotel Admin Password" />**.

    ![](Images/15-7-25-l2-18.png)

    ![](Images/infra-l1-5.png)

1. On the **smarthotelweb1** VM. Open **Internet Explorer** from the **Start** menu. Paste the link to the **64-bit Microsoft Monitoring Agent for Windows** that you saved earlier. Once the download completes, click one **Save (1)** and then **Run (2)** when prompted to start the installer.

    ![](Images/L1E2T2S11.2-3012.png)

    ![Screenshot showing the Internet Explorer prompt to run the installer for the Microsoft Monitoring Agent.](Images/L1E2T2S11.3-3012.png)

     >**Note:** If a Security alert window opens, select the **checkbox (1)** and click on **Yes (2)** to proceed.

    ![](Images/L1E2T2S11.1-3012.png)

     >**Note**: Please install the Agents as mentioned in the lab guide on both **SmartHotelWeb1** and **SmartHotelWeb2** VMs. Read the instructions carefully to avoid mistakes.

1. On the **Welcome to the Microsoft Monitoring Agent Setup Wizard** screen, select **Next**. 

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/L1E2T2S12-3012.png "MMA installation")

1. On the **Microsoft Software License Terms** screen, select **I Agree**.

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/L1E2T2S13-3012.png "MMA installation")

1. On the **Destination Folder** screen, leave everything as default and select **Next**. 

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/15-7-25-l2-20.png "MMA installation") 

1. On the **Agent Setup Options** screen, select **Connect the agent to Azure Log Analytics (OMS) (1)** and click **Next (2)**.

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/15-7-25-l2-21.png "MMA installation") 

1. On the **Azure Log Analytics** screen, enter the **Workspace ID** and **Workspace Key** **(1)** that you copied earlier and then select **Next (2)**.

    ![Screenshot of the Microsoft Monitoring Agent install wizard, showing the Log Analytics (OMS) workspace ID and key.](Images/15-7-25-l2-22.png)

1. On the **Microsoft Update** screen, leave everything as default and select **Next**. 

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/infra-l1-7.png "MMA installation")

1. On the **Ready to Install** screen, click on **Install**. 

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/15-7-25-l2-23.png "MMA installation")

1. On the **Microsoft Monitoring Agent configuration completed successfully** screen, click **Finish** to complete the installation.

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/15-7-25-l2-24.png "MMA installation")

1. Open **Internet Explorer** and paste the link to the **Windows Dependency Agent** installer. When prompted, click **Save** to download the file. Once the download is complete, click **Run** to launch the installer.

    ![](Images/15-7-25-l2-25.png)
    ![](Images/15-7-25-l2-26.png)

    >**Note:** If a Internet exploerer securtity window opens, click on **Add (1)**, then **Add (2)** again to add the site, and then click on **Close (3)**. 

      ![](Images/L1E2T2S19.1-3012.png)

      ![](Images/L1E2T2S19.2-3012.png)


1. On the **License Agreement** screen, select **I Agree** to accept the agreement and continue. 

    ![Screenshot for installing Dependency Agent.](Images/infra-l1-8.png "Dependency Agent installation") 

1. On the **Completing Dependency Agent Setup** screen, select **Finish** to finish the installation process.

    ![Screenshot for installing Dependency Agent.](Images/infra-l1-9.png "Dependency Agent installation") 

    > **Note**: You do not need to configure the workspace ID and key when installing the Dependency Agent, since it uses the same settings as the Microsoft Monitoring Agent, which must be installed beforehand.

1. Minimize the Virtual Machine connection window for the **SmartHotelWeb1** VM. Connect to the **smarthotelweb2 VM** and repeat the installation process (steps 10-21) for both agents (the administrator password is the same as for smarthotelweb1). Minimize the virtual machine connection window for the **smarthotelweb2 VM** once the installation of agents is done.

1. Open the **smarthotelweb1** connection windowVM on the desktop, type **cmd (1)** in the search bar and select **Command Prompt (2)** from the results to open a terminal window.

     ![](Images/infra-l1-10.png)
    
     > **Note**: The SmartHotelHost runs Windows Server 2019 with the Windows Subsystem for Linux enabled. This allows the command prompt to be used as an SSH client. More info on supported Linux on Azure can be found here: https://Azure.com/Linux. 

1. Enter the following command to connect to the **UbuntuWAF** VM running in Hyper-V on the SmartHotelHost:

    ```bash
    ssh demouser@192.168.0.8
    ```
    > **Note**: If Ctrl + V does not work in Command Prompt, right-click inside the window or press Shift + Insert to paste the command.
    
1. Enter 'yes' when prompted whether to connect. Enter the password **<inject key="SmartHotel Admin Password" />**.

    ![Screenshot showing the command prompt with an SSH session to UbuntuWAF.](Images/ssh.png "SSH session with UbuntuWAF")

    >**Note**: The Command Prompt does not display password characters while typing. This is normal. Simply paste your password into the window and press Enter.

1. Enter the following command, followed by the password **<inject key="SmartHotel Admin Password" />** when prompted:
  
    ```
    sudo -s
    ```

    > This gives the terminal session elevated privileges.

1. Enter the following command, substituting **\<Workspace ID\> and \<Primary Key\>** with the values copied previously. Answer **Yes** when prompted to **Restart services during package upgrades without asking**. You may need to use the < arrow keys on your keyboard to choose **Yes**.

    ```
    wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w <Workspace ID> -s <Primary Key>
    ```

    ![Screenshot showing the command prompt with an SSH session to UbuntuWAF.](Images/h1-e2-t2-s28.png "SSH session with UbuntuWAF")
    
    > **Note**: If you encounter any error related to the deprecation of the log analytics agent while executing the command above, you can ignore it and proceed.
    
     ![Screenshot showing the command prompt with an SSH session to UbuntuWAF](Images/H1E2T2S28.png)

    > **Note**: However, if you encounter any other errors other than the log analytics agent, run the command below to update the packages and then repeat **Step 28**.
     
     ```
     apt-get update
     ```

31. Enter the following command, substituting \<Workspace ID\> with the value copied earlier:

    ```s
    /opt/microsoft/omsagent/bin/service_control restart <Workspace ID>
    ```

    > **Note**: If you receive any error while running the above command, run the below command to update the rebuild the directory and perform **Step 29** again.
     
     ```
      sudo sh /opt/microsoft/omsagent/bin/omsadmin.sh -w <workspaceID> -s <workspaceKey>
     ```

1. Enter the following command. This downloads a script that will install the Dependency Agent.

    ```s
    wget --content-disposition https://aka.ms/dependencyagentlinux -O InstallDependencyAgent-Linux64.bin
    ```

1. Install the dependency agent by running the script downloaded in the previous step.

    ```s
    sh InstallDependencyAgent-Linux64.bin -s
    ```

    ![Screenshot showing that the Dependency Agent install on Linux was successful.](Images/da-linux-done.png "Dependency Agent installation was successful")

1. Return to the **SmartHotel VMs** group in the **Azure Migrate** portal. Refresh the page using the **browser refresh button** (not the one in the portal UI). Verify that the **Dependency Agent** status for **smarthotelweb1**, **smarthotelweb2**, and **UbuntuWAF** shows as **Installed**. It may take up to **10 minutes** for the status to update after installation.

    ![Screenshot showing the dependency agent installed on each VM in the Azure Migrate VM group.](Images/15-7-25-l2-28.png)
   
    **Note**: If you notice that the dependency agent status is showing as **Requires Agent Installation** instead of Installed even after installing dependency agents in all three VMs, please follow the steps from [here](https://github.com/CloudLabsAI-Azure/Know-Before-You-Go/blob/main/AIW-KBYG/AIW-Infrastructure-Migration.md#4-exercise1---task6---step1) to confirm dependency agent installation in VMs using Log Analytics workspace.
 
1. In the **SmartHotel VMs** group page, click **View dependencies** to open the dependency visualization.

    ![](Images/15-7-25-l2-29.png)
   
1. Take a few minutes to explore the **Dependencies** view. Expand each server to show the processes running on that server. Select a process to see process information. See which connections each server makes.

    ![Screenshot showing the dependencies view in Azure Migrate.](Images/dependencies1.png "Dependency map")

     > **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
     > - Hit the Inline Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
     > - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
     > - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help.

     <validation step="d14e0cfe-d2dd-42a0-b16d-08a9dec2913c" />

## Summary 

In this exercise, you created and configured a migration assessment in Azure Migrate and its dependency visualization feature by creating a Log Analytics workspace and deploying the Azure Monitoring Agent and Dependency Agent on both Windows and Linux on-premises machines.

Click on **Next** from the lower right corner to move on to the next page.

![](Images/infra-s7.png)
