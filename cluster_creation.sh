gcloud config set project $project
gcloud config set account admin@$project.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/$project.json"
gcloud auth activate-service-account admin@$project.iam.gserviceaccount.com --key-file=$HOME/$project.json

if [ "${cidr}" == "" ]
then

   gcloud beta container --project $project clusters create $cluster_name --zone $zone --no-enable-basic-auth --cluster-version $gke_version --machine-type $machine_type --image-type "COS" --disk-type "pd-standard" --disk-size ${disk_size} --metadata disable-legacy-endpoints=true,patching-type=2,owner-email=gcp@soju.com --scopes "https://www.googleapis.com/auth/devstorage.read_write","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes ${num_nodes} --enable-stackdriver-kubernetes --no-enable-ip-alias --network $network --subnetwork $subnet --enable-autoscaling --min-nodes ${min_nodes} --max-nodes ${max_nodes} --enable-master-authorized-networks --master-authorized-networks 66.232.224.0/20 --addons HorizontalPodAutoscaling,HttpLoadBalancing --no-enable-autoupgrade --enable-autorepair --tags ${cluster_tag},${env},${region} --node-locations ${add_zones} --enable-network-policy
else
   gcloud beta container --project $project clusters create $cluster_name --zone $zone --no-enable-basic-auth --cluster-version $gke_version --machine-type $machine_type --image-type "COS" --disk-type "pd-standard" --disk-size ${disk_size} --metadata disable-legacy-endpoints=true,patching-type=2,owner-email=gcp@soju.com --scopes "https://www.googleapis.com/auth/devstorage.read_write","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes ${num_nodes} --enable-stackdriver-kubernetes --cluster-ipv4-cidr $cidr --no-enable-ip-alias --network $network --subnetwork $subnet --enable-autoscaling --min-nodes ${min_nodes} --max-nodes ${max_nodes} --enable-master-authorized-networks --master-authorized-networks 66.232.224.0/20 --addons HorizontalPodAutoscaling,HttpLoadBalancing --no-enable-autoupgrade --enable-autorepair --tags ${cluster_tag},${env},${region} --node-locations ${add_zones} --enable-network-policy

## Istio Enable
  ## gcloud beta container --project $project clusters create $cluster_name --zone $zone --machine-type $machine_type --image-type "COS" --disk-size ${disk_size} --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_write","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes ${num_nodes} --enable-cloud-logging --enable-cloud-monitoring --enable-autoscaling --min-nodes=${min_nodes} --max-nodes=${max_nodes} --node-labels=env1=${env},app=mobile,service=all --username "gke-admin-${env}-usc1" --password "mobileadmin456789" --tags ${cluster_tag},${env},${region} --network $network --subnetwork $subnet --cluster-ipv4-cidr $cidr --cluster-version $gke_version --node-version $node_version --additional-zones ${add_zones} --enable-network-policy --addons=Istio --istio-config=auth=MTLS_PERMISSIVE
fi

cidr_range=$(gcloud container clusters describe $cluster_name --zone=$zone --format=json | jq '.clusterIpv4Cidr' | tr -d '"')
mater_endpoint=$(gcloud container clusters describe $cluster_name --zone=$zone --format=json | jq '.endpoint' | tr -d '"')
instance_grp_name=$(gcloud container clusters describe $cluster_name --zone=$zone --format=json | jq '.instanceGroupUrls' | grep "$zone" | awk -F "/" '{print $NF}' | tr -d '"' | tr -d ',')
instance_name=$(gcloud compute instance-groups list-instances $instance_grp_name --zone=$zone | awk '{print $1}' | tail -1)
tag=$(gcloud compute instances describe $instance_name --zone=$zone --format=json | jq '.tags.items[]' | grep $cluster_name | tr -d "\"")
id=$(echo "$tag" | sed 's/-node$//')
all=$(gcloud compute firewall-rules list --format=json | jq '.[] | .name' | grep $id | awk '{print $1}' | tr -d "\"" | grep -w "all")
ssh=$(gcloud compute firewall-rules list --format=json | jq '.[] | .name' | grep $id | awk '{print $1}' | tr -d "\"" | grep -w "ssh")
vms=$(gcloud compute firewall-rules list --format=json | jq '.[] | .name' | grep $id | awk '{print $1}' | tr -d "\"" | grep -w "vms")

echo $all
echo $ssh
echo $vms

source_ranges=$(gcloud compute firewall-rules describe $vms --format=json | jq '.sourceRanges[0]' | tr -d '"')

gcloud compute --project $project firewall-rules create "${all}-new" --allow sctp,tcp,udp,icmp,esp,ah --direction "INGRESS" --priority "990" --network $network --source-ranges "${cidr_range}"
gcloud compute --project $project firewall-rules create "${ssh}-new" --allow tcp:22 --direction "INGRESS" --priority "990" --network $network --source-ranges "${mater_endpoint}/32" --target-tags "${tag}"
gcloud compute --project $project firewall-rules create "${vms}-new" --allow icmp,tcp:1-65535,udp:1-65535 --direction "INGRESS" --priority "990" --network $network --source-ranges "${source_ranges}" --target-tags "${tag}"


gcloud compute firewall-rules delete $all --quiet
gcloud compute firewall-rules delete $ssh --quiet
gcloud compute firewall-rules delete $vms --quiet

gcloud compute --project=$project routes create gke-${cluster_name}-to-master-route-${BUILD_NUMBER} --network=$network --priority=900 --destination-range=${mater_endpoint}/32 --next-hop-gateway=default-internet-gateway

gcloud config set project $project
gcloud config set account admin@$project.iam.gserviceaccount.com
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/$project.json"
gcloud auth activate-service-account admin@$project.iam.gserviceaccount.com --key-file=$HOME/$project.json
gcloud container clusters get-credentials $cluster_name --zone $zone --project $project
cp gcp/cmon/clusteraccess/* .
cp gcp/pod-security-policy/* .

if [ "$channel" == "chanel1" ]
then
   kubectl apply -f mrp-restrict-psp.yaml
elif [ "$channel" == "chanel2" ]
then
   kubectl apply -f gr-restrict-psp.yaml
elif [ "$channel" == "chanel3" ]
then
   kubectl apply -f ar-restrict-psp.yaml
elif [ "$channel" == "chanel4" ]
then
   kubectl apply -f kp-restrict-psp.yaml
else
   kubectl apply -f egproxy-restrict-psp.yaml
fi
