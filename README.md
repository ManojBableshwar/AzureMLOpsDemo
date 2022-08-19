# AzureMLOpsDemo

Make your you have `az login` and `az account set`

```
GROUP="rg-contoso-819prod"

LOCATION="eastus"

WORKSPACE="mlw-contoso-819prod"

SUBSCRIPTION=$(az account show --query id -o tsv)


echo "Installing Azure CLI extension for Azure Machine Learning..."

az extension add -n ml -y



echo "Creating service principal and setting repository secret..."

SP_DISPLAY_NAME="contoso_mlops_demo_sp"

az ad sp create-for-rbac --name $SP_DISPLAY_NAME --role owner --scopes /subscriptions/$SUBSCRIPTION/resourceGroups/$GROUP --sdk-auth | gh secret set AZ_CREDS_CONTOSO_MLOPS

If you need to grant more resources access to the same service principal, use the following commands:

Get the app id:
appid=$( az ad sp list --display-name $SP_DISPLAY_NAME | grep appId | awk -F: '{print $2}' | sed s/\"//g | sed s/,//g )

az role assignment create --assignee $appid --role Owner --scope /subscriptions/$SUBSCRIPTION/resourceGroups/$GROUP 

echo "Configuring Azure CLI defaults..."

az configure --defaults group=$GROUP workspace=$WORKSPACE location=$LOCATION

