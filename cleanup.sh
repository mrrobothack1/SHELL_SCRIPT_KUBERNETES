#!/bin/bash
for ns in $(cat ns.txt)
do
kubectl get deploy -n $ns --sort-by=.metadata.creationTimestamp | grep 0 | awk '{print $1}'|tail -r > all.txt
sed -e '1,4d' <all.txt  >remove.txt
for dep in $(cat remove.txt)
do
echo "#########Deleting older deployments for Namespace $ns #########"
kubectl delete deploy $dep -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep env | awk '{print $1}'  | tail -r > env.txt
sed -e '1,5d' <env.txt > removeenv.txt
for cm in $(cat removeenv.txt)
do
echo "#########Deleting older envconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep app | awk '{print $1}'  | tail -r > app.txt
sed -e '1,5d' <app.txt > removeapp.txt
for cm in $(cat removeapp.txt)
do
echo "#########Deleting older appconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep kill | awk '{print $1}'  | tail -r > kill.txt
sed -e '1,5d' <kill.txt > removekill.txt
for cm in $(cat removekill.txt)
do
echo "#########Deleting older killconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep cmon | awk '{print $1}'  | tail -r > cmon.txt
sed -e '1,5d' <cmon.txt > removecmon.txt
for cm in $(cat removecmon.txt)
do
echo "#########Deleting older cmonconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;


for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep hybrid | awk '{print $1}'  | tail -r > hybrid.txt
sed -e '1,5d' <hybrid.txt > removehybrid.txt
for cm in $(cat removehybrid.txt)
do
echo "#########Deleting older hybridconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep angular | awk '{print $1}'  | tail -r > angu.txt
sed -e '1,5d' <angu.txt > removeangular.txt
for cm in $(cat removeangular.txt)
do
echo "#########Deleting older angularconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep frontend | awk '{print $1}'  | tail -r > frontend.txt
sed -e '1,5d' <frontend.txt > removefrontend.txt
for cm in $(cat removefrontend.txt)
do
echo "#########Deleting older frontendconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get secrets -n $ns --sort-by=.metadata.creationTimestamp | grep secret | awk '{print $1}'  | tail -r > secrets.txt
sed -e '1,5d' <secrets.txt > removesecrets.txt
for sec in $(cat removesecrets.txt)
do
echo "#########Deleting older secrets for Namespace $ns #########"
kubectl delete secrets $sec -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep client | awk '{print $1}'  | tail -r > client.txt
sed -e '1,5d' <client.txt > removeclient.txt
for cm in $(cat removeclient.txt)
do
echo "#########Deleting older clientconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep sites | awk '{print $1}'  | tail -r > sites.txt
sed -e '1,5d' <sites.txt > removesites.txt
for cm in $(cat removesites.txt)
do
echo "#########Deleting older sitesconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep htdoc | awk '{print $1}'  | tail -r > htdoc.txt
sed -e '1,5d' <htdoc.txt > removehdconf.txt
for cm in $(cat removehdconf.txt)
do
echo "#########Deleting older Hdconfconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;

for ns in $(cat ns.txt)
do
kubectl get cm -n $ns --sort-by=.metadata.creationTimestamp | grep nginx | awk '{print $1}'  | tail -r > nginx.txt
sed -e '1,5d' <nginx.txt > removenginx.txt
for cm in $(cat removenginx.txt)
do
echo "#########Deleting older ngixconfig for Namespace $ns #########"
kubectl delete cm $cm -n $ns
done;
done;



for ns in $(cat ns.txt)
do
kubectl get secrets -n $ns --sort-by=.metadata.creationTimestamp | grep tls-cert | awk '{print $1}'  | tail -r > tlscert.txt
sed -e '1,5d' <tlscert.txt > removetls.txt
for sec in $(cat removetls.txt)
do
echo "#########Deleting older tlscert for Namespace $ns #########"
kubectl delete secrets $sec -n $ns
done;
done;
