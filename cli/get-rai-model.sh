run_id=$1

#model_id="nyctaxi-model-$run_id"
#model_version=1

[[ -z "$run_id" ]] && { echo "run_id is empty" ; exit 1; }

export child_run_id=$(az ml job list --parent-job-name $run_id --query [3].name | sed s/\"//g)

az ml job show --name $child_run_id

az ml job download --name $child_run_id --output-name model_info_output_path

model_id=$(cat named-outputs/model_info_output_path/model_info.json | awk -F'"' '{print $4}' | awk -F':' '{print $1}')
model_version=$(cat named-outputs/model_info_output_path/model_info.json | awk -F'"' '{print $4}' | awk -F':' '{print $2}')
echo "::set-output name=CHILDRUNID::$child_run_id"

#az ml model create --name $model_id --version $model_version --type mlflow_model --path azureml://jobs/$child_run_id/outputs/artifacts/model/ || {
#    echo "model create failed..."; exit 1;
#}

az ml model show --name $model_id --version $model_version

echo "::set-output name=MODELID::$model_id"
echo "::set-output name=MODELURI::https://ml.azure.com/model/$model_id:$model_version?flight=ModelRegisterV2,ModelRegisterExistingEnvironment,dpv2data"