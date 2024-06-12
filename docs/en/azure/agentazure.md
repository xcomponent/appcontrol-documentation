# In AppControl, how supervise and monitor Azure resources

## Useful Links :

### Docker Images

- Gateway :

```bash
docker pull xcomponent/x4b-gateway:latest
```


### Azure Documentation

- [Azure CLI documentation](https://learn.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)
- [Azure CLI Installation](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)

## Environment Setup :

- A dedicated resource group if possible.
- A managed identity within this group. It will be used by the agent when calling "az login."
- A virtual network and subnet to allow defining a private IP for the agent and possible communication between the gateway and the agent.
- Deploy an ACI for the gateway with the desired image.
- Deploy an ACI for the agent with the following image.

Note that both ACIs will be in the same subnet, and the agent's ACI should preferably use the managed identity assigned by the system.

Once this environment is created, you can set up a map in AppControl to supervise the Azure resources you're interested in.

## Installation procedure

Setting up this environment requires the installation of the Azure CLI package. Most actions will be performed through it.

1. Authenticate to Azure :

```bash
az login
```

2. Set the subscription where you want to set up this environment:

```bash
az account set --subscription [**SUBSCRIPTION-ID**]
```

3. Create a resource group in your Azure subscription:

```bash
az group create --name [**RESOURCE-GROUP-NAME**] --location [**northeurope par exemple**]
```

4. Create the managed identity for the resource group:

```bash
az identity create --resource-group [**RESOURCE-GROUP-NAME**] --name [**IDENTITY-NAME**]
```

5. Create the virtual network and subnet for the gateway:

```bash
az network vnet create --name [**VNET-NAME**] --resource-group [**RESOURCE-GROUP-NAME**] --address-prefix 10.0.0.0/16 --subnet-name [**SUBNET-NAME**] --subnet-prefixes 10.0.0.0/24
```

6. Add a gateway record on the AppControl platform.

![](gateway_creation.png)

Copy the Docker command line on the gateway line created:

![](copy_command.png)

You obtain that :

```docker
docker run  --name [**YOUR-GATEWAY-NAME**] --hostname [**YOUR-GATEWAY-NAME**] -e X4B\_ACCESS\_KEY=[**YOUR-GATEWAY-SECRET-KEY**] -e X4B_SECRET_ACCESS_KEY=[**YOUR-GATEWAY-SECRET-KEY**] -e X4B_PROXY_NAME=[**YOUR-GATEWAY-NAME**] -e APPCONTROL_API_URL=https://appcontrol.xcomponent.com/core/ xcomponent/x4b-gateway:latest
```

In this command, you'll find the parameters to copy and place into the next command to create your gateway container.

```bash
az container create --resource-group [**RESOURCE-GROUP-NAME**] --name [**CONTAINER-GATEWAY-NAME**] --image xcomponent/x4b-gateway:latest --restart-policy OnFailure --environment-variables X4B_ACCESS_KEY=[**YOUR-GATEWAY-ACCESS-KEY**] X4B_SECRET_ACCESS_KEY=[**YOUR-GATEWAY-SECRET-KEY**] X4B_PROXY_NAME=[**YOUR-GATEWAY-NAME**] APPCONTROL_API_URL=https://appcontrol.xcomponent.com/core/ --vnet [**VNET-NAME**] --subnet [**SUBNET-NAME**]
```

After the container is created and starts automatically, check its operation in Azure by examining the logs.

![](gateway_container.png)

And in AppControl to ensure the gateway is accessible.

![](gateway_started.png)

You are now ready to create your map in AppControl using this gateway and agent to supervise your Azure infrastructure.

Here's an example that supervises an Azure function:

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
