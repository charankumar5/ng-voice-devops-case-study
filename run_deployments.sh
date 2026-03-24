kubectl apply -f calico/
sleep 2
kubectl apply -f multus/
sleep 2
kubectl apply -f cni-plugins/
sleep 2
helm install ngvoice helm-chart/ -f helm-chart/values.yaml