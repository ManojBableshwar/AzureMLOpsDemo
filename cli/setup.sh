az extension add -n ml -y

GROUP=${{ github.event.inputs.name.GROUP }}

LOCATION=${{ github.event.inputs.name.LOCATION }}

WORKSPACE=${{ github.event.inputs.name.WORKSPACE }}

az configure --defaults group=$GROUP workspace=$WORKSPACE location=$LOCATION

