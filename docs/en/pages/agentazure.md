## Docker Image for Gateway, Agent, and Azure CLI Deployment in Azure

To simplify the deployment of AppControl’s gateway and agent in Azure, a pre-configured Docker image is available. This image includes:

-   **AppControl Gateway**
-   **AppControl Agent**
-   **Azure CLI (az cli)**

The goal is to streamline the process of deploying and managing the agent and gateway in an Azure environment. By running this Docker container in **Managed Identity**, the agent will have the capability to execute Azure CLI commands without requiring additional authentication.

**Key Benefits**

-   **Pre-configured Environment**: The Docker image includes both the gateway and the agent, along with the Azure CLI, in one cohesive package. This eliminates the need to install and configure each component separately.

-   **Managed Identity Integration**: When the Docker container is run with a managed identity, the agent gains access to Azure resources without manual authentication. This allows the agent to execute az commands securely, inheriting the permissions associated with the managed identity.

-   **Seamless Deployment**: This image is designed to be used within Azure environments, simplifying the process of deploying the gateway and agent directly in the cloud. You can use the image to monitor and manage your applications and infrastructure easily.

### Deploying an Azure Container with a Managed Identity Using AppControl’s Docker Image

This guide will walk you through creating a dedicated resource group, setting up a managed identity, and running a container using AppControl's Docker image, which includes the gateway, agent, and Azure CLI.

**Prerequisites**

-   **Azure CLI** installed on your local machine.
-   Azure account with sufficient privileges to create resource groups, managed identities, and run containers.

**Procedure**

### 1. Create a Resource Group

First, create a new resource group in Azure. This resource group will house the container and the associated resources.

```bash
az group create --name AppControlResourceGroup --location <your-region>
```

Replace **<your-region>** with the desired Azure region (e.g., eastus, westus, westeurope).

### 2. Create a Managed Identity

Next, create a managed identity that will be used by the container to authenticate and execute Azure commands without requiring credentials.

```bash
az identity create --name AppControlIdentity --resource-group AppControlResourceGroup --location <your-region>
```

Once the managed identity is created, note down the **client ID** and **principal ID** (also referred to as the object ID) from the output.

### 3. Assign the Managed Identity to a Role

Assign the managed identity appropriate roles so that it has permissions to interact with Azure resources. For example, to allow it to manage virtual machines, assign the Virtual Machine Contributor role.

```bash
az role assignment create --assignee <principal-id> --role "Virtual Machine Contributor" --scope /subscriptions/<subscription-id>/resourceGroups/AppControlResourceGroup
```

Replace:

-   **<principal-id>** with the principal ID of the managed identity.
-   **<subscription-id>** with your Azure subscription ID.
    You can also assign different roles depending on what permissions are needed for the agent running in the container.

### 4. Create and Configure an Azure Container Instance

Now, deploy an Azure Container Instance using the Docker image that contains the AppControl gateway, agent, and Azure CLI. Make sure to assign the managed identity to this container so it can execute Azure commands without requiring explicit credentials.

```bash
az container create \
  --resource-group AppControlResourceGroup \
  --name appcontrol-container \
  --image xcomponent/x4b-azuregateway:latest \
  --assign-identity <client-id> \
  --cpu 1 \
  --memory 1.5 \
  --environment-variables AZURE_CLIENT_ID=<client-id> \
  --location <your-region> \
  --dns-name-label appcontrol-container-instance \
  --resource-group [**RESOURCE-GROUP-NAME**] \
   --restart-policy OnFailure \
   --environment-variables  AZURE_CLIENT_ID=<client-id> X4B_ACCESS_KEY=[**YOUR-GATEWAY-ACCESS-KEY**] X4B_SECRET_ACCESS_KEY=[**YOUR-GATEWAY-SECRET-KEY**] X4B_PROXY_NAME=[**YOUR-GATEWAY-NAME**] APPCONTROL_API_URL=https://appcontrol.xcomponent.com/core/
```

Replace:

-   **<client-id>** with the client ID of the managed identity.
-   **<your-region>** with your preferred Azure region.

This command will:

Create a new container instance running the Docker image xcomponent/x4b-azuregateway:latest.
Assign the managed identity to the container so that it can run Azure CLI commands using the permissions of that identity.
Allocate 1 CPU and 1.5GB memory for the container.

### 5. Verify the Container and Managed Identity

After running the above command, you can verify that the container is running:

```bash
az container show --resource-group AppControlResourceGroup --name appcontrol-container --query "instanceView.state"
```

If everything is configured correctly, the container will be in a "Running" state.

### 6. Running Azure CLI Commands from Inside the Container

Since the container is running with the managed identity, you can now use the Azure CLI inside the container to manage Azure resources. The managed identity provides seamless access without needing explicit authentication credentials.

To list virtual machines, for example, you can run the following command inside the container:

```bash
az vm list --output table
```

The managed identity will use the permissions assigned to it to interact with the Azure resources as needed.

### 7. Clean Up Resources (Optional)

Once you're done with the container and managed identity, you can delete the resource group and all its associated resources:

```bash
az group delete --name AppControlResourceGroup --yes --no-wait
```

This command will remove the resource group, the container, and the managed identity.

### Conclusion

By following this procedure, you can deploy a container running AppControl’s gateway, agent, and Azure CLI in an Azure environment, using a managed identity for secure, password-less authentication. This setup allows the agent to execute Azure commands seamlessly, simplifying infrastructure management and monitoring.

For more advanced configurations or additional details, refer to the official Azure and AppControl documentation.

After the container is created and starts automatically, check its operation in Azure by examining the logs.

Now check on [AppControl](https://appcontrol.xcomponent.com/gateways?lng=en) to ensure the gateway is accessible.

![Image](../../images/gateway_started.png)

You are now ready to create your map in AppControl, utilizing this gateway and agent to monitor your Azure infrastructure.

Below is an example that supervises an Azure Function:

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes" ?>
<apps>
 <hosts>
  <host hostid="agent-azure" host="localhost" port="12567" sslprotocol="Tls12" />
 </hosts>
 <auths>
  <auth authid="LOCAL" domain="" password="" user="" />
 </auths>
 <app name="AZURE MAP" version="v1">
  <component name="Azure CLI" description="Azure access" hostref="agent-azure" authref="LOCAL" redirectoutput="false" type="file">
   <action value="az version" name="check" />
   <action value="az $(command)" commandname="Test az cli" name="custom">
    <parameters>
     <parameter name="command" value="account list" canedit="true" validation="\*" />
    </parameters>
   </action>
  </component>
  <component name="AzureFunction" description="Azure Function" hostref="agent-azure" authref="LOCAL" redirectoutput="true" type="browser">
   <father>Azure</father>
   <action value="az functionapp show --ids /subscriptions/[SUBSCRIPTION-ID]/resourceGroups/[RESOURCE-GROUP-NAME]/providers/Microsoft.Web/sites/[FUNCTION-APP-NAME] --query 'state' | grep -q '&#34;Running&#34;'" name="check" />
   <action value="az functionapp start --ids /subscriptions/[SUBSCRIPTION-ID]/resourceGroups/[RESOURCE-GROUP-NAME]/providers/Microsoft.Web/sites/[FUNCTION-APP-NAME]" name="enable" />
   <action value="az functionapp stop --ids /subscriptions/[SUBSCRIPTION-ID]/resourceGroups/[RESOURCE-GROUP-NAME]/providers/Microsoft.Web/sites/[FUNCTION-APP-NAME]" name="disable" />
  </component>
 </app>
</apps>
```
