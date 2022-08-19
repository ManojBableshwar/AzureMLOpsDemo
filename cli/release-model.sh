endpoint_name=$1
deployment_name=$2
rg=$3
ws=$4

if [[ ! -z "$ws" ]]
then
   ws_info="--workspace-name $ws --resource-group $rg"
fi

[[ -z "$endpoint_name" ]] && { echo "endpoint_name is empty" ; exit 1; }
[[ -z "$deployment_name" ]] && { echo "deployment_name is empty" ; exit 1; }

echo "endpoint_name: $endpoint_name and deployment_name: $deployment_name"

az ml online-endpoint update --traffic "$deployment_name=100" --name $endpoint_name $ws_info || {
    echo "deployment traffic update failed..."; exit 1; 
}

az ml online-endpoint show --name $endpoint_name $ws_info

az ml online-deployment show --name $deployment_name --endpoint-name $endpoint_name $ws_info

echo "\n\n\n\nDeleting older deployments...\n\n\n"

for x in $(az ml online-deployment list --endpoint-name $endpoint_name  --query [*].name $ws_info | grep "\"" | sed 's/[\", ]//g')
do
  if [[ $deployment_name != $x ]]
  then
    echo "Deleting $x ..."
    az ml online-deployment delete --endpoint-name $endpoint_name --name $x --yes $ws_info || {
      echo "$x deployment delete failed..."; exit 1; 
    }
  fi
done  
