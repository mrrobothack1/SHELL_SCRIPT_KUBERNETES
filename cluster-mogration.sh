#./clustermigration.sh mobileservices-dev-lle-usc1 us-central1-b soju-soju-lll gke-tcom-poc1-9-4 us-central1-b soju-soju-lll
#./clustermigration.sh gke-tcom-lle-dev us-central1-b soju-soju-lll
#./clustermigration.sh gke-cluster-hle us-central1-b soju-mobile-hle
set +e
mkdir -p $PWD/${1}
gcloud container clusters get-credentials ${1} --zone ${2} --project ${3}
kubectl get -o=json ns  | jq '.items[] | select(.metadata.name!="kube-system") | select(.metadata.name!="default") | select(.metadata.name!="kube-public") | del(.status, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation )' > $PWD/${1}/ns.json

for ns in $(jq -r '.metadata.name' < $PWD/${1}/ns.json);
do
  echo "Namespace: $ns" ;
  kubectl --namespace="${ns}" get --export -o=json gateway,virtualservice,destinationrules,serviceentry,cronjobs,pvc,ep,rc,secrets,configmaps,svc,hpa,ds,deploy,rs,po | jq '.items[] | select(.type!="kubernetes.io/service-account-token") | del( .spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )'>> "$PWD/${1}/deploy.json";
done;


# for ns in $(jq -r '.metadata.name' < $PWD/cluster-dump/ns.json);
# do
#   echo "Namespace: $ns" ;
#   kubectl --namespace="${ns}" get --export -o=json svc | jq '.items[] | select(.type!="kubernetes.io/service-account-token") | del( .spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )'>> "$PWD/cluster-dump/service-dump.json";
# done;
#
# for ns in $(jq -r '.metadata.name' < $PWD/cluster-dump/ns.json);
# do
#   echo "Namespace: $ns" ;
#   kubectl --namespace="${ns}" get --export -o=json hpa | jq '.items[] | select(.type!="kubernetes.io/service-account-token") | del( .spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )'>> "$PWD/cluster-dump/hpa-dump.json";
# done;

#cat ./cluster-dump/cluster-dump.json

# Uncomment below lines to create namespaces and deployments
#gcloud container clusters get-credentials ${4} --zone ${5} --project ${6}

#kubectl create -f $PWD/cluster-dump/ns.json --validate=false
#kubectl create -f $PWD/cluster-dump/service-dump.json --validate=false
#kubectl create -f $PWD/cluster-dump/cluster-dump.json --validate=false
