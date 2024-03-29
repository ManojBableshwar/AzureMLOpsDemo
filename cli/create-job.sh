job=$1
compute=$2
rg=$3
ws=$4

if [[ ! -z "$ws" ]]
then
   ws_info="--workspace-name $ws --resource-group $rg"
fi

if [[ ! -z "$compute" ]]
then
   compute_param="--set settings.default_compute=$compute"
fi



export run_id=$(az ml job create --file $job $compute_param --query name -o tsv $ws_info)
#export run_uri=$(az ml job show --name $run_id --query services.Studio.endpoint $ws_info)
export run_uri="https://ml.azure.com/runs/$run_id?flight=ModelRegisterV2,ModelRegisterExistingEnvironment,dpv2data"
az ml job show --name $run_id $ws_info

if [[ -z "$run_id" ]]
then
    echo "Job creation failed"
    exit 3
fi

status=$(az ml job show --name $run_id --query status -o tsv $ws_info)

if [[ -z "$status" ]]
then
    echo "Status query failed"
    exit 4
fi

job_uri=$(az ml job show --name $run_id --query services.Studio.endpoint $ws_info)

echo $job_uri

running=("Queued" "NotStarted" "Starting" "Preparing" "Running" "Finalizing")
while [[ ${running[*]} =~ $status ]]
do
    echo $job_uri
    sleep 8 
    status=$(az ml job show --name $run_id --query status -o tsv $ws_info)
    echo $status
done

if [[ $status == "Completed" ]]
then
    echo "Job completed"
    echo "::set-output name=RUNID::$run_id"
    echo "::set-output name=RUNURI::https://ml.azure.com/runs/$run_id?flight=ModelRegisterV2,ModelRegisterExistingEnvironment,dpv2data"
    exit 0
elif [[ $status == "Failed" ]]
then
    echo "Job failed"
    exit 1
else
    echo "Job not completed or failed. Status is $status"
    exit 2
fi   