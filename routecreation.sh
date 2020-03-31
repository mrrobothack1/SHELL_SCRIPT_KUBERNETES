gcloud compute --project "soju-project" routes create gke-cluster-lle-usc1b-to-internet-route-01-september-00 --network "m-lle" --destination-range 0.0.0.0/0 --next-hop-instance kohls-rhel7-m-lle-natgw01-usc1b-september-00 --next-hop-instance-zone us-central1-b --priority 950 --tags "gke-cluster"

gcloud compute --project "soju-project" routes create gke-cluster-lle-usc1c-to-internet-route-01-september-01 --network "m-lle" --destination-range 0.0.0.0/0 --next-hop-instance kohls-rhel7-m-lle-natgw01-usc1c-september-01 --next-hop-instance-zone us-central1-c --priority 950 --tags "gke-cluster"

gcloud compute --project "soju-project" routes create gke-cluster-lle-usc1a-to-internet-route-01-september-02 --network "m-lle" --destination-range 0.0.0.0/0 --next-hop-instance kohls-rhel7-m-lle-natgw01-usc1a-september-02 --next-hop-instance-zone us-central1-a --priority 950 --tags "gke-cluster"

