# Shell_scripts

used for creation and working for kubernetes in GCP

while :; do echo "$(date)"|tr '\n' ' ' && kubectl get hpa --context=gke_kohls-mobile-prd_us-central1-b_grservices-prd-usc1-1 --all-namespaces | grep -v "unknown" | awk '$9 != "0"' && sleep 5; done | tee -a GRhpaOCT.txt

