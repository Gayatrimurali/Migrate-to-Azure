
# Exercise 3: Failover the Infrastructure to Azure Cloud

### Estimated duration: 30 minutes

## Overview
In this exercise, you will deploy the Failover from on-premises to Azure. After setting up replication to Azure for on-premises machines, when your on-premises site goes down, you fail those machines over to Azure. After a failover, Azure VMs are created from replicated data.

## Objectives

In this exercise, you will complete the following task:

- Task 1: Failover the Infrastructure to Azure Cloud

### Task 1: Failover the Infrastructure to Azure Cloud

In this task, you will perform a failover of the replicated VM from on-premises to Azure. This action brings the VM online in Azure and confirms disaster recovery readiness by committing the failover.

1. In the **search resources, services and docs bar**, type **Recovery services vaults (1)**. From the dropdown results under **Services**, click on **Recovery Services vaults (2)**.
   
    ![](Images/15-7-25-l10-1.png)
    
1. On the **Recovery service vaults** page, click on **SmartHotelMigration<inject key="DeploymentID" enableCopy="false" />-MigrateVault-xxxx**.  

    ![](Images/infra-l11-1.png "create Recovery service vaults")
    
1. On the **Recovery Service Vault page**, click on **Replicated Items (1)** under **Protected Items** section and select **AzureArcVM (2)**.     

    ![Screenshot of the replicate items.](Images/15-7-25-l11-1.png) 
    
1. On the **AzureArcVM** page, click on **Cleanup test Failover**.   

   ![Screenshot of the cleanup test failover.](Images/5-7-25-h4-1a.png "cleanup test failover") 
   
1. On the **Test failover cleanup** page, enter `Test failover ok.` under **Notes (1)** and make sure to **(2) check the box: Testing is complete. Delete test failover virtual machine(s)** and then click on **OK (3)**.

   > **Note:** Wait for the cleanup test failover to get completed successfully.
   
   ![Screenshot of the cleanup test failover.](Images/5-7-25-h4-2.png "cleanup test failover") 
   
1. On the **AzureArcVM** page, click on **Failover**.

   ![Screenshot of the failover.](Images/5-7-25-h4-3.png "failover") 
   
1. On the **Failover** page, review the settings and click on **Ok**.  

   ![Screenshot of the failover page.](Images/5-7-25-h4-4a.png) 
   
1. Go back to the Replicated items page and select **Site Recovery Jobs (1)** under **Monitoring (2)** from the left-hand side panel and click on **Failover (3)** to view the job status.

   ![Screenshot of the failover jobs.](Images/5-7-25-h4-5.png "failover jobs") 
   
1. On the **Failover** page, wait for **10-15 minutes** for the failover job to complete. The **Status** column should show **Successful** for all key steps.

    ![Screenshot of the Failover status.](Images/5-7-25-h4-6.png "Failover status")    
   
1. After the Failover is completed successfully, go to **Protected items (1)** → **Replicated items (2)** and verify that the status of the replicated **AzureArcVM (3)** shows **Failover completed** with **Active location** as **Microsoft Azure**.

   ![Screenshot of the failover done.](Images/5-7-25-h4-7.png "failover done")  
   
   > **Note:** If you want to switch to a different recovery point to use for the failover, use **Change recovery point**.   
  
   ![Screenshot of the recovery points.](Images/5-7-25-h4-8.png "recovery points") 
   
1. On the **replicated AzureArcVM** page, click on **Commit** to commit the failover (The Commit action deletes all the recovery points available with the service). 

   ![Screenshot of the commit.](Images/5-7-25-h4-9a.png)
   
1. On the **Commit** page, click on **Ok**.   

   ![Screenshot of the commit page.](Images/5-7-25-h4-10.png "commit page") 
   
1. After the Failover is **committed successfully**,  In the **Search resources, services, and docs** bar, type **Virtual Machines** **(1)** and select **Virtual machines** from the Services **(2)**.

   ![](Images/15-7-25-l11-4.1.png) 

1. Under the **Virtual Machines** page, select the **AzureArcVM**, which is automatically created from replicated data after a Failover.

   ![](Images/infra-l12-7.png) 
   
1. On the **AzureArcVM** page, verify that the status of the VM is in the **Running state**. 

    ![Screenshot of the vm-created status.](Images/5-7-25-h4-11.png)  

    > **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
    > - Hit the Inline Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
    > - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
    > - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help.
  
    <validation step="686b754f-1ccf-4f85-9fa5-aa7bb83819e5" />

## Summary

In this exercise, you explored how to fail over on-premises physical servers that are replicating to Azure with Azure Site Recovery. After you've failed over, you fail back from Azure to your on-premises site when it's available.

Click on **Next** from the lower right corner to move on to the next page.

![](Images/infra-s7.png)
