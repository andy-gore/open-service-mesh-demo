#create namespaces
for i in bookstore bookbuyer bookthief bookwarehouse; do kubectl create ns $i; done

#deploy application to the cluster
#note namespaces not onboarded to cluster yet
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm/release-v0.9/docs/example/manifests/apps/bookbuyer.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm/release-v0.9/docs/example/manifests/apps/bookthief.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm/release-v0.9/docs/example/manifests/apps/bookstore.yaml
kubectl apply -f https://raw.githubusercontent.com/openservicemesh/osm/release-v0.9/docs/example/manifests/apps/bookwarehouse.yaml

#check the book buyer UI app
kubectl port-forward <pod name> -n bookbuyer 8080:14001

##kubectl port-forward bookbuyer-7dbbfcf796-jqqf8 -n bookbuyer 8080:14001

#check the book thief app
kubectl port-forward <pod name> -n bookthief 8080:14001

##kubectl port-forward bookthief-7869bbddfc-tfwlv -n bookthief 8080:14001


#onboard the namespaces
osm namespace add bookstore bookbuyer bookthief bookwarehouse

#restart the existing deployments - only needd if namespaces are onboarded after the deployments have been deployed
kubectl rollout restart deployment bookbuyer -n bookbuyer
kubectl rollout restart deployment bookstore -n bookstore
kubectl rollout restart deployment bookwarehouse -n bookwarehouse
kubectl rollout restart deployment bookthief -n bookthief

#Disable OSM permissive traffic mode
kubectl patch meshconfig osm-mesh-config -n kube-system -p '{"spec":{"traffic":{"enablePermissiveTrafficPolicyMode":false}}}' --type=merge

