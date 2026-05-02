

# Exercise 8: Onboard On-premises servers to Azure Arc-Enabled Server

## Exercise 1: Run workloads anywhere with Azure Cloud Services

In this Exercise, you will deploy and configure the Azure Connected Machine agent on a Windows machine hosted outside of Azure.

### Estimated Duration: 30 Minutes

## Overview
In this HOL, you will use the Azure Migrate: Discovery and assessment tool that describes how to onboard on-premises Hyper-V VMs to Azure Arc for Azure Management.

Azure Arc allows you to manage your hybrid IT estate with a single pane of glass by extending the Azure management experience to your on-premises servers, which are not ideal candidates for migration.

## Objectives

In this Exercise, you will complete the following task:

- Task 1: Run workloads anywhere with Azure Cloud Services

### Task 1: Run workloads anywhere with Azure Cloud Services

In this task, you will deploy and configure the Azure Connected Machine agent on a Windows machine hosted outside of Azure, to ensure that it can be managed through Azure Arc-enabled servers.

1. In the search bar of the Azure portal, type **Azure arc (1)** and select **Azure Arc (2)** from suggestions under Services, as shown below:
   
    ![Screenshot of the search azure arc.](Images/15-7-25-l9-11.png "search azure arc")
  
1. On the **Azure Arc** page, select **Machines (1)** under **Infrastructure** from left pane, click on **Onboard/Create (2)**, then **Onboard existing machine (3)**.
    
    ![Screenshot of the add server.](Images/AIM-image17.png "add server")
    
1. On the **Add servers with Azure Arc** page, In the **Basics** section, add the following details:
     
   - Subscription: **Select your subscription**
    
   - Resource group: **SmartHotelRG (1)**
  
   - Region: Select **<inject key="Region" enableCopy="false" /> (2)**
   
   - Operating system: **Windows (3)**
   
   - Leave other values as default and click on **Next (4).**

        ![Screenshot of the resource details tab.](Images/AIM-image19.png "resource details tab")

1. In the **Tags** section, leave the values as default and click on **Next**.

     ![](Images/15-7-25-l9-5.png)

1. In the **Download and run script** section, click **copy (1)** icon to copy the entire script. Paste it into Notepad or your preferred text editor, as you will need it in the upcoming steps, then click on **Close (2)**.

    ![Screenshot of the copy script.](Images/15-7-25-l9-6.png "copy script")
    
1. Go to the **Start** button in the VM, type **Hyper-V Manager (1)** and select **Hyper-V Manager (2)**.

    ![Screenshot of Hyper-V Manager, with the 'Hyper-V Manager' action highlighted.](Images/infra-l10-1.png "Hyper-V Manager")

   > **Note:** You can also open the **Hyper-V manager** by clicking on the icon that is present in the taskbar. 
    
1. In Hyper-V Manager, select **HOSTVMS<inject key="DeploymentID" enableCopy="false" />**. 
  
    ![Screenshot of Hyper-V Manager on the SmartHotelHost.](Images/15-7-25-l9-7.png "Hyper-V Manager")

 1. In the Hyper-V Manager, select the **AzureArcVM** VM and you will see the state as **Running**.

    ![](Images/15-7-25-l9-8.png)  

    >**Note:** If you are unable to find the state for the **AzureArcVM (1)** VM as Running, then select **Start (2)** in the Actions pane on the right.

    ![Screenshot of Hyper-V Manager showing the start button for the AzureArcVM.](Images/infra-l9-3.png "Start AzureArcVM")    
    
1. In Hyper-V Manager, select the **AzureArcVM (1)** VM, then select **Connect (2)** in the Actions pane on the right.

    ![Screenshot of Hyper-V Manager showing the connect button for the AzureArcVM.](Images/infra-l10-2-new.png "Connect to AzureArcVM")  
    
1. Under Connect to AzureArcVM, click on **Connect** and then log into the VM with the **Administrator password**: **<inject key="SmartHotel Admin Password" />** (If the copy/paste is not working in the hyper-V machine, please try typing the password. The login screen may pick up your local keyboard mapping, use the 'eyeball' icon to check).
 
    ![Screenshot of the Connect to AzureArcVM.](Images/infra-l10-4.png)
    
1. From the **Start** menu of the AzureArcVM, search for **Windows Powershell (1)** and open it **(2)**.

    ![Screenshot of the PowerShell.](Images/infra-l10-3.png)
      
1. In PowerShell, run the following command to set the execution policy as unrestricted.

    ```
    Set-ExecutionPolicy -ExecutionPolicy unrestricted
    ```
   >**Note:** If you get an option, "Do you want to change the execution policy?", please type A and press Enter. 

1. Now, run the whole script that you copied in Notepad earlier in **step 6**.

1. After running the script, packages will be installed, and then you will be directed to a pop-up browser page to log into your Azure account for authentication purposes. Use the below Azure credentials:

    - Enter your Username/Email: **<inject key="AzureAdUserEmail"></inject>**  in the Sign in field. Click Next to continue.

       ![](./Images/AIM-image1.png)
    
    - Enter Temporary Access Pass: **<inject key="AzureAdUserPassword"></inject>** and click Sign in

       ![](./Images/AIM-image2.png)

   > **Note:** Move back to the PowerShell pane, and now you have connected your AzureArcVM to Azure successfully.
   
   >**Note:** On the Welcome to Microsoft Edge page, select  **Start without your data**, on **Stay current with your browsing data** select **Confirm and continue**, and on the help for importing Google browsing data page, select the  **Continue without this data**  button. Then, proceed to select  **Confirm and start browsing**  on the next page has a context menu.
    
    ![Screenshot of the PowerShell script.](Images/infra-l10-5.png)
     
 1. Close the AzureArcVM, navigate to **Azure Arc** page in the Azure portal, select **Machines (1)** under **Azure Arc resources** and now verify that a server is connected successfully **(2)**.

    >**Note:** The name of the new server added could be different. You should refresh to see the new server.
    
    ![Screenshot of the server added.](Images/AIM-image20.png)
    
## Summary

In this exercise, you explored how to deploy and configure the Azure Connected Machine agent on a Windows machine hosted outside of Azure. You learnt about creating Azure Arc-enabled servers so that they can manage the Windows machine.

Click on **Next >>** from the lower right corner to move on to the next page.
 
  ![](Images/infra-s7.png)
