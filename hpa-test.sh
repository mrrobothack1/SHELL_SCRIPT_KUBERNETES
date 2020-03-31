#!/usr/bin/env bash

# Author: Vishwanath Kendur
# Creation Date: 12 Mar 2019

# kubectl get hpa --all-namespaces --no-headers | awk '$(NF-1)!=0'

# kubectl get hpa --all-namespaces --no-headers | awk '$(NF-1)!=0'| awk '{print $1,$(NF-3),$(NF-2),$(NF-4)}' | sed -E -e 's/-[a-z]{1,8}//' -e 's/[0-9]{1,2}%\///' -e 's/%//'| tr ' ' ','
# ingress,8,15,60
# wallet,42,60,60
# vishwanath.k@K9-MAC-017 ~/Downloads/MRP/MyScripts (master●●●)$ kubectl get hpa --all-namespaces --no-headers | awk '$(NF-1)!=0'| awk '{print $1","$(NF-3)","$(NF-2)","$(NF-4)}' | sed -E -e 's/-[a-z]{1,8}//' -e 's/[0-9]{1,2}%\///' -e 's/%//'
# ingress,8,15,60
# wallet,42,60,60


while getopts hmag OPT; do
    case "$OPT" in
        h)
          echo USAGE ;;
        m)
            min=true;;
        a)
            all=true;;
        g)
            kubectl get hpa --all-namespaces --no-headers | awk '$(NF-1)!=0'| awk '{print $1","$(NF-3)","$(NF-2)","$(NF-4)}' | sed -E -e 's/-[a-z]{1,8}//' -e 's/[0-9]{1,2}%\///' -e 's/%//' >| hpa_details.txt
            echo 'hpa_details.txt'
            echo '---------------'
            cat hpa_details.txt
            ;;
    esac
done

if [ "$min" = "true" ] || [ "$all" = "true" ]; then
  echo "Changing HPA for cluster: " `kubectl config current-context | awk -F '_' '{print $NF}'`
  printf "Is this ok [yes/no] "
  read proceed

  if [ "$proceed" = "" ] || [ "$proceed" = "no" ]; then
      printf 'no';
      exit 1
  elif [ "$proceed" = "yes" ] || [ "$proceed" = "y" ]; then
      IFS=$'\n'
      for line in `kubectl get hpa --all-namespaces --no-headers | awk '{if ($(NF-1)!=0) print $1,$2}'`
      do
        deploy=$(echo $line | awk '{print $2}')
        ns=$(echo $line | awk '{print $1}')

        ns_sub_string=`echo $line | awk '{print $1}'| cut -d '-' -f1`

        if [ "$min" = "true" ]; then
          patchString="{\"spec\":{\"minReplicas\": 1}}"
        fi

        if [ -f hpa_details.txt ];then
          if [ `grep $ns_sub_string hpa_details.txt` ]; then
            if [ "$all" = "true" ]; then
              min_replicas=$(grep "$ns_sub_string" hpa_details.txt | cut -d ',' -f2)
              max_replicas=$(grep "$ns_sub_string" hpa_details.txt | cut -d ',' -f3)
              target_CPU_utilization_percentage=$(grep "$ns_sub_string" hpa_details.txt | cut -d ',' -f4)
              patchString="{\"spec\":{\"minReplicas\": $min_replicas, \"maxReplicas\": $max_replicas, \"targetCPUUtilizationPercentage\": $target_CPU_utilization_percentage}}"
            fi
          fi
        fi
          # patchString="{\"spec\":{\"minReplicas\": $min_replicas, \"maxReplicas\": $max_replicas, \"targetCPUUtilizationPercentage\": $target_CPU_utilization_percentage}}"
          # patchString="{\"spec\":{\"minReplicas\": $min_replicas, \"maxReplicas\": $max_replicas}}"
          # patchString="{\"spec\":{\"minReplicas\": $min_replicas}}"
        echo $patchString

          # echo $line
         kubectl patch hpa $deploy -n $ns --patch "$patchString"
      done
  fi
fi



/hpa_patch -g (to generate file)

./hpa_patch -a (to set min, max and CPU)

./hpa_patch -m (to set to min config)

