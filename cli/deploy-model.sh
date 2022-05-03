
model_id=$1
model_version=$2

[[ -z "$model_id" ]] && { echo "model_id is empty" ; exit 1; }

echo "Model id: $model_id and model version: $model_version"

endpoint_name=$(echo $model_id | sed 's/nyctaxi-model/ep/')
endpoint_name=$(echo $endpoint_name | sed 's/_/-/')
deployment_name=$(echo $model_id | sed 's/model/deployment/')

az ml online-endpoint create --name $endpoint_name --file src/online-endpoint/endpoint.yml

az ml online-deployment create --name $deployment_name --endpoint-name $endpoint_name --set model=azureml:$model_id:$model_version

az ml online-endpoint show --name $endpoint_name 

az ml online-deployment show --name $deployment_name --endpoint-name $endpoint_name 

echo "\n\n\n\nSample scoring request file:\n\n\n"

cat src/online-endpoint/sample.json

echo "\n\n\n\nSample scoring response:\n\n\n"

az ml online-endpoint invoke --name $deployment_name --request-file src/online-endpoint/sample.json

echo "\n\n\n\n"

echo "::set-output name=EPURI::https://ml.azure.com/endpoints/realtime/$endpoint_name?flight=ModelRegisterV2,ModelRegisterExistingEnvironment,dpv2data"