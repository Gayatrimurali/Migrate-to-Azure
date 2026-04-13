# Lab 1 - Exercise 2: Assess On-premises Workloads to set up your environment on Azure to Migrate Servers

## Lab overview

In this hands-on lab, participants will embark on the foundational steps of initiating an Azure migration project using Azure Migrate. The focus is on creating and setting up an Azure Migrate project, deploying the Azure Migrate appliance, and preparing the on-premises environment for a seamless migration to Azure.

## Lab scenario
In this Lab, you will learn how to create a migration assessment, using the Azure Migrate dependency visualization, right-sizing of on-premises resources.

## Lab objectives (Duration: 50 minutes)

In this lab, you will complete the following tasks:
+ Task 1: Create a migration assessment
+ Task 2: Configure dependency visualization

## Architecture Diagram

  ![Picture 1](Images/Assessment_of_the_servers.png)

### Task 1: Create a migration assessment

In this task, you will use Azure Migrate to create a migration assessment for the SmartHotel application, using the data gathered during the discovery phase.

1. Select **Assess (1)** under **Azure Migrate: Discovery and assessment** and click on **Azure VM (2)** to start a new migration assessment.

   ![Screenshot of the Azure Migrate portal blade, with the '+Assess' button highlighted.](Images/hol1-exe2-step1-assess.png "Start assessment")

2. On the Basics blade, ensure the Assessment type to be **Azure VM** and Discovery Source to be **Servers discovered from Migrate Appliance**. Under **Assessment settings**, select **Edit**.

   ![Screenshot of the Azure Migrate 'Assess servers' blade, showing the assessment name.](Images/upd-assessment1.png "Assess servers - assessment name")

3. The **Assessment settings** blade allows you to tailor many of the settings used when making a migration assessment report. Take a few moments to explore the wide range of assessment properties. Hover over the information icons to see more details on each setting. Choose any settings you like, then select **Save**. (You have to make a change for the Save button to be enabled; if you don't want to make any changes, just close the blade.)

   ![Screenshot of the Azure Migrate 'Assessment properties' blade, showing a wide range of migration assessment settings.](Images/upd-assessment2.png "Assessment properties")

4. Select **Next** to move to the **Select servers to assess** tab and enter the following information:
     
     1. Assessment name: Enter **MigrateServersAssessment (1)** 
     1. Select or create a group: Choose **Create New (2)**  
     1. Enter the Group name: **Hyper-V VMs (3)**
     1. Add machines to the Group:  Select **MigrateAppl(Hyper-V) (4)** from dropdown.
     1. Select the **WindowsServer**, **UbuntuServer**, and **redhat** VMs **(5)** and
     1. Click on **Next: Review+Create assessment (6)**.

   ![Screenshot of the Azure Migrate 'Assess servers' page. A new server group containing servers smarthotelweb1, smarthotelweb2, and UbuntuWAF.](Images/hol1-exe2-step4-create-assessment-select-serversv2.png "Assessment VM group")

    > **Note**: There is no need to include the **AzureArcVM**, **AzureMigrateAppliance** and other VMs in the assessment, since they will not be migrated to Azure.
    
    > **Note**: Please note that even though we are adding **redhat** VM to the assessment here, we will not be setting up our environment in redhat VM in this exercise. It is just for users to review the assessment.
    
    
5. Click on **Create assessment** to create the assessment. 

   ![](Images/hol1-exe2-step5-create-assessment.png)

6. In Azure Migrate, on the **Servers, databases, and web apps** blade, select **Refresh** periodically until the number of assessments shown is **1** (This may take few minutes). Once the assessments count is updated, click on **1** that is next to **Total** under **Assessments**.  

   ![Screenshot from Azure Migrate showing the number of assessments as '1'.](Images/hol1-exe2-step6-select-total-assessment.png "Azure Migrate - Assessments (count)")
    
7. Select **Assessments (1)** under **Azure Migrate: Discovery and assessment** to see a list of assessments. Then select the **actual assessment (2)**.

   ![Screenshot showing a list of Azure Migrate assessments. There is only one assessment in the list. It has been highlighted.](Images/hol1-exe2-step7-select-assessment-group.png "Azure Migrate - Assessments (list)")

### Task 2: Configure dependency visualization

When migrating a workload to Azure, it is important to understand all workload dependencies. A broken dependency could mean that the application does not run properly in Azure, perhaps in hard-to-detect ways. Some dependencies, such as those between application tiers, are obvious. Other dependencies, such as DNS lookups, Kerberos ticket validation or certificate revocation checks, are not.

In this task, you will configure the Azure Migrate dependency visualization feature. This requires you to first create a Log Analytics workspace, and then to deploy agents on the to-be-migrated VMs.

1. Return to the **Azure Migrate** blade in the Azure Portal, select **Servers, databases and web apps (1)**. Under **Discovery and assessment**, select **1 (2)** under **Groups**.

   ![](Images/hol1-exe2-task2-step1-select-groups.png)   

2. Under the **Groups (1)** pane, select the **Hyper-V VMs (2)** group to see the group details. 

   ![](Images/hol1-exe2-task2-step2-select-hyperv-group.png)   

3. Note that each VM has their **Dependencies** status as **Requires agent installation**. Select **Requires agent installation** for the **WindowsServer** VM.

   ![Screenshot showing the SmartHotel VMs group. Each VM has dependency status 'Requires agent installation'.](Images/hol1-exe2-task2-step3-view-require-agent-dependency.png "Hyper-V VMs server group")

4. On the **Dependencies** blade, select **Configure Log Analytics workspace**.

   ![Screenshot of the Azure Migrate 'Dependencies' blade, with the 'Configure OMS Workspace' button highlighted.](Images/hol1-exe2-task2-step4-select-configure-log-analytics-ws.png "Configure OMS Workspace link")

5. On the **Configure Log Analytics workspace** blade, provide the below information and select **Configure (4)**.

   - Log Analytics workspace: Click on **Create new (1)** and enter **AzureMigrateWS<inject key="DeploymentID" enableCopy="false" /> (2)**
   - Log Analytics workspace location: Select **Region (3)** from the dropdown in which contains virtual machine.

   ![Screenshot of the Azure Migrate 'Configure OMS workspace' blade.](Images/upd-createLAW.png "OMS Workspace settings")

6. Wait for the workspace to be deployed. Once it is deployed, navigate to **AzureMigrateWS<inject key="DeploymentID" enableCopy="false" />** by clicking on it.

   ![Screenshot of the Azure Migrate 'Configure OMS workspace' blade.](Images/hol1-exe2-task2-step6-select-created-log-analytics-ws.png "OMS Workspace settings")

7. Select **Agents (1)** under **Settings** from the left-hand side menu. Make a note of the **Workspace ID (2)** and **Primary Key (3)** (for example by using Notepad).

   ![Screenshot of part of the Azure Migrate 'Dependencies' blade, showing the OMS workspace ID and key.](Images/hol1-exe2-task2-step7-copy-wsid-and-primary-key.png "OMS Workspace ID and primary key")

8. Return to the Azure Migrate **Dependencies** blade. Copy each of the 4 agent download URLs and paste them alongside the Workspace ID and key you noted in the previous step. 
   
   ![Screenshot of the Azure Migrate 'Dependencies' blade with the 4 agent download links highlighted.](Images/hol1-exe2-task2-step8-copy-agent-download-urls.png "Agent download links")

9. From **Hyper-V Manager** console, select **WindowsServer (1)** and select **Connect (2)**.

   ![Screenshot from Hyper-V manager highlighting the 'Connect' button for the smarthotelweb1 VM.](Images/hol1-exe2-task2-step9-connect-to-windowsserver.png "Connect to smarthotelweb1")

10. Select **Connect** again when prompted and log in to the **Administrator** account using the password **<inject key="On-prem Servers Admin Password" />**.

     > **Note**: Once logged in, close the Server Manager application if it is open. You may also get a Network pop-up, select **No**.

11. Go to **Start** button in the **WindowsServer** VM and select **Internet Explorer** to open it. Paste the link to the 64-bit Microsoft Monitoring Agent for Windows, which you noted earlier. When prompted, **Run** the installer.

     > **Note**:

     >> a) You may need to disable **Internet Explorer Enhanced Security Configuration** on **Server Manager** under **Local Server** to complete the download.

     >> b) If you get **Set up Internet Explorer 11** pop-up, select **Don't use recommended settings** and then select **OK**. 

    ![Screenshot showing the Internet Explorer prompt to run the installer for the Microsoft Monitoring Agent.](Images/upd-mma-win-run.png "Run MMA installer")

12. On the **Welcome to the Microsoft Monitoring Agent Setup Wizard** blade, select **Next**. 

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/upd-mma1.png "MMA installation")

13. On the **Microsoft Software License Terms** blade, select **I Agree**.

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/upd-mma2.png "MMA installation")

14. On the **Destination Folder** blade, leave everything as default and select **Next**. 

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/mma3.png "MMA installation") 

15. On the **Agent Setup Options** blade, select **Connect the agent to Azure Log Analytics (OMS) (1)** and select **Next (2)**.

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/upd-mma4.png "MMA installation") 

16. On the **Azure Log Analytics** blade, enter the **Workspace ID** and **Workspace Key** that you copied earlier, and select **Azure Commercial (1)** from the Azure Cloud drop-down then select **Next (2)**.

    ![Screenshot of the Microsoft Monitoring Agent install wizard, showing the Log Analytics (OMS) workspace ID and key.](Images/upd-mma-wizard.png "MMA agent installer - workspace configuration")

17. On the **Microsoft Update** blade, leave everything as default and select **Next**. 

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/updt-mma7.png "MMA installation")

18. On the **Ready to Install** blade, click on **Install**. 

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/mma5.png "MMA installation")

19. Select **Finish** to finish the installation process of **Microsoft Monitoring Agent for Windows**.

    ![Screenshot for installing 64-bit Microsoft Monitoring Agent for Windows.](Images/upd-mma6.png "MMA installation")

20. Paste the link to the **Dependency Agent Windows installer** into the browser address bar. **Run** the installer.

    ![Screenshot showing the Internet Explorer prompt to run the installer for the Dependency Agent.](Images/upd-da-win-run.png "Run Dependency Agent installer")

21. On the **License Agreement** blade, select **I Agree** to accept the agreement and continue. 

    ![Screenshot for installing Dependency Agent.](Images/dependencyagent1.png "Dependency Agent installation") 

22. On the **Completing Dependency Agent Setup** blade, select **Finish** to finish the installation process.

    ![Screenshot for installing Dependency Agent.](Images/dependencyagent2.png "Dependency Agent installation") 

    > **Note**: You do not need to configure the workspace ID and key when installing the Dependency Agent, since it uses the same settings as the Microsoft Monitoring Agent, which must be installed beforehand.

23. Close the virtual machine connection window for the **WindowsServer VM**.

24. Open a command prompt using the desktop shortcut.  

    > **Note**: The HostVM runs Windows Server 2019 with the Windows Subsystem for Linux enabled. This allows the command prompt to be used as an SSH client. More info of supported Linux on Azure can be found here: https://Azure.com/Linux. 

25. Enter the following command to connect to the **UbuntuServer** VM running in Hyper-V on the HostVM:

    ```bash
    ssh demouser@192.168.0.8
    ```

26. Enter 'yes' when prompted whether to connect. Use the password **<inject key="On-prem Servers Admin Password" />**.

    ![Screenshot showing the command prompt with an SSH session to UbuntuWAF.](Images/ssh.png "SSH session with UbuntuWAF")

27. Enter the following command, followed by the password **<inject key="On-prem Servers Admin Password" />** when prompted:
  
    ```
    sudo -s
    ```

    > This gives the terminal session elevated privileges.

28. Enter the following command, substituting \<Workspace ID\> and \<Primary Key\> with the values copied previously. Answer **Yes** by using keyboard arrows and Enter key when prompted to restart services during package upgrades without asking.  

    ```
    wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w <Workspace ID> -s <Primary Key>
    ```
    
    > **Note**:
    >> a) If you receive any error while running the above command, run the below command to update the packages and perform **Step 28** again.
    
    >> b) If you receive a warning **The Log Analytics agent is on a deprecation path**, then ignore it.

     ```s
     apt-get update
     ```

29. Enter the following command. This downloads a script that will install the Dependency Agent.

    ```s
    wget --content-disposition https://aka.ms/dependencyagentlinux -O InstallDependencyAgent-Linux64.bin
    ```

30. Install the dependency agent by running the script download in the previous step.

    ```s
    sh InstallDependencyAgent-Linux64.bin -s
    ```

    ![Screenshot showing that the Dependency Agent install on Linux was successful.](Images/da-linux-done.png "Dependency Agent installation was successful")
    

31. Return to the Azure Portal and refresh the Azure Migrate **Hyper-V VMs** VM group blade. The 2 VMs on which the dependency agent was installed should now show their status as **Installed**. (If not, refresh the page **using the browser refresh button**, not the refresh button in the blade.  It may take up to **5 minutes** after installation for the status to be updated.)

    ![Screenshot showing the dependency agent installed on each VM in the Azure Migrate VM group.](Images/hol1-exe2-task2-step32-dependency-agent-status.png "Dependency agent installed")
   
     >**Note**: If you notice that the dependency agent status is showing as **Requires Agent Installation** instead of Installed even after installing dependency agents in all the three VMs, please follow the steps from [here](https://github.com/CloudLabsAI-Azure/Migrate-and-Secure-Workloads/blob/main/labguide/HelpDoc-AzureMigrate.md) to confirm dependency agent installation in VMs using Log Analytics workspace.
 
32. Select **View dependencies**.

    ![Screenshot showing the view dependencies button in the Azure Migrate VM group blade.](Images/hol1-exe2-task2-step33-select-view-dependency-button.png "View dependencies")
   
33. Take a few minutes to explore the dependencies view. Expand each server to show the processes running on that server. Select a process to see process information. See which connections each server makes.

    ![Screenshot showing the dependencies view in Azure Migrate.](Images/hol1-exe2-task2-step34-view-dependency.png "Dependency map")
    

#### Task summary 

In this exercise you created and configured an Azure Migrate migration assessment and configured the Azure Migrate dependency visualization feature, by creating a Log Analytics workspace and deploying the Azure Monitoring Agent and Dependency Agent on both Windows and Linux on-premises machines.
