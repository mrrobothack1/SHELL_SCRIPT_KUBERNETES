#! /bin/bash 

REDIS_MASTER_CONFIG_MAP=redis-master-config
REDIS_SLAVE_CONFIG_MAP=redis-slave-config
REDIS_SENTINEL_CONFIG_MAP=redis-sentinel-config

allocated_memory=$(cat redis-controller.yaml | grep memory | sed 1d | tr -d [:space:] | cut -c 9,10,11,12)
redis_maxmemory=$(cat redis-slave-config | grep maxmemory | awk NR==4 | awk '{print$2}' | cut -c 1,2,3,4 )

namespace=$1
service=$2


function deploy() {

#Creating namespace 
if [[ $(kubectl describe ns $namespace) ]];
then 
    echo "Namespace alredy exists"
    if  [[ $(kubectl get rc -n $namespace) ]]
    then 
        kubectl delete rc $service-redis $service-redis-sentinel -n $namespace
    fi
else 
    kubectl create ns $namespace
fi

#creating redis-sentinel service
 if  [[ $(kubectl get svc -n $namespace) ]]
 then
     echo "Service already existing"
else
    kubectl create -f redis-sentinel-service.yaml -n $namespace
fi

#creating bootstap pod
echo "Creating Bootstrap Redis"
if [[ $(kubectl get pods -n $namespace) ]]
then
    echo "Bootsrap already exits"
else
    kubectl create -f redis-master-deploy.yaml -n $namespace
    
fi
sleep 10s 

master_ip=$(kubectl get pod -n $namespace -o wide |  sed  1d | awk '{print$6}')
if [[ $master == none ]]
then 
    echo sleep 10s 
else
    master_ip=$(kubectl get pod -n $namespace -o wide |  sed  1d | awk '{print$6}')
fi
#Updating master_ip in salve config 
echo $master_ip
echo "Updating master_ip in salve config"

if [[ -f $REDIS_SLAVE_CONFIG_MAP.org ]]
then 
    mv $REDIS_SLAVE_CONFIG_MAP.org $REDIS_SLAVE_CONFIG_MAP
fi
sed -i '.org' "s/slaveof %master-ip% %port%/slaveof $master_ip 6379/g" redis-slave-config

if [[ -f $REDIS_SENTINEL_CONFIG_MAP.org ]]
then 
    mv $REDIS_SENTINEL_CONFIG_MAP.org $REDIS_SENTINEL_CONFIG_MAP
fi
sed -i '.org' "s/sentinel monitor mymaster %master-ip% 6379 2/sentinel monitor mymaster $master_ip 6379 2/g" redis-sentinel-config

#creating config map for slave
echo "creating config map" 
if [[ -f $REDIS_SLAVE_CONFIG_MAP  ]]
then 
    echo "creating slave config map" 
    kubectl create cm $REDIS_SLAVE_CONFIG_MAP --from-file=$REDIS_SLAVE_CONFIG_MAP -n $namespace
fi

#creating config map for master
if [[ -f $REDIS_MASTER_CONFIG_MAP  ]]
then 
    echo "creating master config map" 
    kubectl create cm  $REDIS_MASTER_CONFIG_MAP --from-file=$REDIS_MASTER_CONFIG_MAP -n $namespace
fi

#creating config map for sentinel
if [[ -f $REDIS_SENTINEL_CONFIG_MAP  ]]
then 
    echo "creating sentinel config map" 
    kubectl create cm  $REDIS_SENTINEL_CONFIG_MAP --from-file=$REDIS_SENTINEL_CONFIG_MAP -n $namespace
fi

echo "creating replication controller"
#creating replication controller for redis 
kubectl create -f redis-controller.yaml -n $namespace
sleep 5s
#creating replication controller for sentinel
kubectl create -f redis-sentinel-controller.yaml -n $namespace
sleep 5s
echo "Redis cluster has been deployed successfully.Please scale accordingly"

#Creating config map for Cron Jobs
kubectl create cm sentinelresetscript-01 --from-file=redis-sentinel-reset.sh -n $namespace
kubectl create cm sentinelresetenvconfig-01 --from-file=sentinelresetenvconfig-01 -n $namespace

#Creating Cron Jobs 
kubectl create -f redis-sentinel-reset-cron.yaml -n $namespace

}


if [[ $allocated_memory -gt	$redis_maxmemory ]] || [[ $allocated_memory -eq	$redis_maxmemory ]];
then 
    deploy
    exit 0
else 
    echo "maxmemory is more than allocated memory"
fi
