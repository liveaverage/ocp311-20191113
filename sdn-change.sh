## Confirm no VNIDs (from Master)
oc get netnamespace

## Masters
ansible -i inventory masters -m replace -a "path=/etc/origin/master/master-config.yaml regexp='networkPluginName.*' replace='networkPluginName: "ovs-multitenant"'" --diff --check

## Nodes
ansible -i inventory nodes -m replace -a "path=/etc/origin/node/node-config.yaml regexp='networkPluginName.*' replace='networkPluginName: "ovs-multitenant"'" --diff --check

## Master Service Restarts
ansible -i inventory masters -m shell -a "master-restart api"
ansible -i inventory masters -m shell -a "master-restart controllers"

## Node Service Halt
ansible -i inventory nodes -m shell -a "systemctl stop atomic-openshift-node.service"

## SDN Pod Restarts
oc delete pod --all -n openshift-sdn

## Node Service Restarts
ansible -i inventory nodes -m shell -a "systemctl restart atomic-openshift-node.service"

## Confirm set VNIDs (from Master)
oc get netnamespace
