
model_name=$1
instance_type="Standard_DS3_v2"

[[ -z "$model_name" ]] && { echo "model_name is empty" ; exit 1; }

model_asset_id="azureml://registries/HuggingFaceHub/models/$model_name/labels/latest"

echo "Model info: $model_info"

timestamp=$(date +%s)
endpoint_name="hf-ep-$timestamp"
deployment_name="demo-$timestamp"

az ml online-endpoint create --name $endpoint_name $ws_info|| {
    echo "endpoint create failed..."; exit 1; 
  }

az ml online-deployment create --name $deployment_name --endpoint-name $endpoint_name \
--set model=$model_info instance_type="$instance_type" --file src/online-endpoint/deploy.yml --all-traffic  || {
    echo "deployment create failed..."; exit 1; 
}

print("\n\az ml online-endpoint show --name $endpoint_name\n\n")
az ml online-endpoint show --name $endpoint_name
print("\n\az ml online-deployment show --name $deployment_name --endpoint-name $endpoint_name\n\n")
az ml online-deployment show --name $deployment_name --endpoint-name $endpoint_name
print ("\n\naz ml online-deployment get-logs --name $deployment_name --endpoint-name $endpoint_name\n\n")
az ml online-deployment get-logs --name $deployment_name --endpoint-name $endpoint_name

#az ml online-endpoint invoke --name $endpoint_name --deployment-name $deployment_name --request-file src/online-endpoint/sample.json $ws_info
az ml online-endpoint delete --name $endpoint_name

