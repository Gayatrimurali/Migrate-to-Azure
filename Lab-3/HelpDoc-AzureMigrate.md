#### If attendees notice that the dependency agent status is showing as **Requires Agent Installation** instead of Installed even after installing dependency agents in all the three VMs, This is because there is an ongoing issue from Azure end where the latest status is not getting reflected in dependencies blade. Please follow the steps below to confirm dependency agent installation in VMs using **Log Analytics workspace**.
   
   1. Search for **AzureMigrateWS** Log Analytics workspace under **Azure Migrate** Resource Group and select it.

      ![Screenshot showing the view dependencies button in the Azure Migrate VM group blade.](Images/helpdoc-select-log-analytics-ws.png "View dependencies")


   1. Select **Logs (1)** in left pane. Close the **Introduction video (2)** and **Queries** popup. Next, enter the below query and click on **Run** **(3)** to review the connected servers information.

       ```
       Heartbeat
       ```

      ![Screenshot showing the view dependencies button in the Azure Migrate VM group blade.](Images/helpdoc-step2-select-logs-close-videov2.png "View dependencies")



      ![Screenshot showing the view dependencies button in the Azure Migrate VM group blade.](Images/helpdoc-step2-select-run.png "View dependencies")
     
   1. Notice the **SmartHotelWeb1**, **SmartHotelWeb2** and **UbuntuWAF** servers have the required agents intsalled and are connected to the workspace.
       ![Screenshot showing the view dependencies button in the Azure Migrate VM group blade.](https://github.com/CloudLabs-MCW/MCW-Line-of-business-application-migration/blob/prod/Hands-on%20lab/images/Exercise1/dependency-3.png?raw=true "View dependencies")
      
