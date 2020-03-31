#update the hpa based on the inputs
function downScale() {
  #Read parameters
  context=$1
  threshold=$2
  namespace=$3
  hpa_name=$4
  min_pods=$5
  max_pods=$6
  target_cpu=$7

 #Read running pod count
  running_pods=`kubectl --context=$context get hpa ${hpa_name} -n $namespace --no-headers | awk '{print $4}'`

  if [[ $min_pods != $running_pods ]]; then
    running_pods=$(($running_pods-$threshold))
    if [[ $min_pods -gt $running_pods ]]; then
      running_pods=$min_pods
    fi
    if [[ $max_pods -gt $running_pods ]]; then
      max_pods_temp=$max_pods
    else
      max_pods_temp=$running_pods
    fi
    kubectl --context=$context patch hpa ${hpa_name} -n $namespace --patch '{"spec":{"targetCPUUtilizationPercentage":'${target_cpu}',"minReplicas":'${running_pods}',"maxReplicas":'${max_pods_temp}'}}'
    kubectl --context=$context scale deploy ${hpa_name} -n $namespace --replicas=${running_pods}
    echo "$hpa_name min_pods $min_pods max_pods $max_pods_temp running_pods $running_pods"
    echo ""
    isDownScale=true
  fi
}

#set the context based on the zone
if [[ ${zone} == "central" ]]; then

  mtn_context="gke_Soju-project_us-central1-Soju--prd-usc1-1"
  mtn_proxy_context="gke_Soju-project_us-central1-Soju--proxy-prd-usc1-1"
  k_proxy_context="gke_Soju-project_us-central1-b_k-proxy-prd-usc1-1"
  w_context="gke_Soju-project_us-central1-b_w-prd-usc1-1"

elif [[ ${zone} == "east" ]]; then

  mtn_context="gke_Soju-project_us-east1-Soju--prd-use1-1"
  mtn_proxy_context="gke_Soju-project_us-east1-Soju--proxy-prd-use1-1"
  kp_groxy_context="gke_Soju-project_us-east1-b_k-proxy-prd-use1-1"
  w_context="gke_Soju-project_us-east1-b_w===-prd-use1-1"

fi

#define the threshold to downscale
mtn_threshold=5
egress_threshold=5
ingress_threshold=5
w_threshold=5

isDownScale=true

while [[ $isDownScale = true ]]; do
  isDownScale=false
  #cpu/max pod changes keep here
  #kubectl patch hpa ${hpa_name} -n $namespace --patch '{"spec":{"targetCPUUtilizationPercentage":${target_cpu},"minReplicas":${running_pods},"maxReplicas":${max_pods_temp}}}'

  #pass arguments in below format
  #downScale k8s_context threshold namespace hpa_name min_pods max_pods target_cpu
#  downScale $mtn_context $mtn_threshold browse-perf browse-75-1 5 10 45
#  downScale $mtn_egproxy_context $egress_threshold egproxy-perf egproxy-10 15 40 60
  downScale $mtn_context $mtn_threshold b-perf browse-75-1 26 40 45
  downScale $mtn_egproxy_context $egress_threshold proxy-perf proxy-10 30 120 60


  if [[ $isDownScale == true ]]; then
    sleep 60
  fi
done

#based on
if [[ ${mtn} == "true" ]]; then
  kubectl --context=$mtn_context get hpa --all-namespaces | grep -v unknown
  kubectl --context=$mtn_proxy_context get hpa --all-namespaces | grep -v unknown
fi

if [[ ${w} == "true" ]]; then
  kubectl --context=$w_context get hpa --all-namespaces | grep -v unknown
  kubectl --context=$kp_proxy_context get hpa --all-namespaces | grep -v unknown
fi
