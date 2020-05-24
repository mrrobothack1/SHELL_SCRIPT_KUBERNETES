# Shell_scripts

used for creation and working for kubernetes in GCP

while :; do echo "$(date)"|tr '\n' ' ' && kubectl get hpa --context=gke_kohls-mobile-prd_us-central1-b_grservices-prd-usc1-1 --all-namespaces | grep -v "unknown" | awk '$9 != "0"' && sleep 5; done | tee -a GRhpaOCT.txt

kubectl patch hpa ingress-105 -n ingress-prod  --patch '{"spec":{"targetCPUUtilizationPercentage":60,"minReplicas":45,"maxReplicas":100}}'

Confluence for Private GKE: https://confluence.kohls.com:8443/display/MD/Private+GKE+with+restricted+access+to+cluster+master+endpoints

Concepts:

Private Cluster (No public ips)
VPC Peering
Master Authorization
Shared VPC
Cloud NAT
IP Masquerading
POD Security
Network Policy
Kubernetes Service Account & RBAC
Corporate VPN
IAM Policy
Storage
