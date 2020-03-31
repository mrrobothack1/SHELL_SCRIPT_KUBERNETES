#!/bin/bash +x

#kubectl --insecure-skip-tls-verify get ns -o json | jq 'del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status)' >> "$PWD/${1}/deploy.json";

for ns in $(cat ns.txt);
do
    echo "Namespace: $ns" ;
    #kubectl --insecure-skip-tls-verify --namespace="${ns}" get --export -o=json cronjobs,pvc,ep,rc,secrets,configmaps,svc,hpa,ds,deploy,rs,po | jq '.items[] | select(.type!="kubernetes.io/service-account-token") | del( .spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )'>> "$PWD/${1}/deploy.json";
    #kubectl --insecure-skip-tls-verify --namespace="${ns}" get     -o=json cronjobs,pvc,ep,rc,secrets,configmaps,svc,hpa,ds,deploy,rs,po | jq '.items[] | select(.type!="kubernetes.io/service-account-token") | del( .spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )'>> "$PWD/${1}/deploy.json";

    for runningDeployment in $(kubectl --insecure-skip-tls-verify get deploy -n $ns  | awk '$2!=0' | grep -v NAME | awk '{print $1}')
    do
        configMaps=$(kubectl --insecure-skip-tls-verify get deploy $runningDeployment -n $ns -o jsonpath='{range .spec.template.spec.volumes[*]}{.configMap.name}{" "}'| tr -s " ")
        if [ "$configMaps" != " " ];then
            kubectl --insecure-skip-tls-verify get cm $configMaps -n $ns -o json | jq 'del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.schedulerName,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )' >> "$PWD/${1}/deploy.json";
        fi
        secrets=$(kubectl --insecure-skip-tls-verify get deploy $runningDeployment -n $ns -o jsonpath='{range .spec.template.spec.volumes[*]}{.secret.secretName}{" "}'| tr -s " ")
        if [ "$secrets" != " " ];then
            kubectl --insecure-skip-tls-verify get secrets $secrets -n $ns -o json | jq 'del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.schedulerName,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )' >> "$PWD/${1}/deploy.json";
        fi
        kubectl --insecure-skip-tls-verify get deploy $runningDeployment -n $ns -o json | jq 'del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.schedulerName,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )' >> "$PWD/${1}/deploy.json";
    done

    for cronjob in $(kubectl --insecure-skip-tls-verify get cronjobs -n $ns  | grep -v NAME | awk '{print $1}')
    do
        configMaps=$(kubectl --insecure-skip-tls-verify get cronjob $cronjob -n $ns -o jsonpath='{range .spec.jobTemplate.spec.template.spec.volumes[*]}{.configMap.name}{" "}'| tr -s " ")
        if [ "$configMaps" != " " ];then
            kubectl --insecure-skip-tls-verify get cm $configMaps -n $ns -o json | jq ' del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.jobTemplate.spec.template.spec.securityContext,.spec.jobTemplate.spec.template.spec.dnsPolicy,.spec.jobTemplate.spec.template.spec.schedulerName,.spec.jobTemplate.spec.template.spec.terminationGracePeriodSeconds)' >> "$PWD/${1}/deploy.json";
        fi
        secrets=$(kubectl --insecure-skip-tls-verify get cronjob $cronjob -n $ns -o jsonpath='{range .spec.jobTemplate.spec.template.spec.volumes[*]}{.secret.secretName}{" "}'| tr -s " ")
        if [ "$secrets" != " " ];then
            kubectl --insecure-skip-tls-verify get secrets $secrets -n $ns -o json | jq ' del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.jobTemplate.spec.template.spec.securityContext,.spec.jobTemplate.spec.template.spec.dnsPolicy,.spec.jobTemplate.spec.template.spec.schedulerName,.spec.jobTemplate.spec.template.spec.terminationGracePeriodSeconds)' >> "$PWD/${1}/deploy.json";
        fi
        kubectl --insecure-skip-tls-verify get cronjob $cronjob -n $ns -o json | jq ' del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.jobTemplate.spec.template.spec.securityContext,.spec.jobTemplate.spec.template.spec.dnsPolicy,.spec.jobTemplate.spec.template.spec.schedulerName,.spec.jobTemplate.spec.template.spec.terminationGracePeriodSeconds)' >> "$PWD/${1}/deploy.json";        
    done

    for runningHpa in $(kubectl --insecure-skip-tls-verify get hpa -n $ns  | awk '$(NF-1)!=0'| grep -v NAME| awk '{print $1}')
    do
        kubectl --insecure-skip-tls-verify get hpa $runningHpa -n $ns -o json| jq ' del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status)' >> "$PWD/${1}/deploy.json";
    done
    
    for daemonSet in $(kubectl --insecure-skip-tls-verify get ds -n $ns | grep -v NAME | awk '{print $1}')
    do
        configMaps=$(kubectl --insecure-skip-tls-verify get ds $daemonSet -n $ns -o jsonpath='{range .spec.template.spec.volumes[*]}{.configMap.name}{" "}'| tr -s " ")
        if [ "$configMaps" != " " ];then
            kubectl --insecure-skip-tls-verify get cm $configMaps -n $ns -o json | jq 'del(.metadata.annotations,.spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )'>> "$PWD/${1}/deploy.json";
        fi
        secrets=$(kubectl --insecure-skip-tls-verify get ds $daemonSet -n $ns -o jsonpath='{range .spec.template.spec.volumes[*]}{.secret.secretName}{" "}'| tr -s " ")
        if [ "$secrets" != " " ];then
            kubectl --insecure-skip-tls-verify get secrets $secrets -n $ns -o json | jq 'del(.metadata.annotations,.spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )'>> "$PWD/${1}/deploy.json";
        fi
        kubectl --insecure-skip-tls-verify get ds $daemonSet -n $ns -o json | jq 'del(.metadata.annotations,.metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status,.spec.template.spec.securityContext,.spec.template.spec.dnsPolicy,.spec.template.spec.schedulerName,.spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )'>> "$PWD/${1}/deploy.json";     
    done

    kubectl --insecure-skip-tls-verify --namespace="${ns}" get -o=json svc,ep,pvc | jq '.items[] | del(.metadata.annotations,.spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status)' >> "$PWD/${1}/deploy.json";
done

