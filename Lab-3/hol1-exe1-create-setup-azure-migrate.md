# Lab 1 - Exercise 1: Create and Setup Azure Migrate Project and Appliance

## Lab overview

In this hands-on lab, participants will embark on the foundational steps of initiating an Azure migration project using Azure Migrate. The focus is on creating and setting up an Azure Migrate project, deploying the Azure Migrate appliance, and preparing the on-premises environment for a seamless migration to Azure.

## Lab scenario
In this Lab, you will learn how to use Azure Migrate service to assess the Hyper-V environment. you will be creating the azure migrate project and performing the necessary steps in the appliance machine for assessment of the Hyper-V Server.

## Lab objectives (Duration: 60 minutes)

In this lab, you will complete the following tasks:
+ Task 1: Create and Setup Azure Migrate Project and Applicance

## Architecture Diagram

  ![Picture 1](Images/Assessment_of_the_servers.png)


### Task 1: Create and Setup Azure Migrate Project and Applicance

In this task, you will create an Azure Migrate project and deploy the Azure Migrate appliance in the on-premises Hyper-V environment. This appliance communicates with the Hyper-V server to gather configuration and performance data about your on-premises VMs, and returns that data to your Azure Migrate project.

1. If you are not logged in already, click on Azure portal shortcut that is available on the desktop and log in with below Azure credentials.
    * Azure Username/Email: <inject key="AzureAdUserEmail"></inject> 
    * Azure Password: <inject key="AzureAdUserPassword"></inject>

2. In the search bar, search for **Azure Migrate** and select it from the suggestions to open the Azure Migrate Overview blade, as shown below. 
 
    ![Screenshot of the Azure migrate overview blade.](Images/newmigrateasd.png "Azmigrate Overview blade")

3. Under **Migration goals**, select **Servers, databases and web apps (1)** and then select **Create project (2)**.
 
    ![](Images/exe1-step3-create-migrate-project.png)

 4. In the **Create project** wizard, provide the below information to create a Azure migrate project and select **Create (5)**. 
      
      * Subscription: **Select your Azure subscription (1)**
      * Resource group: **MigrateServers (2)**
      * Project: **<inject key="Azure Migrate Project Name"></inject> (3)**
      * Geography: **United States (4)** 
   
    ![](Images/exe1-step4-create-migrate-project-with-details.png)

5. In the **Azure Migrate: Discovery and assessment** tool, select **Discover** to open the **Discover** blade.
 
    ![](Images/exe1-step5-select-dicsover.png)

6. Under **Are your servers virtualized?**, select **Yes, with Hyper-V** from the **drop-down** menu.

    ![](Images/upd-SP-Ex1t2s2.png)

7.  In **1: Generate project key**, provide the below name for the **Azure Migrate appliance (1)** that you will set up for the discovery of Hyper-V VMs. Select **Generate key (2)** to start the creation of the required Azure resources.

     ```
     MigrateAppl
     ```
    ![Screenshot of the Azure Migrate 'Discover machines' blade showing the 'Generate Azure Migrate project key' section.](Images/exe1-step7-create-appliance.png "Generate Azure Migrate project key")

8.  **Wait** for the key to be generated, then copy the **Azure Migrate project key** to your clipboard and paste it in a text editor of your choice for later use.

    ![Screenshot of the Azure Migrate 'Discover machines' blade showing the Azure Migrate project key.](Images/exe1-step8-copy-key.png "Azure Migrate project key")

9.  Read through the instructions on how to download, deploy and configure the Azure Migrate appliance, then close the 'Discover machines' blade by clicking on cross button **X** (do **not** download the .VHD file or .ZIP file, the .VHD has already been downloaded for you). 
 
    ![Screenshot of the closing the blade.](Images/upd-discover-projectkey.png "Closing the Azure migrate appliance blade")

10. As we have created the Azure Migrate project key for the Discover and Assessment, you will be accessing the Hyper-V manager in the next tasks to start the discovery process with the help of Azure Migrate Appliance.

11. Now, to Connect to your on-premises environment, Go to **Start (1)** button in the VM, search for **Hyper-V Manager (2)** there and select it. You will be accessing your infrastructure from the hyper-V manager and will be connecting to the Azure Migrate Appliance VM to start the process of discovery.  

    > You can also open the **Hyper-V manager** by clicking on the ![](Images/Icon-hyperv.png) icon that is present in the taskbar. 

      ![Screenshot of Hyper-V Manager, with the 'Hyper-V Manager' action highlighted.](Images/upd-hyper-v-manager.png "Hyper-V Manager")

12. In Hyper-V Manager, select **TESTVM**. You should now see the five VMs(2) along with the AzureMigrateAppliance VM that comprise the on-premises environment and will be used in the next HOLs.

    ![Screenshot of Hyper-V Manager on the SmartHotelHost.](Images/exe1-step12-view-hyperv-vms.png "Hyper-V Manager")
     
13. In Hyper-V Manager, select the **AzureMigrateAppliance (1)** VM, then select **Connect (2)** on the right.

    ![Screenshot of Hyper-V Manager showing the connect button for the Azure Migrate appliance.](Images/exe1-step14-connect-to-appliance-vm.png "Connect to AzureMigrateAppliance")
    
   
14. Under Connect to AzureMigrateAppliance, click **Connect** and then log into the VM with the administrator password **<inject key="On-prem Servers Admin Password" />** (the login screen may pick up your local keyboard mapping, use the 'eyeball' icon to check).
 
    ![Screenshot of the Connect to AzureMigrateAppliance.](Images/HOL1-EX1-S14v2.png)

15. Launch the **Azure Migrate appliance configuration Manager wizard** using the shortcut available on the desktop (wait for a minute or two, the browser will open showing the Azure Migrate appliance configuration wizard)

     > **Note:**
     >> a) If you are prompted with New updates available pop-up when connected with AzureMigrateAppliance VM, just click on View updates and then close the settings panel for now.

     >> b) If you get a warning **Your connection isn't private** in the browser page post launching the **Azure Migrate appliance configuration Manager wizard**, then close the browser application and launch the **Azure Migrate appliance configuration Manager** again.
      

    ![Screenshot of the Azure Migrate appliance terms of use.](Images/HOL1-EX1-S15.png "Desktop shortcut")
    
    >**Note**: If you receive a prompt asking for credentials after launching the **Azure Migrate appliance configuration wizard** using the shortcut available on the desktop, please follow the instructions from [here](https://github.com/CloudLabsAI-Azure/Know-Before-You-Go/blob/main/AIW-KBYG/AIW-Infrastructure-Migration.md#1-exercise1---task3---step3) to connect to Azure Migrate appliance configuration wizard.


   

16. On opening of the appliance configuration wizard, if a pop-up with the license terms appears, accept the terms by selecting **I agree**.

    ![Screenshot of the Azure Migrate appliance terms of use.](Images/upd-terms.png "Terms of use")

17. Under **Set up prerequisites**, the following two steps to verify Internet connectivity and time synchronization should pass automatically.

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the first step 'Set up prerequisites' in progress. The internet connectivity and time sync steps have been completed.](Images/upd-prereq.png "Set up prerequisites")

18. **Wait** for some time while the wizard installs the latest Azure Migrate updates. If prompted for credentials, enter username **Administrator** and password **<inject key="On-prem Servers Admin Password" />**. Once the Azure Migrate updates are completed, you may see a pop-up if the management app restart is required, and if so, select **Refresh** to restart the app.  

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the prompt to restart the management app after installing updates.](Images/upd-refresh.png "New update installed - Refresh")

      > **Note:** It might take 15-20 minutes for Azure Migrate to install updates. If you do not get any pop-up after waiting, then proceed to next step.   

19. At the next phase of the wizard, **Check latest updates and register appliance**, paste the **Azure Migrate project key (1)** that you copied from the Azure portal earlier and select **Verify (2)** to verify the Azure Migrate project key. 

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the registration with the Azure Migrate project.](Images/exe1-step20-verify-appliance-key.png "Register with Azure Migrate")

20. Wait for the **Appliance auto-update status (1)** to complete and select **Login (2)**. 

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the registration with the login code for the Azure Migrate project.](Images/exe1-step21-login-appliance.png "Azure Migrate login code")
   
   > Now, follow the below instructions to complete the login process.
    
 21. At first, you will be presented with a **Continue with Azure login** pop-up. On the **Continue with Azure login** pop-up dialog, click on **Copy code & Login**.

     ![](Images/azmigrate-05v2.png "Azure Migrate login code")
  
 22. This will open an Azure login prompt in a new browser tab (if it doesn't appear, make sure the pop-up blocker in the browser is disabled) paste the **code (1)** and click on **Next (2)**. You will then be asked for your Azure portal credentials to complete the login process.

      ![Screenshot of the Azure Migrate appliance login window, showing where to copy and paste the login code for the Azure Migrate project.](Images/azmigrate-06.png "Azure Migrate Microsoft login")

 23. Login using the below Azure credentials and select **Continue** on the **Are you trying to sign in to Microsoft Azure PowerShell?** window to complete the login process. Once you have logged in, return to the Azure Migrate Appliance tab and the appliance registration will start automatically and displays below message once the registration is successful.
    
  * Azure Username/Email: <inject key="AzureAdUserEmail"></inject> 
    
* Azure Password: <inject key="AzureAdUserPassword"></inject> 


   > **Note:** If you are presented with **Action Required** dialog box, then select **Ask later** option.

   Once the registration has been completed, you can proceed to the next panel, **Manage credentials and discovery sources**.

24. In **Step 1: Provide Hyper-V host credentials for the discovery of Hyper-V VMs** under **2. Manage credentials and discovery sources**, select **Add credentials**.

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the 'Add credentials' button.](Images/addcredsss.png)


25. Specify the following details on the **Add credentials** blade for the Hyper-V host/cluster that the appliance will use to discover VMs and select **Save (4)**.
 
      1. Friendly name: Enter **hostlogin (1)** 
      2. Username: **<inject key="HostVM Admin Username" /> (2)**
      3. Password: **<inject key="HostVM Admin Password" /> (3)**

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the 'Add credentials' panel.](Images/upd-add-creds.png "Credentials")

     > **Note**: The Azure Migrate appliance may not have picked up your local keyboard mapping. Select the 'eyeball' in the password box to check the password was entered correctly.

26. In **Step 2: Provide Hyper-V host/cluster details**, select **Add discovery source** to specify the Hyper-V host/cluster IP address/FQDN and the friendly name for credentials to connect to the host/cluster.

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the 'Add discovery source' button.](Images/adddscvryyy.png "Add discovery source")

27. On the **Add discovery source** blade, provide the following details:
     
      1. Select **Add single item (1)**
      1. IP Address / FQDN:  Enter **HOSTVM (2)** 
      1. Friendly name: Select **hostlogin (3)** from the dropdown and 
      1. Select **Save (4)**.

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the 'Add discovery source' panel.](Images/HOL1-EX1-S24.png "Discovery source - SmartHotelHost")

    > **Note:** You can either **Add single item** at a time or **Add multiple items** in one go. There is also an option to provide Hyper-V host/cluster details through **Import CSV**.

28. The appliance will validate the connection to the Hyper-V hosts/clusters added and show the **Validation status** in the table against each host/cluster

    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the successful validation of the configured discovery source.](Images/HOL1-EX1-S25.png "Discovery source - validation successful")

    > **Note:** When adding discovery sources:
    > - For successfully validated hosts/clusters, you can view more details by selecting their IP address/FQDN.
    > - If validation fails for a host, review the error by selecting the Validation failed in the Status column of the table. Fix the issue and validate again.
    > - To remove hosts or clusters, select **Delete**.
    > - You can't remove a specific host from a cluster. You can only remove the entire cluster.
    > - You can add a cluster, even if there are issues with specific hosts in the cluster.

29. In **Step 3: provide server credentials to perform software inventory and agentless dependency analysis**, **Disable the slider (1)** and select **Start discovery (2)** to kick off VM discovery from the successfully validated hosts/clusters.

     > **Note:** The discovery process can take up to 10 minutes. 
   
    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the 'Start discovery' button.](Images/disablered1_1.png)
    
    ![Screenshot of the Azure Migrate appliance configuration wizard, showing the 'Start discovery' button.](Images/startdscvry1.png)

30. Wait for the Azure Migrate status to show **Discovery has been successfully initiated**. This will take several minutes. After the discovery has been successfully initiated, you can check the discovery status against each host/cluster in the table.

32. Return to the **JumpVM** then to **Azure Migrate** blade in the Azure portal.  Select **Servers, databases, and web apps (1)**, then select **Refresh (2)**.  Under **Azure Migrate: Servers, databases and web apps** you should see a **count (3)** of the number of servers discovered so far. If discovery is still in progress, select **Refresh** periodically until 5 discovered servers are shown. This may take several minutes.

    ![Screenshot of the Azure Migrate portal blade. Under 'Azure Migrate: Server Assessment' the value for 'discovered servers' is '5'.](Images/exe1-step32-vm-discover-verify.png "Discovered servers") 

    > Note:- **Wait for the discovery process to complete before proceeding to the next Task**.


#### Task summary 

In this exercise, you explored an Azure Migrate project and the default built-in tools for server assessment and server migration. You have also configured the Azure Migrate appliance in the on-premises Hyper-V environment and started the migration assessment discovery process using Azure Migrate.
