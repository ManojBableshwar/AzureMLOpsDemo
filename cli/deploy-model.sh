
model_id=$1
model_version=$2
model_reg_id=$3
rg=$4
ws=$5

if [[ ! -z "$ws" ]]
then
   ws_info="--workspace-name $ws --resource-group $rg"
fi

if [[ ! -z "$model_reg_id" ]]
then
  model_info=$model_reg_id
else
  model_info="azureml:$model_id:$model_version"
fi


[[ -z "$model_info" ]] && { echo "model_info is empty" ; exit 1; }

echo "Model info: $model_info"


endpoint_name='nyc-taxi-ep'

# endpoint and deployment name can be max 32 char long...
# endpoint_name=$(echo $model_id | sed 's/nyctaxi-model/ep/')
deployment_name=$(echo $model_id | sed 's/nyctaxi-model/dply/')

# endpoint and deployment name cannot contain '_'; one alpha numeric and '-'
# endpoint_name=$(echo $endpoint_name | sed 's/_/-/g')
deployment_name=$(echo $deployment_name | sed 's/_/-/g')


az ml online-endpoint show --name $endpoint_name 


if [[ $? != 0 ]]
then
  echo "Endpoint $endpoint_name does not exist. Creating..."
  az ml online-endpoint create --name $endpoint_name --file src/online-endpoint/endpoint.yml $ws_info|| {
    echo "endpoint create failed..."; exit 1; 
  }
fi


az ml online-deployment create --name $deployment_name --endpoint-name $endpoint_name \
--set model=$model_info --file src/online-endpoint/deploy.yml $ws_info  || {
    echo "deployment create failed..."; exit 1; 
}

az ml online-deployment show --name $deployment_name --endpoint-name $endpoint_name $ws_info

echo "\n\n\n\nSample scoring request file:\n\n\n"

cat src/online-endpoint/sample.json

echo "\n\n\n\nSample scoring response:\n\n\n"

az ml online-endpoint invoke --name $endpoint_name --deployment-name $deployment_name --request-file src/online-endpoint/sample.json $ws_info

echo "\n\n\n\n"

echo "::set-output name=ENDPOINTID::$endpoint_name"

echo "::set-output name=DEPLOYMENTID::$deployment_name"

echo "::set-output name=EPURI::https://ml.azure.com/endpoints/realtime/$endpoint_name?flight=ModelRegisterV2,ModelRegisterExistingEnvironment,dpv2data"