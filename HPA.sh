mtn=true
w=true
zone=east

#set the context based on the zone
if [[ ${zone} == "central" ]]; then

  mtn_context="gke_soju-projectus-central1-b_soju-project-prd-usc1-1"
  mtn_proxy_context="gke_soju-projectus-central1-b_soju-proxy-prd-usc1-1"
  k_proxy_context="gke_soju-projectus-central1-b_k-proxy-prd-usc1-1"
  w_context="gke_soju-projectus-central1-b_w-prd-usc1-1"

  we_hpa="we"

elif [[ ${zone} == "east" ]]; then

  mtn_context="gke_soju-projectus-east1-b_soju-prd-use1-1"
  mtn_proxy_context="gke_soju-projectus-east1-b_soju-proxy-prd-use1-1"
  k_proxy_context="gke_soju-projectus-east1-b_kpservices-proxy-prd-use1-1"

  e_hpa="encryption-34-3"

fi

#based on option upscale the hpa's
if [[ ${mtn} == "true" ]]; then

  kubectl --context=$mtn_context -n -prod patch hpa -116 --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":30,"maxReplicas":80}}'

  kubectl --context=$mtn_context -n -prod patch hpa -58-c3a59ac-1 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":2,"maxReplicas":40}}'

  kubectl --context=$mtn_context -n -prod patch hpa -1363 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":5,"maxReplicas":40}}'

  kubectl --context=$mtn_context -n -prod patch hpa -62-08fcad0 --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":2,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa -66-5673bbe-1 --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":2,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa -67-f9fa531 --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":2,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa -65-205a5ad --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":4,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa -29-4b0e3df-3 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":2,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa $we --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":2,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa amp--35421fb --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":1,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa -93-12 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":2,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa -49-16 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":2,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa -25-1 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":2,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa -13-2 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":1,"maxReplicas":10}}'

  kubectl --context=$mtn_context -n -prod patch hpa r-60-161693c-1 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":2,"maxReplicas":10}}'


  #proxy hpa changes
  kubectl --context=$mtn_egproxy_context -n proxy-prod patch hpa -8 --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":60,"maxReplicas":240}}'
fi

if [[ ${w} == "true" ]]; then

kubectl --context=$w_context -n prod patch hpa -6 --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":4,"maxReplicas":20}}'

kubectl --context=$w_context -n prod patch hpa -103 --patch '{"spec":{"targetCPUUtilizationPercentage":45,"minReplicas":2,"maxReplicas":40}}'

#proxy hpa changes

kubectl --context=$proxy_context -n proxy-prod patch hpa -11 --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":4,"maxReplicas":15}}'

fi

