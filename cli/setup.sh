az extension remove -n azure-cli-ml
az extension remove -n ml
az extension add -n ml -y

# Use defaults if not passed by workflow inputs

GROUP1=${GROUP:-"rg-contoso-819prod"}

LOCATION1=${LOCATION:-"eastus"}

WORKSPACE1=${WORKSPACE:-"mlw-contoso-819prod"}

az configure --defaults group=$GROUP1 workspace=$WORKSPACE1 location=$LOCATION1

