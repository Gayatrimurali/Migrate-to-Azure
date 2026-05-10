

# Exercise 9: Enable Microsoft Defender for Cloud, Microsoft Sentinel, Azure Monitor, and setup Log Analytics

### Estimated duration: 30 Minutes

## Overview
In this exercise, you will learn how to enable enhanced security features by enabling the Defender for Cloud plans through the Azure portal. The Defender plans show you the monitoring coverage for each Defender plan. You will be enabling the same for Microsoft Sentinel and Azure Monitor. Also, you will set up a Log Analytics workspace to collect logs and data of these resources, and their information will be stored in a workspace.

> **Note:** 
> - Microsoft Defender for Cloud, Azure Sentinel, and Monitor Insights can take several hours to surface after the completion of a scan.
> - At this point in the workshop, only a limited number of data visualizations may be populated. (So the result in the screenshots below may vary)
> - The screenshots and information below have been provided so that you can conceptualise the type of graphs and output that can be gleaned from a fully populated environment.

## Objectives

In this exercise, you will complete the following tasks:

- Task 1: Enable Microsoft Defender for Cloud
- Task 2: Enable Microsoft Sentinel
- Task 3: Enable Azure Monitor

### Task 1: Enable Microsoft Defender for Cloud

In this task, you will enable Microsoft Defender for Cloud to enhance the security of your Azure environment.

1. In the **search resources, services and docs** bar, type **Microsoft Defender for Cloud (1)** and select **Microsoft Defender for Cloud (2)** from Services list.

    ![](Images/infra-l14-1.png)
    
    > **Note:** If you are prompted with a new upgrade pop-up, click on Skip.
    
1. On the **Microsoft Defender for Cloud** page, click **Management (1)** > **Environment settings (2)**, expand the Tenant Root Group and subscription **Azure HOL (SUFFIX) / Sub 05 - (SUFFIX)** with the **down arrow (3) (4)**, then select **AzureMigrateWS<inject key="DeploymentID" enableCopy="false" /> (5)**.

    ![](Images/AIM-image35.png)
     
1. On the **Defender plans** page, select **Defender plans** from the left-hand panel **(1)**, toggle the **Servers** plan to **On (2)**, and click **Save (3)** to apply the changes.

    ![](Images/AIM-image36.png)
    
1. Back on **Microsoft Defender for Cloud** Overview page. When Enhance your security posture by enabling Defender CSPM pop up click on **No thanks**

1. On on **Microsoft Defender for Cloud**, expand **General (1)** thrn select **Overview (2)**  when  offers a consolidated perspective for security experts. This section combines various independent cloud security components, such as **Secure Score, Regulatory Compliance, and Workloads Protection**, and provides detailed insights on the security posture on a distinct dashboard.    

   ![Screenshot of the overview page](Images/AIM-image37.png "overview page")

1. In the Microsoft Defender for Cloud portal, click **General (1)**, then select **Recommendations (2)** to view risk-based recommendations and resource health insights..

    >**Note**: You may need to select the Collapse button to view the recommendations.
    
     ![](Images/AIM-image38.png)
     > **Note:** You many not see any recommendations now, since you have just enabled the Defender Plan.


1. On the **Security alerts page** under General, you can see the alerts that describe details of the affected resources, suggested remediation steps, and in some cases, an option to trigger a logic app in response. (The Remediation steps contain the remediation logic where you can remediate the selected resource/s. To simplify remediation, improve your environment's security, and increase your secure score, many recommendations include a Fix option. Fix helps you quickly remediate a recommendation on multiple resources.)

### Task 2: Enable Microsoft Sentinel

In this task, you will create and enable Microsoft Sentinel and review the Content Hub for enhanced security monitoring and threat detection in your Azure environment.

1. In the Azure portal search bar, type **Microsoft Sentinel (1)** and select **Microsoft Sentinel (2)** from the results.

    ![](Images/15-7-25-l12-5.png)
    
1. On the **Microsoft Sentinel** page, click on **+ Create** to start onboarding a workspace.   

    ![Screenshot of the create Microsoft Sentinel.](Images/infra-l14-7.png "Microsoft Sentinel")
    
1. On the **Add Microsoft Sentinel to a Workspace** page, select the **AzureMigrateWS<inject key="DeploymentID" enableCopy="false" /> (1)** workspace and click on **Add (2)**. If prompted, the Microsoft Sentinel free trial is activated. Click on **OK**.   

   ![](Images/infra-l14-8.png)
    
1. In the Microsoft Sentinel window, navigate to the left-hand pane and, under **Configuration (1)**, select **Data connectors (2)**. This will take you to the Data Connectors page.  

    ![Screenshot of the get started.](Images/infra-l14-7.1.png "get started")
    
1. On the **Microsoft Sentinel | Data connectors** page, click **Content Hub** under the **More content at** section to view additional connectors.

    ![Screenshot of the get started.](Images/infra-l14-8-2.png "get started")

1. You will now be directed to the **Content hub** page. Microsoft Sentinel comes with many connectors for Microsoft solutions that are available out of the box and provide real-time integration. For non-Microsoft solutions, Microsoft Sentinel provides built-in interfaces to the larger security and application ecosystems. Close the **Content hub** window.

    ![Screenshot of the Data Connectors.](Images/infra-l14-8-3.png "Data Connectors")

     > **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
     > - Hit the Inline Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
     > - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
     > - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help.
      
     <validation step="e44942ed-8536-4e13-8e05-6fbe494cf8cd" />

### Task 3: Enable Azure Monitor

In this task, you will enable Azure Monitor to track and manage the performance and health of your Azure resources, and you can check the insights for detailed analytics.

1. In the **search resources, services and docs** bar, type **Monitor (1)** and select **Monitor (2)** from the suggestions.

     ![](Images/15-7-25-l12-6.png)
    
1. On the **Monitor** page, from the left pane, select **Log Analytics Workspaces (2)** present under **Insights (1)** (Select the Azure HOL (SUFFIX) / Sub 05 - (SUFFIX) Subscription and then select azuremigraterg) and click on **AzureMigrateWS<inject key="DeploymentID" enableCopy="false" /> (3)** workspace under azuremigraterg.

    ![Screenshot of the search Azure workspace Monitor.](Images/AIM-image39.png "Azure Monitor")

1. On the **Log Analytics Workspaces** page, under the **Monitoring (1)** section, click on **Insights (2)**, and in the **Overview (3)** tab, you will find the following:

   - The monthly ingestion volume of the workspace
   - How many machines sent heartbeats, meaning - machines that are connected to this workspace (in the selected time range)
   - Machines that haven't sent heartbeats in the last hour (in the selected time range)
   - The data retention period set
   - The daily cap set, and how much data was already ingested on the recent day
   - Ingestion anomalies - a list of identified spikes and dips in ingestion to these tables
       
     ![Screenshot of the search Azure workspace Monitor.](Images/infra-l14-10.png "Azure Monitor")
     > **Note:** You many not see any Insights now, since you have just enabled the Defender Plan.

1. On the **Usage tab**, you can see ingestion data by tables and defaults to the 5 most ingested tables in the selected time range.
   
   - How much data was ingested into it (during the selected time range)
   - The percentage this table takes from the entire ingestion volume (during the selected time range). That helps identify the tables that affect your ingestion the most.
   - When was the last update of usage statistics regarding each table? We normally expect usage stats to refresh hourly.
   
     ![Screenshot of the search Azure workspace Monitor.](Images/infra-l14-14.png "Azure Monitor") 
     > **Note:** You many not see any Usage data now, since you have just enabled the Defender Plan.

1. On the **Health tab**, you can see the workspace's health state and when it was last reported, as well as operational errors and warnings.
        
    ![Screenshot of the search Azure workspace Monitor.](Images/infra-l14-12.png "Azure Monitor")
    
1. On the **Agents tab**, you can see :

   - Operation errors and warnings - these are errors and warnings related specifically to agents. 
   - Workspace agents - these are the agents that send logs to the workspace during the selected time range. You can see the agent's type and health state. 
   - Agents activity - this grid shows information on either all agents, healthy agents, or unhealthy agents.
      
     ![Screenshot of the search Azure workspace Monitor.](Images/infra-l14-13.png "Azure Monitor")  
     > **Note:** You many not see any Agents data now, since you have just enabled the Defender Plan.

     > **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
     > - Hit the Inline Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
     > - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
     > - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help.

     <validation step="42a1f577-61ab-4242-8030-84868937aeaa" />
    
## Summary

In this exercise, you explored what Microsoft Defender is and how to enable it for Cloud and Microsoft Sentinel. You also learnt about Monitoring, which helps you maximize the availability and performance of your applications and services. Then you explored how Azure Monitor Logs stores the data that it collects in the Log Analytics workspaces.

### You have successfully completed this Hands-on lab.

By completed the Infrastructure Migration lab, you gained hands-on experience with Azure Migrate, including reviewing discovered servers, performing migration readiness assessments for SmartHotel VMs, right-sizing, and enabling dependency visualization. Configured migration using Azure Site Recovery by registering the Hyper-V host, enabling replication, aligning network settings, and successfully migrating a Red Hat VM to Azure. Additionally, deployed Azure Arc (Connected Machine agent) for hybrid management and strengthened monitoring and security by enabling Microsoft Defender for Cloud, Microsoft Sentinel, Azure Monitor, and a Log Analytics workspace for centralized visibility.
