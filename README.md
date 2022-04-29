# AzureMLOpsDemo

Make your you have `az login` and `az account set`

```
GROUP="rg-contoso-819prod"

LOCATION="eastus"

WORKSPACE="mlw-contoso-819prod"

SUBSCRIPTION=$(az account show --query id -o tsv)

SECRET_NAME="AZ_CREDS"

echo "Installing Azure CLI extension for Azure Machine Learning..."

az extension add -n ml -y

echo "Creating service principal and setting repository secret..."

az ad sp create-for-rbac --name $GROUP --role owner --scopes /subscriptions/$SUBSCRIPTION/resourceGroups/$GROUP --sdk-auth | gh secret set $SECRET_NAME

echo "Configuring Azure CLI defaults..."

az configure --defaults group=$GROUP workspace=$WORKSPACE location=$LOCATION

