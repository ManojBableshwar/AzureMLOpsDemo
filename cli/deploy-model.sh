
model_id="nyctaxi-model"
model_version=$1

[[ -z "$model_version" ]] && { echo "model_version is empty" ; exit 1; }

echo "Model id: $model_id and model version: $model_version"


endpoint_name='nyc-taxi-ep'

# endpoint and deployment name can be max 32 char long...
# endpoint_name=$(echo $model_id | sed 's/nyctaxi-model/ep/')
deployment_name=$(echo $model_id | sed 's/nyctaxi-model/dply/')

# endpoint and deployment name cannot contain '_'; one alpha numeric and '-'
# endpoint_name=$(echo $endpoint_name | sed 's/_/-/g')
deployment_name=$(echo $deployment_name | sed 's/_/-/g')


az ml online-endpoint create --name $endpoint_name --file src/online-endpoint/endpoint.yml || {
    echo "endpoint create failed..."; exit 1; 
}

az ml online-deployment create --name $deployment_name --endpoint-name $endpoint_name \
--set model=azureml:$model_id:$model_version --file src/online-endpoint/deploy.yml  || {
    echo "deployment create failed..."; exit 1; 
}

az ml online-endpoint show --name $endpoint_name 

az ml online-deployment show --name $deployment_name --endpoint-name $endpoint_name 

echo "\n\n\n\nSample scoring request file:\n\n\n"

cat src/online-endpoint/sample.json

echo "\n\n\n\nSample scoring response:\n\n\n"

az ml online-endpoint invoke --name $deployment_name --request-file src/online-endpoint/sample.json

echo "\n\n\n\n"

echo "::set-output name=EPURI::https://ml.azure.com/endpoints/realtime/$endpoint_name?flight=ModelRegisterV2,ModelRegisterExistingEnvironment,dpv2data"