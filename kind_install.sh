#!/bin/bash

# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.31.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


# validate installation
kind --version


# Install kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list 
sudo apt-get update
sudo apt-get install -y kubectl

# validate installation
kubectl version --client
#kubectl cluster-info  # only works after kind cluster is created


# create a kind cluster using config file
kind create cluster --image kindest/node:v1.29.4@sha256:3abb816a5b1061fb15c6e9e60856ec40d56b7b52bcea5f5f1350bc6e2320b6f8 --name ngvoice-cluster --config kind-config.yaml
kubectl config use-context kind-ngvoice-cluster
kubectl get nodes


# Install Calico
# Install the operator
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/tigera-operator.yaml
# Install the custom resources
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.2/manifests/custom-resources.yaml
kubectl get pods -n calico-system -o wide
kubectl get nodes -o wide

# Label nodes so MySQL pods can be pinned to specific ones (Requirement 7)
kubectl label node ngvoice-cluster-worker  database-location=node-1
kubectl label node ngvoice-cluster-worker2 database-location=node-2
kubectl get nodes --show-labels | grep database-location


# Trying to test in EKS cluster — labels should be applied to the correct nodes there as well
kubectl label node ip-10-0-1-75.eu-central-1.compute.internal  database-location=node-1
kubectl label node ip-10-0-2-212.eu-central-1.compute.internal database-location=node-2