az extension add -n ml -y

GROUP="rg-contoso-819prod"

LOCATION="eastus"

WORKSPACE="mlw-contoso-819prod"

az configure --defaults group=$GROUP workspace=$WORKSPACE location=$LOCATION

