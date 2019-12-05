## Confirm no VNIDs (from Master)
oc get netnamespace

## Execute from a Master node
for c in $(oc get cm -n openshift-node | awk '{print($1)}' | tail -n +2)
do
 oc get cm $c -o yaml --export -n openshift-node > ${c}-backup-$(date +%Y%m%d%k%M).yaml
 oc get cm $c -o yaml --export -n openshift-node | sed 's/redhat\/openshift-ovs.*/redhat\/openshift-ovs-multitenant/g' | oc -n openshift-node replace -f -

 echo "Config map: ${c} now using networkPlugin:"
 oc get cm $c -o yaml --export -n openshift-node | grep networkPlugin

done


## Masters (Deprecated -- use to confirm configMap update above)
## ansible -i inventory masters -m replace -a "path=/etc/origin/master/master-config.yaml regexp='networkPluginName.*' replace='networkPluginName: "redhat/openshift-ovs-multitenant"'" --diff --check

## Nodes (Deprecated -- use to confirm configMap update above)
## ansible -i inventory nodes -m replace -a "path=/etc/origin/node/node-config.yaml regexp='networkPluginName.*' replace='networkPluginName: "redhat/openshift-ovs-multitenant"'" --diff --check

## Master Service Restarts
ansible -i inventory masters -m shell -a "master-restart api"
ansible -i inventory masters -m shell -a "master-restart controllers"

## Node Service Halt
ansible -i inventory nodes -m shell -a "systemctl stop atomic-openshift-node.service"

## SDN Pod Restarts (from Master)
oc delete pod --all -n openshift-sdn

## Node Service Restarts
ansible -i inventory nodes -m shell -a "systemctl restart atomic-openshift-node.service"

## Confirm set VNIDs (from Master)
oc get netnamespace
