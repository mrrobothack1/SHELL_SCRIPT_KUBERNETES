#!/bin/bash
namespace=$1
region=$2
podarr=(`kubectl get po -n $namespace |awk '{if(NR>1)print}'| awk {'print $1'}`)
#for pod_name in "${podarr[@]:1}"
for pod_name in "${podarr[@]}"
do
kubectl exec  $pod_name --namespace=$namespace -- bash -c "pid=\$(ps -aux|grep java|grep /soju/config/application/ | awk '{print \$2}'|sed -n 1p) && \
jstack -l \$pid > threaddump_$pod_name.txt"
kubectl cp $namespace/$pod_name:/threaddump_$pod_name.txt ./threaddump_$pod_name\_$region.txt 
echo $pod_name
done
