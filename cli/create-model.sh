run_id=$1
child_job_index=$2
model_id_prefix=$3
rg=$4
ws=$5
registry=$6

if [[ ! -z "$ws" ]]
then
   ws_info="--workspace-name $ws --resource-group $rg"
fi

reg_info
if [[ ! -z "$registry" ]]
then
   reg_info="--registry-name $registry"
fi

model_id="$model_id_prefix-$run_id"
model_version=1

[[ -z "$run_id" ]] && { echo "run_id is empty" ; exit 1; }

export child_run_id=$(az ml job list --parent-job-name $run_id --query [$child_job_index].name $ws_info | sed s/\"//g)

az ml job show --name $child_run_id $ws_info

echo "::set-output name=CHILDRUNID::$child_run_id"

if [[ ! -z "$reg_info" ]]
then
# the old way to download the model and create in registry is now changing to creating a model from job output and promoting to registry
#  az ml job download --name $child_run_id $ws_info || {
#    echo "model download failed..."; exit 1;
#  }
#  model_reg_id=$( az ml model create --name $model_id --version $model_version --type mlflow_model --path ./artifacts/model $reg_info --query id | sed s/\"//g ) || {
#    echo "model create in registry failed..."; exit 1;
#  }
   
   # create model in workspace
   az ml model create --path azureml://jobs/$child_run_id/outputs/artifacts/model --name $model_id --version $model_version --type mlflow_model $ws_info || {
    echo "model create in workspace failed..."; exit 1;
   }
   # promote model to registry
   model_in_workspace_path="azureml://subscriptions/$DEV_SUBSCRIPTION/resourceGroups/$DEV_GROUP/workspaces/$DEV_WORKSPACE/models/$model_id/versions/$model_version"
   model_reg_id=$(az ml model create --path $model_in_workspace_path $reg_info --query id | sed s/\"//g ) || {
        echo "model create in registry failed..."; exit 1;
   }
else
  az ml model create --name $model_id --version $model_version --type mlflow_model --path azureml://jobs/$child_run_id/outputs/artifacts/model/ $ws_info || {
    echo "model create in workspace failed..."; exit 1;
  }
fi

if [[ ! -z "$reg_info" ]]
then
  az ml model show --name $model_id --version $model_version  $reg_info || {
    echo "model show in registry failed..."; exit 1;
  }
else
  az ml model show --name $model_id --version $model_version  $ws_info || {
    echo "model show in workspace failed..."; exit 1;
  }
fi



echo "::set-output name=MODELID::$model_id"
echo "::set-output name=MODEL_REG_ID::$model_reg_id"
echo "::set-output name=MODELURI::https://ml.azure.com/model/$model_id:$model_version?flight=ModelRegisterV2,ModelRegisterExistingEnvironment,dpv2data"