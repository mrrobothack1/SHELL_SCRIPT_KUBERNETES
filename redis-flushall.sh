#!/bin/bash

gcloud container clusters get-credentials ${CLUSTER_NAME} --zone ${ZONE} --project ${PROJECT_ID}

NS=$(kubectl get ns --no-headers |grep "redis" |grep -w "${app}" |awk '{print $1}')

echo "======= Namespace is $NS =========="

EP=$(kubectl get ep -n $NS --no-headers | awk '{print $2}' |  cut -f 1 -d ":")

echo "======= Endpoint for $NS is $EP =========="

REDIS_CLUSTER=$(gcloud compute forwarding-rules list |grep ${EP} |awk '{print $1 }' | cut -f 1-3 -d  "-")
REDIS_REGION=$(gcloud compute forwarding-rules list |grep ${EP} |awk '{print $2 }')

echo "=======Redis cluster:$REDIS_CLUSTER | Redis Region:$REDIS_REGION =========="

REDIS_CN=$(gcloud container clusters list | grep ${REDIS_CLUSTER} | grep -w ${REDIS_REGION} | awk '{print $1}')
REDIS_CN_R=$(gcloud container clusters list | grep ${REDIS_CLUSTER} | grep -w ${REDIS_REGION} | awk '{print $2}')

gcloud container clusters get-credentials ${REDIS_CN} --zone ${REDIS_CN_R} --project soju-m-hle

REDIS_POD=$(kubectl get po -n ${app}-redis-perf --no-headers | grep -v sentinel |awk '{print $1} ' |tail -1)

MASTER_CHECK=$(kubectl exec -it ${REDIS_POD} -n ${app}-redis-perf -- bash -c "redis-cli info | grep ^role" |cut -d ":" -f2)

MASTER_CHECK_res=`echo "$MASTER_CHECK" | sed 's/[^a-zA-Z0-9]//g'`

if [[ "$MASTER_CHECK_res" == "master" ]]
then
    MASTER_POD=$(kubectl get po -n ${app}-redis-perf |grep ${REDIS_POD} |awk '{print $1}')
    echo "======logining to MASTER POD -> $MASTER_POD======="

    echo "======Getting Keyspace and ttl Value......========"

    KEYSPACE=$(kubectl exec -it $MASTER_POD -n ${app}-redis-perf -- bash -c "redis-cli INFO Keyspace")


    echo "======Keyspace and ttl Value --> $KEYSPACE"


    echo "======Running flushall command..........========"

	#kubectl exec -it $MASTER_POD -n ${app}-redis-perf -- bash -c "redis-cli FLUSHALL"

    echo "======Getting Keyspace and ttl Value after flushall....."

    KEYSPACE_FLUSHALL=$(kubectl exec -it $MASTER_POD -n ${app}-redis-perf -- bash -c "redis-cli INFO Keyspace")

    echo "=======Keyspace and ttl Value after flushall ---> $KEYSPACE_FLUSHALL"

else
	MASTER_IP=$(kubectl exec -it ${REDIS_POD} -n ${app}-redis-perf -- bash -c "redis-cli info" |grep master_host |cut -d ":" -f2)

	MASTER_IP_res=`echo "$MASTER_IP" | sed 's/[^a-zA-Z0-9.]//g'`

	MASTER_POD1=$(kubectl get po -n ${app}-redis-perf -o wide |grep ${MASTER_IP_res} |awk '{print $1}')

	MASTER_POD1_res=`echo "$MASTER_POD1" | sed 's/[^a-zA-Z0-9-]//g'`

    echo "======logining to MASTER POD -> $MASTER_POD1_res======="

    echo "======Getting Keyspace and ttl Value......========"

	KEYSPACE_SLAVE=$(kubectl exec -it $MASTER_POD1_res -n ${app}-redis-perf -- bash -c "redis-cli INFO Keyspace")

	echo "======Keyspace and ttl Value --> $KEYSPACE_SLAVE"

    echo "======Running flushall command..........========"

	#kubectl exec -it $MASTER_POD1_res -n ${app}-redis-perf -- bash -c "redis-cli FLUSHALL"

    echo "======Getting Keyspace and ttl Value after flushall....."

    KEYSPACE_FLUSHALL_SLAVE=$(kubectl exec -it $MASTER_POD1_res -n ${app}-redis-perf -- bash -c "redis-cli INFO Keyspace")

    echo "=======Keyspace and ttl Value after flushall ---> $KEYSPACE_FLUSHALL_SLAVE"

fi
