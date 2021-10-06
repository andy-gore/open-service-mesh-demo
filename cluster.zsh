#install aks-preview extension

az extension add --name aks-preview

az extension update --name aks-preview

#register osm preview feature
az feature register --namespace "Microsoft.ContainerService" --name "AKS-OpenServiceMesh"

#check if osm feature registered
az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/AKS-OpenServiceMesh')].{Name:name,State:properties.state}"

az provider register --namespace Microsoft.ContainerService

#create cluster
az group create -l westus2  -n osmrg

az aks create -g osmrg -n osm-demo-aks --node-count 1 --enable-addons monitoring --enable-managed-identity --node-osdisk-type Ephemeral --node-osdisk-size 30 --network-plugin azure --generate-ssh-keys

#get credentials
az aks get-credentials -n osm-demo-aks -g osmrg

#enable osm on the cluster
az aks enable-addons --addons open-service-mesh -g osmrg -n osm-demo-aks

#validate osm installation

az aks list -g osmrg -o json | jq -r '.[].addonProfiles.openServiceMesh.enabled'

kubectl get deployments -n kube-system --selector app=osm-controller
kubectl get pods -n kube-system --selector app=osm-controller
kubectl get services -n kube-system --selector app=osm-controller

#get OSM add-on configuration

kubectl get meshconfig osm-mesh-config -n kube-system -o yaml

#download OSM client
# Specify the OSM version that will be leveraged throughout these instructions
OSM_VERSION=v0.9.1

curl -sL "https://github.com/openservicemesh/osm/releases/download/$OSM_VERSION/osm-$OSM_VERSION-linux-amd64.tar.gz" | tar -vxzf -

sudo mv ./linux-amd64/osm /usr/local/bin/osm
sudo chmod +x /usr/local/bin/osm
