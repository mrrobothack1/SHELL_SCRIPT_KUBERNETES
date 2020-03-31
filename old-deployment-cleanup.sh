#!/bin/bash

output_log=$1

if [ $output_log != "" ]; then
for ns in $(kubectl get ns| grep -vE "NAME|kube-system|kube-public|default" | awk '{print $1}'); do

    # for ns in r19-5-mui-dev; do
    if [ $(kubectl get svc -n $ns| grep -v "NAME" | wc -l) -eq 1 ];then
      for svc in $(kubectl get svc -n $ns| grep -v "NAME"| awk '{print $1}'); do
        selector=$(kubectl describe svc $svc -n $ns| grep 'Selector:' | cut -d ':' -f2 | tr -s ' ')
        runningDeployment=$(kubectl get deploy -n $ns -l $selector| grep -v "NAME"| awk '{print $1}')

        echo '#############' $ns '#############'
        echo '--->' "Selector: $selector ' ---> Running Dep: '$runningDeployment" >> $output_log

        for deploy in $(kubectl get deploy -n $ns| awk '$2!=0'| grep -v "NAME"| awk '{print $1}' | grep -vw "runningDeployment"); do
          echo 'Scaled down deploy: ' $deploy >> $output_log
          kubectl scale deploy $deploy -n $ns --replicas=0
        done

        if [ $runningDeployment != "" ]; then
          for rs in $(kubectl get rs -n $ns| awk '$2!=0'| grep -v "NAME"| awk '{print $1}'); do
            rsOwner=$(kubectl get rs $rs -n $ns -o json| jq '.metadata.ownerReferences[].name'| tr -d '"')
            if [ "$rsOwner" = "" ]; then
              echo "Scaled down rs: $rs $rsOwner" >> $output_log
              kubectl scale rs $rs -n $ns --replicas=0
            elif [ $(echo $rsOwner | grep -w "runningDeployment") ]; then
              echo "Scaled down rs-deploy: $deploy  $rs $rsOwner" >> $output_log
              kubectl scale deploy $deploy -n $ns --replicas=0
            else
              echo "Deployment Not Deleted:  $rsOwner" >> $output_log
            fi
          done
        fi

      done
    fi
  done
else
  echo "Please pass the argument"
fi
x