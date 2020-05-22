#!/bin/bash

#gcloud container clusters get-credentials mobileservices-hle-use1-1 --zone us-east1-b --project soju-mobile-hle

for ns in $(kubectl get ns  --no-headers |grep -v cmon | grep -v stage |grep -v relqa2 |grep -v relqa3 |grep -i relqa|grep -i prod| grep -v uat | grep -v svctest1  | grep -v uat |grep -v tui |grep -v egproxy |grep -v redis |grep -v stage|awk '{ print $1 }');
do

   depno=`kubectl get deploy -n $ns --no-headers| awk '$5!=0' | awk '{print $1}'`
   #Hpa=$(kubectl get hpa $depno --namespace=$ns | grep -v unknown)
   Image=$(kubectl describe deploy $depno -n $ns | grep -i image)

   echo "Namespace: $ns" ;
   echo "depno: $depno" ;
   #echo "Hpa: $Hpa" ;
   echo "Image: $Image" ;

done

