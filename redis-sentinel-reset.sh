#!/bin/bash
# copyright soju
# Author:
# Creation Date: 14 Apr, 2019#
#
#
# This script resets the sentinels. Reset sentinel is based on no of actual slaves from master redis with slaves count from sentinels.
# Note: Redis Cluster desing has to be equal no of slaves and sentinels.


# envconfigfile=/soju/config/environment/env-config
# envconfigfile="/environment"

envconfigfile="$ENVIRONMENT_CONFIG_PATH"


if [ -f "$envconfigfile" ]
then
  sentinelservice=$(grep "sentinel-service" "$envconfigfile" | cut -d "=" -f2| tr -d " ")
  namespace=$(grep "namespace" "$envconfigfile" | cut -d '=' -f2| tr -d " ")
  redismaster=$(grep "spring.redis.sentinel.master" "$envconfigfile" | cut -d '=' -f2| tr -d " ")
else
  echo "$envconfigfile not found."
  exit 0
fi

echo "Sentinel Service: $sentinelservice"
echo "Redis Namespace: $namespace"
echo "Redis Master: $redismaster"
if [ $sentinelservice != "" ] && [ $namespace != "" ] && [ $redismaster != "" ]
then
  if [[ $(redis-cli -h "$sentinelservice"."$namespace".svc.cluster.local -p 26379 ping) == "PONG" ]]
  then
    masterinfo=$(redis-cli -h "$sentinelservice"."$namespace".svc.cluster.local -p 26379 info | grep "master0:name=")
    masterip=$(echo "$masterinfo" | cut -d ',' -f3 | cut -d ':' -f1 | cut -d '=' -f2)
  else
    echo "Redis Service is not available"
    exit 0
  fi
  if [[ $(redis-cli -h "$masterip" -p 6379 ping) == "PONG" ]]
  then
    master_info_slaves_count=$(redis-cli -h "$masterip" -p 6379 info | grep "connected_slaves" | cut -d ":" -f2 | tr -d " " | tr -dc '0-9')
  fi


  #fetching sentinel IP's
  sentinel_ips=$(redis-cli -h "$sentinelservice"."$namespace".svc.cluster.local -p 26379 sentinel sentinels mymaster | grep '10.')
  echo "Sentinel IP's List: $sentinel_ips"
  SAVEIFS=$IFS   # Save current IFS
  IFS=$'\n'      # Change IFS to new line
  sentinel_ips=($sentinel_ips) # split to array $names
  IFS=$SAVEIFS   # Restore IFS

  declare -i activesentinels=0

  for i in "${sentinel_ips[@]}"; do
      if [[ $(redis-cli -h "$i" -p 26379 ping) == "PONG" ]]
      then
        activesentinels=$((activesentinels+1))
      else
        echo "Deleting IP"
        sentinel_ips=( "${sentinel_ips[@]/$i}" )  #delete the ip from the arraylist
      fi
  done

  for i in "${sentinel_ips[@]}"; do
    if [ ! -z "$i" -a "$i" != " " ]
    then
      slaves_info_slaves_count=$(redis-cli -h "$i" -p 26379 info | grep "master0:name=mymaster" |  cut -d "," -f4 | cut -d "=" -f2 | tr -d " " | tr -dc '0-9')
      slaves_info_sentinels_count=$(redis-cli -h "$i" -p 26379 info | grep "master0:name=mymaster" |  cut -d "," -f5 | cut -d "=" -f2 | tr -d " " | tr -dc '0-9')

      echo "Sentinel IP: $i"
      echo "Slaves count from Master Info: $master_info_slaves_count"
      echo "Slaves count from Sentinel Info: $slaves_info_slaves_count"
      echo "Sentinels count from Sentinel Info: $slaves_info_sentinels_count"

      if [ "$slaves_info_slaves_count" != "$master_info_slaves_count" ] || [ "$slaves_info_sentinels_count" != "$master_info_slaves_count" ]
      then
        echo "Trigger Reset command"
        redis-cli -h "$i" -p 26379 sentinel reset mymaster
      else
        echo "Sentinel Reset not required at this time."
      fi
    fi
  done

fi