for ns in $( kubectl get ns --no-headers |grep -i perf | awk '{ print $1 }');
do
depno=kubectl get deploy -n $ns --no-headers| awk '$2!="0/0"' | awk '{print $1}' ;

kubectl get deploy $depno -n $ns -o yaml | sed "s/10.62.242.156/10.71.241.108/g" | kubectl apply -f - 

Done
