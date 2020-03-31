#!/bin/bash

#gcloud container clusters get-credentials soju-projecte-use1-1 --zone us-east1-b --project -soju-hle

#for ns in $( kubectl get ns  --no-headers |grep -v stage | grep -i relqa2 | grep -v relqa | grep -v svctest1 | grep -v  svctest2 | grep -v  relqa3 | grep -v uat  |awk '{ print $1 }');
for ns in $( kubectl get ns --no-headers | grep -i relqa | grep -v relqa2 | grep -v relqa3 |awk ' {print $1 }' );
#kubectl get ns  --no-headers |grep -i relqa3 |grep -v relqa2|grep -v relqa|grep -v svctest2|grep -v svctest1|grep -v cmon |grep -v tui |grep -v egproxy |grep -v redis |grep -v stage|awk '{ print $1 }');
do

   depno=`kubectl get deploy -n $ns --no-headers| awk '$5!=0' | awk '{print $1}'`
  # Hpa=$(kubectl get hpa $depno --namespace=$ns | grep -v unknown)
   Image=$(kubectl describe deploy $depno -n $ns | grep -i image)
   #open=$(kubectl describe deploy $depno -n $ns | grep -i open)
#wallet=$(kubectl describe deploy $depno -n $ns | grep -i wallet)
#env=$(kubectl describe deploy $depno -n $ns | grep -i env-config | awk '{print $2}')
#kubectl describe deploy auth-29 -n auth-perf | grep -i env-config | awk '{print $2}'
#env_open=$(kubectl describe cm $env -n $ns | grep -i open)

echo "**********"
  echo "Namespace: $ns" ;
   echo "depno: $depno" ;
  #echo "Hpa: $Hpa" ;
  echo "Image: $Image" ;
  #echo "openapi: $open" ;
  #echo "wallet: $wallet";
#echo "env: $env";
#echo "env_open= $env_open";
echo "**********"
done


