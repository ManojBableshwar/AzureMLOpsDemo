run_id=$1

[[ -z "$run_id" ]] && { echo "run_id is empty" ; exit 1; }

export child_run_id=$(az ml job list --parent-job-name $run_id --query [2].name | sed s/\"//g)

az ml job show --name $child_run_id

echo "::set-output name=CHILDRUNID::$child_run_id"

export model_id=$(az ml model create --name nyctaxi-model-$run_id --path azureml://jobs/$child_run_id/outputs/artifacts/model/ --query name -o tsv)

az ml model show --name $model_id

echo "::set-output name=MODELID::$model_id"
echo "::set-output name=MODELURI::https://ml.azure.com/model/$model_id:1?flight=ModelRegisterV2,ModelRegisterExistingEnvironment,dpv2data"