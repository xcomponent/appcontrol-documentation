# smar = Supervise and Monitor Azure Resources

# élément à récupérer en paramètre:
param (

    #[string]$APP_ID,
    #[string]$PASSWORD,
    #[string]$TENANT_ID,
    [string]$SUBSCRIPTION_ID,
    [string]$RESOURCE_GROUP_NAME,
    [string]$LOCALISATION,
    [string]$IDENTITY_NAME,
    [string]$VNET_NAME,
    [string]$SUBNET_NAME,
    [string]$CONTAINER_NAME,
    [string]$CONTAINER_GATEWAY_NAME,
    [string]$YOUR_GATEWAY_NAME,
    [string]$YOUR_GATEWAY_ACCESS_KEY,
    [string]$YOUR_GATEWAY_SECRET_KEY
)

<# 
az ad sp create-for-rbac --name connexion_mode_non_interactif
az ad sp credential reset --name connexion_mode_non_interactif #appID et password obtenu ici
az login --service-principal -u $APP_ID -p $PASSWORD --tenant $TENANT_ID
#>
az login

az account set --subscription $SUBSCRIPTION_ID
az group create --name $RESOURCE_GROUP_NAME --location $LOCALISATION
az identity create --resource-group $RESOURCE_GROUP_NAME --name $IDENTITY_NAME
az network vnet create --name $VNET_NAME --resource-group $RESOURCE_GROUP_NAME --address-prefix 10.0.0.0/16 --subnet-name $SUBNET_NAME --subnet-prefixes 10.0.0.0/24
az container create --resource-group $RESOURCE_GROUP_NAME --name $CONTAINER_NAME --image docker.io/xcomponent/agent-debian12-azure:36.0 --assign-identity --scope /subscriptions/$SUBSCRIPTION_ID/resourcegroups/$RESOURCE_GROUP_NAME --vnet $VNET_NAME --subnet $SUBNET_NAME

az container create --resource-group $RESOURCE_GROUP_NAME --name $CONTAINER_GATEWAY_NAME --image xcomponent/x4b-gateway:36.0 --restart-policy OnFailure --environment-variables X4B_ACCESS_KEY=$YOUR_GATEWAY_ACCESS_KEY X4B_SECRET_ACCESS_KEY=$YOUR_GATEWAY_SECRET_KEY X4B_PROXY_NAME=$YOUR_GATEWAY_NAME APPCONTROL_API_URL=https://appcontrol.xcomponent.com/core/ --vnet $VNET_NAME --subnet $SUBNET_NAME