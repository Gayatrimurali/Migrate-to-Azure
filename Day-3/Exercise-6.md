# Exercise 6: Migrate your application with App Service Migration Assistant
 
### Estimated Duration: 20 minutes

## Overview

App Service Migration Assistant is a tool designed to assess and migrate web applications to Azure App Service. You will explore how the tool identifies compatibility issues, provides remediation recommendations, and facilitates the migration of the web application to Azure’s platform-as-a-service (PaaS) environment.

## Lab objectives

You will be able to complete the following tasks:

- Task 1: Migrate the web application to Azure App Service

- Task 2: Configure the application connection to SQL Azure Database


## Task 1: Migrate the web application to Azure App Service

In this task, after reviewing the assessment results, you have ensured the web application is a good candidate for migration to Azure App Service. Now, we will continue migrating the application.

1. Navigate back to the **App Service Migration Assistant** window from the background. You can click from the bottom menu as well.

    ![](media/m56.png)

 > **WARNING:** If you get this error.  
      ![](media/loginerror.png)
      Repeat **Step 5** and **Step 6** from **Task 2: Perform assessment for migration to Azure App Service** of **Exercise: 1**



1. In order to continue with the migration of our website, Azure App Service Migration Assistant needs access to our Azure Subscription. Select **Copy Code & Open Browser** button to be redirected to the Azure Portal.

   ![Azure App Service Migration Assistant's Azure Login dialog is open. A device code is presented. Copy Code & Open Browser button is highlighted.](media/m51.png "Azure Login")

1. A new tab opens to the login page within the Edge browser. Paste your Device code **(1)**. Select **Next (2)** to give subscription access to App Service Migration Assistant.

    ![](media/code.png)

1. Continue the login process with your Azure Subscription credentials.

   ![](media/aftercode2.png)

1. Click on **Continue**.

    ![](media/m53.png)

1. When you see the message that says **You have signed in to the Azure App Service Migration Assistant application on your device**, close the browser tab and minimize the Edge browser window to return to the App Service Migration Assistant Window.    

    ![Azure Login process is complete. A message dialog is shown that indicates the login process is a success.](media/updated33.png "App Service Migration Assistant authentication approval")

1. Navigate to the **App Service Migration Assistant** window, select the Azure Migrate project **partsunlimitedweb<inject key="DeploymentID" enableCopy="false"/> (1)** that we created in the previous exercise to submit the results of our migration. Select **Next (2)** to continue.

    ![](media/slectamp.png)

1. In order to migrate the Parts Unlimited website, we have to create an App Service Plan. The Azure App Service Migration Assistant will take care of all the requirements needed.

    - **Subscription:** Azure HOL (SUFFIX) / Sub 05 - (SUFFIX)  **(1)**
    - **Hybrid Connection**: Select **Use existing (2)** 
    - **Migration Results**: select the resource group **hands-on-lab** **(3)**
    - **Destination Site Name**: Enter **partsunlimited-web-<inject key="DeploymentID" enableCopy="false"/>** **(4)**.
    - **Region**: Select the **<inject key="location" style="color:red" />** **(5)**. 
    - Click **Migrate** **(6)** to start the migration process.

      ![](media/clickmig.png)

      > **WARNING:** If your migration fails with a **WindowsWorkersNotAllowedInLinuxResourceGroup (1)** It may be due to the incorrect region. Try the migration process again, but this time select the correct region.  
      
      > ![Migration failed error screen is shown. WindowsWorkersNotAllowedInLinuxResourceGroup message is highlighted.](media/updated35.png "Migration failed")

      > You’ll see a confirmation message once the migration completes successfully.     

        ![](media/migdone.png)

## Task 2: Configure the application connection to SQL Azure Database

In this task, you'll configure your application to connect to the SQL Azure Database after migration to Azure.

Now that we have both our application and database migrated to Azure. It is time to configure our application to use the SQL Azure Database.

1. In the Azure portal, navigate to your `parts` SQL Database resource by selecting the **hands-on-lab** resource group, and selecting the `parts` SQL Database from the list of resources.

   ![](media/sqldbslect.png)

1. Switch to the **Connection strings (1)** Blade, and copy the connection string under **ADO.NET(SQL authentication)** by selecting the copy button **(2)**.

   ![](media/cnctstrings.png)

1. Paste the value into a text editor, such as Notepad.exe, to replace the Password placeholder. Replace the `{your_password}` section with **<inject key="SQLVM Password" />**. Copy the full connection string with the replaced password for later use.

    ![Notepad is open. SQL Connection string is pasted in. {your_password} placeholder is highlighted.](media/sql-connection-string-password-replace.png "Database connection string")

1. Go back to the resource list, search for `partsunlimited-web` **(1)** to find your Web App and App Service Plan. Select to your **partsunlimited-web-<inject key="DeploymentID" enableCopy="false"/> (2)** App Service resource.

   ![](media/srchweb.png)

1. Switch to the **Environment variables (1)** Blade, and select **connection string (2)** then click on **+Add (3)**.

    ![](media/envt.png)

1. On the **Add/Edit connection string** panel, enter the following:

   - **Name (1)**: Enter `DefaultConnectionString` **(1)**
   - **Value (2)**: Enter SQL Connection String you copied in Step 3. **(2)**
   - **Type (3)**: Select **SQLAzure (3)**
   - **Deployment slot setting (4)**: Check this option to make sure connection strings stick to a deployment slot. This will be helpful when we add additional deployment slots during the next exercises.
   - Select **Apply (5)**.

     ![](media/addstring.png)

1. Select **Apply (1)** and **Confirm (2)** for the following Save changes dialog.

   ![](media/m61.png)

1. Switch to the **Overview (1)** Blade, and select **Default domain (2)** to navigate to the Parts Unlimited web site hosted in our Azure App Service using Azure SQL Database.

    ![](media/dd.png)
    
1. You will be navigated to a web page which we have migrated to App Service.

    ![](media/azweb.png)
   
> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
  - Hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task. 
  - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
  - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help you out.

<validation step="409807e3-a466-46a4-84a0-f370fe4de4fc" />

## Summary

In this exercise you have covered the following:
 
 - Migrated the on-prem web application to Azure using App Service Migration Assistant. 

## Conclusion

By completing these exercises, you have successfully assessed and migrated the on-premises application and database to Azure. The application is now hosted on Azure App Service, benefiting from enhanced performance, scalability, and simplified management.

### You have successfully completed the Lab
